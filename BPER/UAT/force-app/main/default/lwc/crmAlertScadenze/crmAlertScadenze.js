import { LightningElement, track, api, wire } from 'lwc';
import getAllData from '@salesforce/apex/AlertScadenzeController.getAllData';
import { NavigationMixin } from "lightning/navigation";

import img_ndgcointestatario from '@salesforce/resourceUrl/ndgcointestatario';
import img_ndgintestatario from '@salesforce/resourceUrl/ndgintestatario';

const columns = [
    { label: 'Tipo', type: 'image',initialWidth: 70, typeAttributes:{url: {fieldName:'immagine'}},},
    { label: 'NUMERO SCAD.', fieldName: 'Name_url', type:'url',sortable:"true", initialWidth: 160,
        typeAttributes: {
            label: { fieldName: 'Name' }
        },
    },
    { label: 'CED', fieldName: 'CRM_CED__c', type: 'text',initialWidth: 70 },
    { label: 'TIPO SCAD.', fieldName: 'CRM_TipologiaScadenza__c', type: 'text',initialWidth: 115 },
    { label: 'DATA', fieldName: 'CRM_FormulaData__c', type: 'date',sortable:"true",initialWidth: 110 },
    { label: 'IMPORTO', fieldName: 'CRM_Importo__c', type: 'currency',sortable:"true",initialWidth: 125, cellAttributes: { alignment: 'left' },
        typeAttributes: { currencyCode: 'EUR', minimumFractionDigits: '2'} 
    },
    { label: 'PRODOTTO', fieldName: 'CRM_ProdottoCommDS__c', type: 'text',initialWidth: 135},
    /*{ label: 'PRODOTTO', fieldName: 'FinancialAccount_url', type: 'url',initialWidth: 135,
        typeAttributes: {
            label: { fieldName: 'FinServ__FinancialAccount__r' }
        }, 
    },
    { label: 'DESCRIZIONE', fieldName: 'Descrizione_Prodotto', type: 'text',initialWidth: 150 }, 
    { label: 'CODICE PRODOTTO', fieldName: 'CRM_CodiceProdottoElementare__c', type: 'text',initialWidth: 170 }, */
    { label: 'ESITO CONTATTO', fieldName: 'CRM_EsitoContatto__c', type: 'picklist',initialWidth: 150 },  
];

const allColumns = [
    { label: 'Tipo', type: 'image',initialWidth: 70, typeAttributes:{url: {fieldName:'immagine'}},},
    { label: 'NUMERO SCAD.', fieldName: 'Name_url',sortable:"true", type:'url',
        typeAttributes: {
            label: { fieldName: 'Name' }
        },
    },
    { label: 'CED', fieldName: 'CRM_CED__c', type: 'text' },
    { label: 'TIPO SCAD.', fieldName: 'CRM_TipologiaScadenza__c', type: 'text' },
    { label: 'DATA', fieldName: 'CRM_FormulaData__c', type: 'date',sortable:"true"},
    { label: 'IMPORTO', fieldName: 'CRM_Importo__c', type: 'currency',sortable:"true",cellAttributes: { alignment: 'left' },
        typeAttributes: { currencyCode: 'EUR', minimumFractionDigits: '2'}  },
        { label: 'PRODOTTO', fieldName: 'CRM_ProdottoCommDS__c', type: 'text'},
   /* { label: 'PRODOTTO', fieldName: 'FinancialAccount_url', type: 'url',
        typeAttributes: {
            label: { fieldName: 'FinServ__FinancialAccount__r' }
        }, 
    },
    { label: 'DESCRIZIONE', fieldName: 'Descrizione_Prodotto', type: 'text',initialWidth: 150 },
    { label: 'CODICE PRODOTTO', fieldName: 'CRM_CodiceProdottoElementare__c', type: 'text'},*/
    { label: 'ESITO CONTATTO', fieldName: 'CRM_EsitoContatto__c', type: 'picklist' },
];

export default class CaseDataTable extends NavigationMixin(LightningElement) {


    @track isRendered;
    @track isViewAll = false;
    @track columns = [];
    @track allColumns = [];
    @track data = [];
    @track allData = [];
    @api recordId;
    @track numberAll = 0;
    @api title;
    @api pagina;
    @api JSONfiltriVisibilita; //alessandro di nardo @ten
    @track sortBy;
    @track sortByAll;
    @track sortDirection;
    @track sortDirectionAll;
    @track notShowComponent;
    @api viewAllLabel;
    @track recTypeId;
    @api objectApiName;
    @api builderIcon;
    @track record = null;
    @track subscription = {};
    @track noDataMessage='';
    

