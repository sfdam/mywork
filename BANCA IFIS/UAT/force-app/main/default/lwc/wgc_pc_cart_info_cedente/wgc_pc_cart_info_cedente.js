import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssCartPC from '@salesforce/resourceUrl/cssCartPC';
import wgc_pc_cart_info_cedente_ModificaDefaultBO from '@salesforce/label/c.wgc_pc_cart_info_cedente_ModificaDefaultBO';
// import templateCommerciale from './templateCommerciale.html';
// import templateBO from './templateBO.html';
// import save from '@salesforce/apex/WGC_PC_CartSECTION_FORMULA_VISIBILITYoller.saveSceltaProdotto';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDatiMaschera from '@salesforce/apex/WGC_PC_CartController.getDatiMascheraPC';
import getPicklistsVal from '@salesforce/apex/WGC_PC_CartController.getPicklists';

const FF_VISIBILITY = 'this.RecordType == "IFISOpportunitaFastFinance"';
const NOT_FISCALEBONIS_VISIBILITY = 'this.codProd != "FiscaleBonis"';
const FISCALEBONIS_VISIBILITY = 'this.codProd == "FiscaleBonis"';
const SECTION_FORMULA_VISIBILITY = 'this.userInfo.Profile.Name == "Amministratore del sistema" || this.userInfo.Profile.Name == "IFIS - B/O Valutazione Fast Finance"';
const REQUIRED_BOTH = 'this.userInfo.Profile.Name == "IFIS - Crediti Erariali" || this.userInfo.Profile.Name == "Amministratore del sistema" || this.userInfo.Profile.Name == "IFIS - B/O Valutazione Fast Finance"';
const REQUIRED_COMMERCIALE = 'this.userInfo.Profile.Name == "IFIS - Crediti Erariali"';
const REQUIRED_BO = '( this.userInfo.Profile.Name == "Amministratore del sistema" || this.userInfo.Profile.Name == "IFIS - B/O Valutazione Fast Finance" )';
const VISIBILITY_COMMERCIALE_CC = 'this.userInfo.Profile.Name == "IFIS - Sviluppo Commerciale Filiali"';
const FORMULA_READONLY = 'this.privateReadOnly == true';

export default class Wgc_pc_cart_info_cedente extends LightningElement {
    // @api
    // recordId;

    label = {
        modificaDefault: wgc_pc_cart_info_cedente_ModificaDefaultBO
    }

    @track
    privateReadOnly = false;

    @track
    privatePayload;

    @track
    privateUserInfo;

    @track
    privateDebitoreId;

    @track
    privateRecordId;

    @track
    privateIsCompleted = false;

    tipologia = [{ value: 'ALTRO' , label: 'ALTRO' },
    { value: 'CONC. FALL.RE' , label: 'CONC. FALL.RE' },
    { value: 'AMM.NE GIUDIZIARIA' , label: 'AMM.NE GIUDIZIARIA' },
    { value: 'FALL.TO' , label: 'FALL.TO' },
    { value: 'CONC.PREV.' , label: 'CONC.PREV.' },
    { value: 'LIQ. COATTA AMM.' , label: 'LIQ. COATTA AMM.' },
    { value: 'LIQ. VOL.' , label: 'LIQ. VOL.' },
    { value: 'LIQ. GIUD.' , label: 'LIQ. GIUD.' },
    { value: 'IN BONIS' , label: 'IN BONIS' },
    { value: 'ACCORDI 67/182BIS' , label: 'ACCORDI 67/182BIS' },
    { value: 'LIQ. GENERALE' , label: 'LIQ. GENERALE' },
    { value: 'ACCORDO RISTRUTT. DEB.' , label: 'ACCORDO RISTRUTT. DEB.' },
    { value: 'PERSONA FISICA' , label: 'PERSONA FISICA' }];

