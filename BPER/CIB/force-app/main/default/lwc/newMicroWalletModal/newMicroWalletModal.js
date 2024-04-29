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
    @track portafoglio999 = false;
    @track valueCheckbox;

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

    @track prepopulatedAccount = { objId: undefined, sObjectName: 'Account', iconName: 'standard:account', name: undefined };
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
    @track options;
    @track selectedOption;
    //CR52359 SV end
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
                    if(this.valueModServizio == 'Private' && this.selectedOption == undefined){
                        const toastEvent = new ShowToastEvent({
                            title: "Warning!",
                            message: "Selezionare un uffico",
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
            
            let filtroAggiuntivo = result.currentUser.Profilo__c != "NEC_D.0"  && result.currentUser.Profile.Name != "System Administrator" ? " AND FinServ__BankNumber__c = '" + result.currentUser.abi__c + "'" : "";
            this.accountFilter = "RecordType.DeveloperName = 'FilialeDiRelazione' AND PTF_DataChiusura__c = NULL " + filtroAggiuntivo;
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
        let valueNumMicroPortafoglio = this.valueNumMicroPortafoglio;

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
            
            if(this.valueCheckbox === true && this.valueModServizio === 'Key Client Privati') {
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
                        getGestoriPrincipali({ filialeId: valueFiliale, modelloServizio: valueModServizio, isChecked999: this.valueCheckbox })
                        .then(result => {
                            console.log('SV getAllGestoriPrincipali result', result);
                
                            this.getAllGestoriPrincipali = result;
                
                            let rowsGestoriPrincipali = [];
                            for (let k in result) {
                                rowsGestoriPrincipali.push(result[k]);
                            }
                
                            this.listViewDataGestorePrincipale = rowsGestoriPrincipali;
                            this.listDataGestorePrincipale = rowsGestoriPrincipali;
                            return getGestoriBackup({ filialeId: valueFiliale, modelloServizio: valueModServizio, isChecked999: this.valueCheckbox }) 
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
                        publish(this.context, lmsDemoMC, payload);
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
                    getGestoriPrincipaliPrivate({idFiliale: valueFiliale, modelloServizio: valueModServizio, ufficioPrivate: this.selectedOption, abi: this.abi})
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
                    publish(this.context, lmsDemoMC, payload);

                }else{
                    getGestoriPrincipali({ filialeId: valueFiliale, modelloServizio: valueModServizio, isChecked999: this.valueCheckbox })
                    .then(result => {
                        console.log('SV getAllGestoriPrincipali result', result);
                        this.getAllGestoriPrincipali = result;
            
                        let rowsGestoriPrincipali = [];
                        for (let k in result) {
                            rowsGestoriPrincipali.push(result[k]);
                        }
            
                        this.listViewDataGestorePrincipale = rowsGestoriPrincipali;
                        this.listDataGestorePrincipale = rowsGestoriPrincipali;
                        return getGestoriBackup({ filialeId: valueFiliale, modelloServizio: valueModServizio, isChecked999: this.valueCheckbox }) 
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
                    publish(this.context, lmsDemoMC, payload);
                }
            }                
        }
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
        this.valueModServizio = event.detail.value;
        let modServizio = event.detail.value;
        let numSelected = this.valueNumMicroPortafoglio;

        modServizio === 'Key Client Privati' ? this.portafoglio999 = true : this.portafoglio999 = false;
      

        if(modServizio === 'Family' || modServizio === 'POE' || modServizio === 'Controparti Istituzionali' || modServizio === 'Residuale' || modServizio === 'Assente'){
            this.disabledNumMicroPortafoglio = true;
            numSelected = '1';
            this.stepSalvaMultiMP = false;
            //CR52359 SV start
            this.ptfPrivate = false;
        } else if(modServizio === 'Private') {
            this.handleGetUffPrivate();
            this.ptfPrivate = true;
            //CR52359 SV end
        }else {
            //CR52359 SV start
            this.ptfPrivate = false;
            //CR52359 SV end
            this.disabledNumMicroPortafoglio = false;
            if(numSelected > 1){
                this.stepSalvaMultiMP = true;
            } else {
                this.stepSalvaMultiMP = false;
            }
        }

        this.valueNumMicroPortafoglio = numSelected;

        const payload = {
            source: "newMicroWalletModal",
            messageBody: { num : numSelected, valueModServizio : modServizio }
        }; 
        publish(this.context, lmsDemoMC, payload);
    }
    //CR52359 SV start
    handleGetUffPrivate(){
        handleGetUffPrivate({idFiliale: this.valueFiliale})
        .then(result => {
            this.options = result;
        })
        .catch(error => {
            console.log('NewMicroWalletModal.handleGetUffPrivate.error: ' + JSON.stringify(error));
        })
    }

    selectionChangeHandler(event){
        this.selectedOption = event.target.value;
    }
    //CR52359 SV end
    handleChangeFiliale(idFiliale){
        this.valueFiliale = idFiliale;
        let idCapofila;
        let idAree;
        let idDReg;
        let idBanca;
        let branchFilialeSelected;
        console.log('responseee >> ' +this.getAllData);
        let filiali = this.getAllData['filialeMap'];
        let bankNum = this.getAllData['filialeMap'][this.valueFiliale].FinServ__BankNumber__c;

        console.log(this.getAllData['filialeMap']);
        console.log(this.getAllData['filialeMap'][this.valueFiliale]);
        console.log(this.getAllData['filialeMap'][this.valueFiliale].FinServ__BankNumber__c);

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
                saveMicroWallet({ filiale: valueFiliale, banca: valueBanca, dirRegionale: valueDReg, area: valueAree, capofila: valueCapofila, modelloServizio: valueModServizio, numMP: valueNumMicroPortafoglio, gestorePrincipale: gestorePrincipale, gestoreBackup: gestoreBackup, ufficioPrivate: this.selectedOption, isCheckboxChecked: this.valueCheckbox})
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
        this.portafoglio999 = false;


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
        this.valueCheckbox = event.target.checked;

        if(this.valueCheckbox === true){
            this.disabledNumMicroPortafoglio = true;
            this.valueNumMicroPortafoglio = '1';           
        }else{
            this.disabledNumMicroPortafoglio = false;
        }
    }*/
    changeToggle(event) {
       
        this.valueCheckbox = event.target.checked;

        if( this.valueCheckbox === true){
            this.disabledNumMicroPortafoglio = true;
            this.valueNumMicroPortafoglio = '1';           
        }else{
            this.disabledNumMicroPortafoglio = false;
        }
            
        console.log('event.target: ',event);
        console.log('event.target.checked: ',event.target.checked);
        console.log('event.target.label: ',event.target.label);
        console.log('event.target.name: ',event.target.name);
  
    }
}