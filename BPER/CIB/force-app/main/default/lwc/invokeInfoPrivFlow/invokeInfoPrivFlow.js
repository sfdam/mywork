import { LightningElement, api, track } from 'lwc';
import { FlowNavigationFinishEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import pubsub from 'omnistudio/pubsub';

export default class InvokeInfoPrivFlow extends OmniscriptBaseMixin(LightningElement) {

    @api prefill;
    @track showButton;
    @api availableActions = [];

    renderedCallback(){
        pubsub.register('omniscript_step', {
          data: this.handleOmniStepLoadData.bind(this)
        });
    }

    handleOmniStepLoadData(data){
        console.log('TEST --> ' + data.end);
        this.showButton = data.end;
    }

    closeAction() {
        console.log('TEST this.availableActions --> ' + JSON.stringify(this.availableActions));
        
        if (this.availableActions.find((action) => action === 'FINISH')) {
            const navigateNextEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateNextEvent);
        }

        if (this.availableActions.find((action) => action === 'NEXT')) {
            // navigate to the next screen
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }
}