    @track
    fields_info_cedente = [ {label: 'Valutatore', apiName: 'WGC_Valutatore__c', type: 'lookup', /*formulaVisibility: REQUIRED_BOTH + ' || ' + VISIBILITY_COMMERCIALE_CC,*/ formulaVisibility: true, visibility: true, readOnly: FORMULA_READONLY, required: true, filter: '', objectName: 'User', icon: 'standard:user', title: '' },
                            {label: 'Assuntore', apiName: 'WGC_Assuntore__c', type: 'radio', formulaVisibility: NOT_FISCALEBONIS_VISIBILITY + ' && !(' + VISIBILITY_COMMERCIALE_CC +')', visibility: false, readOnly: FORMULA_READONLY, required: REQUIRED_BOTH},
                            // {label: 'Procedura', apiName: 'WGC_Azienda_Cedente__c', type: 'lookup', filter: "WHERE RecordType.DeveloperName != 'WGC_Tribunale'", objectName: 'Account', icon: 'standard:account', title: '', formulaVisibility: 'this.opp.WGC_Assuntore__c == "true" && ' + NOT_FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: REQUIRED_BOTH},
                            {label: 'Intermediario', apiName: 'Intermediario__c', type: 'lookup', objectName: 'Account', icon: 'standard:account', title: '', formulaVisibility: 'this.opp.WGC_Assuntore__c == "true" && ' + NOT_FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: false},
                            {label: 'Data proposta', apiName: 'WGC_Data_proposta__c', type: 'date', formulaVisibility: 'this.opp.WGC_Assuntore__c == "true" && ' + NOT_FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: false},
                            {label: 'Data omologa', apiName: 'WGC_Data_omologa_assuntore__c', type: 'date', formulaVisibility: 'this.opp.WGC_Assuntore__c == "true" && ' + NOT_FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: false},
                            {label: 'Data richiesta estratto di ruolo', apiName: 'WGC_Data_richiesta_estratto_di_ruolo__c', type: 'date', formulaVisibility: 'this.opp.WGC_Assuntore__c == "true" && ' + NOT_FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: false},
                            {label: 'Data evasione di ruolo', apiName: 'WGC_Data_evasione_di_ruolo__c', type: 'date', formulaVisibility: 'this.opp.WGC_Assuntore__c == "true" && ' + NOT_FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: false},
                            {label: 'Procedura', apiName: 'WGC_Azienda_Cedente__c', type: 'lookup', filter: "WHERE RecordType.DeveloperName != 'WGC_Tribunale'", objectName: 'Account', icon: 'standard:account', title: '', formulaVisibility: 'this.opp.WGC_Assuntore__c == "true" && ' + NOT_FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: REQUIRED_BOTH},
                            {label: 'Tipologia', apiName: 'WGC_Tipologia__c', type: 'picklist', formulaVisibility: NOT_FISCALEBONIS_VISIBILITY + ' && !(' + VISIBILITY_COMMERCIALE_CC +')', visibility: false, readOnly: FORMULA_READONLY, required: REQUIRED_BOTH, options: this.tipologia},
                            {label: 'Data ricorso', apiName: 'WGC_Data_ricorso__c', type: 'date', formulaVisibility: 'this.opp.WGC_Tipologia__c == "CONC.PREV." && ' + NOT_FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: REQUIRED_BO},
                            {label: 'Data ammissione', apiName: 'WGC_Data_ammissione__c', type: 'date', formulaVisibility: 'this.opp.WGC_Tipologia__c == "CONC.PREV." && ' + NOT_FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: REQUIRED_BO},
                            {label: 'Data omologa', apiName: 'WGC_Data_omologa__c', type: 'date', formulaVisibility: 'this.opp.WGC_Tipologia__c == "CONC.PREV." && ' + NOT_FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: false},
                            {label: 'Data ingresso in procedura', apiName: 'WGC_Data_ingresso_in_procedura__c', type: 'date', formulaVisibility: NOT_FISCALEBONIS_VISIBILITY + ' && !(' + VISIBILITY_COMMERCIALE_CC +') && this.opp.WGC_Tipologia__c != "CONC.PREV."', visibility: false, readOnly: FORMULA_READONLY, required: REQUIRED_BO},
                            //{label: 'Multiproprietà', apiName: 'WGC_Multiproprieta__c', type: 'radio', visibility: true, required: false},
                            //{label: '% suggerita di acquisto', apiName: 'WGC_Perc_suggerita_di_acquisto__c', type: 'number', formatter: 'percent-fixed', visibility: true},
                            {label: 'Ente sovrintendente', apiName: 'WGC_Ente_sovraintendente__c', type: 'lookup', /*filter: "WHERE RecordType.DeveloperName = 'WGC_Tribunale'",*/ objectName: 'Account', icon: 'standard:account', title: '', formulaVisibility: NOT_FISCALEBONIS_VISIBILITY + ' && !(' + VISIBILITY_COMMERCIALE_CC +')', visibility: false, readOnly: FORMULA_READONLY, required: REQUIRED_BOTH},
                            {label: 'Giudice delegato', apiName: 'WGC_Giudice_delegato__c', type: 'text', formulaVisibility: NOT_FISCALEBONIS_VISIBILITY + ' && !(' + VISIBILITY_COMMERCIALE_CC +')', visibility: false, readOnly: FORMULA_READONLY, required: false},
                            {label: 'Data cessazione Partita IVA', apiName: 'WGC_Data_Cessazione_PIVA__c', type: 'date', formulaVisibility: NOT_FISCALEBONIS_VISIBILITY + ' && !(' + VISIBILITY_COMMERCIALE_CC +')', visibility: false, readOnly: FORMULA_READONLY, required: false/*required: REQUIRED_BO*/},
                            //{label: 'Rischio Alto', apiName: 'WGC_Rischio_Alto__c', type: 'radio', formulaVisibility: '(' + SECTION_FORMULA_VISIBILITY + ') && ' + NOT_FISCALEBONIS_VISIBILITY, visibility: false, required: REQUIRED_BO},
                            {label: 'Data ingresso in liquidazione', apiName: 'WGC_Data_messa_in_Liquidazione__c', type: 'date', formulaVisibility: FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: false/*REQUIRED_BO*/},
                            {label: 'Liti pendenti', apiName: 'WGC_Liti_pendenti__c', type: 'radio', formulaVisibility: FF_VISIBILITY, visibility: true, readOnly: FORMULA_READONLY, required: REQUIRED_BOTH},
                            {label: 'Descrizioni liti pendenti', apiName: 'WGC_Descrizione_liti_pendenti__c', type: 'text', formulaVisibility: 'this.opp.WGC_Liti_pendenti__c == "true"', visibility: false, readOnly: FORMULA_READONLY, required: false},
                            {label: 'Num. riparti effettuati', apiName: 'WGC_Num_Riparti_effettuati__c', type: 'number', /*step: '1',*/ formulaVisibility: FF_VISIBILITY + ' && ' + NOT_FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: false},
                             {label: 'Num. creditori', apiName: 'WGC_Num_Creditori__c', type: 'number', /*step: '1',*/ formulaVisibility: FF_VISIBILITY + ' && ' + NOT_FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: false},
                             {label: 'Data ultimo riparto', apiName: 'WGC_Data_ultimo_riparto__c', type: 'date', formulaVisibility: FF_VISIBILITY + ' && ' + NOT_FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: false},
                             {label: 'Ulteriori attivi da realizzare', apiName: 'WGC_Ulteriori_attivi_da_realizzare__c', type: 'number', /*step: '1',*/ formulaVisibility: FF_VISIBILITY + ' && ' + NOT_FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: false},
                             {label: 'Data presunta decreto chiusura', apiName: 'WGC_Data_presunta_decreto_chiusura__c', type: 'date', formulaVisibility: FF_VISIBILITY + ' && ' + NOT_FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: true},
                            //CAMPI SOLO PER FISCALE BONIS
                            {label: 'Ristrutturazione del debito', apiName: 'WGC_Ristrutturazione_del_debito__c', type: 'radio', formulaVisibility: FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: REQUIRED_BO},
                            {label: 'Tipologia di ristrutturazione debito', apiName: 'WGC_Tipologia_di_ristrutturazione_debito__c', type: 'picklist', formulaVisibility: 'this.opp.WGC_Ristrutturazione_del_debito__c == "true" && ' + FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: REQUIRED_BO},
                            /*
                            {label: 'Liti pendenti', apiName: 'WGC_Liti_pendenti__c', type: 'radio', visibility: true, required: REQUIRED_BOTH},
                            {label: 'Descrizioni liti pendenti', apiName: 'WGC_Descrizione_liti_pendenti__c', type: 'text', formulaVisibility: 'this.opp.WGC_Liti_pendenti__c == "true"', visibility: false, required: false},
                            {label: 'Num. riparti effettuati', apiName: 'WGC_Num_Riparti_effettuati__c', type: 'number', visibility: true},
                            {label: 'Num. creditori', apiName: 'WGC_Num_Creditori__c', type: 'number', visibility: true},
                            {label: 'Data ultimo riparto', apiName: 'WGC_Data_ultimo_riparto__c', type: 'date', visibility: true},
                            {label: 'Ulteriori attivi da realizzare', apiName: 'WGC_Ulteriori_attivi_da_realizzare__c', type: 'number', visibility: true},
                            {label: 'Data presunta decreto chiusura', apiName: 'WGC_Data_presunta_decreto_chiusura__c', type: 'date', visibility: true}
                            */
                        ];

