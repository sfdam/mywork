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

import NDG from '@salesforce/label/c.treeGridGruppi_CLM_NDG';
import Nominativo from '@salesforce/label/c.treeGridGruppi_CLM_Nominativo';
import FilialeRelazione from '@salesforce/label/c.treeGridGruppi_CLM_FilialeRelazione';
import NaturaGiuridica from '@salesforce/label/c.treeGridGruppi_CLM_NaturaGiuridica';
import Tipo from '@salesforce/label/c.treeGridGruppi_CLM_Tipo';
import Descrizione from '@salesforce/label/c.treeGridGruppi_CLM_Descrizione';


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
        fieldName: 'PTF_Url',
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
    /*
    {
        type: 'url',
        fieldName: 'PTF_Url_MP',
        typeAttributes: {
            label: { fieldName: 'PTF_MicroP' }
        },
        label: 'Micro-Portafoglio',
    },*/
    {
        type: 'text',
        fieldName: 'PTF_NaturaGiuridica__c',
        label: NaturaGiuridica
    },
    {
        type: 'text',
        fieldName: 'ModelloDiServizio__c',
        label: 'Macro Modello di Servizio',
    },
    {
        type: 'text',
        fieldName: 'PTF_SegmentoComportamentale__c',
        label: 'Segmento Comportamentale',
    },
    // {"type":"action","typeAttributes":{"rowActions":[{"label":"Mostra Dettaglio", "name": "show_details"}]}}
];

import getAllData from '@salesforce/apex/treeGridGruppiController.getAllData';
import getRecordInfo from '@salesforce/apex/treeGridGruppiController.getRecordInfo';

// import { getRecord } from 'lightning/uiRecordApi';
// import ACCOUNT_RECORDTYPE_FIELD from '@salesforce/schema/Account.RecordTypeId';

export default class TreeGridGruppi extends NavigationMixin(LightningElement) {
    @track loaded = false;
    @track error;
    @api recordId;
    @api account;
    @api showComponent;

    @api title;
    @api iconName;
    @api numRows;
    @api recordTypes;
    @track numberMember;
    @api isRendered;
    @api openmodel = false;

    @api getAllData;

    // definition of columns for the tree grid
    gridColumns = EXAMPLES_COLUMNS_DEFINITION_BASIC;

    // data provided to the tree grid
    gridData = [];
    gridDataAll = [];

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
        console.log('Connected CallBack');
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
                let rows = [];
                let rowsAll = [];

