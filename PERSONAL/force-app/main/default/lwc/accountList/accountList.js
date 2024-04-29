import { LightningElement, track } from 'lwc';

import { reduceErrors } from 'c/ldsUtils';
import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';
const COLUMNS = [
    { label: 'First Name', fieldName: FIRSTNAME_FIELD.fieldApiName, type: 'text' },
    { label: 'Last Name', fieldName: LASTNAME_FIELD.fieldApiName, type: 'text' },
    { label: 'Email', fieldName: EMAIL_FIELD.fieldApiName, type: 'text' }
];
export default class AccountList extends LightningElement {
    columns = COLUMNS;
    @track accountList = [];
    @track accountContactsMap = {};
    @track contactsToShow = [];
    
    connectedCallback(){
        
        getAccounts().then(data => {
            
            this.accountList = data["accountList"].map(element => JSON.parse(JSON.stringify(element)));
            this.accountList.forEach(element => element.showPopup = false);
            this.accountContactsMap = data["accountContactsMap"];
        }).catch(error => {
            
            console.log('getAccounts.error: ' + error);
        });
    }

    handleOnClick(event){

        try {
            console.log(event.target.id);
            this.accountList.forEach(element => {

                if(element.showPopup = true){

                    element.showPopup = false;
                }
                if(event.target.id.includes(element.Id)){

                    element.showPopup = true;
                }
            });
            console.log('handleOnClick Start');
            console.log('event: ' + event);
        } catch (error) {
            
            console.log('error: ' + error);
        }
    }
}