    @track
    fields_consecutivita = [ {label: 'Consecutività', apiName: 'WGC_Consecutivita__c', type: 'radio', formulaVisibility: SECTION_FORMULA_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: REQUIRED_BO},
                             {label: 'Tipologia consecutività', apiName: 'WGC_Tipologia_di_consecutivita__c', type: 'picklist', formulaVisibility: 'this.opp.WGC_Consecutivita__c == "true"', visibility: false, readOnly: FORMULA_READONLY, required: REQUIRED_BO, options: this.tipologia },
                             {label: 'Data ricorso', apiName: 'WGC_Data_ricorso_consecutivit__c', type: 'date', formulaVisibility: 'this.opp.WGC_Consecutivita__c == "true"', visibility: false, readOnly: FORMULA_READONLY, required: '!( ' + FF_VISIBILITY + ') && ' + REQUIRED_BO },
                             //Data ingresso in liquidazione
                             /*
                             {label: 'Data ingresso in liquidazione', apiName: 'WGC_Data_messa_in_Liquidazione__c', type: 'date', formulaVisibility: FISCALEBONIS_VISIBILITY, visibility: false, required: REQUIRED_BO},
                             {label: 'Liti pendenti', apiName: 'WGC_Liti_pendenti__c', type: 'radio', formulaVisibility: FF_VISIBILITY, visibility: true, required: REQUIRED_BOTH},
                             {label: 'Descrizioni liti pendenti', apiName: 'WGC_Descrizione_liti_pendenti__c', type: 'text', formulaVisibility: 'this.opp.WGC_Liti_pendenti__c == "true"', visibility: false, required: false},
                             */
                             
                             {label: 'AeR - Estratto di ruolo', apiName: 'WGC_AeR_Estratto_di_ruolo__c', type: 'picklist', formulaVisibility: '(' + SECTION_FORMULA_VISIBILITY + ') && ' + NOT_FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: true},
                             {label: 'AdE – Carichi pendenti', apiName: 'WGC_AdE_Carichi_pendenti__c', type: 'lookup', filter: "", objectName: 'WGC_AdE_Territoriale__c', icon: 'custom:custom16', title: '', formulaVisibility: '(' + SECTION_FORMULA_VISIBILITY + ') && ' + NOT_FISCALEBONIS_VISIBILITY, visibility: false, readOnly: FORMULA_READONLY, required: true},
                             {label: 'Multiproprietà', apiName: 'WGC_Multiproprieta__c', type: 'radio', formulaVisibility: 'this.RecordType != "IFISOpportunitaFastFinance"', visibility: false, readOnly: FORMULA_READONLY, required: false}
                            ];
    
