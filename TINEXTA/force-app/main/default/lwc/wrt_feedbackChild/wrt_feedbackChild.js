import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import FEEDBACK_OBJECT from '@salesforce/schema/Feedback__c';
import VISITAEFFETTUATA_FIELD from '@salesforce/schema/Feedback__c.Stato_visita__c';
import TIPOVISITA_FIELD from '@salesforce/schema/Feedback__c.Tipo_Visita__c';
import BUSINESSAREA_FIELD from '@salesforce/schema/Feedback__c.Business_Area__c';
import ESITO_FIELD from '@salesforce/schema/Feedback__c.Esito__c';
import MOTIVO_FIELD from '@salesforce/schema/Feedback__c.Motivo_di_non_interesse__c';
import CONSULENTE_FIELD from '@salesforce/schema/Feedback__c.Consulente__c';

export default class FeedbackChild extends LightningElement {

    @track _feedback = { sObjectType: 'Feedback'/*, Stato_visita__c: 'Visita eseguita'*/ };
    @track _parentFeedback = { Stato_visita__c: 'Visita eseguita' };
    @track eventObject = 'Generico';
    // @track objectOptions = ;
    @track createOpty = false;
    @track createTask = false;
    // @track createEvent = false;
    // @track _event = { sObjectType: 'Event', Subject: '', StartDateTime: new Date(Date.now()).toISOString(), EndDateTime: new Date(Date.now() + (1*60*60*1000)).toISOString()};
    @track task = { sObjectType: 'Task', Subject: '' /*Stesso della visita*/, WhatId: undefined, /*Stesso della visita*/IsReminderSet: true, ReminderDateTime: new Date().toISOString(), ActivityDate: new Date().toISOString() };

    @track _taskFields = {};

    @track _parentEvent = {};

    @track prepopulatedAccount = { objId: undefined, sObjectName: 'Account', iconName: 'standard:account', name: undefined };

    @wire(getObjectInfo, { objectApiName: FEEDBACK_OBJECT })
    objectInfo;

