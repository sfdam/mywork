import { LightningElement, wire, track, api} from 'lwc';
// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import getAccountRelationshipList from '@salesforce/apex/ART_WholesalerController.getAccountRelationshipList';
import updateOrder from '@salesforce/apex/ART_WholesalerController.updateOrder';
import SAVE from '@salesforce/label/cgcloud.SAVE';
import WHOLESALER from '@salesforce/label/cgcloud.WHOLESALER';
import STREET from '@salesforce/label/cgcloud.STREET';
import POSTALCODE from '@salesforce/label/c.POSTALCODE';
import CITY from '@salesforce/label/cgcloud.CITY';
import STATE from '@salesforce/label/cgcloud.STATE';
import COUNTRY from '@salesforce/label/cgcloud.COUNTRY';
import ART_Error from '@salesforce/label/c.ART_Error';
import ART_Success from '@salesforce/label/c.ART_Success';
import ART_WholeSaler_UpdateOrderMsg from '@salesforce/label/c.ART_WholeSaler_UpdateOrderMsg';

export default class ArtWholesaler extends NavigationMixin(LightningElement) {

    isLoading = true;
    @track showButtons = false;
    buttonsVisibleFor = ["Initial","Rejected"];
    label = {
        SAVE,
        WHOLESALER,
        STREET,
        POSTALCODE,
        CITY,
        STATE,
        COUNTRY,
        ART_Error,
        ART_Success,
        ART_WholeSaler_UpdateOrderMsg
    }

    @track columns = [{
        label: this.label.WHOLESALER,
        fieldName: 'Name'
    },
    {
        label: this.label.STREET,
        fieldName: 'BillingStreet'
    },
    {
        label: this.label.POSTALCODE,
        fieldName: 'BillingPostalCode'
    },
    {
        label: this.label.CITY,
        fieldName: 'BillingCity'
    },
    {
        label: this.label.STATE,
        fieldName: 'BillingState'
    },
    {
        label: this.label.COUNTRY,
        fieldName: 'BillingCountry'
    }
];
@api recordId;
@track error;
@track accList;
@track preselectedRow = [];
@wire(getAccountRelationshipList, {orderId: '$recordId'})

wiredAccounts({error, data}) {
    if (data) {
        console.log(data);
        this.showButtons = this.buttonsVisibleFor.includes(data.phase);
        console.log('DK this.showButtons: ' , this.showButtons);
        this.accList = data.accList;
        this.preselectedRow.push(data.wholesaler);
    } else if (error) {
        console.error('error: ', JSON.parse(JSON.stringify(error)));
        this.error = error;
    }
    this.isLoading = false;
}

handleClickSave(){
    
    var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
    console.log(this.recordId + " " + JSON.stringify(selectedRecords) + " " + selectedRecords[0].Id);
    this.isLoading = true;
    if(selectedRecords.length > 0){
    
        updateOrder({   orderId: this.recordId,
                        accountId: selectedRecords[0].Id
        })
        .then(result => {
        console.log('result ===> '+result);
        // Show success messsage
        this.handleShowToastMsg(this.label.ART_Success,this.label.ART_WholeSaler_UpdateOrderMsg,'success');
        getRecordNotifyChange([{recordId: this.recordId}]);
        this.navigateToRecord(this.recordId);
        this.isLoading = false;
        })
        .catch(error => {
        this.error = error.message;
        this.handleShowToastMsg(this.label.ART_Error,error.message,'error');
        });
    }
}
handleShowToastMsg(titolo, messagio , variante){
    this.dispatchEvent(new ShowToastEvent({
        title: titolo,
        message: messagio,
        variant: variante
        }),
    );
}
navigateToRecord(recordId) {
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: recordId,
            actionName: 'view'
        }
    });
}
}