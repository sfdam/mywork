import { LightningElement , api, track } from 'lwc';

import assignRecords from '@salesforce/apex/priceBookSelectorController.assignRecords';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation' ;

export default class LookupDemo extends NavigationMixin(LightningElement) {
  // handel custom lookup component event 
    selectedRecord = {};
    validated = false;
    @api recordId;
    /*@api
    get cases(){
        return this.cases;
    }*/
    
    lookupRecord(event){
        //alert('Selected Record Value on Parent Component is ' +  JSON.stringify(event.detail.selectedRecord) + 'casi selezionati: ' + this.cases);
        this.selectedRecord = event.detail.selectedRecord;
    }

    handleSubmit(evt){
        this.handleValidate();
        if(this.validated){
            console.log("VALIDATO" + this.validated);
            assignRecords({ recordId:  this.recordId, pricebookId: this.selectedRecord.Id })
            .then((result) => {
                console.log("SUCCESS" + this.selectedRecord);
                //this.handleRecordNavigation(this.selectedRecord.Id);
                this.showToast('Success!', 'Pricebook updated successfully.', 'success');
                getRecordNotifyChange([{recordId: this.recordId}]);
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch((error) => {
                console.log("ERROR");
                this.showToast('Error!', 'Something went wrong', 'error');
            })
        }
        else{
            console.log("NON VALIDATO" + this.validated);
            this.dispatchEvent(new CustomEvent(
                    'areaVuota', 
                    {
                        detail: { recordId:  this.selectedRecord.Id},
                        bubbles: true,
                        composed: true,
                    }
                ));
        }
        
    }
    /*handleRecordNavigation(caseId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseId,
                objectApiName: 'Case',
                actionName: 'view'
            },
        });
    }*/

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    handleValidate() {
        if(this.selectedRecord != undefined &&  this.selectedRecord != null ){
            this.validated = true;
        }
        console.log("VALIDATO?" + this.validated);
    }

}