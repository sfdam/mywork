import { LightningElement, track, api } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import Email_FIELD from '@salesforce/schema/Contact.Email';
import getContacts from '@salesforce/apex/ContactController.getContacts';
const COLUMNS = [

    {label: 'Account', fieldName: 'accountLink', type: 'url'},
    {label: 'First Name', fieldName: FIRSTNAME_FIELD.fieldApiName, type: 'text'},
    {label: 'Last Name', fieldName: LASTNAME_FIELD.fieldApiName, type: 'text'},
    {label: 'Email', fieldName: Email_FIELD.fieldApiName, type: 'text'}
];
export default class ContactList extends LightningElement {
    
    columns = COLUMNS;
    @track contacts = [];
    @track bears;
	@track ranger;
	@track left;
	@track top;
    
    showData(event){
		this.ranger = event.currentTarget.dataset.rangerid;
		this.left = event.clientX;
		this.top=event.clientY;
	}
	hideData(event){
		this.ranger = "";
	}

    connectedCallback(){
        
        getContacts().then(data => {
            
            this.contacts = data.map(element => JSON.parse(JSON.stringify(element)));
            this.contacts.forEach(element => element.accountLink = '/' + element.AccountId);
            
        }).catch(error => {
            
            console.log('getAccounts.error: ' + error);
        });

    }

    renderedCallback(){

        this.template.querySelectorAll('table tr').forEach(tr => {
            console.log('FOREACH');
            tr.onmouseover(function( event ){
                showData(event)
            });
            tr.onmouseout(function( event ){
                console.log('onmouseout');
                hideData(event);
            });
        });
        console.log('trList: ' + this.template.querySelectorAll('tr').length);
    }
}