import { LightningElement, wire, api, track } from 'lwc';
import { subscribe, MessageContext } from "lightning/messageService";
import { NavigationMixin } from 'lightning/navigation';
import WGC_HOMEPAGE_CHANNEL from '@salesforce/messageChannel/wgcHomePageFilter__c';
import LWGC_Opportunita_Progress_avviate from '@salesforce/label/c.WGC_Opportunita_Progress_avviate';
import LWGC_Opportunita_Progress_Da_inizio_anno from '@salesforce/label/c.WGC_Opportunita_Progress_Da_inizio_anno';
import LWGC_Opportunita_Progress_segnalazioni_aperte from '@salesforce/label/c.WGC_Opportunita_Progress_segnalazioni_aperte';
import LWGC_Opportunita_Progress_chiuse from '@salesforce/label/c.WGC_Opportunita_Progress_chiuse';
import LWGC_Opportunita_Progress_vinte from '@salesforce/label/c.WGC_Opportunita_Progress_Vinte';
import LWGC_Opportunita_Progress_inlavorazione from '@salesforce/label/c.WGC_Opportunita_Progress_inlavorazione';
import getOpportunityCountByStatus from '@salesforce/apex/WGC_Opp_Home_Controller.getOpportunityCountByStatus';

export default class wgc_opportunita_home extends NavigationMixin(LightningElement) {

    @wire(MessageContext) messageContext;
    currentUserId;
    userLevel;
    filterValue;
    tipoFiltro;
    subscription = null;

    @api title;
    @api title2;
    @api iconName;

    @api reportIstruttoria;
    @api reportValPratica;
    @api reportPredContratto;
    @api reportPerfContratto;
    @api reportAttRapporto;
    @api reportAvviate;
    @api reportCrossSelling;
    @api reportChiuse;
    @api reportDettagli;

    @track Stato_Opp_1 = "IN ISTRUTTORIA";
    @track Stato_Opp_2 = "IN VALUTAZIONE";
    @track Stato_Opp_3 = "FIRMA CONTRATTI";
    @track Stato_Opp_4 = "DA AVVIARE";

    @track Opp_1_class1 = "";
    @track Opp_1_class2 = "";

    @track countIstruttoria = 0;
    @track countValutazionePratica = 0;
    @track countPerfContratto = 0;
    @track countAttRapporto = 0;
    @track countCrossSellingInLavorazione = 0;
    @track countCrossSellingWonTotalYear = 0;
    @track countCrossSellingClosedTotalYear = 0;
    @track countTotalYear = 0;
    @track countWonTotalYear = 0;
    @track countClosedTotalYear = 0;
    @track expiredIstruttoriaOpty = false;

    @track WGC_Opportunita_Progress_avviate = LWGC_Opportunita_Progress_avviate;
    @track WGC_Opportunita_Progress_Da_inizio_anno = LWGC_Opportunita_Progress_Da_inizio_anno;
    @track WGC_Opportunita_Progress_segnalazioni_aperte = LWGC_Opportunita_Progress_segnalazioni_aperte;
    @track WGC_Opportunita_Progress_chiuse = LWGC_Opportunita_Progress_chiuse;
    @track WGC_Opportunita_Progress_vinte = LWGC_Opportunita_Progress_vinte;
    @track WGC_Opportunita_Progress_inlavorazione = LWGC_Opportunita_Progress_inlavorazione;

    @track expiredIstruttoriaOpty = true;


    handleSubscribe() {
        console.log("in handle subscribe");
        if (this.subscription) {
          return;
        }
    
        this.subscription = subscribe(
            this.messageContext,
            WGC_HOMEPAGE_CHANNEL,
            (payload) => {
                this.handleMessage(payload);
            }
        );
    }
    
 
    handleMessage(payload) {
        this.currentUserId = payload ? payload.currentUserId : '';
        this.currentUserLevel = payload ? payload.currentUserLevel : '';
        this.filterValue = payload ? payload.filterValue : '';
        this.tipoFiltro = payload ? payload.tipoFiltro : '';
        console.log('@@@Opportunità: payload.currentUserId: ' + this.currentUserId);
        console.log('@@@Opportunità: payload.currentUserLevel: ' + this.currentUserLevel);
        console.log('@@@Opportunità: payload.filterValue: ' + this.filterValue);
        console.log('@@@Opportunità: payload.tipoFiltro: ' + this.tipoFiltro);
        
        this.getOpportunity();
    }


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

    renderedCallback(){
        this.Opp_1_class1 = 'circleBase type4 clickable ' + (this.expiredIstruttoriaOpty ? 'background-red border-white' : 'border-grey');
        this.Opp_1_class2 = 'circleBaseBody clickable ' + (this.expiredIstruttoriaOpty ? 'found-white' : '');
    }

    connectedCallback(){
        this.handleSubscribe();
    }

    getOpportunity(){
        getOpportunityCountByStatus({currentUserId: this.currentUserId, currentUserLevel: this.currentUserLevel, filterValue: this.filterValue, tipoFiltro: this.tipoFiltro})
            .then(response => {
                if(response.success){
                    console.log('@@@ Response: ' + JSON.stringify(response.data[0]));

                    this.countIstruttoria = response.data[0].countIstruttoria;
                    this.countValutazionePratica = response.data[0].countValutazionePratica;
                    this.countPerfContratto = response.data[0].countPerfContratto;
                    this.countAttRapporto = response.data[0].countAttRapporto;
                    this.countCrossSellingInLavorazione = response.data[0].countCrossSellingInLavorazione;
                    this.countCrossSellingWonTotalYear = response.data[0].countCrossSellingWonTotalYear;
                    this.countCrossSellingClosedTotalYear = response.data[0].countCrossSellingClosedTotalYear;
                    this.countTotalYear = response.data[0].countTotalYear;
                    this.countWonTotalYear = response.data[0].countWonTotalYear;
                    this.countClosedTotalYear = response.data[0].countClosedTotalYear;
                    console.log('@@@ countClosedTotalYear ' , this.countClosedTotalYear);
                    this.expiredIstruttoriaOpty = response.data[0].expiredIstruttoriaOpty;
                }
                else{
                    console.error('getOpportunity error: ' + response.getError());
                }
            });
    }

}