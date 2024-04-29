import { LightningElement, api, track, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import checkMW from '@salesforce/apex/EliminaPortafoglioController.checkMW';
import eliminaMW from '@salesforce/apex/EliminaPortafoglioController.eliminaMW';
import { NavigationMixin } from 'lightning/navigation';

export default class EliminaPortafoglio extends NavigationMixin(LightningElement) {

    @track openmodal = false;
    @track error;
    @api recordId;
    @api title;

    openModal() {
        checkMW({ recordId: this.recordId }).then(() => {
            this.openmodal = true;
            
        })
        .catch(error => {
            this.error = error;
            console.log('EDB ERROR', error);
            const x = new ShowToastEvent({
                "title": "Errore!",
                "variant": "error",
                "message": this.error.body.message
            });
            this.dispatchEvent(x);
            this.openmodal = false;
        })
        .finally(() => {
            console.log('EDB FINALLY');
        }); 
    }

    closeModal() {
        this.openmodal = false;
    }

    elimina() {
        eliminaMW({ recordId: this.recordId }).then(() => {
            this.openmodal = false;
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Wallet__c', 
                    actionName: 'home'
                }
                
            });

            const x = new ShowToastEvent({
                "title": "Successo!",
                "variant": "success",
                "message": "Microportafoglio eliminato con successo"
            });
            this.dispatchEvent(x);
        })
        .catch(error => {
            this.error = error;
            console.log('EDB ERROR', error);
            const x = new ShowToastEvent({
                "title": "Errore!",
                "variant": "error",
                "message": this.error.body.message
            });
            this.dispatchEvent(x);
            this.openmodal = false;
        })
        .finally(() => {
            console.log('EDB FINALLY');
        });
    }


}