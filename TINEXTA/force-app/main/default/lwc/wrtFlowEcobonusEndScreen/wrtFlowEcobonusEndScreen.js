import { LightningElement, api } from 'lwc';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';
import deleteContactFlow from '@salesforce/apex/PardotIntegrationCtrl.deleteContactFlow';
//import getNexiBaseUrl from '@salesforce/apex/NexiPaymentIntegrationCtrl.getNexiBaseUrl';

export default class WrtFlowEcobonusEndScreen extends LightningElement {

    _inputVar;
    _pardotId;

    connectedCallback(){

    }

    // GETTER & SETTER - START

    @api get inputVar(){
        return this._inputVar;
    }

    set inputVar(v){
        console.log('@@@ inputVar ' , v);
        this._inputVar = v;
    }

    @api get pardotId(){
        return this._pardotId;
    }

    set pardotId(v){
        console.log('@@@ pardotId ' , v);
        this._pardotId = v;
        this.deletePardotContact();
    }

    // GETTER & SETTER - END

    // FUNCTIONS - START

    deletePardotContact(){
        deleteContactFlow({ parametri: { id: this.pardotId } }).then(res => {
            console.log('@@@ res ' , res);
        }).catch(err => {
            console.log('@@@ err ' , err);
        });
    }

    // FUNCTIONS - END

    // EVENT HANDLERS - START

    pay(event){
        this.dispatchEvent(
            new FlowNavigationFinishEvent()
        );

        window.open(this.inputVar.split('|')[1], '_self');
    }
    // EVENT HANDLERS - END 
}