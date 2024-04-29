import { LightningElement, api, track } from 'lwc';
 
export default class Wgc_pc_cart_product extends LightningElement {

    @api
    prod;

    @api
    readOnly;

    @track
    productState = { remove: false, selected: false };

    connectedCallback(){

    }

    renderedCallback(){
        console.log('@@@ this ' , JSON.stringify(this.productState));
        // var stato = this.productState;
        // if((stato.index != 0 && !stato.selected && stato.remove) || (stato.index == 0 && !stato.selected && !stato.remove))
        //     stato.selected = true;
    }

    /* GETTER & SETTER */

    // get isRemovable(){
    //     console.log('@@@ prod ' , JSON.stringify(this.prod));
    //     return this.prod.removable;
    // }

    get classProd(){
        // return this.prod.selected ? 'cstm-product-wrapper active' : 'cstm-product-wrapper';
        return this.productState.selected ? 'cstm-product-wrapper active' : 'cstm-product-wrapper';
    }

    get variantClass(){
        // return this.prod.selected ? 'inverse' : '';
        return this.productState.selected ? 'inverse' : '';
    }

    get removeClass(){
        // return this.prod.selected ? 'cstm-remove-product white slds-text-align_right' : 'cstm-remove-product slds-text-align_right';
        return this.productState.selected ? 'cstm-remove-product white slds-text-align_right' : 'cstm-remove-product slds-text-align_right';
    }

    @api
    get remove(){
        return this.productState.remove && !this.readOnly;
    }

    set remove(value){
        this.productState.remove = value == true ? value : this.productState.remove;
    }

    @api
    get selected(){
        // return this.productState.selected && this.productState.index == 0 ? true : this.productState.selected ;
        return this.productState.selected;
    }

    set selected(value){
        // this.productState.selected = value == true ? value : this.productState.selected;
        this.productState.selected = value;
    }

    @api
    get index(){
        
    }

    set index(value){
        this.productState.index = value;
    }

    /* GETTER & SETTER */

    /* EVENT HANDLERS */

    clickProduct(event){
        event.preventDefault();
        if(!this.readOnly)
            this.dispatchEvent(new CustomEvent('selectproduct', { bubbles: true, composed: true, detail: this.prod } ));
    }

    removeProduct(event){
        event.preventDefault();
        this.dispatchEvent(new CustomEvent('removeproduct', { bubbles: true, composed: true, detail: this.prod } ));
    }
    /* EVENT HANDLERS */
}