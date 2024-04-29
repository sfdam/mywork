import { LightningElement, api, track, wire } from 'lwc';
import getPicklistsVal from '@salesforce/apex/WGC_PC_CartController.getPicklists';
import getDatiIrr from '@salesforce/apex/WGC_PC_CartController.getDatiIRR';
import saveCredito from '@salesforce/apex/WGC_PC_CartController.saveSingleCredito';
import CREDITO_OBJECT from '@salesforce/schema/Credito__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import UNITA_LOCALE from '@salesforce/schema/Credito__c.WGC_Unita_Locale__c';
import CONTRATTO_UNITA_LOCALE from '@salesforce/schema/Credito__c.WGC_Contratto_unita_locale__c';
import calcolaInteressi from '@salesforce/apex/WGC_PC_CartController.callCalcolaInteressi';
import calcolaCompensi from '@salesforce/apex/WGC_PC_CartController.callCalcolaCompensi';
import getDatiCostoNotaio from '@salesforce/apex/WGC_PC_CartController.getDatiCostoNotaio';

const FORMULA_VISIBILITY_BO_FIELDS = '( this.privateUserInfo.Profile.Name == "Amministratore del sistema" || this.privateUserInfo.Profile.Name == "System Administrator" || this.privateUserInfo.Profile.Name == "IFIS - B/O Valutazione Fast Finance" )';
const FORMULA_VISIBILITY_COMMERCIALE = 'this.privateUserInfo.Profile.Name == "IFIS - Crediti Erariali"';
const NOT_FORMULA_VISIBILIY_COMERCIALE_CC = 'this.privateUserInfo.Profile.Name != "IFIS - Sviluppo Commerciale Filiali"';
const FORMULA_READONLY = 'this.privateReadOnly == true';
const FF_VISIBILITY = 'this.recordType.DeveloperName == "IFISOpportunitaFastFinance"';
const FORMULA_INBONIS = '( this.recordType.DeveloperName == "WGC_IFIS_Oppotunita_Crediti_Erariali" || this.recordType.DeveloperName == "IFISOpportunitaFactoring" ) ';
const FORMULA_ATD_FISCALE = 'this.privateCodProd == "ATDFiscale"';
const FORMULA_ATD_FISCALE_NOTNOT = 'this.privateCodProd == "ATDFiscaleNotNot"'; 
const FORMULA_FACTORING_FISCALE_NOTNOT = 'this.privateCodProd == "FactoringOrdinarioFiscaleNotNot"';
const FORMULA_FACTORING_FISCALE = 'this.privateCodProd == "FactoringOrdinarioFiscale"';
const FORMULA_FISCALE_BONIS = 'this.privateCodProd == "FiscaleBonis"';
//const formulaInizioMaturazioneOLD = 'this.state.Imposta__c == "36" || this.state.Imposta__c == "39" || this.state.Imposta__c == "3721" ? ( this.state.WGC_Data_richiesta_rimborso__c != undefined ? new Date( new Date(this.state.WGC_Data_richiesta_rimborso__c).setDate( new Date(this.state.WGC_Data_richiesta_rimborso__c).getDate() + this.state.WGC_Gg_Maturazione_Interessi__c ) ).toISOString().split("T")[0] : this.state.WGC_Data_rimborso_presunto__c != undefined ? new Date( new Date(this.state.WGC_Data_rimborso_presunto__c).setDate( new Date(this.state.WGC_Data_rimborso_presunto__c).getDate() + this.state.WGC_Gg_Maturazione_Interessi__c ) ).toISOString().split("T")[0] : new Date( new Date(this.state.WGC_Data_presentazione_rimborso__c).setDate( new Date(this.state.WGC_Data_presentazione_rimborso__c).getDate() + this.state.WGC_Gg_Maturazione_Interessi__c ) ).toISOString().split("T")[0]) : ( this.state.WGC_Data_richiesta_rimborso__c != undefined ? new Date( new Date(this.state.WGC_Data_richiesta_rimborso__c).setDate( new Date(this.state.WGC_Data_richiesta_rimborso__c).getDate() + this.state.WGC_Gg_Maturazione_Interessi__c ) ).toISOString().split("T")[0] : this.state.WGC_Data_rimborso_presunto__c != undefined ? new Date( new Date(this.state.WGC_Data_rimborso_presunto__c).setDate( new Date(this.state.WGC_Data_rimborso_presunto__c).getDate() + this.state.WGC_Gg_Maturazione_Interessi__c ) ).toISOString().split("T")[0] : new Date( new Date(this.state.WGC_Data_presentazione_rimborso__c).setDate( new Date(this.state.WGC_Data_presentazione_rimborso__c).getDate() + this.state.WGC_Gg_Maturazione_Interessi__c ) ).toISOString().split("T")[0] )';

const formulaInizioMaturazione = 'this.state.WGC_Data_richiesta_rimborso__c != undefined && this.state.WGC_Gg_Maturazione_Interessi__c != undefined ? new Date( new Date(this.state.WGC_Data_richiesta_rimborso__c).setDate( new Date(this.state.WGC_Data_richiesta_rimborso__c).getDate() + this.state.WGC_Gg_Maturazione_Interessi__c  ) ).toISOString().split("T")[0] : (this.state.WGC_Data_rimborso_presunto__c != undefined && this.state.WGC_Gg_Maturazione_Interessi__c != undefined ? new Date( new Date(this.state.WGC_Data_rimborso_presunto__c).setDate( new Date(this.state.WGC_Data_rimborso_presunto__c).getDate() + this.state.WGC_Gg_Maturazione_Interessi__c  ) ).toISOString().split("T")[0] : (this.state.WGC_Data_presentazione_rimborso__c != undefined && this.state.WGC_Gg_Maturazione_Interessi__c != undefined ? new Date( new Date(this.state.WGC_Data_presentazione_rimborso__c).setDate( new Date(this.state.WGC_Data_presentazione_rimborso__c).getDate() + this.state.WGC_Gg_Maturazione_Interessi__c  ) ).toISOString().split("T")[0] : undefined))';

export default class Wgc_pc_cart_credito extends LightningElement {

    @track
    creditoInfo;

    @wire(getObjectInfo, { objectApiName: CREDITO_OBJECT })
    creditoInfo
    
    @track
    unitaLocale;
    @track
    contrattoUnitaLocale;

   
    //recordTypeId: '012000000000000AAA'
    @wire(getPicklistValues, { recordTypeId: '$creditoInfo.data.defaultRecordTypeId', fieldApiName: UNITA_LOCALE })
    unitaLocaleInfo({ error, data }) {
        if (data) { 
            this.unitaLocale = data;
            this.sections.forEach(s => {
                s.fields.forEach(f => {
                    if(f.apiName == 'WGC_Unita_Locale__c'){
                        f.options = data.values;
                    }
                });
            });
        }
    }
    
    
    @wire(getPicklistValues, { recordTypeId: '$creditoInfo.data.defaultRecordTypeId', fieldApiName: CONTRATTO_UNITA_LOCALE })
    contrattoUnitaLocaleInfo({ error, data }) {
        if (data) {
            this.contrattoUnitaLocale = data;
            var valUnita;
            this.sections.forEach(s => {
                s.fields.forEach(f => {
                    if(f.apiName == 'WGC_Unita_Locale__c'){
                        valUnita = f.value;
                    }
                    if(f.apiName == 'WGC_Contratto_unita_locale__c'){
                        f.options = data.values;
                        let key = this.contrattoUnitaLocale.controllerValues[valUnita];
                        this.sections.forEach(s => {
                            s.fields.forEach(f => {
                                if(f.apiName == CONTRATTO_UNITA_LOCALE.fieldApiName){
                                    f.options = this.contrattoUnitaLocale.values.filter(opt => { return opt.validFor.includes(key) });
                                }
                            });
                        });
                    }
                });
            });
        }
    }

    @track _costoNotaioFormula;
    @wire(getDatiCostoNotaio, {})
    costoNotaioFunction({ error, data }){
        if(data){
            console.log('@@@ formula');
            this._costoNotaioFormula = data.data[0].Default_Value__c;
            this.fields_quantitative.find(f => { return f.apiName == 'WGC_Costo_notaio__c'}).defaultVal = 'this.state.WGC_Modifica_Costo_Notaio__c == "false" || this.state.WGC_Modifica_Costo_Notaio__c == undefined ? (' +this._costoNotaioFormula + ') : this.state.WGC_Costo_notaio__c ';
            this.setupData();     
        }
        if(error){
            console.log('@@@ error ' , error.body.message);
        }
    }

    @track
    state;

    @api
    recordId;

    @api
    privateRecordType;

    @track
    privateUserInfo;

