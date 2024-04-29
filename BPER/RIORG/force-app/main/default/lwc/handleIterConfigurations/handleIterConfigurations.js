import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getIterConfigurations from '@salesforce/apex/HandleIterConfigurationsController.getIterConfigurations';
import createIterConfiguration from '@salesforce/apex/HandleIterConfigurationsController.createIterConfiguration';
import saveIterConfigurations from '@salesforce/apex/HandleIterConfigurationsController.saveIterConfigurations';
import getUsedTipiConfigurazione from '@salesforce/apex/HandleIterConfigurationsController.getUsedTipiConfigurazione';
import deleteIterConfigurations from '@salesforce/apex/HandleIterConfigurationsController.deleteIterConfigurations';

export default class HandleIterConfigurations extends LightningElement
{
    @track openDialog;
    @api options;
    @track selABI;
    @track allConfigs = {};
    @track showTable;
    @track showFields;
    @track searchedUnita;
    @track searchedDT;
    @track searchedABI;
    @track disableDelete = true;
    @track disableCreate = true;
    @track selectedRows;
    @track noRows;
    // aggiungi iter
    @track selTipo;
    @track selGiorni;
    selUnita;
    @track tipoColumns;
    @track columns = [
        { label: 'Unità Organizzativa', fieldName: 'nomeUnita' },
        { label: 'Direzine Territoriale', fieldName: 'nomeDT' },
        { label: 'ABI', fieldName: 'Abi__c' },
        { label: 'Tipo Spostamento', fieldName: 'TipoSpostamento__c'},
        { label: 'Giorni Annullamento', fieldName: 'GiorniAnnullamento__c', editable: true, type: 'number'}
    ];

    @track loading = false;
    @track loadingModal = false;

    //@track optionsJSON;

    // In connectedCallBack
    connectedCallback()
    {
        return getIterConfigurations()
        .then(result =>{

            console.log('DK handleSearch_result:', result);
            result.forEach(row => {
                row.nomeUnita = row.UnitaOrganizzativa__r.Name;
                row.nomeDT = row.UnitaOrganizzativa__r.RecordType.Name == 'Filiale di relazione' ? row.UnitaOrganizzativa__r.PTF_DirezioneRegionale__r.Name : '';
            });
            this.showTable = true;
            this.data = result;
            this.filteredRecords = this.data;
            this.noRows = this.filteredRecords.length==0;
            this.selectedRows = [];
            this.selectedRecordsIds = [];
            this.setPages(this.filteredRecords);
        }).catch(error =>{
            console.log('DK handleSearch_error:', error);
        })
    }

    accountFilter = "RecordType.DeveloperName IN ('FilialeDiRelazione', 'DirezioneRegionale')";

    get getOptions()
    {
        console.log(this.options)
        return JSON.parse(this.options);
    }

    handleGetSelectedRecords(event)
    {
        this.selectedRows = event.detail.selectedRows;
        this.selectedRecordsIds = this.selectedRows.map(element => element.Id);
        if(this.selectedRows.length > 0)
        {
            this.disableDelete = false
        }
        else
        {
            this.disableDelete = true
        }
    }

    @track errors = {};
    handleSaveTable(event) {
        
        try {
            this.loading = true;
            let configErrors = [];
            this.errors.table = null;
            this.errors.rows = {};
            this.errors = {...this.errors}
            let hasError = false;
            console.log(event.detail.draftValues);
            let recordsToUpdate = [];
            event.detail.draftValues.forEach(updatedRow => {
                let row = this.data.find(item => item.Id === updatedRow.Id);
                Object.assign(row, updatedRow);
                if(updatedRow.GiorniAnnullamento__c < 3){
                    hasError = true;
                    configErrors.push(updatedRow.Id);
                    this.errors.rows[updatedRow.Id] = {
                        title: 'Errore',
                        messages: [
                            'Il valore minimo di giorni per l\'annullamento è di 3'
                        ],
                        fieldNames: ['GiorniAnnullamento__c']
                    },
                    this.errors.table= {
                        title: 'Ci sono degli errori',
                    }
                }
                recordsToUpdate.push(row);
            });
            
            if(hasError){

                this.errors.table.messages = [];
                configErrors.forEach(Id =>{
                    this.errors.table.messages.push('Ci sono degli errori');
                });
                this.loading = false;
            }else{
                console.log('DK recordsToUpdate:', recordsToUpdate);
                saveIterConfigurations({iterConfigs: recordsToUpdate})
                .then(() => {
                    const evt = new ShowToastEvent({
                        title: 'Record di configurazione aggiornati correttamente',
                        variant: 'success'
                    });
                    this.dispatchEvent(evt);
                    this.loading = false;
                }).catch(error =>{
                    const evt = new ShowToastEvent({
                        title: 'Ci sono stati dei problemi durante il salvataggio. Contattare il proprio Amministratore di sistema.',
                        variant: 'error'
                    });
                    this.dispatchEvent(evt);
                    console.log(error);
                    this.loading = false;
                })
                this.handleCloseModal();
            }
        } catch (error) {
            console.log(error);
        }

        event.target.draftValues = [];
    }

