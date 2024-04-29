import { LightningElement, track, api} from 'lwc';
import getWallet from '@salesforce/apex/sganciaReferentePTF_Controller.getWallet';
import sganciaReferente from '@salesforce/apex/sganciaReferentePTF_Controller.sganciaReferente';
import getContact from '@salesforce/apex/sganciaReferentePTF_Controller.getContact';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';



export default class SganciaReferentePTF extends LightningElement {

    @api portafogliPool=[];
    @api selectedRows=[];
    @api selectedPortafogliRow =[];
    @api selectedPortafogliIds = [];
    @api selectedModelloDiServizio;
    @api devname;
    @track selectedPortafogli = [];
    @track disableSganciaButton = true;
    @api isFromReportPage=false;
    contactId;
    @api contacts;
    @api contactSelected = false;
    @api portafogli;
    @api cards = false;
    @api portafogliList = false;
    @api infoContact;
    @api registrationNum;
    @api macroModelli;
    @api tipologiaRuolo;
    @api unitaOrg;
    @api OFS;
    @api nameRef;
    @api idContact;
    @api noFilter= false;
    @api buttonSgancia= false;
    loading=false;
    @track columnsPTF = [
        { label: 'Portafoglio', fieldName: 'PTF_NomePortafoglio__c', type: 'text'},
        { label: 'Filiale', fieldName: 'PTF_Filiale__c', type: 'text'},
        { label: 'Modello Di Servizio', fieldName: 'PTF_ModelloDiServizio__c', type: 'text'},
        { label: 'Numero di NDG', fieldName: 'CRM_numNDG', type: 'number', cellAttributes: { alignment: 'left' }},
        { label: 'Tipo di Referente', fieldName: 'recordTypeName', type: 'text'},
    ];


    connectedCallback(){
       
    }


    handleCustomEvent(event) {

        if(event.detail!=null ){
            this.contactId=event.detail.objId;
        }
        else{
            this.contactId=null;
        }
        let contactSelected = JSON.stringify(event.detail);
        console.log('@@@@@selectedContact: ' + contactSelected);;
        console.log('@@@@@contactId: ' , this.contactId);
        this.getContactInfo(this.contactId);
    }

    async getContactInfo(contactId) {
        try {
        this.infoContact = await getContact({ contactId });
        console.log('infoContact', this.infoContact);
        if(this.infoContact.length > 0){
            this.nameRef = this.infoContact[0].CRM_NomeReferente__c;
            this.registrationNum = this.infoContact[0].PTF_RegistrationNumber__c;
            this.macroModelli = this.infoContact[0].PTF_MDSConcatList__c;
            this.tipologiaRuolo = this.infoContact[0].PTF_TipologiaRuolo__r.Name;
            this.unitaOrg = this.infoContact[0].PTF_UnitaOrganizzativaNoEncryption__c;
            this.OFS = this.infoContact[0].PTF_OFS__c;
            this.idContact= '/lightning/r/Contact/' + contactId + '/view';       
            this.cards = true;
            this.getPortafogli(contactId);

        }else{
            this.cards = false;
        }
        } catch (error) {
        console.error('Error:', error);
        }
        this.contactSelected = true;

        if(contactId == null){
            this.contactSelected = false;
        }
    }


    async getPortafogli(contactId) {
        
        try {
            this.portafogli = await getWallet({ contactId });
            console.log('this.portafogli: ', this.portafogli);
            if(this.portafogli) {
                let newArray = [];
                this.portafogli.forEach(tracking => {
                    let newTracking = tracking;
                    newTracking.PTF_NomePortafoglio__c = tracking.PTF_NomePortafoglio__c;
                    newTracking.PTF_ModelloDiServizio__c = tracking.PTF_ModelloDiServizio__c;
                    newTracking.PTF_Filiale__c = tracking.PTF_Filiale__c;
                    newTracking.recordTypeName = tracking.RecordType.DeveloperName;
                    newTracking.CRM_numNDG = tracking.PTF_MicroWallet__r.CRM_numNDG__c;
                    newArray.push(newTracking);

                    if(tracking.PTF_MicroWallet__r.PTF_Pool__c === true){
                        this.portafogliPool.push(tracking.Id);
                    }
                });
                this.portafogli = newArray;
            }
        
            if(this.portafogli.length > 0){
                this.portafogliList = true;
                console.log('sono nell if', this.portafogli);
            }else{
                this.portafogliList = false;
            }
        } catch (error) {
            console.error('Error:', error);
        }
        this.contactSelected = true;

        if(contactId == null){
            this.contactSelected = false;
        }

    }