    @track
    rendered = false;

    @track
    showModal = false;

    @track
    privateReadOnly = false;

    @track
    datiIrr = {};

    //{ label: 'Invia', apiName: 'selected', type: 'checkbox', value: false, visibility: true },

    //@track
    privateIsCompleted = false;

    //Modal Params
    cmpModal;
    modalParams;

    @track
    fields_qualitative = [ { label: 'Imposta', apiName: 'Imposta__c', type: 'picklist', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY, visibility: false, required: /*true*/ 'this.state.WGC_Escludi_IRR__c == "false"', options: [{ label: 'IVA', value: 'IVA' }, { label: 'IRES', value: 'IRES' }, { label: 'IRAP', value: 'IRAP' }, { label: 'IRESxIRAP', value: 'IRESxIRAP' }, { label: 'IRPEF', value: 'IRPEF' }, { label: 'IRPEG', value: 'IRPEG' }, { label: 'Commerciali', value: 'Commerciali' }, { label: 'Altro', value: 'Altro' }] },
                            { label: 'Origine', apiName: 'WGC_Origine__c', type: 'picklist', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY, visibility: false, required: true, options: [ { label: 'Ante', value: 'cmpModal1'}, { label: 'Post', value: '2'}, { label: 'Ante-Post', value: '3'} ] },
                            { label: 'Annualità Imposta', apiName: 'WGC_Annualita_imposta__c', type: 'text', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY, visibility: false, required: true },
                            { label: 'Anno', apiName: 'WGC_Anno__c', type: 'text', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FORMULA_INBONIS, visibility: false, required: true },
                            //INBONIS
                            { label: 'Tipo rimborso', apiName: 'WGC_Tipo_rimborso__c', type: 'picklist', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FORMULA_INBONIS, visibility: false, required: true},
                            { label: 'Modalità di offerta', apiName: 'WGC_Modalita_di_offerta__c', type: 'picklist', value: 'MDI', /*defaultVal: '(' + FORMULA_INBONIS + ' && this.state.WGC_Modalita_di_offerta__c != undefined ) ? "MDI" : this.state.WGC_Modalita_di_offerta__c',*/ frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FORMULA_INBONIS, visibility: false, required: FORMULA_VISIBILITY_BO_FIELDS,  options: [ { label: 'ALTRO' , value: 'ALTRO' }, { label: 'GARA' , value: 'GARA' }, { label: 'MDI' , value: 'MDI' }, { label: 'OFFERTA PRIVATA' , value: 'OFFERTA PRIVATA' } ] },
                            { label: 'AdE Territoriale', apiName: 'WGC_AdE_Territoriale__c', type: 'lookup', title: '', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, visibility: true, required: true, objectName: 'WGC_AdE_Territoriale__c', icon: 'custom:custom16' },
                            { label: 'Tipologia incasso', apiName: 'WGC_Tipologia_Incasso__c', type: 'picklist', formulaVisibility: FORMULA_VISIBILITY_BO_FIELDS, frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, visibility: false, required: FORMULA_VISIBILITY_BO_FIELDS, options: [ {label: 'ORDINARIO', value: '3601'}, {label: 'MODELLO G', value: '3602'}, {label: 'PROC. SEMPLIFICATA', value: '3921'}]},
                            { label: 'Tipologia operazione', apiName: 'WGC_Tipo_Operazione__c', type: 'picklist', formulaVisibility: FF_VISIBILITY + ' && (' +FORMULA_VISIBILITY_BO_FIELDS + ')', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, visibility: false, required: FORMULA_VISIBILITY_BO_FIELDS, options: [ {label: 'ALTRO', value: 'ANAT1'}, {label: 'CREDITI ITALVENTITRE', value: 'FASTI'}, {label:'CREDITO D\'IMPOSTA IN COMPENSAZIONE', value: 'FASTT'}, {label: 'F.MATURITY COMM.LI/AZIENDE', value: 'FM001'}, {label: 'FAST CREDITI COMMERCIALI', value: 'FASTC'}, {label: 'FISCALI AGGRESSIVI', value: 'FASTA'}, {label: 'FISCALI FF/IN BONIS', value: 'FASTB'}, {label:'FISCALI FF/IRPEF', value: 'FAST2'}, {label: 'FISCALI FF/NO INVEST', value: 'FASTF'}, {label: 'FISCALI FF/ORDINARI', value: 'FASTO'}, {label: 'FISCALI FF/PRELIMINARI', value: 'FASTP'}, {label: 'FISCALI FF/QUICK', value: 'FASTQ'}, {label: 'FISCALI SUBORDINATI', value: 'FASTS'}, {label: 'REVOCATORIE EX FAST FINANCE', value: 'REVFF'}] },
                            { label: 'Data Notif. Autoriz. GD', apiName: 'WGC_Data_Notifi_Autoriz_GD__c', type: 'date', formulaVisibility: FF_VISIBILITY + ' && (' +FORMULA_VISIBILITY_BO_FIELDS + ')', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, visibility: false },
                            // OLD { label: 'Modalità di offerta', apiName: 'WGC_Modalita_di_offerta__c', type: 'picklist', defaultVal: FORMULA_INBONIS + ' ? "MDI" : null', readOnly: FORMULA_READONLY, formulaVisibility: FORMULA_INBONIS, visibility: false, required: FORMULA_VISIBILITY_BO_FIELDS,  options: [ { label: 'ALTRO' , value: 'ALTRO' }, { label: 'GARA' , value: 'GARA' }, { label: 'MDI' , value: 'MDI' }, { label: 'OFFERTA PRIVATA' , value: 'OFFERTA PRIVATA' } ] },
                            { label: 'Esenzione garanzia' , apiName: 'WGC_Esenzione_garanzia__c', type: 'radio', value: 'false', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, visibility: true, required: false},
                            { label: 'Garante' , apiName: 'WGC_Garante__c', type: 'picklist', formulaVisibility: 'this.state.WGC_Esenzione_garanzia__c == "false" || this.state.WGC_Esenzione_garanzia__c == undefined', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, visibility: false, required: false, options: [ {label: 'Banca IFIS', value: 'Banca IFIS'}, {label: 'Altro istituto', value: 'Altro istituto'}] },
                            { label: 'Garanzia già richiesta da AdE' , apiName: 'WGC_Garanzia_richiesta_da_AdE__c', type: 'radio', value: 'false', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: '(' + FORMULA_INBONIS + ' && ( this.state.WGC_Esenzione_garanzia__c == "false" || this.state.WGC_Esenzione_garanzia__c == undefined ) )', visibility: false, required: false},
                            { label: 'Data richiesta da AdE' , apiName: 'WGC_Data_richiesta_da_AdE__c', type: 'date', formulaVisibility: 'this.state.WGC_Garanzia_richiesta_da_AdE__c == "true"', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, visibility: false, required: false},
                            { label: 'Richiesta documenti AdE', apiName: 'WGC_Richiesta_all_azienda_dei_Doc_da_AdE__c', type: 'radio', value: 'false', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, visibility: true, required: false },
                            { label: 'Data richiesta', apiName: 'WGC_Data_richiesta__c', type: 'date', formulaVisibility: 'this.state.WGC_Richiesta_all_azienda_dei_Doc_da_AdE__c == "true"', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, visibility: false, required: false },
                            { label: 'Data evasione', apiName: 'WGC_Data_evasione__c', type: 'date', formulaVisibility: 'this.state.WGC_Richiesta_all_azienda_dei_Doc_da_AdE__c == "true"', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, visibility: false, required: false},
                            // OLD { label: 'Esenzione garanzia' , apiName: 'WGC_Esenzione_garanzia__c', type: 'radio', value: 'false', readOnly: FORMULA_READONLY, visibility: true, required: false},
                            // OLD { label: 'Garante' , apiName: 'WGC_Garante__c', type: 'picklist', formulaVisibility: 'this.state.WGC_Esenzione_garanzia__c == "false" || this.state.WGC_Esenzione_garanzia__c == undefined', readOnly: FORMULA_READONLY, visibility: false, required: false, options: [ {label: 'Banca IFIS', value: 'Banca IFIS'}, {label: 'Altro istituto', value: 'Altro istituto'}] },
                            // OLD { label: 'Garanzia già richiesta da AdE' , apiName: 'WGC_Garanzia_richiesta_da_AdE__c', type: 'radio', value: 'false', readOnly: FORMULA_READONLY, formulaVisibility: '(' + FORMULA_INBONIS + ' && this.state.WGC_Esenzione_garanzia__c == "false" )', visibility: false, required: false},
                            // OLD { label: 'Data richiesta da AdE' , apiName: 'WGC_Data_richiesta_da_AdE__c', type: 'date', formulaVisibility: 'this.state.WGC_Garanzia_richiesta_da_AdE__c == "true"', readOnly: FORMULA_READONLY, visibility: false, required: false},
                            { label: 'Multiproprietà' , apiName: 'WGC_Multiproprieta__c', type: 'radio', value: 'false', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY, visibility:false, required: FORMULA_VISIBILITY_BO_FIELDS},
                            { label: 'Richiesta polizza', apiName: 'WGC_Richiesta_Polizza__c', type: 'radio', value: 'false', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY, visibility: false, required: false},
                            { label: 'Data richiesta polizza', apiName: 'WGC_Data_richiesta_Polizza__c', type: 'date', formulaVisibility: 'this.state.WGC_Richiesta_Polizza__c == "true"', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, visibility: false, required: false},
                            { label: '% Suggerita di acquisto' , apiName: 'PercentualeSuggerita__c', type: 'number', formatter: 'percent-fixed', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY, visibility: false, required: FORMULA_VISIBILITY_COMMERCIALE },
                            //SM - TEN 408 - 4 Unità locale solo per fast finance
                            { label: 'Due Diligence', apiName: 'WGC_Due_Diligence__c', type: 'radio', value: 'false', formulaVisibility: FORMULA_INBONIS + ' || ' + FORMULA_FISCALE_BONIS, frmReadOnly: FORMULA_READONLY, required: false, visible: false},
                            //WGC_Unita_Locale_flag
                            { label: 'Unità Locale', apiName: 'WGC_Unita_Locale_flag__c', type: 'radio', value: 'false', /*formulaVisibility: FORMULA_VISIBILITY_BO_FIELDS,*/ frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY, visibility: true, required: false, },
                            { label: 'Unità Locale', apiName: 'WGC_Unita_Locale__c', type: 'picklist', formulaVisibility: 'this.state.WGC_Unita_Locale_flag__c == "true"', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, visibility: false, required: true, },
                            { label: 'Contratto unità locale', apiName: 'WGC_Contratto_unita_locale__c', type: 'picklist', formulaVisibility: 'this.state.WGC_Unita_Locale_flag__c == "true" && (' + FORMULA_VISIBILITY_BO_FIELDS + ')', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, visibility: false, required: false },
                            { label: 'Compensi', apiName: 'WGC_Compensi__c', type: 'number', formatter: 'currency', formulaVisibility: 'this.state.WGC_Unita_Locale_flag__c == "true" && (' + FORMULA_VISIBILITY_BO_FIELDS + ')', readOnly: true, visibility: false, showBtnFRM: FORMULA_VISIBILITY_BO_FIELDS, required: false, btnLabel: 'Ricalcola Compensi', showBtn: false, btnActionName: 'compensi'},
                            { label: 'Compensi (gest. Manuale)', formulaLabel: '( (' + FORMULA_INBONIS + ' || '+FORMULA_FISCALE_BONIS+' )  && this.state.WGC_Due_Diligence__c == "true" ) ? "Compensi" : "Compensi (gest. Manuale)"', apiName: 'WGC_Compensi_gest_Manuale__c', type: 'number', formatter: 'currency', formulaVisibility: '(this.state.WGC_Unita_Locale_flag__c == "true" && (' + FORMULA_VISIBILITY_BO_FIELDS + ')) || ( (' + FORMULA_INBONIS + ' || ' + FORMULA_FISCALE_BONIS + ')  && this.state.WGC_Due_Diligence__c == "true" )' , frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, visibility: false, formulaRequired: '( (' + FORMULA_INBONIS + ' || '+ FORMULA_FISCALE_BONIS +' )  && this.state.WGC_Due_Diligence__c == "true" ) ? true : false', required: false},
                            // MS - Aggiunto picklist status
                            { label: 'Status', apiName: 'Status__c', type: 'picklist', frmReadOnly: '!' + FORMULA_VISIBILITY_BO_FIELDS, readOnly: '!' + FORMULA_VISIBILITY_BO_FIELDS, visibility: true, required: false, options: [ {label: 'BREVE', value: 'BREVE'}, {label: 'CONCLUSA', value: 'CONCLUSA'}, {label: 'CASSATA', value: 'CASSATA'}, {label: 'PERSA x CONCORRENZA', value: 'PERSA x CONCORRENZA'}, {label: 'PERSA', value: 'PERSA'}]},
                        ];

