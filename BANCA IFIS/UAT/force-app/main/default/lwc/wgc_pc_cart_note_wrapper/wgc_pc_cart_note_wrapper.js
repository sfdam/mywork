import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssCartPC from '@salesforce/resourceUrl/cssCartPC';
import updateField from '@salesforce/apex/WizardOpportunityController.updateField';

const openClass = 'cstm-accordion-icon';
const closeClass = 'cstm-accordion-icon collapsed';
const labelCompilato = 'Compilato';
const labelNonCompilato = 'Da compilare';
 
export default class Wgc_pc_cart_note_wrapper extends LightningElement {

    @api
    recordId;

    @track
    privatePayload;

    @track
    privateReadOnly = false;

    @track
    listaNote = [ {label: "DESCRIZIONE DELL'AZIENDA", stateLabel: labelNonCompilato, value: '', placeholder: 'Inserisci una descrizione dell\'azienda...', apiName: 'WGC_Descrizione_dell_azienda__c', isCompleted: false, showIcon: true, isOpen: false, class: 'cstm-accordion-icon', showBtnConferma: true, required: true }, 
                    {label: 'DESCRIZIONE DELLA PROPOSTA', stateLabel: labelNonCompilato, value: '', placeholder: 'Inserisci una descrizione della proposta...', apiName:'WGC_Descrizione_Operativit_Proposta__c', isCompleted: false, showIcon: true, isOpen: false, class: 'cstm-accordion-icon', showBtnConferma: true, required: true },
                    //{label: 'DEROGHE CONDIZIONI SUI FIDI DI COPPIA', stateLabel: labelNonCompilato, value: '',  placeholder: 'Inserisci una descrizione delle deroghe condizioni sui fidi di coppia...', apiName:'WGC_Note_Condizioni_Economiche__c', isCompleted: false, showIcon: false, isOpen: false, class: 'cstm-accordion-icon', showBtnConferma: true },
                    {label: 'DESCRIZIONE CONCORRENZA', stateLabel: labelNonCompilato, value: '',  placeholder: 'Inserisci una descrizione della concorrenza...', apiName:'WGC_Descrizione_concorrenza__c', isCompleted: false, showIcon: false, isOpen: false, class: 'cstm-accordion-icon', showBtnConferma: true, required: false },
                    {label: 'NOTE AUTOMATICHE', stateLabel: labelCompilato, placeholder: '', apiName:'WGC_Note_automatiche__c', isCompleted: true, showIcon: false, isOpen: false, class: 'cstm-accordion-icon', showBtnConferma: false, disabled: true, required: false }
                ];
    
    connectedCallback(){
        loadStyle(this, cssCartPC);
    }

    renderedCallback(){
        this.checkNoteCompleted();
    }

    /* GETTER & SETTER */

    @api
    get readOnly(){
        return this.privateReadOnly;
    }

    set readOnly(v){
        this.privateReadOnly = v;
        this.setupNoteRO(v);
    }

    @api
    get payload(){
        return this.privatePayload;
    }

    set payload(p){
        this.privatePayload = p;
        this.setupNote();
    }
    

    /* GETTER & SETTER */

    /* FUNCTIONS */

    setupNote(){
        let opportunity = this.privatePayload.opportunityData;
        let account = this.privatePayload.opportunityData.Account;

        this.listaNote.forEach((n) => {
            if(opportunity.hasOwnProperty(n.apiName)){
                n.value = opportunity[n.apiName];
                n.isCompleted = true;
                n.stateLabel = labelCompilato;
            } else if(account.hasOwnProperty(n.apiName)){
                n.value = account[n.apiName];
                n.isCompleted = true;
                n.stateLabel = labelCompilato;
            }
        });
    }

    setupNoteRO(ro){
        this.listaNote.forEach(n => {
            n.disabled = ro;
        });
    }

    checkNoteCompleted(){
        let check = this.listaNote.filter((n) => { return !n.isCompleted && n.isRequired });
        if(check.length == 0)
            this.dispatchEvent(new CustomEvent('stepwizard', { bubbles: true, composed: true, detail: { step: 'note' } }));
    }

    /* FUNCTIONS */

    /* EVENT HANDLERS */

    toggleNote(event){
        let nota = event.target.name;

        this.listaNote.forEach((n) => {
            if(n.label == nota){
                n.isOpen = !n.isOpen;
                if(n.isOpen)
                    n.class = closeClass;
                else
                    n.class = openClass;
            }
        })
    }

    changeNotaVal(event){
        let nota = event.target;

        this.listaNote.forEach((n) => {
            if(nota.name == n.apiName)
                n.value = nota.value;
        })
    }

    confirmNote(event){
        let nota = event.target;
        let record = this.recordId;

        if(nota.name == 'WGC_Descrizione_dell_azienda__c')
            record = this.privatePayload.opportunityData.AccountId;

        this.dispatchEvent(
            new CustomEvent('cart_pc_call_server', 
                { bubbles: true, composed: true, 
                    detail: { params: { field: nota.name, value: nota.value, objectId: record  }, method: updateField, methodName: 'reload' }
                }
            )
        );    
    }

    /* EVENT HANDLERS */
}