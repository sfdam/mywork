import { LightningElement, api, track } from 'lwc';
import LightningModal from 'lightning/modal';

export default class CustomCaseListColumnManager extends LightningModal {

    @api listManager;
    @api listView;
    newOwner;

    connectedCallback(){
        this.handleInit()
    }

    async handleInit()
    {
    
    }

    lookupRecord(event){
        // alert('Selected Record Value on Parent Component is ' +  JSON.stringify(event.detail.selectedRecord) + 'casi selezionati: ' + this.cases);
        this.newOwner = event.detail.selectedRecord;
    }
    
    handleCancel() {
        const closeModalEvent = new CustomEvent('close');
        this.dispatchEvent(closeModalEvent);
    }

    handleOkay() {
        this.listView.updateListView()
        this.close('okay');
    }

    handleKO() {
        this.close('KO');
    }
}