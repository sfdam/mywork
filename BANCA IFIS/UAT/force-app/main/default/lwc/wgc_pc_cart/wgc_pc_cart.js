import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssCartPC from '@salesforce/resourceUrl/cssCartPC';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//Label Start
import labelInvioPEF from '@salesforce/label/c.WGC_Cart_SpinnerMessage_InviaNuovaVendita';
import labelStato2 from '@salesforce/label/c.Stato_Opp_2';
import labelStato3 from '@salesforce/label/c.Stato_Opp_3';
import esistePefLabel from '@salesforce/label/c.WGC_Cart_EsistePEFAttiva';
import labelErroreCarrello from '@salesforce/label/c.WGC_Cart_ToastWarningTitle';
//Label End
import getPayload from '@salesforce/apex/WGC_PC_CartController.getPayload';
import getUserInfo from '@salesforce/apex/WGC_PC_CartController.getUserInfo';
import getProds from '@salesforce/apex/WGC_PC_CartController.getProducts';
import checkOpenOpp from '@salesforce/apex/WizardOpportunityController.checkIfOpenable';
import getTitEsec from '@salesforce/apex/WizardOpportunityController.getTitolariEsecutori';
import getOwnership from '@salesforce/apex/WizardOpportunityController.checkOwnership';
import checkClosable from '@salesforce/apex/WizardOpportunityController.checkIfClosable';
import creaAgenziaEntrate from '@salesforce/apex/WGC_PC_CartController.createAttoreAgenzia';
// import aggiornaInvioBO from '@salesforce/apex/WizardOpportunityController.updateField';
import aggiornaCampo from '@salesforce/apex/WizardOpportunityController.updateField';
import apriOpp from '@salesforce/apex/WGC_PC_CartController.openOpportunityFF';
import invioTime from '@salesforce/apex/WGC_PC_CartController.callCensimentoTrattativa';
import invioPEF41 from '@salesforce/apex/WGC_PC_CartController.callPEF41';
import esistePEF from '@salesforce/apex/WizardOpportunityController.esistePef';
import associaResponsabili from '@salesforce/apex/WizardOpportunityController.associaResponsabili';
import checkTitolariEsecutore from '@salesforce/apex/WizardOpportunityController.checkTitolariEsecutore';
import privacyEsecutoreFirmata from '@salesforce/apex/WizardOpportunityController.privacyEsecutoreFirmata';
import checkCensimentoAnag from '@salesforce/apex/WGC_PC_CartController.checkCensimentoAnag';

export default class Wgc_pc_cart extends NavigationMixin(LightningElement) {
    /* OPPORTUNITY */
    //@api
    //opp = { Account : { } , Owner: { } , Tribunale__r: { } };
    @api
    recordId;
    @api
    recordTypeId;
    @track
    payload = { opportunityData : { Account : { }, Tribunale__r : { }, Owner : { } }  };
    @track
    userInfo;

    /* Modal */
    @api
    showModal = false;
    @api
    cmpModalName;
    @api
    modalParams;
    /* Modal */

    /* Spinner */
    @track
    loaded = false;
    @api
    spinnerMessage = 'Inizializzazione dati pratica';
    /* Spinner */

    @api
    mainWizProgress = 0;
    
    @track
    selectedStep = 'sceltaProdotto';

    @api
    mainWizardItems = [{ title: "In Lavorazione", phase: "In Lavorazione", active: true, visible: true, state: "inProgress", phaseDuration: 0, visibleFor: "nuovaConcessione,revisione", class: "cstm-main-wizard-item " }, 
                        { title: labelStato2, phase: "Valutazione Pratica", active: false, visible: true, state: "", phaseDuration: 0, visibleFor: "nuovaConcessione,revisione", class: "cstm-main-wizard-item " }, 
                        { title: labelStato3, phase: "Perfezionamento Contratto", active: false, visible: true, state: "", phaseDuration: 0, visibleFor: "nuovaConcessione,revisione", class: "cstm-main-wizard-item " },
                        { title: "Vinta", phase: "Vinta", active: false, visible: true, state: "", phaseDuration: 0, visibleFor: "nuovaConcessione,revisione", class: "cstm-main-wizard-item " }];
    @api
    stepWizard = [{ title: "SCELTA PRODOTTO", step: "sceltaProdotto", completed: false, failed: false, completedIcon: '', disabled: false, class: "slds-text-align_center cstm-wizard-item active ", defaultClass: "slds-text-align_center cstm-wizard-item " },
                    { title: "CONFIGURA PRODOTTO", step: "configuraProdotto", completed: false, failed: false, completedIcon: '', disabled: false, class: "slds-text-align_center cstm-wizard-item ", defaultClass: "slds-text-align_center cstm-wizard-item " },
                    //TODO DOCUMENTAZIONE COMPLETED
                    { title: "DOCUMENTAZIONE", step: "documentazione", completed: false, failed: true, completedIcon: '', disabled: false, class: "slds-text-align_center cstm-wizard-item failed ", defaultClass: "slds-text-align_center cstm-wizard-item failed " },
                    { title: "NOTE", step: "note", completed: false, failed: true, completedIcon: '', disabled: false, class: "slds-text-align_center cstm-wizard-item failed ", defaultClass: "slds-text-align_center cstm-wizard-item failed " }];
    
