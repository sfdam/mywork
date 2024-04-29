/* eslint-disable no-unused-vars */
/* eslint-disable guard-for-in */
import { LightningElement, api, track, wire } from 'lwc';

// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

import { publish,MessageContext, subscribe, unsubscribe, APPLICATION_SCOPE } from 'lightning/messageService';
import lmsDemoMC from "@salesforce/messageChannel/newMicroWalletModal__c";

import getAllData from '@salesforce/apex/NewMicroWalletController.getAllData';
import getAllModelli from '@salesforce/apex/NewMicroWalletController.getAllModelli';
import getGestoriPrincipali from '@salesforce/apex/NewMicroWalletController.getGestoriPrincipali';
import getGestoriBackup from '@salesforce/apex/NewMicroWalletController.getGestoriBackup';
import saveMicroWallet from '@salesforce/apex/NewMicroWalletController.saveMicroWallet';

import Matricola from '@salesforce/label/c.newMicroWalletModal_CLM_Matricola';
import Nome from '@salesforce/label/c.newMicroWalletModal_CLM_Nome';
import Cognome from '@salesforce/label/c.newMicroWalletModal_CLM_Cognome';
//CR52359 SV start
import handleGetUffPrivate from '@salesforce/apex/NewMicroWalletController.getUffPrivate';
import getGestoriPrincipaliPrivate from '@salesforce/apex/NewMicroWalletController.getGestoriPrincipaliPrivate';
import getGestoriBackupPrivate from '@salesforce/apex/NewMicroWalletController.gestoriBackupPrivate';
import checkPortafoglioExists from '@salesforce/apex/NewMicroWalletController.checkPortafoglioExists';
//CR52359 SV end

export default class NewMicroWalletModal extends NavigationMixin(LightningElement) {

    @track disabledNumMicroPortafoglio = false;

    @api recordId;
    @api step1;
    @api step2 = false;
    @api stepSalvaMultiMP = false;
    @track showPTF999 = false;
    @track isPTF999 = false;
    @track isPTFSvil = false; // LV CR NEC #70081

    @api getAllData;
    @api getAllModelli;
    @api getAllGestoriPrincipali;
    @api getAllGestoriBackup;
    @api isRendered;
    @api accountFilter;

    @api valueBanca;
    @api valueDReg;
    @api valueAree;
    @api valueCapofila;
    @api valueFiliale;
    @api valueModServizio;
    @api valueNumMicroPortafoglio = '1';

    @api labelBanca;
    @api labelDReg;
    @api labelAree;
    @api labelCapofila;
    @api labelFiliale;

    @api optionsFilialeAll;

    @api listViewDataGestorePrincipale = [];
    @api listViewDataGestoreBackup = [];
    @api columns = [{
            label: Matricola,
            fieldName: 'PTF_RegistrationNumber__c',
            type: 'text',
            sortable: true
        },
        {
            label: Nome,
            fieldName: 'FirstName',
            type: 'text',
            sortable: true
        },
        {
            label: Cognome,
            fieldName: 'LastName',
            type: 'text',
            sortable: true
        },
    ];

    // @track prepopulatedAccount = { objId: undefined, sObjectName: 'Account', iconName: 'standard:account', name: undefined };
    @track prepopulatedAccount = null;
    @track optionsModServizio = [];
    @track searchedMatricola = '';
    @track searchedNome = '';
    @track searchedCognome = '';
    @track listDataGestorePrincipale='';
    @track listDataGestoreBackup='';

    @api selectedRowsGestorePrincipale = [];
    @api selectedRowsGestoreBackup = [];

    @track resetIndexReferentePrincipale=[];
    //CR52359 SV start
    @api abi;
    @track ptfPrivate = false;
    @track ptfCentriPrivate = false;//SV Centri Private
    @track options;
    @track optionsCentri;//SV Centri Private
    @track filiale1800 = false;//SV Centri Private
    @track selectedOption;
    @track selectedCentroOption; //SV Centri Private
    @track mappaUffici;//SV Centri Private
    @track mappaCentri;//SV Centri Private
    @track valueUffici;
    @track valueCentri;
    //CR52359 SV end
    @track optionsExecutive; //Salvatore Barbieri - Executive Private - 01/03/2024
    @track valueExecutive;
    @track selectedOptionExecutive;

    @track showSectionPrivate = false;

    //DK START CR72146
    mdsPtfSvil = ['private', 'key client privati']
    showPTFSvil = false;
    //DK END CR72146
    channel;
    @wire(MessageContext)
    context;

    constructor() {
        super();
    }
   
