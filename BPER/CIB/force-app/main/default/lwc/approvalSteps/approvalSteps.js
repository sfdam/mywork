import { LightningElement, api, track } from 'lwc';

import getAllData from '@salesforce/apex/ApprovalStepsController.getAllData';

import Step from '@salesforce/label/c.approvalSteps_CLM_Step';
import Approvatore from '@salesforce/label/c.approvalSteps_CLM_Approvatore';
import Commenti from '@salesforce/label/c.approvalSteps_CLM_Commenti';
import Status from '@salesforce/label/c.approvalSteps_CLM_Status';
/**
 * Columns definition
 * :: used in examples
 */
const columns = [
    {
        label: Step,
        fieldName: 'Step',
        type: 'text'
    },
    {
        label: Approvatore,
        fieldName: 'Actor',
        type: 'text'
    },
    {
        label: Commenti,
        fieldName: 'Comments',
        type: 'text'
    },
    {
        label: Status,
        fieldName: 'Status',
        type: 'text'
    }
];
export default class ApprovalSteps extends LightningElement {

    @api recordId;
    @api title;
    @api iconName;

    @track loaded = false;
    @track rows;
    @track notEmptyList;

    // definition of columns for the tree grid
    columns = columns;

    connectedCallback() {

        getAllData({recordId : this.recordId})
        .then(result => {

            console.log('DK getAllData result', result);

            if(result.length > 0){

                this.rows = result;
                this.notEmptyList = true;
            }else{

                this.notEmptyList = false;
            }

            this.loaded = true;
        })
        .catch(error => {
            console.log('DK ERROR', JSON.stringify(error));
            this.loaded = true;
        });
    }

}