    stepWizardClass = { default: 'slds-text-align_center cstm-wizard-item',
                        completed : 'slds-text-align_center cstm-wizard-item completed',
                        failed: 'slds-text-align_center cstm-wizard-item failed',
                        active: 'slds-text-align_center cstm-wizard-item active',
                        completed_active: 'slds-text-align_center cstm-wizard-item active completed',
                        failed_active: 'slds-text-align_center cstm-wizard-item active failed',
                        disabled: 'slds-text-align_center cstm-wizard-item disabled'};

    @api
    titolariEffettivi;
    @api
    esecutori;
    @api
    isClosable;
    @api
    readOnlyParent = false;
    @api
    readOnly = false;
    @api
    ifOpeningOpportunity;

    @track
    isVisible;

    @track
    isVisibleTracker;

    /* PRODUCTS */
    @track
    allProducts = [{ name: 'ProceduraConcorsuale', label: 'Procedura Concorsuale', famiglia: 'Crediti Erariali', selected: false, removable: false }, { name: 'FiscaleBonis', label: 'Fiscale Bonis', famiglia: 'Crediti Erariali', selected: false, removable: false }];
    @track
    prods = [];
    @track
    selectedProds = [];
    @track
    selectedLines = [];

    @api isCommerciale = false;

    /* PRODUCTS */

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        this.recordId = currentPageReference.state.c__opportunityId;
    }

    constructor() {
        super();
        // this.template.addEventListener('closemodal', this.handleCloseModal.bind(this));
        this.addEventListener('modal', this.handleModal.bind(this));
        this.template.addEventListener('cart_pc_call_server', this.handleCartCallServer.bind(this));
        this.template.addEventListener('stepwizard', this.updateStepWizard.bind(this));
        this.template.addEventListener('spinnerevt', this.handleSpinner.bind(this));
    }

    connectedCallback(){
        //Used for override standard CSS
        loadStyle(this, cssCartPC);
        this.showSpinner(this.spinnerMessage);

        getPayload({ opportunityId : this.recordId })
            .then(result => {
                console.log('@@@ payload init ' , JSON.stringify(result));
                this.payload = result;
                this.recordTypeId = result.opportunityData.RecordType.Id;
                this.isVisible = result.opportunityData.StageName == 'In Lavorazione' /*|| result.opportunityData.StageName == 'Persa'*/;
                this.isVisibleTracker = result.opportunityData.StageName != 'In Lavorazione' && result.opportunityData.StageName != 'Persa';
                return getUserInfo();
            })
            .then(result => {
                this.userInfo = result;
                this.isCommerciale = result.Profile.Name != 'Amministratore del sistema' && result.Profile.Name != 'IFIS - B/O Valutazione Fast Finance';
                
                return getProds();
            })
            .then(result => {
                this.allProducts = [];
                result.data[0].forEach(p => {
                    let newP = {};
                    newP.name = p.CodiceUnivoco__c;
                    newP.label = p.Name;
                    newP.famiglia = p.WGC_Area__c,
                    newP.selected = false;
                    newP.removable = false;
                    this.allProducts.push(newP);
                    //name: 'ProceduraConcorsuale', label: 'Procedura Concorsuale', famiglia: 'Crediti Erariali', selected: false, removable: false
                });
            })
            .finally(() => {
                //SETUP 
                this.setupTitEsec();
                this.setupMainWizardItems();
                this.setupStepWizard();
                this.checkOwnership();
                this.checkIsClosable();
                this.ifOpeningOpportunityCheck();

                //READONLY
                this.setupReadOnly();

                //PRODUCTS
                this.setupProducts();

                //FINISH SETUP
                this.hideSpinner();
            })
            .catch(err => {
                console.log('@@@ err ' , err);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Errore',
                        message: err.message,
                        variant: 'error'
                    })
                );
            });
    }

    renderedCallback(){
    }

    /* GETTER & SETTER START */

    get accountId(){
        return '/'+this.payload.opportunityData.AccountId;        
    }

    get accountIdDoc(){
        return this.payload.opportunityData.AccountId;
    }

    get isLost(){
        return this.payload.opportunityData.StageName == 'Persa';
    }

    get stepWizardVisibility(){
        return this.payload.opportunityData.StageName == 'In Lavorazione';
    }

    get tipoOpp(){
        return this.payload.opportunityData.Tipologia_Opportunit__c == 'CONC' ? 'Nuova Concessione' : this.payload.opportunityData.Tipologia_Opportunit__c;
    }

    //Steps
    get sceltaProdotto(){
        return this.selectedStep == 'sceltaProdotto';
    }

    // get substepSceltaProdotto(){
    //     return this.subStep == 'inserimentoCed';
    // }

    get inserimentoCed(){
        return this.selectedStep == 'inserimentoCed';
    }

    get configuraProdotto(){
        return this.selectedStep == 'configuraProdotto';
    }

    get documentazione(){
        return this.selectedStep == 'documentazione';
    }

    get note(){
        return this.selectedStep == 'note';
    }

    //Check NV
    get checkNV(){
        let check = this.stepWizard.filter((step) => { return !step.completed }).length > 0 || ( this.payload.opportunityData.WGC_Invio_Mail_FF__c && this.isCommerciale ) || this.payload.opportunityData.WGC_Sospesa__c;
        return check;
    }

    get cmpModal(){
        return this.cmpModalName;
    }

    get ownerFase(){
        return this.payload.opportunityData.WGC_Invio_Mail_FF__c ? 'B/O' : 'Commerciale';
    }

    /* GETTER & SETTER END */

    setupReadOnly(){
        //this.readOnly = this.payload.userInfo.Id != this.payload.opportunityData.OwnerId && this.payload.userInfo.Profile.Name != 'Amministratore del sistema' && this.payload.userInfo.Profile.Name != 'IFIS - B/O Valutazione Fast Finance';
        this.readOnly = ((this.userInfo.Id != this.payload.opportunityData.OwnerId && this.userInfo.Profile.Name != 'Amministratore del sistema' && this.userInfo.Profile.Name != 'System Administrator' && this.userInfo.Profile.Name != 'IFIS - B/O Valutazione Fast Finance') || (this.userInfo.Profile.Name == 'IFIS - Crediti Erariali' && this.payload.opportunityData.WGC_Invio_Mail_FF__c) ) || this.payload.opportunityData.StageName != 'In Lavorazione';
    }

    setupProducts(){
        if(this.payload.opportunityData.WGC_Prodotti_Selezionati__c != undefined){
            var selezionati = this.payload.opportunityData.WGC_Prodotti_Selezionati__c.split(';');
            var lockedNames = this.selectedProds.map(p => { return p.name; });
            this.allProducts.forEach((p) => {
                if(selezionati.includes(p.name)){
                    p.selected = true;
                    p.removable = true;
                    if(!lockedNames.includes(p.name))
                        this.selectedProds.push(p);
                } else {
                    p.removable = false;
                    p.selected = false;
                    this.prods.push(p);
                }
            });
        } else {
            this.prods = this.allProducts;
        }

        console.log('@@@ this.selectedProds ' , this.selectedProds);
        this.selectedLines = this.selectedProds;
    }

    reloadProd(){
        var selectedName = [];
        this.selectedProds.forEach((p) => { 
            selectedName.push(p.name); 
            p.selected = true;
            p.removable = true;
        });

        this.prods = [];
        this.allProducts.forEach((p) => {
            if(!selectedName.includes(p.name)) this.prods.push(p);
        });

        // this.selectedLines = this.selectedProds;
    }

    setupTitEsec(){
        getTitEsec({ accountId : this.payload.opportunityData.AccountId })
            .then((result) => {
                result.titeff.forEach((t) => { t.valid = t.Contact.WGC_Censimento_MAV__c != "Parziale" });
                result.esec.forEach((e) => { e.valid = e.Contact.WGC_Censimento_MAV__c != "Parziale" });

                this.titolariEffettivi = result.titeff;
                this.esecutori = result.esec;
            })
    }

    setupMainWizardItems(){
        this.mainWizardItems.forEach((item) => {
            if(item.title == this.payload.opportunityData.StageName){
                if(this.payload.opportunityData.StageName != 'Vinta')
                    item.class += 'inProgress active';
                else
                    item.class += ' completed';
            }
        });

        let today = new Date();
        // let mainWizardProgressValue = 0;
        let millisecondUnit = (24 * 60 * 60 * 1000);

        if (this.payload.opportunityData) {
            let isLost = this.payload.opportunityData.StageName == "Persa";
            let phase = (this.payload.opportunityData.StageName == "Persa" ? this.payload.opportunityData.FaseDiCaduta__c : this.payload.opportunityData.StageName);
            let dateOut;
            let dateIn;
            this.mainWizardItems.forEach(mwi => {
                
                mwi.active = (phase == mwi.phase);
                mwi = this.manageMainWizardItemState(mwi, this.payload.opportunityData);

                switch (mwi.phase) {
                    case "In Lavorazione":
                    dateOut = (this.payload.opportunityData.StageName == mwi.phase ? today : (isLost ? new Date(this.payload.opportunityData.WGC_Data_Fase_Chiusa_Persa__c) : new Date(this.payload.opportunityData.WGC_Data_out_Fase_In_Istruttoria__c)));
                    dateIn = new Date(this.payload.opportunityData.WGC_Data_Fase_In_Istruttoria__c);
                    if (dateOut) mwi.phaseDuration = Math.floor(
                        (Date.UTC(dateOut.getFullYear(), dateOut.getMonth(), dateOut.getDate()) -
                        Date.UTC(dateIn.getFullYear(), dateIn.getMonth(), dateIn.getDate()))
                    ) / (millisecondUnit);
                    if (mwi.phaseDuration <= 0) mwi.phaseDuration = 1;
                    // console.log('@@@ lavorazione ' , mwi);
                    break;
                    case "Valutazione Pratica":
                        if (this.payload.opportunityData.WGC_Data_Fase_Valutazione_Pratica__c != null) {
                            dateOut = (this.payload.opportunityData.StageName == mwi.phase ? today : (isLost ? new Date(this.payload.opportunityData.WGC_Data_Fase_Chiusa_Persa__c) : new Date(this.payload.opportunityData.WGC_Data_out_Fase_Valutazione_Pratica__c)));
                            dateIn = new Date(this.payload.opportunityData.WGC_Data_Fase_Valutazione_Pratica__c);
                            if (dateOut) mwi.phaseDuration = Math.floor(
                                (Date.UTC(dateOut.getFullYear(), dateOut.getMonth(), dateOut.getDate()) -
                                Date.UTC(dateIn.getFullYear(), dateIn.getMonth(), dateIn.getDate()))
                            ) / (millisecondUnit);
                            if (mwi.phaseDuration <= 0) mwi.phaseDuration = 1;
                        }
                        break;
                    case "Perfezionamento Contratto":
                    if (this.payload.opportunityData.WGC_Data_Fase_Perfezionamento_Contratto__c != null) {
                        dateOut = (this.payload.opportunityData.StageName == mwi.phase ? today : (isLost ? new Date(this.payload.opportunityData.WGC_Data_Fase_Chiusa_Persa__c) : new Date(this.payload.opportunityData.WGC_Data_out_Perfezionamento_Contratto__c)));
                        dateIn = new Date(this.payload.opportunityData.WGC_Data_Fase_Perfezionamento_Contratto__c);
                        if (dateOut) mwi.phaseDuration = Math.floor(
                            (Date.UTC(dateOut.getFullYear(), dateOut.getMonth(), dateOut.getDate()) -
                            Date.UTC(dateIn.getFullYear(), dateIn.getMonth(), dateIn.getDate()))
                        ) / (millisecondUnit);
                        if (mwi.phaseDuration <= 0) mwi.phaseDuration = 1;
                    }
                    break;
                }
            });

            switch (this.payload.opportunityData.StageName) {
                case "Valutazione Pratica":
                this.mainWizProgress = 33;
                this.mainWizardItems.filter(mwi => {return mwi.phase == "In Lavorazione" || mwi.phase == "Valutazione Pratica";}).forEach(mwi => {mwi.clickable = true;});
                break
                case "Perfezionamento Contratto":
                    this.mainWizProgress = 67;
                    this.mainWizardItems.filter(mwi => {return mwi.phase == "In Lavorazione" || mwi.phase == "Valutazione Pratica" || mwi.phase == "Perfezionamento Contratto";}).forEach(mwi => {mwi.clickable = true;});
                    break;
                case "Attivazione":
                case "Vinta":
                case "Persa":
                    this.mainWizProgress = 100;
                    this.mainWizardItems.filter(mwi => {return mwi.phase == "In Lavorazione" || mwi.phase == "Valutazione Pratica" || mwi.phase == "Perfezionamento Contratto";}).forEach(mwi => {mwi.clickable = true;});
                    break;
                // case "Valutazione":
                break;
            }
        }

        //return mainWizardProgressValue;
    }

    setupStepWizard(){
        var p = this.payload;
        console.log('@@@ p.linee ' , JSON.stringify(p));
        if(p.opportunityData.WGC_Configurazione_Prodotti_Completa__c){
            this.stepWizard.forEach(s => {
                if(s.step == 'sceltaProdotto'){
                    s.completed = true;
                    s.class = s.class.includes('active') ? this.stepWizardClass.completed_active : this.stepWizardClass.completed;
                    s.completedIcon = 'utility:check';
                }
            });
        } else {
            this.stepWizard.forEach(s => {
                if(s.step == 'configuraProdotto'){
                    s.disabled = true;
                    s.class = this.stepWizardClass.disabled;
                }
            });
        }

        //console.log('@@@ controllo crediti ' , p.linee[0].crediti.filter(c => { return c.WGC_Invia_Credito__c }));
        let checkCrediti;
        if(p.linee.length > 0 && ( this.userInfo.Profile.Name == 'Amministratore del sistema' || this.userInfo.Profile.Name == 'IFIS - B/O Valutazione Fast Finance' )){
            checkCrediti = p.linee[0].crediti.filter(c => { return c.WGC_Invia_Credito__c && c.WGC_Completo_BO__c }).length > 0;
        } else if(p.linee.length > 0){
            checkCrediti = p.linee[0].crediti.filter(c => { return c.WGC_Invia_Credito__c && c.WGC_Completo_Commerciale__c }).length > 0;
        }
        
        if(p.opportunityData.WGC_Configurazione_Prodotti_Completa__c && p.linee.length > 0 && checkCrediti){
            this.stepWizard.forEach(s => {
                if(s.step == 'configuraProdotto'){
                    s.completed = true;
                    s.class = s.class.includes('active') ? this.stepWizardClass.completed_active : this.stepWizardClass.completed;
                    s.completedIcon = 'utility:check';
                }
            });
        } else if(p.opportunityData.WGC_Configurazione_Prodotti_Completa__c && p.linee.length > 0 && !checkCrediti){
            this.stepWizard.forEach(s => {
                if(s.step == 'configuraProdotto'){
                    s.completed = false;
                    s.class = s.class.includes('active') ? this.stepWizardClass.active : this.stepWizardClass.default;
                    s.completedIcon = '';
                }
            });
        }

        this.stepWizard.forEach(s => {
            if(s.step == 'documentazione'){
                if(p.opportunityData.WGC_Documenti_validi__c){
                    s.completed = true;
                    s.class = s.class.includes('active') ? this.stepWizardClass.completed_active : this.stepWizardClass.completed;
                    s.completedIcon = 'utility:check';
                } else {
                    s.completed = false;
                    s.class = s.class.includes('active') ? this.stepWizardClass.failed_active : this.stepWizardClass.failed;
                    s.completedIcon = '';
                }
            }
        });

        console.log('@@@ controllo note ' , p.opportunityData.Account.WGC_Descrizione_dell_azienda__c + ' -- ' + p.opportunityData.WGC_Descrizione_Operativit_Proposta__c);
        if(p.opportunityData.Account.WGC_Descrizione_dell_azienda__c != undefined && p.opportunityData.WGC_Descrizione_Operativit_Proposta__c != undefined){
            this.stepWizard.forEach(s => {
                if(s.step == 'note'){
                    s.completed = true;
                    s.class = s.class.includes('active') ? this.stepWizardClass.completed_active : this.stepWizardClass.completed;
                    s.completedIcon = 'utility:check';
                }
            });
        }

        // let checkDoc = this.querySelector('wgc_documents');
        // console.log('@@@ prova doc ' , checkDoc.checkDocs());
    }

    manageMainWizardItemState(mwi) {
        if (mwi.phase == this.payload.opportunityData.FaseDiCaduta__c){
            mwi.state = "failed";
            mwi.class += " failed";
        }else if (mwi.active){
            mwi.state = "inProgress";
            mwi.class += " inProgress";
        }else {
            switch (mwi.phase) {
                // case "Rinnovo":
                //     if (this.payload.opportunityData.Tipologia_Opportunit__c == "RINN" && (this.payload.opportunityData.WGC_Codice_Pratica__c != "" || this.payload.opportunityData.WGC_Codice_Pratica__c != null))
                //         mwi.state = "completed";
                // break;
                case "In Lavorazione":
                    console.log('@@@ this.payload.opportunityData.IdCartella__c ' , this.payload.opportunityData.WGC_Codice_Pratica__c);
                    if (this.payload.opportunityData.IdCartella__c || this.payload.opportunityData.StageName == 'Perfezionamento Contratto' || this.payload.opportunityData.StageName == 'Valutazione Pratica' || this.payload.opportunityData.StageName == 'Vinta'){
                        mwi.state = "completed";
                        mwi.class += ' completed';
                    }
                break;
                case "Valutazione Pratica":
                    if (this.payload.opportunityData.StageName == "Predisposizione Contratto" || this.payload.opportunityData.StageName == "Perfezionamento Contratto" || this.payload.opportunityData.StageName == "Vinta"){
                        mwi.state = "completed";
                        mwi.class += ' completed';
                    }
                break;
                case "Perfezionamento Contratto":
                    if (this.payload.opportunityData.StageName == "Vinta"){
                        mwi.state = "completed";
                        mwi.class += ' completed';
                    }
                break;
            }
        }

        return mwi;
    }

    ifOpeningOpportunityCheck(){
        checkOpenOpp({ opportunityId : this.recordId })
            .then((res) => {
                this.ifOpeningOpportunity = !res;
            });
    }

    checkReadOnly(){
        if(this.readOnlyParent !== true)
            this.readOnlyParent = this.payload.opportunityData.StageName != 'In Lavorazione'; 
    }

    checkIsClosable(){
        checkClosable( { opportunityId: this.recordId })
            .then((res) => {
                this.isClosable = !res;
            })
    }

    checkOwnership(){
        getOwnership( { opportunityId: this.recordId } )
            .then((res) => {
                this.readOnlyParent = !res;
            });
    }

    /* EVENT HANDLERS START */

    goBackToAccount(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.payload.opportunityData.AccountId,
                actionName: 'view',
            },
        });
    }

    handleClickStepWizard(event){
        this.showSpinner('');
        // this.setupProducts();
        if(event.target.value == 'sceltaProdotto'){
            this.reloadProd();
        } else if(event.target.value == 'configuraProdotto'){
            this.selectedLines.forEach(l => {
                l.selected = true;
            });
        }
        
        this.stepWizard.forEach((btn) => {
            if(btn.step == event.target.value){
                this.selectedStep = event.target.value;
                if(btn.completed)
                    btn.class = this.stepWizardClass.completed_active;
                else if(btn.failed)
                    btn.class = this.stepWizardClass.failed_active;
                else
                    btn.class = this.stepWizardClass.active;
            } else {
                if(btn.completed)
                    btn.class = this.stepWizardClass.completed;
                else if(btn.failed)
                    btn.class = this.stepWizardClass.failed;
                else
                    btn.class = btn.disabled ? this.stepWizardClass.disabled : this.stepWizardClass.default;
            }
        });
        /*
        this.stepWizard.forEach((btn) => {
            if(btn.step == event.target.value){ 
                if(!btn.class.includes('active')) btn.class += 'active';
                this.selectedStep = event.target.value;
            }
            else if(!btn.completed){
                btn.class = btn.defaultClass;
            }
        });
        */
        this.hideSpinner();

        // if(event.target.value == 'documentazione'){
        //     this.selectedStep = event.target.value;

        //     let checkDoc = this.template.querySelector('c-wgc_documents');
        //     while(checkDoc == null){
        //         console.log('@@@ not rendered');
        //     }
        //     console.log('@@@ prova doc ' , checkDoc.checkDocs());
        // }
    }
    
    clickMainWizardItem(event){
        let title = event.currentTarget.dataset.name;

        //if(this.payload.opportunityData.StageName != 'Persa'){
            if(title == 'In Lavorazione' && this.payload.opportunityData.StageName != 'In Lavorazione'){
                this.mainWizardItems.forEach(m => {
                    if(m.title == title){
                        m.state = "inProgress active";
                        m.class = m.class.includes('inProgress active') ? m.class : 'cstm-main-wizard-item  inProgress active';
                    } else {
                        m.class = 'cstm-main-wizard-item ';
                        m.state = "";
                    }

                    this.isVisibleTracker = false;
                    this.isVisible = true;
                    //this.stepWizardVisibility = true;
                    this.readOnly = true;
                });
            } else if(title != 'In Lavorazione' && this.payload.opportunityData.StageName != 'In Lavorazione'){
                this.mainWizardItems.forEach(m => {
                    if(m.title == title){
                        m.state = "inProgress active";
                        m.class = m.class.includes('inProgress active') ? m.class : 'cstm-main-wizard-item  inProgress active';
                    } else {
                        m.state = "";
                        m.class = 'cstm-main-wizard-item ';
                    }

                    this.isVisibleTracker = true;
                    this.isVisible = false;
                    //this.stepWizardVisibility = false;
                    this.readOnly = false;
                });
            }
        //}

        this.setupMainWizardItems();
    }

    closeOpp(event){
        this.cmpModalName = 'c-wgc_cart_close_opp';
        this.modalParams = { title : 'Chiudi Opportunità' };
        this.showModal = true;
    }

    // handleCloseModal(event){
    //     this.showModal = false;
    // }

    changeOwnerOpp(event){
        this.cmpModalName = 'c-wgc_cart_change_owner';
        this.modalParams = { title : 'Cambia Titolare Opportunità' };
        this.showModal = true;
    }

    handleModal(event){
        var detail = event.detail;
        console.log('@@@ detail modal ' , JSON.stringify(event.detail));
        if(detail.open){
            this.cmpModalName = detail.cmpName;
            this.modalParams = detail.params;
        } else if(!detail.open && detail.reload){
            this.showSpinner('');
            window.open(location, '_self', '');
        }

        this.showModal = detail.open;
    }

    onOpenOpportunityClick(event){
        this.showSpinner('');
        apriOpp({ opportunityId: this.recordId })
            .then(r => {
                this.hideSpinner('');
                window.open(location, '_self', '');
            })
            .catch(err => {
                console.log('@@@ err ' , err);
            });
    }

    suspendOpportunity(event){
        var msgSpinner = this.payload.opportunityData.WGC_Sospesa__c ? 'Ripresa Pratica...' : 'Sospensione Pratica...';
        this.showSpinner(msgSpinner);
        //Inverto il valore del camppo
        aggiornaCampo({ field: 'WGC_Sospesa__c', value: !this.payload.opportunityData.WGC_Sospesa__c, objectId: this.recordId }).then(result => {
            if(result != null && result != undefined)
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Errore',
                        message: result,
                        variant: 'error'
                    })
                )

            return getPayload({ opportunityId : this.recordId })
        }).then(result => {
            console.log('@@@ payload init ' , JSON.stringify(result));
            this.payload = result;
            this.recordTypeId = result.opportunityData.RecordType.Id;
            this.isVisible = result.opportunityData.StageName == 'In Lavorazione' /*|| result.opportunityData.StageName == 'Persa'*/;
            this.isVisibleTracker = result.opportunityData.StageName != 'In Lavorazione' && result.opportunityData.StageName != 'Persa';
            return getUserInfo();
        }).then(result => {
            this.userInfo = result;
            this.isCommerciale = result.Profile.Name != 'Amministratore del sistema' && result.Profile.Name != 'IFIS - B/O Valutazione Fast Finance';
        }).finally(() => {
            this.hideSpinner();
        }).catch(err => {
            console.log('@@@ error ' , err);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore',
                    message: 'Errore durante la sospensione della pratica, riprovare!',
                    variant: 'error'
                })
            )
            this.hideSpinner();
        })
    }

    removeProduct(event){
        var pp = {...event.detail};
        pp.selected = false;
        
        var selectedName = [];
        this.selectedProds = this.selectedProds.filter((p) => { 
            if(p.name != event.detail.name){
                selectedName.push(p.name);    
                return p;
            }
        });

        var available = [];
        this.allProducts.forEach((ap) => {
            if(!selectedName.includes(ap.name)){
                ap.selected = false;
                ap.removable = false;
                available.push(ap);
            }
        });

        this.prods = available;
        
        // this.stepWizard.forEach(s => {
        //     if(s.step == 'configuraProdotto'){
        //         s.disabled = true;
        //         s.class = this.stepWizardClass.disabled;
        //     }
        // });

    }

    selectProduct(event){
        var pp = {...event.detail};

        if(this.selectedProds.length == 1){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore',
                    message: 'Non è possibile vendere due prodotti nella stessa pratica',
                    variant: 'error'
                })
            );
        } else {
            if(!pp.selected){
                pp.selected = true;
                pp.removable = true;
                this.selectedProds.push(pp);

                var names = this.selectedProds.map((p) => {
                    return p.name;
                });

                this.prods = [];
                this.allProducts.forEach((p) => {
                    if(!names.includes(p.name)){
                        this.prods.push(p);
                    }
                });
            }

            // this.stepWizard.forEach(s => {
            //     if(s.step == 'configuraProdotto'){
            //         s.disabled = true;
            //         s.class = this.stepWizardClass.disabled;
            //     }
            // });
        }
    }

    handleChooseProd(event){
        this.selectedProds.forEach((p) => {
            if(p.name == event.detail.name){
                p.selected = true;
            } else {
                p.selected = false;
            }
        });
    }

    updateStepWizard(event){
        this.showSpinner('');

        if(event.detail.step == 'sceltaProdotto'){
            this.reloadProd();
            this.stepWizard.forEach(s => {
                if(s.step == event.detail.step){
                    s.class = this.stepWizardClass.completed_active;
                }
            });
        } else if(event.detail.step == 'inserimentoCed') {
            this.stepWizard.forEach(s => {
                if(s.step == 'sceltaProdotto'){
                    s.class = this.stepWizardClass.completed_active;
                } else if(s.step == 'configuraProdotto' && s.completed){
                    s.class = this.stepWizardClass.completed;
                    s.completedIcon = 'utility:check';
                } else if(s.step == 'configuraProdotto' && !s.completed){
                    s.class = this.stepWizardClass.default;
                    s.completedIcon = '';
                }
            });
        } else if(event.detail.step == 'configuraProdotto'){
            this.stepWizard.forEach((s) => {
                if(s.step == 'sceltaProdotto'){
                    s.completed = true;
                    s.class = this.stepWizardClass.completed;
                    s.completedIcon = 'utility:check';
                } else if(s.step == 'configuraProdotto'){
                    s.disabled = false;
                    s.class = this.stepWizardClass.active;
                }
            });
        } else if(event.detail.step == 'documentazione'){
            this.stepWizard.forEach(s => {
                if(s.step == event.detail.step){
                    s.class = this.stepWizardClass.failed_active;
                } else if(s.step == 'configuraProdotto'){
                    s.completed = true;
                    s.class = this.stepWizardClass.completed;
                    s.completedIcon = 'utility:check';
                }
            });
        } else if(event.detail.step == 'note'){
            this.stepWizard.forEach(s => {
                if(s.step == event.detail.step && s.completed){
                    s.completedIcon = 'utility:check';
                    s.class = this.stepWizardClass.completed_active;
                } else if(s.step == event.detail.step && !s.completed){
                    s.completedIcon = '';
                    s.class = this.stepWizardClass.failed_active;
                }
                    /*
                    s.completed = true;
                    s.completedIcon = 'utility:check';
                    if(this.selectedStep == event.detail.step){
                        s.class = this.stepWizardClass.completed_active;
                    } else {
                        s.class = this.stepWizardClass.completed;
                    }
                    
                }*/
            });
        }

        this.selectedStep = event.detail.step;
        this.hideSpinner();
    }

    handleCartCallServer(event){
        let method = event.detail.method;
        let methodName = event.detail.methodName;
        let params = event.detail.params;

        this.showSpinner('');
        method(params)
            .then((result) => {
                this.manageCallback(methodName, result);
                //this.connectedCallback();
                this.hideSpinner();
            })
            .catch((err) => {
                console.log('@@@ err ' , err);
            });
    }

    manageCallback(methodName, methodResult){
        switch (methodName){
            case 'salvaProdotti': {
                this.createAttoreDefault();
                this.confirmProd();
                this.selectedStep = 'inserimentoCed';
                break;
            }
            case 'configuraProdotto': {
                this.payload = methodResult.data[0];
                this.selectedStep = 'configuraProdotto';
                this.updateStepWizard({ detail : { step: 'configuraProdotto' }});
                break;
            }
            case 'reload':{
                this.connectedCallback();
                if(methodResult == null || ( methodResult.hasOwnProperty('success') && methodResult.success ) )
                    this.dispatchEvent(new ShowToastEvent({
                            title: 'SUCCESSO',
                            message: 'Salvataggio effettuato con successo',
                            variant: 'success'
                        })
                    );
                else 
                    this.dispatchEvent(new ShowToastEvent({
                            title: 'ERRORE',
                            message: methodResult.message,
                            variant: 'error'
                        })
                    );
                break;
            }
        }
    }

    createAttoreDefault(){
        creaAgenziaEntrate({ opportunityId: this.recordId })
            .then((r) => {
                if(r.success){
                    this.payload = r.data[0];
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            "title" : "ERRORE",
                            "message" : "Errore durante il salvataggio dell'attore di default",
                            "variant" : "error"
                        })
                    );
                }
            })
            .catch(err => {

            });
    }

    confirmProd(){
        this.selectedProds.forEach((p,ind) => {
            ind == 0 ? p.selected = true : p.selected = false;
            p.removable = false;
        });

        this.stepWizard.forEach(s => {
            if(s.step == 'configuraProdotto'){
                s.completedIcon = '';
                s.completed = false;
                s.class = this.stepWizardClass.default;
            } /*else if(s.step == 'documentazione'){
                s.completedIcon = '';
                s.completed = false;
                s.class = this.stepWizardClass.failed;
            }*/
        })

        this.selectedLines = this.selectedProds;
    }

    invioBO(event){
        this.showSpinner('Invio al B/O');
        aggiornaCampo({ field: 'WGC_Invio_Mail_FF__c', value: true, objectId: this.recordId })
            .then(result => {
                console.log('@@@ result ' , result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'SUCCESSO',
                        message: 'Pratica Inviata al B/O con successo',
                        variant: 'success'
                    })
                );
                window.open(location, '_self', '');
                this.readOnly = true;
                // this.readOnlyParent = true;
                this.hideSpinner();
        })
        .catch(err => {
            console.log('@@@ err ' , err);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore',
                    message: 'Errore durante l\'invio della pratica al B/O',
                    variant: 'error'
                })
            )
        });
    }

    invioTime(event){
        this.showSpinner('Verifica completezza anagrafica...')
        checkCensimentoAnag({ accountId: this.payload.opportunityData.AccountId }).then(result => {
            if(result == null){
                this.showSpinner('Verifica validità Titolari ed Esecutore...');
                return checkTitolariEsecutore({ accountId: this.payload.opportunityData.AccountId, opportunityId: this.payload.opportunityId });
            } else {
                throw 'Censire l\'anagrafica in maniera completa prima di inviare la pratica';
            }

        }).then(result => {
        // this.showSpinner('Verifica validità Titolari ed Esecutore...')
        // checkTitolariEsecutore({ accountId: this.payload.opportunityData.AccountId, opportunityId: this.payload.opportunityId }).then(result => {
            if(result != ''){
                this.hideSpinner();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title : 'ERRORE!',
                        message : labelErroreCarrello,
                        variant : 'warning'
                    })
                );
            } else {
                this.showSpinner('Verifica validità Privacy Esecutore...')
                return privacyEsecutoreFirmata({ accountId: this.payload.opportunityData.AccountId })
            }
        }).then(result => {
            if(result !== undefined){
                if(result == false){
                    //ERRORE
                    this.hideSpinner();
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title : 'ERRORE!',
                            message : labelErroreCarrello,
                            variant : 'warning'
                        })
                    );
                } else {
                    this.showSpinner('Controllo esistenza PEF...')
                    return esistePEF({ oppId: this.recordId });
                }
            }  
        }).then(result => {
            console.log('@@@ result pef ' , result);
            if(!result){
                //this.showSpinner('Invio Dati a TIME');
                this.showSpinner('Associazione responsabili in corso...');
				//A.M. Associazione a debitore per i concordati fallimentari e non all'Assuntore (titolare opportunità)
				console.log('@@@A.M. WGC_Assuntore__c: ' , this.payload.opportunityData.WGC_Assuntore__c);
				if (this.payload.opportunityData.WGC_Assuntore__c){
				   return associaResponsabili({ accountId: this.payload.opportunityData.WGC_Azienda_Cedente__c, opportunityRecordType: this.payload.opportunityData.RecordType.DeveloperName });
				}else{
                   return associaResponsabili({ accountId: this.payload.opportunityData.AccountId, opportunityRecordType: this.payload.opportunityData.RecordType.DeveloperName });
				}
            } else {
                this.hideSpinner();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title : 'ERRORE!',
                        message : esistePefLabel,
                        variant : 'error'
                    })
                );
            }
        }).then(result => {
                console.log('@@@ result ' , result);
                if(result != undefined){
                    if(result == ''){
                        this.showSpinner('Invio Dati a TIME...');
                        return invioTime({opportunityId: this.recordId, typeCall: 'pre' });
                        // console.log('@@@ payload ' , JSON.parse(result.data[0]).payload);                     
                    } else {
                        this.hideSpinner();
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title : 'ERRORE',
                                message : result,
                                variant : 'error'
                            })
                        );
                    }

                    this.hideSpinner();
                }
        }).then(r => {
            console.log('@@@ result pef41 ' , r);
            if(r != undefined){
                if(r.success){                        
                    this.showSpinner(labelInvioPEF);
                    return invioPEF41({ opportunityId: this.recordId });
                } else {
                    this.hideSpinner();
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title : 'ERRORE',
                            message : result.message,
                            variant : 'error'
                        })
                    );
                }
            }
        }).then(result => {
            if(result != undefined){
                if(result.success){
                    this.hideSpinner();
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title : 'SUCCESSO',
                            message : 'Pratica Inviata correttamente',
                            variant : 'success'
                        })
                    );
                    window.open(location, '_self', '');
                } else {
                    this.hideSpinner();
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title : 'ERRORE',
                            message : result.message,
                            variant : 'error'
                        })
                    );
                }
            }
        }).finally(() => {
            this.hideSpinner();
            window.open(location, '_self', '');
        })
        .catch(err => {
            console.log('@@@ err invio ' , err);
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'ERRORE',
                    message : err,
                    variant : 'error'
                })
            );
        });
    }

    checkDocuments(event){
        let checkDoc = this.template.querySelector('c-wgc_documents').checkDocs;
        console.log('@@@ prova doc ' , checkDoc);

        var steps = [...this.stepWizard];
        steps.forEach((btn) => {
            if(btn.step == 'documentazione'){
                // this.selectedStep = event.target.value;
                if(checkDoc){
                    btn.completed = true;
                    btn.completedIcon = 'utility:check';
                    btn.class = this.stepWizardClass.completed_active;
                } else if(!checkDoc){
                    // console.log('@@@ qua');
                    btn.completed = false;
                    btn.completedIcon = '';
                    btn.class = this.stepWizardClass.failed_active;
                }
            }
        });
        this.stepWizard = steps;

        aggiornaCampo({ field: 'WGC_Documenti_validi__c', value: checkDoc, objectId: this.recordId }).then(() => {

        }).catch(err => {
            console.log('@@@ err docs ' , err);
        });
    }

    showSpinner(msg){
        this.spinnerMessage = msg;
        this.loaded = false;
    }

    hideSpinner(){
        this.loaded = true;
    }

    get spinnerClass(){
        return !this.loaded ? 'spinnerWrapper' : 'spinnerWrapper slds-hide';
    }

    get isSuspended(){
        return !this.payload.opportunityData.WGC_Invio_Mail_FF__c || (this.payload.opportunityData.WGC_Invio_Mail_FF__c && this.isCommerciale);
    }

    get btnSuspendLabel(){
        return this.payload.opportunityData.WGC_Sospesa__c ? 'Riprendi' : 'Sospendi';
    }

    handleSpinner(event){
        if(event.detail.value == 'show'){
            this.showSpinner('');
        } else if(event.detail.value == 'hide'){
            this.hideSpinner();
        }
    }

    /* EVENT HANDLERS END */
}