    @track
    fields_rischio = [
                        {label: 'Rischio Alto', apiName: 'WGC_Rischio_Alto__c', type: 'radio', formulaVisibility: '(' + SECTION_FORMULA_VISIBILITY + ') && ' + NOT_FISCALEBONIS_VISIBILITY + ' && this.codProd != ""', visibility: false, readOnly: FORMULA_READONLY, required: REQUIRED_BO},
                    ];

    @track
    fields_valutatore = [ 
                        {label: 'Valutatore', apiName: 'WGC_Valutatore__c', type: 'lookup', /*formulaVisibility: REQUIRED_BOTH + ' || ' + VISIBILITY_COMMERCIALE_CC,*/ visibility: true, readOnly: FORMULA_READONLY, required: true, filter: '', objectName: 'User', icon: 'standard:user', title: '' }
                        ];

    @track
    sections = [
                //SEZIONE FAKE SOLO PER IN BONIS
                { label: 'Info Cedente', fields: this.fields_valutatore, isVisibleFRM: '!(' + FF_VISIBILITY + ' || ' + VISIBILITY_COMMERCIALE_CC + ')', isVisible: false}, 
                { label: 'Info Cedente' , fields: this.fields_info_cedente, isVisibleFRM: FF_VISIBILITY + ' || ' + VISIBILITY_COMMERCIALE_CC, isVisible: false},
                { label: 'Rischio', fields: this.fields_rischio, isVisibleFRM: '(' + SECTION_FORMULA_VISIBILITY + ') && ' + NOT_FISCALEBONIS_VISIBILITY + ' && this.codProd != "" && this.codProd != undefined', isVisible: false},
                    /*{ label: 'Consecutività', fields: this.fields_consecutivita, isVisible: SECTION_FORMULA_VISIBILITY }*/
                { label: 'Consecutività', fields: this.fields_consecutivita, isVisibleFRM: SECTION_FORMULA_VISIBILITY, isVisible: false } ];

