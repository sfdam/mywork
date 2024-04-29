import { LightningElement, api, track } from 'lwc';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import init from '@salesforce/apex/SetDowngradeDateController.init';
import getContactInfo from '@salesforce/apex/SetDowngradeDateController.getContactInfo';
import saveRecord from '@salesforce/apex/SetDowngradeDateController.saveRecord';

export default class SetDowngradeDate extends LightningElement {

    @api recordId;
    @api title;
    @api iconName;
    @track record = {};
    @track showSave = false;

    @track loaded = false;
    @track utenteAutorizzato = false;
    today = new Date();

    connectedCallback(){

        getContactInfo()
        .then(result => {

            console.log('DK result', result);
            if(result.length > 0){

                if(result[0].PTF_User__r.Profilo__c == 'NEC_D.0'){
                    
                    console.log('DK sno QUA');
                    this.utenteAutorizzato = true;
                    init({recordId: this.recordId})
                    .then(result => {
            
                        this.record = result;
                        this.loaded = true;
                    })
                    .catch(error => {
            
                        this.loaded = true;
                        console.log('DK init.error: ' + JSON.stringify(error));
                        console.log('DK init.error2: ' + error);
                    });
                }
            }
        })
        .catch(error => {

            this.loaded = true;
            console.log('DK getContactInfo.error: ' + JSON.stringify(error));
            console.log('DK getContactInfo.error2: ' + error);
        });
    }

    handleSave(){

        try {
            this.loaded = false;
            const dateValid = [...this.template.querySelectorAll("[data-item='date']")]
                            .reduce((validSoFar, inputCmp) => {
                                        inputCmp.reportValidity();
                                        return validSoFar && inputCmp.checkValidity();
                            }, true);

            if(!dateValid){

                throw 'Valorizzare entrambe le date';
            }

            if(new Date(this.record.PTF_DowngradeReqEndDate__c) < this.today){
                
                throw 'Data Fine Finestra non può essere antecedente ad oggi';
            }

            if(new Date(this.record.PTF_DowngradeReqEndDate__c) < new Date(this.record.PTF_DowngradeReqStartDate__c)){
                
                throw 'Data Fine Finestra non può essere antecedente a Data Inizio Finestra';
            }
            saveRecord({account: this.record})
            .then(result => {
                this.loaded = true;
                const toastEvent = new ShowToastEvent({
                    title: "Success!",
                    message: "Date Finestra di downgrade aggiornate correttamente",
                    variant: "success"
                });
                this.dispatchEvent(toastEvent);
                this.showSave = false;
                eval("$A.get('e.force:refreshView').fire();");
            })
            .catch(error => {
                this.loaded = true;
                console.log('DK error: ' + JSON.stringify(error));
                console.log('DK error: ' + error);
                const toastEvent = new ShowToastEvent({
                    title: "Error!",
                    message: error.body.message,
                    variant: "error"
                });
                this.dispatchEvent(toastEvent);
            });
        } catch (error) {
            this.loaded = true;
            console.log('DK error: ' + error);
            const toastEvent = new ShowToastEvent({
                title: "Warning!",
                message: error,
                variant: "warning"
            });
            this.dispatchEvent(toastEvent);
        }
    }

    handleFilter(event){

        console.log('DK handleFilter Started');
        if(event.target.name == 'startDate'){
            
            this.record.PTF_DowngradeReqStartDate__c = event.target.value;
            this.showSave = true;
        }else if(event.target.name == 'endDate'){
            
            this.record.PTF_DowngradeReqEndDate__c = event.target.value;
            this.showSave = true;
        }
    }
}