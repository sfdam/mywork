import { LightningElement, track, api, wire } from 'lwc';

import getAllData from '@salesforce/apex/miniWalletDetailNDGController.getAllData';

const columns = [
    { label: 'Nome Mini-Portafoglio', fieldName: 'nameMiniPTF_url', type:'url',
        typeAttributes: {
            label: { fieldName: 'nameMiniPTF' }
        },
    },
    { label: 'Sportello leggero', fieldName: 'nameSL_url', type:'url',
        typeAttributes: {
            label: { fieldName: 'nameSL' }
        },
    },
];

export default class MiniWalletDataGrid extends LightningElement {

    @track isRendered;
    @track isViewAll = false;
    @track columns = [];
    @track allColumns = [];
    @track data = [];
    @track allData = [];
    @api recordId;
    @track numberAll = 0;
    @api title;
    @api pagina;
    @track notShowComponent;
    @api viewAllLabel;
    @track recTypeId;
    @api objectApiName;
    @api builderIcon;
    @track record = null;
    

    connectedCallback() {
        this.columns = columns;
        this.isRendered = false;
        getAllData({ recordId: this.recordId })
        .then(result => {
            this.notShowComponent = false;
            let miniWallet = [];
            result.forEach(element => {
                if(element.PTF_MiniPortafoglio__c){
                    element.nameMiniPTF_url='/'+element.PTF_MiniPortafoglio__c;
                    element.nameMiniPTF= element.PTF_MiniPortafoglio__r.Name;
                    
                    element.nameSL_url='/'+element.PTF_MiniPortafoglio__r.PTF_SL__c;
                    element.nameSL= element.PTF_MiniPortafoglio__r.PTF_SL__r.Name;
                }
                miniWallet.push(element);
            });
            this.data = miniWallet;
        }).catch(error => {
            console.log('MC ERRORE ' + JSON.stringify(error));
        }).finally(() => {
            this.isRendered = true;
        });
    }
    handleViewAll(){
        this.isViewAll=true;
    }
    refreshClick(){
        this.connectedCallback();
    }
   
}