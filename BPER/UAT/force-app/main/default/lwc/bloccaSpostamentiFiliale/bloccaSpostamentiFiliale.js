import { LightningElement, api, track } from 'lwc';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getRecord from '@salesforce/apex/BloccaSpostamentiFilialeController.getRecord';
import updateRecord from '@salesforce/apex/BloccaSpostamentiFilialeController.updateRecord';
export default class BloccaSpostamentiFiliale extends LightningElement {

    @api recordId;
    @track bloccaSpostamentiInFiliale;
    @track bloccaSpostamentiVersoFiliale;
    @track bloccaSpostamentiFiliale;

    @track loaded = false;
    connectedCallback(){

        getRecord({accountId: this.recordId})
        .then(result =>{

            console.log('DK result: ', result);
            this.bloccaSpostamentiInFiliale = result.PTF_BloccaSpostamentiInFiliale__c;
            this.bloccaSpostamentiVersoFiliale = result.PTF_BloccaSpostamentiVersoFiliale__c;
            this.bloccaSpostamentiFiliale = result.PTF_BloccaSpostamentiFiliale__c;
        })
        .catch(error =>{

            console.warn(error);
        })
        .finally(() =>{
            this.loaded = true;
        })
    }

    changeToggle(event) {
        try {
            
            console.log('event.target: ',event);
            console.log('event.target.checked: ',event.target.checked);
            console.log('event.target.label: ',event.target.label);
            console.log('event.target.name: ',event.target.name);
            let targetName = event.target.name;
            let targetChecked = event.target.checked;
            updateRecord({accountId: this.recordId, value: targetChecked, field: targetName})
            .then(() =>{
                
                try {
                    
                    const element = this.template.querySelector('[data-id="' + targetName + '"]');
                    element.setAttribute('checked', targetChecked);
                } catch (error) {
                    console.warn(error);
                }
            })
            .catch(error =>{
                console.warn(error);
                const toastEvent = new ShowToastEvent({
                    title: "Error!",
                    message: 'Errore durante il salvataggio, contatta il tuo amministratore.',
                    variant: "error"
                });
                this.dispatchEvent(toastEvent);
            })
            .finally(() =>{
            })
        } catch (error) {
            console.log('error: ' , error);
        }

    }
}