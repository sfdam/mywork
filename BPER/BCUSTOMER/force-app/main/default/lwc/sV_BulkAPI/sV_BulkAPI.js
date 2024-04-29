import { LightningElement, api, track } from 'lwc';

// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

// Import Controller Methods
import createJobQuery from '@salesforce/apex/SV_BulkAPI.createJobQuery';
import getJobQueryResult from '@salesforce/apex/SV_BulkAPI.getJobQueryResult';


export default class SV_BulkAPI extends NavigationMixin(LightningElement) {
    @track loaded = true;

    value = '';
    @api textValue = '';
    @api jobId = '';
    @api maxRecords = 300000;
    @api locator = '';
    @api disableButtonGetJobQueryResult = false;

    get options() {
        return [
            { label: 'Create job Query', value: 'CreateJobQuery' },
            { label: 'Get Job Info Query', value: 'GetJobInfoQuerygress' },
            { label: 'Abort a Job Query', value: 'AbortJobQuery' },
            { label: 'Get Job Query Result', value: 'GetJobQueryResult' },
            { label: 'CRUD Job', value: 'CreateCRUDJob' }
        ];
    }

    // connectedCallback() {
    //     this.loaded = true;
    // }

    handleChange(event) {
        this.value = event.detail.value;
    }

    get optionsCreateJobQuery(){
        return this.value === 'CreateJobQuery' ? true : false;
    }

    get optionsGetJobInfoQuerygress(){
        return this.value === 'GetJobInfoQuerygress' ? true : false;
    }

    get optionsAbortJobQuery(){
        return this.value === 'AbortJobQuery' ? true : false;
    }

    get optionsGetJobQueryResult(){
        return this.value === 'GetJobQueryResult' ? true : false;
    }

    get optionsCreateCRUDJob(){
        return this.value === 'CreateCRUDJob' ? true : false;
    }

    handleInputChange(event) {
        this.textValue = event.detail.value;
    }

    handleInputGetJobQueryResultJobIdChange(event) {
        this.jobId = event.detail.value;
    }

    handleInputGetJobQueryResultMaxRecordsChange(event) {
        this.maxRecords = event.detail.value;
    }

    handleClick(event) {
        this.loaded = false;
        console.log(this.textValue);
        createJobQuery({operation: 'query', query: this.textValue})
            .then(result => {
                console.log('SV getOrgInfo result', JSON.stringify(result));
                
            })
            .catch(error => {
                //alert('ERROR');
                console.log('SV ERROR', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Errore',
                        message: error,
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                console.log('SV FINALLY');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Successo',
                        message: 'Stiamo processando la tua richiesta riceverai presto notifica di completamento',
                        variant: 'success'
                    })
                );
                this.loaded = true;
            }); 
    }

    handleClickGetJobQueryResult(event) {
        this.loaded = false;

        console.log(this.jobId);
        console.log(this.locator);
        console.log(this.maxRecords);
        getJobQueryResult({jobId: this.jobId, locator: this.locator, maxRecords: this.maxRecords})
            .then(result => {
                console.log('SV getOrgInfo result', result);
                let csvString = result[0].responseBody;
                this.locator = result[0].responseHeaderSforceLocator == 'null' ? '' : result[0].responseHeaderSforceLocator;

                if(result[0].responseHeaderSforceLocator == 'null'){
                    this.disableButtonGetJobQueryResult = true;
                }
                // Creating anchor element to download
                let downloadElement = document.createElement('a');
        
                // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
                downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
                downloadElement.target = '_self';
                // CSV File Name
                downloadElement.download = 'JobQueryResult_'+result[0].responseHeaderSforceLocator+'_'+result[0].responseHeaderSforceNumberOfRecords+'.csv';
                // below statement is required if you are using firefox browser
                document.body.appendChild(downloadElement);
                // click() Javascript function to download CSV file
                downloadElement.click(); 
                        
            })
            .catch(error => {
                //alert('ERROR');
                console.log('SV ERROR', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Errore',
                        message: error,
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                console.log('SV FINALLY');
                this.loaded = true;
            }); 
    }


}