import { LightningElement, api, track} from 'lwc';

import init from '@salesforce/apex/EliminaPortafogliController.init';
import eliminaPortafogli from '@salesforce/apex/EliminaPortafogliController.eliminaPortafogli';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import MicroPortafoglio from '@salesforce/label/c.spostaNdgIter_CLM_MicroPortafoglio';
import ModelloServizio from '@salesforce/label/c.spostaNdgIter_CLM_ModelloServizio';
import Filiale from '@salesforce/label/c.spostaNdgIter_CLM_Filiale';
import Referente from '@salesforce/label/c.spostaNdgIter_CLM_Referente';

const COLUMNS = [
    {
        label: MicroPortafoglio,
        fieldName: 'Name',
        type: 'text',
        cellAttributes:{class:{fieldName: 'typeCSSClass' }}
    },
    {
        label: ModelloServizio,
        fieldName: 'PTF_ModelloDiServizio__c',
        type: 'text'
    },
    {
        label: 'Banca',
        fieldName: 'abi',
        type: 'text'
    },
    {
        label: 'Direzione Territoriale',
        fieldName: 'direzioneTerritoriale',
        type: 'text'
    },
    {
        label: Filiale,
        fieldName: 'filiale',
        type: 'text'
    },
    {
        label: Referente,
        fieldName: 'CRM_ReferenteFormula__c',
        type: 'text'
    },
    {
        label: 'Portafoglio tecnico',
        fieldName: 'PTF_isPTFTecnico__c',
        type: 'boolean'
    }
];

export default class EliminaPortafogli extends LightningElement {

    columns = COLUMNS;

    
    @track recordList;
    @track filteredList;

    @track selectedRecords;
    @track pageSelecetedRowsMap = {};
    @track pageSelecetedRowsValuesMap = {};

    @track searchedBanca = '';
    @track searchedDr = '';
    @track searchedFiliale = '';
    @track searchedMDS = '';
    @track searchedNome = '';
    @track searchedReferente = '';
    @track searchedPtfTecnico = '';

    @track loaded = false;
    @track loading = true;

    connectedCallback(){
        this.loaded = false;
        this.loading = true;
        console.log('DK EliminaPortafogli connectedCallback');
        init()
        .then(result =>{
            console.log('DK EliminaPortafogli init result', result);
            if(result){
                let abiSet = [];
                let options = [{ label: '---None---', value: '' }];
                result.recordList.forEach(element =>{
                    element.filiale = element.PTF_Filiale__r ? element.PTF_Filiale__r.Name : '';
                    element.direzioneTerritoriale = element.PTF_DirezioneRegionale__r ? element.PTF_DirezioneRegionale__r.Name : '';
                    element.banca = element.PTF_Banca__r.Name;
                    element.abi = element.PTF_Banca__r.FinServ__BankNumber__c;
                    if(!abiSet.includes(element.abi)){
                        abiSet.push(element.abi);
                    }
                })
                abiSet.forEach(abi =>{
                    options.push({
                        label: abi,
                        value: abi
                    });
                })
                this.optionsAbi = options;
                this.recordList = result.recordList;
                this.filteredList = result.recordList;
                this.setPages(this.filteredList);
            }
        })
        .catch(error =>{
            console.log('DK EliminaPortafogli init error', error.message);
        })
        .finally(() =>{
            this.loaded = true;
            this.loading = false;
        })
    }

    @track optionsMDS = [
        { label: '---None---', value: '' },
        {
            label: 'Personal',
            value: 'Personal'
        },
        {
            label: 'Small Business',
            value: 'Small Business'
        },
        {
            label: 'Private',
            value: 'Private'
        },
        {
            label: 'Consulenti Finanziari',
            value: 'Consulenti Finanziari'
        },
        {
            label: 'Corporate',
            value: 'Corporate'
        }
    ]
    @track optionsPtfTecnico = [
        { label: '---None---', value: '' },
        {
            label: 'Si',
            value: 'true'
        },
        {
            label: 'No',
            value: 'false'
        }
    ];
    @track optionsAbi = [];

    handleDeleteRows(event){
        
        this.loading = true;
        let selectedRows = [];
        Object.keys(this.pageSelecetedRowsValuesMap).forEach(pageNumber =>{
            selectedRows = selectedRows.concat(this.pageSelecetedRowsValuesMap[pageNumber]);
        })
        console.log('DK handleDeleteRows selectedRows', JSON.stringify(selectedRows));

        eliminaPortafogli({wallets: selectedRows})
        .then(() => {
            let fieldSet = ['Id'].concat(this.columns.map(element => element.fieldName));
            let doc = '<table>';   
        
            // Add all the Table Headers from @track fieldsHeader
            doc += '<tr>';
            doc += '<th bgcolor="c6c6c6">Id</th>';
            this.columns.map(element => element.label).forEach(header => {
                doc += '<th bgcolor="c6c6c6">' + header + '</th>';
            });
            doc += '</tr>';
        
            selectedRows.forEach(portafoglio => {
                doc += '<tr>';
                fieldSet.forEach(fieldName =>{

                    doc += '<td>' + portafoglio[fieldName] + '</td>';
                })
                doc += '</tr>';
            });
            doc += '</table>';
        
            var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
            let downloadElement = document.createElement('a');
            downloadElement.href = element;
            downloadElement.target = '_self';
            // use .csv or .xls as extension on below line if you want to export data
            downloadElement.download = 'Protafogli Eliminati ' + new Date().toLocaleDateString("it").replaceAll('/', '-') + '.xls';
            document.body.appendChild(downloadElement);
            downloadElement.click();

            const toastEvent = new ShowToastEvent({
                title: "Successo!",
                message: 'Portafogli eliminati con successo.',
                variant: "success"
            });
            this.dispatchEvent(toastEvent);
            this.connectedCallback();
        })
        .finally(() =>{
            this.loading = false;
        })
        .catch(error => {
            console.log('DK handleDeleteRows eliminaPortafogli error', error);
            const toastEvent = new ShowToastEvent({
                title: "Error!",
                message: 'Errore durante l\'eliminazione dei portafogli, contatta il tuo amministratore.',
                variant: "error"
            });
            this.dispatchEvent(toastEvent);
            this.loading = false;
        });
    }

