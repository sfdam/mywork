import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssCartPC from '@salesforce/resourceUrl/cssCartPC';
import changeOwner from '@salesforce/apex/WizardOpportunityController.updateField';
 
export default class Wgc_cart_change_owner extends LightningElement {
    @api
    recordId;
    @api
    recordTypeId;

    recordSelected;

    connectedCallback(){
        loadStyle(this, cssCartPC);
    }

    renderedCallback(){

    }

    changeVal(event){
        this.recordSelected = event.target.value;
    }

    confirm(event){
        const changeOwnerEvt = new CustomEvent('cart_pc_call_server', { bubbles: true, composed:true, 
            detail : { params: { field: 'OwnerId', value: this.recordSelected, objectId: this.recordId  }, method: changeOwner/*, methodName: 'reloadWindow'*/ } });
        this.dispatchEvent(changeOwnerEvt);

        const closeModal = new CustomEvent('closesubmodal');
        this.dispatchEvent(closeModal);

        window.open(location, '_self', '');
    }
}