    get contactFilter() {
        var condition = "PTF_ReferenteElegibile__c = TRUE";
        return condition;
    }

    handleSelection(event) {
        try{
            let selectedPortafogliIdsCopy=[].concat(this.selectedPortafogliIds);
            let rowId = event.detail.config.value;
            let methodSelection= event.detail.config.action;
            console.log('rowId', rowId);        
            console.log('methodSelection', methodSelection);  
   
            if(methodSelection === 'rowSelect'){
                if(this.portafogliPool.includes(rowId)){
                    const toastEvent = new ShowToastEvent({
                        title: "Warning!",
                        message: "Non è possibile selezionare portafogli in pool.",
                        variant: "warning"
                    });
                    this.dispatchEvent(toastEvent);

                    console.log('select port: ', this.selectedPortafogliIds);
                    this.selectedPortafogliIds = selectedPortafogliIdsCopy;
                }else{
                    this.selectedPortafogliIds.push(rowId);
                }
            }else if(methodSelection === 'rowDeselect'){
                let index = selectedPortafogliIdsCopy.indexOf(rowId);
            
                if(index >- 1){
                    selectedPortafogliIdsCopy.splice(index,1); 
                }
                this.selectedPortafogliIds = selectedPortafogliIdsCopy;

            }else if(methodSelection === 'selectAllRows'){
                console.log('selectAllRows');
                selectedPortafogliIdsCopy= [];
                event.detail.selectedRows.forEach(element => {

                    if(element.PTF_MicroWallet__r.PTF_Pool__c === false){
                        console.log('sono nell if pool === false');
                        selectedPortafogliIdsCopy.push(element.Id);
                    }
                })

                this.selectedPortafogliIds = selectedPortafogliIdsCopy;

            }else if (methodSelection === 'deselectAllRows'){
                console.log('deselectAllRows');
                this.selectedPortafogliIds = [];
            }           
           
        }catch (error) {
            console.error('Error:', error);
        }

    }

    reset(){
        this.contactId = null;
        this.contactSelected = false;
        this.portafogliList = [];
    }
    
    async handleSganciaReferente() {

        if(this.selectedPortafogliIds.length == 0){
            const toastEvent = new ShowToastEvent({
                title: "Attenzione!",
                message: "Selezionare almeno un portafoglio da cui sganciare il referente.",
                variant: "warning"
            });
            this.dispatchEvent(toastEvent);
        }else{

            try {
                this.loading= true;
                sganciaReferente({assignmentIds:this.selectedPortafogliIds, nomeReferente: this.infoContact[0].CRM_NomeReferente__c, idReferente: this.contactId})
                .then(() =>{
    
                    const toastEvent = new ShowToastEvent({
                        title: "Successo!",
                        message: "Operazione di sgancio in corso, riceverai una notifica al completamento!",
                        variant: "success",
                        mode: 'sticky'
                    });
                    this.dispatchEvent(toastEvent);
                    this.selectedPortafogliIds = [];
                    this.contactSelected = false;
                    // this.reset();
                    this.getPortafogli(this.contactId);
                    // window.location.reload();
                })
                .catch(error =>{
                    console.log('Error:', error);
                    const toastEvent = new ShowToastEvent({
                        title: "Errrore!",
                        message: "Errore durante lo sgancio. Contattare il proprio amministratore di sistema.",
                        variant: "error"
                    });
                    this.dispatchEvent(toastEvent);
                })
                .finally(() =>{
                    this.loading = false;
                });
                
            }catch (error) {
                this.loading= true;
                console.error('Error: ', error);
            }
        }
    }
           
}