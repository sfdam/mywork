import { LightningElement, track, api, wire } from 'lwc';
import makeRequest from '@salesforce/apex/SearchSmartAccountController.makeRequest';
import jsonWrapper from '@salesforce/resourceUrl/jsonWrapper';
//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import Error_Message_searchsmart from '@salesforce/label/c.Error_Message_searchsmart';


export default class SearchSmatAccountExtended extends LightningElement {

    @api recordId;
    @api apiRequests = 'ricercaSmartAccountEstesa';
    @api certificateName;
    @api disableLog;

    @track error = false;
    @track errorMessage = Error_Message_searchsmart;

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
                this.certificateName = 'salesforceprodclient2024';
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

            let response = JSON.parse(data);
            if(Boolean(response.error) && response.error != '' && !response.isEmpty){
                this.error = true;
                console.log('makeRequest.reqError: ', response);
                // const toastEvent = new ShowToastEvent({
                //     title: "Error!",
                //     message: Error_Message_searchsmart,
                //     variant: "error"
                // });
                // this.dispatchEvent(toastEvent);
            }else{

                console.log('response: ' , response);
                if(response.statusCode < 200 || response.statusCode >= 300 && !response.isEmpty){
                    this.error = true;
                    // const toastEvent = new ShowToastEvent({
                    //     title: "Error!",
                    //     message: Error_Message_searchsmart,
                    //     variant: "error"
                    // });
                    // this.dispatchEvent(toastEvent);
                }
            }

        }).catch(reqError =>{

            console.log('makeRequest.reqError: ' , reqError);
            this.error = true;
            // const toastEvent = new ShowToastEvent({
            //     title: "Error!",
            //     message: Error_Message_searchsmart,
            //     variant: "error"
            // });
            // this.dispatchEvent(toastEvent);
        }).finally(() =>{

            eval("$A.get('e.force:refreshView').fire();");
        });
    }
}