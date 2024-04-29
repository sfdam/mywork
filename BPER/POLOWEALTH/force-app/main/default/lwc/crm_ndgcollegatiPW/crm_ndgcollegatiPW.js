import { LightningElement, api, track, wire } from 'lwc';

import getUserInfo from '@salesforce/apex/SV_Utilities.getUserInfo';
import getAllData from '@salesforce/apex/CRM_NDGCollegatiPW.getAllData';

import { getRecord } from 'lightning/uiRecordApi';
import ACCOUNT_NDGGOVERNO_FIELD from "@salesforce/schema/Account.CRM_NDGGoverno__c";
import ACCOUNT_ABI_FIELD from "@salesforce/schema/Account.FinServ__BankNumber__c";

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

/**
 * Default settings values
 */
export const KEYFIELD = 'Id';

/**
  * Columns definition
  * :: used in examples
  */
export const EXAMPLES_COLUMNS_DEFINITION_BASIC = [

    {
        type: 'url',
        fieldName: 'PTF_Url',
        /*cellAttributes:{ iconName: { fieldName: 'provenanceIconName' } },*/
        typeAttributes: {
            label: { fieldName: 'CRM_NDG' }
        },
        label: 'NDG',
    },
    {
        type: 'text',
        fieldName: 'Name',
        cellAttributes:{ class: { fieldName: 'typeCSSClass' } },
        label: 'NOME',
    },
    {
        type: 'text',
        fieldName: 'PTF_StatoCRMFull__c',
        label: 'STATO CRM',
    },
    {
        type: 'text',
        fieldName: 'CRM_LinkType__c',
        label: 'TIPO COLLEGAMENTO',
    },
    {
        type: 'text',
        fieldName: 'PTF_Filiale',
        label: 'FILIALE',
    },
    {
        type: 'text',
        fieldName: 'ModelloDiServizio__c',
        label: 'M-MDS',
    },
    { 
        label: 'PORTAFOGLIO', 
        fieldName: 'CRM_NomePortafoglio__c', 
        type: 'text',
        initialWidth: 180
    },
    { 
        label: 'REFERENTE', 
        fieldName: 'CRM_ReferenteNameFormula__c', 
        type: 'text'
    }
];

export const EXAMPLES_COLUMNS_DEFINITION_BASICNOLINK = [

    {
        type: 'text',
        fieldName: 'PTF_Url',
        label: 'NDG',
    },
    {
        type: 'text',
        fieldName: 'Name',
        cellAttributes:{ class: { fieldName: 'typeCSSClass' } },
        label: 'NOME',
    },
    {
        type: 'text',
        fieldName: 'PTF_StatoCRMFull__c',
        label: 'STATO CRM',
    },
    {
        type: 'text',
        fieldName: 'CRM_LinkType__c',
        label: 'TIPO COLLEGAMENTO',
    },
    {
        type: 'text',
        fieldName: 'PTF_Filiale',
        label: 'FILIALE',
    },
    {
        type: 'text',
        fieldName: 'ModelloDiServizio__c',
        label: 'M-MDS',
    },
    { 
        label: 'PORTAFOGLIO', 
        fieldName: 'CRM_NomePortafoglio__c', 
        type: 'text',
        initialWidth: 180
    },
    { 
        label: 'REFERENTE', 
        fieldName: 'CRM_ReferenteNameFormula__c', 
        type: 'text'
    }
];

export default class Crm_ndgcollegatiPW extends NavigationMixin(LightningElement) {

    @api recordId;
    @api title;
    @api iconName;

    @track ndgGoverno='';
    @track ndgAbi='';
    @track userInfo='';
    @track getAllData='';
    @track isRendered='';

    // definition of columns for the tree grid
    gridColumns = EXAMPLES_COLUMNS_DEFINITION_BASIC;

