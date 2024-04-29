/* eslint-disable no-useless-constructor */
import { LightningElement, api, track, wire } from 'lwc';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

import { publish,MessageContext, subscribe, unsubscribe, APPLICATION_SCOPE } from 'lightning/messageService';
import lmsDemoMC from "@salesforce/messageChannel/newMicroWalletModal__c";

export default class NewMicroWalletModalFooter extends NavigationMixin(LightningElement) {

    @api recordId;
    @api step1;
    @api step2 = false;
    @api stepSalvaMultiMP = false;
    @api valueNumMicroPortafoglio = '1';
    @api valueModServizio;
    @api allValid;
    @track isButtonDisabled=false;



    channel;
    @wire(MessageContext)
    context;

    constructor() {
        super();
    }

    subscribeToMessageChannel() {
        this.channel = subscribe(
            this.context, 
            lmsDemoMC, 
            (message) => this.handleMessage(message),
            { scope: APPLICATION_SCOPE }
        );
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.channel);
        this.channel = null;
    }

    // Handler for message received by component
    handleMessage(messageResult) {
        if (messageResult != null) {
            let message = messageResult.messageBody;
            let source = messageResult.source;
            if(source == 'newMicroWalletModal'){
                this.valueNumMicroPortafoglio = message.num;
                this.valueModServizio = message.valueModServizio;
                this.allValid = message.allValid;

                if(message.allValid){
                    
                    this.step1 = false;
                    this.step2 = true;
                    this.stepSalvaMultiMP = true;

                } else {
                    if(message.num > 1){
                        this.stepSalvaMultiMP = true;
                    } else {
                        if(this.valueModServizio === 'Family' || this.valueModServizio === 'POE' || this.valueModServizio === 'Controparti Istituzionali' || this.valueModServizio === 'Residuale' || this.valueModServizio === 'Assente'){
                            this.stepSalvaMultiMP = true;
                        } else {
                            this.stepSalvaMultiMP = false;
                        }
                    }
                }

            }
        }
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
        this.step1 = true;
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    previousStep(event) {
        this.step1 = true;
        this.step2 = false;
        if(this.valueNumMicroPortafoglio > 1){
            this.stepSalvaMultiMP = true;
        } else {
            this.stepSalvaMultiMP = false;
        }

        const payload = {
            source: "newMicroWalletModalFooter",
            messageBody: { action : 'previousStep' }
        }; 
        publish(this.context, lmsDemoMC, payload);
    }

    nextStep(event) {
        
        const payload = {
            source: "newMicroWalletModalFooter",
            messageBody: { action : 'nextStep' }
        }; 
        publish(this.context, lmsDemoMC, payload);
    }

    closeQuickAction(event){

        const payload = {
            source: "newMicroWalletModalFooter",
            messageBody: { action : 'closeQuickAction' }
        }; 
        publish(this.context, lmsDemoMC, payload);
    }

    handleSave(event) {
        this.isButtonDisabled=true;
        const payload = {
            source: "newMicroWalletModalFooter",
            messageBody: { action : 'saveAction' }
        }; 
        publish(this.context, lmsDemoMC, payload);
        
    }
    
}