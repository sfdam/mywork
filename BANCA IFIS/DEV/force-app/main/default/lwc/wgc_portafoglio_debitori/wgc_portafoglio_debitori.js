import { LightningElement, wire, api, track } from 'lwc';
import { subscribe, MessageContext } from "lightning/messageService";
import { NavigationMixin } from 'lightning/navigation';
import WGC_HOMEPAGE_CHANNEL from '@salesforce/messageChannel/wgcHomePageFilter__c';


export default class wgc_portafoglio_debitori extends NavigationMixin(LightningElement) {

    @wire(MessageContext) messageContext;
    currentUserId;
    userLevel;
    @track filterValue;
    @track tipoFiltro;
    subscription = null;

    @api title = 'Portafoglio Debitori';
    @api iconName = 'standard:chart';
    @api report;
    @api charttitle;
    @track loadcharts = true;

    @api showComponent;
    @track iconAction = 'utility:chevrondown';

    connectedCallback(){
        if(!this.showComponent){
            this.showComponent = false;
        }
        this.changeIcon();
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
        console.debug('@@@Portafoglio Debitori: payload.filterValue: ' + this.filterValue);
        console.debug('@@@Portafoglio Debitori: payload.tipoFiltro: ' + this.tipoFiltro);
        
        this.loadcharts = false;
        setTimeout(() => {
            this.loadcharts = true;
        }
        , 500);
        
    }

    handlereport(){
        this.redirectReport(this.report);
    }

    toggleComponent(){
        this.showComponent = !this.showComponent;
        this.changeIcon();
    }

    changeIcon(){
        if(this.showComponent == true){
            this.iconAction = 'utility:chevronup';
        }else{
            this.iconAction = 'utility:chevrondown';
        }
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