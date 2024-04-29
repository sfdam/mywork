import { LightningElement, track, api, wire } from 'lwc';

import puntoesclamativo from '@salesforce/resourceUrl/puntoesclamativo1';
import escalation from '@salesforce/resourceUrl/escalation';
import feedbackcliente from '@salesforce/resourceUrl/feedbackcliente';

import USER_ID from '@salesforce/user/Id';

//import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';

import getAllData from '@salesforce/apex/CaseDataTableController.getAllData';
import getRecordTypeId from '@salesforce/apex/CaseDataTableController.getRecordTypeId';
import getInfo from '@salesforce/apex/CaseDataTableController.getInfo';

import Stato from '@salesforce/label/c.CaseDataTable_CLM_Stato';
import Caso from '@salesforce/label/c.CaseDataTable_CLM_Caso';
import DataOraApertura from '@salesforce/label/c.CaseDataTable_CLM_DataOraApertura';
import Area from '@salesforce/label/c.CaseDataTable_CLM_Area';
import Esito from '@salesforce/label/c.CaseDataTable_CLM_Esito';
import Canale from '@salesforce/label/c.CaseDataTable_CLM_Canale';
import Ambito from '@salesforce/label/c.CaseDataTable_CLM_Ambito';
import Reclamo from '@salesforce/label/c.CaseDataTable_CLM_Reclamo';
import Lamentela from '@salesforce/label/c.CaseDataTable_CLM_Lamentela';
import Attivita from '@salesforce/label/c.CaseDataTable_CLM_Attivita';
import BloccoNEW from '@salesforce/label/c.CaseDataTable_CLM_BloccoNew';
import PrimoAssegnatario from '@salesforce/label/c.CaseDataTable_CLM_PrimoAssegnatario';
import Owner from '@salesforce/label/c.CaseDataTable_CLM_Owner';




import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";

