import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import countSegnalazioni from '@salesforce/apex/wgc_HomePageNew_SCrossSelling_Controller.countSegnalazioni';

//CUSTOM LABELS

//METHODS

export default class Wgc_HomePageNew_SCrossSelling extends NavigationMixin(LightningElement) {

    @api title;
    @api iconName;
    @track countInCorso = 0;
    @track countPerse = 0;
    @track countVinte = 0;
    @api inCorsoReportId;
    @api perseReportId;
    @api vinteReportId;
    @api vediTutteReportId;

    connectedCallback(){

        var currentYear = new Date().getFullYear();

        //console.log("test")
        countSegnalazioni()
        .then(result => {
            
            result.forEach(element => {
                if (!['Vinta', 'Persa'].includes(element.StageName))
                {
                    this.countInCorso++
                }
                else if(element.StageName == 'Vinta' && new Date(element.CloseDate).getFullYear() == currentYear)
                {
                    this.countVinte++
                }
                else if(element.StageName == 'Persa' && new Date(element.CloseDate).getFullYear() == currentYear)
                {
                    this.countPerse++
                }
              });
        })
        .catch(error => {
            console.log(error)
        });
    }

    viewAll(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.vediTutteReportId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }

    onClickInCorso(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.inCorsoReportId,
                objectApiName: 'Report',
                actionName: 'view'
            }
        });
    }

    onClickPerse(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.perseReportId,
                objectApiName: 'Report',
                actionName: 'view'
            }
        });
    }

    onClickVinte(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.vinteReportId,
                objectApiName: 'Report',
                actionName: 'view'
            }
        });
    }
}