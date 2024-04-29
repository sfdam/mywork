import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { refreshApex } from '@salesforce/apex';

import Stato_Opp_1 from "@salesforce/label/c.Stato_Opp_1";
import Stato_Opp_2 from "@salesforce/label/c.Stato_Opp_2";
import Stato_Opp_3 from "@salesforce/label/c.Stato_Opp_3";
import Stato_Opp_4 from "@salesforce/label/c.Stato_Opp_4";
import WGC_Opportunita_Progress_avviate from "@salesforce/label/c.WGC_Opportunita_Progress_avviate";
import WGC_Opportunita_Progress_segnalazioni_aperte from "@salesforce/label/c.WGC_Opportunita_Progress_segnalazioni_aperte";
import WGC_Opportunita_Progress_chiuse from "@salesforce/label/c.WGC_Opportunita_Progress_chiuse";
import WGC_Opportunita_Progress_Da_inizio_anno from "@salesforce/label/c.WGC_Opportunita_Progress_Da_inizio_anno";

import getFilialeUtentiOptions from "@salesforce/apex/WGC_Opportunita_Progress_FilteredCtrl.getFilialeUtentiOptions";
import getCommercialeOptions from "@salesforce/apex/WGC_Opportunita_Progress_FilteredCtrl.getCommercialeOptions";
import getOpportunityCountByStatusFiltered from "@salesforce/apex/WGC_Opportunita_Progress_FilteredCtrl.getOpportunityCountByStatusFiltered";

export default class WgcOpportunitaProgressFiltered extends NavigationMixin(
  LightningElement
) {
  @api idReport;
  @api nomeIcona = "utility:rating";
  @api title = "Opportunità";

  label = {
    Stato_Opp_1,
    Stato_Opp_2,
    Stato_Opp_3,
    Stato_Opp_4,
    WGC_Opportunita_Progress_avviate,
    WGC_Opportunita_Progress_segnalazioni_aperte,
    WGC_Opportunita_Progress_chiuse,
    WGC_Opportunita_Progress_Da_inizio_anno
  };

  @track spinner = true;

  // @track filialeOptions = [];

  @track filiale = '';
  @track commerciale = '';

  @track items = [
    {
      label: this.label.Stato_Opp_1,
      subLabel: "",
      cssClassCircleBase: "circleBase type4",
      cssClassCircleBaseBody: "circleBaseBody",
      counter: 0,
      id: 'countIstruttoria'
    },
    {
      label: this.label.Stato_Opp_2,
      subLabel: this.label.WGC_Opportunita_Progress_Da_inizio_anno,
      cssClassCircleBase: "circleBase type4 border-grey",
      cssClassCircleBaseBody: "circleBaseBody",
      counter: 0,
      id: 'countValutazionePratica'
    },
    {
      label: this.label.Stato_Opp_3,
      subLabel: "",
      cssClassCircleBase: "circleBase type4 border-red",
      cssClassCircleBaseBody: "circleBaseBody found-red",
      counter: 0,
      id: 'countPerfContratto'
    },
    {
      label: this.label.Stato_Opp_4,
      subLabel: "",
      cssClassCircleBase: "circleBase type4 border-red",
      cssClassCircleBaseBody: "circleBaseBody found-red",
      counter: 0,
      id: 'countAttRapporto'
    },
    {
      label: this.label.WGC_Opportunita_Progress_avviate,
      subLabel: this.label.WGC_Opportunita_Progress_Da_inizio_anno,
      cssClassCircleBase: "circleBase type4 border-grey",
      cssClassCircleBaseBody: "circleBaseBody",
      counter: 0,
      id: 'countTotalYear'
    },
    {
      label: this.label.WGC_Opportunita_Progress_segnalazioni_aperte,
      subLabel: "",
      cssClassCircleBase: "circleBase type4 border-grey",
      cssClassCircleBaseBody: "circleBaseBody",
      counter: 0,
      id: 'countCrossSelling'
    },
    {
      label: this.label.WGC_Opportunita_Progress_chiuse,
      subLabel: this.label.WGC_Opportunita_Progress_Da_inizio_anno,
      cssClassCircleBase: "circleBase type4 border-grey",
      cssClassCircleBaseBody: "circleBaseBody found-grey",
      counter: 0,
      id: 'countClosedTotalYear'
    }
  ];

  //Recupero la lista di filiali con cui popolo la picklist
  @wire(getFilialeUtentiOptions, {})
  filialeOptions;

  @wire(getCommercialeOptions, { filiale: "$filiale" })
  commercialeOptions;

  connectedCallback(){
      this.getOpportunityCount();
  }

  /* FUNCTIONS - START */

  showSpinner() {
    this.spinner = true;
  }

  hideSpinner() {
    this.spinner = false;
  }

  setupCounter(data){
      console.log('@@@ data ' , data);
      this.items = this.items.map((item) => {
          let cssClassCircleBase = item.cssClassCircleBase;
          let cssClassCircleBaseBody = item.cssClassCircleBaseBody;

          if(item.id == 'countIstruttoria'){
              if(data.data.expiredIstruttoriaOpty){
                cssClassCircleBase += ' background-red border-white';
                cssClassCircleBaseBody += ' found-white';
              } else {
                cssClassCircleBase += ' border-grey';
                // cssClassCircleBaseBody += ' found-white';
              }
          }

        return {
            label: item.label,
            subLabel: item.subLabel,
            cssClassCircleBase: cssClassCircleBase,
            cssClassCircleBaseBody: cssClassCircleBaseBody,
            counter: data.data[item.id],
            id: item.id
        }
      });

      this.hideSpinner();
  }

  getOpportunityCount(){
      this.showSpinner();
        getOpportunityCountByStatusFiltered({ filiale: this.filiale, commerciale: this.commerciale })
        .then(data => {
            this.setupCounter(data);
            this.hideSpinner();
        }).catch((err) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore',
                    message: err.body.message,
                    variant: 'error'
                })
            )
            this.hideSpinner();
        })
  }

  /* FUNCTIONS - END */

  /* EVENT HANDLERS - START */

  onChangeFilialeHandler(evt) {
    this.filiale = evt.target.value;
    this.commerciale = '';
    this.getOpportunityCount();
  }

  onChangeCommercialeHandler(evt) {
    this.commerciale = evt.target.value;
    this.getOpportunityCount();
  }

  goToDetail(evt) {
    evt.preventDefault();
    evt.stopPropagation();

    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.idReport,
        objectApiName: "Report",
        actionName: "view"
      }
    });
  }

  /* EVENT HANDLERS - END */

  /* GETTER & SETTER - START */

  get filledFiliale() {
    return this.filiale != '';
  }

  /* GETTER & SETTER - END */
}