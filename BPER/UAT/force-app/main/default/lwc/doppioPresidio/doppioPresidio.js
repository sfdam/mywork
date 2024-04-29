import { LightningElement, api, track, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import createDoppioPresidio from '@salesforce/apex/CreateDoppioPresidioController.createDoppioPresidio';
import getContactRole from '@salesforce/apex/CreateDoppioPresidioController.getContactRole';
import { NavigationMixin } from 'lightning/navigation';

export default class DoppioPresidio extends NavigationMixin(LightningElement) {
    @api recordId;
    @track error;
    @track showButton;
    
    connectedCallback(){
        getContactRole().then(result=>{
            if (result==false){
                this.showButton=false;
            }
            else{
                this.showButton=true;
            }
        });
    }
    invoke() {
        createDoppioPresidio({ recId: this.recordId }).then(result => {
            console.log('EDB createDoppioPresidio', result);
            const x = new ShowToastEvent({
                "title": "Successo!",
                "variant": "success",
                "message": "Doppo Presidio creato con successo"
            });
            this.dispatchEvent(x);
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Account', // objectApiName is optional
                    actionName: 'view'
                }
            });
        }).catch(error=>{
            this.error = error;
            console.log('EDB ERROR', error);
            const x = new ShowToastEvent({
                "title": "Errore!",
                "variant": "error",
                "message": this.error.body.message
            });
            this.dispatchEvent(x);
        });
    }
}