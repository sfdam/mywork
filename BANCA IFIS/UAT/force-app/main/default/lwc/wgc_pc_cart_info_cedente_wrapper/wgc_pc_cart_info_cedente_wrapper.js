import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssCartPC from '@salesforce/resourceUrl/cssCartPC';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import save from '@salesforce/apex/WGC_PC_CartController.saveSceltaProdotto';
import aggiornaCampo from '@salesforce/apex/WizardOpportunityController.updateField';

export default class Wgc_pc_cart_info_cedente_wrapper extends LightningElement {

    @api
    recordId;

    @track
    privateReadOnly;

    @track
    privatePayload;

    @track
    privateUserInfo;

    @track
    selectedProds;

    @track
    debitoreId;

    @track
    goNextBtn = false;

    connectedCallback(){
        loadStyle(this, cssCartPC);
    }

    renderedCallback(){

    }

    /* GETTER & SETTER */

    @api
    get readOnly(){
        return this.privateReadOnly;
    }

    set readOnly(r){
        this.privateReadOnly = r;
        console.log('@@@ r ' , r);
        this.goNextBtn = r;
        console.log('@@@ r2 ' , this.goNextBtn);
    }

    @api
    get payload(){
        return this.privatePayload;
    }

    set payload(p){
        this.privatePayload = p;
        if(this.selectedProds != undefined && p.debitori.length > 0){
            this.debitoreId = p.debitori[0].id;
            this.setupJoin();
        }
    }

    @api
    get userInfo(){
        return this.privateUserInfo;
    }

    set userInfo(u){
        this.privateUserInfo = u;
    }

    @api
    get selectedProducts(){
        return this.selectedProds;
    }

    set selectedProducts(p){
        this.selectedProds = p;
        if(this.privatePayload != undefined && this.privatePayload.debitori.length > 0 && this.selectedProds != undefined && this.selectedProds.length > 0)
            this.setupJoin();
    }

    get codProd(){
        if(this.selectedProds != undefined && this.selectedProds[0] != undefined)
            return this.selectedProds[0].name;
        else
            return undefined;
    }

    /* GETTER & SETTER */

    /* FUNCTIONS */

    setupJoin(){
        let p = {...this.privatePayload};
        let prod = [...this.selectedProds];

        let newJoin = {
            attore: p.debitori[0].id,
            servizio: prod[0].name
        };

        p.joinLineaDeb = newJoin;
        this.privatePayload = p;
    }

    /* FUNCTIONS */

    /* EVENT HANDLERS */

    goBackSceltaProdotto(event){
        this.dispatchEvent(new CustomEvent('stepwizard', { bubbles: true, composed: true, detail: { step: 'sceltaProdotto' } }));
    }

    confirmInfoCedente(event){        
        let child = this.template.querySelector('c-wgc_pc_cart_info_cedente');
        let resp = child.confirm();

        const saveEvt = new CustomEvent('cart_pc_call_server', { bubbles: true, composed:true, 
            detail : { params: { opportunityId: this.recordId, fields: JSON.stringify(resp), payload: JSON.stringify(this.payload)  }, method: save, methodName: 'reload' } });
        this.dispatchEvent(saveEvt);

        if(child.isCompleted)
            this.goNextBtn = true;

        aggiornaCampo({ field: 'WGC_Configurazione_Prodotti_Completa__c', value: child.isCompleted, objectId: this.payload.opportunityId });
        
    }

    goNextStep(event){
        this.dispatchEvent(new CustomEvent('stepwizard', { bubbles: true, composed: true, detail: { step: 'configuraProdotto' } }));
    }

    handleChangeField(event){
        let completed = event.detail != undefined && event.detail != null ? event.detail.value : false;
        if(!this.readOnly)this.goNextBtn = completed;
    }

    handleSpinner(event){
    }

    /* EVENT HANDLERS */

}