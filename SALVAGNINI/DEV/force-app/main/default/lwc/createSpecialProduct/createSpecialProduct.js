import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getPricebookId from "@salesforce/apex/CreateSpecialProductController.getPricebookId";
import insertAdditionalLines from "@salesforce/apex/CreateSpecialProductController.insertAdditionalLines";
import PRODUCT2_OBJECT from '@salesforce/schema/Product2';

export default class CreateSpecialProduct extends NavigationMixin(LightningElement){
    
    @api recordId;


    @wire(getPricebookId,{recordId: '$recordId'})
    pricebookId;

    @wire(getObjectInfo, { objectApiName: PRODUCT2_OBJECT })
    objectInfo;

    get recordTypeId() {
        if(this.objectInfo.data) {
            return Object.keys(this.objectInfo.data.recordTypeInfos).find(rti => this.objectInfo.data.recordTypeInfos[rti].name === 'Special Item');
        } else {
            return {}; 
        }
    }


    handleSuccess(event) {
        console.log('productId: '+event.detail.id);
        console.log('pricebookId: '+this.pricebookId.data);
        console.log('quoteId: '+this.recordId);
        insertAdditionalLines({productId : event.detail.id, pricebookId : this.pricebookId.data, quoteId : this.recordId})
        .then((response) => {
            if(response == "OK"){
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: event.detail.id,
                        actionName: 'view',
                    },
                }).then((url) => {
                    const evt = new ShowToastEvent({
                        title: 'Product created!',
                        message: 'Record {0} created! See it {1}!',
                        messageData: [
                            'Salesforce',
                            {
                                url,
                                label: 'here',
                            },
                        ],
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    this.closeQuickAction();                
                });
            }
        });        
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}