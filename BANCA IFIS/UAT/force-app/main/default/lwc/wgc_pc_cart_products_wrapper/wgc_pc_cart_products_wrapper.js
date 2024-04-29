import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssCartPC from '@salesforce/resourceUrl/cssCartPC';
import updateField from '@salesforce/apex/WizardOpportunityController.updateField';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 
export default class Wgc_pc_cart_products_wrapper extends LightningElement {
    @api
    recordId;

    @api
    readOnly;
    
    @track
    allProducts = [];

    @track
    selectedProducts = [];

    connectedCallback(){
        loadStyle(this, cssCartPC);
    }

    renderedCallback(){
    }

    /* GETTER & SETTER */

    get isProdSelected(){
        return this.selectedProducts.length > 0 && !this.readOnly;
    }

    get next(){
        console.log('@@@ this.readOnly ' , this.readOnly);
        return this.readOnly;
    }

    @api
    get products(){
        return this.allProducts;
    }

    set products(value){
        this.allProducts = value;
    }

    @api
    get selProducts(){
        return this.selectedProducts;
    }

    set selProducts(value){
        this.selectedProducts = value;
    }

    /* EVENT HANDLERS */

    confirmProduct(event){
        var prdSelezionati = '';
        this.selectedProducts.forEach((p, ind) => {
            prdSelezionati += p.name;
            if(ind != this.selectedProducts.length - 1) prdSelezionati += ';';
        });

        console.log('@@@ prd ' , this.prdSelezionati);
        console.log('@@@ selected ' , this.selectedProducts);
        if(this.selectedProducts.length == 1){
            const prdConf = new CustomEvent('cart_pc_call_server', { bubbles: true, composed:true, 
                detail : { params: { field: 'WGC_Prodotti_Selezionati__c', value: prdSelezionati, objectId: this.recordId  }, method: updateField, methodName: 'salvaProdotti' } });
            this.dispatchEvent(prdConf);
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore',
                    message: 'Non è possibile vendere due prodotti nella stessa pratica',
                    variant: 'error'
                })
            )
        }
    }

    goNextStep(event){
        this.dispatchEvent(new CustomEvent('stepwizard', { bubbles: true, composed: true, detail: { step: 'inserimentoCed' } } ));
    }

    /* EVENT HANDLERS */

}