import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//CUSTOM LABELS
import LWGC_In from '@salesforce/label/c.WGC_In_Title';
import LWGC_Istruttoria from '@salesforce/label/c.WGC_Istruttoria';
import LWGC_Valutazione from '@salesforce/label/c.WGC_Valutazione';
import LWGC_Firma from '@salesforce/label/c.WGC_Firma';
import LWGC_Contratti from '@salesforce/label/c.WGC_Contratti_Title';
import LWGC_Da from '@salesforce/label/c.WGC_Da';
import LWGC_Avviare from '@salesforce/label/c.WGC_Avviare';
import LWGC_Ferma_Da from '@salesforce/label/c.WGC_Fermeda';
import LWGC_Oltre_30gg from '@salesforce/label/c.WGC_Oltre_30gg';
import LWGC_Perse from '@salesforce/label/c.WGC_Perse';
import LWGC_Vinte from '@salesforce/label/c.WGC_Vinte';
import LWGC_Da_Inizio_Anno from '@salesforce/label/c.WGC_Da_Inizio_Anno';


//METHODS
import init from '@salesforce/apex/WGC_HomePageNew_Portafoglio_Controller.getData';

export default class Wgc_HomePageNew_Portafoglio extends NavigationMixin(LightningElement) {

    @api title;
    @api iconName;
    @api istruttoriaReportId;
    @api valutazioneReportId;
    @api firmaContattiReportId;
    @api daAvviareReportId;
    @api ferme30ggReportId;
    @api perseReportId;
    @api vinteReportId;
    @api vediTutteReportId;

    @track WGC_In = LWGC_In;
    @track WGC_Istruttoria = LWGC_Istruttoria;
    @track WGC_Valutazione = LWGC_Valutazione;
    @track WGC_Firma = LWGC_Firma;
    @track WGC_Contratti = LWGC_Contratti;
    @track WGC_Da = LWGC_Da;
    @track WGC_Avviare = LWGC_Avviare;
    @track WGC_Ferme_Da = LWGC_Ferma_Da;
    @track WGC_Oltre_30gg = LWGC_Oltre_30gg;
    @track WGC_Perse = LWGC_Perse;
    @track WGC_Vinte = LWGC_Vinte;
    @track WGC_Da_Inizio_Anno = LWGC_Da_Inizio_Anno;
    
    @track tooltip;
    @track tooltip2;
    @track istruttoria = 0;
    @track inValutazione = 0;
    @track firma = 0;
    @track daAvviare = 0;
    @track ferme30gg = 0;
    @track vinte;
    @track perse;
    @track data;

    connectedCallback(){

        init()
        .then(response =>{
            console.log('AT init.response', response);
            this.vinte = response.vinte;
            this.perse = response.perse;
            let fasi = response.faseList;

            fasi.forEach(element => {
                if(element.StageName == 'In Istruttoria'){
                    this.istruttoria++;
                }
                else if(element.StageName == 'Valutazione Pratica'){
                    this.inValutazione++;
                }
                else if(element.StageName == 'Perfezionamento Contratto'){
                    this.firma++;
                }
                else if(element.StageName == 'Attivazione prodotto'){
                    this.daAvviare++;
                }
            });

            let ferme30ggResponse = response.ferme;
            this.data = response.data30g;

            ferme30ggResponse.forEach(element => {
                if((element.StageName == 'In Istruttoria' && element.WGC_Data_Fase_In_Istruttoria__c < this.data) || (element.StageName == 'Perfezionamento Contratto' && element.WGC_Data_Fase_Perfezionamento_Contratto__c < this.data) || (element.StageName == 'Valutazione Pratica' && element.WGC_Data_Fase_Valutazione__c < this.data)){
                    this.ferme30gg++;
                }
            })

        })
        .catch(error =>{
            console.error('AT init.error', error);
        })
    }

    viewAll(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.vediTutteReportId,
                objectApiName: 'Report',
                actionName: 'view'
            }
        });
    }

    onclickIstruttoria(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.istruttoriaReportId,
                objectApiName: 'Report',
                actionName: 'view'
            }
        });
    }

    onclickInValutazione(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.valutazioneReportId,
                objectApiName: 'Report',
                actionName: 'view'
            }
        });
    }

    onclickFirmaContratti(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.firmaContattiReportId,
                objectApiName: 'Report',
                actionName: 'view'
            }
        });
    }

    onclickDaAvviare(evt){
        evt.preventDefault();
        evt.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.daAvviareReportId,
                objectApiName: 'Report',
                actionName: 'view'
            }
        });
    }

    onclickFerme30gg(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.ferme30ggReportId,
                objectApiName: 'Report',
                actionName: 'view'
            }
        });
    }

    onclickPerse(evt) {
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

    onclickVinte(evt) {
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

    tooltipOn(evt) {
        this.tooltip = true;
    }

    tooltipOff(){
        this.tooltip = false;
    }

    tooltipOn1() {
        this.tooltip2 = true;
    }

    tooltipOff1() {
        this.tooltip2 = false;
    }
}