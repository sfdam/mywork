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

import NDG from '@salesforce/label/c.gruppiFinanziariTreeGridPortafoglio_CLM_NDG';
import AccountName from '@salesforce/label/c.gruppiFinanziariTreeGridPortafoglio_CLM_AccountName';
import NaturaGiuridica from '@salesforce/label/c.gruppiFinanziariTreeGridPortafoglio_CLM_NaturaGiuridica';
import MicroPortafoglio from '@salesforce/label/c.gruppiFinanziariTreeGridPortafoglio_CLM_MicroPortafoglio';
import FilialeRelazione from '@salesforce/label/c.gruppiFinanziariTreeGridPortafoglio_CLM_FilialeRelazione';
import OFS from '@salesforce/label/c.gruppiFinanziariTreeGridPortafoglio_CLM_OFS';
import NumeroGruppo from '@salesforce/label/c.gruppiFinanziariTreeGridPortafoglio_CLM_NumeroGruppo';

/**
 * Default settings values
 */
export const KEYFIELD = 'Id';

/**
 * Columns definition
 * :: used in examples
 */
export const EXAMPLES_COLUMNS_DEFINITION_BASIC = [
        { label: NDG, fieldName: 'PTF_Url', type: 'url', typeAttributes: {label: { fieldName: 'CRM_NDG__c' }} },
        { label: AccountName, fieldName: 'Name', type: 'text', cellAttributes:{class:{fieldName: 'typeCSSClass' }}},
        { label: "Macro Modello di Servizio", fieldName: 'ModelloDiServizio__c', type: 'text' },
        { label: "Segmento Comportamentale", fieldName: 'PTF_SegmentoComportamentale__c', type: 'text' },
        { label: NaturaGiuridica, fieldName: 'PTF_NaturaGiuridica__c', type: 'text', cellAttributes:{class:{fieldName: 'typeNGCSSClass' }}},
        { label: MicroPortafoglio, fieldName: 'PTF_MPUrl', type: 'url', typeAttributes: {label: { fieldName: 'PTF_MPName' }}},
        // { label: 'Filiale di Relazione', fieldName: 'Filiale__c', type: 'text'},
        {
        type: 'text',
        fieldName: 'PTF_Filiale',
        label: FilialeRelazione,
        },
        { label: "Sportello leggero", fieldName: 'nomeSL', type: 'text', 
            typeAttributes: {
                label: { fieldName: 'PTF_MiniPortafoglio__r' }
            },
        },
        // { label: 'OFS', fieldName: 'PTF_OFS__c', type: 'text' },
        /*{ label: OFS, fieldName: '', type: 'Boolean',cellAttributes: {
            iconName: { fieldName: 'PTF_IsOFSIcon' },
            iconPosition: 'left'
        }},*/
        { label: NumeroGruppo, fieldName: 'PTF_NumTotGruppo', type: 'text' },
        { label: "TAG", fieldName: 'PTF_RiportafogliazioneTAG__c', type: 'text' },
        
        // {"type":"action","typeAttributes":{"rowActions":[{"label":"Mostra Dettaglio", "name": "show_details"}]}}
];

export const impreseMDS = ['CORPORATE', /*'Corporate',*/ 'LARGE CORPORATE', 'SMALL BUSINESS', 'Consulenti Finanziari', 'Controparti Istituzionali', 'Enti e Tesorerie'];
export const privateMDS = ['Personal', 'Family', 'Private', 'Key Client Privati', 'POE'];

import getUserInfo from '@salesforce/apex/SV_Utilities.getUserInfo';
import getAllData from '@salesforce/apex/GruppiFinanziariTreeGridPFController.getAllData';
import getRecordInfo from '@salesforce/apex/GruppiFinanziariTreeGridPFController.getRecordInfo';

// import { getRecord } from 'lightning/uiRecordApi';
// import ACCOUNT_RECORDTYPE_FIELD from '@salesforce/schema/nucleo.RecordTypeId';

export default class GruppiFinanziariTreeGridPortafoglio extends NavigationMixin(LightningElement) {
    @track loaded = false;
    @track error;
    @api recordId;
    @api recordInfo;

    @api userInfo;
    @api profiliAutorizzati;
    @api profiloAutorizzatoShow = false;

    @api title;
    @api iconName;
    @api numRows;
    @api recordTypesImprese;
    @api recordTypesPrivati;
    @api recordNGPrivati;

    @api isRendered;
    @api openmodel = false;

    @api getAllData;

    
    // definition of columns for the tree grid
    gridColumns = EXAMPLES_COLUMNS_DEFINITION_BASIC;

    // data provided to the tree grid
    gridData = [];
    gridDataAll = [];
    totNumRows = 0;

