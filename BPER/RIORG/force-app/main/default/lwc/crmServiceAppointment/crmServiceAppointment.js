import { LightningElement, track, api, wire } from 'lwc';
import getAllData from '@salesforce/apex/ServiceAppointmentController.getAllData';
import { NavigationMixin } from "lightning/navigation";



const columns = [
    { label: 'TITOLO', fieldName: 'AppointmentNumber_url', type:'url',
        typeAttributes: {
            label: { fieldName: 'AppointmentNumber' }
        },
    },
    { label: 'OGGETTO APPT', fieldName: 'Subject', type: 'text' },
    { label: 'DATA E ORA', fieldName: 'SchedStartTime', type: 'date',
        typeAttributes:{
            year: "numeric",
            month: "2-digit",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        } 
     },
    
     
];

const allColumns = [
    { label: 'TITOLO', fieldName: 'AppointmentNumber_url', type:'url',
        typeAttributes: {
            label: { fieldName: 'AppointmentNumber' }
        },
    },
    { label: 'OGGETTO APPT', fieldName: 'Subject', type: 'text' },
    { label: 'DATA E ORA', fieldName: 'SchedStartTime', type: 'date',
        typeAttributes:{
            year: "numeric",
            month: "2-digit",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        } 
    },
];

export default class crmServiceAppoinment extends NavigationMixin(LightningElement) {


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

                let servApp = [];
                result.forEach(element => {
                    element.AppointmentNumber_url='/'+element.Id;
                    element.Descrizione_Prodotto=element.Subject;
                    description=element.SchedStartTime;
                    servApp.push(element);
                });
                
                this.allData = servApp;
                this.data=[];

                this.sortBy = 'SchedStartTime';
                this.sortDirection = 'desc';
                this.sortDataAll(this.sortBy, this.sortDirection);
                servApp= this.allData;

                if (servApp.length > 5) {
                    for (let i = 0; i < 5; i++) {
                        this.data.push(servApp[i]);
                    }
                }
                else {
                    this.data = servApp;
                }
                this.numberAll = servApp.length;

                if(this.numberAll==0)
                    this.noDataMessage="No data returned";

            }).catch(error => {
                console.log('DK init.error 1: ' + JSON.stringify(error));
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