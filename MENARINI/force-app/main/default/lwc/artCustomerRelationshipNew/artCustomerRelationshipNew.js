/*------------------------------------------------------------
Author: Alessandro Di Nardo @ten 2023-08-30

Description: lwc usato per la creazione di customer relationship
             passando al metodo "insertCustomer" come valori gli id delle custom lookup 
             ("Customer" , "Related Customer") , il tipo di relazione (relationshiptype) 
             data inizio e data fine 
             come raggiungere il componente : tab Accounts-->Customer Relationship -- bottone : New
                
 ------------------------------------------------------------*/
import { LightningElement, api, track, wire } from 'lwc';

// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

//TEST AA 
import { CurrentPageReference } from 'lightning/navigation';
import getAccountInfo from '@salesforce/apex/ART_CreateOrderController.getAccountInfo';
import getRelatedCustomer from '@salesforce/apex/ART_CustomerRelationshipNewController.getRelatedCustomer';
import insertCustomer from '@salesforce/apex/ART_CustomerRelationshipNewController.insertCustomer';
import ART_CustomerName from '@salesforce/label/c.ART_CustomerName';
import ART_CreateCustomerRelationship_SuccessMsg from '@salesforce/label/c.ART_CreateCustomerRelationship_SuccessMsg';
import ART_InsertCorrectDate_Msg from '@salesforce/label/c.ART_InsertCorrectDate_Msg';
import ART_InsertAllData_Msg from '@salesforce/label/c.ART_InsertAllData_Msg';
import ART_Error from '@salesforce/label/c.ART_Error';
import CancelLabel from '@salesforce/label/cgcloud.CANCEL';
import ART_Save_Button from '@salesforce/label/c.ART_Save_Button';
import ART_Related_Customer from '@salesforce/label/c.ART_Related_Customer';
import ART_Start_Date from '@salesforce/label/c.ART_Start_Date';
import ART_End_Date from '@salesforce/label/c.ART_End_Date';
import ART_Relationship_Type from '@salesforce/label/c.ART_Relationship_Type';
import ART_Customer_Identification_Code from '@salesforce/label/c.ART_Customer_Identification_Code';
import ART_CustomerRelationshipNew from '@salesforce/label/c.ART_CustomerRelationshipNew';
import SEARCH from '@salesforce/label/cgcloud.SEARCH';
import Identification from '@salesforce/label/cgcloud.IDENTIFICATION';

export default class ArtCustomerRelationshipNew extends  NavigationMixin(LightningElement) {

    label = {   
        ART_CustomerName,
        Identification,
        ART_CreateCustomerRelationship_SuccessMsg,
        ART_InsertCorrectDate_Msg,
        ART_Error,
        ART_InsertAllData_Msg,
        CancelLabel,
        ART_Save_Button,
        ART_Related_Customer,
        ART_Start_Date,
        ART_End_Date,
        ART_Relationship_Type,
        ART_Customer_Identification_Code,
        ART_CustomerRelationshipNew,
        SEARCH
    };

    @track recordBack;
    @track disabledField = true;
    @track relationshipIsSelect = true;
    @track filter;
    @track loaded = false;
    @track required = true;

    relationshipType='Wholesaler';
    relatedCustomer='';
    dateStart='';
    dateEnd='';
    datetime='';
    

    @track prepopulatedAccount = {obj: {}, objId: undefined, name: undefined, sObjectName: 'Account', iconName: 'standard:account'};

    @wire(CurrentPageReference)
    currentPageReference;
    
    @track selectedCustomerId;

    connectedCallback(){

        var currentdate = new Date(); 
        var currentdate2 = new Date('2099-12-31'); 
        
        // currentdate2.setDate(currentdate.getDate()+1);
        this.currentEndDate = currentdate2.getFullYear() +'-'+(currentdate2.getMonth()+1)+'-'+currentdate2.getDate();

        this.currentStartDate =  currentdate.getFullYear()+"-"+(currentdate.getMonth()+1)+"-"+currentdate.getDate();

        console.log('DK START ArtCustomerRelationshipNew.connectedCallback');
        console.log(`state = ${JSON.stringify(this.currentPageReference.state, undefined, 2)}`);
        let base64Context = this.currentPageReference.state.inContextOfRef;
        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        let addressableContext = JSON.parse(window.atob(base64Context));
        console.log(`id -> ${addressableContext.attributes.recordId}`);
        let preselectedRecordId = Boolean(addressableContext.attributes.recordId) ? addressableContext.attributes.recordId : null;
        this.recordBack = Boolean(addressableContext.attributes.recordId) ? addressableContext.attributes.recordId : null;
        console.log('AD recordBack : ' , this.recordBack);
        if(Boolean(preselectedRecordId)){
            getAccountInfo({accId: preselectedRecordId})
            .then(accInfo =>{

                this.prepopulatedAccount.objId = preselectedRecordId;
                this.prepopulatedAccount.obj.Id = preselectedRecordId;
                this.prepopulatedAccount.obj.name = accInfo.Name;
                this.prepopulatedAccount.name = accInfo.Name;
                this.prepopulatedAccount.sObjectName = 'Account';
                this.prepopulatedAccount.iconName = 'standard:account';
                //this.handleOrderTemplatePicklist(preselectedRecordId);
                this.selectedCustomerId = preselectedRecordId;
                this.loaded = true;
            })
            .catch(error =>{
                console.log(error);
            })
            .finally(() =>{
                let event = {};
                event.detail = {};
                event.detail.value = 'Wholesaler';
                this.handleChange(event);
            });
        }else{
            this.prepopulatedAccount = undefined; 
        }

    }

