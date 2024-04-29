import { LightningElement, api, track, wire } from 'lwc';

// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

//TEST AA 
import { CurrentPageReference } from 'lightning/navigation';
import getAccountInfo from '@salesforce/apex/ART_CreateOrderController.getAccountInfo';
import getRelatedCustomer from '@salesforce/apex/ART_CustomerRelationshipNewController.getRelatedCustomer';
import selectCustomerRelationship from '@salesforce/apex/ART_CustomerRelationshipEditController.selectCustomerRelationship';
import updateCustomerRelationship from '@salesforce/apex/ART_CustomerRelationshipEditController.updateCustomerRelationship';
import ART_CustomerName from '@salesforce/label/c.ART_CustomerName';
import ART_UpdateCustomerRelationship_SuccessMsg from '@salesforce/label/c.ART_UpdateCustomerRelationship_SuccessMsg';
import ART_InsertCorrectDate_Msg from '@salesforce/label/c.ART_InsertCorrectDate_Msg';
import ART_InsertAllData_Msg from '@salesforce/label/c.ART_InsertAllData_Msg';
import ART_Error from '@salesforce/label/c.ART_Error';
import CancelLabel from '@salesforce/label/cgcloud.CANCEL';
import ART_Related_Customer from '@salesforce/label/c.ART_Related_Customer';
import ART_Start_Date from '@salesforce/label/c.ART_Start_Date';
import ART_End_Date from '@salesforce/label/c.ART_End_Date';
import ART_Update_Button from '@salesforce/label/c.ART_Update_Button';
import ART_Relationship_Type from '@salesforce/label/c.ART_Relationship_Type';
import ART_Customer_Identification_Code from '@salesforce/label/c.ART_Customer_Identification_Code';
import ART_CustomerRelationshipEdit  from '@salesforce/label/c.ART_CustomerRelationshipEdit';
import SEARCH  from '@salesforce/label/cgcloud.SEARCH';
import Identification from '@salesforce/label/cgcloud.IDENTIFICATION';

export default class ArtCustomerRelationshipEdit extends  NavigationMixin(LightningElement) {

    label = {   
        ART_CustomerName,
        Identification,
        ART_UpdateCustomerRelationship_SuccessMsg,
        ART_InsertCorrectDate_Msg,
        ART_Error,
        ART_InsertAllData_Msg,
        CancelLabel,
        ART_Update_Button,
        ART_Related_Customer,
        ART_Start_Date,
        ART_End_Date,
        ART_Relationship_Type,
        ART_Customer_Identification_Code,
        ART_CustomerRelationshipEdit,
        SEARCH
    };

    @api recordId;
    @track recordBack;
    @track disabledField = true;
    @track relationshipIsSelect = true;
    @track filter;
    @track currentStartDate;
    @track currentEndDate;
    @track valueRelationshipType;
    @track customerID;
    @track relatedCustomerID;
    @track customerIdentificationCode;
    @track backupData;
    @track loaded = false;
    @track required = true;

    relationshipType='';
    relatedCustomer='';
    dateStart='';
    dateEnd='';
    datetime='';
    

    @track prepopulatedAccount = {obj: {}, objId: undefined, name: undefined, sObjectName: 'Account', iconName: 'standard:account'};
    @track objRelatedCustomer = {obj: {}, objId: undefined, name: undefined, sObjectName: 'Account', iconName: 'standard:account'};

    @wire(CurrentPageReference)
    currentPageReference;
    
    @track selectedCustomerId;

    connectedCallback(){

        console.log('AD recordId: ' ,this.recordId);
        console.log('DK START ArtCustomerRelationshipNew.connectedCallback');
      
        if(this.recordId){
            selectCustomerRelationship({customerRelationshipID: this.recordId})
            .then(customerRelationshipInfo =>{

                console.log('AD customerRelationshipInfo:' , customerRelationshipInfo);
                
                this.customerID = customerRelationshipInfo[0]['cgcloud__Account__c'];
                this.relatedCustomerID=customerRelationshipInfo[0]['cgcloud__Related_Account__c'];
                this.currentStartDate = customerRelationshipInfo[0]['cgcloud__Start_Date__c'];
                this.currentEndDate=customerRelationshipInfo[0]['cgcloud__End_Date__c'];
                this.valueRelationshipType = customerRelationshipInfo[0]['cgcloud__Relationship_Type__c'];
                this.customerIdentificationCode = customerRelationshipInfo[0]['ART_Customer_identification_code__c'];
                this.relationshipType = this.valueRelationshipType;
                this.relationshipIsSelect=false;

                //console.log('AD name account__R :  ' , customerRelationshipInfo[0]['cgcloud__Account__r']['Name']);
                // Customer lookup populate
                this.prepopulatedAccount.objId = this.customerID;
                this.prepopulatedAccount.obj.Id = this.customerID;
                this.prepopulatedAccount.obj.name = customerRelationshipInfo[0]['cgcloud__Account__r']['Name'];
                this.prepopulatedAccount.name = customerRelationshipInfo[0]['cgcloud__Account__r']['Name'];
                this.prepopulatedAccount.sObjectName = 'Account';
                this.prepopulatedAccount.iconName = 'standard:account';
                this.selectedCustomerId = this.customerID;

                // Related Customer lookup populate
                this.objRelatedCustomer.objId = this.relatedCustomerID;
                this.objRelatedCustomer.obj.Id = this.relatedCustomerID;
                this.objRelatedCustomer.obj.name = customerRelationshipInfo[0]['cgcloud__Related_Account__r']['Name'];
                this.objRelatedCustomer.name = customerRelationshipInfo[0]['cgcloud__Related_Account__r']['Name'];
                this.objRelatedCustomer.sObjectName = 'Account';
                this.objRelatedCustomer.iconName = 'standard:account';

                this.elaborateRelatedCustomer();
            })
            .catch(error =>{
                console.log('AD selectCustomerRelationship:' , error);
            })
        }
        
    }

