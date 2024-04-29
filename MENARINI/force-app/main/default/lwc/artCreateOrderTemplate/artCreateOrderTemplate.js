import { LightningElement, api, track, wire } from 'lwc';

// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

//TEST AA 
import { CurrentPageReference } from 'lightning/navigation';

import CreateOrder from '@salesforce/label/cgcloud.CREATE_ORDER';
import Identification from '@salesforce/label/cgcloud.IDENTIFICATION';
import ContinueLabel from '@salesforce/label/cgcloud.CONTINUE';
import CancelLabel from '@salesforce/label/cgcloud.CANCEL';
import OrderTemplate from '@salesforce/label/cgcloud.ORDER_TEMPLATE';
import ART_CustomerName from '@salesforce/label/c.ART_CustomerName';
import ART_CreateOrder_CompilaCampi from '@salesforce/label/c.ART_CreateOrder_CompilaCampi';
import ART_CreateOrder_SuccessMsg from '@salesforce/label/c.ART_CreateOrder_SuccessMsg';
import ART_Success from '@salesforce/label/c.ART_Success';
import ART_Error from '@salesforce/label/c.ART_Error';



import uId from '@salesforce/user/Id';
import getAccIdFromManager from '@salesforce/apex/ART_CreateOrderController.getAccIdFromManager';
import getAccountInfo from '@salesforce/apex/ART_CreateOrderController.getAccountInfo';
import OrderTemplatePicklist from '@salesforce/apex/ART_CreateOrderController.getOrderTemplatePicklist';
import insertOrderTemplate from '@salesforce/apex/ART_CreateOrderController.insertOrderTemplate';

import init from '@salesforce/apex/ART_CreateOrderController.init';
export default class ArtCreateOrderTemplate extends  NavigationMixin(LightningElement) {
    label = {
        CreateOrder,
        Identification,
        ContinueLabel,
        CancelLabel,
        OrderTemplate,
        ART_CustomerName,
        ART_CreateOrder_CompilaCampi,
        ART_CreateOrder_SuccessMsg,
        ART_Success,
        ART_Error
    };
    @track prepopulatedAccount = {obj: {}, objId: undefined, name: undefined, sObjectName: 'Account', iconName: 'standard:account'};
    @track options;
    @track selectedOption;
    @track selectedAccountId;
    @track required;
    @track filter
    @track loaded = false;
    @track disabledToOrder = true;

    //TEST AA
    @wire(CurrentPageReference)
    currentPageReference;

    // connectedCallback method called when the element is inserted into a document
    connectedCallback() {
        //TEST AA
        console.log(`state = ${JSON.stringify(this.currentPageReference.state, undefined, 2)}`);
        let base64Context = this.currentPageReference.state.inContextOfRef;
        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        let addressableContext = JSON.parse(window.atob(base64Context));
        console.log(`id -> ${addressableContext.attributes.recordId}`);
        let preselectedRecordId = Boolean(addressableContext.attributes.recordId) ? addressableContext.attributes.recordId : null;
        if(Boolean(preselectedRecordId)){
            getAccountInfo({accId: preselectedRecordId})
            .then(accInfo =>{

                this.prepopulatedAccount.objId = preselectedRecordId;
                this.prepopulatedAccount.obj.Id = preselectedRecordId;
                this.prepopulatedAccount.obj.name = accInfo.Name;
                this.prepopulatedAccount.name = accInfo.Name;
                this.prepopulatedAccount.sObjectName = 'Account';
                this.prepopulatedAccount.iconName = 'standard:account';
                this.handleOrderTemplatePicklist(preselectedRecordId);
            })
            .catch(error =>{
                console.log(error);
            })
        }else{
            this.prepopulatedAccount = undefined; 
        }

        init()
        .then(result => {

            console.log('DK init_result:', result);
            this.userInfo = result.userInfo;
            this.userIdSet = result.userIdSet;
            this.chooseResponsabile = this.visibilitySet.includes(this.userInfo.Profile.Name);

            // this.userFilter = "isActive = true AND Profile.Name IN (" + profilesToQuery + ")"
            this.userFilter = "isActive = true ";
            //FINE TEST AA 
            // fetch order item records from apex method 
            getAccIdFromManager()
                .then((result) => {
                    if (result != null) {
                        if(!Boolean(preselectedRecordId) || (Boolean(preselectedRecordId) && result.includes(preselectedRecordId))){
                            console.log('RESULT--> ' + JSON.stringify(result));
                            var newFilter = '';
                            for(let i=0; i< result.length ; i++){
                                newFilter =  newFilter +"\'"+result[i]+"\',";
                            }
                            if(newFilter)
                            newFilter = newFilter.substring(0, newFilter.length - 1); 
                            console.log('RESULT--> ' + JSON.stringify(newFilter));
                            this.filter =  "("+newFilter+")";
                            this.loaded = true;
                            this.disabledToOrder = false;
                        }else if(Boolean(preselectedRecordId)){
                            this.loaded = true;
                            this.handleShowToastMsg('Error!!','Cliente non abilitato alla presa ordine','error');
                        }
                    }
                })
                .catch((error) => {
                    console.log('error while fetch accounts--> ' + JSON.stringify(error));
                });
        });
    }

