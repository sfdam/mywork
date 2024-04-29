/* eslint-disable no-prototype-builtins */
/* eslint-disable dot-notation */
/* eslint-disable guard-for-in */
/* eslint-disable no-alert */
/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';

// Import ToastEvent

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

import cssTreeGrid from '@salesforce/resourceUrl/reassignAccountToWallet';

import NDG from '@salesforce/label/c.treeGrid_CLM_NDG';
import Nominativo from '@salesforce/label/c.treeGrid_CLM_Nominativo';
import FilialeRelazione from '@salesforce/label/c.treeGrid_CLM_FilialeRelazione';
import MicroPortafoglio from '@salesforce/label/c.treeGrid_CLM_MicroPortafoglio';
import NaturaGiuridica from '@salesforce/label/c.treeGrid_CLM_NaturaGiuridica';
import Tipo from '@salesforce/label/c.treeGrid_CLM_Tipo';
import Descrizione from '@salesforce/label/c.treeGrid_CLM_Descrizione';


/**
 * Sample data
 * :: used by examples
 */
export const EXAMPLES_DATA_BASIC = [
    {
        name: '123556',
        accountName: 'Acme Corporation',
        employees: 10000,
        phone: '837-555-0100',
        accountOwner: 'http://salesforce.com/fake/url/jane-doe',
        accountOwnerName: 'John Doe',
        billingCity: 'San Francisco, CA',
        description: 'test',
        provenanceIconName: '',
        provenanceIconLabel: '',
        typeCSSClass: '',
        _children: [
            {
                name: '123556-A',
                accountName: 'Acme Corporation (Bay Area)',
                employees: 3000,
                phone: '837-555-0100',
                accountOwner: 'http://salesforce.com/fake/url/jane-doe',
                accountOwnerName: 'John Doe',
                billingCity: 'New York, NY',
                description: 'test',
                provenanceIconName: 'utility:level_down',
                provenanceIconLabel: '',
                typeCSSClass: 'pippo'
            },

            {
                name: '123556-B',
                accountName: 'Acme Corporation (East)',
                employees: 430,
                phone: '837-555-0100',
                accountOwner: 'http://salesforce.com/fake/url/jane-doe',
                accountOwnerName: 'John Doe',
                billingCity: 'San Francisco, CA',
                description: 'test',
                provenanceIconName: 'utility:level_down',
                provenanceIconLabel: '',
                typeCSSClass: ''
            },

            {
                name: '123556-B',
                accountName: 'Acme Corporation (East)',
                employees: 430,
                phone: '837-555-0100',
                accountOwner: 'http://salesforce.com/fake/url/jane-doe',
                accountOwnerName: 'John Doe',
                billingCity: 'San Francisco, CA',
                description: 'test',
                provenanceIconName: 'utility:level_down',
                provenanceIconLabel: '',
                typeCSSClass: ''
            },
        ],
    },

    {
        name: '123558',
        accountName: 'Tech Labs',
        employees: 1856,
        phone: '837-555-0100',
        accountOwner: 'http://salesforce.com/fake/url/jane-doe',
        accountOwnerName: 'John Doe',
        billingCity: 'New York, NY',
        description: 'test',
        provenanceIconName: '',
        provenanceIconLabel: '',
        typeCSSClass: '',
        _children: [
            {
                name: '123558-A',
                accountName: 'Opportunity Resources Inc',
                employees: 1934,
                phone: '837-555-0100',
                accountOwner: 'http://salesforce.com/fake/url/jane-doe',
                accountOwnerName: 'John Doe',
                billingCity: 'Los Angeles, CA',
                description: 'test',
                provenanceIconName: 'utility:level_down',
                provenanceIconLabel: '',
                typeCSSClass: ''
            },

            {
                name: '123558-A',
                accountName: 'Opportunity Resources Inc',
                employees: 1934,
                phone: '837-555-0100',
                accountOwner: 'http://salesforce.com/fake/url/jane-doe',
                accountOwnerName: 'John Doe',
                billingCity: 'Los Angeles, CA',
                description: 'test',
                provenanceIconName: 'utility:level_down',
                provenanceIconLabel: '',
                typeCSSClass: ''
            },
        ],
    },
];

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
        fieldName: 'PTF_Url_NDG',
        cellAttributes:{ iconName: { fieldName: 'provenanceIconName' } },
        typeAttributes: {
            label: { fieldName: 'CRM_NDG__c' }
        },
        label: NDG,
        initialWidth: 180,
    },
    {
        type: 'text',
        fieldName: 'Name',
        cellAttributes:{ class: { fieldName: 'typeCSSClass' } },
        label: Nominativo,
    },
    {
        type: 'text',
        fieldName: 'PTF_Filiale',
        label: FilialeRelazione,
    },
    {
        type: 'url',
        fieldName: 'PTF_Url_MP',
        typeAttributes: {
            label: { fieldName: 'PTF_MicroP' }
        },
        label: MicroPortafoglio,
    },
    {
        type: 'text',
        fieldName: 'PTF_NaturaGiuridica__c',
        label: NaturaGiuridica
    },
    {
        type: 'text',
        fieldName: 'codTipo',
        label: Tipo,
    },
    {
        type: 'text',
        fieldName: 'Description',
        label: Descrizione,
    },
    // {"type":"action","typeAttributes":{"rowActions":[{"label":"Mostra Dettaglio", "name": "show_details"}]}}
];

