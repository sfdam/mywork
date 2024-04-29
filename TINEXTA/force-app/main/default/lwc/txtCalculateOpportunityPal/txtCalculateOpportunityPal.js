import { LightningElement, api } from 'lwc';
import calculate from '@salesforce/apex/TXT_CalculateOpportunityPalCtrl.calculate';

export default class TxtCalculateOpportunityPal extends LightningElement {
    
    @api recordId;

    async connectedCallback(){
        let result = await calculate({ recordId: this.recordId });
        console.log('@@@ result calculate ' , result);
    }

}