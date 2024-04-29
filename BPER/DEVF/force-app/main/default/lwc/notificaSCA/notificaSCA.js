import { LightningElement, track, wire, api } from 'lwc';
import getFieldsAndRecords from '@salesforce/apex/notificaSCA_Controller.getFieldsAndRecords';
import getResponse from '@salesforce/apex/MakeRequestV2Controller.getResponse';
import getRecordX from '@salesforce/apex/notificaSCA_Controller.getRecord';
import { getRecord } from 'lightning/uiRecordApi';
import CASE_AccountId from "@salesforce/schema/Case.AccountId";

export default class NotificaSCA extends LightningElement {
    @api recordId;
    @api abiBanca;
    @api idUtente;
    @api apiRequests = 'verificaSca,autorizzazioneSca,finalizzazioneSca';
    @api currentRequest = '';
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
    @track verificaSca = false;
    @track autorizzaSca = false;
    @track finalizzaSca = false;
    @track hasNoCointestazioneLinkedNdg = false;


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


    /*connectedCallback(){

        this.isRendered = false;
        this.conditionsMap = {};
        this.parseJSONMap = {};
        let request = new XMLHttpRequest();
        request.open("GET", jsonWrapper, false);
        request.send(null);
        this.parsedJson = JSON.parse(request.responseText);
        this.additionalFieldsToQuery = [];
        console.log('DK ALL REQUESTS ', this.apiRequests);
        this.apiRequests.split(',').forEach(requestToApiGateway =>{
            console.log('DK requestToCheck ', requestToApiGateway);
            if(this.parsedJson[requestToApiGateway]){
                this.parseJSONMap[requestToApiGateway] = this.parsedJson[requestToApiGateway].fields;
                this.conditionsMap[requestToApiGateway] = this.parsedJson[requestToApiGateway].conditionList ? this.parsedJson[requestToApiGateway].conditionList : null;
            }
        });

        init({recordId: this.recordId, parseJSONMap: this.parseJSONMap, conditionsMap: this.conditionsMap, additionalFields : null})
        .then(result => {
            this.currentUser= result.currentUser;
            this.record = result['record'];
            this.relatedListMap = result['relatedListMap'];
            console.log('GR currentUser: ', this.currentUser);
        }).catch((error) => {
            console.log('DK init.error: ', error);
        })

        getOrgId({})
        .then(result => {
            console.log('result: ',result);
            result === true ? this.certificate = 'salesforcetestclient2024': this.certificate = 'salesforceprodclient2024';
        }).catch((error) => {
            console.log('DK init.error: ', error);
        });
    }*/


