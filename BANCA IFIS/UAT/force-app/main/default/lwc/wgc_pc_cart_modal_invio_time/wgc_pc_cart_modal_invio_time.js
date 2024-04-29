import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssCartPC from '@salesforce/resourceUrl/cssCartPC';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import censimentoTrattativa from '@salesforce/apex/WGC_PC_CartController.callCensimentoTrattativa';
import confermaTrattativa from '@salesforce/apex/WGC_PC_CartController.callConfermaTrattativa';
import saveCredito from '@salesforce/apex/WGC_PC_CartController.saveSingleCredito';
import updateField from '@salesforce/apex/WizardOpportunityController.updateField';
// import saveSingleCredito from '@salesforce/apex/WGC_PC_CartController.saveSingleCredito';

export default class Wgc_pc_cart_modal_invio_time extends LightningElement {

    @api recordId;

    @api creditoId;

    @api
    credito = {};

    @track rendered = false;

    connectedCallback(){
        loadStyle(this, cssCartPC);
        this.rendered = true;
    }

    renderedCallback(){
        console.log('@@@ credito init ' , this.credito);
    }

    /* EVENT HANDLERS */

    confirm(event){
        event.preventDefault();
        var credito = {...this.credito};
        credito.attributes = undefined;
        this.credito = credito;

        console.log('@@@ credito ' , JSON.stringify(this.credito));
        console.log('@@@ recordId ' , this.recordId);

        var esitoTIME03 = false;

        saveCredito({ credito : this.credito }).then(saveResult => {
            console.log('@@@ saveResult ' , saveResult);
            this.rendered = false;

            return censimentoTrattativa({ opportunityId: this.recordId, typeCall: 'post' })
        }).then(r => {
            console.log('@@@ result time02 ' , r);
            if(r.success){
                //this.recordId
                return confermaTrattativa({ creditoId: this.creditoId })
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ERRORE',
                        message: r.message,
                        variant: 'error'
                    })
                )
            }
        }).then(r => {
            console.log('@@@ result time03 ' , r);
            if(r.success){
                let res = JSON.parse(r.data[0]).payload.esito;
                console.log('@@@ time03' , res);

                // this.dispatchEvent(
                //     new ShowToastEvent({
                //         title: res == 'OK' ? 'SUCCESSO' : 'ERRORE',
                //         message: res,
                //         variant: res == 'OK' ? 'success' : 'error'
                //     })
                // )
                if(res == 'OK'){
                    esitoTIME03 = true;
                    updateField({ field: 'WGC_Credito_Confermato__c', value: true, objectId: this.creditoId })
                    return esitoTIME03;
                }
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ERRORE',
                        message: res,
                        variant: 'error'
                    })
                )
                return res;
            }
        }).then(res => {
            console.log('@@@ esito ', res);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: res == 'OK' || res == true ? 'SUCCESSO' : 'ERRORE',
                    message: res,
                    variant: res == 'OK' || res == true ? 'success' : 'error'
                })
            )

            this.dispatchEvent(
                new CustomEvent('updatecreditotime', { composed: true, bubbles: true, detail: { id: this.creditoId, esito: esitoTIME03 }})
            )
        }).finally(() => {
            this.rendered = true;
            const closeModal = new CustomEvent('closesubmodal');
            this.dispatchEvent(closeModal);

        }).catch(err => {
            console.log('@@@ error ' , err);
        })
        /*
        const closeModal = new CustomEvent('closesubmodal');
        this.dispatchEvent(closeModal);
        */
    }

    changeFieldVal(event){
        var credito = {...this.credito};
        credito[event.target.name] = event.target.value;
        this.credito = credito;
    }

    /* EVENT HANDLERS */
}