    subscribeToMessageChannel() {
        const parentPage = this;
        this.channel = subscribe(
            this.context, 
            lmsDemoMC, 
            (message) => this.handleMessage(message),
            { scope: APPLICATION_SCOPE }
        );
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.channel);
        this.channel = null;
    }

    // Handler for message received by component
    handleMessage(messageResult) {
        if (messageResult != null) {
            let message = messageResult.messageBody;
            let source = messageResult.source;
            if(source == 'newMicroWalletModalFooter'){
                if(message.action == 'nextStep'){
                    //CR52359 SV start
                    /*if(this.valueModServizio == 'Private' && this.selectedOption == undefined){
                        const toastEvent = new ShowToastEvent({
                            title: "Warning!",
                            message: "Selezionare un ufficio",
                            variant: "warning"
                        });
                        this.dispatchEvent(toastEvent);
                    }else{
                        //alert(JSON.stringify(this.prepopulatedAccount));
                        this.nextStep();
                    }*/
                    //CR52359 SV end
                    //SV Centri Corporate start
                    if(this.valueModServizio == 'Private' && this.selectedOption == undefined && !this.ptfCentriPrivate){
                        const toastEvent = new ShowToastEvent({
                            title: "Warning!",
                            message: "Selezionare un ufficio",
                            variant: "warning"
                        });
                        this.dispatchEvent(toastEvent);
                    }else if(this.valueModServizio == 'Private' && this.ptfCentriPrivate && this.selectedOption == undefined && this.selectedOptionExecutive == undefined && this.selectedCentroOption != undefined){
                        const toastEvent = new ShowToastEvent({
                            title: "Warning!",
                            message: "Selezionare un Ufficio o un Executive",
                            variant: "warning"
                        });
                        this.dispatchEvent(toastEvent);
                    }else if(this.valueModServizio == 'Private' && this.ptfCentriPrivate && this.selectedOption == undefined && this.selectedCentroOption == undefined && this.selectedOptionExecutive == undefined){
                        const toastEvent = new ShowToastEvent({
                            title: "Warning!",
                            message: "Selezionare un Ufficio e un Centro oppure un Executive",
                            variant: "warning"
                        });
                        this.dispatchEvent(toastEvent);
                    }else if(this.valueModServizio == 'Private' && this.ptfCentriPrivate && this.selectedOption != undefined && this.selectedCentroOption == undefined && this.selectedOptionExecutive == undefined){
                        const toastEvent = new ShowToastEvent({
                            title: "Warning!",
                            message: "Selezionare un Centro oppure un Executive",
                            variant: "warning"
                        });
                        this.dispatchEvent(toastEvent);
                    }else{
                        //alert(JSON.stringify(this.prepopulatedAccount));
                        this.nextStep();
                    }
                    //CR52359 SV end
                }

                if(message.action == 'previousStep'){
                    this.previousStep();
                }

                if(message.action == 'closeQuickAction'){
                    this.closeQuickAction();
                }

                if(message.action == 'saveAction'){
                    this.handleSave();
                }
            }
        }
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
        this.step1 = true;

        getAllData({ })
        .then(result => {
            console.log('SV getAllData result', result);
            console.log('SV getAllData result.currentUser', result.currentUser);
            
            // let filtroAggiuntivo = result.currentUser.Profilo__c != "NEC_D.0" ? " AND FinServ__BankNumber__c = '" + result.currentUser.abi__c + "'" : "";
            this.accountFilter = "RecordType.DeveloperName = 'FilialeDiRelazione'"/* + filtroAggiuntivo*/;
            this.getAllData = result;

            return getAllModelli({ })
            
        })
        .then(result => {
            console.log('SV getAllModelli result', result);

            this.getAllModelli = result;
            
        })
        .catch(error => {
            alert('ERROR');
            this.error = error;
            console.log('SV ERROR', error);
            this.isRendered = true;
        })
        .finally(() => {
            console.log('SV FINALLY');
            this.isRendered = true;
        }); 
    }

  

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    nextStep() {
        let valueFiliale = this.valueFiliale;
        let valueModServizio = this.valueModServizio;
        // let valueNumMicroPortafoglio = this.valueNumMicroPortafoglio;

        const allValid = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) =>{
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

            console.log(allValid);

        if(allValid){
            
            //CR52359 SV start
            console.log('ref servizio: '+ this.valueModServizio);
            console.log('ref abi: '+ this.abi);
            
            if(this.isPTF999 === true /*&& (this.valueModServizio !== 'POE') && (this.valueModServizio !== 'Family') && (this.valueModServizio !== 'Controparti Istituzionali')*/ ) {
                console.log('sono nell if del checkportafoglioexists');
                checkPortafoglioExists({filiale: this.valueFiliale, modelloServizio : this.valueModServizio})
                .then(result => {
                    if(result){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Errore',
                                message: 'Esiste già un Portafoglio 999 per questa filiale.',
                                variant: 'error'
                            })
                        );
                    }else{

                        this.isRendered=false;
                        this.step2 = true;
                        this.step1 = false;
                        this.stepSalvaMultiMP = true;
                        if(this.valueModServizio === 'Private'){
                            this.getRefsPrivate(valueFiliale, valueModServizio, allValid);
                        }else{
                            this.getRefs(valueFiliale, valueModServizio, allValid);
                            /*getGestoriPrincipali({ filialeId: valueFiliale, modelloServizio: valueModServizio, isChecked999: this.isPTF999, 
                                ischeckedPTF: this.isPTFSvil }) // LV CR NEC #70081
                            .then(result => {
                                console.log('SV getAllGestoriPrincipali result', result);
                    
                                this.getAllGestoriPrincipali = result;
                    
                                let rowsGestoriPrincipali = [];
                                for (let k in result) {
                                    rowsGestoriPrincipali.push(result[k]);
                                }
                    
                                this.listViewDataGestorePrincipale = rowsGestoriPrincipali;
                                this.listDataGestorePrincipale = rowsGestoriPrincipali;
                                return getGestoriBackup({ filialeId: valueFiliale, modelloServizio: valueModServizio, isChecked999: this.isPTF999,
                                isCheckedPTF: this.isPTFSvil }) // LV CR NEC #70081 
                            })
                            .then(result => {
                                console.log('SV getAllGestoriBackup result', result);
                    
                                this.getAllGestoriBackup = result;
                    
                                let rowsGestoriBackup = [];
                                for (let k in result) {
                                    rowsGestoriBackup.push(result[k]);
                                }
                    
                                this.listViewDataGestoreBackup = rowsGestoriBackup;
                                this.listDataGestoreBackup = rowsGestoriBackup;
                                
                            })
                            .catch(error => {
                                alert('ERROR');
                                this.error = error;
                                console.log('SV ERROR', error);
                                this.isRendered = true;
                    
                            })
                            .finally(() => {
                                console.log('SV FINALLY');
                    
                                this.isRendered = true;
                    
                    
                            });
    
                            const payload = {
                                source: "newMicroWalletModal",
                                messageBody: { num : valueNumMicroPortafoglio, valueModServizio : valueModServizio, allValid : allValid }
                            }; 
                            publish(this.context, lmsDemoMC, payload);*/
                        }
                    }
                })
                .catch(error => {
                    console.error(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Errore',
                            message: 'Si è verificato un errore.',
                            variant: 'error'
                        })
                    );
                });
            }else{
                this.isRendered=false;
                this.step2 = true;
                this.step1 = false;
                this.stepSalvaMultiMP = true;
                
                if(this.valueModServizio === 'Private'/* && this.abi === '05387'*/){
                    this.getRefsPrivate(valueFiliale, valueModServizio, allValid);
                    /*getGestoriPrincipaliPrivate({idFiliale: valueFiliale, modelloServizio: valueModServizio, ufficioPrivate: this.selectedOption, abi: this.abi})
                    .then(result => {
                        this.getAllGestoriPrincipali = result;
        
                        let rowsGestoriPrincipaliPrivate = [];
                        for(let k in result){
                            rowsGestoriPrincipaliPrivate.push(result[k]);
                        }
                        this.listViewDataGestorePrincipale = rowsGestoriPrincipaliPrivate;
                        this.listDataGestorePrincipale = rowsGestoriPrincipaliPrivate;
                        console.log('ref princ: '+this.listViewDataGestorePrincipale);
                        return getGestoriBackupPrivate({idFiliale: this.valueFiliale, modelloServizio: this.valueModServizio, ufficioPrivate: this.selectedOption, abi: this.abi})
                    })
                    .then(result => {
                        this.getAllGestoriBackup = result;
                        let rowsGestoriBackupPrivate = [];
                        for(let k in result){
                            rowsGestoriBackupPrivate.push(result[k]);
                        }
                        this.listViewDataGestoreBackup = rowsGestoriBackupPrivate;
                        this.listDataGestoreBackup = rowsGestoriBackupPrivate;
                        console.log('ref princ: '+this.listViewDataGestoreBackup);
                    })
                    .catch(error => {
                        alert('ERROR');
                        this.error = error;
                        console.log('SV ERROR', error);
                        this.isRendered = true;
                    })
                    .finally(() => {
                        console.log('SV FINALLY');
                        this.isRendered = true;
                    });

                    const payload = {
                        source: "newMicroWalletModal",
                        messageBody: { num : valueNumMicroPortafoglio, valueModServizio : valueModServizio, allValid : allValid }
                    }; 
                    publish(this.context, lmsDemoMC, payload);*/

                }else{

                    this.getRefs(valueFiliale, valueModServizio, allValid);
                    /*getGestoriPrincipali({ filialeId: valueFiliale, modelloServizio: valueModServizio, isChecked999: this.isPTF999,
                    isCheckedPTF: this.isPTFSvil }) // LV CR NEC #70081
                    .then(result => {
                        console.log('SV getAllGestoriPrincipali result', result);
                        this.getAllGestoriPrincipali = result;
            
                        let rowsGestoriPrincipali = [];
                        for (let k in result) {
                            rowsGestoriPrincipali.push(result[k]);
                        }
            
                        this.listViewDataGestorePrincipale = rowsGestoriPrincipali;
                        this.listDataGestorePrincipale = rowsGestoriPrincipali;
                        return getGestoriBackup({ filialeId: valueFiliale, modelloServizio: valueModServizio, isChecked999: this.isPTF999,
                        isCheckedPTF: this.isPTFSvil }) // LV CR NEC #70081 
                    })
                    .then(result => {
                        console.log('SV getAllGestoriBackup result', result);
            
                        this.getAllGestoriBackup = result;
            
                        let rowsGestoriBackup = [];
                        for (let k in result) {
                            rowsGestoriBackup.push(result[k]);
                        }
            
                        this.listViewDataGestoreBackup = rowsGestoriBackup;
                        this.listDataGestoreBackup = rowsGestoriBackup;
                        
                    })
                    .catch(error => {
                        alert('ERROR');
                        this.error = error;
                        console.log('SV ERROR', error);
                        this.isRendered = true;
            
                    })
                    .finally(() => {
                        console.log('SV FINALLY');
            
                        this.isRendered = true;
            
            
                    });

                    //CR52359 SV start
                    const payload = {
                        source: "newMicroWalletModal",
                        messageBody: { num : valueNumMicroPortafoglio, valueModServizio : valueModServizio, allValid : allValid }
                    }; 
                    publish(this.context, lmsDemoMC, payload);*/
                }
            }                
        }
    }

    getRefs(valueFiliale, valueModServizio, allValid){
        getGestoriPrincipali({ filialeId: valueFiliale, modelloServizio: valueModServizio, isChecked999: this.isPTF999,
        isCheckedPTF: this.isPTFSvil }) // LV CR NEC #70081
        .then(result => {
            console.log('SV getAllGestoriPrincipali result', result);
            this.getAllGestoriPrincipali = result;

            let rowsGestoriPrincipali = [];
            for (let k in result) {
                rowsGestoriPrincipali.push(result[k]);
            }

            this.listViewDataGestorePrincipale = rowsGestoriPrincipali;
            this.listDataGestorePrincipale = rowsGestoriPrincipali;
            return getGestoriBackup({ filialeId: valueFiliale, modelloServizio: valueModServizio, isChecked999: this.isPTF999,
            isCheckedPTF: this.isPTFSvil }) // LV CR NEC #70081 
        })
        .then(result => {
            console.log('SV getAllGestoriBackup result', result);

            this.getAllGestoriBackup = result;

            let rowsGestoriBackup = [];
            for (let k in result) {
                rowsGestoriBackup.push(result[k]);
            }

            this.listViewDataGestoreBackup = rowsGestoriBackup;
            this.listDataGestoreBackup = rowsGestoriBackup;
            
        })
        .catch(error => {
            alert('ERROR');
            this.error = error;
            console.log('SV ERROR', error);
            this.isRendered = true;

        })
        .finally(() => {
            console.log('SV FINALLY');

            this.isRendered = true;
        });

        //CR52359 SV start
        const payload = {
            source: "newMicroWalletModal",
            messageBody: { num : this.valueNumMicroPortafoglio, valueModServizio : valueModServizio, allValid : allValid }
        }; 
        publish(this.context, lmsDemoMC, payload);
    }

    getRefsPrivate(valueFiliale, valueModServizio, allValid){
        //SV aggiunto centro private in input
        getGestoriPrincipaliPrivate({idFiliale: valueFiliale, modelloServizio: valueModServizio, ufficioPrivate: this.selectedOption, abi: this.abi, isCheckedPTF: this.isPTF999, isPTFSvil: this.isPTFSvil, centroPrivate: this.selectedCentroOption, executivePrivate: this.selectedOptionExecutive})
        .then(result => {
            this.getAllGestoriPrincipali = result;

            let rowsGestoriPrincipaliPrivate = [];
            for(let k in result){
                rowsGestoriPrincipaliPrivate.push(result[k]);
            }
            this.listViewDataGestorePrincipale = rowsGestoriPrincipaliPrivate;
            this.listDataGestorePrincipale = rowsGestoriPrincipaliPrivate;
            console.log('ref princ: '+this.listViewDataGestorePrincipale);
            //SV aggiunto centro private in input
            return getGestoriBackupPrivate({idFiliale: this.valueFiliale, modelloServizio: this.valueModServizio, ufficioPrivate: this.selectedOption, abi: this.abi, centroPrivate: this.selectedCentroOption, executivePrivate: this.selectedOptionExecutive})
        })
        .then(result => {
            this.getAllGestoriBackup = result;
            let rowsGestoriBackupPrivate = [];
            for(let k in result){
                rowsGestoriBackupPrivate.push(result[k]);
            }
            this.listViewDataGestoreBackup = rowsGestoriBackupPrivate;
            this.listDataGestoreBackup = rowsGestoriBackupPrivate;
            console.log('ref princ: '+this.listViewDataGestoreBackup);
        })
        .catch(error => {
            alert('ERROR');
            this.error = error;
            console.log('SV ERROR', error);
            this.isRendered = true;
        })
        .finally(() => {
            console.log('SV FINALLY');
            this.isRendered = true;
        });

        const payload = {
            source: "newMicroWalletModal",
            messageBody: { num : this.valueNumMicroPortafoglio, valueModServizio : valueModServizio, allValid : allValid }
        }; 
        publish(this.context, lmsDemoMC, payload);
    }

    previousStep() {
        let valueFiliale = this.valueFiliale;
        let valueModServizio = this.valueModServizio;
        let valueNumMicroPortafoglio = this.valueNumMicroPortafoglio;

        this.step1 = true;
        this.step2 = false;
        if(valueNumMicroPortafoglio > 1){
            this.stepSalvaMultiMP = true;
        } else {
            this.stepSalvaMultiMP = false;
        }

    }

    get optionsNumMicroPortafoglio(){
        return [
            { label: '1', value: '1' },
            { label: '2', value: '2' },
            { label: '3', value: '3' },
            { label: '4', value: '4' },
            { label: '5', value: '5' },
            { label: '6', value: '6' },
            { label: '7', value: '7' },
            { label: '8', value: '8' },
            { label: '9', value: '9' },
            { label: '10', value: '10' },
        ];
    }

    handleChangeNumMicroPortafoglio(event){
        this.valueNumMicroPortafoglio = event.detail.value;
        let valueModServizio = this.valueModServizio;
        let numSelected = event.detail.value;
        if(numSelected > 1){
            this.stepSalvaMultiMP = true;
        } else {
            this.stepSalvaMultiMP = false;
        }

        const payload = {
            source: "newMicroWalletModal",
            messageBody: { num : numSelected, valueModServizio : valueModServizio }
        }; 
        publish(this.context, lmsDemoMC, payload);
    }

    handleChangeModServizio(event){
        this.showSectionPrivate = false;
        this.valueModServizio = event.detail.value;
        let modServizio = event.detail.value;
        let numSelected = this.valueNumMicroPortafoglio;
        this.showPTFSvil = this.mdsPtfSvil.includes(modServizio.toLowerCase());

        if(modServizio === 'POE' ||  modServizio === 'Family' || modServizio === 'Controparti Istituzionali' ){
            this.showPTF999 = false;
        }else{
            this.showPTF999 = true;
        }     

        if(modServizio === 'Family' || modServizio === 'POE' || modServizio === 'Controparti Istituzionali' || modServizio === 'Residuale' || modServizio === 'Assente'){
            this.disabledNumMicroPortafoglio = true;
            numSelected = '1';
            this.stepSalvaMultiMP = false;
            //CR52359 SV start
            this.ptfPrivate = false;
            this.ptfCentriPrivate = false;//SV Centri Private

            this.isPTF999 = false;
        } else if(modServizio === 'Private') {
            this.handleGetUffPrivate();
            this.ptfPrivate = true;
            this.ptfCentriPrivate = this.filiale1800 && this.ptfPrivate ? true : false;//SV Centri Private
            //CR52359 SV end
        }else {
            //CR52359 SV start
            this.ptfPrivate = false;
            this. ptfCentriPrivate = false;//SV Centri Private
            //CR52359 SV end
            this.disabledNumMicroPortafoglio = false;
            if(numSelected > 1){
                this.stepSalvaMultiMP = true;
            } else {
                this.stepSalvaMultiMP = false;
            }
        }
        setTimeout(() => {
            this.showSectionPrivate = true;
          }, 700);

        this.valueNumMicroPortafoglio = numSelected;

        const payload = {
            source: "newMicroWalletModal",
            messageBody: { num : numSelected, valueModServizio : modServizio }
        }; 
        publish(this.context, lmsDemoMC, payload);
    }
    //CR52359 SV start
    handleGetUffPrivate(){
        //SV cambiato il metodo di ritorno da lista di options per gli uffici a un wrapper
        handleGetUffPrivate({idFiliale: this.valueFiliale})
        .then(result => {
            this.options = result.optionUffici;
            this.optionsCentri = result.optionCentri;
            this.filiale1800 = result.filiale1800;
            this.ptfCentriPrivate = this.filiale1800 && this.ptfPrivate ? true : false;
            this.mappaCentri = result.mappaCentri;
            this.mappaUffici = result.mappaUffici;
            this.optionsExecutive = result.optionExecutive;
        })
        .catch(error => {
            console.log('NewMicroWalletModal.handleGetUffPrivate.error: ' + JSON.stringify(error));
        })
    }

    selectionChangeHandlerExecutive(event){
        this.selectedOptionExecutive = event.target.value;
        this.valueExecutive = event.target.value;
        this.valueUffici = undefined;
        this.selectedOption = undefined;
        this.valueCentri = undefined;
        this.selectedCentroOption = undefined;
    }

    selectionChangeHandler(event){
        this.selectedOption = event.target.value;
        //SV Centri private start
        this.valueUffici = event.target.value;
        if(this.ptfCentriPrivate){
            let newOptions = [];
            let centriSelezionati = this.mappaCentri[event.target.value];
            console.log('centri selezionati map: ',centriSelezionati);
            centriSelezionati.forEach((values, keys) => {
                newOptions.push({label: values.Name, value: values.PTF_IdCED__c});
            })
            this.optionsCentri = newOptions;
        }
        //SV Centri private end
        this.valueExecutive = undefined;
        this.selectedOptionExecutive = undefined;
    }

    //SV Centri Private start
    selectionChangeHandlerCentri(event) {
        this.selectedCentroOption = event.target.value;
        this.valueCentri = event.target.value;
        let ufficoSelezionato = this.mappaUffici[event.target.value];
        this.valueUffici = ufficoSelezionato;
        this.selectedOption = ufficoSelezionato;
        console.log('opzione selezionata: '+this.selectedOption);
        this.valueExecutive = undefined;
        this.selectedOptionExecutive = undefined;
    }
    //SV Centri Private end
    //CR52359 SV end
    handleChangeFiliale(idFiliale){
        this.valueFiliale = idFiliale;
        let idCapofila;
        let idAree;
        let idDReg;
        let idBanca;
        let branchFilialeSelected;
        let filiali = this.getAllData['filialeMap'];
        let bankNum = this.getAllData['filialeMap'][this.valueFiliale].FinServ__BankNumber__c;

        let filiale = this.getAllData['filialeMap'][this.valueFiliale];

        let optionsMDS = filiale.PTF_MDSAbilitati__c.split(',');
        let objList = [];
        optionsMDS.forEach(element => {
            let obj = {};
            obj.label = element;
            obj.value = element;
            objList.push(obj);
        });

        console.log('Modelli di servizio per Filiale: ', objList);

        this.optionsModServizio = objList;
        this.labelFiliale = filiale.Name;

        this.valueCapofila = filiale.PTF_Capofila__c;
        this.labelCapofila = filiale.PTF_Capofila__c ? this.getAllData['filialeMap'][filiale.PTF_Capofila__c].Name : null;

        this.valueDReg = filiale.PTF_DirezioneRegionale__c;
        this.labelDReg = filiale.PTF_DirezioneRegionale__c ? this.getAllData['dirRegionaleMap'][filiale.PTF_DirezioneRegionale__c].Name : null;

        this.valueAree = filiale.PTF_Area__c;
        this.labelArea = filiale.PTF_Area__c ? this.getAllData['areaMap'][filiale.PTF_Area__c].Name : null;

        this.valueBanca = filiale.PTF_Banca__c;
        this.labelBanca = filiale.PTF_Banca__c ? this.getAllData['bancheMap'][filiale.PTF_Banca__c].Name : null;
        //CR52359 SV start
        this.abi = filiale.FinServ__BankNumber__c;
        //CR52359 SV end
        this.selectedFiliale = true; 

        if(this.ptfPrivate){
            this.handleGetUffPrivate();
        }

    }

    get notEmptyListGestorePrincipale(){
        return this.listViewDataGestorePrincipale.length > 0;
    }

    get notEmptyListGestoreBackup(){
        return this.listViewDataGestoreBackup.length > 0;
    }

    handleSave(){
        
        let valueFiliale = this.valueFiliale;
        let valueBanca = this.valueBanca;
        let valueDReg = this.valueDReg;
        let valueAree = this.valueAree;
        let valueCapofila = this.valueCapofila;
        let valueModServizio = this.valueModServizio;
        let valueNumMicroPortafoglio = this.valueNumMicroPortafoglio;
        let gestorePrincipale = this.selectedRowsGestorePrincipale;
        let gestoreBackup = this.selectedRowsGestoreBackup;

        const allValid = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);

            console.log(allValid);

        if(allValid){
            if(!gestorePrincipale.some(item => gestoreBackup.includes(item))){
            
                this.isRendered = false;
                //SV aggiunto centro private in input
                saveMicroWallet({ filiale: valueFiliale, banca: valueBanca, dirRegionale: valueDReg, area: valueAree, capofila: valueCapofila, modelloServizio: valueModServizio, numMP: valueNumMicroPortafoglio, gestorePrincipale: gestorePrincipale, gestoreBackup: gestoreBackup, ufficioPrivate: this.selectedOption, isPTF999: this.isPTF999,
                isPTFSvil : this.isPTFSvil, centroPrivate: this.selectedCentroOption, executivePrivate: this.selectedOptionExecutive}) // LV CR NEC #70081
                    .then(result => {
                        console.log('SV saveMicroWallet result', result);
        
                        if(result){
                            const x = new ShowToastEvent({
                                "title": "Successo!",
                                "variant": "success",
                                "message": "\"" + valueNumMicroPortafoglio + "\" micro-portafogli creati!"
                            });
                            this.dispatchEvent(x);
        
                            this[NavigationMixin.Navigate]({
                                "type": "standard__objectPage",
                                "attributes": {
                                    objectApiName: 'Wallet__c',
                                    actionName: 'list'
                                }
                            });
                        }
                        
                    })
                    .catch(error => {
                        this.error = error;
                        console.log('SV ERROR', error);
                        const x = new ShowToastEvent({
                            "title": "Attenzione!",
                            "variant": "warning",
                            "message": error.body.pageErrors[0].message
                        });
                        this.dispatchEvent(x);
        
                        this.isRendered = true;
        
                    })
                    .finally(() => {
                        console.log('SV FINALLY');
        
                        this.isRendered = true;
        
        
                    });
            }else{
    
                const x = new ShowToastEvent({
                    "title": "Attenzione!",
                    "variant": "warning",
                    "message": "Uno o piu referenti sono stati selezionati sia per il ruolo di Referente di Backup che per quello di Primario."
                });
                this.dispatchEvent(x);
            }
        }

    }

    @api lastRow=[];
    
    getSelectedRowsGestorePrincipale(event){
        
        this.lastRow=this.selectedRowsGestorePrincipale;
        let selectedR = event.detail.selectedRows;
    
        let rows = [];
        for (let i = 0; i < selectedR.length; i++){
            rows.push(selectedR[i].Id);
        }
        this.selectedRowsGestorePrincipale = rows;
        //this.lastRow=this.selectedRowsGestorePrincipale;
        
    }

    @api lastRowBackUp=[];

    getSelectedRowsGestoreBackup(event){

        this.lastRowBackUp=this.selectedRowsGestoreBackup;
        let selectedR = event.detail.selectedRows;
        // Display that fieldName of the selected rows
        let rows = [];
        for (let i = 0; i < selectedR.length; i++){
            rows.push(selectedR[i].Id);
        }

        this.selectedRowsGestoreBackup = rows;
        this.lastRowBackUp=this.selectedRowsGestoreBackup;
    }


    refreshFiltri(){
        this.valueBanca='';
        this.valueCapofila='';
        this.valueDReg='';
        this.valueAree='';
        this.valueFiliale='';
        this.valueModServizio='';
        this.valueNumMicroPortafoglio='1';

        this.optionsFiliale = this.optionsFilialeAll;
        this.optionsDReg = [];
        this.optionsAree = [];
        this.optionsCapofila = [];
        this.optionsModServizio = [];

        this.disabledDReg = false;
        this.disabledArea = false;
        this.disabledNumMicroPortafoglio = false;

        this.selectedFiliale = false;
        this.showPTF999 = false;

        // LV CR NEC #70081 start
        this.ptfPrivate = false;
        this.ptfCentriPrivate = false;//SV Centri Private
        this.isPTF999 = false;
        this.isPTFSvil = false;
        // LV CR NEC #70081 end
        this.showSectionPrivate = false;


    }

    @api
    /*get accountFilter() {
        console.log();
        let filtroAggiuntivo = "";
        // let filtroAggiuntivo = this.currentUser.Profilo__c != "NEC_D.0" ? " AND FinServ__BankNumber__c = '" + this.currentUser.abi__c + "'" : "";
        return (
            "RecordType.DeveloperName = 'FilialeDiRelazione'" + filtroAggiuntivo
        );
    }*/

    handleCustomEvent(event) {
        console.log('@@@@@selectedWallet: '+JSON.stringify(event.detail)); 
        try{

            if(event.detail!=null ){
                this.prepopulatedAccount = event.detail;
                this.handleChangeFiliale(event.detail.objId);
            }
            else{
                this.refreshFiltri();
            }
        }catch(error){
            console.log('Dk error', error);
        }
        
    }

    setFilter(event)
    {
        if(event.target.name == 'searchedNome')  {
            this.searchedNome = event.target.value;
            console.log('searchedNome' , this.searchedNome)
        }
        else 
        this.searchedMatricola = event.target.value;
    }
    handleReset()
    {
       
        this.searchedNome = '';
        this.searchedMatricola = '';
        this.listViewDataGestorePrincipale=this.listDataGestorePrincipale;
        this.listViewDataGestoreBackup=this.listDataGestoreBackup;

        if( this.selectedRowsGestorePrincipale.length==0)
        {
            this.selectedRowsGestorePrincipale = this.lastRow;
            this.selectedRowsGestoreBackup = this.lastRowBackUp;
        }


        //this.handleSearch();
    }
    handleSearch()
    {
        this.newselectvalue=this.selectedRowsGestorePrincipale;
        console.log("START Handle SEARCH ROW",this.newselectvalue);

        this.listViewDataGestorePrincipale=this.listDataGestorePrincipale;
        this.listViewDataGestoreBackup=this.listDataGestoreBackup;
        console.log("Gestori MC", this.listViewDataGestorePrincipale);
        console.log("Gestori B MC", this.listViewDataGestoreBackup);
        
        this.filteredReferentiList = [];
        this.filteredReferentiBackUpList = [];
        this.page = 1;
        var nameReferente='';
        var surnameReferente='';
        var nameReferenteBackUp='';
        var surnameReferenteBackUp='';
        var matricola='';
        var firstName = '';
        try 
        {

            for(var i in this.listViewDataGestorePrincipale)
            {    
    
                firstName = this.listViewDataGestorePrincipale[i].FirstName != undefined ? this.listViewDataGestorePrincipale[i].FirstName.toLowerCase() : '';
            
                nameReferente=this.listViewDataGestorePrincipale[i].LastName.toLowerCase()+' '+firstName;
                surnameReferente= firstName+' '+this.listViewDataGestorePrincipale[i].LastName.toLowerCase();
                matricola=this.listViewDataGestorePrincipale[i].PTF_RegistrationNumber__c != undefined ? this.listViewDataGestorePrincipale[i].PTF_RegistrationNumber__c.toLowerCase() : '';
                nameReferente.trim();
                surnameReferente.trim();
                matricola.trim();
                if(Boolean(this.searchedNome))
                {
                    if(!(nameReferente.includes(this.searchedNome.toLowerCase().trim())||surnameReferente.includes(this.searchedNome.toLowerCase().trim())))
                    {
                        continue;
                    }  
                }
                if(Boolean(this.searchedMatricola)){
                   
                    if(!matricola.includes(this.searchedMatricola.toLowerCase().trim())){
                        continue;
                    }
                }
                
                this.filteredReferentiList.push(this.listViewDataGestorePrincipale[i]);
              
            }
          

            for(var i in   this.listViewDataGestoreBackup)
            {    
           
                firstName = this.listViewDataGestoreBackup[i].FirstName != undefined ? this.listViewDataGestoreBackup[i].FirstName.toLowerCase() : '';

                nameReferenteBackUp=this.listViewDataGestoreBackup[i].LastName.toLowerCase()+' '+ firstName;
                surnameReferenteBackUp= firstName +' '+this.listViewDataGestoreBackup[i].LastName.toLowerCase();
                matricola=this.listViewDataGestoreBackup[i].PTF_RegistrationNumber__c != undefined ? this.listViewDataGestoreBackup[i].PTF_RegistrationNumber__c.toLowerCase() : '';
                nameReferenteBackUp.trim();
                surnameReferenteBackUp.trim();
                matricola.trim();
                if(Boolean(this.searchedNome))
                {
                    if(!(nameReferenteBackUp.includes(this.searchedNome.toLowerCase().trim())||surnameReferenteBackUp.includes(this.searchedNome.toLowerCase().trim())))
                    {
                        continue;
                    }  
                }
                if(Boolean(this.searchedMatricola)){
                    if(!matricola.includes(this.searchedMatricola.toLowerCase().trim())){
                        continue;
                    }
                }
                this.filteredReferentiBackUpList.push(this.listViewDataGestoreBackup[i]);
                
            }
            console.log('DK filteredReferentiList: ' + JSON.stringify(this.filteredReferentiBackUpList));
           
            if(this.filteredReferentiBackUpList.length > 0)
            {
                this.hasGestori = true;
            } 
            else
            {
                this.hasGestori = false;
            }
            this.listViewDataGestoreBackup=this.filteredReferentiBackUpList;
            this.listViewDataGestorePrincipale=this.filteredReferentiList;
        } 
        catch (error) 
        {
            console.log('DK error: ' + error);
        }
        console.log("END  Handle SEARCH ROW",this.selectedRowsGestorePrincipale);
    }

   /* handleCheckboxNumMicroPortafoglio(event){
        this.isPTF999 = event.target.checked;

        if(this.isPTF999 === true){
            this.disabledNumMicroPortafoglio = true;
            this.valueNumMicroPortafoglio = '1';           
        }else{
            this.disabledNumMicroPortafoglio = false;
        }
    }*/

    changeToggle(event) {
       
        this.isPTF999 = event.target.checked;

        if( this.isPTF999 === true){
            this.disabledNumMicroPortafoglio = true;
            this.valueNumMicroPortafoglio = '1';
            this.isPTFSvil = false; // LV CR NEC #70081          
        }else{
            this.disabledNumMicroPortafoglio = false;
        }
            
        console.log('event.target: ',event);
        console.log('event.target.checked: ',event.target.checked);
        console.log('event.target.label: ',event.target.label);
        console.log('event.target.name: ',event.target.name);
  
    }
    // LV CR NEC #70081 start
    changeToggle2(event) {
       
        this.isPTFSvil = event.target.checked;

        if( this.isPTFSvil === true){
            this.isPTF999 = false;         
            this.disabledNumMicroPortafoglio = false;  
        }

        console.log('event.target: ',event);
        console.log('event.target.checked: ',event.target.checked);
        console.log('event.target.label: ',event.target.label);
        console.log('event.target.name: ',event.target.name);
  
    }
    // LV CR NEC #70081 end
}