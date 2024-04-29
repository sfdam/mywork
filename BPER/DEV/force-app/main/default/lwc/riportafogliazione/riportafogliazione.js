import { LightningElement, api, track  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import getUserInfo from '@salesforce/apex/RiportafogliazioneController.getUserInfo';
import getAllData from '@salesforce/apex/RiportafogliazioneController.getAllData';
import getInfoFiliale from '@salesforce/apex/RiportafogliazioneController.getInfoFiliale';
import noSpost from '@salesforce/apex/RiportafogliazioneController.noSpost';
import annullaRifiuto from '@salesforce/apex/RiportafogliazioneController.annullaRifiuto';

const disclaimer="IN CASO DI CAMBIO MICROPORTAFOGLIO DI DESTINAZIONE, SI RICORDA DI SELEZIONARNE UNO COERENTE CON MACRO-MODELLO DI SERVIZIO, PENA IL MANCATO RECEPIMENTO DELLA MODIFICA";
const COLUMNS = [
    {
        label: 'NDG',
        initialWidth: 100,
        fieldName: 'NDG__c',
        type: 'text'
    },
    {
        label: 'Denominazione',
        initialWidth: 200,
        fieldName: 'Denominazione',
        type: 'text'
    },
    {
        label: 'Portafoglio di partenza',
        initialWidth: 200,
        fieldName: 'Portafoglio_Di_Partenza__c',
        type: 'text'
    },
    {
        label: 'MMDS',
        initialWidth: 100,
        fieldName: 'MMDS__c',
        type: 'text'
    },
    {
        label: 'Patrimonio',
        initialWidth: 150,
        fieldName: 'Patrimonio',
        type: 'currency'
    },
    {
        label: 'Fatturato',
        initialWidth: 150,
        fieldName: 'Fatturato',
        type: 'currency'
    },
    {
        label: 'Accordato',
        initialWidth: 150,
        fieldName: 'Accordato',
        type: 'currency'
    },
    {
        label: 'Utilizzato',
        initialWidth: 150,
        fieldName: 'Utilizzato',
        type: 'currency'
    },
    {
        label: 'MMDS Obiettivo',
        initialWidth: 150,
        fieldName: 'MMDS_Obiettivo__c',
        type: 'text'
    },
    {
        label: 'Portafoglio di destinazione',
        initialWidth: 200,
        fieldName: 'Portafoglio_Di_Destinazione__c',
        type: 'text'
    },
    {
        label: 'Stato Spostamento',
        fieldName: '',
        initialWidth: 200,
        type: 'Boolean',
        cellAttributes: {
            iconName: { fieldName: 'StatoIcon' },
            iconPosition: 'left'
        }
    },
    {
        label: 'Motivo di rifiuto',
        initialWidth: 200,
        fieldName: 'Motivo_di_rifiuto__c',
        type: 'text'
    },
    {
        label: 'Portafoglio alternativo',
        initialWidth: 200,
        fieldName: 'Portafoglio_Alternativo_Name__c',
        type: 'text'
    },
    {
        label: 'Altro',
        initialWidth: 300,
        fieldName: 'Altro__c',
        type: 'text'
    },
];



export default class Riportafogliazione extends LightningElement {

    @api nascondiRifiuta;
    @api nascondiAnnRifiuto;
    @track searchedNome;
    @track loaded=false;
    @track searchedNDG;
    @track searchedMWOld;
    @track searchedMWNew;
    @track lookupResult={};
    @track filteredRecords=[];
    @track rifiutoValue;
    @track altroValue;
    @track records=[];
    @api title;
    @track conditionObj={};
    @api tipoImpurezza;
    @api labelChangeMW;
    @api labelNoSpost;
    @api optionsRifiutoString;
    @track selectedWallet;
    @track selectedRows=[];
    @track openmodal=false;
    @track isRifiutaDisabled=false;
    @track makerequired=false;
    @track isRifiuta=false;
    @track isSpoke=false;
    @track listWalletExclude=[];
    @track throwWarning=false;
    @track condition;
    @track searchedMMDSOb;
    @track searchedMMDS;
    @track searchedPatrimonio;
    @track searchedPatrimonioMin;
    @track searchedUtilizzato;
    @track searchedUtilizzatoMin;

    get optionsRifiuto() {
        let temp= this.optionsRifiutoString.split(',');
        let result=[];
        temp.forEach(element => {
            let tempObj={};
            tempObj.value=element;
            tempObj.label=element;
            result.push(tempObj);
        });
        return result;
    }

    columns=COLUMNS;
    fieldhelper=disclaimer;
    connectedCallback() {
        getInfoFiliale().
        then(result => {
           console.log('@@result'+JSON.stringify(result)); 
           this.conditionObj=result;
           if(result.hasOwnProperty('capofilaCondition')){
                this.isSpoke=true;
           }
           console.log('@@@condition'+this.conditionObj);
           this.isRifiutaDisabled=true;

        }).catch(error => {

            console.log('DK init.error: ' + JSON.stringify(error.body));
        });
        
    }
    handleBack(){
        this.isRifiuta=false;
        this.altroValue='';
        this.rifiutoValue='';
        this.template.querySelector('c-custom-lookup').removeSelectedItem();
    }

    handleChangeMotivo(event){
        this.rifiutoValue=event.target.value;
        console.log('sonoqui'+this.rifiutoValue);
        if(this.rifiutoValue==='Altro (specificare)'){
            console.log('sonoqui');
            this.makerequired=true;
        }
        else{
            this.makerequired=false;
        }
    }

    handleChangeAltro(event){
        this.altroValue=event.target.value;
    }
    
    handleSave(){
        const allValid = [...this.template.querySelectorAll('lightning-combobox'),...this.template.querySelectorAll('lightning-textarea')]
        .reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if(allValid){
            noSpost({walletId: this.selectedWallet,
                    recordIds: this.selectedRows,
                    motivo: this.rifiutoValue,
                    altro: this.altroValue
            }).
            then(result => {
                const toastEvent = new ShowToastEvent({
                    title: "Successo!",
                    message: "Salvataggio avvenuto con successo!",
                    variant: "success"
                });
                this.dispatchEvent(toastEvent);
                this.loaded=false;
                this.queryData();
                this.isRifiuta=false;
                this.selectedRows=[];
                this.isRifiutaDisabled=true;
                this.altroValue='';
                this.rifiutoValue='';
                this.template.querySelector('c-custom-lookup').removeSelectedItem();
    
            }).catch(error => {
                const toastEvent = new ShowToastEvent({
                    title: "Errore!",
                    message: "Qualcosa è andato storto!",
                    variant: "error"
                });
                this.dispatchEvent(toastEvent);
                console.log('DK init.error: ' + JSON.stringify(error.body));
            });
        }
       
    }
    handleAnnullaRifiuta(){
        annullaRifiuto({recordIds: this.selectedRows}).
        then(result => {
            const toastEvent = new ShowToastEvent({
                title: "Successo!",
                message: "Salvataggio avvenuto con successo!",
                variant: "success"
            });
            this.dispatchEvent(toastEvent);
            this.loaded=false;
            this.queryData();
            this.selectedRows=[];
            this.isRifiutaDisabled=true;
        }).catch(error => {
            const toastEvent = new ShowToastEvent({
                title: "Errore!",
                message: "Qualcosa è andato storto!",
                variant: "error"
            });
            this.dispatchEvent(toastEvent);
            console.log('DK init.error: ' + JSON.stringify(error.body));
        });
    }
    handleSelect(event){
        this.listWalletExclude=[];
        let rows=event.detail.selectedRows;
        this.selectedRows=rows.map(item=>item.Id);
        var mmds;
        if(rows.length>0){
            mmds=rows[0].MMDS__c;
        }
        
        this.throwWarning=false;
        rows.forEach(element=>{
            let walOld;
            let walNew;
            if(element.hasOwnProperty('Portafoglio_Old__c')){
                walOld='\''+element.Portafoglio_Old__c+'\'';
                this.listWalletExclude.push(walOld);
            }
            if(element.hasOwnProperty('Portafoglio_New__c')){
                walNew='\''+element.Portafoglio_New__c+'\'';
                this.listWalletExclude.push(walNew);
            }
            
            
            if(element.MMDS__c!==mmds){
                this.throwWarning=true;
            }
        });
        if(this.selectedRows.length>0){
            this.isRifiutaDisabled=false;
            let tempCond;
            if(this.isSpoke && Boolean(mmds=='POE') && Boolean(this.tipoImpurezza=='UPGRADE')){
                console.log('@@@@sonoif');
                tempCond= '( '+this.conditionObj.filialeCondition + ' OR '+this.conditionObj.capofilaCondition+' ) '+' AND Id NOT IN ('+ this.listWalletExclude.join(',')+')';
            }
            else{
                console.log('@@@@sonoelse');
                tempCond= this.conditionObj.filialeCondition +' AND Id NOT IN ('+ this.listWalletExclude.join(',')+')';
            }
            this.condition=tempCond;
            console.log('@@@cond '+this.condition);
        }
        else{
            this.isRifiutaDisabled=true;
            
        }
    }

    handleNoSpost(){
        
        if(this.throwWarning){
            const toastEvent = new ShowToastEvent({
                title: "Attenzione!",
                message: "Non è possibile selezionare NDG afferenti a diversi MDS!",
                variant: "warning"
            });
            this.dispatchEvent(toastEvent);
        }
        else{
            this.isRifiuta=true;
        }
        
    }

    queryData(){
        getAllData({tipoImpurezza: this.tipoImpurezza}).
        then(result => {
            
            result.forEach(element =>{
                //element.StatoIcon=element.Stato_Spostamento__c? 'utility:check' : '';
                if(element.hasOwnProperty('NDGId__c')){
                    element.Denominazione=element.NDGId__r.Name;
                }
                if(element.hasOwnProperty('NDGId__c')){
                    element.Patrimonio=element.NDGId__r.PTF_Patrimonio__c;
                }
                if(element.hasOwnProperty('NDGId__c')){
                    element.Accordato=element.NDGId__r.PTF_Accordato__c;
                }
                if(element.hasOwnProperty('NDGId__c')){
                    element.Utilizzato=element.NDGId__r.PTF_Utilizzato__c;
                }
                if(element.hasOwnProperty('NDGId__c')){
                    element.Fatturato=element.NDGId__r.AnnualRevenue;
                }
                if(element.hasOwnProperty('Portafoglio_Old__c')){
                    element.MMDS__c=element.Portafoglio_Old__r.PTF_ModelloDiServizio__c;
                }
            });
            this.records = result.sort(function(a,b){
                if(a.NDGId__r.PTF_IndiceSegmentoComportamentale__c>b.NDGId__r.PTF_IndiceSegmentoComportamentale__c){
                    return -1;
                }
                else if(a.NDGId__r.PTF_IndiceSegmentoComportamentale__c<b.NDGId__r.PTF_IndiceSegmentoComportamentale__c){
                    return 1;
                }
                else{
                    if((a.NDGId__r.RecordType.DeveloperName==='Cointestazione' ||  a.NDGId__r.RecordType.DeveloperName==='PersonAccount') && (b.NDGId__r.RecordType.DeveloperName==='Cointestazione' ||  b.NDGId__r.RecordType.DeveloperName==='PersonAccount')){
                        if(a.NDGId__r.PTF_Patrimonio__c>b.NDGId__r.PTF_Patrimonio__c){
                            return -1;
                        }
                        else if(a.NDGId__r.PTF_Patrimonio__c<=b.NDGId__r.PTF_Patrimonio__c){
                            return 1;
                        }
                    }
                    else if((a.NDGId__r.RecordType.DeveloperName==='Cointestazione' ||  a.NDGId__r.RecordType.DeveloperName==='PersonAccount') && b.NDGId__r.RecordType.DeveloperName!=='Cointestazione' &&  b.NDGId__r.RecordType.DeveloperName!=='PersonAccount'){
                        if(a.NDGId__r.PTF_Patrimonio__c>b.NDGId__r.PTF_Accordato__c){
                            return -1;
                        }
                        else if(a.NDGId__r.PTF_Patrimonio__c<=b.NDGId__r.PTF_Accordato__c){
                            return 1;
                        }
                    }
                    else if(a.NDGId__r.RecordType.DeveloperName==='IndustriesBusiness' && a.NDGId__r.RecordType.DeveloperName!==b.NDGId__r.RecordType.DeveloperName){
                        if(a.NDGId__r.PTF_Accordato__c>b.NDGId__r.PTF_Patrimonio__c){
                            return -1;
                        }
                        else if(a.NDGId__r.PTF_Accordato__c<=b.NDGId__r.PTF_Patrimonio__c){
                            return 1;
                        }
                    }
                    else{
                        if(a.NDGId__r.PTF_Accordato__c>b.NDGId__r.PTF_Accordato__c){
                            return -1;
                        }
                        else if(a.NDGId__r.PTF_Accordato__c<=b.NDGId__r.PTF_Accordato__c){
                            return 1;
                        }
                    }
                }
            });
            this.filteredRecords = this.records;
            this.setPages(this.filteredRecords);
            this.loaded=true;

        }).catch(error => {

            console.log('DK init.error: ' + JSON.stringify(error.body));
        });
    }
    openModal(){
        this.openmodal=true;
        this.queryData();
    }
    closeModal(){
        this.searchedNome = '';
        this.searchedNDG = '';
        this.searchedMWOld='';
        this.searchedMWNew='';
        this.searchedPatrimonio=null;
        this.searchedPatrimonioMin=null;
        this.searchedUtilizzato=null;
        this.searchedUtilizzatoMin=null;
        this.searchedMMDS='';
        this.searchedMMDSOb='';
        this.page = 1;
        this.openmodal=false;
        this.isRifiuta=false;
        this.selectedRows=[];
    }
    handleReset(){

        this.searchedNome = '';
        this.searchedNDG = '';
        this.searchedMWOld='';
        this.searchedMWNew='';
        this.searchedPatrimonio=null;
        this.searchedPatrimonioMin=null;
        this.searchedUtilizzato=null;
        this.searchedUtilizzatoMin=null;
        this.searchedMMDS='';
        this.searchedMMDSOb='';
        this.handleSearch();
    }

    handleCustomEvent(event) {
        if(event.detail!=null ){
            this.selectedWallet=event.detail.objId;
        }
        else{
            this.selectedWallet=null;
        }
            
        console.log('@@@@@selectedWallet: '+JSON.stringify(this.selectedWallet)); 
    }

   
    handleFilter(event){

        if(event.target.name == 'searchedNome'){
                
            this.searchedNome = event.target.value;
        }
        else if(event.target.name == 'searchedNDG'){
                
            this.searchedNDG = event.target.value;
        }
        else if(event.target.name == 'searchedMWOld'){
                
            this.searchedMWOld = event.target.value;
        }
        else if(event.target.name == 'searchedMWNew'){
                
            this.searchedMWNew = event.target.value;
        }
        else if(event.target.name == 'searchedPatrimonio'){
                
            this.searchedPatrimonio = event.target.value;
        }
        else if(event.target.name == 'searchedUtilizzato'){
                
            this.searchedUtilizzato = event.target.value;
        }
        else if(event.target.name == 'searchedPatrimonioMin'){
                
            this.searchedPatrimonioMin = event.target.value;
        }
        else if(event.target.name == 'searchedUtilizzatoMin'){
                
            this.searchedUtilizzatoMin = event.target.value;
        }
        else if(event.target.name == 'searchedMMDS'){
                
            this.searchedMMDS = event.target.value;
        }
        else if(event.target.name == 'searchedMMDSOb'){
                
            this.searchedMMDSOb = event.target.value;
        }
    }
    
    handleSearch(){

        this.filteredRecords = [];
        this.page = 1;
        try {
            
            for(var i in this.records){
                  
                if(Boolean(this.searchedNome)){

                    if(!this.records[i].Denominazione.toLowerCase().includes(this.searchedNome.toLowerCase())){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedNDG)){

                    if(!this.records[i].NDG__c.toLowerCase().includes(this.searchedNDG.toLowerCase())){
    
                        continue;
                    }
                }

                
                if(Boolean(this.searchedMWOld)){

                    if(!this.records[i].Portafoglio_Di_Partenza__c.toLowerCase().includes(this.searchedMWOld.toLowerCase())){
    
                        continue;
                    }
                }

                
                if(Boolean(this.searchedMWNew)){

                    if(!this.records[i].Portafoglio_Di_Destinazione__c.toLowerCase().includes(this.searchedMWNew.toLowerCase())){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedMMDS)){

                    if(!this.records[i].MMDS__c.toLowerCase().includes(this.searchedMMDS.toLowerCase())){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedMMDSOb)){

                    if(!this.records[i].MMDS_Obiettivo__c.toLowerCase().includes(this.searchedMMDSOb.toLowerCase())){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedPatrimonio)){

                    if(this.records[i].Patrimonio>this.searchedPatrimonio){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedPatrimonioMin)){

                    if(this.records[i].Patrimonio<this.searchedPatrimonioMin || this.records[i].Patrimonio==undefined){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedUtilizzatoMin)){

                    if(this.records[i].Utilizzato<this.searchedUtilizzatoMin || this.records[i].Utilizzato==undefined){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedUtilizzato)){

                    if(this.records[i].Utilizzato>this.searchedUtilizzato){
    
                        continue;
                    }
                }
    
                this.filteredRecords.push(this.records[i]);
            }
    
            
           
            this.setPages(this.filteredRecords);
        } catch (error) {
            
            console.log('DK error: ' + error);
        }
    }    
    //Pagination
    @track page = 1;
    perpage = 25;
    @track pages = [];
    set_size = 25;
    

    handleAvanti(){
        ++this.page;
    }
    handleIndietro(){
        --this.page;
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