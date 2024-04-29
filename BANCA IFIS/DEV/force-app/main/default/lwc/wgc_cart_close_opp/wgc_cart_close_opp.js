import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssCartPC from '@salesforce/resourceUrl/cssCartPC';

export default class Wgc_cart_close_opp extends LightningElement {
    @api
    recordId;

    @api
    recordTypeId;

    @api
    categoriaChiusura;

    connectedCallback(){
        loadStyle(this, cssCartPC);
    }

    renderedCallback(){

    }

    /* GETTER & SETTER */

    get btnDisabled(){
        return this.categoriaChiusura === undefined || this.categoriaChiusura === "";
    }

    /* GETTER & SETTER */

    /* EVENT HANDLER */

    changeCategoria(event){
        this.categoriaChiusura = event.target.value;
    }

    handleSuccessDelete(event){
        const closeModal = new CustomEvent('closesubmodal', { detail: { reload: true }});
        this.dispatchEvent(closeModal);
        // window.open(location, '_self', '');
    }

    /* EVENT HANDLER */
}