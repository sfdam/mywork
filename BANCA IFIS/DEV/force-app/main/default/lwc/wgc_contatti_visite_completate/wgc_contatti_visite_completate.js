import { LightningElement, wire, api, track } from 'lwc';
import { subscribe, MessageContext } from "lightning/messageService";
import { NavigationMixin } from 'lightning/navigation';
import WGC_HOMEPAGE_CHANNEL from '@salesforce/messageChannel/wgcHomePageFilter__c';

import WGC_Visite_Completate from '@salesforce/label/c.WGC_Visite_Completate';
import WGC_Contatti from '@salesforce/label/c.WGC_Contatti';

export default class wgc_contatti_visite_completate extends NavigationMixin(LightningElement) {

    @wire(MessageContext) messageContext;
    currentUserId;
    userLevel;
    @track filterValue;
    @track tipoFiltro;
    subscription = null;

    @api title = 'Contatti e Visite Completate';
    @api iconName = 'standard:chart';
    @track reportlabel = WGC_Visite_Completate;
    @api report;
    @track reportlabel2 = WGC_Contatti;
    @api report2;
    @api charttitle;
    @track loadcharts = true;


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
        this.currentUserId = payload ? payload.currentUserId : 'no field received';
        this.currentUserLevel = payload ? payload.currentUserLevel : 'no field received';
        this.filterValue = payload ? payload.filterValue : 'no field received';
        this.tipoFiltro = payload ? payload.tipoFiltro : 'no field received';
        //console.log('payload.currentUserId: ' + this.currentUserId);
        //console.log('payload.currentUserLevel: ' + this.currentUserLevel);
        console.debug('@@@Contatti e visite Completate: payload.filterValue: ' + this.filterValue);
        console.debug('@@@Contatti e visite Completate: payload.tipoFiltro: ' + this.tipoFiltro);

        
        this.loadcharts = false;
        setTimeout(() => {
            this.loadcharts = true;
        }
        , 500);
        
        
    }

    handlereport(){
        this.redirectReport(this.report);
    }

    handlereport2(){
        this.redirectReport(this.report2);
    }



    redirectReport(repid){
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
}