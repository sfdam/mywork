/* eslint-disable no-unused-vars */
/* eslint-disable guard-for-in */
/* eslint-disable no-alert */
/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';

// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

import cssReassignAccountToWallet from '@salesforce/resourceUrl/reassignAccountToWallet';

import getAllData from '@salesforce/apex/ReassignAccountToWalletController.getAllData';
import getAssignData from '@salesforce/apex/ReassignAccountToWalletController.getAssignData';
import getMW from '@salesforce/apex/ReassignAccountToWalletController.getMW';
import assignSelectedAccounts from '@salesforce/apex/ReassignAccountToWalletController.assignSelectedAccounts';
import reassignSelectedAccount from '@salesforce/apex/ReassignAccountToWalletController.reassignSelectedAccount';
import { updateRecord } from 'lightning/uiRecordApi';

import AccountName from '@salesforce/label/c.reassignAccountToWallet_CLM_AccountName';
import CoerenzaGruge from '@salesforce/label/c.reassignAccountToWallet_CLM_CoerenzaGruge';
import NDG from '@salesforce/label/c.reassignAccountToWallet_CLM_NDG';
import P_IVA from '@salesforce/label/c.reassignAccountToWallet_CLM_PIVA';
import NaturaGiuridica from '@salesforce/label/c.reassignAccountToWallet_CLM_NaturaGiuridica';
import GruppoGestionale from '@salesforce/label/c.reassignAccountToWallet_CLM_GruppoGestionale';
import Name from '@salesforce/label/c.reassignAccountToWallet_CLM_Name';
import Filiale from '@salesforce/label/c.reassignAccountToWallet_CLM_Filiale';
import ModelloServizio from '@salesforce/label/c.reassignAccountToWallet_CLM_ModelloServizio';

export default class ReassignAccountToWallet extends NavigationMixin(LightningElement) {

    @track loaded = false;
    @track error;
    @api recordId;

    @api title;
    @api iconName;
    @api numRows;
    @api button_reassign;
    @api button_assign;

    @api getAllData;
    @api getAssignData;
    @api getMW;
    @api listViewData;
    @api listViewAssign;
    @api selectedRows = [];
    @api selectedRowsAssign = [];
    @api selectedRowsMW = [];
    @track totalElement = 0;

    @api isRendered = false;
    @api openmodel = false;
    @api openmodelAssign = false;
    @api stepModal1;
    @api stepModal2;

    columns = [
        { label: AccountName, fieldName: 'Name', type: 'text' },
        { label: CoerenzaGruge, fieldName: '', type: 'text',cellAttributes:{class:{fieldName:"typeCSSClass"}} },
        { label: NDG, fieldName: 'PTF_Url', type: 'url', typeAttributes: {label: { fieldName: 'CRM_NDG__c' }} },
        { label: P_IVA, fieldName: 'CRM_VAT__c', type: 'text' },
        { label: NaturaGiuridica, fieldName: 'PTF_NaturaGiuridica__c', type: 'text' },
        { label: GruppoGestionale, fieldName: 'PTF_GruppoComportamentale__c', type: 'text' },
        // { type:"action",typeAttributes:{rowActions:[{label:"Mostra Dettaglio", name: "show_details"}]}}
    ]

    columnsMW = [
        { label: Name, fieldName: 'PTF_Url', type: 'url', typeAttributes: {label: { fieldName: 'Name' }} },
        { label: Filiale, fieldName: 'PTF_Filiale__c', type: 'text' },
        { label: ModelloServizio, fieldName: 'PTF_ModelloDiServizio__c', type: 'text' },
        // { type:"action",typeAttributes:{rowActions:[{label:"Mostra Dettaglio", name: "show_details"}]}}
    ]

    connectedCallback() {
        let recordId = this.recordId;
        this.isRendered = false;

        loadStyle(this, cssReassignAccountToWallet);

        getAllData({ recordId: recordId })
            .then(result => {
                console.log('SV getAllData result', result);

                this.getAllData = result;
                
            })
            .catch(error => {
                alert('ERROR');
                this.error = error;
                console.log('SV ERROR', error);
                this.isRendered = true;
            })
            .finally(() => {
                console.log('SV FINALLY');

                let allData = this.getAllData;
                
                let rows = [];
                let rowsAll = [];
                let count = 0;
                for (let key in allData) {
                    allData[key].PTF_Url = '/' + key;

                    if(allData[key].PTF_CoerenzaGruge__c.includes('green.png')){
                        allData[key].typeCSSClass = 'green';
                    } else if(allData[key].PTF_CoerenzaGruge__c.includes('red.png')){
                        allData[key].typeCSSClass = 'red';
                    }

                    if(count < this.numRows){
                        count ++;
                        rows.push(allData[key]);
                    }
                    rowsAll.push(allData[key]);
                }

                this.listViewData = rows;
                this.listViewDataAll = rowsAll; 
                this.totalElement = rowsAll.length;

                this.isRendered = true;
            }); 
    }

    // handleRowAction(event) {
    //     const actionName = event.detail.action.name;
    //     const row = event.detail.row; // riga selezionata con tutti i campi

    //     // View a custom object record.
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__recordPage',
    //         attributes: {
    //             recordId: row.Id,
    //             objectApiName: 'Account', // objectApiName is optional
    //             actionName: 'view'
    //         }
    //     });
    // }

    // handleRowActionMW(event) {
    //     const actionName = event.detail.action.name;
    //     const row = event.detail.row; // riga selezionata con tutti i campi

