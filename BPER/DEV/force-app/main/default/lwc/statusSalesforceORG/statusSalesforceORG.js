import { LightningElement, track, api }  from 'lwc';

// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

// Import Controller Methods
import getOrgInfo from '@salesforce/apex/StatusSalesforceORG.getOrgInfo';
import getOrgStatus from '@salesforce/apex/StatusSalesforceORG.getOrgStatus';

export default class StatusSalesforceORG extends NavigationMixin(LightningElement) {
    
    @track loaded = false;
    @track error;
    @track orgInfo;
    @track responseStatus;

    connectedCallback() {

        getOrgInfo()
            .then(result => {
                console.log('SV getOrgInfo result', result);
                
                this.orgInfo = result.InstanceName;
                
                return getOrgStatus({istanceName: result.InstanceName});
            })
            .then(result => {
                console.log('SV getOrgStatus result', result);
                
                this.responseStatus = result;
                
            })
            .catch(error => {
                //alert('ERROR');
                this.error = error;
                console.log('SV ERROR', error);
                this.isRendered = true;
            })
            .finally(() => {
                console.log('SV FINALLY');
                this.loaded = true;
            }); 

    }
}