    @track
    fields_quantitative = [ 
                            {label: 'Valore Nominale', apiName: 'ValoreNominale__c', type: 'number', step: '0.01', formatter: 'currency', /*step: '0.01',*/ frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, visibility: true, required: true},
                            //DFO
                            //{label: 'Prosoluto', apiName: 'WGC_Prosoluto__c', type: 'radio', value: 'false', readOnly: FORMULA_READONLY, formulaVisibility: FORMULA_FACTORING_FISCALE + ' || ' + FORMULA_FACTORING_FISCALE_NOTNOT, visibility: false, required: true},
                            {label: 'Ruoli compens.', apiName: 'WGC_Ruoli_compens__c', type: 'number', formatter: 'currency', step: '', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FORMULA_VISIBILITY_BO_FIELDS, visibility: false, required: FORMULA_VISIBILITY_BO_FIELDS},
                            //INBONIS
                            {label: 'Data richiesta rimborso', apiName: 'WGC_Data_richiesta_rimborso__c', type: 'date', frmReadOnly: FORMULA_READONLY, readOnly:FORMULA_READONLY, formulaVisibility: FORMULA_INBONIS, visibility: false, required: false},
                            //DFO
                            {label: 'Termini di pagamento', apiName: 'WGC_Termini_di_pagamento__c', type: 'number', step: '', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FORMULA_FACTORING_FISCALE + ' || ' + FORMULA_FACTORING_FISCALE_NOTNOT, visibility: false, required: true},
                            {label: 'Val. Nom. Esigibile', apiName: 'WGC_Val_Nom_Esigibile__c', type: 'number', step: '0.01', formatter: 'currency', defaultVal: 'this.state.ValoreNominale__c - this.state.WGC_Ruoli_compens__c', /*'(this.state.ValoreNominale__c != null && this.state.WGC_Ruoli_compens__c != null) ? this.state.ValoreNominale__c - this.state.WGC_Ruoli_compens__c : null',*/ readOnly: FORMULA_READONLY, formulaVisibility: FORMULA_VISIBILITY_BO_FIELDS, visibility: false, required: '('+FORMULA_VISIBILITY_BO_FIELDS+') && this.state.WGC_Escludi_IRR__c == "false"'},
                            {label: 'Modalità di offerta', apiName: 'WGC_Modalita_di_offerta__c', type: 'picklist', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY, visibility: false, required: FORMULA_VISIBILITY_BO_FIELDS},
                            {label: 'Data scadenza bando', apiName: 'WGC_Data_scadenza_bando__c', type: 'date', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')', visibility: false, required: false},
                            {label: 'Data offerta', apiName: 'WGC_Data_Offerta__c', type: 'date', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')', visibility: false, required: false },
                            {label: 'Data scadenza offerta', apiName: 'WGC_Data_Scadenza_Offerta__c', type: 'date', defaultVal: 'this.state.WGC_Data_Offerta__c != null ? new Date( new Date(this.state.WGC_Data_Offerta__c).setDate(new Date(this.state.WGC_Data_Offerta__c).getDate() + 60) ).toISOString().split("T")[0] : null', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')', visibility: false, required: false },
                            {label: 'Commissione d\'acquisto', apiName: 'WGC_Commissione_acquisto__c', type: 'number', step: '0.01', formatter: 'percent-fixed', frmReadOnly: FORMULA_READONLY  + ' || this.state.WGC_Escludi_IRR__c == "true"', readOnly: FORMULA_READONLY, formulaVisibility: /*FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')' + ' && ' + FORMULA_INBONIS*/ FORMULA_INBONIS, visibility: false, required: '('+FORMULA_VISIBILITY_BO_FIELDS+') && this.state.WGC_Escludi_IRR__c == "false"'},
                            {label: 'Prezzo d\'acquisto', apiName: 'WGC_Prezzo_di_acquisto__c', type: 'number',  formatter: 'currency', frmReadOnly: '(' + FORMULA_READONLY + ') || ( ' + FORMULA_INBONIS + ' )' , readOnly: '(' + FORMULA_READONLY + ') || ' + FORMULA_INBONIS, defaultVal: 'if(this.state.WGC_Commissione_acquisto__c != undefined){ Math.round(this.state.WGC_Val_Nom_Esigibile__c * ( 1 - parseFloat(parseFloat(this.state.WGC_Commissione_acquisto__c) / 100) )) } else { this.state.WGC_Prezzo_di_acquisto__c }', /* else parseFloat(this.state.WGC_Prezzo_di_acquisto__c)*/ formulaVisibility: '(( ' + FORMULA_INBONIS + ' && ('+ FORMULA_VISIBILITY_BO_FIELDS + ')' /*NOT_FORMULA_VISIBILIY_COMERCIALE_CC*/ + ') || (' + FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS +') ) )', visibility: false, required: '('+FORMULA_VISIBILITY_BO_FIELDS+') && this.state.WGC_Escludi_IRR__c == "false"'},
                            {label: '% Offerta', apiName: 'WGC_Offerta_perc__c', type: 'number',  formatter: /*percent-fixed*/ 'percent-fixed', readOnly: true, defaultVal: '(this.state.WGC_Val_Nom_Esigibile__c != null && this.state.WGC_Prezzo_di_acquisto__c != null ) ? ((this.state.WGC_Prezzo_di_acquisto__c / this.state.WGC_Val_Nom_Esigibile__c) * 100).toFixed(2) : null', /*defaultVal: 'parseFloat((this.state.WGC_Prezzo_di_acquisto__c / this.state.WGC_Val_Nom_Esigibile__c).toFixed(2))',*/ formulaVisibility: '(( ' + FORMULA_INBONIS + ' && '+ FORMULA_VISIBILITY_BO_FIELDS/*NOT_FORMULA_VISIBILIY_COMERCIALE_CC*/ + ') || (' + FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS +') ) )', visibility: false, required: '('+FORMULA_VISIBILITY_BO_FIELDS+') && this.state.WGC_Escludi_IRR__c == "false"'},
                            {label: '% ulteriore quantificazione', apiName: 'WGC_Ulteriore_quantificazione_perc__c', type: 'number',  formatter: 'percent-fixed', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FORMULA_VISIBILITY_BO_FIELDS, visibility: false, required: false},
                            {label: 'Interessi maturati', apiName: 'WGC_Interessi_maturati__c', type: 'number',  formatter: 'currency', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FORMULA_VISIBILITY_BO_FIELDS, visibility: false, required: FORMULA_VISIBILITY_BO_FIELDS},
                            {label: 'Data presentazione rimborso', apiName: 'WGC_Data_presentazione_rimborso__c', type: 'date', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')' + ' && this.state.WGC_Data_rimborso_presunto__c == undefined', visibility: false, required: false},
                            {label: 'Data rimborso presunto', apiName: 'WGC_Data_rimborso_presunto__c', type: 'date', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')' + ' && this.state.WGC_Data_presentazione_rimborso__c == undefined', visibility: false, required: false},
                            {label: 'Data rimborso presunta in atto di cessione', apiName: 'WGC_Data_rimb_pres_in_atto_di_cessione__c', type: 'date', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')' + ' && this.state.WGC_Data_presentazione_rimborso__c == undefined', visibility: false, required: '(' + FORMULA_VISIBILITY_BO_FIELDS + ') && this.state.WGC_Data_rimborso_presunto__c == undefined'},                            
                            {label: 'Data DSO', apiName: 'WGC_Data_DSO__c', type: 'date', frmReadOnly2: 'this.state.WGC_Modifica_DSO__c != undefined ? ( this.state.WGC_Modifica_DSO__c.toString() == "false" || ( ' + FORMULA_READONLY + ' )) : true', readOnly: true, formulaVisibility: '((' + FF_VISIBILITY + ') && (' + FORMULA_VISIBILITY_BO_FIELDS + ')) || ( ('+ FORMULA_INBONIS + ') && !(' + FORMULA_FACTORING_FISCALE_NOTNOT + ') && !(' + FORMULA_FACTORING_FISCALE + ') )', /*'(' + FORMULA_INBONIS + ' || (' + FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS +') ) )',*/ visibility: false, required: '('+FORMULA_VISIBILITY_BO_FIELDS+') && this.state.WGC_Escludi_IRR__c == "false"', showBtnFRM: '(' + FORMULA_INBONIS + ') || (' + FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS +') )', btnLabel: 'Ricalcola DSO', showBtn: false, btnActionName: 'modalDso'},                            
                            {label: 'Modifica DSO', apiName: 'WGC_Modifica_DSO__c', type: 'radio', value: 'false', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: '((' + FF_VISIBILITY + ') && (' + FORMULA_VISIBILITY_BO_FIELDS + ')) || ( ('+ FORMULA_INBONIS + ') && !(' + FORMULA_FACTORING_FISCALE_NOTNOT + ') && !(' + FORMULA_FACTORING_FISCALE + ') )', /*'(' + FORMULA_INBONIS + ' || (' + FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS +') ) )',*/ visibility: false, required: false},
                            {label: 'Causale Modifica DSO', apiName: 'WGC_Causale_modifica_DSO__c', type: 'picklist', frmReadOnly2: 'this.state.WGC_Modifica_DSO__c != undefined ? ( this.state.WGC_Modifica_DSO__c.toString() == "false" || ' + FORMULA_READONLY + ') : true', readOnly: true, formulaVisibility: '((' + FF_VISIBILITY + ') && (' + FORMULA_VISIBILITY_BO_FIELDS + ')) || ( ('+ FORMULA_INBONIS + ') && !(' + FORMULA_FACTORING_FISCALE_NOTNOT + ') && !(' + FORMULA_FACTORING_FISCALE + ') )', /*'(' + FORMULA_INBONIS + ' || (' + FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS +') ) )',*/ visibility: false, required:false, options: [{label: 'PRESUPPOSTO MINOR CREDITO', value: 'PRESUPPOSTO MINOR CREDITO'}, {label: 'DATI STORICI ESIGUI', value: 'DATI STORICI ESIGUI'}, {label: 'INCASSO MODELLO G', value: 'INCASSO MODELLO G'}, {label: 'PRESENZA RICHIESTA POLIZZA', value: 'PRESENZA RICHIESTA POLIZZA'}, {label: 'DIP AUTOMATICA SUPERATA', value: 'DIP AUTOMATICA SUPERATA'}, {label: 'ATTESA EVENTO', value: 'ATTESA EVENTO'}, {label: 'NO INVEST', value: 'NO INVEST'}, {label: 'VERIFICA TEL. ADE COMPETENTE', value: 'VERIFICA TEL. ADE COMPETENTE'}, {label: 'TEMP. INCASSO MOD.G INCERTA', value: 'TEMP. INCASSO MOD.G INCERTA'}, {label: 'CONTENZIOSO', value: 'CONTENZIOSO'}, {label: 'MEDIA TMR/ULTIMA OSSERV.', value: 'MEDIA TMR/ULTIMA OSSERV.'}, {label: 'DIP ULTIMA OSSERVAZIONE', value: 'DIP ULTIMA OSSERVAZIONE'}, {label: 'ALTRO', value: 'ALTRO'}, {label: 'MEDIA RIMB. PREC.', value: 'MEDIA RIMB. PREC.'} ]},
                            {label: 'Modifica costo notaio', apiName: 'WGC_Modifica_Costo_Notaio__c', type: 'radio', value: 'false', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')', visibility: false, required: false},
                            {label: 'Costo notaio', apiName: 'WGC_Costo_notaio__c', type: 'number', formatter:'currency', /*frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY,*/ frmReadOnly: '('+FORMULA_READONLY + ') || ( this.state.WGC_Modifica_Costo_Notaio__c == "false" || this.state.WGC_Modifica_Costo_Notaio__c == undefined )', readOnly: true, formulaVisibility: FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')', defaultVal: 'this.state.WGC_Modifica_Costo_Notaio__c == "false" || this.state.WGC_Modifica_Costo_Notaio__c == undefined ? (' +this._costoNotaioFormula + ') : this.state.WGC_Costo_notaio__c ', visibility: false, required: false},
                            //CR - Abilitazione per Campo Manuale Interessi Stimati
                            {label: 'Modifica Interessi stimati', apiName: 'WGC_Modifica_Interessi_Stimati__c', type: 'radio', value: 'false', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')', visibility: false, required: false},
                            {label: 'Interessi stimati', apiName: 'WGC_Interessi_stimati__c', type: 'number', formatter:'currency', frmReadOnly: '('+FORMULA_READONLY + ') || ( this.state.WGC_Modifica_Interessi_Stimati__c == "false" || this.state.WGC_Modifica_Interessi_Stimati__c == undefined )', readOnly: true, formulaVisibility: FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')', visibility: false, required: false, showBtnFRM: FORMULA_VISIBILITY_BO_FIELDS, btnLabel: 'Ricalcola Interessi', showBtn: false, btnActionName: 'interessi'},
                            //{label: 'Escludi IRR', apiName: 'WGC_Escludi_IRR__c', type: 'radio', value: 'false', frmReadOnly: FORMULA_READONLY, readOnly: false, formulaVisibility: '((' + FORMULA_ATD_FISCALE + ' || ' + FORMULA_ATD_FISCALE_NOTNOT + ') && (' + FORMULA_VISIBILITY_BO_FIELDS + ')) || (' + FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS +'))', visibility: false, required: FORMULA_VISIBILITY_BO_FIELDS },
                            {label: '% IRR', apiName: 'WGC_IRR_perc__c', type: 'number', formatter:'percent-fixed', readOnly: true, formulaVisibility: '((' + FORMULA_ATD_FISCALE + ' || ' + FORMULA_ATD_FISCALE_NOTNOT + ') && (' + FORMULA_VISIBILITY_BO_FIELDS + ')) || (' + FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS +'))', /*FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS +')',*/ /*'(( ' + FORMULA_INBONIS + ' && '+ FORMULA_VISIBILITY_BO_FIELDS + ') || (' + FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS +') ) )',*/ visibility: false, required: FORMULA_VISIBILITY_BO_FIELDS, formulaRequired: '('+FORMULA_VISIBILITY_BO_FIELDS + ') && this.state.WGC_Escludi_IRR__c == "false"', showBtnFRM: '(' + FORMULA_INBONIS + ' || (' + FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS +') ) )', btnLabel: 'Ricalcola IRR', showBtn: false, btnActionName: 'modalIrr' },
                            {label: 'Data Contratto', apiName: 'WGC_Data_Contratto__c', type: 'date', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')', visibility: false, required: false},
                            {label: 'Modalità contabilizzazione', apiName: 'WGC_Modalita_contabilizzazione__c', type: 'picklist', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')', visibility: false, required: FORMULA_VISIBILITY_BO_FIELDS, options: [ {label: 'Costo', value: 'Costo'}, {label: 'Costo ammortizzato', value: 'Costo ammortizzato'} ]},
                            {label: 'Data start up', apiName: 'WGC_Data_start_up__c', type: 'date', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')', visibility: false, required: false},
                            //Importo acconto
                            {label: 'Importo pagato alla cessione', apiName: 'WGC_Importo_acconto__c', type: 'number', formatter: 'currency', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')', visibility: false, required: false},
                            //Data acconto
                            {label: 'Data pagato alla cessione', apiName: 'WGC_Data_acconto__c', type: 'date', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: /*FORMULA_VISIBILITY_BO_FIELDS + ' && ' + */'this.state.WGC_Importo_acconto__c != null && this.state.WGC_Importo_acconto__c != undefined && this.state.WGC_Importo_acconto__c != ""', visibility: false, required: false},
                            //Importo cauzione 
                            {label: 'Importo cauzione', apiName: 'WGC_Importo_cauzione__c', type: 'number', formatter: 'currency', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')', visibility: false, required: false },
                            //Data cauzione
                            {label: 'Data cauzione', apiName: 'WGC_Data_cauzione__c', type: 'date', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: /*FORMULA_VISIBILITY_BO_FIELDS + ' && ' + */'this.state.WGC_Importo_cauzione__c != null && this.state.WGC_Importo_cauzione__c != undefined && this.state.WGC_Importo_cauzione__c != ""', visibility: false, required: false},
                            //Importo Saldo 
                            {label: 'Importo I° tranche prezzo differito', apiName: 'WGC_Importo_Saldo__c', type: 'number', formatter: 'currency', defaultVal: 'if(this.state.WGC_Importo_acconto__c == null) { this.state.WGC_Prezzo_di_acquisto__c } else if(this.state.WGC_Importo_acconto__c != undefined) { this.state.WGC_Prezzo_di_acquisto__c - this.state.WGC_Importo_acconto__c } else if(this.state.WGC_Prezzo_di_acquisto__c == undefined) { 0 }', readOnly: true/*FORMULA_READONLY*/, formulaVisibility: FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')', visibility: false, required: false },
                            //Data saldo
                            {label: 'Data I° tranche prezzo differito', apiName: 'WGC_Data_Saldo__c', type: 'date', frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')' + ' && ' + 'this.state.WGC_Importo_Saldo__c != null && this.state.WGC_Importo_Saldo__c != undefined', visibility: false, required: false},
                            //Note B/O
                            {label: 'Note B/O', apiName: 'WGC_Note_BO__c', type: 'textarea', flexibility: true, frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, formulaVisibility: FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')' /*+ ' && ' + 'this.state.WGC_Importo_Saldo__c != null && this.state.WGC_Importo_Saldo__c != undefined && this.state.WGC_Importo_Saldo__c != ""'*/, visibility: false, required: true}
                        ];
    
