import { LightningElement, track, api, wire } from 'lwc';
import init from '@salesforce/apex/MakeRequestV2Controller.init';
import getResponse from '@salesforce/apex/MakeRequestV2Controller.getResponse';
import jsonWrapper from '@salesforce/resourceUrl/jsonWrapper_v2';
import updateUser from '@salesforce/apex/ClickToDial_Controller.updateUser';
import getOrgId from '@salesforce/apex/ClickToDial_Controller.getOrgId';
import getPhoneNumbers from '@salesforce/apex/ClickToDial_Controller.getPhoneNumbers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import UserPreferencesShowFaxToExternalUsers from '@salesforce/schema/User.UserPreferencesShowFaxToExternalUsers';

export default class ClickToDial extends LightningElement {

    @api recordId;
    @api apiRequests = 'risoluzioneIndirizzi,bperTelephony';
    @api currentRequest = '';
    @api certificate;
    @api logDisable;
    @api title = 'Chiama';
    @api buttonLabel = 'Aggiorna dati';
    @api buttonLabelPhone = 'Chiama';
    @api currentUser;
    @api phoneNumber;
    @api iconName= 'utility:outbound_call';


    @track isRendered = false;
    @track isReadyToSecondCall = false; 
    @track picklistPhone = false;
    @track isReadyToFirstCall = true;

    @api phoneOptions=[];
    @api phoneNumberList=[];
    @api conditionsMap = {};
    @api parseJSONMap = {};
    @api additionalFieldsToQuery = [];
    
    parsedJson;
    record = [];


