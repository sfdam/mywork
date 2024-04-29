import { LightningElement, api} from 'lwc';

import handleActionForManager from '@salesforce/apex/ApproverHandler.handleActionForManager'
import getSobjectId from '@salesforce/apex/ApproverHandler.getSobjectId'
export default class ManageApprovalRequest extends LightningElement {

    @api recordId;
    sobjectId;

    connectedCallback(){

        getSobjectId({processId: this.recordId})
        .then(result => {

            this.sobjectId = result;
        }).catch(error => {

            console.log('DK error: ' + error);
        });
    }

    handleApprove(){

        handleActionForManager({sObjectId: this.sobjectId, action: 'Approve', commentFromApprover: 'Approved By Manager'}).
        then(function(){

            alert('REQUEST APPROVED');
        }).catch(error => {

            console.log('DK error: ' + JSON.stringify(error));
        });
    }

    handleReject(){

        handleActionForManager({sObjectId: this.sobjectId, action: 'Reject', commentFromApprover: 'Rejected By Manager'}).
        then(function(){

            alert('REQUEST Rejected');
        }).catch(error => {

            console.log('DK error: ' + JSON.stringify(error));
        });
    }
}