import getAllData from '@salesforce/apex/TreeGridController.getAllData';
import getRecordInfo from '@salesforce/apex/TreeGridController.getRecordInfo';

// import { getRecord } from 'lightning/uiRecordApi';
// import ACCOUNT_RECORDTYPE_FIELD from '@salesforce/schema/Account.RecordTypeId';

export default class TreeGrid extends NavigationMixin(LightningElement) {
    @track loaded = false;
    @track error;
    @api recordId;
    @api account;
    @api showComponent;

    @api title;
    @api iconName;
    @api numRows;
    @api recordTypes;

    @api isRendered;
    @api openmodel = false;

    @api getAllData;

    // definition of columns for the tree grid
    gridColumns = EXAMPLES_COLUMNS_DEFINITION_BASIC;

    // data provided to the tree grid
    gridData;
    gridDataAll;

    // @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_RECORDTYPE_FIELD] })
    // getAccount({ error, data }){
    //     if(data){
    //         alert('wire');

    //         var result = JSON.parse(JSON.stringify(data));
    //         console.log('acc data: ', result);
    //         this.account = result;
    //         this.recordTypeId = result.fields.RecordTypeId.value;
    //         this.recordTypeName = result.recordTypeInfo.name;
        
    //     }else if(error) {
    //         var result = JSON.parse(JSON.stringify(error));
    //         console.log('error: ', result);
    //     }
    // };