    connectedCallback() {
        //console.log("ICONA->",builderIcon);
        
        
        this.columns = columns;
        this.allColumns = allColumns;
        this.noDataMessage='';
        //this.registerErrorListener();
        var description;
        //window.addEventListener('beforeunload', this.beforeUnloadHandler.bind(this));
        this.isRendered = false;
        getAllData({ recordId: this.recordId }).
            then(result => {
               
                this.notShowComponent = false;

                let alertScadenze = [];
                result.forEach(element => {

                    element.Name_url='/'+element.Id;
                    element.Descrizione_Prodotto=element.FinServ__FinancialAccount__r.CRM_DescrizioneNome__c;
                    description=element.Descrizione_Prodotto;
                    // DK - START sostituito per far si che non vengano sovrascritti i valori della relazione con financial Account  
                    element.FinServ__FinancialAccount__c=element.FinServ__FinancialAccount__r.Name;
                    // element.FinServ__FinancialAccount__r=element.FinServ__FinancialAccount__r.Name;
                    // DK - END sostituito per far si che non vengano sovrascritti i valori della relazione con financial Account  

                    element.FinancialAccount_url='/'+element.FinServ__FinancialAccount__c;
                    if(element.CRM_OwnershipType__c.includes("ndgintestatario"))
                        element.immagine=img_ndgintestatario;
                    else if(element.CRM_OwnershipType__c.includes("ndgcointestatario"))
                        element.immagine=img_ndgcointestatario;
                    
                    if(description==element.FinServ__FinancialAccount__c)
                        element.Descrizione_Prodotto='';
                    let toKeep = true;
                    if(this.JSONfiltriVisibilita){
                        toKeep = this.filterDataByJsonFiltriVisibilita(element);//alessandro di nardo @ten
                    }
                    if(toKeep){
                        alertScadenze.push(element);
                    }
                });
                
                this.allData = alertScadenze;
                this.data=[];
                this.sortBy = 'Name';
                this.sortDirection = 'asc';
                this.sortDataAll(this.sortBy, this.sortDirection);
                
                alertScadenze= this.allData;

                if (alertScadenze.length > 5) {
                    for (let i = 0; i < 5; i++) {
                        this.data.push(alertScadenze[i]);
                    }
                }
                else {
                    this.data = alertScadenze;
                }
                this.numberAll = alertScadenze.length;

                if(this.numberAll==0)
                    this.noDataMessage="No data returned";

            }).catch(error => {
                console.log('DK init.error 1: ', error);
            }).finally(() => {
                this.isRendered = true;
                /*   getRecordTypeId({sObjName:'Case',recTypeDevName:'NewManualCase'}).then(result=>{
                       console.log('@@@@@@@@@:'+result);
                       this.recTypeId = result;
                   }).catch(error=>{
                       this.recTypeId = null;
                   }).finally(()=>{
                       getInfo({sObjName:this.objectApiName,recId:this.recordId}).then(result=>{
                           this.record = result;
                       }).catch(error=>{
                           this.record=null;
                       }).finally(()=>{
                           this.isRendered=true;
                           /*
                           if(Object.keys(this.subscription).length === 0 && this.subscription.constructor === Object){
                               this.handleSubscribe();
                           }
                           
                       });
                   });*/
            });
    }

    
    /*
    //alessandro di nardo @ten
    in base al filtro "JSONfiltriVisibilita" la funzione si occupa di mostrare i dati solo nel caso in cui la data di scadenza ("CRM_DataScadenza__c") 
    è compresa tra i 30 giorni nel passato e i 120 giorni nel futuro
    
    */
    filterDataByJsonFiltriVisibilita(element){

        let jsonDATA = JSON.parse(this.JSONfiltriVisibilita);

        console.log("alertSacenze_data to filter : " , element);
        let toKeep = true;
        for(var k = 0; k < jsonDATA.length; k++){

            const {field,value,rules} = jsonDATA[k];
            
            //rules.apiName value of CRM_DataScadenza__c
            const useToFilter = rules[0]["apiName"]; 
            const {dailyTop,dailyDown} = rules[0];
            
            //dailyTop e dailyDown vengono usati per stabilire 
            //l'intervallo di tempo in cui dev'essere compresa la data 
            console.log('DK alertSacenze_datePast', dailyTop);
            console.log('DK alertSacenze_datePast', dailyDown);
            

            var today = new Date();
            //const dateFuture = new Date().setDate(dailyTop);
            const dateFuture = new Date();
            dateFuture.setDate(today.getDate()+dailyTop);

            //const datePast = new Date().setDate(-dailyDown);
            const datePast = new Date();
            datePast.setDate(today.getDate()-dailyDown);

            console.log('DK alertSacenze_dateFuture', dateFuture);
            console.log('DK alertSacenze_datePast', datePast);
            
            // DK - START serve a recuperare il valore del campo indicato come filtro, in questo modo riesce a navigare le varie relazioni
            let point = field.split('.');
            let valore = element;
            point.forEach(p => {
                valore = Boolean(valore) ? Boolean(valore[p]) ? valore[p] : null : null;
            });
            console.log('DK alertSacenze_valore', valore);
            console.log('DK alertSacenze_value', value);
            // DK - END serve a recuperare il valore del campo indicato come filtro, in questo modo riesce a navigare le varie relazioni

            if(valore==value){
    
                const dateToCompare = new Date(element[useToFilter].toString());
                console.log('DK alertSacenze_dateToCompare', dateToCompare);
    
                if( dateToCompare < datePast || dateToCompare > dateFuture){
    
                    toKeep = false;
                    break;
                }
            }
        }
        return toKeep;
    }