    @track
    selectedProds;

    @api
    agenzia = {}; //{ Account__r: { Name: 'AGENZIA DELLE ENTRATE'} };

    @api
    opp = {};

    @track
    codProd;

    @track _isFiscaleBonis = false;

    _readOnlyNotifica = false;

    _readOnlyLineaGarantita = false;

    @track
    rendered = false;

    connectedCallback(){
        loadStyle(this, cssCartPC);
        let fields = new Array('WGC_Tipologia__c','WGC_Tipologia_di_consecutivita__c','WGC_AeR_Estratto_di_ruolo__c', 'WGC_Tipologia_di_ristrutturazione_debito__c');
        getPicklistsVal({ sobj: 'Opportunity', fieldsApiName: fields })
            .then(result => {
                result.data.forEach(r => {
                    this.sections.forEach(s => {
                        s.fields.forEach(f => {
                            if(r.fieldName == f.apiName){
                                f.options = r.listaValori;
                            }
                        });
                    });
                });
        })
        .catch(err => {
        console.log('@@@ err ' , err);
        });
    }

    renderedCallback(){
        if(this.privateUserInfo != undefined && this.opp != undefined && window.RecordType != undefined && window.privateReadOnly != undefined)
            this.setupSectionsAndFields();
    }

    /* GETTER & SETTER */

    get options(){
        return [ { label: "Si", value: 'true' }, { label: "No", value: 'false' } ];
    }

    /*
    @api
    get payload(){
        return this.privatePayload;
    }

    set payload(p){
        this.privatePayload = p;
        window.privatePayload = this.privatePayload;
        window.RecordType = this.privatePayload.opportunityData.RecordType.DeveloperName;

        console.log('@@@ this.privateDebitoreId ' , this.privateDebitoreId);
        if(this.privateDebitoriId != undefined)
            this.getMaschera();
    }
    */

    @api
    get userInfo(){
        return this.privateUserInfo;
    }

    set userInfo(u){
        window.userInfo = u;
        this.privateUserInfo = u;
        if(/*this.privateDebitoriId != undefined &&*/ this.recordId != undefined)
            this.getMaschera();
    }

    @api
    get debitoreId(){
        return this.privateDebitoreId;
    }

    set debitoreId(i){
        this.privateDebitoreId = i;
        if(/*this.privateDebitoreId != undefined &&*/ this.recordId != undefined)
            this.getMaschera();
    }

    @api
    get pReadOnly(){
        return this.privateReadOnly;
    }

    set pReadOnly(r){
        this.privateReadOnly = r;
        window.privateReadOnly = r;
    }

    @api
    get readOnlyNotifica(){
        if(this.pReadOnly)
            return this.pReadOnly;
        else
            return this._readOnlyNotifica;
    }

    set readOnlyNotifica(v){
        return this._readOnlyNotifica = v;
    }

    @api
    get readOnlyLineaGarantita(){
        if(this.pReadOnly)
            return this.pReadOnly;
        else
            return this._readOnlyLineaGarantita;
    }

    set readOnlyLineaGarantita(v){
        this._readOnlyLineaGarantita = v;
    }

    @api
    get recordId(){
        return this.privateRecordId;
    }

    set recordId(r){
        this.privateRecordId = r;
        if(/*this.privateDebitoreId != undefined &&*/ this.recordId != undefined)
            this.getMaschera();
    }

