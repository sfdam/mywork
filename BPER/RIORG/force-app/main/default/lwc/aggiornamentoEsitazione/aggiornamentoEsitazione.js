import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPickListValues from '@salesforce/apex/AggiornamentoEsitazioneController.getPickListValues';
import getFieldLabel from '@salesforce/apex/AggiornamentoEsitazioneController.getFieldName';
import updateRecord from '@salesforce/apex/AggiornamentoEsitazioneController.updateRecord';



export default class AggiornamentoEsitazione extends LightningElement {
    @api label;
    @api stato;
    @api recordId;
    @api apiRequestName = 'salvaEsitazioneAzioniNec';
    @api jsonParam;
    @api certificationName;
    @api disableLog;
    @api openmodel = false;
    @api note;
    @api oggetto;
    @track options;
	@track selectedOption;
	@track fieldLabelNameStato;
    @track fieldLabelNameNote;
    
   
    connectedCallback(){

        if(Boolean(this.apiRequestName)){
            if(!this.certificationName){
                this.certificationName = 'salesforceprodclient2024';
            }
        }
        getPickListValues({
            objApiName: this.oggetto,
            fieldName: this.stato
        })
        .then(data => {
            this.options = data;
        })
        .catch(error => {
            console.log('AggiornamentoEsitazione.getPickListValues.error: ' + JSON.stringify(error));
        });

        getFieldLabel({
            objApiName: this.oggetto,
            stato: this.stato,
            note: this.note
        })
        .then(data => {
            let allField = data;
            this.fieldLabelNameStato = allField['stato'];
            this.fieldLabelNameNote = allField['note'];
        })
        .catch(error => {
            console.log('AggiornamentoEsitazione.getFieldLabel.error: ' + JSON.stringify(error));
        })
    }
   
    openModal(){
        this.openmodel = true;
    }

    selectionChangeHandler(event) {
		this.selectedOption = event.target.value;
        console.log('stato: '+this.selectedOption);
	}

    handleChange(event){
        this.noteValue = event.target.value;
        console.log('note: '+this.noteValue);
    }

    closeModal(){
        this.openmodel = false;
    }

    handleSave(){
        updateRecord({
            recordId: this.recordId,
            stato: this.stato,
            note: this.note,
            selectedOption: this.selectedOption,
            noteValue: this.noteValue,
            oggetto: this.oggetto,
            apiRequestName: this.apiRequestName,
            certificationName: this.certificationName,
            disableLog: this.disableLog,
            runAsUserId: null,
            jsonParam: this.jsonParam
        })
        .then(data => {
            if(data){
                const toastEvent = new ShowToastEvent({
                    title: "Success!",
                    message: "Esitazione aggiornata correttamente!!",
                    variant: "success"
                });
                this.dispatchEvent(toastEvent);
            }else{
                const toastEvent = new ShowToastEvent({
                    title: "Error!",
                    message: "Errore durante l'aggiornamento dell'esitazione!!",
                    variant: "error"
                });
                this.dispatchEvent(toastEvent);
            }
        })
        .catch(error => {
            console.log('AggiornamentoEsitazione.handleSave.error: ' + JSON.stringify(error));
        })
        .finally(() => {
            eval("$A.get('e.force:refreshView').fire();");
        })
    }
}