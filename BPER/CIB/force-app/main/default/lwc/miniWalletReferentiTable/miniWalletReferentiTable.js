import { LightningElement, api, track } from 'lwc';
// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import getReferenti from '@salesforce/apex/miniWalletReferentiTableController.getReferenti';
import AssegnaReferenti from '@salesforce/apex/miniWalletReferentiTableController.AssegnaReferenti';
import getReferentiAssegnati from '@salesforce/apex/miniWalletReferentiTableController.getReferentiAssegnati';
import getReferentePrimario from '@salesforce/apex/miniWalletReferentiTableController.getReferentePrimario';
import deleteReferente from '@salesforce/apex/miniWalletReferentiTableController.deleteReferente';
import addReferentePrimario from '@salesforce/apex/miniWalletReferentiTableController.addReferentePrimario';
import addReferente from '@salesforce/apex/miniWalletReferentiTableController.addReferente';

const COLS = [
    { label: 'Nominativo', fieldName: 'PTF_Gestore_Name__c', hideDefaultActions: true,
    cellAttributes:{class:{fieldName: 'typeCSSClass' }} },
    { label: 'Matricola', fieldName: 'PTF_RegistrationNumber__c', hideDefaultActions: true },
    { label: 'Filiale', fieldName: 'PTF_Filiale__c', hideDefaultActions: true },
    { label: 'Macro-modello di servizio', fieldName: 'PTF_ModelloDiServizio__c', hideDefaultActions: true },
    {
        type: 'action',
        typeAttributes: { rowActions: [{ label: 'Elimina Referente', name: 'deleteReferente' }, { label: 'Aggiungi referente Primario', name: 'addReferentePrimario' }] },
    },
];

const COLSDISPONIBILI = [
    { label: 'Nominativo', fieldName: 'PTF_Gestore_Name__c', hideDefaultActions: true,
    cellAttributes:{class:{fieldName: 'typeCSSClass' }} },
    { label: 'Matricola', fieldName: 'PTF_RegistrationNumber__c', hideDefaultActions: true },
    { label: 'Filiale', fieldName: 'PTF_Filiale__c', hideDefaultActions: true },
    { label: 'Macro-modello di servizio', fieldName: 'PTF_ModelloDiServizio__c', hideDefaultActions: true }
];

export default class miniWalletReferentiTable extends LightningElement {

    columns = COLS;
    columnsDisponibili = COLSDISPONIBILI;
    @api title = 'Gestisci Referenti';
    @api recordId;
    @api openmodel = false;
    @api tableSource = '';
    @api noReferentiMsg = 'nessun referente selezionabile';
    @track nomeReferentePrimario = '';
    @track idReferentePrimario = '';
    @track selectedRows = [];
    @track referentiAssegnati = [];
    @track referentiList = [];
    @track selectedReferente = null;
    @track hasData = false;
    @track hasReferenti = false;
    @track isSaveDisabled = true;
    @track tableData = [];
    @track isRendered = true;

    @track isAssigned = false;
    @track disableAdd = true;
    @track disableDelete = true;
    @track disableAddPrimario = true;

    

