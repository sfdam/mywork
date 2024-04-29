import { LightningElement, api } from 'lwc';
import arricchimentoAction from '@salesforce/apex/TXT_CalloutHandler.arricchimentoAction';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/*
* @author: SM
* @description: componente per richiamare il servizio di arricchimento anagrafica tramite pulsante custom
*
*/
export default class TxtArricchimentoAccount extends LightningElement {

    @api recordId;


    handleArricchimento(event) {
        this.calloutArricchimento();
    }
    
    async calloutArricchimento() {
        var success = true;
        var errorMessage = '';
        this.template.querySelector('.cstm-spinner').classList.toggle('slds-hide');
        try {
            let resultArricchimento = await arricchimentoAction({ accountId: this.recordId })
            console.log('@@@ resultArricchimento ', resultArricchimento);
        } catch (e) {
            console.log('@@@ error arricchimento ', e);
            success = false;
            errorMessage = e.body !== undefined ? e.body.message : '';
        }
        
        const event = new ShowToastEvent({
            title: success ? 'Successo!' : 'Errore!',
            message: success ? 'Account arricchito correttamente' : 'Si è verificato un errore durante l\'arricchimento dell\'account ' + errorMessage,
            variant: success ? 'success' : 'error'
        });
        this.dispatchEvent(event);
        this.template.querySelector('.cstm-spinner').classList.toggle('slds-hide');
    }
    
}