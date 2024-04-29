import { LightningElement,api,track } from 'lwc';
import IMG_Resource from "@salesforce/resourceUrl/Spunta_Verde";
import getFieldsAndRecords from '@salesforce/apex/PoloWealthNotificaSCA_Controller.getFieldsAndRecords';
import getRecord from '@salesforce/apex/PoloWealthNotificaSCA_Controller.getRecord';
import cifraDati from '@salesforce/apex/PoloWealthNotificaSCA_Controller.cifraDati';
import sendPush from '@salesforce/apex/PoloWealthNotificaSCA_Controller.sendPush';
import inserisciOperazione from '@salesforce/apex/PoloWealthNotificaSCA_Controller.inserisciOperazione';
import recuperaStatoOperazione from '@salesforce/apex/PoloWealthNotificaSCA_Controller.recuperaStatoOperazione';
//DK new Annulla Operazione
import cancelOperation from '@salesforce/apex/PoloWealthNotificaSCA_Controller.cancelOperation';
//DK new Annulla Operazione
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PoloWealthNotificaSCA extends LightningElement {
    @api title;
    @api recordId;
    @api firstButtonLabel;
    @api secondButtonLabel;
    @api firstStepOKMessage;
    @api firstStepKOMessage;
    @api erroNoSelection;
    @api secondStepKOMessage;
    @api thirdStepMessage;
    @track isStep1=false;
    @track isStep2=false;
    @track isStep3=false;
    @track columns=[];
    @track tableData=[];
    @track selectedRows=[];
    @track userId;
    @track dati;
    @track notId;
    @track abi;
    @track showSpinner = false;
    imageUrl=IMG_Resource;

    connectedCallback(){
        this.showSpinner = true;
        getRecord({recordId: this.recordId})
        .then(item=>{
            this.abi=item.Account.FinServ__BankNumber__c;
            this.accountId = item.AccountId;
            if(item.CC_notificationId__c==null){
                this.handleGetFieldsAndRecords();
            }
            else if(item.CC_notificationId__c!=null && item.CRM_CustomerAuthenticationType__c!='Strong Authentication'){
                this.notId=item.CC_notificationId__c;
                this.isStep2=true;
                this.showSpinner = false;
            }
            else if(item.CC_notificationId__c!=null && item.CRM_CustomerAuthenticationType__c=='Strong Authentication'){
                this.notId=item.CC_notificationId__c;
                this.isStep3=true;
                this.showSpinner = false;
            }
        })
        .catch(error=>{
            console.log('@@@polo error: '+JSON.stringify(error));
        });
        

    }

    getSelectedRow(event){
        let row = event.detail.selectedRows;
        this.userId=row[0].CRM_UserId__c;
    }

    async handleFirstStep(){
        if(this.userId==null){
            const toastEvent = new ShowToastEvent({
                title: "Errore!",
                message: this.erroNoSelection,
                variant: "error"
            });
            this.dispatchEvent(toastEvent);
            return;
        }
        try{
            this.showSpinner = true;
            // this.dati= await cifraDati({userId: this.userId, abi: this.abi});
            let responseCifraDati = await cifraDati({userId: this.userId, abi: this.abi});
            if(responseCifraDati.result.startsWith("errore")){
                throw new Error(this.dati);
            }
            this.dati= responseCifraDati.result;
            this.myHex = responseCifraDati.myHex;
            this.notId= await sendPush({userId: this.userId, dati: this.dati, abi: this.abi});
            if(this.notId.startsWith("errore")){
                throw new Error(this.notId);
            }
            let op=await inserisciOperazione({userId: this.userId, notId: this.notId, recordId: this.recordId, myHex: this.myHex});
            if(op.startsWith("errore")){
                throw new Error(this.op);
            }
            this.showSpinner = false;
            const toastEvent = new ShowToastEvent({
                title: "Successo!",
                message: this.firstStepOKMessage,
                variant: "success"
            });
            this.dispatchEvent(toastEvent);
            this.isStep1=false;
            this.isStep2=true;
        }
        catch(error){
            console.log('@@@polo error: '+JSON.stringify(error));
            this.showSpinner = false;
            const toastEvent = new ShowToastEvent({
                title: "Errore!",
                message: this.firstStepKOMessage,
                variant: "error"
            });
            this.dispatchEvent(toastEvent);
            this.isStep1=true;
            this.isStep2=false;
        }
        
        

    }

    async handleSecondStep(){
        try{
            this.showSpinner = true;
            let op= await recuperaStatoOperazione({notId: this.notId, recordId: this.recordId, myHex: this.myHex});
            if(op.startsWith("errore")){
                throw new Error(this.op);
            }
            this.showSpinner = false;
            this.isStep2=false;
            this.isStep3=true;

        }
        catch(error){
            console.log('@@@polo error: '+JSON.stringify(error));
            this.showSpinner = false;
            const toastEvent = new ShowToastEvent({
                title: "Errore!",
                message: this.secondStepKOMessage,
                variant: "error"
            });
            this.dispatchEvent(toastEvent);
            this.isStep2=true;
            this.isStep3=false;
        }
    }

    // DK ADDED 26-11-2024
    @api thirdButtonLabel = 'Annulla richiesta';
    myHex;
    accountId;
    handleGetFieldsAndRecords(){

        return getFieldsAndRecords({accountId: this.accountId})
        .then(data=>{
            let objStr = JSON.parse(data);   
            let listOfFields= JSON.parse(Object.values(objStr)[1]);
            let listOfRecords = JSON.parse(Object.values(objStr)[0]);
            let items = [];
            Object.keys(listOfFields).map(element=>{
                items = [...items ,{label: listOfFields[element].Label, 
                    fieldName: listOfFields[element].Name, order: listOfFields[element].Order}];
            });
            this.columns=items.sort((a,b)=>{
                return  a.order - b.order;
            });
            this.tableData = listOfRecords;
            if(listOfRecords.length>0){
                this.isStep1=true;
                if(listOfRecords.length==1){
                    let temp=[];
                    temp.push(listOfRecords[0].Id);
                    this.selectedRows=[...temp];
                    this.userId=listOfRecords[0].CRM_UserId__c;
                }
            }
        })
        .catch(error=>{
            console.log('@@@polo error: '+JSON.stringify(error));
        })
        .finally(() =>{
            this.showSpinner = false;
        });
    }

    handleBack(){
        try {
            
            this.showSpinner = true;
            cancelOperation({recordId: this.recordId})
            .then(() =>{
                this.handleGetFieldsAndRecords();
                this.isStep1=true;
                this.isStep2=false;
                this.isStep3=false;
            })
            .catch(err =>{
                console.error('DK cancelOperation.error', err);
            })
            .finally(() =>{
                this.showSpinner = false;
            })
        } catch (error) {
            this.showSpinner = false;
            console.log('DK handleBack.error', error);
        }
    }
}