    @track visitaEffettuataOpts = [{ label: 'Visita eseguita', value: 'Visita eseguita'}];
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: VISITAEFFETTUATA_FIELD })
    visitaEffettuataOptions({data, error}) {
        if (error) {
        } else if (data) {
            this.visitaEffettuataOpts = data.values;

        }
    }

    @track tipoVisitaOpts;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: TIPOVISITA_FIELD })
    tipoVisitaOptions({data, error}) {
        if (error) {
        } else if (data) {
            this.tipoVisitaOpts = data.values;

        }
    }

    @track businnessAreaOpts;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: BUSINESSAREA_FIELD })
    businessAreaOptions({data, error}) {
        if (error) {
        } else if (data) {
            this.businnessAreaOpts = data.values;

        }
    }

    @track esitoOpts;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: ESITO_FIELD })
    esitoOptions({data, error}) {
        if (error) {
        } else if (data) {
            this.esitoOpts = data.values;

        }
    }

    @track nonInteressatoOpts;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: MOTIVO_FIELD })
    nonInteressatoOptions({data, error}) {
        if (error) {
        } else if (data) {
            this.nonInteressatoOpts = data.values;

        }
    }

    @track consulenteOpts;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: CONSULENTE_FIELD })
    consulenteOptions({data, error}) {
        if (error) {
        } else if (data) {
            this.consulenteOpts = data.values;

        }
    }

    targetOpts = [{ label: 'Si', value: 'Si'},  {label: 'No', value: 'No'}];

    placeholder = 'Seleziona un\'opzione';

    //Metodo utilizzato dal parent per recuperare tutte le informazioni dei record figli
    @api
    getRecordInfo(){
        //Recupero l'oggetto feedback
        let childFeedback = this.feedback;
        //Assegno il WhatId e Articolo__c preso dalla lookup
        // let whatId;
        console.log("@@@ this.template.querySelector('c-custom-lookup') " , this.template.querySelectorAll('c-custom-lookup'));

        if(this.template.querySelector('c-custom-lookup') != null){
            let lookups = this.template.querySelectorAll('c-custom-lookup');
            console.log('@@@ lookups ' , lookups.length);
            lookups.forEach(l => {
                if(l.selectedSObject != undefined){
                    console.log('@@@ l ' , JSON.stringify(l.selectedSObject));
                    if(l.selectedSObject.sObjectName == 'Account'){
                        this.task.WhatId = l.selectedSObject.objId;
                    }
                    if(l.selectedSObject.sObjectName == 'Contact' || l.selectedSObject.sObjectName == 'Lead')
                        this.task.WhoId = l.selectedSObject.objId;

                    if(l.selectedSObject.sObjectName == 'Product2'){
                        childFeedback.Articolo__c = l.selectedSObject.objId;
                        childFeedback.Articolo__r = {};
                        childFeedback.Articolo__r.Id = childFeedback.Articolo__c;
                        childFeedback.Articolo__r.Name = l.selectedSObject.name;
                    }
                }
            });
        }
        //Utilizzo un oggetto wrapper
        if(childFeedback.Esito__c == 'Interessato' || childFeedback.Esito__c == 'Interessato senza requisiti'){
            childFeedback.Motivo_di_non_interesse__c = null;
            childFeedback.Consulente__c = null;
        }
        console.log('@@@ childFeedback ' , childFeedback);
        
        let wrapperObj = { childFeedback: childFeedback, isCompleted: this.validateFeedback(childFeedback), createOpty: this.createOpty, task: this.createTask ? this.task : null };
        return wrapperObj;
    }

    //Gestisce la checkbox dell'opportunità
    handleChangeOpty(event){
        this.createOpty = event.target.checked;
    }

    handleChangeTask(event){
        this.createTask = event.target.checked;
    }

    handleChangeEvent(event){
        this.createEvent = event.target.checked;
    }

    //Gestisce i campi
    handleChangeCheckboxEvent(event){
        let properties = event.target.name.split('-');
        this[properties[0]][properties[1]] = event.target.checked;
    }

    handleChangeFieldEvent(event){
        let properties = event.target.name.split('-');
        this[properties[0]][properties[1]] = event.target.value;
    }

    //Gestisce la picklist dell'oggetto per il task
    handleChangeObjectOptions(event){
        this.eventObject = event.detail.value;
    }

    validateFeedback(feedback){
        let check = true;
        if(this.visitaEseguita && feedback.Business_Area__c == undefined){
            check = false;
        }

        if(this.visitaEseguita && feedback.Target__c == undefined)
            check = false;

        if(this.visitaEseguita && feedback.Esito__c == undefined)
            check = false;

        if(this.visitaEseguita && feedback.Esito__c == 'Non interessato' && feedback.Motivo_di_non_interesse__c == undefined)
            check = false;

        if(this.visitaEseguita && feedback.Esito__c == 'Non interessato' && feedback.Motivo_di_non_interesse__c == 'Altri consulenti' && feedback.Consulente__c == undefined)
            check = false;

        if(this.createOpty && feedback.Articolo__c == undefined)
            check = false;

        return check;
    }

    //GETTER & SETTER - START

    @api
    get feedback(){
        return this._feedback;
    }

    set feedback(value){
        this._feedback = value;
    }

    @api
    get parentFeedback(){
        return this._parentFeedback;
    }

    set parentFeedback(v){
        this._parentFeedback = v;
    }

    // get visitaAnnullata(){
    //     return this._parentFeedback.Stato_visita__c == 'Visita annullata';
    // }
    
    get visitaEseguita(){
        return this._parentFeedback.Stato_visita__c == 'Visita eseguita';
    }

    get nonInteressato(){
        return this._feedback.Esito__c == 'Non interessato';
    }

    get altriConsulenti(){
        return this._feedback.Motivo_di_non_interesse__c == 'Altri consulenti';
    }

    @api
    get taskFields(){
        return this._taskFields;
    }

    set taskFields(value){
        this._taskFields = value;
        this.task.WhatId = value.whatId;
        this.task.WhoId = value.whoId;
        this.prepopulatedAccount.objId = value.whatId != undefined ? value.whatId : value.whoId;
        this.prepopulatedAccount.sObjectName = value.whatId != undefined ? 'Account' : value.whoId != undefined ? value.whoId.startsWith('00Q') ? 'Lead' : 'Contact' : '';//'Account';
        this.prepopulatedAccount.name = value.whatName != undefined ? value.whatName : value.whoName;
        this.prepopulatedAccount.iconName = value.whatId != undefined ? 'standard:account' : value.whoId != undefined ? value.whoId.startsWith('00Q') ? 'standard:lead' : 'standard:contact' : ''; //'standard:account';
        this.task.Subject = value.Subject;
    }

    @api
    get parentEvent(){
        return this._parentEvent;
    }

    set parentEvent(v){
        this._parentEvent = v;
    }

    get isAccountParentEvent(){
        return this._parentEvent.WhatId != undefined || (this._parentEvent.WhoId != undefined && this._parentEvent.WhoId.startsWith('003'));
    }

    get SObjectName(){
        if(this._parentEvent.WhatId != undefined){
            this.prepopulatedAccount.sObjectName = 'Account';
            this.prepopulatedAccount.iconName = 'standard:account';
            return 'Account';
            // if(this._parentEvent.WhatId.startsWith('0011X'))
            //     return 'Account';
        } else if(this._parentEvent.WhoId != undefined){
            if(this._parentEvent.WhoId.startsWith('00Q')){
                this.prepopulatedAccount.sObjectName = 'Lead';
                this.prepopulatedAccount.iconName = 'standard:lead';
                return 'Lead';
            }
            if(this._parentEvent.WhoId.startsWith('003')){
                this.prepopulatedAccount.sObjectName = 'Contact';
                this.prepopulatedAccount.iconName = 'standard:contact';
                return 'Contact';
            }
        }

        // this.prepopulatedAccount.objId = value.whatId;
        // this.prepopulatedAccount.name = value.whatName;
    }

    // get lookupIcon(){
    //     return 'standard:' + this.SObjectName.toLowerCase();
    // }

    get calculatedWhereCondition(){
        switch (this.SObjectName){
            case 'Account':
                return ' Censito_Warrant__c = TRUE';
                break;
            case 'Lead':
                return ' RecordType.DeveloperName =\'Warrant\'';
                break;
            case 'Contact':
                return ' RecordType.DeveloperName =\'Warrant\'';
                break;
        }
        // return ' Censito_Warrant__c = true';
    }

    // @api
    // get event(){
    //     return this._event;
    // }

    // set event(v){
    //     this._event.Subject = v.Subject;
    //     // this._event = v;
    // }

    get articoloRequired(){
        return this.createOpty;
    }

    //GETTER & SETTER - END
}