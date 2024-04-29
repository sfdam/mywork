import { LightningElement, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssCartPC from '@salesforce/resourceUrl/cssCartPC';

export default class Wgc_pc_cart_products_container extends LightningElement {

    @api
    products;

    @api
    title = 'prodotti selezionati';

    connectedCallback(){
        loadStyle(this, cssCartPC);
    }

    renderedCallback(){
        console.log('@@@ products ' , this.products);
    }
    
}