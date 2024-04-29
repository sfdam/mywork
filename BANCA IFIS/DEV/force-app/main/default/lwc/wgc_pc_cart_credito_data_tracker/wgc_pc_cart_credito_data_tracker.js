import { LightningElement, api, track, wire } from 'lwc';

import CREDITO_OBJECT from '@salesforce/schema/Credito__c';

import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import UNITA_LOCALE from '@salesforce/schema/Credito__c.WGC_Unita_Locale__c';
import CONTRATTO_UNITA_LOCALE from '@salesforce/schema/Credito__c.WGC_Contratto_unita_locale__c';

// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

import getValoriIRR from '@salesforce/apex/WGC_PC_CartCreditoDataTrackerController.getValoriIRR';
import getMetadata from '@salesforce/apex/WGC_PC_CartCreditoDataTrackerController.getMetadata';
import saveCredito from '@salesforce/apex/WGC_PC_CartCreditoDataTrackerController.saveCredito';
import getCreditoInviato from '@salesforce/apex/WGC_PC_CartController.getCreditoInviato';
import calcolaInteressi from '@salesforce/apex/WGC_PC_CartController.callCalcolaInteressi';

import btnConferma from '@salesforce/label/c.wgc_pc_cart_credito_data_tracker_btnConferma';

export default class Wgc_pc_cart_credito_data_tracker extends LightningElement {

    label = {
        btnConferma,
    };
    
    error;
    valoriIRR;

    @track fields_qualitative = [];
    @track fields_quantitative = [];
    @track fields_irr = [];

    @api item;
    @api userInfo;

    @track sections = [];
    @track btnDisabled = false;

    @track showModal = false;
    @track cmpModal;
    @track modalParams;

