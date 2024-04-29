import { LightningElement, track, api, wire } from 'lwc';
import makeRequest from '@salesforce/apex/MakeRequestController.makeRequest';
import jsonWrapper from '@salesforce/resourceUrl/jsonWrapper';
export default class MakeRequest extends LightningElement {
    
    @api recordId;
    @api apiRequests;
    @api certificateName;
    @api disableLog;

    connectedCallback(){

        // Create a request for the JSON data and load it synchronously,
        // parsing the response as JSON into the tracked property
        let request = new XMLHttpRequest();
        request.open("GET", jsonWrapper, false);
        request.send(null);
        let parsedJson = JSON.parse(request.responseText);

        console.log('this.apiRequests: ' + this.apiRequests);
        if(Boolean(this.apiRequests)){
            if(!this.certificateName){
                this.certificateName = 'salesforceprodclient2022';
            }
            let apiRequestsList = this.apiRequests.split(",");
            apiRequestsList.forEach(apiRequestName => {
                let apiRequestsSequenceList = apiRequestName.split("#");
                let firstRequest = apiRequestsSequenceList[0];
                let sequenceRequestList = apiRequestsSequenceList[1] ? apiRequestsSequenceList[1].split('*') : [];
                console.log('firstRequest - ' + firstRequest);
                this.callMakeRequestController(firstRequest, sequenceRequestList, parsedJson);

            });
        }
    }

    callMakeRequestController(firstRequest, sequenceRequestList, parsedJson){
        
        makeRequest({
            apiRequestName: firstRequest,
            recordId: this.recordId,
            fieldsMap: parsedJson[firstRequest].fields,
            conditions: parsedJson[firstRequest].conditionList ? parsedJson[firstRequest].conditionList : null,
            certificateName: this.certificateName,
            runAsUserId: null,
            disableLog: this.disableLog
        }).then(data =>{
            if(sequenceRequestList){
                sequenceRequestList.forEach(apiRequestName => {
                    console.log('apiRequestName - ' + apiRequestName);
                    this.callMakeRequestController(apiRequestName, null, parsedJson);
                });
            }

            console.log('data: ' + data);

        }).catch(reqError =>{

            console.log('makeRequest.reqError: ' + JSON.stringify(reqError));
        }).finally(() =>{

            eval("$A.get('e.force:refreshView').fire();");
        });
    }
}