    //valueRelationshipType = 'Select value';

    get options() {
        return [
            { label: 'Payer', value: 'Payer' },
            { label: 'Wholesaler', value: 'Wholesaler' }
        ];
    }

    //Relationship Type handler
    handleChange(event) {
        console.log('AD event : ' , event.detail.value );
        this.relationshipType=event.detail.value;
        this.template.querySelector("[data-item='customLookupRelatedCustomer']").removeSelectedItem(event);
        if(this.relationshipType){
            this.objRelatedCustomer=undefined;
            this.elaborateRelatedCustomer();
        }
    }

    elaborateRelatedCustomer(){
        console.log('AD elaborateRelatedCustomer');
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
                    this.loaded = true;
                }
            })
            .catch(error =>{
                console.log('AD getRelatedCustomer error : ',error);
            })
    }
    //Related Customer
    /*handleRelatedCustomerEvent(event) {
        console.log('@@@@@selectedWallet: '+JSON.stringify(event)); 
        this.required = true;
        if(event.detail!=null ){
            this.saveRelatedCustomerEvent(event.detail.objId);
        } 
    }

    saveRelatedCustomerEvent(id){
        this.relatedCustomerID=id;
        console.log('AD relatedCustomer : ' , this.relatedCustomerID);
    }*/
    handleRelatedCustomerEvent(event) {
        console.log('@@@@@selectedWallet: '+JSON.stringify(event.detail)); 
        this.required = true;
        this.relatedCustomerID = event.detail !== null ? event.detail.objId : null;
        if(!this.relatedCustomerID){
            this.template.querySelector("[data-item='customLookupRelatedCustomer']").results = [];
        }
        console.log('AD relatedCustomer : ' , this.relatedCustomerID);
    }

    @api
    get accountFilter() {
        // if(!this.relationshipIsSelect){
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
        console.log('AD relatedCustomer : ' , this.relatedCustomerID);
        console.log('AD relationshipType : ' , this.relationshipType);

        console.log('AD parse date start : ' , this.currentStartDate);
        //console.log('AD parse date end : ' , Date.parse(this.currentEndDate));

        if(Date.parse(this.currentStartDate)>Date.parse(this.currentEndDate)){
            console.log('AD Date non corrette');
            //alert('inserire date corrette');
            this.handleShowToastMsg(this.label.ART_Error,this.label.ART_InsertCorrectDate_Msg ,'error');

            return;
        }

        if(this.currentEndDate&&this.currentStartDate&&this.selectedCustomerId&&this.relatedCustomerID&&this.relationshipType){

            updateCustomerRelationship(
                {currentEndDate:this.currentEndDate ,
                currentStartDate:this.currentStartDate,
                selectedCustomerId:this.selectedCustomerId,
                relatedCustomer:this.relatedCustomerID,
                relationshipType:this.relationshipType,
                recordID:this.recordId})
                .then(result =>{

                    console.log('AD updateCustomerRelationship result : ' , result);
                    this.handleShowToastMsg(this.label.ART_Success,this.label.ART_UpdateCustomerRelationship_SuccessMsg,'success');


            }).catch(error =>{
                console.log('AD updateCustomerRelationship error' , error);
            })

        }else{

            //alert('inserire tutti i dati');
            this.handleShowToastMsg(this.label.ART_Error,this.label.ART_InsertAllData_Msg ,'error');

        }

    }


    cancelUpdate(){

        console.log('AD cancelUpdate');
        this[NavigationMixin.Navigate]({
            "type": "standard__recordPage",
            "attributes": {
                recordId: this.recordId,
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