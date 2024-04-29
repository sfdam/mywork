import { LightningElement, api, wire } from 'lwc';

import USER_ID from '@salesforce/user/Id';

import { publish,MessageContext } from 'lightning/messageService';
import prodListViewRefresh from "@salesforce/messageChannel/productListView__c";

export default class ProductListViewRefreshBtn extends LightningElement {

    @wire(MessageContext)
    messageContext;

    @api btnLabel = 'Refresh';
    @api recordTypeProductList;

    dispatchMC(event){
        const payload = { userId: USER_ID, recordTypeProductList: this.recordTypeProductList };
        publish(this.messageContext, prodListViewRefresh, payload);
    }
}