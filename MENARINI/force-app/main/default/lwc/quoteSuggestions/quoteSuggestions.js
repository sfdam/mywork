import {LightningElement, wire, api} from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {getRecord} from 'lightning/uiRecordApi';
import QUOTE_NAME_FIELD from '@salesforce/schema/Quote.Name';
import getQuoteLineItems from '@salesforce/apex/QuoteSuggestionsController.getQuoteLineItems';

/* LAILA */
const LAILA_80MG_14CPS = "51J01A";
const LAILA_80MG_28CPS = "51J01B";

/* SUSTENIUM */
const SUST_PLUS_INT_FORM_12_BUSTE = "51328C";
const SUST_PLUS_INT_FORM_22_BUSTE_PROMO = "51328A";
const SUST_PLUS_INT_FORM_22_BUSTE_TROPICAL = "513203";

/* ENANTYUM */
const ENANTYUM_25MG_10_CPR = "51233B";
const ENANTYUM_BEVIBILE_25MG_10BST = "51BFBA";
const ENANTYUM_25MG_20_CPR = "51233A";

export default class QuoteSuggestions extends LightningElement {
    positiveSuggestion = "Si è raggiunta la minima quantità per applicare lo sconto previsto dalla campagna.";
    negativeSuggestion = "Non si è raggiunta la minima quantità per applicare lo sconto previsto dalla campagna.";
    loading = false;
    quoteLineItems = [];
    suggestions = [];
    @api recordId;
    @wire(getRecord, {recordId: '$recordId', fields: [QUOTE_NAME_FIELD]}) quote;

    get quoteName() {
        return this.quote?.data?.fields?.Name?.value;
    }

