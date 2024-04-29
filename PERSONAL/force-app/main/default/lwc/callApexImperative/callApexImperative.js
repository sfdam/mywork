import { LightningElement, api, wire } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';
export default class CallApexImperative extends LightningElement {
    @api recordId;
    errors;
    
    @wire(getAccounts, { accountId: '$recordId' })
    wiredContacts({data, error}) {
        if (error)
            this.errors = reduceErrors(error);
    }
    
    handleButtonClick() {
        getAccounts({
            accountId: '$recordId'
        })
            .then(contacts => {
                // code to execute if the promise is resolved
            })
            .catch(error => {
                this.errors = reduceErrors(error); // code to execute if the promise is rejected
            });
    }
}