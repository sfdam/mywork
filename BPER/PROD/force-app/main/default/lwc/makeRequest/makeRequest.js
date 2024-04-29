import { LightningElement, track, api, wire } from 'lwc';
import makeRequest from '@salesforce/apex/MakeRequestController.makeRequest';
import getRecordTypeName from '@salesforce/apex/MakeRequestController.getRecordTypeName';
import jsonWrapper from '@salesforce/resourceUrl/jsonWrapper';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';
//import ACCOUNT_RECORDTYPE_FIELD from "@salesforce/schema/Account.RecordType.Name";
export default class MakeRequest extends LightningElement {
    
    @api recordId;
    @api apiRequests;
    @api certificateName;
    @api disableLog;
    @track recordTypeName;

   // @track ACCOUNT_RECORDTYPE_NAME ='';
   // @track RECORDTYPE_ID

    /*@wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_RECORDTYPE_FIELD] })
    getAccount({ error, data }){
        if(data){
            
            var result = JSON.parse(JSON.stringify(data));
            console.log('acc data: ', result);
            console.log('acc data A: ', result.fields.RecordType.value.fields.Name.value);
            // this.account = result;
            // this.RECORDTYPE_ID = result.fields.RecordType.value;
            this.ACCOUNT_RECORDTYPE_NAME = result.fields.RecordType.value.fields.Name.value;
            console.log('acc data 111: ', this.RECORDTYPE_ID);
            console.log('acc data 222: ', JSON.stringify(this.ACCOUNT_RECORDTYPE_NAME));
        }else if(error) {
            var result = JSON.parse(JSON.stringify(error));
            console.log('error: ', result);
        }
    }; */

    connectedCallback() {
        // Create a request for the JSON data and load it synchronously,
        // parsing the response as JSON into the tracked property
        let request = new XMLHttpRequest();
        request.open("GET", jsonWrapper, false);
        request.send(null);
        let parsedJson = JSON.parse(request.responseText);
    
        console.log('this.apiRequests: ' + this.apiRequests);
        if (Boolean(this.apiRequests)) {
            if (!this.certificateName) {
                this.certificateName = 'salesforceprodclient2024';
            }
            this.callgetRecordTypeName().then(() => {
                let apiRequestsList = this.apiRequests.split(",");
                apiRequestsList.forEach(apiRequestName => {
                    let apiRequestsSequenceList = apiRequestName.split("#");
                    let firstRequest = apiRequestsSequenceList[0];
                    let sequenceRequestList = apiRequestsSequenceList[1] ? apiRequestsSequenceList[1].split('*') : [];
                    console.log('firstRequest - ' + firstRequest);
                    console.log('parsedJson - ' + JSON.stringify(parsedJson));
    
                    this.callMakeRequestController(firstRequest, sequenceRequestList, parsedJson);
                });
            });
        }
    }
    
    callgetRecordTypeName() {
        return new Promise((resolve, reject) => {
            getRecordTypeName({ recordId: this.recordId })
                .then(result => {
                    console.log('result -', result);
                    this.recordTypeName = result;
                    resolve();
                })
                .catch(error => {
                    console.error('Error getRecordTypeName: ' + JSON.stringify(error));
                    reject(error);
                });
        });
    }

    callMakeRequestController(firstRequest, sequenceRequestList, parsedJson){
            console.log('fieldsMap - ' + JSON.stringify(parsedJson[firstRequest].fields));
            console.log('this.firstRequesttttttttt AAA ' + firstRequest);
            /*//pz  NEC #72207
            if (firstRequest == 'getDettaglioAnagrafica'){
            console.log('DK getDettaglioAnagraficaaaaa');
            let getDettaglioAnagrafica = parsedJson[firstRequest];
            console.log('DK getDettaglioAnagrafica', firstRequest);
            let fields = parsedJson[firstRequest].fields;
            console.log('DK fields', fields);
            let consenso = fields['consenso'];
            console.log('DK consenso', consenso);
            console.log('pz RecordTypeName', this.ACCOUNT_RECORDTYPE_NAME);
            if (this.ACCOUNT_RECORDTYPE_NAME == 'Person Account'){
                consenso['devName'] = 'CRM_Privacy_1Level__c';
            }else{
                consenso['devName'] = 'CRM_BusinessPrivacy1Level__c';
            }
            fields['consenso'] = consenso;
            console.log('pz fields consenso ', fields['consenso']);
           // firstRequest[fields] = fields;
            console.log('pz firstRequest fields ', firstRequest['fields']);
            parsedJson[firstRequest] = getDettaglioAnagrafica;
            console.log('pz parsejson ', parsedJson[firstRequest]);
            console.log('pz this.parsedJson' ,parsedJson);
            console.log('pz ALL REQUESTS', this.apiRequests);
         } */
            if (firstRequest == 'getDettaglioAnagrafica'){
            console.log('DK getDettaglioAnagraficaaaaa');
            let getDettaglioAnagrafica = parsedJson[firstRequest];
            console.log('DK getDettaglioAnagrafica', firstRequest);
            let fields = parsedJson[firstRequest].fields;
            console.log('DK fields', fields);
            let consenso = fields['consenso'];
            console.log('DK consenso', consenso);
            console.log('pz RecordTypeName', this.recordTypeName);
            if (this.recordTypeName == 'Person Account'){
                consenso['devName'] = 'CRM_Privacy_1Level__c';
            }else{
                consenso['devName'] = 'CRM_BusinessPrivacy1Level__c';
            }
            fields['consenso'] = consenso;
            console.log('pz fields consenso ', fields['consenso']);
           // firstRequest[fields] = fields;
            console.log('pz firstRequest fields ', firstRequest['fields']);
            parsedJson[firstRequest] = getDettaglioAnagrafica;
            console.log('pz parsejson ', parsedJson[firstRequest]);
            console.log('pz this.parsedJson' ,parsedJson);
            console.log('pz ALL REQUESTS', this.apiRequests);
            console.log('pz json fieldmap',  parsedJson[firstRequest].fields);
            } 
            console.log('pz makeRequest apiRequestName', firstRequest);
            console.log('pz makeRequest recordId', this.recordId);
            console.log('pz makeRequest fieldsMap', JSON.stringify(parsedJson[firstRequest].fields));
            console.log('pz makeRequest conditions', parsedJson[firstRequest].conditionList ? parsedJson[firstRequest].conditionList : null,);
            console.log('pz makeRequest runAsUserId', this.certificateName);
            console.log('pz makeRequest disableLog', this.disableLog);

            makeRequest({
                apiRequestName: firstRequest,
                recordId: this.recordId,
                fieldsMap: parsedJson[firstRequest].fields,
                conditions: parsedJson[firstRequest].conditionList ? parsedJson[firstRequest].conditionList : null,
                certificateName: this.certificateName,
                runAsUserId: null,
                disableLog: this.disableLog
            }).then(data =>{
                console.log('data: ' + data);
                console.log('data.record: ' + data.record);
                console.log('data.response: ' + data.response);
                if(sequenceRequestList){
                sequenceRequestList.forEach(apiRequestName => {
                    console.log('apiRequestName - ' + apiRequestName);
                    this.callMakeRequestController(apiRequestName, null, parsedJson);
                });
            }
            console.log('data firstRequest: ' + firstRequest);
            console.log('data: ' + data);


            }).catch(reqError =>{

            console.log('makeRequest.reqError: ' + JSON.stringify(reqError));
            }).finally(() =>{
                console.log('Finally');
                this.isRendered = true;
                getRecordNotifyChange([{recordId: this.recordId}]);
            });
        
    }
}