                if(this.account.RecordType.DeveloperName !== 'GruppoFinanziario'){
                    console.log('@@@@allData: '+JSON.stringify(allData));
                    
                    if(allData.hasOwnProperty('gruppiMap')){
                        for(let keyG in allData['gruppiMap']){
                            
                            allData['gruppiMap'][keyG].PTF_Filiale = allData['gruppiMap'][keyG].hasOwnProperty('PTF_Filiale__c') ? allData['gruppiMap'][keyG].PTF_Filiale__r.Name : '';
                            allData['gruppiMap'][keyG]._children = [];
                                
                                for(let keyA in allData['accMap']){
                                    if(allData['accToLinkObj'][keyA]){
                                        allData['accMap'][keyA].CRM_LinkCode = allData['accToLinkObj'][keyA].CRM_LinkCode__c;
                                        allData['accMap'][keyA].PTF_Gruppo__c = allData['accToLinkObj'][keyA].CRM_Account__c;
                                        if(allData['accMap'][keyA].hasOwnProperty('PTF_Gruppo__c') && allData['accMap'][keyA].PTF_Gruppo__c === keyG){
                                            allData['accMap'][keyA].PTF_Filiale = allData['accMap'][keyA].hasOwnProperty('PTF_Filiale__c') ? allData['accMap'][keyA].PTF_Filiale__r.Name : '';
                                            allData['accMap'][keyA].PTF_Url = '/' + keyA;
                                            allData['accMap'][keyA].provenanceIconName='utility:level_down';
                                            allData['gruppiMap'][keyG]._children.push(allData['accMap'][keyA]);
                                        }
                                        if(allData['accMap'][keyA].Id === this.recordId){
                                            allData['accMap'][keyA].typeCSSClass='treeGrid-green';
                                        }
                                    }
                                    
                                }
        
                                allData['gruppiMap'][keyG].PTF_Url = '/' + keyG;
                                allData['gruppiMap'][keyG]._children = allData['gruppiMap'][keyG]._children.sort( this.compare );
                                
                            
    
                        }
    
                        
                        for(let key in allData['gruppiMap']){
                            
                            if(rows.length < this.numRows){
                                rows.push(allData['gruppiMap'][key]);
                            }
                            rowsAll.push(allData['gruppiMap'][key]);
                        }
                        
                        console.log('rows: ' + JSON.stringify(rows));
                    }                    

                } else {

                    
                    if(allData.hasOwnProperty('accMap')){
                        for(let key in allData['accMap']){

                            if(allData['accToLinkObj'][key]){
                                allData['accMap'][key].CRM_LinkCode = allData['accToLinkObj'][key].CRM_LinkCode__c;
                                allData['accMap'][key].PTF_Url = '/' + key;
                                allData['accMap'][key].PTF_Filiale = allData['accMap'][key].hasOwnProperty('PTF_Filiale__c') ? allData['accMap'][key].PTF_Filiale__r.Name : '';
                                if(rows.length < this.numRows){
                                    rows.push(allData['accMap'][key]);
                                }
                                rowsAll.push(allData['accMap'][key]);
                            }


                            
                            
    
                            
                        }
                    }

                    this.title = 'NDG Gruppo Finanziario' + ' ' + '(' + rowsAll.length +')';
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

                    /*for(let keyC in allData['gruppiMap']){
                        let splitKey = keyC.split('_');
                        if(splitKey[1] !== this.recordId){
                            if(!gruppiId.includes(splitKey[1])){
                                gruppiId.push(splitKey[1]);
                                allData['accMap'][splitKey[1]].codTipo = allData['gruppiMap'][keyC].CRM_PrimaryNDG__c ? '188' : '101';
                                allData['accMap'][splitKey[1]].Description = allData['gruppiMap'][keyC].CRM_PrimaryNDG__c ? 'NDG Primario' : 'NDG Cointestatario';
                                allData['accMap'][splitKey[1]].PTF_Filiale = allData['accMap'][splitKey[1]].hasOwnProperty('PTF_Filiale__c') ? allData['accMap'][splitKey[1]].PTF_Filiale__r.Name : '';
                                allData['accMap'][splitKey[1]].PTF_MicroP = allData['accMap'][splitKey[1]].hasOwnProperty('PTF_Portafoglio__c') ? allData['accMap'][splitKey[1]].PTF_MicroWallet__r.Name : '';
                                allData['accMap'][splitKey[1]].PTF_Url_NDG = '/' + splitKey[1];
                                allData['accMap'][splitKey[1]].PTF_Url_MP = allData['accMap'][splitKey[1]].hasOwnProperty('PTF_Portafoglio__c') ? '/' + allData['accMap'][splitKey[1]].PTF_Portafoglio__c : '';
                                
                                if(gruppiId.length < this.numRows){
                                    listViewData.push(allData['accMap'][splitKey[1]]);
                                }
                                listViewDataAll.push(allData['accMap'][splitKey[1]]);
                            }
                        }

                    }*/
                }




                this.gridData = rows.sort( this.compare );
                this.gridDataAll = rowsAll.sort( this.compare );
                ;
                this.setPages(this.gridDataAll);
                this.totNumRows = rowsAll.length;

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

      compare( a, b ) {
        if ( a.CRM_LinkCode < b.CRM_LinkCode ){
          return -1;
        }
        if ( a.CRM_LinkCode > b.CRM_LinkCode ){
          return 1;
        }
        return 0;
    }

  
  
    //Test Pagination
}