    @track
    fields_irr = [
                    {label: 'Sospensione Interessi', apiName: 'WGC_Gg_Maturazione_Interessi__c', type: 'number',  frmReadOnly: FORMULA_READONLY  + ' || this.state.WGC_Escludi_IRR__c == "true"', readOnly: FORMULA_READONLY, formulaVisibility: FORMULA_VISIBILITY_BO_FIELDS + ' && !' + FORMULA_INBONIS, visibility: false, required: '('+FORMULA_VISIBILITY_BO_FIELDS+') && this.state.WGC_Escludi_IRR__c == "false"'},
                    //TODO
                    {label: 'Data inizio maturazione interessi', apiName: 'WGC_Data_inizio_maturazione_interessi__c', type: 'date', frmReadOnly: FORMULA_READONLY + ' || this.state.WGC_Escludi_IRR__c == "true"', readOnly: FORMULA_READONLY, defaultVal: 'this.state.WGC_Data_inizio_maturazione_interessi__c == undefined ? ' + '('+formulaInizioMaturazione + ') : this.state.WGC_Data_inizio_maturazione_interessi__c', formulaVisibility: FORMULA_VISIBILITY_BO_FIELDS + ' && !' + FORMULA_INBONIS, visibility: false, required: FORMULA_VISIBILITY_BO_FIELDS},
                    {label: 'Data cessione credito', apiName: 'WGC_Data_cessione_credito__c', type: 'date', frmReadOnly: FORMULA_READONLY  + ' || this.state.WGC_Escludi_IRR__c == "true"', readOnly: FORMULA_READONLY, defaultVal: /*this.state.WGC_Data_cessione_credito__c == new Date( new Date().setDate( new Date().getDate() + 45 )).toISOString().split("T")[0] || */'if(this.state.WGC_Data_cessione_credito__c == undefined) { new Date( new Date().setDate( new Date().getDate() + 45 )).toISOString().split("T")[0] } else { this.state.WGC_Data_cessione_credito__c }', formulaVisibility: FORMULA_VISIBILITY_BO_FIELDS + ' && !' + FORMULA_INBONIS, visibility: false, required: '('+FORMULA_VISIBILITY_BO_FIELDS+') && this.state.WGC_Escludi_IRR__c == "false"'},
                    //TODO
                    {label: 'Data pagamento notaio e imposta registro', apiName: 'WGC_Data_pagamento_notaio__c', type: 'date', frmReadOnly: FORMULA_READONLY  + ' || this.state.WGC_Escludi_IRR__c == "true"', readOnly: FORMULA_READONLY, defaultVal: 'if(this.state.WGC_Data_cessione_credito__c != null) { new Date( new Date(this.state.WGC_Data_cessione_credito__c).setDate( new Date(this.state.WGC_Data_cessione_credito__c).getDate() + 15 )).toISOString().split("T")[0] } else { }', formulaVisibility: FORMULA_VISIBILITY_BO_FIELDS + ' && !' + FORMULA_INBONIS, visibility: false, required: '('+FORMULA_VISIBILITY_BO_FIELDS+') && this.state.WGC_Escludi_IRR__c == "false"'},
                    {label: 'Costo contenzioso', apiName: 'WGC_Costo_contenzioso__c', type: 'number', formatter: 'currency',  frmReadOnly: FORMULA_READONLY + ' || this.state.WGC_Escludi_IRR__c == "true"', readOnly: FORMULA_READONLY, formulaVisibility: FORMULA_VISIBILITY_BO_FIELDS + ' && !' + FORMULA_INBONIS, visibility: false, required: false},
                    {label: 'Data pagamento costo contenzioso', apiName: 'WGC_Data_Pagamento_Contenzioso__c', type: 'date',  frmReadOnly: FORMULA_READONLY + ' || this.state.WGC_Escludi_IRR__c == "true"', readOnly: FORMULA_READONLY, formulaVisibility: FORMULA_VISIBILITY_BO_FIELDS + ' && !' + FORMULA_INBONIS, visibility: false, required: false},
                    // condizione defaultVal sotto
                    {label: 'Data pagamento costo UL', apiName: 'WGC_Data_pagamento_costo_UL__c', type: 'date',  frmReadOnly: FORMULA_READONLY, readOnly: FORMULA_READONLY, defaultVal: 'if(this.state.WGC_Data_cessione_credito__c != null) { new Date( new Date(this.state.WGC_Data_cessione_credito__c).setDate( new Date(this.state.WGC_Data_cessione_credito__c).getDate() + 20 )).toISOString().split("T")[0] } else { }', formulaVisibility: FORMULA_VISIBILITY_BO_FIELDS + ' && !' + FORMULA_INBONIS, visibility: false, required: false},
                    //Tasso di riferimento
                    //Spread
                    //Costo denaro
                    {label: 'Tasso di riferimento', apiName: 'tassoRif', defaultVal_IRR: 'this.datiIrr.tassoInteresse != undefined ? this.datiIrr.tassoRif : ""', type: 'number', formatter: 'percent-fixed', readOnly: true, formulaVisibility: '(' + FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')) || ( !(' + FORMULA_FACTORING_FISCALE_NOTNOT + ') && !(' + FORMULA_FACTORING_FISCALE + ') )', /*FORMULA_VISIBILITY_BO_FIELDS,*/ visibility: false, required: false },
                    {label: 'Spread', apiName: 'spread', defaultVal_IRR: 'this.datiIrr.tassoInteresse != undefined ? this.datiIrr.spread : ""', type: 'number', formatter: 'percent-fixed', readOnly: true, formulaVisibility: '(' + FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')) || ( !(' + FORMULA_FACTORING_FISCALE_NOTNOT + ') && !(' + FORMULA_FACTORING_FISCALE + ') )', /*FORMULA_VISIBILITY_BO_FIELDS,*/ visibility: false, required: false },
                    {label: 'Costo denaro', apiName: 'costoDenaro', defaultVal_IRR: 'this.datiIrr.tassoInteresse != undefined ? this.datiIrr.costoDenaro : ""', type: 'number', formatter: 'percent-fixed', readOnly: true, formulaVisibility: '(' + FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')) || ( !(' + FORMULA_FACTORING_FISCALE_NOTNOT + ') && !(' + FORMULA_FACTORING_FISCALE + ') )', /*FORMULA_VISIBILITY_BO_FIELDS,*/ visibility: false, required: false },
                    {label: 'Tasso interesse attivo', apiName: 'tassoInteresse', defaultVal_IRR: 'this.datiIrr.tassoInteresse != undefined ? this.datiIrr.tassoInteresse : ""', /* defaultVal_IRR: '1.68',*/ type: 'number', formatter: 'percent-fixed', readOnly: true, formulaVisibility: FORMULA_VISIBILITY_BO_FIELDS + ' && !' + FORMULA_INBONIS, visibility: false, required: false }
                ];
                /*
                tassoInteresse
                tassoRif
                spread
                costoDenaro
                */
    @track
    sections = [ { name: 'Info qualitative', fields: this.fields_qualitative, renderInvia: true, isVisible: true },
                 { name: 'Info quantitative', fields: this.fields_quantitative, renderInvia: false, isVisible: true },
                 { name: 'IRR', fields: this.fields_irr, renderInvia: false, isVisible: '(' + FF_VISIBILITY + ' && (' + FORMULA_VISIBILITY_BO_FIELDS + ')) || ( !(' + FORMULA_FACTORING_FISCALE_NOTNOT + ') && !(' + FORMULA_FACTORING_FISCALE + ') )' /*FORMULA_VISIBILITY_BO_FIELDS*/ } ];

