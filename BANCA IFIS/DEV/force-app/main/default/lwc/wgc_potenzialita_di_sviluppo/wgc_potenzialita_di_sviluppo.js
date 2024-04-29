import { LightningElement, api, wire, track } from 'lwc';
import { subscribe, MessageContext } from "lightning/messageService";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import WGC_HOMEPAGE_CHANNEL from '@salesforce/messageChannel/wgcHomePageFilter__c';
import getCountAnagrafiche from '@salesforce/apex/WGC_potenzialita_svil_Controller.getCountAnagrafiche';
//S custom label
import POTENZIALITA from '@salesforce/label/c.WGC_Potenzialita_title';
import DI_SVILUPPO from '@salesforce/label/c.WGC_diSviluppo_title';
import PROSPECT from '@salesforce/label/c.WGC_prospect_title';
import CON_ATTIVITA from '@salesforce/label/c.WGC_con_attivita_title';
import SENZA_ATTIVITA from '@salesforce/label/c.WGC_senza_attivita_title';
import CLIENTI_ALTRE_BU from '@salesforce/label/c.WGC_clienti_altre_bu_title';
import EX_CLIENTI from '@salesforce/label/c.WGC_ex_clienti_title';
import ES_ALTRE_BU from '@salesforce/label/c.WGC_es_altre_bu';
//E custom label
 
export default class Wgc_potenzialita_di_sviluppo extends NavigationMixin(LightningElement) {
    @wire(MessageContext) messageContext;

    label = {
        POTENZIALITA,
        DI_SVILUPPO,
        PROSPECT,
        CON_ATTIVITA,
        SENZA_ATTIVITA,
        CLIENTI_ALTRE_BU,
        EX_CLIENTI,
        ES_ALTRE_BU,
    };

    //S channel variables
    currentUserId;
    userLevel;
    filterValue;
    tipoFiltro;
    subscription = null;
    //E channel variables

    //S report values
    countProspectConAttivita = 0;
    countProspectSenzaAttivita = 0;
    countclientiAltreBU = 0;
    countExClienti = 0;
    //E report values

    //S id report configurabili da builder
    @api reportProspectConAttivita;
    @api reportProspectSenzaAttivita;
    @api reportClienteAltreBU;
    @api reportExClienti;
    //E id report configurabili da builder

    @track showSpinner = false;

    connectedCallback(){
        this.handleSubscribe();
    }

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
        this.showSpinner = true;
        this.currentUserId = payload ? payload.currentUserId : '';
        this.currentUserLevel = payload ? payload.currentUserLevel : '';
        this.filterValue = payload ? payload.filterValue : '';
        this.tipoFiltro = payload ? payload.tipoFiltro : '';

        getCountAnagrafiche({ currentUserId: this.currentUserId, currentUserLevel: this.currentUserLevel, filterValue: this.filterValue, tipoFiltro: this.tipoFiltro })
            .then(result => {
                if(result){
                    this.countProspectConAttivita = (result.prospectConAttivita) ? result.prospectConAttivita : 0;
                    this.countProspectSenzaAttivita = (result.prospcetSenzaAttivita) ? result.prospcetSenzaAttivita : 0;
                    this.countclientiAltreBU = (result.clientiAltreBU) ? result.clientiAltreBU : 0;
                    this.countExClienti = (result.exClienti) ? result.exClienti : 0;
                }
            })
            .catch(error => {
                console.error('getCountAnagrafiche error: ' + JSON.stringify(error));
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    openNewTabReport(event){
        let reportId = '';
        let targetId = JSON.stringify(event.target.id);
        console.log('-- openNewTab eventTargetId: ' + targetId);
        if(targetId.includes('prospect-con-attivita')){
            reportId = this.reportProspectConAttivita;
        }else if(targetId.includes('prospect-senza-attivita')){
            reportId = this.reportProspectSenzaAttivita;
        }else if(targetId.includes('clienti-altre-bu')){
            reportId = this.reportClienteAltreBU;
        }else if(targetId.includes('ex-clienti')){
            reportId = this.reportExClienti;
        }

        if(reportId != '' && reportId != null){
            try{
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: reportId,
                        actionName: 'view',
                    },
                }).then(url => {
                     window.open(url);
                });
            }catch(error){
                console.error('NavigationMixin openNewTabReport error: ' + error);
                this.showToastMessage("Si è verificato un errore", "error");
            }
        }else{
            this.showToastMessage("Nessun report visualizzabile", "error");
        }
        
    }

    showToastMessage(text, type) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "",
                message: text,
                variant: type
            })
        );
    }

}