    connectedCallback() {
        this.isRendered = false;
        loadStyle(this, cssTreeGrid);

        getRecordInfo({ recordId: this.recordId })
            .then(result => {
                console.log('SV getRecordInfo result', result);

                this.account = result;
                this.showComponent = this.recordTypes.includes(this.account.RecordType.DeveloperName);

                return getAllData({ recordId: this.recordId, recordType: this.account.RecordType.DeveloperName });
                
            })
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
                let allData = this.getAllData;
                let listViewData = [];
                let listViewDataAll = [];

                let cointestazioniId = [];

                if(this.account.RecordType.DeveloperName === 'PersonAccount'){
                    for(let keyC in allData['cointestazioniMap']){
                        let splitKey = keyC.split('_');

                        let objChildren = JSON.parse(JSON.stringify(allData['accMap'][splitKey[1]]));
                            
                        if(!cointestazioniId.includes(splitKey[0])){
                            allData['accMap'][splitKey[0]]._children = [];
                        }
                        objChildren.provenanceIconName = 'utility:level_down';
                        if(this.recordId === splitKey[1]) objChildren.typeCSSClass = 'treeGrid-green';
                        
                        objChildren.PTF_Filiale = objChildren.hasOwnProperty('PTF_Filiale__c') ? objChildren.PTF_Filiale__r.Name : '';
                        objChildren.PTF_MicroP = objChildren.hasOwnProperty('PTF_Portafoglio__c') ? objChildren.PTF_Portafoglio__r.Name : '';
                        objChildren.PTF_Url_NDG = '/' + splitKey[1];
                        objChildren.PTF_Url_MP = objChildren.hasOwnProperty('PTF_Portafoglio__c') ? '/' + objChildren.PTF_Portafoglio__c : '';


                        objChildren.codTipo = allData['cointestazioniMap'][keyC].CRM_PrimaryNDG__c ? '188' : '101';
                        objChildren.Description = allData['cointestazioniMap'][keyC].CRM_PrimaryNDG__c ? 'NDG Primario' : 'NDG Cointestatario';
                        allData['accMap'][splitKey[0]]._children.push(objChildren);
                        allData['accMap'][splitKey[0]]._children.sort(function( a , b){
                            if(a.codTipo > b.codTipo) return -1;
                            if(a.codTipo < b.codTipo) return 1;
                            return 0;
                        });
                        allData['accMap'][splitKey[0]].provenanceIconName = '';
                        allData['accMap'][splitKey[0]].PTF_Filiale = allData['accMap'][splitKey[0]].hasOwnProperty('PTF_Filiale__c') ? allData['accMap'][splitKey[0]].PTF_Filiale__r.Name : '';
                        allData['accMap'][splitKey[0]].PTF_MicroP = allData['accMap'][splitKey[0]].hasOwnProperty('PTF_Portafoglio__c') ? allData['accMap'][splitKey[0]].PTF_Portafoglio__r.Name : '';
                        allData['accMap'][splitKey[0]].PTF_Url_NDG = '/' + splitKey[0];
                        allData['accMap'][splitKey[0]].PTF_Url_MP = allData['accMap'][splitKey[0]].hasOwnProperty('PTF_Portafoglio__c') ? '/' + allData['accMap'][splitKey[0]].PTF_Portafoglio__c : '';


                        if(!cointestazioniId.includes(splitKey[0])){
                            cointestazioniId.push(splitKey[0]);
                            if(cointestazioniId.length < this.numRows){
                                listViewData.push(allData['accMap'][splitKey[0]]);
                            }
                            listViewDataAll.push(allData['accMap'][splitKey[0]]);
                        }
                        console.log('294'+JSON.stringify(listViewDataAll));
                    }
                } else {

                    this.title = 'NDG Cointestazione';
                    //PTF_MicroWallet__c
                    // for(let keyA in allData['accMap']){
                    //     if(keyA != this.recordId){
                    //         if(!cointestazioniId.includes(keyA)){
                    //             cointestazioniId.push(keyA);
                    //             if(cointestazioniId.length < this.numRows){
                    //                 listViewData.push(allData['accMap'][keyA]);
                    //             }
                    //             listViewDataAll.push(allData['accMap'][keyA]);
                    //         }
                    //     }
                    // }

                    for(let keyC in allData['cointestazioniMap']){
                        let splitKey = keyC.split('_');
                        if(splitKey[1] !== this.recordId){
                            if(!cointestazioniId.includes(splitKey[1])){
                                cointestazioniId.push(splitKey[1]);
                                allData['accMap'][splitKey[1]].codTipo = allData['cointestazioniMap'][keyC].CRM_PrimaryNDG__c ? '188' : '101';
                                allData['accMap'][splitKey[1]].Description = allData['cointestazioniMap'][keyC].CRM_PrimaryNDG__c ? 'NDG Primario' : 'NDG Cointestatario';
                                allData['accMap'][splitKey[1]].PTF_Filiale = allData['accMap'][splitKey[1]].hasOwnProperty('PTF_Filiale__c') ? allData['accMap'][splitKey[1]].PTF_Filiale__r.Name : '';
                                allData['accMap'][splitKey[1]].PTF_MicroP = allData['accMap'][splitKey[1]].hasOwnProperty('PTF_Portafoglio__c') ? allData['accMap'][splitKey[1]].PTF_Portafoglio__r.Name : '';
                                allData['accMap'][splitKey[1]].PTF_Url_NDG = '/' + splitKey[1];
                                allData['accMap'][splitKey[1]].PTF_Url_MP = allData['accMap'][splitKey[1]].hasOwnProperty('PTF_Portafoglio__c') ? '/' + allData['accMap'][splitKey[1]].PTF_Portafoglio__c : '';
                                
                                if(cointestazioniId.length < this.numRows){
                                    listViewData.push(allData['accMap'][splitKey[1]]);
                                }
                                listViewDataAll.push(allData['accMap'][splitKey[1]]);
                            }
                        }

                    }
                    listViewData.sort(function( a , b){
                        if(a.codTipo > b.codTipo) return -1;
                        if(a.codTipo < b.codTipo) return 1;
                        return 0;
                    });
                    listViewDataAll.sort(function( a , b){
                        if(a.codTipo > b.codTipo) return -1;
                        if(a.codTipo < b.codTipo) return 1;
                        return 0;
                    });

                }

                console.log(listViewDataAll);

                this.gridExpandedRows = cointestazioniId;
                this.gridData = listViewData;
                this.gridDataAll = listViewDataAll;
                //Test Pagination
                this.setPages(this.gridDataAll);
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
                objectApiName: 'Account', // objectApiName is optional
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

    //Test Pagination
    @track page = 1;
    perpage = 100;
    @track pages = [];
    set_size = 100;
    

    handleAvanti(){
        ++this.page;
    }
    handleIndietro(){
        --this.page;
    }
    
      get pagesList(){
          let mid = Math.floor(this.set_size/2) + 1 ;
          if(this.page > mid){
              return this.pages.slice(this.page-mid, this.page+mid-1);
          } 
          return this.pages.slice(0,this.set_size);
       }
      
       
      
      pageData = ()=>{
          let page = this.page;
          let perpage = this.perpage;
          let startIndex = (page*perpage) - perpage;
          let endIndex = (page*perpage);
          return this.gridDataAll.slice(startIndex,endIndex);
       }
  
      setPages = (data)=>{
          let numberOfPages = Math.ceil(data.length / this.perpage);
          for (let index = 1; index <= numberOfPages; index++) {
              this.pages.push(index);
          }
       }  
      
      get disabledButtonIndietro(){
          return this.page === 1;
      }
      
      get disabledButtonAvanti(){
          return this.page === this.pages.length
      }
  
      
  
      get currentPageData(){
          return this.pageData();
      }
  
  
    //Test Pagination
    
}