import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//CUSTOM LABELS
import attivitaDiOggi from '@salesforce/label/c.WGC_attivita_odierne_AttivitaDiOggi';
import aziendeDaContattare from '@salesforce/label/c.WGC_attivita_odierne_AziendeDaContattare';
import aziendeDaVisitare from '@salesforce/label/c.WGC_attivita_odierne_AziendeDaVisitare';

//METHODS
import init from '@salesforce/apex/WGC_AttivitaOdierneController.init';


export default class Wgc_attivita_odierne extends NavigationMixin(LightningElement) {

    label = {
        attivitaDiOggi,
        aziendeDaContattare,
        aziendeDaVisitare
    };

    @track daContattare = 0;
    @track daVisitare = 0;
    @track thisTemplate = this.template;

    @api idReportDaContattare;
    @api idReportDaVisitare;

    // Navigates to app page on button click
    handleNavigate(event) {
        console.log('DK event', event.target.name);
        let reportId = event.target.name == 'daContattare' ? this.idReportDaContattare : this.idReportDaVisitare
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: reportId,
                objectApiName: 'Report',
                actionName: 'view'
            }
        });
        /*this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'AttivitaOdierneChart',
            },
            state: {
                c__idReportID: '' + this.idReportDaContattare,//must be string
                c__idReportSD: '' + this.idReportDaVisitare//must be string
            }
        });*/
    }
    
    connectedCallback(){

        init()
        .then(response =>{
            console.log('DK init.response', response);
            this.daContattare = response.daContattare.length
            this.daVisitare = response.daVisitare.length
        })
        .catch(error =>{
            console.error('DK init.error', error);
        })
    }
}