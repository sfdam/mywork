import { LightningElement, api } from 'lwc';
import createGroup from "@salesforce/apex/cartVisualizerController.createGroup";
export default class CartVisualizer extends LightningElement {

    baseURL;
    JSONCart;
    @api recordId;

    connectedCallback(){
		//super.connectedCallback();
        console.log('DENTRO component loaded' + this.baseURL + 'document.URL ' + document.URL);
		//this.JSONCart = JSON.stringify(cart);
	}

    refreshPage(){
        eval("$A.get('e.force:refreshView').fire();");
    }

    async createGroup(){
        await createGroup({ recordId: this.recordId });
    }
}