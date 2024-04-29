import { LightningElement,api,track } from 'lwc';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import setRollback from '@salesforce/apex/CRM_AffinamentoRollbackActionCtrl.setRollback';

export default class Crm_affinamentorollback extends LightningElement {


    @api recordId;
    @api defaultLimit;
    @track data = [];
    @track filteredData = [];
    @track columns = [];
    sortedBy;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    @track type1;
    @track type2;

    @track showFilter = false;
    @track loaded = false;

    @track typeMap = {};

    @track showRangeNum1 = false; 
    @track showRangeDate1 = false;
    @track showSearchtext1 = false;

    @track showRangeNum2 = false; 
    @track showRangeDate2 = false;
    @track showSearchtext2 = false;

    @track optionsAttributo1 = [];
    @track foundAttributo1 = [];
    @track optionsAttributo2 = [];
    @track foundAttributo2 = [];

    @track numMembers = 0;

    connectedCallback(){
        
        try {
            setRollback({recordIdCM:this.recordId})
            .then(result => {
                
                console.log('FS getData related to campaign member', this.recordId);
                
                
            })
            .catch(error => {
                // this.error = error;
                console.log('ERROR', error);
            })
            .finally(() => {
                console.log('FS Start Finaly');
                console.log('FS End Finaly');
            });
        } catch (error) {
            
            console.log('ERROR', error);
        }
    }
}