    handleRowSelection(event){
        
        let selectedRows = event.detail.selectedRows.map(element => element.Id);
        this.selectedRecords = selectedRows;
        this.pageSelecetedRowsMap[this.page] = selectedRows;
        this.pageSelecetedRowsValuesMap[this.page] = event.detail.selectedRows;
    }

    get disableDelete(){
        let pages = Object.keys(this.pageSelecetedRowsMap);
        for (var i=0; i < pages.length; i++){
            if(this.pageSelecetedRowsMap[pages[i]].length > 0){
                return false;
            }
        }
        return true;
    }
    
    handleFilter(event){

        console.log('DK handleFilter Started');
        this[event.target.name] = event.target.value;
    }
    handleReset(){
        this.searchedBanca = '';
        this.searchedDr = '';
        this.searchedFiliale = '';
        this.searchedMDS = '';
        this.searchedNome = '';
        this.searchedReferente = '';
        this.searchedPtfTecnico = '';
        this.filteredList = this.recordList;
        this.setPages(this.filteredList);
    }
    handleSearch(){

        this.filteredList = [];
        this.page = 1;
        try {
            
            for(var i in this.recordList){
                        
                if(Boolean(this.searchedBanca)){
                    
                    if(!Boolean(this.recordList[i].PTF_Banca__r)){

                        continue;
                    }
                    if(this.recordList[i].PTF_Banca__r.FinServ__BankNumber__c != this.searchedBanca){
    
                        continue;
                    }
                }
                if(Boolean(this.searchedDr)){
                    
                    if(!Boolean(this.recordList[i].PTF_DirezioneRegionale__r)){

                        continue;
                    }
                    if(!this.recordList[i].PTF_DirezioneRegionale__r.Name.toLowerCase().includes(this.searchedDr.toLowerCase())){
    
                        continue;
                    }
                }
                if(Boolean(this.searchedFiliale)){
                    if(!Boolean(this.recordList[i].PTF_Filiale__r)){

                        continue;
                    }
                    if(!this.recordList[i].PTF_Filiale__r.Name.toLowerCase().includes(this.searchedFiliale.toLowerCase())){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedNome)){
                    if(!this.recordList[i].Name.toLowerCase().includes(this.searchedNome.toLowerCase())){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedReferente)){
                    
                    if(!Boolean(this.recordList[i].CRM_ReferenteFormula__c)){

                        continue
                    }
                    if(!this.recordList[i].CRM_ReferenteFormula__c.toLowerCase().includes(this.searchedReferente.toLowerCase())){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedMDS)){
                    
                    if(this.recordList[i].PTF_ModelloDiServizio__c.toLowerCase() != this.searchedMDS.toLowerCase()){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedPtfTecnico)){
                    
                    if(this.recordList[i].PTF_isPTFTecnico__c.toString().toLowerCase() != this.searchedPtfTecnico.toLowerCase()){
    
                        continue;
                    }
                }
    
                this.filteredList.push(this.recordList[i]);
            }
    
            console.log('DK filteredList: ' + JSON.stringify(this.filteredList));
            console.log('DK this.page: ' + this.page);
            this.setPages(this.filteredList);
        } catch (error) {
            
            console.log('DK error: ' + error);
        }
    }

    //Test Pagination
    @track page = 1;
    perpage = 25;
    @track pages = [];
    set_size = 25;

    handleAvanti(){
        ++this.page;
        this.selectedRecords = this.pageSelecetedRowsMap[this.page] ? this.pageSelecetedRowsMap[this.page] : [];
    }
    handleIndietro(){
        --this.page;
        this.selectedRecords = this.pageSelecetedRowsMap[this.page] ? this.pageSelecetedRowsMap[this.page] : [];
    }
    get pagesList(){
        let mid = Math.floor(this.set_size/2) + 1 ;
        if(this.page > mid){
            return this.pages.slice(this.page-mid, this.page+mid-1);
        } 
        return this.pages.slice(0,this.set_size);
    }
    pageData = ()=>{
        let page = this.page;
        let perpage = this.perpage;
        let startIndex = (page*perpage) - perpage;
        let endIndex = (page*perpage);
        return this.filteredList.slice(startIndex,endIndex)
    }
    setPages = (data)=>{
        this.pages = [];
        let numberOfPages = Math.ceil(data.length / this.perpage);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
        console.log('DK this.pages: ' + this.pages);
    }  
    get disabledButtonIndietro(){
        return this.page === 1;
    }
    get disabledButtonAvanti(){
        return this.page === this.pages.length || this.filteredList.length === 0
    }
    get currentPageData(){
        return this.pageData();
    }
}