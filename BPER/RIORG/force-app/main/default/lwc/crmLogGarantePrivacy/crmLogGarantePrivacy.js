import { LightningElement, api, track, wire } from 'lwc';

import saveLog from '@salesforce/apex/CrmLogGarantePrivacyController.saveLog';

export default class CrmLogGarantePrivacy extends LightningElement {

    @api recordId;
    @api dati_accessori;
    @api object;

    connectedCallback() {
        saveLog({ objectType: this.object, recordId: this.recordId, dati_accessori: this.dati_accessori })
        .then(result => {
            console.log('SV saveLog result', result);

        })
        .catch(error => {
            this.error = error;
            console.log('ERROR', error);
        })
        .finally(() => {

        });
    }
}