    //     // View a custom object record.
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__recordPage',
    //         attributes: {
    //             recordId: row.Id,
    //             objectApiName: 'Wallet__c', // objectApiName is optional
    //             actionName: 'view'
    //         }
    //     });
    // }
    handleAssign(event){
        let recordId = this.recordId;
        this.isRendered = false;

        getAssignData({ recordId: recordId })
            .then(result => {
                console.log('SV getAssignData result', result);

                this.getAssignData=result;
            })
            .catch(error => {
                alert('ERROR');
                this.error = error;
                console.log('SV ERROR', error);
                this.isRendered = true;
            })
            .finally(() => {
                console.log('SV FINALLY');

                let assignData = this.getAssignData;
                
                
                let rowsAll = [];
                let count = 0;
                for (let key in assignData) {
                    assignData[key].PTF_Url = '/' + key;

                    if(assignData[key].PTF_CoerenzaGruge__c.includes('green.png')){
                        assignData[key].typeCSSClass = 'green';
                    } else if(assignData[key].PTF_CoerenzaGruge__c.includes('red.png')){
                        assignData[key].typeCSSClass = 'red';
                    }

                    
                    rowsAll.push(assignData[key]);
                }

                
                this.listViewAssign = rowsAll; 

                this.openModalAssign();
                this.isRendered = true;
            }); 
            

    }

    handleReassign(event) {
        let recordId = this.recordId;
        this.isRendered = false;

        getMW({ recordId: recordId })
            .then(result => {
                console.log('SV getMW result', result);

                this.getMW = result;
                
            })
            .catch(error => {
                alert('ERROR');
                this.error = error;
                console.log('SV ERROR', error);
                this.isRendered = true;
            })
            .finally(() => {
                console.log('SV FINALLY');

                let allmw = this.getMW;

                let rowsAll = [];
                for (let key in allmw) {
                    allmw[key].PTF_Url = '/' + key;

                    rowsAll.push(allmw[key]);
                }

                
                this.listViewMW = rowsAll; 

                this.stepModal1 = false;
                this.stepModal2 = true;
                this.openModal();
                this.isRendered = true;

            }); 
    }

    handleViewAll(event) {

        this.stepModal1 = true;
        this.stepModal2 = false;
        this.openModal();

    }

    getSelectedRowsAssign(event){
        let selectedR = event.detail.selectedRows;
        // Display that fieldName of the selected rows
        let rows = [];
        for (let i = 0; i < selectedR.length; i++){
            rows.push(selectedR[i].Id);
        }

        this.selectedRowsAssign = rows;
    }

    getSelectedRows(event){
        let selectedR = event.detail.selectedRows;
        // Display that fieldName of the selected rows
        let rows = [];
        for (let i = 0; i < selectedR.length; i++){
            rows.push(selectedR[i].Id);
        }

        this.selectedRows = rows;
    }

    getSelectedRowsMW(event){
        let selectedR = event.detail.selectedRows;
        // Display that fieldName of the selected rows
        let rows = [];
        for (let i = 0; i < selectedR.length; i++){
            rows.push(selectedR[i].Id);
        }

        this.selectedRowsMW = rows;
    }
    openModalAssign(){
        this.openmodelAssign = true;
    }

    openModal() {
        this.openmodel = true;
    }

    closeModalAssign(){
        this.openmodelAssign = false;
    }

    closeModal() {
        this.openmodel = false;
    } 

    returnModal(){
        this.openmodel = false;
    }

    get notEmptyList(){
        return this.listViewData.length > 0;
    }
    assignAccount(){
        
        let recordId = this.recordId;
        this.isRendered = false;

        assignSelectedAccounts({recordId: recordId, accounts:this.selectedRowsAssign})
        .then(result => {

            console.log('SV assignSelectedAccount result', result);

            const toastEvent = new ShowToastEvent({
                title: "Successo!",
                message: "Gli NDG sono stati assegnati con successo al Micro-Portafoglio",
                variant: "success"
            });
            this.dispatchEvent(toastEvent);
            this.isRendered=true;
            this.closeModalAssign();
            /*this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recordId,
                    objectApiName: 'Wallet__c', // objectApiName is optional
                    actionName: 'view'
                }
            });*/
            this.connectedCallback();


            
        })
        .catch(error => {
            console.log('SV ERROR', error);
            const toastEvent = new ShowToastEvent({
                title: "Errore!",
                message: error.body.message,
                variant: "error"
            });
            this.dispatchEvent(toastEvent);

            this.isRendered = true;
        })
        .finally(() => {
            console.log('SV FINALLY');
            
        });

    }
    reassignAccount(event){
        let recordId = this.recordId;

        this.isRendered = false;


        reassignSelectedAccount({ x_from: recordId, accounts: this.selectedRows, x_to: this.selectedRowsMW[0] })
        .then(result => {
            console.log('SV reassignSelectedAccount result', result);

            const toastEvent = new ShowToastEvent({
                title: "Successo!",
                message: "Gli NDG sono stati spostati con successo al Micro-Portafoglio selezionato",
                variant: "success"
            });
            this.dispatchEvent(toastEvent);

                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.selectedRowsMW[0],
                        objectApiName: 'Wallet__c', // objectApiName is optional
                        actionName: 'view'
                    }
                });
        })
        .catch(error => {
            console.log('SV ERROR', error);
            const toastEvent = new ShowToastEvent({
                title: "Errore!",
                message: error.body.message,
                variant: "error"
            });
            this.dispatchEvent(toastEvent);

            this.isRendered = true;
        })
        .finally(() => {
            console.log('SV FINALLY');

        }); 
    }
    
}