    @api
    get accountFilter() {
        console.log('AT : '+ uId);
        return (
            //"cgcloud__Active__c  = true AND  cgcloud__Management_Type__c = 'Sales' "
            "Id IN "+this.filter
        );
    }

    handleCustomEvent(event) {
        console.log('@@@@@selectedWallet: '+JSON.stringify(event.detail)); 
        this.required = true;
        if(event.detail!=null ){
            this.handleOrderTemplatePicklist(event.detail.objId);
        }
        else{
            this.refreshFiltri();
        }
        
    }

    selectionChangeHandler(event){
        this.selectedOption = event.target.value;
        console.log('AT : '+this.selectedOption);
    }
    handleOrderTemplatePicklist(idAcc){
        this.selectedAccountId = idAcc;
        OrderTemplatePicklist({accId: idAcc})
        .then(result => {
            console.log('AT result : '+JSON.stringify(result));
            let optionsPick = [];
            this.options = [];

            //let objResult = flattenQueryResult(result);
            //console.log('AT result : '+JSON.stringify(objResult));
            for (let key in result) {
                console.log('AT result : '+JSON.stringify(result[key]));
                optionsPick.push({ label: result[key].cgcloud__Order_Template__r.Name, value: result[key].cgcloud__Order_Template__r.Id });
            }

            this.options = optionsPick;
        })
        .catch(error => {
            console.log('ART_CreateOrderController.getOrderTemplatePicklist: ' + JSON.stringify(error));
        })
        
    }

    handleClickCancel(){
        console.log('AT : '+this.selectedOption);
        console.log('AT : '+this.selectedAccountId);

        this[NavigationMixin.Navigate]({
            "type": "standard__objectPage",
            "attributes": {
                objectApiName: 'cgcloud__Order__c',
                actionName: 'list'
            }
        });
        
    }
    handleClickContinue(){

        console.log('AT : '+this.selectedOption);
        console.log('AT : '+this.selectedAccountId);

        if(this.shareOrder && this.selectedResponsible == null){
            this.handleShowToastMsg('Attenzione', 'Selezionare Responsabile primma di continuare!!' ,'warning');
        }else if(this.selectedOption == null || this.selectedAccountId == null || this.selectedOption == undefined || this.selectedAccountId ==undefined){
                
            this.handleShowToastMsg(this.label.ART_Error,this.label.ART_CreateOrder_CompilaCampi ,'error');
        }else{
            insertOrderTemplate({   accId: this.selectedAccountId,
                orderTempId : this.selectedOption,
                responsabile: this.selectedResponsible
            })
            .then(result => {

            console.log('result ===> '+result);
            // Show success messsage
            this.handleShowToastMsg(this.label.ART_Success,this.label.ART_CreateOrder_SuccessMsg,'success');
            
            this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result,
                        //objectApiName: 'Case', // objectApiName is optional
                        actionName: 'view'
                    }
                });
            })
            .catch(error => {
                console.error(error);
                this.error = error.message;
                this.handleShowToastMsg('Error!!',error.message,'error');
            });
        }
    }

    refreshFiltri() {
        this.selectedOption = '';
        this.options =  [];
        this.required = true;
    }

    handleShowToastMsg(tittolo, messagio , variante){
        this.dispatchEvent(new ShowToastEvent({
            title: tittolo,
            message: messagio,
            variant: variante
            }),
        );
    }

    //DK START DE-067
    @track shareOrder = false;
    @track selectedResponsible = null;
    @track chooseResponsabile = false;
    @api userFilter = "";

    @track userInfo;
    @track userIdSet;
    @api visibilitySet = [
        'CGCloud_Sales_Area_Manager',
        'CGCloud_Area_Manager',
        'Contact Center Operator'
    ];

    handleCustomEventUser(event) {
        console.log('@@@@@selectedResponsible: '+JSON.stringify(event.detail));
        this.selectedResponsible = Boolean(event.detail) ? event.detail.obj.Id : null;
    }

    changeToggle(event) {
        this.shareOrder = event.target.checked;
        if(!this.shareOrder){
            this.selectedResponsible = null;
        }
    }

    //DK END DE-067
    
}