    handleDeleteRows()
    {   
        this.loading = true;
        let configurationsTable = this.template.querySelector("[data-item='configurationsTable']");
        let selectedRows = [];
        // aggiungo alla lista degli elementi selzionati le righe nelle pagina corrente
        if(configurationsTable){
            selectedRows = configurationsTable.getSelectedRows();
        }
        // aggiungo alla lista degli elementi selzionati le righe nelle altre pagine
        for(let currentPage of Object.keys(this.selectRowsMapValues)){
            if(currentPage != this.page){
                this.selectRowsMapValues[currentPage].forEach(element =>{

                    selectedRows.push(element);
                });
            }
        }

        console.log('DK selectedRows:', selectedRows);
        deleteIterConfigurations({iterConfigs: selectedRows})
        .then(() => {
            // this.handleSearch();
            const evt = new ShowToastEvent({
                title: 'Record di configurazione eliminati correttamente',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }).catch(error =>{
            this.loading = false;
            console.log(error);
        }).finally(() =>{
            this.connectedCallback()
            .then(() => {
                this.page = 1;
                // this.setConfigurationTabel();
                this.loading = false;
                this.handleCloseModal();
            });
        })
    }

    /*handleChangeABI(event)
    {   
        try {
            
            this.selABI = event.target.value;
            this.setConfigurationTabel();
        } catch (error) {
            console.log(error);
        }
    }

    setConfigurationTabel(){
        console.log('DK this.selABI', this.selABI);
        if(Boolean(this.selABI)){

            this.showTable = true;
            this.filteredRecords = this.selABI === '05387' ? this.allConfigs.bperList : this.allConfigs.bdsList;
            this.data = this.filteredRecords;
            // this.handleSearch();
            console.log('DK this.filteredRecords', this.filteredRecords);
            this.noRows = this.filteredRecords.length==0;
            this.selectedRows = [];
            this.selectedRecordsIds = [];
            this.setPages(this.filteredRecords);
        }
    }*/

    handleFormInputChange(event){
        if( event.target.name == 'tipoSpostamento' ){
            this.selTipo = event.target.value;
        }
        else if( event.target.name == 'giorniAnnullamento' ){
            this.selGiorni = event.target.value;
        }
        else if( event.target.name == 'searchedUnita' ){
            this.searchedUnita = event.target.value;
        }
        else if( event.target.name == 'searchedDT' ){
            this.searchedDT = event.target.value;
        }
        else if( event.target.name == 'searchedABI' ){
            this.searchedABI = event.target.value;
        }
        this.canCreate();
    }

    canCreate()
    {
        if(this.selTipo && this.selGiorni){
            this.disableCreate = false;
        }else{
            this.disableCreate = true;
        }
    }

    handleOpenModal()
    {
        this.openDialog = true;
        this.canCreate();
    }

    handleCloseModal()
    {
        this.openDialog = false;
        this.showFields = false;
    }

    @track allSelected;
    handleCustomEvent(event)
    {   
        try {
            
            if(event.detail!=null ){
                this.selUnita = event.detail.obj;
                this.showFields = true;
            }
            else{
                this.selUnita = null;
                this.showFields = false;
            }
            
            console.log('DK this.selUnita:', JSON.stringify(this.selUnita));
            getUsedTipiConfigurazione({unitaOrganizzativa: this.selUnita, isFiliale: (this.selUnita != null ? this.selUnita.RecordTypeName__c == 'Filiale di relazione' : false)})
            .then(results =>{
    
            let tipoColumns = [
                { label: 'MDS', value: 'MDS' },
                { label: 'Filiale', value: 'Filiale' },
                { label: 'MDS / Filiale', value: 'MDS / Filiale' },
                { label: 'Referenti', value: 'Referenti' },
            ];
    
            this.tipoColumns = tipoColumns.filter(item => !results.includes(item.value));
            this.allSelected = this.tipoColumns.length == 0;
            console.log('DK this.allSelected: ', this.allSelected);
            //this.tipoColumns = result;
            }).catch(error =>{
                console.log(error);
            })
        } catch (error) {
            console.log(error);
        }
    }

    handleCreateConfig()
    {
        if(Number(this.selGiorni) < 3){
            const evt = new ShowToastEvent({
                title: 'Il valore minimo di giorni per l\'annullamento è di 3',
                variant: 'warning'
            });
            this.dispatchEvent(evt); 
        }else{
            
            this.loadingModal = true;
            createIterConfiguration({unitaOrganizzativa: this.selUnita, tipoSpostamento: this.selTipo, giorniAnnullamento: this.selGiorni})
            .then(() => {
                const evt = new ShowToastEvent({
                    title: 'Aggiunta nuova IterConfiguration',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.selGiorni = null;
                this.selTipo = null;
                this.selUnita = null;
            }).catch(error =>{
                this.loadingModal = false;
                console.log(error);
            }).finally(() =>{
                this.connectedCallback()
                .then(() => {
                    this.page = 1;
                    // this.setConfigurationTabel();
                    this.loadingModal = false;
                    this.handleCloseModal();
                });
            })
        }
    }

    handleReset(){
        this.searchedUnita = '';
        this.searchedDT = '';
        this.searchedABI = '';
        this.handleSearch();
    }

    handleSearch(){

        this.filteredRecords = [];
        this.page = 1;
        try {
            for(var i in this.data){
                if(Boolean(this.searchedUnita)){
                    if(!this.data[i].nomeUnita.toLowerCase().includes(this.searchedUnita.toLowerCase())){
                        continue;
                    }
                }
                if(Boolean(this.searchedDT)){
                    if(!this.data[i].nomeDT.toLowerCase().includes(this.searchedDT.toLowerCase())){
                        continue;
                    }
                }
                if(Boolean(this.searchedABI)){
                    if(this.data[i].Abi__c != this.searchedABI.toLowerCase()){
                        continue;
                    }
                }
                this.filteredRecords.push(this.data[i]);
            }
    
            console.log('DK handleSearch_filteredRecords: ' + JSON.stringify(this.filteredRecords));
            this.setPages(this.filteredRecords);
        } catch (error) {
            
            console.log('DK handleSearch_error: ' + error);
        }
    }

    //Pagination
    @track filteredRecords = [];
    @track data = [];
    @track page = 1;
    perpage = 25;
    @track pages = [];
    set_size = 25;

    @api selectedRecordsIds = [];
    @track selectRowsMap = {};
    @track selectRowsMapValues = {};
    

    handleAvanti(){
        try {
            
            let selectedRows = this.template.querySelector("[data-item='configurationsTable']").getSelectedRows();
            console.log('DK handleAvanti_selectedRows', selectedRows);
            let selectedRowIds = selectedRows.map(element => element.Id);
            console.log('DK handleAvanti_selectedRowIds', selectedRowIds);
            this.selectRowsMapValues[this.page] = selectedRows;
            this.selectRowsMap[this.page] = selectedRowIds;
            console.log('DK handleAvanti_this.selectRowsMapValues', JSON.stringify(this.selectRowsMapValues));
            console.log('DK handleAvanti_this.selectRowsMap', JSON.stringify(this.selectRowsMap));
            this.selectedRecords = Boolean(this.selectRowsMapValues[this.page+1]) ? this.selectRowsMapValues[this.page+1] : [];
            this.selectedRecordsIds = Boolean(this.selectRowsMap[this.page+1]) ? this.selectRowsMap[this.page+1] : [];
            ++this.page;
        } catch (error) {
            console.log('DK handleAvanti_error:', error);
        }
    }
    handleIndietro(){
        try {
            
            let selectedRows = this.template.querySelector("[data-item='configurationsTable']").getSelectedRows();
            console.log('DK handleIndietro_selectedRows', selectedRows);
            let selectedRowIds = selectedRows.map(element => element.Id);
            console.log('DK handleIndietro_selectedRowIds', selectedRowIds);
            this.selectRowsMapValues[this.page] = selectedRows;
            this.selectRowsMap[this.page] = selectedRowIds;
            console.log('DK handleIndietro_this.selectRowsMapValues', JSON.stringify(this.selectRowsMapValues));
            console.log('DK handleIndietro_this.selectRowsMap', JSON.stringify(this.selectRowsMap));
            this.selectedRecords = Boolean(this.selectRowsMapValues[this.page-1]) ? this.selectRowsMapValues[this.page-1] : [];
            this.selectedRecordsIds = Boolean(this.selectRowsMap[this.page-1]) ? this.selectRowsMap[this.page-1] : [];
            --this.page;
        } catch (error) {
            console.log('DK handleIndietro_error:', error);
        }
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
        let recordToDisplay = this.filteredRecords.slice(startIndex,endIndex);
        //let recordToDisplayIdList = recordToDisplay.map(item => item.Id);

        

        return recordToDisplay;
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
        return this.page === this.pages.length || this.filteredRecords.length === 0
    }    

    get currentPageData(){
        return this.pageData();
    }
    //Pagination
}