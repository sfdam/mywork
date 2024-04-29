import { LightningElement, track, wire, api } from 'lwc';
import getFieldsAndRecords from '@salesforce/apex/notificaSCA_Controller.getFieldsAndRecords';
import getRecordX from '@salesforce/apex/notificaSCA_Controller.getRecord';
import { getRecord } from 'lightning/uiRecordApi';
import CASE_AccountId from "@salesforce/schema/Case.AccountId";

export default class NotificaSCA extends LightningElement {
    @api recordId;

    @track showSpinner = false;
    @track step0 = true;
    @track step1 = false;
    @track step2A = false;
    @track step2B = false;
    @track step3A = false;
    @track step3B = false;
    @track step3C = false;
    @track step3D = false;
    @track disabledRichiediRiconoscimento = true;

    selectedRows = [];
    columns = [];
    otpValue = '';

    @wire(getRecord, { recordId: '$recordId',  fields: [CASE_AccountId]})
    getRecord({ error, data }) {
        console.log('getRecord');
        console.log('recordId: ' + this.recordId);
        console.log('data: ' + data);
        if (data) {
            let result = JSON.parse(JSON.stringify(data));
            console.log('wire data: ', result);
            this.handleGetFieldsAndRecords();

        } else if (error) {
            console.error('Errore durante il recupero del case: ', error);
        }
    }


    handleGetFieldsAndRecords(){

        return getFieldsAndRecords({caseId: this.recordId})
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
            console.log('columns: ' +  this.columns);
            
            this.tableData = listOfRecords;
            console.log('tableData: ' +  this.tableData);

        })
        .catch(error=>{
            console.log('Errore durante il recupero dei dati: '+JSON.stringify(error));
        })
    }
    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
        this.disabledRichiediRiconoscimento = false;
    }

    handleRichiediRiconoscimento() {
        //TODO Richiama servizio VerificaSca

        //se restituisce OK
            this.step0 = false;
            this.step1 = true;
        //altrimenti
            const event = new ShowToastEvent({ message: 'C\'è stato un errore imprevisto, si prega di riprovare.', variant: 'error',});
            this.dispatchEvent(event);
    }

    handleInviaNotifica() {
        //TODO Richiama servizio AutorizzaSca
        //se restituisce OK
            this.step1 = false;
            this.step2B = true;
        //altrimenti
            const event = new ShowToastEvent({ message: 'C\'è stato un errore imprevisto, si prega di riprovare.', variant: 'error',});
            this.dispatchEvent(event);
    }
    
    handleInserisciOTP() {
        //TODO Richiama servizio AutorizzaSca
        //se restituisce OK
            this.step1 = false;
            this.step2A = true;
        //altrimenti
            const event = new ShowToastEvent({ message: 'C\'è stato un errore imprevisto, si prega di riprovare.', variant: 'error',});
            this.dispatchEvent(event);
    }

    handleVerifica() {
        //TODO Richiama servizio Finalizza con l'OTP come parametro

        //se la chiamata restituisce OK
            this.step2A = false;
            this.step3A = true;
        //altrimenti
            this.step2A = false;
            this.step3B = true;

    }

    handleVerificaAutorizzazione() {
        //TODO Richiama servizio FinalizzaSca

        //se la chiamata restituisce OK
            this.step2B = false;
            this.step3C = true;
        //altrimenti
            this.step2B = false;
            this.step3D = true;
            const event = new ShowToastEvent({ message: 'C\'è stato un errore imprevisto, la verifica non è andata a buon fine, si prega di riprovare.', variant: 'error',});
            this.dispatchEvent(event);
            //TODO Semaforo blu su case Strong Auth

    }

    handleChiudi() {
        this.step3A = false;
        this.step3C = false;
        this.step0 = true;
    }

    handleTornaIndietro() {
        this.step3B = false;
        this.step3D = false;
        this.step1 = true;
    }

    handleX() {
        this.step1 = false;
        this.step2A = false;
        this.step2B = false;
        this.step3A = false;
        this.step3B = false;
        this.step3C = false;
        this.step3D = false;
        this.step0 = true;
    }

    handleOtpChange(event) {
        this.otpValue = event.target.value;
    }

}