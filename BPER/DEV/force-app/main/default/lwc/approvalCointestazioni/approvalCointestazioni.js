import { LightningElement, api, track } from 'lwc';

import NDG from '@salesforce/label/c.approvalCointestazioni_CLM_NDG';
import Nominativo from '@salesforce/label/c.approvalCointestazioni_CLM_Nominativo';
import Natura_Giuridica from '@salesforce/label/c.approvalCointestazioni_CLM_NaturaGiuridica';
import Patrimonio from '@salesforce/label/c.approvalCointestazioni_CLM_Patrimonio';
import Utilizzato from '@salesforce/label/c.approvalCointestazioni_CLM_Utilizzato';
import Fatturato from '@salesforce/label/c.approvalCointestazioni_CLM_Fatturato';
import Accordato from '@salesforce/label/c.approvalCointestazioni_CLM_Accordato';


import { loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';

import cssTreeGrid from '@salesforce/resourceUrl/reassignAccountToWallet';

import getAllData from '@salesforce/apex/ApprovalCointestazioniController.getAllData';
/**
 * Columns definition
 * :: used in examples
 */
const columns = [
    { label: NDG, fieldName: 'PTF_Url', type: 'url', 
    cellAttributes:{ iconName: { fieldName: 'provenanceIconName' } },
        typeAttributes: {
            label: { fieldName: 'CRM_NDG__c' }
        },
        hideDefaultActions: "true"},
    { label: Nominativo, fieldName: 'Name', type: 'text' },
    { label: Natura_Giuridica, fieldName: 'PTF_NaturaGiuridica__c', type: 'text' },
    { label: Patrimonio, fieldName: 'PTF_Patrimonio__c', type: 'currency', cellAttributes: { alignment: 'left' }},
    { label: Utilizzato, fieldName: 'PTF_Utilizzato__c', type: 'currency', cellAttributes: { alignment: 'left' }},
    { label: Fatturato, fieldName: 'AnnualRevenue', type: 'currency', cellAttributes: { alignment: 'left' }},
    { label: Accordato, fieldName: 'PTF_Accordato__c', type: 'currency', cellAttributes: { alignment: 'left' }}
    // { label: 'Coerenza Gruge', fieldName: '', type: 'text',cellAttributes:{class:{fieldName:"typeCSSClass"}} }
];

export default class ApprovalCointestazioni extends LightningElement {

    @track loaded = false;
    @track error;
    @api recordId;
    @api nucleo;
    @api showComponent;

    @api title;
    @api iconName;
    @api numRows;
    @api recordTypes;

    @api isRendered;
    @api openmodel = false;

    @api getAllData;
    @track gridExpandedRows;

    // definition of columns for the tree grid
    gridColumns = columns;

    // data provided to the tree grid
    gridData = [];
    gridDataAll = [];
    totNumRows = 0;

    connectedCallback() {
        this.isRendered = false;
        loadStyle(this, cssTreeGrid);

        getAllData({ recordId: this.recordId })
        .then(result => {
            console.log('DK getAllData result', result);

            let allData = result;
            
            let rows = [];
            let rowsAll = [];
            let nucleiMap = {}
            allData['primari'].forEach(primario => {

                primario._children = [];
                primario.PTF_Url = '/' + primario.Id;
                allData['cointestazioniMap'][primario.Id].forEach(child => {

                    child.PTF_Url = '/' + child.Id;
                    primario._children.push(child);
                })

                if(rows.length < this.numRows){
                    rows.push(primario);
                }
                rowsAll.push(primario);
            });
            
            console.log('rows: ' + JSON.stringify(rows));
            this.gridData = rows;
            this.gridDataAll = rowsAll;
            this.totNumRows = rowsAll.length;
            this.gridExpandedRows = rowsAll.map(item => item.Id);

            this.isRendered = true;
            this.showComponent = true;
        })
        .catch(error => {
            alert('DK ERROR');
            this.error = error;
            console.log('DK ERROR', error);
            this.isRendered = true;
        });
    }

    
    get notEmptyList(){
        return this.gridData.length > 0;
    }

    handleRowAction(event) {
        let row = event.detail.row;

        // const actionName = event.detail.action.name;
        // const row = event.detail.row; // riga selezionata con tutti i campi

        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.Id,
                actionName: 'view'
            }
        });
    }
    
    openModal() {
        this.openmodel = true;
    }

    closeModal() {
        this.openmodel = false;
    } 

    returnModal(){
        this.openmodel = false;
    }
}