    handleGetFieldsAndRecords(){

        return getFieldsAndRecords({caseId: this.recordId})
        .then(data=>{
            let objStr = JSON.parse(data);  
            this.hasNoCointestazioneLinkedNdg = JSON.parse(Object.values(objStr)[2]); 
            let listOfFields= JSON.parse(Object.values(objStr)[1]);
            let listOfRecords = JSON.parse(Object.values(objStr)[0]);
            let items = [];

            Object.keys(listOfFields).map(element=>{
                items = [...items ,{label: listOfFields[element].Label, 
                    fieldName: listOfFields[element].Name, order: listOfFields[element].Order}];
            });
            
            if(this.hasNoCointestazioneLinkedNdg) {
                items.push({ label: 'Rapporto di Collegamento', fieldName: 'Rapporto di Collegamento'});
            }
        
            this.columns=items.sort((a,b)=>{
                return  a.order - b.order;
            });
            console.log('GR columns: ' +  JSON.stringify(this.columns));
            
            this.tableData = listOfRecords;
            console.log('GR tableData: ' +  JSON.stringify(this.tableData));

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
        console.log('GR RECORD ID' + this.recordId);

        this.currentRequest = 'verificaSca';

        getRecordX({recordId: this.recordId})
        .then(result => {
            console.log('GR result: '+ JSON.stringify(result));
            this.abiBanca = result.Account.FinServ__BankNumber__;
            //this.idUtente =
        })
        .catch(error => {
            console.error('GR error:', error);
        });

        const requestBody = {
            abiBanca: this.abiBanca,
            idUtente: this.idUtente
        };

        //Richiama servizio VerificaSca

        getResponse({
            record: this.recordId, 
            requestToApiGateway: this.currentRequest, 
            parseJSON: requestBody, 
            conditions: null, 
            certificateName: 'salesforcetestclient2024', 
            disableLog: false, 
            addingParamsMap: null 
        })
        .then(result => {
            console.log('GR result getResponse:', result);
            console.log('DK handleSendRequest_resolveApexPromises.result', result);
            /*if(result.response.statusCode == '200'){
                
                let payload = JSON.parse(result.response.data);
                console.log('DK handleSendRequest_payload', payload);
                //console.log('DK handleSendRequest_this.relatedListMap', this.relatedListMap);
            }*/
        })
        .catch(error => {
            console.error('GR error getResponse:', error);
            this.isRendered = true;
            this.loadedAll = true;
            console.log(error);
        })
        .finally(() => {
              //se restituisce OK
           /* if (VerificaSca) {
                this.step0 = false;
                this.step1 = true;
            } else {
                const event = new ShowToastEvent({ message: 'C\'è stato un errore imprevisto, si prega di riprovare.', variant: 'error',});
                this.dispatchEvent(event);
            }
            this.dispatchEvent(new RefreshEvent()); 
            this.isRendered = true; */
            console.log('DK END handleSendRequest');

        });
       
    }

    handleInviaNotifica() {
        //TODO Richiama servizio AutorizzaSca
        /*this.currentRequest = 'autorizzazioneSca';
        getResponse({
            record: this.record,
            requestToApiGateway: this.currentRequest,
            parseJSON: this.parsedJson[this.currentRequest].fields,
            conditions: this.parsedJson[this.currentRequest].conditionList ? this.parsedJson[this.currentRequest].conditionList : null,
            certificateName: this.certificateName,
            disableLog: this.disableLog,
            addingParamsMap: null
        })
        .then(result =>{
            console.log('DK handleSendRequest_resolveApexPromises.result', result);
            if(result.response.statusCode == '200'){
                
                let payload = JSON.parse(result.response.data);
                console.log('DK handleSendRequest_payload', payload);
                console.log('DK handleSendRequest_this.relatedListMap', this.relatedListMap);
            }
        })
        .catch((error) => {
            this.isRendered = true;
            this.loadedAll = true;
            console.log(error);
        })
        .finally(() => {
            //se restituisce OK
            if(autorizzaSca){
                this.step1 = false;
                this.step2B = true;
            }else{
                const event = new ShowToastEvent({ message: 'C\'è stato un errore imprevisto, si prega di riprovare.', variant: 'error',});
                this.dispatchEvent(event);
            }
            this.dispatchEvent(new RefreshEvent()); 
            console.log('DK END handleSendRequest');
            this.isRendered = true; 
        });*/
    }
    
    handleInserisciOTP() {
        //TODO Richiama servizio AutorizzaSca
       /* this.currentRequest = 'autorizzazioneSca';
        getResponse({
            record: this.record,
            requestToApiGateway: this.currentRequest,
            parseJSON: this.parsedJson[this.currentRequest].fields,
            conditions: this.parsedJson[this.currentRequest].conditionList ? this.parsedJson[this.currentRequest].conditionList : null,
            certificateName: this.certificateName,
            disableLog: this.disableLog,
            addingParamsMap: null
        })
        .then(result =>{
            console.log('DK handleSendRequest_resolveApexPromises.result', result);
            if(result.response.statusCode == '200'){
                
                let payload = JSON.parse(result.response.data);
                console.log('DK handleSendRequest_payload', payload);
                console.log('DK handleSendRequest_this.relatedListMap', this.relatedListMap);
            }
        })
        .catch((error) => {
            this.isRendered = true;
            this.loadedAll = true;
            console.log(error);
        })
        .finally(() => {
             //se restituisce OK
            if (autorizzaSca) {
                this.step1 = false;
                this.step2A = true;
            } else {
                const event = new ShowToastEvent({ message: 'C\'è stato un errore imprevisto, si prega di riprovare.', variant: 'error',});
                this.dispatchEvent(event);
            }
            this.dispatchEvent(new RefreshEvent()); 
            console.log('DK END handleSendRequest');
            this.isRendered = true; 
        });*/
    }

    handleVerifica() {
        //TODO Richiama servizio Finalizza con l'OTP come parametro
        /*this.currentRequest = 'finalizzazioneSca';
        getResponse({
            record: this.record,
            requestToApiGateway: this.currentRequest,
            parseJSON: this.parsedJson[this.currentRequest].fields,
            conditions: this.parsedJson[this.currentRequest].conditionList ? this.parsedJson[this.currentRequest].conditionList : null,
            certificateName: this.certificateName,
            disableLog: this.disableLog,
            addingParamsMap: null
        })
        .then(result =>{
            console.log('DK handleSendRequest_resolveApexPromises.result', result);
            if(result.response.statusCode == '200'){
                
                let payload = JSON.parse(result.response.data);
                console.log('DK handleSendRequest_payload', payload);
                console.log('DK handleSendRequest_this.relatedListMap', this.relatedListMap);
            }
        })
        .catch((error) => {
            this.isRendered = true;
            this.loadedAll = true;
            console.log(error);
        })
        .finally(() => {
            //se restituisce OK
            if(finalizzaSca){
                this.step2A = false;
                this.step3A = true;
            }else{
                this.step2A = false;
                this.step3B = true;
                const event = new ShowToastEvent({ message: 'C\'è stato un errore imprevisto, la verifica non è andata a buon fine, si prega di riprovare.', variant: 'error',});
                this.dispatchEvent(event);
                //TODO Semaforo blu su case Strong Auth
            }
            this.dispatchEvent(new RefreshEvent()); 
            console.log('DK END handleSendRequest');
            this.isRendered = true; 
        });*/
    }

    handleVerificaAutorizzazione() {
        //TODO Richiama servizio FinalizzaSca
       /* this.currentRequest = 'finalizzazioneSca';
        getResponse({
            record: this.record,
            requestToApiGateway: this.currentRequest,
            parseJSON: this.parsedJson[this.currentRequest].fields,
            conditions: this.parsedJson[this.currentRequest].conditionList ? this.parsedJson[this.currentRequest].conditionList : null,
            certificateName: this.certificateName,
            disableLog: this.disableLog,
            addingParamsMap: null
        })
        .then(result =>{
            console.log('DK handleSendRequest_resolveApexPromises.result', result);
            if(result.response.statusCode == '200'){
                
                let payload = JSON.parse(result.response.data);
                console.log('DK handleSendRequest_payload', payload);
                console.log('DK handleSendRequest_this.relatedListMap', this.relatedListMap);
            }
        })
        .catch((error) => {
            this.isRendered = true;
            this.loadedAll = true;
            console.log(error);
        })
        .finally(() => {
            //se restituisce OK
            if(finalizzaSca){
                this.step2B = false;
                this.step3C = true;
            }else{
                this.step2B = false;
                this.step3D = true;
                const event = new ShowToastEvent({ message: 'C\'è stato un errore imprevisto, la verifica non è andata a buon fine, si prega di riprovare.', variant: 'error',});
                this.dispatchEvent(event);
                //TODO Semaforo blu su case Strong Auth
            }
            this.dispatchEvent(new RefreshEvent()); 
            console.log('DK END handleSendRequest');
            this.isRendered = true; 
        });*/
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