    doSorting(event){
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        console.log('@@@sortby: '+this.sortBy);
        console.log('@@@sortDirection: '+this.sortDirection);

        this.sortData(this.sortBy, this.sortDirection);
    }

    doSortingAll(event){
        let sortBy;
        this.sortByAll = event.detail.fieldName;
        if(event.detail.fieldName==='CRM_FormulaData__c'){
            sortBy = 'CRM_FormulaData__c';
        }
        else if(event.detail.fieldName==='CRM_Importo__c'){
            sortBy = 'CRM_Importo__c';
        }
        else if(event.detail.fieldName==='Name_url'){
            sortBy = 'Name';
        }
        else{
            sortBy = event.detail.fieldName;
        }
        this.sortDirectionAll = event.detail.sortDirection;
        console.log('@@@sortby: '+this.sortByAll);
        console.log('@@@sortby: '+sortBy);
        console.log('@@@sortDirection: '+this.sortDirectionAll);

        this.sortDataAll(sortBy, this.sortDirectionAll);
    }

    sortDataAll(fieldname, direction){

       // if(this.isViewAll){
            let parseData = JSON.parse(JSON.stringify(this.allData));
            // Return the value stored in the field
            let keyValue = (a) => {
            return a[fieldname];
            };
            // cheking reverse direction
            let isReverse = direction === 'asc' ? 1: -1;
            // sorting data
            parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
            });
            // set the sorted data to data table data
            this.allData = parseData;
      //  }

    }

    sortData(fieldname, direction) {
         let parseData = JSON.parse(JSON.stringify(this.data));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        // set the sorted data to data table data
        this.data = parseData;
        console.log('@@@@ LPSort: ' + JSON.stringify(this.data.length));
    }

    handleViewAll(){
        this.isViewAll=true;
    }
    closeModal(){
        this.isViewAll=false;
    }

    refreshClick(){
        this.connectedCallback();
    }
    /*handleSubscribe(){
        var that = this;
        const messageCallback = function(response) {
            console.log('New message received: ', JSON.stringify(response));
            if(USER_ID===response.data.payload.UserId__c){
                that.data=[];
                that.allData=[];
                that.connectedCallback();
            }
            // Response contains the payload of the new message received
        };

        subscribe('/event/CaseDataTableEvent__e', -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response));
            this.subscription=response;
        });
    }

    disconnectedCallback(){
        console.log('disconnected');
        console.log('that.sub: '+JSON.stringify(this.subscription));
        unsubscribe(this.subscription, response => {
            console.log('unsubscribe() response: '+JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }
    beforeUnloadHandler(event) {
        console.log('before unload handler has been called.');
        console.log('that.sub: '+JSON.stringify(this.subscription));
        unsubscribe(this.subscription, response => {
            console.log('unsubscribe() response: '+ JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
      }
      registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: '+ JSON.stringify(error));
            // Error contains the server-side error
        });
    }*/

}