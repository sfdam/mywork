import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssCartPC from '@salesforce/resourceUrl/cssCartPC';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDatiCrediti from '@salesforce/apex/WGC_PC_CartController.getCreditiLinea';
import saveCrediti from '@salesforce/apex/WGC_PC_CartController.saveCrediti';


export default class Wgc_pc_cart_crediti_wrapper extends LightningElement {

    @api
    recordId;

    @api
    recordType;

    @track
    state = {};

    @track
    crediti = [];

    @track
    privateCodProd;

    @track
    activeCredito = 0;

    @track
    isAllCompleted = false;

    @api
    rendered = false;

    // @track
    // rendered = false;

    connectedCallback(){

    }

    renderedCallback(){

    }

    /* GETTER & SETTER */

    /*
    @api
    get payload(){
        return this.state.payload;
    }

    set payload(p){
        this.state.payload = p;
    }
    */

    @api
    get linea(){
        return this.state.linea;
    }

    set linea(l){
        console.log('@@@ l ' , JSON.stringify(l));
        this.state.linea = l;
        this.privateCodProd = l.codice;
        this.initialize();
        // this.rendered = true;
    }

    @api
    get userInfo(){
        return this.state.userInfo;
    }

    set userInfo(u){
        console.log('@@@ U wrapper ' , JSON.stringify(u));
        this.state.userInfo = u;
    }

    @api
    get pReadOnly(){
        return this.state.readOnly;
    }

    set pReadOnly(r){
        console.log('@@@ readOnly wrapper ' , r);
        this.state.readOnly = r;
    }

    get codProd(){
        return this.privateCodProd;
    }

    @api
    get isCompleted(){
        return this.isAllCompleted;
    }

    /*
    @api
    get codProd(){
        return this.privateCodProd;
    }

    set codProd(c){
        this.privateCodProd = c;
    }
    */

    /* GETTER & SETTER */

    /* FUNCTIONS */

