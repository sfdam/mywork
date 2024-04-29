import { LightningElement, track, api } from 'lwc';

import Product_Category from '@salesforce/label/c.Product_Category';
import Appointment_date_at_the_branch from '@salesforce/label/c.Appointment_date_at_the_branch';
import Recall_date from '@salesforce/label/c.Recall_date';
import Appointment_branch_name from '@salesforce/label/c.Appointment_branch_name';
import Owner from '@salesforce/label/c.Owner';
import Stato from '@salesforce/label/c.opportunityDataTable_CLM_Stato';
import Opportunita from '@salesforce/label/c.opportunityDataTable_CLM_Opportunita';
import DataOraApertura from '@salesforce/label/c.opportunityDataTable_CLM_DataOraApertura';
import Fase from '@salesforce/label/c.opportunityDataTable_CLM_Fase';
import Creato_da from '@salesforce/label/c.opportunityDataTable_CLM_CreatoDa';

import callfailed from '@salesforce/resourceUrl/callfailed';

import USER_ID from '@salesforce/user/Id';

//import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';

import getAllData from '@salesforce/apex/OpportunityDataTableController.getAllData';



const columns = [
    { label: Stato, fieldName: '', type: 'image', hideDefaultActions: "true", 
    typeAttributes:{url: {fieldName:'immagine'}}},
    { label: Opportunita, fieldName: 'Opp_Url', type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' }
        },
        hideDefaultActions: "true", sortable:"true"},
    { label: DataOraApertura, fieldName: 'CreatedDate', type: 'date', hideDefaultActions: "true", sortable:"true",
    typeAttributes: {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
      }},
    { label: Product_Category, fieldName: 'CRM_ProductCategory__c', type: 'text', hideDefaultActions: "true", sortable:"true"},
    { label: Fase, fieldName: 'StageName', type: 'text', hideDefaultActions: "true", sortable:"true"},
    { label: 'Origine', fieldName: 'CRM_OriginCC__c', type: 'text', hideDefaultActions: "true", sortable:"true"}
    
];

const allColumns = [
    { label: Opportunita, fieldName: 'Opp_Url', type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' }
        },
        hideDefaultActions: "true", sortable:"true"},
    { label: Stato, fieldName: '', type: 'image', hideDefaultActions: "true", 
        typeAttributes:{url: {fieldName:'immagine'}}},
    { label: DataOraApertura, fieldName: 'CreatedDate', type: 'date', hideDefaultActions: "true", sortable:"true",
    typeAttributes: {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
      }
    },
    { label: Product_Category, fieldName: 'CRM_ProductCategory__c', type: 'text', hideDefaultActions: "true", sortable:"true"},   
    { label: Fase, fieldName: 'StageName', type: 'text', hideDefaultActions: "true", sortable:"true"},
    { label: Creato_da, fieldName: 'CreatedBy', type: 'text', hideDefaultActions: "true", sortable:"true"},
    { label: Recall_date, fieldName: 'CRM_RecallDate__c', type: 'date', hideDefaultActions: "true", sortable:"true",typeAttributes: {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
      }},
    { label: Appointment_date_at_the_branch, fieldName: 'CRM_AppointmentDateAtTheBranch__c', type: 'date', hideDefaultActions: "true", sortable:"true",typeAttributes: {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
      }},
    { label: Appointment_branch_name, fieldName: 'CRM_AppointmentBranchName__c', type: 'text', hideDefaultActions: "true", sortable:"true"},
    { label: Owner, fieldName: 'Owner', type: 'text', hideDefaultActions: "true", sortable:"true"}
    
];
//

export default class OpportunityDataTable extends LightningElement {

    @api widthc01;
    @api widthc02;
    @api widthc03;
    @api widthc04;
    @api widthc05;
    @api widthc06;
    @api widthc07;
    @api widthc08;
    @api widthc09;
    @api widthc10;
    @api flowLabel;
    @track columnsOrder = ['widthc01','widthc02','widthc03','widthc04','widthc05','widthc06'];
    @track allColumnsOrder = ['widthc02','widthc01','widthc03','widthc04','widthc05','widthc06','widthc07','widthc08','widthc09','widthc10'];

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
    @track subscription = {};
    
    
    

