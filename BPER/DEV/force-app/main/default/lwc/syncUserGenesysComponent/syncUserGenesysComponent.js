import { LightningElement, wire, api, track } from 'lwc';
import getGestoriList from '@salesforce/apex/syncUserGenesysController.getGestoriList';
import syncNewUtenti from '@salesforce/apex/syncUserGenesysController.syncNewUtenti';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const actions = [
    { label: 'Sincronizza', name: 'sincronizza' },
];

const columns = [
    { label: 'Nome e Cognome', fieldName: 'Name' },
    { label: 'Matricola', fieldName: 'FederationIdentifier', type: 'Text' },
    { label: 'Genesys ID', fieldName: 'CRM_GenesysID__c', type: 'Text' },
    { label: 'Business Unit', fieldName: 'CRM_BusinessUnitID__c', type: 'Text' },
    { label: 'Management Unit', fieldName: 'CRM_ManagementID__c', type: 'Text' },
    { label: 'Data ultimo aggiornamento Genesys', fieldName: 'CRM_DataultimasyncGenesys__c', type: 'Datetime'},
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];

export default class SyncUserGenesysComponent extends LightningElement {
    @track searchedNome = '';
    @track searchedMatricola = '';
    @track utentiPrincipaleList = [];
    @track filteredUtentiList = [];
    @track utentiListCount = 0;
    @track columns = columns;
    @track hasUtenti = false;
    @track tableLoadingState = true;
    @track searchLoaded = true;
    @track allLoaded = false;
    @track hasSearched = false;
    @track selected;

    connectedCallback() {
            
        this.handleGetGestoriPrincipale().then(() => {
            this.allLoaded = true;
            this.handleReset();
        });
    }

    async handleGetGestoriPrincipale(){

        try {

                const data = await getGestoriList({
                    profileName: '%Contact Center'
                });
                console.log('JSON.stringify(data): ' + JSON.stringify(data));
                this.utentiPrincipaleList = JSON.parse(JSON.stringify(data));


                if (data.length > 0) {
                    this.hasUtenti = true;
                }
        } catch (error) {
            
            console.log('handleGetGestoriPrincipale.error: ' + error);
        }
    }

    handleReset(){

        this.searchedNome = '';
        this.searchedMatricola = '';
        this.handleSearch();
    }

    handleSearch(){

        this.filteredUtentiList = [];

        this.hasSearched = false;
        this.page = 1;
        try {
            
            for(var i in this.utentiPrincipaleList){
                        
                if(Boolean(this.searchedNome)){

                    if(!this.utentiPrincipaleList[i].Name.toLowerCase().includes(this.searchedNome.toLowerCase())) {
    
                        continue;
                    }
                }

                if(Boolean(this.searchedMatricola)){

                    if(!this.utentiPrincipaleList[i].FederationIdentifier.toLowerCase().includes(this.searchedMatricola.toLowerCase())) {
    
                        continue;
                    }
                }
    
                this.filteredUtentiList.push(this.utentiPrincipaleList[i]);
            }
    
            console.log('LV filteredUtentiList: ' + JSON.stringify(this.filteredUtentiList));
            console.log('LV this.page: ' + this.page);
            if(this.filteredUtentiList.length > 0){
    
                this.hasUtenti = true;
            } else{

                this.hasUtenti = false;
            }
            this.hasSearched = true;
            this.setPages(this.filteredUtentiList);
        } catch (error) {
            
            console.log('LV error: ' + error);
        }
    }

    handleSyncUtenti(row){

        try {

            this.searchLoaded = false;
            
            syncNewUtenti({
                recordId: row,
            }).then(data => {
                this.searchLoaded = true;
                console.log('LV this data ' + data);
                if (data === 'success') {
                    const toastEvent = new ShowToastEvent({
                        title: "Successo!",
                        message: "Utente sincronizzato con successo!",
                        variant: "success"
                    });
                    this.dispatchEvent(toastEvent);

                }
                else {
                    const toastEvent = new ShowToastEvent({
                        title: "Attenzione!",
                        message: 'Non è stato possibile sincronizzare l\'utente',
                        variant: "warning"
                    });
                    this.dispatchEvent(toastEvent);
                }
                this.connectedCallback();

            }).catch(error => {
                this.searchLoaded = true;
                const toastEvent = new ShowToastEvent({
                    title: "Attenzione!",
                    message: error,
                    variant: "error"
                });
                this.dispatchEvent(toastEvent);
                console.log('handlesyncNewUtente.syncUtente.error: ' + JSON.stringify(error));
            })
            
        } catch (error) {
            this.searchLoaded = true;
            const toastEvent = new ShowToastEvent({
                title: "Attenzione!",
                message: error,
                variant: "error"
            });
            this.dispatchEvent(toastEvent);
            console.log('handlesyncNewUtente.error: ' + error);
        }
    }

    setFilter(event){

        if(event.target.name == 'searchedNome'){
                
            this.searchedNome = event.target.value;
        }
        else{

            this.searchedMatricola = event.target.value;
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const rowId = event.detail.row.Id;
        switch (actionName) {
            case 'sincronizza':
                this.handleSyncUtenti(rowId);
                break;
            default:
        }
    }

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
        console.log('pageData');
        let page = this.page;
        let perpage = this.perpage;
        let startIndex = (page*perpage) - perpage;
        let endIndex = (page*perpage);
        let utentiToDisplay = this.filteredUtentiList.slice(startIndex,endIndex);
        let utentiToDisplayIdList = utentiToDisplay.map(item => item.Id);
        console.log('utDisp: '+utentiToDisplay);

        return utentiToDisplay;
    }

    setPages = (data)=>{
        this.pages = [];
        let numberOfPages = Math.ceil(data.length / this.perpage);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
        console.log('LV this.pages: ' + this.pages);
    }  
    
    get disabledButtonIndietro(){
        return this.page === 1;
    }
    
    get disabledButtonAvanti(){
        return this.page === this.pages.length || this.filteredUtentiList.length === 0
    }

    

    get currentPageData(){
        return this.pageData();
    }

    get setDatatableHeight() {
        if(this.count==0){
            return 'height:2rem;';
        }
        else if(this.count>10){
                return 'height:50rem;';
        }
        return '';
    }
}