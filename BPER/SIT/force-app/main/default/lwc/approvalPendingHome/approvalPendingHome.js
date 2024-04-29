import { LightningElement, api, track } from 'lwc';

import getAllData from '@salesforce/apex/ApprovalPendingHomeController.getAllData';

import Numero_richiesta from '@salesforce/label/c.approvalPendingHome_CLM_NumeroRichiesta';
import Portafoglio_destinazione from '@salesforce/label/c.approvalPendingHome_CLM_PortafoglioDestinazione';
import Filiale_destinazione from '@salesforce/label/c.approvalPendingHome_CLM_FilialeDestinazione';
/**
 * Columns definition
 * :: used in examples
 */
const columns = [
    { label: Numero_richiesta, fieldName: 'PTF_UrlRequest', type: 'url',
        typeAttributes: {
            label: { fieldName: 'workOrderName' }
        },
        hideDefaultActions: "true",
        cellAttributes:{class:{fieldName: 'typeCSSClass' }}
    },
    { label: 'NDG', fieldName: 'PTF_UrlNDG', type: 'url',
        typeAttributes: {
            label: { fieldName: 'NDG' }
        },
        hideDefaultActions: "true"},
    { label: Portafoglio_destinazione, fieldName: 'PTF_UrlPTFDestinazione', type: 'url',
        typeAttributes: {
            label: { fieldName: 'PTFDestinazionename' }
        },
        hideDefaultActions: "true"},
    { label: 'M-MDS', fieldName: 'MMDS', type: 'text'},
    { label: Filiale_destinazione, fieldName: 'PTF_UrlFilialeDestinazione', type: 'url',
        typeAttributes: {
            label: { fieldName: 'FilialeDestinazioneName' }
        },
        hideDefaultActions: "true"}
];

export default class ApprovalPendingHome extends LightningElement {

    @api title;
    @api iconName;
    @api showNF;

    @track loaded = false;
    @track approvalRequests;
    @track approvalNFRequests;
    @track approvalDelegatedRequests;
    @track notEmptyList;
    @track notEmptyNFList;
    @track notEmptyDelegatedList;
    @track hasToClose;
    @track alertDays;

    // definition of columns for the tree grid
    columns = columns;

    connectedCallback() {

        getAllData()
        .then(result => {

            let dataTableGlobalStyle = document.createElement('style');
            dataTableGlobalStyle.innerHTML = `
            .no-button {
                text-align: center;
                color: #D3D3D3;
                font-weight: 800;
                text-transform: uppercase;
            }
            
            .tilte-card {
                padding-left: 7px;
            }
            
            .approvalTabs ul.slds-tabs_default__nav{
                width: 150px;
                margin: 0 auto;
            }
            .color-red a {
                font-weight: 500;
                color: red;
            }`;
            document.head.appendChild(dataTableGlobalStyle);
            console.log('DK getAllData result', result);

            this.hasToClose = result['hasToClose'];
            this.alertDays = result['alertDays'];
            if(result['approvalRequests'].length){

                this.approvalRequests = result['approvalRequests'];
                this.notEmptyList = true;
            }else{

                this.notEmptyList = false;
            }

            if(result['approvalNFRequests'].length){

                this.approvalNFRequests = result['approvalNFRequests'];
                this.notEmptyNFList = true;
            }else{

                this.notEmptyNFList = false;
            }

            if(result['approvalDelegatedRequests'].length){

                this.approvalDelegatedRequests = result['approvalDelegatedRequests'];
                this.notEmptyDelegatedList = true;
            }else{

                this.notEmptyDelegatedList = false;
            }

            this.loaded = true;
        })
        .catch(error => {
            console.log('DK ERROR', JSON.stringify(error));
            this.loaded = true;
        });
    }

}