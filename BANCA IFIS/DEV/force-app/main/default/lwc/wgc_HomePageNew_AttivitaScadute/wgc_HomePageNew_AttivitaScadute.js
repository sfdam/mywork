import { LightningElement, api, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getData from '@salesforce/apex/wgc_HomePageNew_AttScadute_Controller.getData';




//CUSTOM LABELS

//METHODS

export default class Wgc_HomePageNew_AttivitaScadute extends NavigationMixin(LightningElement) {

    @api title;
    @api iconName;
    @track Promemoria;
    @track Contatti;
    @track Visite;
    @api PromemoriaReportId;
    @api ContattiReportId;
    @api VisiteReportId;
    @api vediTutteReportId;

    connectedCallback(){
        getData()
        .then(response => {
            this.Promemoria = response.countPromemoriaNonEsitati;
            console.log('prom: ',this.Promemoria);
            this.Contatti = response.countContattiNonEistati;
            this.Visite = response.countVisiteNonEsitate;
        })
        .catch(error => {
            console.error(error + 'metodo2');
        });
    }
 
    onClickPromemoria(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.PromemoriaReportId,
                objectApiName: 'Report',
                actionName: 'view'
            }
        });
    }

    onClickContatti(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.ContattiReportId,
                objectApiName: 'Report',
                actionName: 'view'
            }
        });
    }

    onClickVisite(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.visiteReportId,
                objectApiName: 'Report',
                actionName: 'view'
            }
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
}