    @api pReadOnly = false;

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
            if(this.sections != undefined){
                this.sections.forEach(s => {
                    s.fields.forEach(f => {
    
                        if(f.apiName__c == 'WGC_Unita_Locale__c'){
                            f.options__c = data.values;
                        }
                    });
                });
            }
        } else if(error) {
            console.log('SV ERROR', error);
        }
    }
    
    
    @wire(getPicklistValues, { recordTypeId: '$creditoInfo.data.defaultRecordTypeId', fieldApiName: CONTRATTO_UNITA_LOCALE })
    contrattoUnitaLocaleInfo({ error, data }) {
        if (data) {
            this.contrattoUnitaLocale = data;
            var valUnita;
            this.sections.forEach(s => {
                s.fields.forEach(f => {
                    if(f.apiName__c == 'WGC_Unita_Locale__c'){
                        valUnita = f.value;
                    }
                    if(f.apiName__c == 'WGC_Contratto_unita_locale__c'){
                        f.options__c = data.values;
                        let key = this.contrattoUnitaLocale.controllerValues[valUnita];
                        this.sections.forEach(s => {
                            s.fields.forEach(f => {
                                if(f.apiName__c == CONTRATTO_UNITA_LOCALE.fieldApiName){
                                    f.options__c = this.contrattoUnitaLocale.values.filter(opt => { return opt.validFor.includes(key) });
                                }
                            });
                        });
                    }
                });
            });
        } else if(error) {
            console.log('SV ERROR', error);
        }
    }

    //A.M. SDHDFNZ-101026 - Spostata la chiamata per consentire l'invio dell'ID Opportunità
	//@wire (getValoriIRR)
    //wiredValoriIRR({ error, data }){
    //    if(data){
    //        this.valoriIRR = data;
    //    } else if(error){
    //        console.log('SV ERROR', error);
    //    }
    //}

    constructor(){
        super();
        this.template.addEventListener('modal', this.handleCloseModal.bind(this));
    }

    connectedCallback() {

        console.log('SV item: ', this.item);
        this.item = JSON.parse(JSON.stringify(this.item));

		//A.M. SDHDFNZ-101026 - Spostata qui la chiamata @wire in quanto è necessario passare l'opportunità 
		getValoriIRR({ opportunitaId: this.item.Opportunita__c }).then(res => {
            this.valoriIRR = res;
			})
        
        getCreditoInviato({ creditoId : this.item.Id }).then(res => {
            console.log('SV getCreditoInviato: ', res);
            this.item = JSON.parse(res);
            return getMetadata();
        }).then(result => {
                let valQualitative = [];
                let valQuantitative = [];
                let valIRR = [];
                let cc = this.item;
                let mdtValIRR = this.valoriIRR;
                console.log('SV getMetadata: ', result);

                var h = this;

                result.forEach(function (element) {
                    
                    // console.log('SV element: ', element);
                    //TODO Aggiungere condizione sul profilo
                    if(cc.WGC_Credito_Confermato__c || h.userInfo.Profile.Name == 'IFIS - Crediti Erariali' || h.pReadOnly){
                        element.readOnly__c = true;
                    }
  
                    if(element.type__c == 'picklist' && element.hasOwnProperty('options__c')){
                        var parsedJSON = JSON.parse(element.options__c);
                        element.options__c = parsedJSON;

                        if(element.apiName__c == UNITA_LOCALE.fieldApiName && h.unitaLocale != undefined){
                            element.options__c = h.unitaLocale.values;
                        }
                        if(element.apiName__c == CONTRATTO_UNITA_LOCALE.fieldApiName && h.contrattoUnitaLocale != undefined){
                            element.options__c = h.contrattoUnitaLocale.values;
                        }
                    }

                    
                    if(element.hasOwnProperty('buttonActionName__c')){
                        element.showBtn = true;

                        if(h.item.WGC_Credito_Confermato__c || h.userInfo.Profile.Name == 'IFIS - Crediti Erariali' || h.pReadOnly){
                            element.btnFieldDisabled = true;
                        }
                    }
                    
                    for (var key in cc) {                        
                        if(key == element.apiName__c) element.value =  element.type__c == 'radio' ? cc[key] ? 'true' : 'false' : cc[key];
                        if(element.type__c == 'lookup'){
                            element.icon = "custom:custom16";
                            element.objName = element.apiName__c;
                            let apiNameTitle = element.apiName__c.substring(0, element.apiName__c.length-1) + 'r';
                            if(key == apiNameTitle)
                                element.title = cc[apiNameTitle].Name;
                        }                        
                    }

                    for (var key in mdtValIRR) {
                        if(key == element.apiName__c) element.value = mdtValIRR[key];
                    }

                    if(element.sezione__c == 'Info qualitative'){
                        valQualitative.push(element);
                    }

                    if(element.sezione__c == 'Info quantitative'){
                        valQuantitative.push(element);
                    }

                    if(element.sezione__c == 'IRR'){
                        valIRR.push(element);
                    }
                })

                valQualitative.sort(function (a, b) {

                    // Use toUpperCase() to ignore character casing
                    const positionA = a.posizioneField__c;
                    const positionB = b.posizioneField__c;
                
                    let comparison = 0;
                    if (positionA > positionB) {
                        comparison = 1;
                    } else if (positionA < positionB) {
                        comparison = -1;
                    }
                    return comparison;

                });
                valQuantitative.sort(function (a, b) {

                    // Use toUpperCase() to ignore character casing
                    const positionA = a.posizioneField__c;
                    const positionB = b.posizioneField__c;
                
                    let comparison = 0;
                    if (positionA > positionB) {
                        comparison = 1;
                    } else if (positionA < positionB) {
                        comparison = -1;
                    }
                    return comparison;

                });
                valIRR.sort(function (a, b) {

                    // Use toUpperCase() to ignore character casing
                    const positionA = a.posizioneField__c;
                    const positionB = b.posizioneField__c;
                
                    let comparison = 0;
                    if (positionA > positionB) {
                        comparison = 1;
                    } else if (positionA < positionB) {
                        comparison = -1;
                    }
                    return comparison;

                });

                this.sections = [ { name: 'Info qualitative', fields: valQualitative, renderInvia: true, isVisible: true },
                                { name: 'Info quantitative', fields: valQuantitative, renderInvia: false, isVisible: true },
                                { name: 'IRR', fields: valIRR, renderInvia: false, isVisible: true } ];
                
            })
            .catch(error => {
                console.log('SV ERROR', error);
                this.error = error;
            })
            .finally(() => {
                this.setupData();
                if(this.item.WGC_Credito_Confermato__c || this.userInfo.Profile.Name == 'IFIS - Crediti Erariali' || this.pReadOnly){
                    this.btnDisabled = true;
                }

                this.verifyRequiredField();
            })
    }      

    saveClick(event){
        let credito = {...this.item};
		
        if(credito.WGC_Prezzo_di_acquisto__c > credito.ValoreNominale__c){
            this.dispatchEvent(
                new ShowToastEvent({
                    "title": "Errore!",
                    "message": "Il prezzo di acquisto non può essere maggiore del valore nominale",
                    "variant": "error"
                })
            );
        } else {
            saveCredito({credito: JSON.stringify(credito)})
                .then(result => {

                    console.log('SV saveCredito: ', result);

                    const event = new ShowToastEvent({
                        "title": "Successo!",
                        "variant": "success",
                        "message": "Il credito è stato aggiornato correttamente!"
                    });
                    this.dispatchEvent(event);
                })
                .catch(error => {
                    console.log('SV ERROR', error);
                    this.error = error;
                })
                .finally(() => {
                    this.connectedCallback();
                })
        }
    }

    updateField(event){
        let credito = {...this.item};
        let fieldChanged = event.detail;
        //credito[fieldChanged.apiName] = fieldChanged.value == true && fieldChanged.value.toString() != "1" && fieldChanged.value.toString() != "01" ? "true" : fieldChanged.value == false && fieldChanged.value.toString() != "0" && fieldChanged.value.toString() != "" ? "false" : fieldChanged.value == null ? null : fieldChanged.value;
        credito[fieldChanged.apiName] = fieldChanged.value;

		let allSections = [...this.sections];
        allSections.forEach((s) => {
            s.fields.forEach((f) => {
                if(f.apiName__c == fieldChanged.apiName){
                    //f.value = fieldChanged.value == true && fieldChanged.value.toString() != "1" ? "true" : fieldChanged.value == false && fieldChanged.value.toString() != "0" && fieldChanged.value.toString() != "" ? "false" : fieldChanged.value == null ? null : fieldChanged.value;
                    f.value = fieldChanged.value ;
                }
            });
        });

        this.sections = allSections;

        //Picklist dipendenti STANDARD
        if(fieldChanged.apiName == 'WGC_Unita_Locale__c' && this.contrattoUnitaLocale != undefined){
            let key = this.contrattoUnitaLocale.controllerValues[fieldChanged.value];
//            if(this.sections != undefined){
                this.sections.forEach(s => {
                    s.fields.forEach(f => {
                        if(f.apiName__c == CONTRATTO_UNITA_LOCALE.fieldApiName){
                            f.options = this.contrattoUnitaLocale.values.filter(opt => { return opt.validFor.includes(key) });
                        }
                    });
                });
//            }
        }

		//A.M. Controllo su valore Data_Contratto
		if(fieldChanged.apiName == 'WGC_Data_Contratto__c'){
            this.sections.forEach(s => {
               s.fields.forEach(f => {
				     if(f.apiName__c == 'WGC_Data_Contratto__c'){
					    //A.M. Verifica data contratto (January is 0 quindi aggiungo 1)
		                var mese = new Date().getMonth()+1;
		                var anno = new Date().getFullYear();
		                var contrattoMese = new Date(f.value).getMonth() +1;
		                var contrattoAnno = new Date(f.value).getFullYear();
                        console.log('@@@A.M. mese ', mese);
						console.log('@@@A.M. anno ', anno);
						console.log('@@@A.M. contrattoMese ', contrattoMese);
	    				console.log('@@@A.M. contrattoAnno ', contrattoAnno);
						if((contrattoMese != mese || contrattoAnno != anno) && !(isNaN(contrattoMese))){
					       fieldChanged.value = '';
					       credito[fieldChanged.apiName] = fieldChanged.value;
		                   this.dispatchEvent(
                                new ShowToastEvent({
                                    "title": "Errore!",
                                    "message": "La Data contratto deve essere del mese ed anno correnti",
                                    "variant": "error"
                                })
		                   );
		                }
                     }
                 });
            });
        }

		//A.M. Controllo per Interessi Stimati
		if(fieldChanged.apiName == 'WGC_Data_DSO__c' || fieldChanged.apiName == 'WGC_Data_presentazione_rimborso__c' || fieldChanged.apiName == 'WGC_Data_rimborso_presunto__c' || fieldChanged.apiName == 'Imposta__c' || fieldChanged.apiName == 'WGC_Val_Nom_Esigibile__c' || fieldChanged.apiName == 'ValoreNominale__c' || fieldChanged.apiName == 'WGC_Ruoli_compens__c' || fieldChanged.apiName == 'WGC_Modifica_Interessi_Stimati__c'){
            console.log('@@@A.M. Interessi-variato il campo: ', fieldChanged.apiName);
            this.sections.forEach(s => {
               s.fields.forEach(f => {
				     if(f.apiName__c == 'WGC_Interessi_stimati__c' && (f.value != null && f.value != 0)){
					    console.log('@@@A.M. Interessi: ', f.value);
					    f.value = null;
					    credito[f.apiName__c] = f.value;
		                this.dispatchEvent(
                             new ShowToastEvent({
                                 "title": "Attenzione!",
                                 "message": "Ricalcolare Interessi Stimati e IRR",
                                 "variant": "error"
                             })
		                );
		             }
					 if(f.apiName__c == 'WGC_IRR_perc__c' && (f.value != null && f.value != 0)){
					    console.log('@@@A.M. IRR_perc: ', f.value);
					    f.value = null;
					    credito[f.apiName__c] = f.value;
		             }
                 });
            });
        }


		this.item = credito;

        // DA VEDERE CAMPI FORMULA
        window.state = credito;
        this.setupData();
        this.verifyRequiredField();

        // this.dispatchEvent(
        //     new CustomEvent('checkcompleted', { bubbles: true, composed: true, detail: { completed: false } } )
        // )
    }

    evaluate(formula){
        return eval(formula);
    }

    setupData(){
        this.rendered = false;
        var credito = {...this.item};
        window.state = credito;
        var h = this;
        this.sections.forEach((s) => {
            s.isVisible = eval(s.isVisible);
            s.fields.forEach((f) => {

                f.value = typeof credito[f.apiName__c] == "boolean" ? credito[f.apiName__c].toString() : credito[f.apiName__c] != undefined ? credito[f.apiName__c] : f.value;

                if(f.hasOwnProperty('formulaDefaultValue__c')){
                    try{

                        var val = eval(f.formulaDefaultValue__c);

                        f.value = val;
                        credito[f.apiName__c] = val;
                    }catch(e){
                        console.log('SV e ' , e);
                    }
                }

                if(f.hasOwnProperty('formulaVisibility__c')){ 
                    f.visibility__c = this.evaluate(f.formulaVisibility__c);
                }

                if(f.hasOwnProperty('formulaReadOnly__c')){
                    if(!h.pReadOnly)
                        f.readOnly__c = this.evaluate(f.formulaReadOnly__c);
                    else
                        f.readOnly__c = true;
                }

            });
        });

    }

    verifyRequiredField(event){
        // Prevents the anchor element from navigating to a URL.
        // event.preventDefault();

        let sections = this.sections;
        let verify = true;

        sections.forEach((s) => {
            s.fields.forEach((f) => {

                if(f.required__c && (f.value == undefined || f.value == null || ( f.value == '' && f.value != 0 ) )){
                    if((f.hasOwnProperty('formulaVisibility__c') && eval(f.formulaVisibility__c)) || f.visibility__c){
                        console.log('@@@ field ' , JSON.stringify(f));
                        verify = false;
                    }
                }
            });
        });

        // Creates the event with the contact ID data.
        const selectedEvent = new CustomEvent('unlockbtninviotime', { detail : { isCompleted: verify,  Id: this.item.Id }});

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

    }

    handleBtn(event){
        var action = event.target.name;
        let credito = {...this.item};

        saveCredito({credito: JSON.stringify(credito)})
            .then(result => {

                console.log('SV saveCredito:v', result);

                if(action == 'Ricalcola IRR'){
                    if(credito.Imposta__c != undefined && credito.WGC_Val_Nom_Esigibile__c != undefined && ( credito.WGC_Data_presentazione_rimborso__c != undefined || credito.WGC_Data_rimborso_presunto__c != undefined ) && credito.WGC_Gg_Maturazione_Interessi__c != undefined && credito.WGC_Data_cessione_credito__c != undefined && credito.WGC_Offerta_perc__c != undefined &&
                        credito.WGC_Importo_Saldo__c != undefined && credito.WGC_Prezzo_di_acquisto__c != undefined &&
                        credito.WGC_Data_Saldo__c != undefined && credito.WGC_Data_DSO__c != undefined && credito.WGC_Costo_notaio__c != undefined && 
                        credito.WGC_Data_pagamento_notaio__c != undefined && credito.WGC_Costo_contenzioso__c != undefined && 
                        credito.WGC_Data_Pagamento_Contenzioso__c != undefined ){
                            this.cmpModal = 'c-wgc_pc_cart_modal_irr';
                            this.modalParams = { title: action, componentParams: { creditoId: this.item.Id } };
                            this.showModal = true;
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Attenzione!',
                                message: 'Controllare di aver compilato tutti i campi necessari',
                                variant: 'warning'
                            })
                        )
                    }
                } else if(action == 'Ricalcola DSO'){
                    if(( credito.WGC_Data_presentazione_rimborso__c != undefined || credito.WGC_Data_rimborso_presunto__c != undefined ) &&
                        credito.WGC_AdE_Territoriale__c != undefined && credito.Imposta__c != undefined && credito.WGC_Tipologia_Incasso__c != undefined &&
                        credito.ValoreNominale__c != undefined){
                            this.cmpModal = 'c-wgc_pc_cart_modal_dso';
                            this.modalParams = { title: action, componentParams: { creditoId: this.item.Id } };
                            this.showModal = true;
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Attenzione!',
                                message: 'Controllare di aver compilato tutti i campi necessari',
                                variant: 'warning'
                            })
                        )
                    }
                } else if(action == 'Ricalcola Interessi Stimati'){
                    if(credito.WGC_Data_DSO__c != undefined && ( credito.WGC_Data_presentazione_rimborso__c != undefined || credito.WGC_Data_rimborso_presunto__c != undefined ) && credito.ValoreNominale__c != undefined && credito.Imposta__c != undefined){
                            calcolaInteressi({ creditoId: this.item.Id }).then(res => {
                                
                            }).catch(error => {

                            }).finally(() => {
                                const eventToast = new ShowToastEvent({
                                    "title": "Successo!",
                                    "variant": "success",
                                    "message": "Il credito è stato aggiornato correttamente!"
                                });
                                this.dispatchEvent(eventToast);
                                this.connectedCallback();
                            });
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
            }).catch((error) => {
                console.log('SV ERROR', error);
            }).finally(() => {
            });
    }

    handleCloseModal(event){
        this.showModal = event.detail.open;
        const eventToast = new ShowToastEvent({
            "title": "Successo!",
            "variant": "success",
            "message": "Il credito è stato aggiornato correttamente!"
        });
        this.dispatchEvent(eventToast);
        this.connectedCallback();
    }

    get btnFieldDisabled(){
        return this.item.WGC_Credito_Confermato__c || this.userInfo.Profile.Name == 'IFIS - Crediti Erariali';
    }
}