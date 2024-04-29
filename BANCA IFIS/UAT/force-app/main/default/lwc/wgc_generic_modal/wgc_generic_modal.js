import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssCartPC from '@salesforce/resourceUrl/cssCartPC';
 
export default class Wgc_generic_modal extends LightningElement {
    @api
    recordId;
    @api
    recordTypeId;
    @api
    cmpName;
    @api
    modalTitle;
    @api
    showCloseBtn = false;

    //Additional Parameter
    @track
    privateParams;

    constructor(){
        super();
        this.template.addEventListener('closesubmodal', this.handleDialogClose.bind(this));
    }

    connectedCallback(){
        loadStyle(this, cssCartPC);
    }

    renderedCallback(){
    }

    get ModalClass(){
        return this.cmpName == 'c-wgc_pc_cart_modal_irr' ? 'cstm-modal-large' : 'slds-modal__container';
    }

    @api
    get params(){
        return this.privateParams;
    }

    set params(p){
        console.log('@@@ params modal ' , p);
        this.privateParams = p;
    }

    get closeOpp(){
        return this.cmpName == 'c-wgc_cart_close_opp';
    }

    get changeOwner(){
        return this.cmpName == 'c-wgc_cart_change_owner';
    }

    get ricalcolaIrr(){
        return this.cmpName == 'c-wgc_pc_cart_modal_irr';
    }

    get ricalcolaDSO(){
        return this.cmpName == 'c-wgc_pc_cart_modal_dso';
    }

    get invioTime(){
        return this.cmpName == 'c-wgc_pc_cart_modal_invio_time';
    }

    /* Close Modal */

    handleDialogClose(event){
        let reloadP = event.detail != undefined ? event.detail.reload : false;
        const closemodal = new CustomEvent('modal', { bubbles: true, composed: true, detail : { open: false, reload: reloadP } });
        this.dispatchEvent(closemodal);
    }

    /* Close Modal */
}