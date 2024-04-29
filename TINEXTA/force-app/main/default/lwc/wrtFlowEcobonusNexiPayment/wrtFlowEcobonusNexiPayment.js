import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';

import paymentInit from '@salesforce/apex/NexiPaymentIntegrationCtrl.paymentInit';
import findPayment from '@salesforce/apex/NexiPaymentIntegrationCtrl.findPayment';

//Component utilizzato nel flow di ecobonus, effettua una chiamata al sistema di pagamento di nexi
//ricevo il callback url a cui poi l'utente viene reindirizzato
//Se il pagamento ha buon fine, mostro ok, altrimenti mostro messaggio di errore

export default class WrtFlowEcobonusNexiPayment extends NavigationMixin(LightningElement) {

    _amount;
    _firstName;
    _lastName;
    _email;
    _paymentId;
    fetch;
    @api infoPagamento;
    _check = false;
    _deniedTransaction = false;
    timeoutFinal = 0;
    redirectUrl;
    _canceledTransaction = false;


    /* GETTER & SETTER - START */

    @api
    get amount(){
        return this._amount;
    }

    set amount(value){
        this._amount = value;
        // if(this.FirstName != undefined && this.FirstName != null && this.LastName != undefined && this.LastName != null && this.Email != undefined && this.Email != null)
        //     this.initPagamento();
    }

    @api
    get FirstName(){
        return this._firstName;
    }

    set FirstName(v){
        this._firstName = v;
        // if(this.amount != undefined && this.amount != null && this.LastName != undefined && this.LastName != null && this.Email != undefined && this.Email != null)
        //     this.initPagamento();
    }

    @api
    get LastName(){
        return this._lastName;
    }

    set LastName(v){
        this._lastName = v;
        // if(this.FirstName != undefined && this.FirstName != null && this.amount != undefined && this.amount != null && this.Email != undefined && this.Email != null)
        //     this.initPagamento();
    }

    @api
    get Email(){
        return this._email;
    }

    set Email(v){
        this._email = v;
        // if(this.FirstName != undefined && this.FirstName != null && this.amount != undefined && this.amount != null && this.amount != undefined && this.amount != null)
        //     this.initPagamento();
    }

    @api
    get paymentId(){
        return this._paymentId;
    }

    set paymentId(v){
        this._paymentId = v;
    }

    @api
    get check(){
        return this._check;
    }

    set check(v){
        clearInterval(this.fetch);
        this._check = v;
    }

    @api
    get deniedTransaction(){
        return this._deniedTransaction;
    }

    set deniedTransaction(v){
        this._deniedTransaction = v;
    }

    get canceledTransaction(){
        return this._canceledTransaction;
    }

    set canceledTransaction(v){
        this._canceledTransaction = v;
    }

    get timeoutFinalOver(){
        return this.timeoutFinal;
    }

    set timeoutFinalOver(v){
        this.timeoutFinalOver = v;
    }

    get iconOk(){
        return this.infoPagamento == 'Approvato' ? true : false;
    }

    /* GETTER & SETTER - END */

    /* FUNCTIONS - START */

    //Funzione che richiama le api di Nexi ed inizializza il pagamento
    initPagamento(){
        this.template.querySelector('.cstm-btn-pagamento').classList.add('slds-hide');
        this.template.querySelector('.slds-spinner_container').classList.remove('slds-hide');    
        
        // navigator.sayswho = (function() {
        //     var ua = navigator.userAgent,
        //         tem,
        //         M = ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
        //     if (/trident/i.test(M[1])) {
        //         tem = /\brv[ :]+(\d+)/g.exec(ua) || [];
        //         return 'IE ' + (tem[1] || '');
        //     }
        //     if (M[1] === 'Chrome') {
        //         tem = ua.match(/\b(OPR|Edge)\/(\d+)/);
        //         if (tem != null) return tem.slice(1).join(' ').replace('OPR', 'Opera');
        //     }
        //     M = M[2] ? [ M[1], M[2] ] : [ navigator.appName, navigator.appVersion, '-?' ];
        //     if ((tem = ua.match(/version\/(\d+)/i)) != null) M.splice(1, 1, tem[1]);
        //     return M.join(' ');
        // })();
    
        // console.log(navigator.sayswho);
        paymentInit({ amount: this._amount, cardHolderName: this.FirstName + '|' + this.LastName, cardHolderEmail: this.Email }).then(response => {
            if(response.success){
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: response.redirectUrl
                    }
                });
                this.paymentId = response.paymentid;
                this.redirectUrl = response.redirectUrl;
                this.fetchResultTransazione();
            } else {
                console.log('@@@ error ' , response);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Errore!',
                        message: response.message,
                        variant: 'error'
                    })
                )
            }
        }).catch(err => {
            console.log('@@@ err ' , err);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore!',
                    message: err.body.message,
                    variant: 'error'
                })
            )
        })
    }

    //Funzione che continua a verificare per 60 secondi se è presente una transazione con medesimo paymentId
    //Superati i 60 secondi resettata la situazione
    fetchResultTransazione(){
        console.log('@@@ this.paymentId ' , this.paymentId);
        var that = this;
        // var timeoutFinal = 0;
        var timeout = 0;
        this.fetch = setInterval(function(){
            findPayment({ paymentId: that.paymentId }).then(response => {
                console.log('@@@ response ' , response);
                if(response.record.length > 0 && response.record[0].PaymentId__c == that.paymentId){
                    that.template.querySelector('.slds-spinner_container').classList.add('slds-hide');
                    that.template.querySelector('.cstm-container').classList.remove('slds-hide');
                    that.check = true;
                    that.infoPagamento = that.codificaResult(response.record[0].Result__c);
                    console.log('@@@ that.infoPagamento ' , that.infoPagamento);
                    if(that.infoPagamento == 'Non Approvato' || that.infoPagamento == 'Cancellato'){
                        //that.deniedTransaction = true;
                        that.canceledTransaction = true;
                        that.deniedTransaction = false;
                    } else {
                        that.deniedTransaction = false;
                        that.canceledTransaction = false;
                        const navigateNextEvent = new FlowNavigationNextEvent();
                        that.dispatchEvent(navigateNextEvent);
                    }
                } else if(timeout == 60){
                // } else if(timeout == 7200){
                    that.template.querySelector('.slds-spinner_container').classList.add('slds-hide');
                    that.template.querySelector('.cstm-container').classList.remove('slds-hide');
                    that.check = true;
                    that.deniedTransaction = true;
                    that.canceledTransaction = false;
                }
                this.timeoutFinalOver = this.timeoutFinalOver + 1;
                timeout ++;
            })
        }, 1000);
    }

    //Permette di riprovare il pagamento nel caso non fosse andato a buon fine
    retry(event){
        this.template.querySelector('.slds-spinner_container').classList.remove('slds-hide');
        this.template.querySelector('.cstm-container').classList.add('slds-hide');
        this.initPagamento();
    }

    retrySearch(event){
        console.log('@@@ retrySearch ');
        this.template.querySelector('.slds-spinner_container').classList.remove('slds-hide');
        this.template.querySelector('.cstm-container').classList.add('slds-hide');
        this.fetchResultTransazione();
    }

    codificaResult(result){
        let convertedResult;
        if(result == 'APPROVED' || result == 'COMPLETED'){
            convertedResult = 'Approvato'
        } else if(result == 'NOT APPROVED'){
            convertedResult = 'Non Approvato';
        } else if(result == 'CANCELED'){
            convertedResult = 'Cancellato';
        }

        return convertedResult;
    }

    /* FUNCTIONS - END */
}