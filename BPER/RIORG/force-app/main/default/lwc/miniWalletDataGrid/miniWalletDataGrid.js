import { LightningElement, track, api, wire } from 'lwc';

import getAllData from '@salesforce/apex/miniWalletAccountController.getAllData';
import getNumNDG from '@salesforce/apex/miniWalletAccountController.getNumNDG';

const columns = [
    { label: 'Nome', fieldName: 'Name_url', type:'url',
        typeAttributes: {
            label: { fieldName: 'Name' }
        },
    },
    { label: 'Num NDG', fieldName: 'numNDG', type:'text'},
    { label: 'Sportello leggero', fieldName: 'SL_url', type:'url',
        typeAttributes: {
            label: { fieldName: 'nameSL' }
        },
    },
    { label: 'Referente principale', fieldName: 'ref_url', type:'url',
        typeAttributes: {
            label: { fieldName: 'nameREF' }
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
        let numNdg=[];
        getNumNDG({ recordId: this.recordId })
        .then(result => {
            result.forEach(element =>{
                numNdg.push(element);
            });
            return getAllData({ recordId: this.recordId });
        })
        .then(result => {
            this.notShowComponent = false;
            let miniWallet = [];
            result.forEach(element => {
                if(element.Id)
                    element.Name_url='/'+element.Id;
                if(element.PTF_SL__c){
                    element.SL_url='/'+element.PTF_SL__c;
                    element.nameSL=element.PTF_SL__r.Name;
                }
                if(element.Referente__c){
                    element.ref_url='/'+element.Referente__c;
                    element.nameREF=element.Referente__r.Name;
                }
                numNdg.forEach(mw =>{
                    if(mw.PTF_MiniPortafoglio__c==element.Id)
                        element.numNDG=mw.numMiniWallet;
                });
                miniWallet.push(element);
            });
            this.data = miniWallet;
            this.numberAll=miniWallet.length;
        }).catch(error => {
            console.log('MC ERROR ' + JSON.stringify(error));
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