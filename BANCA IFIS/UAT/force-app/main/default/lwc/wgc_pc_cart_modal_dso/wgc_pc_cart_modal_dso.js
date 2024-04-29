import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssCartPC from '@salesforce/resourceUrl/cssCartPC';
import calcolaDIP from '@salesforce/apex/WGC_PC_CartController.callCalcolaDIP';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Wgc_pc_cart_modal_dso extends LightningElement {
    @api recordId;
    @api recordTypeId;

    @track privateCreditoId;

    @track
    rendered = false;

    @track
    dip;

    connectedCallback(){
        loadStyle(this, cssCartPC);
    }

    renderedCallback(){

    }

    /* GETTER & SETTER */

    @api
    get creditoId(){
        return this.privateCreditoId;
    }

    set creditoId(id){
        console.log('@@@ id ' , id);
        this.privateCreditoId = id;
        this.initialize();
    }

    /* GETTER & SETTER */

    /* FUNCTIONS */

    initialize(){
        calcolaDIP({ creditoId: this.creditoId })
            .then(r => {
                console.log('@@@ result dip ' , r);
                if(r.success){
                    this.dip = JSON.parse(r.data[0]).payload;
                    this.rendered = true;
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'ERRORE',
                            message: r.message,
                            variant: 'error'
                        })
                    )
                    this.confirm();
                }
            })
            .catch(err => {
                console.log('@@@ err service ' , err);
            });
    }

    /* FUNCTIONS */

    /* EVENT HANDLER */

    confirm(event){
        const closeModal = new CustomEvent('closesubmodal', { detail: { reload: false }} );
        this.dispatchEvent(closeModal);
    }

    /* EVENT HANDLER */
}