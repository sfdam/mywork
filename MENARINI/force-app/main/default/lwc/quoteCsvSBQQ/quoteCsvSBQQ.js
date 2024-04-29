import { LightningElement, wire, api } from 'lwc';
import getSbqqCsvQuoteLineItems from '@salesforce/apex/QuoteSuggestionsController.getSbqqCsvQuoteLineItems';
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class QuoteCsvSbqq extends LightningElement {
    @api recordId;
    csv = "";

    @wire(getSbqqCsvQuoteLineItems, {quoteId: '$recordId'}) wiredQuoteLineItems({error, data}) {
        if(data) {
            this.csv = data;
        } else if (error) {
            this.dispatchEvent(new ShowToastEvent({variant: 'error', title: 'Error', message: `An error occurred`}));
        }
    }

    handleCopySapCsvToClipboard(event) {
        const textarea = this.template.querySelector('lightning-textarea ');
        const element = document.createElement('textarea');
        element.value = textarea.value;
        element.textContent  = textarea.value;
        element.setAttribute('readonly', '');
        element.style.position = 'absolute';
        element.style.left = '-9999px';
        document.body.appendChild(element);
        element.select();
        element.setSelectionRange(0, 99999)
    	if(document.execCommand('copy')) {
            this.dispatchEvent(new ShowToastEvent({variant: 'success', title: 'Success!', message: `SAP CSV copied!`}));
        }
        else {
            this.dispatchEvent(new ShowToastEvent({variant: 'info', title: 'Sorry!', message: `SAP CSV can't be copied!`}));
        }
        document.body.removeChild(element);
    }
}