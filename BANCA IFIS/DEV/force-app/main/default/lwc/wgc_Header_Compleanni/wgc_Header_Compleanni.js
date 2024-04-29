import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import countCompleanni from '@salesforce/apex/wgc_Header_Compleanni_Controller.countCompleanni';

export default class Wgc_Header_Compleanni extends NavigationMixin(LightningElement)
{
    @api reportCompleanni;
    @track n_Compleanni = 0;

    redirectReport(event) {
        let repid = event.currentTarget.dataset.report;
        
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: repid,
                actionName: 'view',
            },
        }).then(url => {
             window.open(url);
        });
    }
    renderedCallback()
    {
        console.log("test")
        countCompleanni()
        .then(result => {
            this.n_Compleanni = result
        })
        .catch(error => {
            console.log(error)
        });
    }
}