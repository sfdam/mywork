import { LightningElement, api } from 'lwc';
import sendEmail from '@salesforce/apex/EmailUtils.sendEmail';
import {ShowToastEvent} from "lightning/platformShowToastEvent";

const GENERIC_ERROR_MESSAGE = "Si è verificato un errore";
const GENERIC_SUCCESS_MESSAGE = "Richiesta inviata con successo!";
const GENERIC_WARNING_MESSAGE = "Si è verificato un errore";
const WARNING_EMPTY_FIELD = "Verificare la corretta compilazione dei campi obbligatori";

export default class EmailForm extends LightningElement {

    loading = false;
    disableButtons = false;
    urlPrivacy = "/s/privacy-policy";

    async handleSubmit() {
        this.loading = true;
        this.disableButtons = true;

        const allValid = [
            this.template.querySelector("[data-field='firstname']").validity.valid,
            this.template.querySelector("[data-field='lastname']").validity.valid,
            this.template.querySelector("[data-field='phone']").validity.valid,
            this.template.querySelector("[data-field='subject']").validity.valid,
            this.template.querySelector("[data-field='body']").validity.valid,
            this.template.querySelector("[data-id='checkterms']").checked,
            this.template.querySelector("[data-field='email']").value != "",
            this.template.querySelector("[data-field='email']").validity.valid
        ];

        if(allValid.every(Boolean)) {

        try {
            const response = await sendEmail({

              firstName: this.template.querySelector("[data-field='firstname']").value,
              lastName: this.template.querySelector("[data-field='lastname']").value,
              phone: this.template.querySelector("[data-field='phone']").value,
              senderEmail: this.template.querySelector("[data-field='email']").value,
              vatNumber: this.template.querySelector("[data-field='vatnumber']").value,
              clientCode: this.template.querySelector("[data-field='clientcode']").value,
              subject: this.template.querySelector("[data-field='subject']").value,
              emailBody: this.template.querySelector("[data-field='body']").value

            });
            if(response === true) {
                this.dispatchEvent(new ShowToastEvent({variant: "success", title: "Richiesta inoltrata", message: GENERIC_SUCCESS_MESSAGE}));
            }
            else {
                this.dispatchEvent(new ShowToastEvent({variant: "warning", title: "Attenzione", message: GENERIC_WARNING_MESSAGE}));
            }
            console.log('*** sendEmail response: ', response + ' ***');
        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: "error", title: "Errore", message: GENERIC_ERROR_MESSAGE}));
        }
        finally {
            this.loading = false;
            this.disableButtons = false;
        }
        } else {
            this.dispatchEvent(new ShowToastEvent({variant: "warning", title: "Attenzione", message: WARNING_EMPTY_FIELD}));
            this.loading = false;
            this.disableButtons = false;
        }

    }

    handleReset() {
        this.template.querySelectorAll("[data-field]").forEach(element => {
            element.value = null;
        });
        this.template.querySelector("[data-id='checkterms']").checked = false;
    }


}