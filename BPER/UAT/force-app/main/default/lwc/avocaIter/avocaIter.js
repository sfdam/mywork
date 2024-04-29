import { LightningElement, api, track } from 'lwc';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

import init from '@salesforce/apex/AvocaIterController.init';
import closeIter from '@salesforce/apex/AvocaIterController.closeIter';

const picklistValues = [
    {
        label: 'Approvato',
        value: 'Approvato'
    },
    {
        label: 'Rifiutato',
        value: 'Rifiutato'
    }
];
export default class AvocaIter extends NavigationMixin(LightningElement) {

    @api recordId;
    @api labelBottone;
    @track nota = '';

    showButtons = false;
    showSecondStep = false;
    step;
    action;
    queueId;
    currentStep;
    storiaAvocazione;

    status = picklistValues;
    @track selectedStatus;
    @track disableAction = true;

    loading = true;

    isClose = false;
    connectedCallback(){

        init({recordId: this.recordId})
        .then(result =>{

            console.log('result', result);
            if(result){

                this.showButtons = true;
                this.action = result.action;
                this.isClose = result.action == 'close';
                this.queueId = result.queueId;
                this.currentStep = result.currentStep;
                this.storiaAvocazione = result.storiaAvocazione;
                if(result.step){

                    this.step = result.step;
                }
                this.loading = false;
            }
        })
        .catch(error =>{
            console.log('DK init.error: ' + JSON.stringify(error));
            console.log('DK init.error2: ' + error);
        });
    }

    handleAction(){

        this.showSecondStep = true;
        this.loading = false;
    }

    closeIter(){
        this.loading = true;
        closeIter({recordId: this.recordId, status: this.selectedStatus, nota: this.nota, action: this.action, queueId : this.queueId, step: Boolean(this.step) ? this.step : null, currentStep: Boolean(this.currentStep) ? this.currentStep : null, storiaAvocazione: this.storiaAvocazione})
        .then(result =>{

            let message = this.action == 'replace' ? 'Operazione conclusa con successo' : 'Iter chiuso Correttamente!!';
            const toastEvent = new ShowToastEvent({
                title: "Success!",
                message: message,
                variant: "success"
            });
            eval("$A.get('e.force:refreshView').fire();");
            this.dispatchEvent(toastEvent);
            setTimeout(window.location.reload.bind(window.location),2000);
        })
        .catch(error =>{
            this.loading = false;
            console.log('DK closeIter.error: ' + JSON.stringify(error));
            console.log('DK closeIter.error2: ' + error);
            const toastEvent = new ShowToastEvent({
                title: "Error!",
                message: error.body.message,
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

    onStatusChange(event){
        console.log('DK event.target.value: ' + event.target.value);
        this.selectedStatus = event.target.value;
        this.disableAction = false;
    }
}