const columns = [
    { label: Stato, fieldName: '', type: 'image', hideDefaultActions: "true", 
    typeAttributes:{url: {fieldName:'immagine'}}},
    { label: Caso, fieldName: 'Case_Url', type: 'url',
        typeAttributes: {
            label: { fieldName: 'CaseNumber' }
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
    { label: Area, fieldName: 'CRM_Area__c', type: 'text', hideDefaultActions: "true", sortable:"true"},
    { label: Esito, fieldName: 'CRM_Hesitation__c', type: 'text', hideDefaultActions: "true", sortable:"true"}
    
];

const allColumns = [
    { label: Caso, fieldName: 'Case_Url', type: 'url',
        typeAttributes: {
            label: { fieldName: 'CaseNumber' }
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
    { label: Canale, fieldName: 'Origin', type: 'text', hideDefaultActions: "true", sortable:"true"},    
    { label: Area, fieldName: 'CRM_Area__c', type: 'text', hideDefaultActions: "true", sortable:"true"},
    { label: Ambito, fieldName: 'CRM_Scope__c', type: 'text', hideDefaultActions: "true", sortable:"true"},
    { label: Esito, fieldName: 'CRM_Hesitation__c', type: 'text', hideDefaultActions: "true", sortable:"true"},
    { label: Reclamo, fieldName: 'Claim', type: 'Boolean', hideDefaultActions: "true", sortable:"true", cellAttributes: {
        iconName: { fieldName: 'PTF_IsClaimIcon' },
        iconPosition: 'left'
    }},
    { label: Lamentela, fieldName: 'Complaint', type: 'Boolean', hideDefaultActions: "true", sortable:"true", cellAttributes: {
        iconName: { fieldName: 'PTF_IsComplaintIcon' },
        iconPosition: 'left'
    }},
    { label: Attivita, fieldName: '', type: 'Boolean', hideDefaultActions: "true", sortable:"true", cellAttributes: {
        iconName: { fieldName: 'PTF_Attivita' },
        iconPosition: 'left'
    }},
    { label: BloccoNEW, fieldName: 'Blocco', type: 'Boolean', hideDefaultActions: "true", sortable:"true", cellAttributes: {
        iconName: { fieldName: 'PTF_IsBloccoIcon' },
        iconPosition: 'left'
    }},
    { label: PrimoAssegnatario, fieldName: 'FirstOwner', type: 'text', hideDefaultActions: "true", sortable:"true"},
    { label: Owner, fieldName: 'Owner', type: 'text', hideDefaultActions: "true", sortable:"true"}/*,
    { label: 'Team Owner', fieldName: 'CRM_OwnerTeam__c', type: 'text', hideDefaultActions: "true", sortable:"true"},
    { label: 'Polo Owner', fieldName: 'CRM_OwnerPolo__c', type: 'text', hideDefaultActions: "true", sortable:"true"}*/
];
//

export default class CaseDataTable extends NavigationMixin(LightningElement) {

    @api widthc_01;
    @api widthc_02;
    @api widthc_03;
    @api widthc_04;
    @api widthc_05;
    @api widthc_06;
    @api widthc_07;
    @api widthc_08;
    @api widthc_09;
    @api widthc_10;
    @api widthc_11;
    @api widthc_12;
    @api widthc_13;
    @api widthc_14;
    @api widthc_15;
    @track columnsOrder = ['widthc_01','widthc_02','widthc_03','widthc_04','widthc_05'];
    @track allColumnsOrder = ['widthc_02','widthc_01','widthc_03','widthc_06','widthc_04','widthc_07','widthc_05','widthc_08','widthc_09','widthc_15','widthc_10','widthc_11','widthc_12'/*,'widthc_13','widthc_14'*/];

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
    @track record = null;
    @track subscription = {};
    
    
    

    connectedCallback() {
        this.columns = this.adjustColumns(columns,this.columnsOrder);
        this.allColumns = this.adjustColumns(allColumns,this.allColumnsOrder);
        console.log('@@@@ LPdata: '+JSON.stringify(this.data.length));
        //this.registerErrorListener();
        console.log('sonoqui2');
        //window.addEventListener('beforeunload', this.beforeUnloadHandler.bind(this));
        this.isRendered=false;
        
        getAllData({recordId: this.recordId, pagina:this.pagina}).
        then(result => {
            
            this.notShowComponent=false;
            
            let caseData =[];
           result.forEach(element =>{
                element.Case_Url='/'+element.Id;
                element.PTF_IsBloccoIcon=element.CRM_BloccoNEW__c ? 'utility:check' : '';
                element.PTF_IsClaimIcon=element.CRM_Claim__c ? 'utility:check' : '';
                element.PTF_IsComplaintIcon=element.CRM_Complaint__c ? 'utility:check' : '';
                element.PTF_Attivita=element.CRM_IsPresentActivity__c ? 'utility:check' : '';
                if(element.hasOwnProperty('CRM_FirstOwner__c')){
                    element.FirstOwner=element.CRM_FirstOwner__r.Name;
                }
                element.Owner=element.Owner.Name;
                if(element.hasOwnProperty('CRM_Hesitation__c') && element.CRM_Hesitation__c==='Attesa azione cliente'){
                    
                        element.immagine=feedbackcliente;
                }
                else if(element.hasOwnProperty('CRM_Hesitation__c') && element.CRM_Hesitation__c==='Escalation'){
                    element.immagine=escalation;
                }
                
                else if(element.Status==='Assegnato'){
                    element.immagine=puntoesclamativo;
                }

                else{
                    element.immagine='';
                }
                
                
                caseData.push(element);
           });
           this.allData=caseData;
           this.data=[];
           console.log('LP3Data: '+JSON.stringify(this.data.length));
           
           if(caseData.length>5){
            for (let i=0; i<5; i++) {
                this.data.push(caseData[i]);
            }
           }
           else{
            this.data=caseData;
           }
           
           this.sortBy='Case_Url';
           this.sortByAll='Case_Url';
           this.sortDirection='desc';
           this.sortDirectionAll='desc';
           console.log('LP2Data: '+JSON.stringify(this.data.length));
           this.numberAll=caseData.length;

           console.log('@@@@ LP1: '+JSON.stringify(this.data));

        }).catch(error => {

            console.log('DK init.error: ' + JSON.stringify(error));
        }).finally(()=>{
            getRecordTypeId({sObjName:'Case',recTypeDevName:'NewManualCase'}).then(result=>{
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
                    }*/
                    
                });
            });
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
        if(event.detail.fieldName==='Claim'){
            sortBy = 'CRM_Claim__c';
        }
        else if(event.detail.fieldName==='Complaint'){
            sortBy = 'CRM_Complaint__c';
        }
        else if(event.detail.fieldName==='Blocco'){
            sortBy = 'CRM_BloccoNEW__c';
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
            console.log('@@@@ LPSort: '+JSON.stringify(this.data.length));
        
        
    }

    handleViewAll(){
        this.isViewAll=true;
    }
    closeModal(){
        this.isViewAll=false;
    }
    handleClickNew() {  
        console.log('pz handleClickNew');
        let defaultValues = {};
        if (this.objectApiName=='CRM_Channel__c') {
            defaultValues.AccountId = this.record.CRM_Account__c;
        }
        else if (this.objectApiName=='FinServ__FinancialAccount__c') {
            defaultValues.AccountId = this.record.FinServ__PrimaryOwner__c;
            if (this.pagina==4) {
                defaultValues.FinServ__FinancialAccount__c = this.recordId;
            }
        }
        else {
            defaultValues.AccountId = this.recordId;
        }
        if (this.recTypeId!=null) {
            defaultValues.RecordTypeId = this.recTypeId;
        }
      
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
              objectApiName: "Case",
              actionName: "new"
            },
            // state: {
            //   defaultFieldValues:encodeDefaultFieldValues(defaultValues)
            // }
          });
          console.log('pz handleClickNew end ');
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

    adjustColumns(col,order) {
        let values = [];
        for (var i=0; i<order.length; i++) {
            if (order[i]=='widthc_01') {
                values.push(this.widthc_01!=undefined && this.widthc_01!=null ? this.widthc_01 : 50);   
            }
            else if (order[i]=='widthc_02') {
                values.push(this.widthc_02!=undefined && this.widthc_02!=null ? this.widthc_02 : 50);   
            }
            else if (order[i]=='widthc_03') {
                values.push(this.widthc_03!=undefined && this.widthc_03!=null ? this.widthc_03 : 50);   
            }
            else if (order[i]=='widthc_04') {
                values.push(this.widthc_04!=undefined && this.widthc_04!=null ? this.widthc_04 : 50);   
            }
            else if (order[i]=='widthc_05') {
                values.push(this.widthc_05!=undefined && this.widthc_05!=null ? this.widthc_05 : 50);   
            }
            else if (order[i]=='widthc_06') {
                values.push(this.widthc_06!=undefined && this.widthc_06!=null ? this.widthc_06 : 50);   
            }
            else if (order[i]=='widthc_07') {
                values.push(this.widthc_07!=undefined && this.widthc_07!=null ? this.widthc_07 : 50);   
            }
            else if (order[i]=='widthc_08') {
                values.push(this.widthc_08!=undefined && this.widthc_08!=null ? this.widthc_08 : 50);   
            }
            else if (order[i]=='widthc_09') {
                values.push(this.widthc_09!=undefined && this.widthc_09!=null ? this.widthc_09 : 50);   
            }
            else if (order[i]=='widthc_10') {
                values.push(this.widthc_10!=undefined && this.widthc_10!=null ? this.widthc_10 : 50);   
            }
            else if (order[i]=='widthc_11') {
                values.push(this.widthc_11!=undefined && this.widthc_11!=null ? this.widthc_11 : 50);   
            }
            else if (order[i]=='widthc_12') {
                values.push(this.widthc_12!=undefined && this.widthc_12!=null ? this.widthc_12 : 50);   
            }
            /*else if (order[i]=='widthc_13') {
                values.push(this.widthc_13!=undefined && this.widthc_13!=null ? this.widthc_013 : 50);   
            }
            else if (order[i]=='widthc_14') {
                values.push(this.widthc_14!=undefined && this.widthc_14!=null ? this.widthc_14 : 50);   
            }*/
        }
        for (var i=0; i<col.length; i++) {
            col[i].fixedWidth=values[i];
        }

        return col;
    }

}