    connectedCallback() {
        this.isRendered = false;
        loadStyle(this, cssTreeGrid);

        getUserInfo()
        .then(result => {
            console.log('SV getUserInfo result', result);
            console.log('SV profiliAutorizzati', this.profiliAutorizzati);

            this.userInfo = result;
            if(this.profiliAutorizzati === undefined || this.profiliAutorizzati.includes(result.Profile.Name)){
                this.profiloAutorizzatoShow = true;
            }
            console.log('SV profiloAutorizzatoShow', this.profiloAutorizzatoShow);

            return getRecordInfo({ recordId: this.recordId });
        })
        .then(result => {
            console.log('SV getRecordInfo result', result);

            this.recordInfo = result;

            let dataTableGlobalStyle = document.createElement('style');
            dataTableGlobalStyle.innerHTML = `
            .color-red {
                font-weight: bold;
                color: red;
            }`;
            document.head.appendChild(dataTableGlobalStyle);
            return getAllData({ recordId: this.recordId, recordType: this.recordInfo.RecordType.DeveloperName });
                
        })
        .then(result => {
            console.log('SV getAllData result', result);

            this.getAllData = result;
            
        })
        .catch(error => {
            alert('ERROR');
            this.error = error;
            console.log('ERROR', error);
            this.isRendered = true;
        })
        .finally(() => {
            let allData = this.getAllData;
            let listViewData = [];
            let listViewDataAll = [];

            for(let keyG in allData['gruppiFMap']){
                let numTot = 0;
                allData['gruppiFMap'][keyG]._children = [];
                
                for(let keyA in allData['accMap']){
                    if(allData['accToLinkObj'][keyA]){
                        
                        //allData['accMap'][keyA].CRM_LinkCode = allData['accMap'][keyA].CRM_LinkedNDG__r[0].CRM_LinkCode__c;
                        //allData['accMap'][keyA].PTF_Gruppo__c = allData['accMap'][keyA].CRM_LinkedNDG__r[0].CRM_Account__c;
                        allData['accMap'][keyA].CRM_LinkCode = allData['accToLinkObj'][keyA].CRM_LinkCode__c;
                        allData['accMap'][keyA].PTF_Gruppo__c = allData['accToLinkObj'][keyA].CRM_Account__c;
                        if(allData['accMap'][keyA].hasOwnProperty('PTF_Gruppo__c') && allData['accMap'][keyA].PTF_Gruppo__c === keyG){
                            numTot++;
                            allData['accMap'][keyA].PTF_Filiale = allData['accMap'][keyA].hasOwnProperty('PTF_Filiale__c') ? allData['accMap'][keyA].PTF_Filiale__r.Name : '';
    
                            allData['accMap'][keyA].PTF_Url = '/' + keyA;
                            allData['accMap'][keyA].PTF_MPUrl = allData['accMap'][keyA].hasOwnProperty('PTF_Portafoglio__c') ? '/' + allData['accMap'][keyA].PTF_Portafoglio__c : '';
                            allData['accMap'][keyA].PTF_MPName = allData['accMap'][keyA].hasOwnProperty('PTF_Portafoglio__c') ? allData['accMap'][keyA].PTF_Portafoglio__r.Name : '';
                            allData['accMap'][keyA].PTF_IsOFSIcon = allData['accMap'][keyA].PTF_OFS__c ? 'utility:check' : '';

                            if(allData['accMap'][keyA].PTF_MiniPortafoglio__c){
                                allData['accMap'][keyA].nomeSL=allData['accMap'][keyA].PTF_MiniPortafoglio__r.PTF_SL__r.Name;
                            }
                            // if(allData['accMap'][keyA].PTF_Portafoglio__c != this.recordId){
                                
                            //     allData['accMap'][keyA].typeCSSClass = 'color-red';
                            // }
                            if(allData['accMap'][keyA].PTF_Filiale__c != this.recordInfo.PTF_Filiale__c){
                                        
                                allData['accMap'][keyA].typeCSSClass = 'color-red';
                            }
                            if(Boolean(this.recordNGPrivati) && this.recordNGPrivati.includes(allData['accMap'][keyA].PTF_NaturaGiuridica__c)){
                                allData['accMap'][keyA].typeNGCSSClass = 'color-red';
                            }
                            allData['gruppiFMap'][keyG]._children.push(allData['accMap'][keyA]);
                        }
                    }                
                }

                allData['gruppiFMap'][keyG].PTF_NumTotGruppo = numTot;
                allData['gruppiFMap'][keyG].PTF_Filiale = allData['gruppiFMap'][keyG].hasOwnProperty('PTF_Filiale__c') ? allData['gruppiFMap'][keyG].PTF_Filiale__r.Name : '';

                allData['gruppiFMap'][keyG].PTF_MPUrl = allData['gruppiFMap'][keyG].hasOwnProperty('PTF_Portafoglio__c') ? '/' + allData['gruppiFMap'][keyG].PTF_Portafoglio__c : '';
                allData['gruppiFMap'][keyG].PTF_MPName = allData['gruppiFMap'][keyG].hasOwnProperty('PTF_Portafoglio__c') ? allData['gruppiFMap'][keyG].PTF_Portafoglio__r.Name : '';
                allData['gruppiFMap'][keyG].PTF_IsOFSIcon = allData['gruppiFMap'][keyG].PTF_OFS__c ? 'utility:check' : '';
                if(allData['gruppiFMap'][keyG].PTF_Filiale__c != this.recordInfo.PTF_Filiale__c){
                    allData['gruppiFMap'][keyG].typeCSSClass = 'color-red';
                }
                if(Boolean(this.recordNGPrivati) && this.recordNGPrivati.includes(allData['gruppiFMap'][keyG].PTF_NaturaGiuridica__c)){
                    allData['gruppiFMap'][keyG].typeNGCSSClass = 'color-red';
                }
                allData['gruppiFMap'][keyG].PTF_Url = '/' + keyG;

                allData['gruppiFMap'][keyG]._children = allData['gruppiFMap'][keyG]._children.sort( this.compare );

            };

            let rows = [];
            let rowsAll = [];
            for(let key in allData['gruppiFMap']){
                
                if(rows.length < this.numRows){
                    rows.push(allData['gruppiFMap'][key]);
                }
                rowsAll.push(allData['gruppiFMap'][key]);
            }
            
            this.gridData = rows;
            this.gridDataAll = rowsAll;
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