    connectedCallback(){
        this.isRendered = false;
        this.conditionsMap = {};
        this.parseJSONMap = {};
        // Create a request for the JSON data and load it synchronously,
        // parsing the response as JSON into the tracked property
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
                if(this.parsedJson[requestToApiGateway].lastCall && !this.parsedJson[requestToApiGateway].isLastCallFromUser){
                    this.additionalFieldsToQuery.push(this.parsedJson[requestToApiGateway].lastCall); 
                }
            }
        });
        init({recordId: this.recordId, parseJSONMap: this.parseJSONMap, conditionsMap: this.conditionsMap, additionalFields : this.additionalFieldsToQuery})
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
        }).finally(() => {

            let recordLastCallCheck = this.parsedJson['risoluzioneIndirizzi'].isLastCallFromUser ? this.currentUser : this.record;
            var lastCall = this.parsedJson['risoluzioneIndirizzi'].lastCall && recordLastCallCheck[this.parsedJson['risoluzioneIndirizzi'].lastCall] ? new Date(new Date(new Date(recordLastCallCheck[this.parsedJson['risoluzioneIndirizzi'].lastCall]).toISOString().slice(0,10)).toISOString().slice(0, -1)) : null;
            var today = new Date(new Date(new Date().toISOString().slice(0,10)).toISOString().slice(0, -1));
            console.log('DK is new day:', lastCall < today);

            if(!this.parsedJson['risoluzioneIndirizzi'].check ||
                lastCall === null || lastCall === undefined ||
                (
                    (this.parsedJson['risoluzioneIndirizzi'].check &&
                    lastCall < today) ||
                    this.parsedJson['risoluzioneIndirizzi'].bypass.includes(this.currentUser.Profile.Name.toLowerCase())
                )
            ){          
                this.currentRequest = 'risoluzioneIndirizzi';
                this.isReadyToSecondCall= false;
            }else{
                this.currentRequest = 'bperTelephony';
                this.isReadyToSecondCall = true;
                this.callGetPhoneNumbers();
            }
            this.isRendered = true;
        });
    }
 

    executeCall(event){
        try{
            this.currentRequest = event.target.name == 'aggiornaDati' ? 'risoluzioneIndirizzi' : 'bperTelephony';
            this.handleSendRequest();
        }catch(error) {
            console.log('GR error: '+ error);
        }
       
    }
    
    callGetPhoneNumbers(){
        return getPhoneNumbers({AccountId: this.recordId})
        .then(result => {
            if(result){
                this.phoneOptions = [];
                console.log('GR result: ',JSON.stringify(result));
                for (const [key, value] of Object.entries(result)) {
                    const option = {
                        label: key + ' (' + value + ')',
                        value: value
                    };
                    this.phoneOptions.push(option);
                }
            }
            this.isRendered= true;
        })
        .catch(error => {
            console.error('GR error: ', error);
        });
    }

    handleSendRequest(){
        try {
            this.isRendered= false;
            let additionalParamsMap = this.phoneNumber != null ? {'numeroTel' : this.phoneNumber} : null;  
            if(this.parseJSONMap[this.currentRequest]){               
                var lastCall = this.parsedJson[this.currentRequest].lastCall && this.currentUser[this.parsedJson[this.currentRequest].lastCall] ? new Date(new Date(new Date(this.currentUser[this.parsedJson[this.currentRequest].lastCall]).toISOString().slice(0,10)).toISOString().slice(0, -1)) : null;
                var today = new Date(new Date(new Date().toISOString().slice(0,10)).toISOString().slice(0, -1));

                if(!this.parsedJson[this.currentRequest].check ||
                    lastCall === null || lastCall === undefined ||
                    (
                        (this.parsedJson[this.currentRequest].check &&
                        lastCall < today) ||
                        this.parsedJson[this.currentRequest].bypass.includes(this.currentUser.Profile.Name.toLowerCase())
                    )
                ){
                    let addingParamsMap = this.currentRequest == 'bperTelephony' ? {'indirizzoMAC' : this.currentUser.MACAddress__c, 'numeroTel' : this.phoneNumber}: {};
                    getResponse({
                        record: this.currentUser,
                        requestToApiGateway: this.currentRequest,
                        parseJSON: this.parsedJson[this.currentRequest].fields,
                        conditions: this.parsedJson[this.currentRequest].conditionList ? this.parsedJson[this.currentRequest].conditionList : null,
                        certificateName: this.certificate,
                        disableLog: this.logDisable,
                        addingParamsMap: addingParamsMap
                    })
                    .then(result => {
                        
                        console.log('DK resolveApexPromises.result ', result);
                        if(result.response.statusCode == '200'){
                            console.log('DK lastCall ', this.parsedJson[this.currentRequest].lastCall);
                            if(this.parsedJson[this.currentRequest].lastCall){
                                this.currentUser[this.parsedJson[this.currentRequest].lastCall] = new Date();
                            }
                            const resultJson = JSON.parse(result.response.data);
                            
                            if(this.currentRequest == 'risoluzioneIndirizzi'){
                                // DK è stata eseguita la chiamata per aggiornare maCAddress ed ha avuto esito positivo
                                // DK aggiorno record User
                                if (resultJson && resultJson.indirizzoMAC) {
                                    this.currentUser.MACAddress__c = resultJson.indirizzoMAC;
                                }
                                console.log('MacAddress__c: ', this.currentUser.MACAddress__c);
                                updateUser({currentUser: this.currentUser})
                                .then(() => {
                                    this.callGetPhoneNumbers()
                                    .then(() =>{
                                        this.isReadyToSecondCall = true;
                                    })
                                    .catch(error => {
                                        console.error('GR error: ', error);
                                    });
                                })
                                .catch(error => {
                                    console.error('GR error: ', error);
                                }); 
                            }else{
                                // DK è stata eseguita la chiamata ed ha avuto esito positivo
                                // DK mostro toast SUCCESS
                                let messaggio = '';
                                messaggio = 'Operazione Completata, la chiamata al numero ' + this.phoneNumber + ' è stata inoltrata correttamente. \n';
                                updateUser({currentUser: this.currentUser})
                                .then(() => {
                                    this.isRendered= true;
                                    this.closeQuickAction();
                                    const toastEvent = new ShowToastEvent({
                                        title: "Successo!",
                                        message: messaggio,
                                        variant: "success"
                                    });
                                    this.dispatchEvent(toastEvent);
                                    eval("$A.get('e.force:refreshView').fire();");

                                })
                                .catch(error => {
                                    console.error('GR error: ', error);
                                }); 
                            }
                        }else{
                            const toastEvent = new ShowToastEvent({
                                title: "Errore!",
                                message: "La richiesta non ha avuto esito positivo",
                                variant: "error"
                            });
                            this.dispatchEvent(toastEvent); 
                        }
                    })
                    .catch((error) => {
                        this.isRendered = true;
                        console.log(error);
                    })
                    .finally(() => {
                        console.log('Finally');
                    });
                }
            }
        }catch(error) {
            console.log('GR error: ', error);
        }
    }
            
    handlePhoneChange(event) {    
        this.phoneNumber = event.detail.value.replace('+', ' ');
        let cleanPhoneNumber = this.phoneNumber.replace(/[^0-9]/g, '');
        if(cleanPhoneNumber.length === 9){
            this.phoneNumber = '0' + this.phoneNumber;
        }else{
            let getLastTenChar = cleanPhoneNumber.slice(-10);
            this.phoneNumber = getLastTenChar.length === 12? getLastTenChar.slice(2) : getLastTenChar;
            if(this.phoneNumber.length === 10){
                this.phoneNumber = '0' + this.phoneNumber;
            }
        }
        console.log('Phone selected: ', this.phoneNumber);
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }
}