    constructor(){
        super();
        this.template.addEventListener('modal', this.handleCloseModal.bind(this));
    }
           
    connectedCallback(){
        //METODO PER RECUPERARE TUTTE LE PICKLIST
        this.rendered = false;
        let fields = new Array('Imposta__c','WGC_Tipologia_Incasso__c','WGC_Origine__c','WGC_Tipo_Operazione__c',
                                'WGC_Modalita_di_offerta__c','WGC_Garante__c',/*'WGC_Unita_Locale__c','WGC_Contratto_unita_locale__c',*/
                                'WGC_Causale_modifica_DSO__c', /*'WGC_Gg_Maturazione_Interessi__c',*/ 'WGC_Tipo_rimborso__c', 'WGC_Modalita_contabilizzazione__c', 'Status__c');
        getPicklistsVal({ sobj: 'Credito__c', fieldsApiName: fields })
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

                return getDatiIrr({ opportunityId : this.recordId });
            })
            .then(result => {
                this.datiIrr = result.data[0];
                window.datiIrr = this.datiIrr;
                this.setupIRR();
                this.rendered = true;
            })
            .catch(err => {
                console.log('@@@ err ' , err);
            });
    }

    renderedCallback(){
        
        // if(this.state != undefined && this.privateReadOnly != undefined && this.privateUserInfo != undefined && this.privateRecordType != undefined && this.privateCodProd != undefined){
        //     this.setupData();
        // }
        //if(window.privateReadOnly == undefined) window.privateReadOnly = false;

        // if(this.privateRecordType != undefined &&/*this.privatePayload != undefined &&*/ this.privateReadOnly != undefined && this.privateUserInfo != undefined && this.privateCodProd != undefined){
        //     this.setupData();
        // }
    }

    /* GETTER & SETTER */

    @api
    get credito(){
        return this.state;
    }

    set credito(c){
        this.state = c;
        window.state = c;
        if(this.privateRecordType != undefined &&/*this.privatePayload != undefined &&*/ this.privateReadOnly != undefined && this.privateUserInfo != undefined && this.privateCodProd != undefined){
            this.setupData();
        }
        this.rendered = true;
    }

    /*
    @api
    get payload(){
        return this.privatePayload;
    }

    set payload(p){
        this.privatePayload = p;
        window.privatePayload = p;

        if(this.state != undefined && this.privateReadOnly != undefined && this.privateUserInfo != undefined){
            this.setupData();
        }
    }
    */

    @api
    get userInfo(){
        return this.privateUserInfo;
    }

    set userInfo(u){
        if(u != undefined){
            this.privateUserInfo = u;
            window.privateUserInfo = u;
        } else {
            this.privateUserInfo = { Profile: { Name: 'Amministratore del sistema'} };
            window.privateUserInfo = { Profile: { Name: 'Amministratore del sistema'} };
        }

        if(this.privateRecordType != undefined && this.state != undefined && /*this.privatePayload != undefined &&*/ this.privateReadOnly != undefined && this.privateCodProd != undefined){
            this.setupData();
        }
        this.rendered = true;
    }

    @api
    get readOnly(){
        return this.privateReadOnly;
    }

    set readOnly(r){
        console.log('@@@ ro ' , r);
        if(r != undefined){
            this.privateReadOnly = r;
            window.privateReadOnly = r;
        } else {
            this.privateReadOnly = false;
            window.privateReadOnly = false;
        }

        if(this.privateRecordType != undefined && this.state != undefined && /*this.privatePayload != undefined &&*/ this.privateUserInfo != undefined && this.privateCodProd != undefined){
            this.setupData();
        }
        this.rendered = true;
    }

    @api
    get isCompleted(){
        return this.privateIsCompleted;
    }

    set isCompleted(c){
        this.privateIsCompleted = c;
    }

    @api
    get recordType(){
        return this.privateRecordType;
    }

    set recordType(r){
        if(r != undefined && typeof r != 'string'){
            this.privateRecordType = r;
            window.recordType = r;
        } else {
            this.privateRecordType = { DeveloperName: 'WGC_IFIS_Oppotunita_Crediti_Erariali' };
            window.recordType = { DeveloperName: 'WGC_IFIS_Oppotunita_Crediti_Erariali' };
        }

        if(this.state != undefined && this.privateUserInfo != undefined && this.privateReadOnly != undefined && this.privateCodProd != undefined){
            this.setupData();
        }

        this.rendered = true;
    }

    @api
    get codProd(){
        return this.privateCodProd;
    }

    set codProd(c){
        this.privateCodProd = c;
        window.privateCodProd = c != undefined ? c : '';

        if(this.state != undefined && this.privateUserInfo != undefined && this.privateReadOnly != undefined && this.privateRecordType != undefined)
            this.setupData();

        this.rendered = true;
    }

    /*
    get recordId(){
        return this.privatePayload.opportunityId;
    }

    get recordTypeId(){
        return this.privatePayload.opportunityData.RecordType.DeveloperName;
    }
    */

    /* GETTER & SETTER */

    /* FUNCTIONS */

    setupIRR(){
        this.sections.forEach(s => {
            s.fields.forEach(f => {
                if(f.hasOwnProperty('defaultVal_IRR'))
                    f.value = this.evaluate(f.defaultVal_IRR);
            });
        });
    }

    evaluate(formula){
        return eval(formula);
    }

    setupData(){
        this.rendered = false;
        var credito = {...this.state};
        window.state = credito;
        console.log('@@@ window.state ' , JSON.stringify(window.state));
        this.sections.forEach((s) => {
            s.isVisible = eval(s.isVisible);
            s.fields.forEach((f) => {
                
                if(f.hasOwnProperty('defaultVal')){
                    try{
                        var val = eval(f.defaultVal);
                        f.value = val;
                        credito[f.apiName] = val;

                        //Ricalcolo solo per data maturazione interessi //CR443-28
                        if(f.apiName == 'WGC_Data_inizio_maturazione_interessi__c'){
                            f.value = eval(formulaInizioMaturazione);
                            credito[f.apiName] = f.value;
                        }
                    }catch(e){
                        console.log('@@@ e ' , e);
                        console.log('@@@ f.apiName ' , f.apiName);
                    }
                }
                
                if(credito.hasOwnProperty(f.apiName)){ 
                    f.value = credito[f.apiName] == true && credito[f.apiName].toString() != "1" && credito[f.apiName].toString() != "01" ? "true" : credito[f.apiName] == false && credito[f.apiName].toString() != "0" && credito[f.apiName].toString() != "" ? "false" : credito[f.apiName] == null ? null : credito[f.apiName];
                    credito[f.apiName] = credito[f.apiName] == true && credito[f.apiName].toString() != "1" && credito[f.apiName].toString() != "01" ? "true" : credito[f.apiName] == false && credito[f.apiName].toString() != "0" && credito[f.apiName].toString() != "" ? "false" : credito[f.apiName] == null ? null : credito[f.apiName];
                    // f.value = credito[f.apiName]
                    // credito[f.apiName] = credito[f.apiName];
                }

                if(f.hasOwnProperty('frmReadOnly2')){
                    f.readOnly = this.evaluate(f.frmReadOnly2);

                    if(credito.WGC_Modifica_DSO__c == "false" && f.apiName == 'WGC_Causale_modifica_DSO__c'){
                        f.value = null;
                        credito[f.apiName] = null;
                    }
                } else if(f.hasOwnProperty('frmReadOnly')) 
                    f.readOnly = this.evaluate(f.frmReadOnly);

                if(f.hasOwnProperty('formulaVisibility')){ 
                    f.visibility = this.evaluate(f.formulaVisibility);
                }
                if(f.hasOwnProperty('showBtnFRM')) f.showBtn = this.evaluate(f.showBtnFRM);

                if(f.type == 'lookup'){
                    let apiNameTitle = f.apiName.substring(0, f.apiName.length-1) + 'r';
                    if(credito.hasOwnProperty(apiNameTitle))
                        f.title = credito[apiNameTitle].Name;
                }

                //SM - TEN 408 - 4 campo due diligence e compensi
                if(f.hasOwnProperty('formulaLabel')){
                    f.label = this.evaluate(f.formulaLabel);
                }

                f.required = this.evaluate(f.required);

                if(f.hasOwnProperty('formulaRequired')){
                    f.required = this.evaluate(f.formulaRequired);
                }

            });
        });

        this.state = credito;
        this.privateIsCompleted = this.checkCompletedFields();
        window.state = this.state;
        this.rendered = true;

        //this.dispatchEvent(new CustomEvent('updatecredito', { detail: { isCompleted: this.privateIsCompleted } }));
    }

    @api
    checkCompletedFields(){
        let allFields = this.sections[0].fields.concat(this.sections[1].fields);
        //if(this.sections[2].isVisible) allFields.concat(this.sections[2].fields);
        //if(this.state.WGC_Invia_Credito__c){
            var check = allFields.reduce((start, f) => {
                console.log('@@@ field ' , f.apiName);
                console.log('@@@ start ' , start);
                if(eval(f.required)){
                    if(!f.visibility){
                        return start;
                        //TODO Quando il servizio è pronto utilizzare questa condizione
                    } /*else if(eval(f.readOnly)) {
                        return start;
                    }*/
                     //CONDIZIONE PER TESTARE QUANDO I SERVIZI SONO GIU'
                    /*else if(eval(f.readOnly)){
                        return true;
                    }*/ else { 
                        if(Number.isFinite(f.value) && f.value == 0){
                            return start && true;
                        } else {
                            if(f.type == 'number'){
                                return ( start && !Number.isNaN(f.value) && f.value != undefined && f.value != null && f.value != "");
                            } else {
                                return ( start && f.value != undefined && f.value != '' && f.value != null && f.value != 'NaN')
                            }
                        }
                    }
                } else {
                    return start;
                }
            }, true);

            return check;
        /*} else {
            return true;
        }*/
    }

    @api
    confirm(){
        var credito = {...this.state};

        this.sections.forEach(s => { 
            s.fields.forEach((f) => {
                if(!f.visibility && f.apiName != 'WGC_Modalita_di_offerta__c'){
                    f.value = null;
                    credito[f.apiName] = null;
                    if(f.type == 'lookup'){
                        f.title = '';
                    }
                }
                if(f.apiName == 'WGC_Offerta_perc__c'){
                    f.value = parseFloat(f.value);
                    credito[f.apiName] = f.value;
                }
            });
        });

        var check = this.checkCompletedFields();
        //SM - TEN: controllo aggiunto
        if(credito.WGC_Prezzo_di_acquisto__c > credito.ValoreNominale__c){
            this.dispatchEvent(
                new ShowToastEvent({
                    "title": "Errore!",
                    "message": "Il prezzo di acquisto non può essere maggiore del valore nominale",
                    "variant": "error"
                })
            );
            check = check && false;
        }

        if(this.privateUserInfo.Profile.Name == "Amministratore del sistema" || this.privateUserInfo.Profile.Name == 'System Administrator' || this.privateUserInfo.Profile.Name == "IFIS - B/O Valutazione Fast Finance"){
            credito.WGC_Completo_BO__c = check;
        } else {
            credito.WGC_Completo_Commerciale__c = check;
        }

        this.state = credito;

        let response = { isCompleted: check, /*this.checkCompletedFields(),*/ credito: this.state };
        return response;
    }

    /* FUNCTIONS */

    /* EVENT HANDLERS */

    handleBtn(event){
        this.rendered = false;
        var action = event.target.name;
        var title = event.target.title;

        if(this.credito.Id == '') this.credito.Id = null;
        //Workaround per salvare correttamente il valore
        this.credito.WGC_Offerta_perc__c = parseFloat(this.credito.WGC_Offerta_perc__c);

        saveCredito({ credito: this.state })
            .then(r => {
                console.log('@@@ result single credito ' , r);
                if(r.success){
                    this.credito = r.data[0];
                } else {
                    console.log('@@@ err ' , r.message);
                }
            })
            .finally(() => {

                if(action == 'modalDso'){
                    if( ( this.privateRecordType.DeveloperName == "WGC_IFIS_Oppotunita_Crediti_Erariali" || this.privateRecordType.DeveloperName == "IFISOpportunitaFactoring" ) &&
                    this.credito.WGC_AdE_Territoriale__c != undefined && this.credito.ValoreNominale__c != undefined && this.credito.WGC_Data_richiesta_rimborso__c != undefined){
                        this.cmpModal = 'c-wgc_pc_cart_modal_dso';
                        this.modalParams = { title: title, componentParams : { creditoId: this.credito.Id } };
                        this.showModal = true;
                        this.rendered = true;
                    } else if((this.credito.WGC_Data_rimborso_presunto__c != undefined || this.credito.WGC_Data_presentazione_rimborso__c != undefined) &&
                            this.credito.WGC_AdE_Territoriale__c != undefined && this.credito.Imposta__c != undefined && this.credito.WGC_Tipologia_Incasso__c != undefined &&
                            this.credito.ValoreNominale__c != undefined){
                                this.cmpModal = 'c-wgc_pc_cart_modal_dso';
                                this.modalParams = { title: title, componentParams : { creditoId: this.credito.Id } };
                                this.showModal = true;
                                this.rendered = true;
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Attenzione!',
                                message: 'Controllare di aver compilato tutti i campi necessari',
                                variant: 'warning'
                            })
                        )
                    }
                } else if(action == 'modalIrr'){
                    if(this.credito.WGC_Data_cessione_credito__c > this.credito.WGC_Data_DSO__c){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Attenzione!",
                                message: 'La data cessione non può essere maggiore della data DSO',
                                variant: 'warning'
                            })
                        );
                    } else {
                        if( ( this.privateRecordType.DeveloperName == "WGC_IFIS_Oppotunita_Crediti_Erariali" || this.privateRecordType.DeveloperName == "IFISOpportunitaFactoring" ) &&
                        this.credito.WGC_Val_Nom_Esigibile__c != undefined /*&& this.credito.WGC_Gg_Maturazione_Interessi__c != undefined*/ && this.credito.WGC_Data_richiesta_rimborso__c != undefined && 
                        this.credito.WGC_Offerta_perc__c != undefined && this.credito.WGC_Commissione_acquisto__c != undefined &&/*this.credito.WGC_Prezzo_di_acquisto__c != undefined &&*/ this.credito.WGC_Data_DSO__c != undefined){
                            this.cmpModal = 'c-wgc_pc_cart_modal_irr';
                            this.modalParams = { title: title, componentParams: { creditoId: this.credito.Id } };
                            this.showModal = true;
                            this.rendered = true;
                        } else if(this.credito.Imposta__c != undefined && this.credito.WGC_Val_Nom_Esigibile__c != undefined && ( this.credito.WGC_Data_presentazione_rimborso__c != undefined || this.credito.WGC_Data_rimborso_presunto__c != undefined ) &&
                            this.credito.WGC_Gg_Maturazione_Interessi__c != undefined && this.credito.WGC_Data_cessione_credito__c != undefined && this.credito.WGC_Offerta_perc__c != undefined &&
                            /*this.credito.WGC_Importo_acconto__c != undefined &&*/ this.credito.WGC_Importo_Saldo__c != undefined && this.credito.WGC_Prezzo_di_acquisto__c != undefined &&
                            this.credito.WGC_Data_Saldo__c != undefined && this.credito.WGC_Data_DSO__c != undefined && this.credito.WGC_Costo_notaio__c != undefined && 
                            this.credito.WGC_Data_pagamento_notaio__c != undefined && this.credito.WGC_Costo_contenzioso__c != undefined && 
                            this.credito.WGC_Data_Pagamento_Contenzioso__c != undefined /*&& this.credito.WGC_Compensi__c != undefined*/ && this.credito.WGC_Data_pagamento_costo_UL__c != undefined){
                                this.cmpModal = 'c-wgc_pc_cart_modal_irr';
                                this.modalParams = { title: title, componentParams: { creditoId: this.credito.Id } };
                                this.showModal = true;
                                this.rendered = true;
                            } else {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Attenzione!',
                                        message: 'Controllare di aver compilato tutti i campi necessari',
                                        variant: 'warning'
                                    })
                                )
                            }
                    }
                } else if(action == 'interessi'){
                    if(this.credito.WGC_Data_DSO__c != undefined && ( this.credito.WGC_Data_rimborso_presunto__c != undefined || this.credito.WGC_Data_presentazione_rimborso__c != undefined ) &&
                        this.credito.ValoreNominale__c != undefined && this.credito.Imposta__c != undefined){
                            this.callCalcolaInteressi();
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Attenzione!',
                                message: 'Controllare di aver compilato tutti i campi necessari',
                                variant: 'warning'
                            })
                        )
                    }
                } else if(action == 'compensi'){
                    if( ( this.privateRecordType.DeveloperName == "WGC_IFIS_Oppotunita_Crediti_Erariali" || this.privateRecordType.DeveloperName == "IFISOpportunitaFactoring" ) && 
                        this.credito.WGC_Unita_Locale__c != undefined && this.credito.WGC_Contratto_unita_locale__c != undefined && this.credito.ValoreNominale__c != undefined &&
                        this.credito.WGC_Commissione_acquisto__c != undefined/*this.credito.WGC_Prezzo_di_acquisto__c != undefined*/ ){
                            this.callCalcolaCompensi();
                    } else if( this.credito.WGC_Unita_Locale__c != undefined && this.credito.WGC_Contratto_unita_locale__c != undefined && this.credito.ValoreNominale__c != undefined &&
                        /*this.credito.WGC_Ruoli_compens__c != undefined && this.credito.WGC_Interessi_maturati__c != undefined &&*/ this.credito.WGC_Prezzo_di_acquisto__c != undefined &&
                        this.credito.Imposta__c != undefined )
                        this.callCalcolaCompensi();
                    else
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Attenzione!',
                                message: 'Controllare di aver compilato tutti i campi necessari',
                                variant: 'warning'
                            })
                        )
                }

                //this.rendered = true;
            })
            .catch(err => {
                console.log('@@@ err ' , err);
            });

        /*
        console.log('@@@ fine ');
        this.dispatchEvent(
            new CustomEvent('spinnerevt', { detail: { show : true } })
        );
        */
    }

    callCalcolaInteressi(){
        calcolaInteressi({ creditoId: this.state.Id })
            .then(r => {
                console.log('@@@ result interessi ' , r);
                this.rendered = true;
                if(r.success){
                    this.dispatchEvent(
                        new CustomEvent('callservice')
                    );

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'SUCCESSO',
                            message: 'Dati aggiornati correttamente',
                            variant: 'success'
                        })
                    );
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'ERRORE',
                            message: r.message,
                            variant: 'error'
                        })
                    );
                }

        })
        .catch(err => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERRORE',
                    message: err,
                    variant: 'error'
                })
            );
        });
    }

    callCalcolaCompensi(){
        calcolaCompensi({ creditoId: this.state.Id })
                .then(r => {
                    console.log('@@@ result compensi ' , r);
                    this.rendered = true;

                    if(r.success){
                        this.dispatchEvent(
                            new CustomEvent('callservice')
                        );

                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'SUCCESSO',
                                message: 'Dati aggiornati correttamente',
                                variant: 'success'
                            })
                        );
                    } else {                    
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'ERRORE',
                                message: r.message,
                                variant: 'error'
                            })
                        );
                    }

            })
            .catch(err => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ERRORE',
                        message: err,
                        variant: 'error'
                    })
                );
            });
    }

    handleCloseModal(event){
        this.showModal = event.detail.open;
    }

    updateSelection(event){
        let state = {...this.state};
        state.WGC_Invia_Credito__c = event.detail.checked;
        this.state = state;
        this.dispatchEvent(
            new CustomEvent('checkcompleted', { bubbles: true, composed: true, detail: { completed: false } } )
        )
    }

    updateField(event){
        let credito = {...this.state};
        let fieldChanged = event.detail;
        //credito[fieldChanged.apiName] = fieldChanged.value == true && fieldChanged.value.toString() != "1" && fieldChanged.value.toString() != "01" ? "true" : fieldChanged.value == false && fieldChanged.value.toString() != "0" && fieldChanged.value.toString() != "" ? "false" : fieldChanged.value == null ? null : fieldChanged.value;
        credito[fieldChanged.apiName] = fieldChanged.value;

        let allSections = [...this.sections];
        allSections.forEach((s) => {
            s.fields.forEach((f) => {
                if(f.apiName == fieldChanged.apiName){
                    //f.value = fieldChanged.value == true && fieldChanged.value.toString() != "1" ? "true" : fieldChanged.value == false && fieldChanged.value.toString() != "0" && fieldChanged.value.toString() != "" ? "false" : fieldChanged.value == null ? null : fieldChanged.value;
                    f.value = fieldChanged.value;
                }
            });
        });

        this.sections = allSections;

        //Picklist dipendenti
        if(fieldChanged.apiName == 'WGC_Unita_Locale__c'){
            let key = this.contrattoUnitaLocale.controllerValues[fieldChanged.value];
            this.sections.forEach(s => {
                s.fields.forEach(f => {
                    if(f.apiName == CONTRATTO_UNITA_LOCALE.fieldApiName){
                        f.options = this.contrattoUnitaLocale.values.filter(opt => { return opt.validFor.includes(key) });
                    }
                });
            });
        }

        this.privateIsCompleted = this.checkCompletedFields();
        if(this.privateUserInfo.Profile.Name == 'Amministratore del sistema' || this.privateUserInfo.Profile.Name == 'System Administrator' || this.privateUserInfo.Profile.Name == 'IFIS - B/O Valutazione Fast Finance')
            credito.WGC_Completo_BO__c = this.privateIsCompleted;
        else
            credito.WGC_Completo_Commerciale__c = this.privateIsCompleted;

        window.state = credito;
        this.state = credito;
        this.setupData();

        this.dispatchEvent(
            new CustomEvent('checkcompleted', { bubbles: true, composed: true, detail: { completed: false } } )
        )
    }

    /* EVENT HANDLERS */
}