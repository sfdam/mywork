import { LightningElement } from 'lwc';
import arricchimentoActionBatch from '@salesforce/apex/TXT_CalloutHandler.arricchimentoActionBatch';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TxtArricchimentoAccountBatch extends LightningElement {

    handleClick() {
        this.launchBatchArricchimento();
    }
    
    async launchBatchArricchimento() {
        var success = true;
        var errorMessage = '';
        this.template.querySelector('.cstm-spinner').classList.toggle('slds-hide');
        try {
            let result = await arricchimentoActionBatch();
            success = result.success; 
            console.log('@@@ result ', result);
        } catch (err) {
            console.log('@@@ err ', err);
            success = false;
            errorMessage = err.body !== undefined ? err.body.message : '';
        }
        
        const event = new ShowToastEvent({
            title: success ? 'Successo!' : 'Errore!',
            message: success ? 'Job di arricchimento avviato correttamente' : 'Si è verificato un errore durante l\'avvio del job di arricchimento ' + errorMessage,
            variant: success ? 'success' : 'error'
        });
        this.dispatchEvent(event);
        this.template.querySelector('.cstm-spinner').classList.toggle('slds-hide');
    }
}