    async handleQuoteSuggestions(event) {
        try {
            console.log("QUOTE SUGGESTIONS");
            const suggestions = [];
            this.loading = true;
            this.template.querySelector('.quote-suggestions-modal').openModal();
            this.quoteLineItems = await getQuoteLineItems({quoteId: this.recordId});

            /* LAILA */
            const LAILA_80MG_14CPS_Items = this.quoteLineItems.filter(item => item.Product2.ProductCode === LAILA_80MG_14CPS);
            const LAILA_80MG_14CPS_Quantity = LAILA_80MG_14CPS_Items.reduce((accumulator, currentValue) => {accumulator += currentValue.Quantity; return accumulator;}, 0);

            const LAILA_80MG_28CPS_Items = this.quoteLineItems.filter(item => item.Product2.ProductCode === LAILA_80MG_28CPS);
            const LAILA_80MG_28CPS_Quantity = LAILA_80MG_28CPS_Items.reduce((accumulator, currentValue) => {accumulator += currentValue.Quantity; return accumulator;}, 0);

            if(
                (LAILA_80MG_14CPS_Quantity + LAILA_80MG_28CPS_Quantity >= 6) &&
                (LAILA_80MG_14CPS_Items.some(item => item.Discount !== 15) || LAILA_80MG_28CPS_Items.some(item => item.Discount !== 15))
            ) {
                suggestions.push(`LAILA: ${this.negativeSuggestion}`);
            }
            else if(
                (LAILA_80MG_14CPS_Quantity + LAILA_80MG_28CPS_Quantity >= 6) &&
                !(LAILA_80MG_14CPS_Items.some(item => item.Discount !== 15) || LAILA_80MG_28CPS_Items.some(item => item.Discount !== 15))
            ) {
                suggestions.push(`LAILA: ${this.positiveSuggestion}`);
            }

            /* SUSTENIUM */
            const SUST_PLUS_INT_FORM_12_BUSTE_Items = this.quoteLineItems.filter(item => item.Product2.ProductCode === SUST_PLUS_INT_FORM_12_BUSTE);
            const SUST_PLUS_INT_FORM_12_BUSTE_Quantity = SUST_PLUS_INT_FORM_12_BUSTE_Items.reduce((accumulator, currentValue) => {accumulator += currentValue.Quantity; return accumulator;}, 0);

            const SUST_PLUS_INT_FORM_22_BUSTE_PROMO_Items = this.quoteLineItems.filter(item => item.Product2.ProductCode === SUST_PLUS_INT_FORM_22_BUSTE_PROMO);
            const SUST_PLUS_INT_FORM_22_BUSTE_PROMO_Quantity = SUST_PLUS_INT_FORM_22_BUSTE_PROMO_Items.reduce((accumulator, currentValue) => {accumulator += currentValue.Quantity; return accumulator;}, 0);

            const SUST_PLUS_INT_FORM_22_BUSTE_TROPICAL_Items = this.quoteLineItems.filter(item => item.Product2.ProductCode === SUST_PLUS_INT_FORM_22_BUSTE_TROPICAL);
            const SUST_PLUS_INT_FORM_22_BUSTE_TROPICAL_Quantity = SUST_PLUS_INT_FORM_22_BUSTE_TROPICAL_Items.reduce((accumulator, currentValue) => {accumulator += currentValue.Quantity; return accumulator;}, 0);

            if(
                (SUST_PLUS_INT_FORM_12_BUSTE_Quantity + SUST_PLUS_INT_FORM_22_BUSTE_PROMO_Quantity + SUST_PLUS_INT_FORM_22_BUSTE_TROPICAL_Quantity >= 12) &&
                (SUST_PLUS_INT_FORM_12_BUSTE_Items.some(item => item.Discount !== 29) || SUST_PLUS_INT_FORM_22_BUSTE_PROMO_Items.some(item => item.Discount !== 29) || SUST_PLUS_INT_FORM_22_BUSTE_TROPICAL_Items.some(item => item.Discount !== 29))
            ) {
                suggestions.push(`SUSTENIUM: ${this.negativeSuggestion}`);
            }
            else if(
                (SUST_PLUS_INT_FORM_12_BUSTE_Quantity + SUST_PLUS_INT_FORM_22_BUSTE_PROMO_Quantity + SUST_PLUS_INT_FORM_22_BUSTE_TROPICAL_Quantity >= 12) &&
                !(SUST_PLUS_INT_FORM_12_BUSTE_Items.some(item => item.Discount !== 29) || SUST_PLUS_INT_FORM_22_BUSTE_PROMO_Items.some(item => item.Discount !== 29) || SUST_PLUS_INT_FORM_22_BUSTE_TROPICAL_Items.some(item => item.Discount !== 29))
            ) {
                suggestions.push(`SUSTENIUM: ${this.positiveSuggestion}`);
            }

            /* ENANTYUM */
            const ENANTYUM_25MG_10_CPR_Items = this.quoteLineItems.filter(item => item.Product2.ProductCode === ENANTYUM_25MG_10_CPR);
            const ENANTYUM_25MG_10_CPR_Quantity = ENANTYUM_25MG_10_CPR_Items.reduce((accumulator, currentValue) => {accumulator += currentValue.Quantity; return accumulator;}, 0);

            const ENANTYUM_BEVIBILE_25MG_10BST_Items = this.quoteLineItems.filter(item => item.Product2.ProductCode === ENANTYUM_BEVIBILE_25MG_10BST);
            const ENANTYUM_BEVIBILE_25MG_10BST_Quantity = ENANTYUM_BEVIBILE_25MG_10BST_Items.reduce((accumulator, currentValue) => {accumulator += currentValue.Quantity; return accumulator;}, 0);

            const ENANTYUM_25MG_20_CPR_Items = this.quoteLineItems.filter(item => item.Product2.ProductCode === ENANTYUM_25MG_20_CPR);
            const ENANTYUM_25MG_20_CPR_Quantity = ENANTYUM_25MG_20_CPR_Items.reduce((accumulator, currentValue) => {accumulator += currentValue.Quantity; return accumulator;}, 0);

            if(
                (ENANTYUM_25MG_10_CPR_Quantity >= 12) &&
                (ENANTYUM_BEVIBILE_25MG_10BST_Quantity === 0) &&
                (ENANTYUM_25MG_20_CPR_Quantity === 0) &&
                ENANTYUM_25MG_10_CPR_Items.some(item => item.Discount !== 25)
            ) {
                suggestions.push(`ENANTYUM: ${this.negativeSuggestion}`);
            }
            else if(
                (ENANTYUM_25MG_10_CPR_Quantity >= 12) &&
                (ENANTYUM_BEVIBILE_25MG_10BST_Quantity === 0) &&
                (ENANTYUM_25MG_20_CPR_Quantity === 0) &&
                !ENANTYUM_25MG_10_CPR_Items.some(item => item.Discount !== 25)
            ) {
                suggestions.push(`ENANTYUM: ${this.positiveSuggestion}`);
            }


            if(
                (ENANTYUM_25MG_10_CPR_Quantity + ENANTYUM_BEVIBILE_25MG_10BST_Quantity + ENANTYUM_25MG_20_CPR_Quantity >= 12) &&
                (ENANTYUM_BEVIBILE_25MG_10BST_Quantity > 0 || ENANTYUM_25MG_20_CPR_Quantity > 0) &&
                (ENANTYUM_25MG_10_CPR_Items.some(item => item.Discount !== 20) || ENANTYUM_BEVIBILE_25MG_10BST_Items.some(item => item.Discount !== 20) || ENANTYUM_25MG_20_CPR_Items.some(item => item.Discount !== 20))
            ) {
                 suggestions.push(`ENANTYUM: ${this.negativeSuggestion}`);
            }
            else if(
                (ENANTYUM_25MG_10_CPR_Quantity + ENANTYUM_BEVIBILE_25MG_10BST_Quantity + ENANTYUM_25MG_20_CPR_Quantity >= 12) &&
                (ENANTYUM_BEVIBILE_25MG_10BST_Quantity > 0 || ENANTYUM_25MG_20_CPR_Quantity > 0) &&
                !(ENANTYUM_25MG_10_CPR_Items.some(item => item.Discount !== 20) || ENANTYUM_BEVIBILE_25MG_10BST_Items.some(item => item.Discount !== 20) || ENANTYUM_25MG_20_CPR_Items.some(item => item.Discount !== 20))
            ) {
                 suggestions.push(`ENANTYUM: ${this.positiveSuggestion}`);
            }

            this.suggestions = suggestions.map((suggestion, index) => {return {key: `s${index}`, value: suggestion};});
        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: 'error', title: 'Error', message: `An error occurred`}));
        }
        finally {
            this.loading = false;
        }
    }

    get showSuggestions() {
        return this.suggestions?.length > 0;
    }
}