    @api
    get isCompleted(){
        return this.privateIsCompleted;
    }

    set isCompleted(v){
        this.privateIsCompleted = v;
    }

    @api
    get prod(){
        return this.codProd;
    }

    set prod(p){
        this.codProd = p;
        window.codProd = p != undefined ? p : '';
        if(this.codProd == 'FiscaleBonis')
            this._isFiscaleBonis = true;
    }

    get isFiscaleBonis(){
        return this._isFiscaleBonis;
    }

    get notProceduraConcorsuale(){
        if(window.RecordType != undefined)
            return window.RecordType != 'IFISOpportunitaFastFinance';
        else
            return false;
    }

    get isCommercialeFactoring(){
        return this.userInfo.Profile.Name == 'IFIS - Sviluppo Commerciale Filiali';
    }

    /* GETTER & SETTER */

    /* FUNCTIONS */

    getMaschera(){
        //this.rendered = false;
        getDatiMaschera({ opportunityId: this.recordId })
            .then((res) => {
                //this.rendered = false;
                console.log('@@@ res ' , JSON.stringify(res));
                //this.dispatchEvent(new CustomEvent('spinnerevt', { bubbles: true, composed: true, detail : { value: "show" } } ));
                if(res.success){
                    window.RecordType = res.data[0].opp.RecordType.DeveloperName;
                    this.agenzia = res.data[0].attore;
                    this.agenzia.WGC_Storicita_Rimborsi__c = res.data[0].attore.WGC_Storicita_Rimborsi__c.toString();

                    if(this.notProceduraConcorsuale)
                        this.agenzia.ANotifica__c = res.data[0].attore.ANotifica__c.toString();

                    // SM - CR Ottobre 21
                    if(!this.notProceduraConcorsuale && this.userInfo.Profile.Name == 'IFIS - Crediti Erariali'){
                        this.agenzia.ANotifica__c = 'true';
                        this.readOnlyNotifica = true;
                    }

                    // SM - CR Ottobre 21
                    if(!this.notProceduraConcorsuale && this.userInfo.Profile.Name == 'IFIS - Crediti Erariali'){
                        this.agenzia.Linea_Garantita__c = 'true';
                        this.readOnlyLineaGarantita = true;
                    }

                    // SM - CR Ottobre 21
                    if(!this.notProceduraConcorsuale && this.userInfo.Profile.Name == 'IFIS - B/O Valutazione Fast Finance'){
                        this.agenzia.ANotifica__c = res.data[0].attore.ANotifica__c.toString();
                        this.agenzia.Linea_Garantita__c = res.data[0].attore.Linea_Garantita__c.toString();
                    }

                    this.opp = res.data[0].opp;
                    window.opp = res.data[0].opp;

                    // SM - CR Ottobre 21
                    if(this.userInfo.Profile.Name == 'IFIS - B/O Valutazione Fast Finance' && this.isFiscaleBonis){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                message: this.label.modificaDefault,
                                variant: 'info'
                            })
                        )
                    }
                } else {
                    this.getMaschera();
                }
            })
            .finally(() => {
                this.setupSectionsAndFields();
                this.rendered = true;
                console.log('@@@ isCompleted init ' , this.isCompleted);
                this.dispatchEvent(
                    new CustomEvent('infocedenterender', { detail : { value: this.isCompleted }})
                )
                //this.dispatchEvent(new CustomEvent('changefieldval', { detail: { value: this.checkCompletedFields() }}));
                //this.dispatchEvent(new CustomEvent('spinnerevt', { bubbles: true, composed: true, detail : { value: "hide" } } ));
            })
            .catch((err) => {
                console.log('@@@ err ' , err);
                /*
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Errore',
                        message: err.message,
                        variant: 'error'
                    })
                )
                */

                //this.getMaschera();
            });
    }

    setupSectionsAndFields(){
        window.opp = this.opp;
        this.sections.forEach(s => {
            if(s.hasOwnProperty('isVisibleFRM')){
                s.isVisible = eval(s.isVisibleFRM);
            }

            if(s.isVisible){
                s.fields.forEach(f => {
                    //if(this.opp.hasOwnProperty(f.apiName)){
                        if(f.hasOwnProperty('formulaVisibility')){
                            var visibilityValue = eval(f.formulaVisibility);
                            f.visibility = visibilityValue;
                        }

                        f.value = this.opp[f.apiName] == true && this.opp[f.apiName].toString() != "1" ? "true" : this.opp[f.apiName] == false && this.opp[f.apiName].toString() != "0" && this.opp[f.apiName].toString() != "" ? "false" : this.opp[f.apiName] == null ? null : this.opp[f.apiName];
                        this.opp[f.apiName] = this.opp[f.apiName] == true && this.opp[f.apiName].toString() != "1" ? "true" : this.opp[f.apiName] == false && this.opp[f.apiName].toString() != "0" && this.opp[f.apiName].toString() != "" ? "false" : this.opp[f.apiName] == null ? null : this.opp[f.apiName];

                        //Gestione della prevalorizzazione delle lookup
                        if(f.type == 'lookup'){
                            let apiNameTitle = f.apiName.substring(0, f.apiName.length-1) + 'r';
                            if(this.opp.hasOwnProperty(apiNameTitle))
                                f.title = this.opp[apiNameTitle].Name;
                        }
                        
                        if(f.hasOwnProperty('readOnly')){
                            f.readOnly = eval(f.readOnly);
                        }
                    //}
                });
            } else {
                s.fields.forEach(f => {
                    f.visibility = false;
                });
            }
        });

        //Check completezza dei dati
        this.privateIsCompleted = this.checkCompletedFields();
    }

    updateAttore(event){
        let apiName = event.target.name;
        this.agenzia[apiName] = event.detail.value;
        this.dispatchEvent(new CustomEvent('changefieldval'));
    }

    updateField(event){
        let fieldChanged = event.detail;
        let opp = {...this.opp};

        opp[fieldChanged.apiName] = fieldChanged.value == true && fieldChanged.value.toString() != "1" ? "true" : fieldChanged.value == false && fieldChanged.value.toString() != "0" && fieldChanged.value.toString() != "" ? "false" : fieldChanged.value == null ? null : fieldChanged.value;
        this.opp = opp;

        let sections = [...this.sections];
        sections.forEach(s => {
            s.fields = [...s.fields];
            s.fields.forEach(f => {
                if(f.apiName == fieldChanged.apiName){
                    f.value = fieldChanged.value == true && fieldChanged.value.toString() != "1" ? "true" : fieldChanged.value == false && fieldChanged.value.toString() != "0" && fieldChanged.value.toString() != "" ? "false" : fieldChanged.value == null ? null : fieldChanged.value;
                }
            });
        });

        this.sections = sections;
        //Check completezza dei dati
        this.privateIsCompleted = this.checkCompletedFields();
        this.setupSectionsAndFields(); 
        this.dispatchEvent(new CustomEvent('changefieldval'));
    }

    checkCompletedFields(){
        let allFields = [];

        this.sections.forEach(s => {
            if(s.isVisible)
                allFields = allFields.concat(s.fields);
        });

        let check = allFields.reduce((start, f) => {
            if(eval(f.required)){ 
                if(!f.visibility){
                    return start;
                } else { 
                    if(f.type == 'number')
                        return ( start && !Number.isNaN(f.value));
                    else{
                        return ( start && f.value != undefined && f.value != '' && f.value != null )
                    }
                }
            } else {
                return start;
            }
        }, true);
        return check;
    }

    @api
    confirm(){
        this.sections.forEach(s => { 
            if(s.isVisible){
                s.fields.forEach((f) => {
                    if(!f.visibility){
                        f.value = f.type == 'radio' ? false : null;
                        this.opp[f.apiName] = f.type == 'radio' ? false : null;
                        if(f.type == 'lookup'){
                            f.title = '';
                        }
                    }
                });
            }
        });
        console.log('@@@ opp ' , JSON.stringify(this.opp));
        console.log('@@@ agenzia ' , JSON.stringify(this.agenzia));

        // SM - CR Ottobre 21
        // if(!this.notProceduraConcorsuale)
        //     this.agenzia.ANotifica__c = false;

        console.log('@@@ completed ' , this.checkCompletedFields());
        console.log('@@@ completed ' , this.isCompleted);

        let wrapper = { attore: this.agenzia, opp: this.opp};
        return wrapper;
    }

    /* EVENT HANDLERS */
}