    // data provided to the tree grid
    gridData = [];

    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_NDGGOVERNO_FIELD, ACCOUNT_ABI_FIELD] })
    getAccount({ error, data }){
        if(data){
            
            let result = JSON.parse(JSON.stringify(data));
            console.log('acc result: ', result);

            this.ndgGoverno = result.fields.CRM_NDGGoverno__c.value;
            this.ndgAbi = result.fields.FinServ__BankNumber__c.value;
            console.log('acc ndgGoverno: ', this.ndgGoverno);
            console.log('acc ndgAbi: ', this.ndgAbi);

        }else if(error) {
            let result = JSON.parse(JSON.stringify(error));
            console.log('error: ', result);
        }
    };

    connectedCallback(){
        getUserInfo()
        .then(result => {
            console.log('DK getUserInfo result', result);

            this.userInfo = result;

            return getAllData({ recordId: this.recordId, ndgGoverno: this.ndgGoverno, abiQuest: this.ndgAbi === '05387' ? '03084' : '05387' });

        }).then(result => {
            console.log('SV getAllData result', result);

            this.getAllData = result;
            
        }).catch(error => {

            console.log('DK error: ' + JSON.stringify(error));
        }).finally(() => {
            let allData = this.getAllData;

            let obj = allData.accMap ? JSON.parse(JSON.stringify(allData.accMap)) : {};
            if(obj[0]){

            
            console.log('SV obj 1', obj);
            console.log('SV obj 1.1', obj[0].FinServ__BankNumber__c);
            console.log('SV obj profile.name', this.userInfo.ProfileId);
            
            
            if((obj[0].FinServ__BankNumber__c == '03084' &&  this.userInfo.ProfileId!='00e3X000001BszcQAC') /*|| (obj[0].FinServ__BankNumber__c == '05387' &&  obj[0].ModelloDiServizio__c !='Cesare Ponti' &&  this.userInfo.ProfileId!='00e3X000001BszcQAC')*/){
                console.log('SV obj 2', obj[0].FinServ__BankNumber__c);
                this.gridColumns = EXAMPLES_COLUMNS_DEFINITION_BASICNOLINK;
            }else{
                console.log('SV obj 3', obj[0].FinServ__BankNumber__c);
                this.gridColumns = EXAMPLES_COLUMNS_DEFINITION_BASIC;
            }
            
            
            let isObjectEmpty = (obj) => {
                for (let prop in obj) {
                    //console.log('objectName: ', obj);
                    //console.log('objectName.hasOwnProperty(prop): ', obj.hasOwnProperty(prop));
                    if (obj.hasOwnProperty(prop)) {
                        return false;
                    }
                }
                return true;
            };
            //this.isObjectEmpty = false;




            console.log('isObjectEmpty: ', obj[0].Id);
            if(true){
                if ((obj[0].FinServ__BankNumber__c == '03084' &&  this.userInfo.ProfileId!='00e3X000001BszcQAC') /*|| (obj[0].FinServ__BankNumber__c == '05387' &&  obj[0].ModelloDiServizio__c !='Cesare Ponti' &&  this.userInfo.ProfileId!='00e3X000001BszcQAC')*/){
                    obj.PTF_Url =  obj[0].CRM_NDG__c;
                } else {
                    obj.PTF_Url =  '/' + obj[0].Id;
                }

                //obj.PTF_Url =  '/' + obj[0].Id;
                obj.CRM_NDG = obj[0].CRM_NDG__c;
                obj.Name = obj[0].Name;
                obj.PTF_StatoCRMFull__c = obj[0].PTF_StatoCRMFull__c;
                obj.CRM_LinkType__c = 'PRIMARIO';
                obj.PTF_Filiale = (obj[0].PTF_Filiale__c!= null) ? obj[0].PTF_Filiale__r.Name : '';
                obj.ModelloDiServizio__c = obj[0].ModelloDiServizio__c;
                obj.CRM_NomePortafoglio__c = obj[0].CRM_NomePortafoglio__c;
                obj.CRM_ReferenteNameFormula__c = obj[0].CRM_ReferenteNameFormula__c;

                /*obj._children = JSON.parse(JSON.stringify(allData.ListCOMap));
                console.log('isObjectEmpty: ', obj._children);
                obj._children.forEach(element => {
                    element.PTF_Url = '/' + element.Id;
                });*/
                
                console.log('SV obj', obj);
    
                this.gridData.push(obj);
            }

            /*if(obj[0].FinServ__BankNumber__c === '05387') {
                this.gridColumns[0].type = 'text';
                this.gridColumns[0].fieldName = 'CRM_NDG__c';
            }*/

            console.log('SV gridColumns', this.gridColumns);


            this.isRendered = true;
        }
        });
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
                objectApiName: 'Account', // objectApiName is optional
                actionName: 'view'
            }
        });
    }
}