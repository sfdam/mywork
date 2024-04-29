import { LightningElement, track, api, wire } from 'lwc';
import saveFeedback from '@salesforce/apex/FeedbackController.saveFeedback';
import saveChildFeedbacks from '@salesforce/apex/FeedbackController.saveChildFeedbacks';
import getFeedbacks from '@salesforce/apex/FeedbackController.getFeedbacks';
import getParentEvent from '@salesforce/apex/FeedbackController.getParentEvent';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import FEEDBACK_OBJECT from '@salesforce/schema/Feedback__c';
import VISITAEFFETTUATA_FIELD from '@salesforce/schema/Feedback__c.Stato_visita__c';
import TIPOVISITA_FIELD from '@salesforce/schema/Feedback__c.Tipo_Visita__c';
import TIPOLOGIAVISITA_FIELD from '@salesforce/schema/Feedback__c.Tipologia_di_visita__c';
import BUSINESSAREA_FIELD from '@salesforce/schema/Feedback__c.Business_Area__c';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class WRT_Feedback_RelatedList extends LightningElement {
    //Contiene l'id dell'evento
    @api recordId;
    //Contiene l'evento
    //Istanziato per nascondere inizialmente il componente
    @track _record = { };
    //Gestisce la visibilità della modale
    @track openModal = false;
    //Contiene l'oggetto Feedback__c
    @track feedbackParent = { sObjectType: 'Feedback__c', Stato_visita__c: 'Visita eseguita' };
    //Contiene i figli dell'oggetto Feedback__c
    @track childFeedbacks = [];

    @track createEvent = false;
    @track _event = { sObjectType: 'Event', Subject: '', StartDateTime: new Date(Date.now()).toISOString(), EndDateTime: new Date(Date.now() + (1*60*60*1000)).toISOString()};
    @track createTask = false;

    @track task = { sObjectType: 'Task', Subject: '' /*Stesso della visita*/, WhatId: undefined, /*Stesso della visita*/IsReminderSet: true, ReminderDateTime: new Date().toISOString(), ActivityDate: new Date().toISOString() };

    @track prepopulatedAccount = { objId: undefined, sObjectName: 'Account', iconName: 'standard:account', name: undefined };

    //Record tree-grid
    @track relatedListFeedback = [];
    //Righe aperte tree-grid
    @track expandedRows = [];

    @track isLoading = false;
    //Disabilita il pulsante new
    @track newDisabled = true;

    //Colonne tree-grid
    columns = [{ label: 'Name', fieldName: 'Id', type: 'url', typeAttributes: { label: { fieldName: 'Name'}, target: '_blank'},             initialWidth: FORM_FACTOR == 'Small' ? 200 : 140 },
                { label: 'Stato visita', fieldName: 'Stato_visita__c', type: 'text', initialWidth: FORM_FACTOR == 'Small' ? 250 : 150},
                { label: 'Modalità visita', fieldName: 'Tipo_Visita__c', type: 'text', initialWidth: FORM_FACTOR == 'Small' ? 250 : 150},
                { label: 'Esito', fieldName: 'Esito__c', type: 'text', initialWidth: FORM_FACTOR == 'Small' ? 250 : 150},
                { label: 'Business Area', fieldName: 'Business_Area__c', type: 'text', initialWidth: FORM_FACTOR == 'Small' ? 250 : 150},
                { label: 'Target', fieldName: 'Target__c', type: 'text', initialWidth: 80},
                { label: 'Opportunità', fieldName: 'Opportunita__c', type: 'url', typeAttributes: { label: { fieldName: 'OpportunitaName'}, target: '_blank'}, initialWidth: FORM_FACTOR == 'Small' ? 250 : 150},
                { label: 'Articolo', fieldName: 'Articolo__c', type: 'url', typeAttributes: { label: { fieldName: 'ArticoloName'}, target: '_blank'}, initialWidth: FORM_FACTOR == 'Small' ? 250 : 150},
                { label: 'Task', fieldName: 'IdTask__c', type: 'url', typeAttributes: { label: { fieldName: 'TaskName'}, target: '_blank'}, initialWidth: FORM_FACTOR == 'Small' ? 250 : 150}
                ];

    @track taskFields = {};

    placeholder = 'Seleziona un\'opzione';

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

    @track primaVisitaOpts;
    @wire(getPicklistValues, { recordTypeId:'$objectInfo.data.defaultRecordTypeId', fieldApiName: TIPOLOGIAVISITA_FIELD })
    primaVisitaOptions({ data, error }) {
        if(data){
            this.primaVisitaOpts = data.values;
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

    targetOpts = [{ label: 'Si', value: 'Si'},  {label: 'No', value: 'No'}];

    connectedCallback(){
        getParentEvent({ recordId: this.recordId }).then(res => {
            this._record = res;
            this.newDisabled = res.Feedback__c != undefined || new Date(res.StartDateTime) >= new Date(Date.now());
            this.task.Subject = res.Subject;
            this.task.WhatId = res.WhatId;
            this.task.WhoId = res.WhoId;
            this._event.WhatId = res.WhatId;
            this._event.Subject = res.Subject;
            this._event.WhoId = res.WhoId;

            this.prepopulatedAccount.objId = res.WhatId != undefined ? res.WhatId : res.WhoId;
            this.prepopulatedAccount.sObjectName = res.WhatId != undefined ? 'Account' : res.WhoId != undefined ? res.WhoId.startsWith('00Q') ? 'Lead' : 'Contact' : '';
            console.log('@@@ res ' , res);
            console.log('@@@ res.what ' , res.What);
            this.prepopulatedAccount.name = res.What != undefined ? res.What.Name : res.Who.Name;
            this.prepopulatedAccount.iconName = res.WhatId != undefined ? 'standard:account' : res.WhoId != undefined ? res.WhoId.startsWith('00Q') ? 'standard:lead' : 'standard:contact' : '';

            return getFeedbacks({ recordId: this._record.Feedback__c });
        }).then(res => {
            //Sistemo url per redirect
            let dataTreeGrid = [];
            var parentFeedback;
            if(this._record.Feedback__c != undefined){
                parentFeedback = { Id: '/'+this._record.Feedback__c, Name: this._record.Feedback__r.Name, Stato_visita__c: this._record.Feedback__r.Stato_visita__c, Tipo_Visita__c: this._record.Feedback__r.Tipo_Visita__c/*Esito__c: this._record.Feedback__r.Esito__c, , Business_Area__c: this._record.Feedback__r.Business_Area__c, Target__c: this._record.Feedback__r.Target__c*/ };
            }
            
            let feedbacks = [];
            res.forEach(r => {
                let newFeedback = r.feedback;
                newFeedback.Id = '/' + newFeedback.Id;
                if(newFeedback.ParentFeedback__r != undefined)
                    newFeedback.ParentFeedback__r.Name = '/'+ newFeedback.ParentFeedback__c;
                if(newFeedback.Opportunita__c != undefined){
                    newFeedback.Opportunita__c = '/'+newFeedback.Opportunita__c;
                    newFeedback.OpportunitaName = newFeedback.Opportunita__r.Name;
                }
                if(newFeedback.IdTask__c != undefined){
                    newFeedback.TaskName = r.task.Subject;
                    newFeedback.IdTask__c = '/'+newFeedback.IdTask__c;
                }
                if(newFeedback.Articolo__c != undefined){
                    newFeedback.ArticoloName = newFeedback.Articolo__r.Name;
                    newFeedback.Articolo__c = '/'+newFeedback.Articolo__c;
                }
                feedbacks.push(newFeedback);
            })

            if(parentFeedback != undefined){
                parentFeedback._children = feedbacks;
                dataTreeGrid.push(parentFeedback);
                this.relatedListFeedback = dataTreeGrid;
                this.expandedRows.push(parentFeedback.Id);
            }

        }).catch(err => {
            console.log('@@@ err ' , err);
        });
    }

    //Apre la modal e genera un figlio dell'oggetto Feedback__c
    newFeedback(event){
        this.openModal = true;
        this.addNewChildFeedback();
    }

    //Chiude la modal e resetta la maschera
    closeModal(event){
        this.openModal = false;
        this.resetData();
    }

    saveFeedback(event){
        this.isLoading = true;
        let childFeedbacks = this.template.querySelectorAll('c-wrt_feedback-child');
        let childFeedbacksInfo = [];
        let checkChildren = true;
        // if(this.feedbackParent.Stato_visita__c == 'Visita eseguita'){
            //Recupero i dati dai feedback figli
        childFeedbacks.forEach(cf => {
            let childrenInfo = cf.getRecordInfo();
            if(!childrenInfo.isCompleted)
                checkChildren = false;

            childrenInfo.isCompleted = undefined;
            childFeedbacksInfo.push(childrenInfo);
        })
        // }
        
        let checkParent = this.validateFeedback();

        if(!checkParent || !checkChildren){
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Errore!",
                    message: "Compila tutti i campi obbligatori",
                    variant: "error"
                })
            )
            return;
        }

        if(this.createEvent){
            if(this._event.StartDateTime >= this._event.EndDateTime){
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Errore!",
                        message: "La data di inizio non può essere maggiore della data di fine dell'evento",
                        variant: "error"
                    })
                )
                return;
            }
        }

        this.feedbackParent.IdEvento__c = this.recordId;
        if(this.visitaAnnullata){
            this.feedbackParent.Tipo_Visita__c = null;
            this.feedbackParent.Tipologia_di_visita__c = null;
        }

        //Assegno le lookup di task e event
        // let lookups = this.template.querySelectorAll('c-custom-lookup');
        saveFeedback({ recordId: this.recordId, feedback: this.feedbackParent, childFeedbacks: childFeedbacksInfo, task: this.createTask ? this.task : null, event: this.createEvent ? this._event : null }).then(result => {
            if(result == null)
                this.resetData();

            return saveChildFeedbacks({ feedbacks: result })
        }).then(response => {
            this.isLoading = false;
            this.closeModal();
            this.connectedCallback();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Successo!",
                    message: "Salvataggio avvenuto con successo",
                    variant: "success"
                })
            )
        }).catch(err => {
            this.isLoading = false;
            console.log('@@@ err ' , err);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Errore!",
                    message: err.body.message,
                    variant: "error"
                })
            )
        });
    }

    //Aggiunge un record figlio dell'oggetto Feedback__c
    addNewChildFeedback(){
        let newChildFeedback = { sObjectType: 'Feedback__c' };
        this.taskFields = { whatId: this._record.WhatId != undefined ? this._record.WhatId : undefined, whoId: this._record.WhoId, whoName: this._record.Who != undefined ? this._record.Who.Name : undefined, whatName: this._record.What != undefined ? this._record.What.Name : undefined, Subject: this._record.Subject };
        this.childFeedbacks.push(newChildFeedback);
    }

    //Funzione per resettare i dati
    resetData(){
        this.feedbackParent = { sObjectType: 'Feedback__c', Stato_visita__c: 'Visita eseguita'};
        this.childFeedbacks = [];
    }

    //Gestisce i campi
    handleChangeCheckboxEvent(event){
        let properties = event.target.name.split('-');
        console.log('@@@ properties ' , properties);
        this[properties[0]][properties[1]] = event.target.checked;
        console.log('@@@ properties[0] ' , this[properties[0]]);
    }

    handleChangeFieldEvent(event){
        let properties = event.target.name.split('-');
        console.log('@@@ properties ' , properties);
        this[properties[0]][properties[1]] = event.target.value;
        console.log('@@@ properties[0] ' , this[properties[0]]);
    }

    handleChangeTask(event){
        this.createTask = event.target.checked;
    }

    handleChangeEvent(event){
        this.createEvent = event.target.checked;
    }

    validateFeedback(){
        let check = true;
        if(this.visitaEseguita && this.feedbackParent.Stato_visita__c == undefined)
            check = false;
        if(this.visitaEseguita && this.feedbackParent.Tipo_Visita__c == undefined)
            check = false;
        if(this.visitaEseguita && this.feedbackParent.Tipologia_di_visita__c == undefined)
            check = false;
        // if(this.tipoVisita1 && this.feedbackParent.Business_Area__c == undefined)
        //     check = false;

        return check;
    }

    // validateFeedback(feedback){
    //     let check = true;
    //     if(this.visitaEseguita && feedback.Business_Area__c == undefined){
    //         check = false;
    //     }

    //     if(this.visitaEseguita && feedback.Target__c == undefined)
    //         check = false;

    //     if(this.visitaEseguita && feedback.Esito__c == undefined)
    //         check = false;

    //     if(this.visitaEseguita && feedback.Esito__c == 'Non interessato' && feedback.Motivo_di_non_interesse__c == undefined)
    //         check = false;

    //     if(this.visitaEseguita && feedback.Esito__c == 'Non interessato' && feedback.Motivo_di_non_interesse__c == 'Altri consulenti' && feedback.Consulente__c == undefined)
    //         check = false;

    //     return check;
    // }

    get feedbackNumber(){
        return this.relatedListFeedback.length;
    }

    get isFeedbackChild(){
        return this.relatedListFeedback.length > 0;
    }

    get visitaAnnullata(){
        return this.feedbackParent.Stato_visita__c == 'Visita annullata';
    }
    
    get visitaEseguita(){
        return this.feedbackParent.Stato_visita__c == 'Visita eseguita';
    }

    get visitaAltro(){
        return !this.visitaAnnullata && !this.visitaEseguita;
    }

    get tipoVisita1(){
        return this.feedbackParent.Tipologia_di_visita__c == 'Introduzione/affiancamento specialista/tecnico' || this.feedbackParent.Tipologia_di_visita__c == 'Risoluzione problematiche di gestione' || this.feedbackParent.Tipologia_di_visita__c == 'Contrasto, possibile disdetta o gestione della stessa';
    }

    get isAccountPopulated(){
        return this._record.WhatId != undefined || this._record.WhoId != undefined;
    }

    get isChildVisible(){
        return this.visitaEseguita && !this.tipoVisita1;
    }

    // get nonInteressato(){
    //     return this.feedbackParent.Esito__c == 'Non interessato';
    // }

    // get altriConsulenti(){
    //     return this.feedbackParent.Motivo_di_non_interesse__c == 'Altri consulenti';
    // }
}