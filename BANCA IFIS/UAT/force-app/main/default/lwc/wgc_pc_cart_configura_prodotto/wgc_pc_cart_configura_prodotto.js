import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssCartPC from '@salesforce/resourceUrl/cssCartPC';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveCrediti from '@salesforce/apex/WGC_PC_CartController.saveCrediti';
 
export default class Wgc_pc_cart_configura_prodotto extends NavigationMixin(LightningElement) {
    @api
    recordId;

    @api
    readOnly;

    @track
    goNextBtn = false;

    // @track
    // rendered = false;

    @track
    privatePayload;

    @track
    privateUserInfo;

    @track
    selectedProds = [];

    @track
    crediti = [ { id: '', name: 'Credito 1', selected: false, idLinea: '' } ];

    @api
    linea;

    // @track
    // checkRemove = true;

    connectedCallback(){
        loadStyle(this, cssCartPC);
        // this.rendered = true;
    }

    renderedCallback(){
    }

    /* GETTER & SETTER */

    get goNextBtnV(){
        return this.goNextBtn || this.readOnly;
    }

    @api
    get payload(){
        return this.privatePayload;
    }

    set payload(p){
        this.privatePayload = p;
        this.linea = {...p.linee[0]};

        //let check = this.linea.crediti.filter((c) => { return c.WGC_Invia_Credito__c; });
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

    set selectedProducts(value){
        this.selectedProds = value;
    }

    get recordType(){
        return this.privatePayload.opportunityData.RecordType;
    }

    /*
    get codProd(){
        return this.linea.codice;
    }
    */

    /* GETTER & SETTER */

    /* EVENT HANDLERS */

    confirmCrediti(event){
        let result = this.template.querySelector('c-wgc_pc_cart_crediti_wrapper').confirm();
        this.goNextBtn = result.isAllCompleted != undefined ? result.isAllCompleted : true;

        this.dispatchEvent(
            new CustomEvent('cart_pc_call_server', { bubbles: true, composed: true, detail : { params: { opportunityId: this.recordId, crediti: result.crediti }, method: saveCrediti, methodName: 'reload' } })
        );
    }

    goBack(event){
        this.dispatchEvent(new CustomEvent('stepwizard', { bubbles: true, composed: true, detail: { step: 'inserimentoCed' } }));
    }

    goNextStep(event){
        console.log('@@@ avanti ' , JSON.stringify(this.linea.crediti));
        // let check = this.linea.crediti.filter((c) => { return c.WGC_Invia_Credito__c; });
        // if(check.length == 0 && !this.readOnly){
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: 'Attenzione!',
        //             message: 'Devi confermare almeno un credito per poter proseguire',
        //             variant: 'warning'
        //         })
        //     )
        // } else if(check.length > 0 && !this.readOnly){
        //     let checkCompleted = this.linea.crediti.filter(c => { 
        //         if(this.privateUserInfo.Profile.Name == 'Amministratore del sistema' || this.privateUserInfo.Profile.Name == 'IFIS - B/O Valutazione Fast Finanace')
        //             return c.WGC_Invia_Credito__c && !c.WGC_Completo_BO__c;
        //         else
        //             return c.WGC_Invia_Credito__c && !c.WGC_Completo_Commerciale__c } );
            
        //     console.log('@@@ checkCompleted aaa ' , checkCompleted.length);
        //     if(checkCompleted.length > 0){
        //         this.dispatchEvent(
        //             new ShowToastEvent({
        //                 title: 'Attenzione',
        //                 message: 'Compilare tutti i campi obbligatori per procedere',
        //                 variant: 'warning'
        //             })
        //         )
        //     }
        // } else {
            this.dispatchEvent(new CustomEvent('stepwizard', { bubbles: true, composed: true, detail: { step: 'documentazione' } }));
        // }
    }

    handleModal(event){
    }

    handleSpinner(event){
    }

    updateCompleted(event){
        this.goNextBtn = event.detail.completed;
    }

    /* EVENT HANDLERS */
}