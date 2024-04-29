import { LightningElement, api } from 'lwc';
import getContratto from '@salesforce/apex/ContrattoEcobonusCtrl.getContratto';
import URL from '@salesforce/label/c.URL_Stampa_Contratto_Ecobonus';
import getContrattoBlob from '@salesforce/apex/ContrattoEcobonusCtrl.getContrattoBlob';

export default class ContrattoEcobonusLwc extends LightningElement {

    _contactId;
    _idContratto;
    _opty;
    _contrattoText;

    isLoading = false;
    _errMsg;

    /* GETTER & SETTER - START */

    get optyFound(){
        return this._opty;
    }

    // set optyFound(v){
    //     this._opty = v;
    // }

    @api
    get contactId(){
        return this._contactId;
    }

    set contactId(v){
        this._contactId = v;
    }

    get idContratto(){
        return this._idContratto;
    }

    set idContratto(v){
        this._idContratto = v;
    }

    get errMsg(){
        return this._errMsg;
    }

    get contrattoText(){
        return this._contrattoText;
    }
    
    /* GETTER & SETTER - END */

    /* EVENT HANDLER - START */

    onChangeIdContratto(event){
        console.log('@@@ val ' , event.target.value);
        this.idContratto = event.target.value;
    }

    searchOpty(event){
        this.isLoading = true;
        //var _this = this;
        var opty;
        getContratto({ contactId: this.contactId, oppId: this.idContratto }).then(result => {
            console.log('@@@ result ' , result);
            this._errMsg = undefined;
            opty = result;
            return getContrattoBlob({ contactId: this.contactId, oppId: this.idContratto });
        }).then(result => {
            console.log('@@@ result 2 ' , result);
            this._opty = opty;

            this._contrattoText = result;
            this.isLoading = false;
        }).catch(err => {
            console.log('@@@ err ' , err);
            this.isLoading = false;
            this._errMsg = err.body.message;
        });
    }

    printPDF(event){
        window.open(URL+this.idContratto, '_blank');
    }

    /* EVENT HANDLER - END  */
}