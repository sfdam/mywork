import { LightningElement, api, track } from 'lwc';
import initData from '@salesforce/apex/WGC_HeaderPotenzialitaSviluppoController.getData';
export default class Wgc_header_potenzilita_sviluppo extends LightningElement {
    @track lead24mesi;
    @track lead24mesiCampagna;
    @track aziende1324mesi;
    @track aziende1324mesiCampagne;
    @track clientiAltreBU;
    @track clientiAltreBUCampagne;
    @track exClienti;
    @track exClientiCampagnae;
    @track debitori;
    @track debitoriCampagna;
    @track tooltip;
    @track tooltip1;
    @track tooltip2;
    @track tooltip3;
    @track tooltip4;

    connectedCallback() {
        initData()
        .then(response => {
            console.log('SV response: ',response);
            this.lead24mesi = response.numLead;
            this.lead24mesiCampagna = response.numLeadCampaign;
            this.aziende1324mesi = response.numAziende1324mesi;
            this.aziende1324mesiCampagne = response.numAziende1324mesiCampaign;
            this.clientiAltreBU = response.numClientiAltreBu;
            this.clientiAltreBUCampagne = response.numClientiAltreBuInCampaign;
            this.exClienti = response.numExClienti;
            this.exClientiCampagnae = response.numExClientiCampaign;
            this.debitori = response.numDebitori;
            this.debitoriCampagna = response.numDebitoriCampaign;
        })
        .catch(error => {
            console.log('SV error: '.error);
        })
    }

    tooltipOn() {
        this.tooltip = true;
    }

    tooltipOff() {
        this.tooltip = false;
    }

    tooltipOn1() {
        this.tooltip1 = true;
    }

    tooltipOff1() {
        this.tooltip1 = false;
    }

    tooltipOn2() {
        this.tooltip2 = true;
    }

    tooltipOff2() {
        this.tooltip2 = false;
    }

    tooltipOn3() {
        this.tooltip3 = true;
    }

    tooltipOff3() {
        this.tooltip3 = false;
    }

    tooltipOn4() {
        this.tooltip4 = true;
    }

    tooltipOff4() {
        this.tooltip4 = false;
    }
}