    connectedCallback() {
        
        this.columns = this.adjustColumns(columns,this.columnsOrder);
        this.allColumns = this.adjustColumns(allColumns,this.allColumnsOrder);
        //this.registerErrorListener();
        console.log('sonoqui2');
        //window.addEventListener('beforeunload', this.beforeUnloadHandler.bind(this));
        this.isRendered=false;
        this.sortBy='Opp_Url';
        this.sortByAll='Opp_Url';
        this.sortDirection='desc';
        this.sortDirectionAll='desc';
        getAllData({recordId: this.recordId, pagina:this.pagina}).
        then(result => {
            if(result.length===0 && this.pagina===4){
                this.notShowComponent=true;
            }
            else{
                this.notShowComponent=false;
            }
            let oppData =[];
           result.forEach(element =>{
                element.Opp_Url='/'+element.Id;
                element.CreatedBy= element.CreatedBy.Name;
                
                element.Owner=element.Owner.Name;
                if(element.hasOwnProperty('StageName')){
                    if(element.StageName==='Non risponde 1' || element.StageName==='Non risponde 2' || element.StageName==='Non risponde 3' || element.StageName==='Non raggiungibile'){
                        element.immagine=callfailed;
                    }
                    else{
                        element.immagine='';
                    }    
                }
                else{
                    element.immagine='';
                }
                
                
                oppData.push(element);
           });
           this.allData=oppData;
           this.data=[];
           if(oppData.length>5){
            for (let i=0; i<5; i++) {
                this.data.push(oppData[i]);
            }
           }
           else{
            this.data=oppData;
           }
           this.numberAll=oppData.length;

           console.log('@@@@ LP1: '+JSON.stringify(this.data));

        }).catch(error => {

            console.log('DK init.error: ' + JSON.stringify(error.body.message));
        }).finally(()=>{
            
                    this.isRendered=true;
                    /*if(Object.keys(this.subscription).length === 0 && this.subscription.constructor === Object){
                        this.handleSubscribe();
                    }*/
                    
                });
                
        }
           
       

                
        

    doSorting(event){
        /*if(event.detail.fieldName==="Opp_Url"){
            this.sortBy = "Name";
        }
        else{
            this.sortBy = event.detail.fieldName;
        }*/
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        console.log('@@@sortby: '+this.sortBy);
        console.log('@@@sortDirection: '+this.sortDirection);

        this.sortData(this.sortBy, this.sortDirection);
        

    }

    doSortingAll(event){

        /*if(event.detail.fieldName==="Opp_Url"){
            this.sortByAll = "Name";
        }
        else{
            this.sortByAll = event.detail.fieldName;
        }*/
        this.sortByAll = event.detail.fieldName;
        this.sortDirectionAll = event.detail.sortDirection;
        console.log('@@@sortby: '+this.sortByAll);
        console.log('@@@sortDirection: '+this.sortDirectionAll);

        this.sortDataAll(this.sortByAll, this.sortDirectionAll);
        

    }

    sortDataAll(fieldname, direction){

        if(this.isViewAll){
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

        }

    }

    sortData(fieldname, direction){
        
        
        
            let parseData = JSON.parse(JSON.stringify(this.data));
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
            this.data = parseData;
            console.log('@@@@ LPSort: '+JSON.stringify(this.data));
        
        
    }

    handleViewAll(){
        this.isViewAll=true;
    }
    closeModal(){
        this.isViewAll=false;
    }
    handleClickNew() {  
        //fire event
        const flowEvent = new CustomEvent("flowevent", {
          });
          // Fire the custom event
          this.dispatchEvent(flowEvent);
    }
    /*
    handleSubscribe(){
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

        subscribe('/event/OpportunityDataTableEvent__e', -1, messageCallback).then(response => {
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
    refreshClick(){
        this.connectedCallback();
    }

    adjustColumns(col,order) {
        let values = [];
        for (var i=0; i<order.length; i++) {
            if (order[i]=='widthc01') {
                values.push(this.widthc01!=undefined && this.widthc01!=null ? this.widthc01 : 50);   
            }
            else if (order[i]=='widthc02') {
                values.push(this.widthc02!=undefined && this.widthc02!=null ? this.widthc02 : 50);   
            }
            else if (order[i]=='widthc03') {
                values.push(this.widthc03!=undefined && this.widthc03!=null ? this.widthc03 : 50);   
            }
            else if (order[i]=='widthc04') {
                values.push(this.widthc04!=undefined && this.widthc04!=null ? this.widthc04 : 50);   
            }
            else if (order[i]=='widthc05') {
                values.push(this.widthc05!=undefined && this.widthc05!=null ? this.widthc05 : 50);   
            }
            else if (order[i]=='widthc06') {
                values.push(this.widthc06!=undefined && this.widthc06!=null ? this.widthc06 : 50);   
            }
            else if (order[i]=='widthc07') {
                values.push(this.widthc07!=undefined && this.widthc07!=null ? this.widthc07 : 50);   
            }
            else if (order[i]=='widthc08') {
                values.push(this.widthc08!=undefined && this.widthc08!=null ? this.widthc08 : 50);   
            }
            else if (order[i]=='widthc09') {
                values.push(this.widthc09!=undefined && this.widthc09!=null ? this.widthc09 : 50);   
            }
            else if (order[i]=='widthc10') {
                values.push(this.widthc10!=undefined && this.widthc10!=null ? this.widthc10 : 50);   
            }
            
        }
        for (var i=0; i<col.length; i++) {
            col[i].fixedWidth=values[i];
        }

        return col;
    }

}