import { LightningElement, track, api, wire } from 'lwc';
import init from '@salesforce/apex/MakeRequestV2Controller.init';
import getResponse from '@salesforce/apex/MakeRequestV2Controller.getResponse';
import saveElements from '@salesforce/apex/MakeRequestV2Controller.saveElements';
import jsonWrapper from '@salesforce/resourceUrl/jsonWrapper_v2';
//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class ListaPiani extends LightningElement {
    @api recordId;
    @api currentUser;
    @api apiRequests = 'listaPiani';
    @api certificateName;
    @api disableLog;
    @api title;
    @api buttonLabel;

    @track isRendered = false;

    parsedJson;

    @track numeroPianoParam = '';
    @track loadedAll = true;
    @track canCall = false;
    @track lastCallSet = false;
    additionalFieldsToQuery = []
    connectedCallback(){

        // Create a request for the JSON data and load it synchronously,
        // parsing the response as JSON into the tracked property
        try {
            
            let request = new XMLHttpRequest();
            request.open("GET", jsonWrapper, false);
            request.send(null);
            this.parsedJson = JSON.parse(request.responseText);
            let parseJSONMap = {};
            let conditionsMap = {};
    
            parseJSONMap[this.apiRequests] = this.parsedJson[this.apiRequests].fields;
            conditionsMap[this.apiRequests] = this.parsedJson[this.apiRequests].conditionList ? this.parsedJson[this.apiRequests].conditionList : null;
    
            if(this.parsedJson[this.apiRequests].lastCall){
                this.additionalFieldsToQuery.push(this.parsedJson[this.apiRequests].lastCall); 
            }
            init({recordId: this.recordId, parseJSONMap: parseJSONMap, conditionsMap: conditionsMap, additionalFields : this.additionalFieldsToQuery})
            .then(result => {
                
                console.log('DK init_result: ', result);
                this.record = result['record'];
                this.relatedListMap = result['relatedListMap'];
                this.currentUser = result['currentUser'];
                /*if(!Boolean(this.title)){this.title = 'Aggiornamento dati real time';}
                if(!Boolean(this.buttonLabel)){this.buttonLabel = 'Carica Piani Rateali';}*/
                if(!this.lastCallSet){

                    this.handleSendRequest();
                }
            }).catch((error) => {
                console.log('DK init_error:', error);
            })
        } catch (error) {
            
        }
    }

    @track showMessage = false;
    @track isSuccess;
    handleSendRequest(){
        console.log('DK START handleSendRequest');
        console.log('DK handleSendRequest_record', this.record);
        console.log('DK handleSendRequest_loadedAll', this.loadedAll);
        console.log('DK handleSendRequest_numeroPianoParam', this.numeroPianoParam);
        this.isRendered = false;
        var lastCall = this.record[this.parsedJson[this.apiRequests].lastCall] ? new Date(new Date(new Date(this.record[this.parsedJson[this.apiRequests].lastCall]).toISOString().slice(0,10)).toISOString().slice(0, -1)) : null;
        console.log('DK handleSendRequest_lastCall', lastCall);
        
        var today = new Date(new Date(new Date().toISOString().slice(0,10)).toISOString().slice(0, -1));
        console.log('DK handleSendRequest_today', today);

        /*if(this.canCall || (!this.parsedJson[this.apiRequests].check ||
            lastCall === null || lastCall === undefined ||
            (
            (this.parsedJson[this.apiRequests].check &&
            lastCall < today) ||
            this.parsedJson[this.apiRequests].bypass.includes(this.currentUser.Profile.Name.toLowerCase())
            )
        )){*/

            let additionalParamsMap = this.numeroPianoParam > 0 ? {'numeroPianoParam' : this.numeroPianoParam} : null;
            console.log('DK handleSendRequest_additionalParamsMap', additionalParamsMap);
            return getResponse({
                record: this.record,
                requestToApiGateway: this.apiRequests,
                parseJSON: this.parsedJson[this.apiRequests].fields,
                conditions: this.parsedJson[this.apiRequests].conditionList ? this.parsedJson[this.apiRequests].conditionList : null,
                certificateName: this.certificateName,
                disableLog: this.disableLog,
                addingParamsMap: additionalParamsMap
            })
            .then(result =>{
                console.log('DK handleSendRequest_resolveApexPromises.result', result);
                let loadNewPage = false;
                let lastRecordVersion = this.record;
                let ultimoNumeroPiano = '';
                if(result.response.statusCode == '200'){
                    
                    let payload = JSON.parse(result.response.data);
                    console.log('DK handleSendRequest_payload', payload);
                    console.log('DK handleSendRequest_this.relatedListMap', this.relatedListMap);
                    let recordToUpdateList = [];
                    let painiRatealiToInsert = [];
                    if(payload.listaPiani){
                        payload.listaPiani.forEach(pianoRateale =>{
                            let pianoRatealeToUpsert = this.relatedListMap.CRM_PianiRateali__r && this.relatedListMap.CRM_PianiRateali__r[pianoRateale.numeroPiano] ? this.relatedListMap.CRM_PianiRateali__r[pianoRateale.numeroPiano] : {CRM_FinancialAccount__c: this.recordId, attributes: {type: 'CRM_PianoRateale__c'}};
                            // pianoRatealeToUpsert.attributes = {type: 'CRM_PianoRateale__c'};
                            let dataAttivazione = pianoRatealeToUpsert.CRM_DataAttivazione__c;
                            let dataEstinzione = pianoRatealeToUpsert.CRM_DataScadenza__c;
                            if(Boolean(pianoRateale.numeroPiano)){pianoRatealeToUpsert.CRM_IdPianoRateale__c = pianoRateale.numeroPiano;}
                            if(Boolean(pianoRateale.numeroPiano)){pianoRatealeToUpsert.Name = pianoRateale.numeroPiano;}
                            if(Boolean(pianoRateale.importo)){pianoRatealeToUpsert.CRM_ImportoPianoRateale__c = pianoRateale.importo;}
                            if(Boolean(pianoRateale.dataAttivazione)){pianoRatealeToUpsert.CRM_DataAttivazione__c = Number(pianoRateale.dataAttivazione.split('-')[0]) >= 1700 && Number(pianoRateale.dataAttivazione.split('-')[0]) <= 4000 ? pianoRateale.dataAttivazione.split('T')[0] : dataAttivazione;}
                            if(Boolean(this.recordId)){pianoRatealeToUpsert.CRM_FinancialAccount__c = this.recordId;}
                            if(Boolean(pianoRateale.stato)){pianoRatealeToUpsert.CRM_Stato__c = pianoRateale.stato;}
                            if(Boolean(pianoRateale.dataEstinzione)){pianoRatealeToUpsert.CRM_DataScadenza__c = Number(pianoRateale.dataEstinzione.split('-')[0]) >= 1700 && Number(pianoRateale.dataEstinzione.split('-')[0]) <= 4000 ? pianoRateale.dataEstinzione.split('T')[0] : dataEstinzione;}
                            if(Boolean(this.record.FinServ__PrimaryOwner__r.FinServ__BankNumber__c +'|'+this.record.CRM_Rapporto__c+'|'+pianoRateale.numeroPiano)){pianoRatealeToUpsert.NDW_ExternalId__c = this.record.FinServ__PrimaryOwner__r.FinServ__BankNumber__c +'|'+this.record.CRM_Rapporto__c+'|'+pianoRateale.numeroPiano;}
                            console.log('DK pianoRateale.dataEstinzione: ' + pianoRateale.dataEstinzione);
                            console.log('DK handleSendRequest_pianoRatealeToUpsert:', pianoRatealeToUpsert);
                            if(this.relatedListMap.CRM_PianiRateali__r && this.relatedListMap.CRM_PianiRateali__r[pianoRateale.numeroPiano]){
                                recordToUpdateList.push(pianoRatealeToUpsert);
                            }else{
                                painiRatealiToInsert.push(pianoRatealeToUpsert);
                            } 
                        });
    
                        if(payload.listaPiani.length == 25){
                            loadNewPage = true;
                            ultimoNumeroPiano = payload.listaPiani[24].numeroPiano;
                        }else{
                            loadNewPage = false;
                        }
                    }
                    
                    // valorizza data ultima esecuzione se necessario
                    console.log('DK handleSendRequest_lastCall', this.parsedJson[this.apiRequests].lastCall);
                    if(this.parsedJson[this.apiRequests].lastCall && !this.lastCallSet){
                        this.record[this.parsedJson[this.apiRequests].lastCall] = new Date();
                        lastRecordVersion = this.record;
                        lastRecordVersion.CRM_PianiRateali__r = undefined;
                        lastRecordVersion.attributes = {type: 'FinServ__FinancialAccount__c'};
                        console.log('Dk lastRecordVersion', lastRecordVersion);
                        recordToUpdateList.push(lastRecordVersion);
                        this.lastCallSet = true;
                    }
                    console.log('DK handleSendRequest_painiRatealiToInsert', painiRatealiToInsert);
                    console.log('DK handleSendRequest_recordToUpdateList', recordToUpdateList);
                    if(recordToUpdateList.length > 0 || painiRatealiToInsert.length > 0){
                        return saveElements({recordToUpdateJSON: JSON.stringify(recordToUpdateList), recordToInsertJSON: JSON.stringify(painiRatealiToInsert)})
                        .then(result=>{
                            this.showMessage = true;
                            this.isSuccess = true;
                            // this.isRendered = true;
                            // const toastEvent = new ShowToastEvent({
                            //     title: "Success!",
                            //     message: "Salvataggio completato!!",
                            //     variant: "success"
                            // });
                            // this.dispatchEvent(toastEvent);
                            if(loadNewPage){
                                this.numeroPianoParam  = ultimoNumeroPiano;
                                this.loadedAll = false;
                                this.canCall = true;
                                this.connectedCallback();
                            }else{
                                this.canCall = false;
                                this.loadedAll = true;
                            }
                        })
                        .catch(error =>{
                            this.showMessage = true;
                            this.isSuccess = false;
                            console.log(error);
                            this.isRendered = true;
                            this.canCall = false;
                            this.loadedAll = true;
                            /*const toastEvent = new ShowToastEvent({
                                title: "Errore!",
                                message: "Errori durante il salvataggio. Contattare il proprio Amministratore di Sistema.",
                                variant: "error"
                            });
                            this.dispatchEvent(toastEvent);*/
                        }).finally(() =>{
                            this.record = lastRecordVersion;
                            console.log('Dk this.record', this.record);
                        });
                    }
                }
            })
            .catch((error) => {
                this.isRendered = true;
                this.loadedAll = true;
                console.log(error);
            })
            .finally(() => {
                eval("$A.get('e.force:refreshView').fire();");
                console.log('DK END handleSendRequest');
                this.isRendered = true;
            });
        /*}else{
            this.isRendered = true;
        }*/
    }
}