    get options() {
        return [
            { label: 'Payer', value: 'Payer' },
            { label: 'Wholesaler', value: 'Wholesaler' }
        ];
    }

    handleChange(event) {
        //this.value = event.detail.value;

        console.log('AD event : ' , event.detail.value );
        this.relationshipType=event.detail.value;
        this.template.querySelector("[data-item='customLookupRelatedCustomer']").removeSelectedItem(event);
        this.template.querySelector("[data-item='customLookupRelatedCustomer']").results = [];
        this.relatedCustomer = null;

        //if()
        if(this.relationshipType){
            getRelatedCustomer({relationshipType: this.relationshipType})
            .then(relatedCustomerInfo =>{

                console.log('AD getRelatedCustomer response : ', relatedCustomerInfo);
                this.relationshipIsSelect=false;

                if(relatedCustomerInfo.length > 0 ){

                    var newFilter = '';

                    for(let i=0; i< relatedCustomerInfo.length ; i++){
                        newFilter =  newFilter +"\'"+relatedCustomerInfo[i]['cgcloud__Account__c']+"\',";
                    }

                    //console.log('AD getRelatedCustomer newFilter : ', newFilter);
                    /*if(newFilter)*/
                    newFilter = newFilter.substring(0, newFilter.length - 1); 
                    //console.log('AD RESULT--> ' + JSON.stringify(newFilter));
                    this.filter =  "("+newFilter+")";
                    //this.accountFilter();
                }
            })
            .catch(error =>{
                console.log('AD getRelatedCustomer error : ',error);
            })
        }
    }

    //Related Customer
    handleRelatedCustomerEvent(event) {
        console.log('@@@@@selectedWallet: '+JSON.stringify(event.detail)); 
        this.required = true;
        this.relatedCustomer = event.detail !== null ? event.detail.objId : null;
        if(!this.relatedCustomer){
            this.template.querySelector("[data-item='customLookupRelatedCustomer']").results = [];
        }
        console.log('AD relatedCustomer : ' , this.relatedCustomer);
    }

    @api
    get accountFilter() {
        if(this.filter !== undefined){
            return (
                        //"cgcloud__Active__c  = true AND  cgcloud__Management_Type__c = 'Sales' "
                        "Id IN "+this.filter
                    );
        }
    }

    startDatechange(event){
        //console.log('AD date start : ' , event.detail.value );
        this.currentStartDate=event.detail.value;
    }
    endDatechange(event){
        //console.log('AD date end : ' , event.detail.value );
        this.currentEndDate=event.detail.value;
    }
    handlerSave(){

        console.log('AD selectedCustomerId : ' , this.selectedCustomerId);
        console.log('AD relatedCustomer : ' , this.relatedCustomer);
        console.log('AD relationshipType : ' , this.relationshipType);

        console.log('AD parse date start : ' , this.currentStartDate);
        //console.log('AD parse date end : ' , Date.parse(this.currentEndDate));

        if(Date.parse(this.currentStartDate)>Date.parse(this.currentEndDate)){
            console.log('AD Date non corrette');
            //alert('inserire date corrette');
            this.handleShowToastMsg(this.label.ART_Error,this.label.ART_InsertCorrectDate_Msg ,'error');

            return;
        }

        if(this.currentEndDate&&this.currentStartDate&&this.selectedCustomerId&&this.relatedCustomer&&this.relationshipType){

            insertCustomer({currentEndDate:this.currentEndDate ,currentStartDate:this.currentStartDate,
                selectedCustomerId:this.selectedCustomerId,relatedCustomer:this.relatedCustomer,relationshipType:this.relationshipType})
            .then(result =>{

               console.log('AD insertCustomer result : ' , result);
               this.handleShowToastMsg(this.label.ART_Success,this.label.ART_CreateCustomerRelationship_SuccessMsg,'success');

               this[NavigationMixin.Navigate]({
                "type": "standard__recordPage",
                "attributes": {
                    recordId:result,
                    actionName: 'view'
                }
            });

            })
            .catch(error =>{
                console.log('AD insertCustomer error' , error);
            })

        }else{

            //alert('inserire tutti i dati');
            this.handleShowToastMsg(this.label.ART_Error,this.label.ART_InsertAllData_Msg ,'error');

        }

    }


    cancelInsert(){

        console.log('AD cancelInsert');
        this[NavigationMixin.Navigate]({
            "type": "standard__recordPage",
            "attributes": {
                recordId:this.recordBack,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });

    }

    handleShowToastMsg(tittolo, messagio , variante){
        this.dispatchEvent(new ShowToastEvent({
            title: tittolo,
            message: messagio,
            variant: variante
            }),
        );
    }
}