    connectedCallback(){

        getReferenti({ miniwalletId: this.recordId })
            .then(result => {
                this.tableData = result;
                if(result.length > 0){
                    this.hasData = true;
                }
            })
            .catch(error => {
                console.error('GPF error: ' + JSON.stringify(error));
            });

        getReferentiAssegnati({ miniwalletId: this.recordId })
            .then(result =>{
                this.referentiAssegnati = result;
                if(result.length > 0){
                    this.hasReferenti = true;
                    this.referentiList = this.referentiAssegnati;
                    if(this.referentiList.length > 0){

                        this.isAssigned = true;
                    }
                }
            }).catch(error => {
                console.error('AdF getReferentiAssegnati error: ' + JSON.stringify(error));
            });

        getReferentePrimario({ miniwalletId: this.recordId })
            .then(result => {
                console.log('AdF result: ' + JSON.stringify(result));
                this.nomeReferentePrimario = result['name'];
                this.idReferentePrimario = result['id'];
            }).catch(error => {
                console.error('AdF getReferentePrimario error: ' + JSON.stringify(error));
            });

    }

    
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'deleteReferente':
                this.deleteReferente(row);
                break;
            case 'addReferentePrimario':
                this.addReferentePrimario(row);
                break;
            default:
        }
    }

    deleteReferente(row){
        try {
            
            if(row.PTF_Gestore__c != this.idReferentePrimario){
                console.log('Dk row: ', row);
                let assignment = {};
                this.referentiList.forEach(element =>{
                    if(element.Id === row.Id){
                        assignment = JSON.parse(JSON.stringify(element));
                    }
                });
                console.log('Dk assignment: ', assignment);
                deleteReferente({
                    assignment: row.Id,
                    referente: row.PTF_Gestore__c,
                    referentePrimario: this.idReferentePrimario,
                    miniWalletId: this.recordId
                }).then(data => {
                    this.tableData = this.tableData.concat([assignment]);
                    if(row.PTF_Gestore__c == this.idReferentePrimario){
                        this.idReferentePrimario = '';
                        this.nomeReferentePrimario = 'nessun referente primario selezionato';
                    }
                    console.log('Dk this.tableData: ', JSON.parse(JSON.stringify(this.tableData)));
                    this.referentiList = this.referentiList.filter(gestore => row.Id != gestore.Id);
                    
                    if(this.referentiList.length > 0){

                        this.isAssigned = true;
                    }else{

                        this.isAssigned = false;
                    }

                    if(this.tableData.length > 0){

                        this.hasData = true;
                    }else{

                        this.hasData = false;
                    }

                    // this.refreshPage();
                    const toastEvent = new ShowToastEvent({
                        title: "Successo!",
                        message: "Gestori eliminato con successo!!",
                        variant: "success"
                    });
                    this.dispatchEvent(toastEvent);
                    eval("$A.get('e.force:refreshView').fire();");
                }).catch(error => {

                    console.log('deleteReferente.error: ',error);
                });
            }else
            {
                this.showToastMessage("Cambiare referente principale per poter procedere con la cancellazione del referente corrente", "Warning");
            }
        } catch (error) {

            console.log('error: ' + error);
        }
    }

    addReferentePrimario(row){
        try {
            console.log('Dk row: ', row.PTF_Gestore__c);
            let gestore;
            this.referentiList.forEach(element =>{
                if(element.Id === row.Id){
                    gestore = element.PTF_Gestore__c;
                }
            });
            addReferentePrimario({
                gestore: gestore,
                miniWalletId: this.recordId
            }).then(data => {

                this.nomeReferentePrimario = row.PTF_Gestore_Name__c;
                this.idReferentePrimario =row.PTF_Gestore__c;
                if(this.referentiList.length > 0){

                    this.isAssigned = true;
                }else{

                    this.isAssigned = false;
                }

                if(this.tableData.length > 0){

                    this.hasData = true;
                }else{

                    this.hasData = false;
                }

                // this.refreshPage();
                const toastEvent = new ShowToastEvent({
                    title: "Successo!",
                    message: "Gestore aggiunto con successo!!",
                    variant: "success"
                });
                this.dispatchEvent(toastEvent);
                eval("$A.get('e.force:refreshView').fire();");
            }).catch(error => {

                console.log('addReferentePrimario.error: ', error);
            });
        } catch (error) {

            console.log('error: ' + error);
        }
    }

    addReferente(){
        try {
            
            let referentiTable = this.template.querySelector('[data-item="referentiDisponibili"]');
            let referentiToAdd = referentiTable.getSelectedRows();
            let addedIds = referentiToAdd.map(item => item.Id)
            if (referentiToAdd.length > 0) {
                // addedReferenteId = referentiToAdd[0].Id;
                
                addReferente({
                    referenti: referentiToAdd,
                    miniWalletId: this.recordId
                }).then(data => {

                    this.tableData = this.tableData.filter(gestore => !addedIds.includes(gestore.Id));
                    console.log('referentiToAdd', referentiToAdd);
                    this.referentiList = this.referentiList.concat(referentiToAdd);
                    console.log('this.referentiList', this.referentiList);
                    console.log('MC this.referentiList',  JSON.stringify(this.referentiList));

                    if(this.referentiList.length > 0){

                        this.isAssigned = true;
                    }else{

                        this.isAssigned = false;
                    }

                    if(this.tableData.length > 0){

                        this.hasData = true;
                    }else{
    
                        this.hasData = false;
                    }


                    // this.refreshPage();
                    const toastEvent = new ShowToastEvent({
                        title: "Successo!",
                        message: "Gestori aggiunti con successo!!",
                        variant: "success"
                    });
                    this.dispatchEvent(toastEvent);
                    eval("$A.get('e.force:refreshView').fire();");
                }).catch(error => {

                    console.log('deleteReferente.error: ' + JSON.stringify(error));
                });
            }
        } catch (error) {

            console.log('error: ' + error);
        }
    }


    handleRefRowSelection(event) {
        /*if(event.detail.selectedRows.length > 0){
            this.selectedRows = event.detail.selectedRows;
            this.isSaveDisabled = false;
            this.hasReferenti = true;
            this.referentiList = [];
            let tempList = [];
            this.referentiAssegnati.forEach(element => {
                tempList.push(element);
            })
            this.selectedRows.forEach(element => {
                tempList.push(element);
            })
            this.referentiList = tempList;
        }else{
            this.selectedRows = [];
            this.referentiList = [];
            this.isSaveDisabled = true;
            this.selectedReferente = null;
            this.selectedReferente = [];
            if(this.referentiAssegnati.length > 0){
                this.referentiList = this.referentiAssegnati;
                this.hasReferenti = true;
            }else{
                this.hasReferenti = false;
            }
        }
        console.log('GPF this.selectedRows ' + JSON.stringify(this.selectedRows));
        console.log('AdF this.selectedReferente ' + JSON.stringify(this.selectedReferente));
        console.log('AdF this.referentiList ' + JSON.stringify(this.referentiList));
        console.log('AdF this.referentiList length ' + this.referentiList.length);*/

        this.selectedRows = event.detail.selectedRows;
        if(this.selectedRows.length == 0){
            this.disableAdd = true;
        }else {
            this.disableAdd = false;
        }
    }

    handleReferenteSelection(event){
        /*this.selectedReferente = event.detail.selectedRows;
        if(this.selectedReferente.length > 0){
            this.isSaveDisabled = false;
        }
        console.log('AdF this.selectedReferente ' + JSON.stringify(this.selectedReferente));*/

        /*this.selectedRows = event.detail.selectedRows;
        if(this.selectedRows.length == 0){
            this.disableAddPrimario = true;
            this.disableDelete = true;
        }else if(this.selectedRows.length == 1){
            this.disableAddPrimario = false;
            this.disableDelete = false;
        }else if(this.selectedRows.length > 1){
            this.disableAddPrimario = true;
            this.disableDelete = false;
        }*/
    }

    /*handleAssignment(){
        this.isRendered = false;
        console.log('GPF result SALVA');
        if(this.selectedRows.length > 0 || this.selectedReferente.length > 0){
            AssegnaReferenti({miniWalletID: this.recordId, referenti: this.selectedRows, referentePrincipale: this.selectedReferente})
                .then(result => {
                    this.miniWalletId = result;
                    
                    this.showToastMessage("Salvataggio effettuato", "success");
                    eval("$A.get('e.force:refreshView').fire();");
                    //setInterval(window.location.reload(),5000);
                    return getReferentePrimario({ miniwalletId: this.recordId })
                })
                .then(result => {
                    
                    this.nomeReferentePrimario = result;
                })
                .catch(error => {
                    //this.showToastMessage("Si è verificato un errore", "error");
                    //console.error('GPF error: ' + JSON.stringify(error));
                }).finally(() => {
                    console.log('GB Finally');
        
                    this.isRendered = true;
                    this.openmodel = false;
        
                }); 

        }else{
            this.showToastMessage("Seleziona un Referente", "error");
        }
    }*/
    
    openModal() {
        this.openmodel = true;
    }

    closeModal() {
        this.openmodel = false;
        /*this.referentiList = [];
        this.referentiList = this.referentiAssegnati;
        this.selectedReferente = [];
        this.isSaveDisabled = true;
        this.selectedReferente = null;*/
    }

    showToastMessage(text, type) {
        const toastEvent = new ShowToastEvent({
            title: '',
            message: text,
            variant: type
        });
        this.dispatchEvent(toastEvent);
    }


}