    initialize(){
        //this.dispatchEvent(new CustomEvent('spinnerevt', { bubbles: true, composed: true, detail : { value: "show" } } ));

        getDatiCrediti({ opportunityId: this.recordId })
            .then(result => {
                console.log('@@@ result ' , JSON.stringify(result));

                if(result.success && result.data[0].length > 0){
                    result.data[0].forEach((c, ind) => {
                        c.name = 'Credito ' + ( ind + 1 );
                    });

                    this.crediti = result.data[0];
                }
            })
            .finally(() => {
                if(this.crediti.length == 0)
                    this.addCredito();

                this.progressivoIcar();
                console.log('@@@ this.crediti ' , this.crediti);
                this.rendered = true;
                //EVENTO PER LA GESTIONE DELLE IN BONIS
                this.dispatchEvent(
                    new CustomEvent('creditiwrapperrender' , { detail: { crediti: this.crediti } })
                )
            })
            .catch(err => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Errore',
                        message: err.message,
                        variant: 'error'
                    })
                )
            });
    }

    //Setto il progressivo nel campo legato al credito
    progressivoIcar(){
        this.crediti.forEach((c, ind) => {
            let index = (ind + 1).toString();
            let codice = this.generateProgressivo(index);
            c.WGC_Progressivo_ICAR__c = codice;
        });

        console.log('@@@ crediti icar ' , this.crediti);
    }

    //Genero un numero progressivo a partire dall'indice dei crediti generati in pagina in forma 001, 002...010
    generateProgressivo(i){
       var res = '000';
       res = res.slice(i.length) + i;
       return res;
    }

    /* FUNCTIONS */

    /* EVENT HANDLERS */

    //Genero un nuovo crediti associato alla linea
    addCredito(event){
        let crediti = [...this.crediti];
        crediti.push({ Id: "", name: "Credito " + ( this.crediti.length + 1 ), WGC_Linea__c: this.linea.id, WGC_Invia_Credito__c: false, Opportunita__c: this.recordId });
        this.crediti = crediti;
        this.progressivoIcar();
    }

    /*
    updateCreditoHandler(event){
        let completed = event.detail.isCompleted;
        if(event.detail.credito != null && event.detail.credito != undefined){
            var updatedCredito = event.detail.credito;
            //var allCrediti = [...this.linea.crediti];
            var allCrediti = [...this.crediti];
            allCrediti = allCrediti.map((cr) => {
                if(cr.name == updatedCredito.name){
                    cr = updatedCredito;
                }
                return cr;
            });

            console.log('@@@ allCrediti ' , allCrediti);
            console.log('@@@ old ' , this.isAllCompleted);
            console.log('@@@ new ' , completed);
            //this.state.crediti = allCrediti;
            this.crediti = allCrediti;
        }
        //this.isAllCompleted = this.isAllCompleted || event.detail.isCompleted;
        console.log('@@@ completed ' , completed );
        this.isAllCompleted = completed != null && completed != undefined ? completed : false;

        this.dispatchEvent(
            new CustomEvent('checkcompleted', { detail: { completed: this.isAllCompleted } } )
        )
    }*/

    updateFieldHandler(event){
        //Serve al passaggio al componente padre
    }

    //Usato quando chiudo la modale per predere i dati salvati dal servizio
    reInit(event){
        this.initialize();
    }

    saveCrediti(event){
        /*
        console.log('@@@ event.detail.show ' , event.detail.show);
        this.rendered = event.detail.show;
        */

        let resp = this.confirm();
        saveCrediti({ opportunityId: this.recordId, crediti: resp.crediti })
            .then(r => {
                console.log('@@@ result salvataggio crediti ' , r);
            })
            .catch(err => {
                console.log('@@@ err ' , err);
            });

    }

    handleToggle(event){
        console.log('@@@ detail ' , JSON.stringify(event.detail.openSections));
        this.activeCredito = event.detail.openSections.length == 0 ? ["0"] : event.detail.openSections; //event.detail.openSections.length == 0 ? ["0"] : parseInt(event.detail.openSections[0]);
    }

    @api
    confirm(){
        //console.log('@@@ confirm crediti init ' , JSON.stringify(this.linea.crediti));
        let allCrediti = this.template.querySelectorAll('c-wgc_pc_cart_credito');
        
        let isAllCompleted = this.isAllCompleted;

        let arrCrediti = new Array();
        allCrediti.forEach((cm) => {
            let resp = cm.confirm();

            arrCrediti = arrCrediti.concat(resp.credito);
            isAllCompleted = isAllCompleted || resp.isCompleted;
            console.log('@@@ prova2 ' , isAllCompleted);
        });

        arrCrediti.forEach((c) => {
            if(c.Id == "") c.Id = null;
        });
        this.isAllCompleted = isAllCompleted;
        console.log('@@@ isAllCompleted ' , this.isAllCompleted);
        console.log('@@@ arrCrediti ' , JSON.stringify(arrCrediti));

        let check = arrCrediti.filter((c) => { return c.WGC_Invia_Credito__c; });
        if(check.length == 0 && !this.readOnly){
            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         title: 'Attenzione!',
            //         message: 'Devi confermare almeno un credito per poter proseguire',
            //         variant: 'warning'
            //     })
            // )

            this.isAllCompleted = false;

        } else if(check.length > 0 && !this.readOnly){
            let checkCompleted = arrCrediti.filter(c => { 
                if(this.state.userInfo.Profile.Name == 'Amministratore del sistema' || this.state.userInfo.Profile.Name == 'IFIS - B/O Valutazione Fast Finance')
                    return c.WGC_Invia_Credito__c && !c.WGC_Completo_BO__c;
                else
                    return c.WGC_Invia_Credito__c && !c.WGC_Completo_Commerciale__c } );
            
            console.log('@@@ checkCompleted aaa ' , checkCompleted.length);
            if(checkCompleted.length > 0){
                // this.dispatchEvent(
                //     new ShowToastEvent({
                //         title: 'Attenzione',
                //         message: 'Compilare tutti i campi obbligatori per procedere',
                //         variant: 'warning'
                //     })
                // )

                this.isAllCompleted = false;
            }
        } //else {
        //     this.dispatchEvent(new CustomEvent('stepwizard', { bubbles: true, composed: true, detail: { step: 'documentazione' } }));
        // }

        let response = { isAllCompleted: this.isAllCompleted, crediti: arrCrediti };
        return response;
    }

    /* EVENT HANDLERS */

}