import { LightningElement, api, track} from 'lwc';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

import init from '@salesforce/apex/AnnullaIterController.init';
import closeIter from '@salesforce/apex/AnnullaIterController.closeIter';

export default class AnnullaIter extends NavigationMixin(LightningElement) {

    @api recordId;
    @api labelBottone;
    @track nota = '';

    showButton = false;
    loading = false;
    connectedCallback(){

        init({recordId: this.recordId})
        .then(result =>{
            console.log('Dk result', result);
            if(result){

                this.showButton = true;
            }
        })
        .catch(error =>{
            console.log('DK init.error: ' + JSON.stringify(error));
            console.log('DK init.error2: ' + error);
        });
    }

    closeIter(){

        this.loading = true;
        closeIter({recordId: this.recordId, nota: this.nota})
        .then(result =>{

            const toastEvent = new ShowToastEvent({
                title: "Success!",
                message: 'Iter Annullato Correttamente',
                variant: "success"
            });
            this.loading = false;
            this.dispatchEvent(toastEvent);
            eval("$A.get('e.force:refreshView').fire();");
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    actionName: 'view'
                }
            });
        })
        .catch(error =>{
            console.log('DK closeIter.error: ' + JSON.stringify(error));
            console.log('DK closeIter.error2: ' + error);
            const toastEvent = new ShowToastEvent({
                title: "Error!",
                message: error.message,
                variant: "error"
            });
            this.dispatchEvent(toastEvent);
        });
    }

    handleFilter(event){

        console.log('DK handleFilter Started');
        if(event.target.name == 'nota'){
            this.nota = event.target.value;
        }
    }
}