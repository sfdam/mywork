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

import NDG from '@salesforce/label/c.treeGridNuclei_CLM_NDG';
import NaturaGiuridica from '@salesforce/label/c.treeGridNuclei_CLM_NaturaGiuridica';
import Nominativo from '@salesforce/label/c.treeGridNuclei_CLM_Nominativo';
import OFS from '@salesforce/label/c.treeGridNuclei_CLM_OFS';
import GruppoGestionale from '@salesforce/label/c.treeGridNuclei_CLM_GruppoGestionale';
import NumeroMembri from '@salesforce/label/c.treeGridNuclei_CLM_NumeroMembri';
import Caponucleo from '@salesforce/label/c.treeGridNuclei_CLM_Caponucleo';


/**
 * Default settings values
 */
export const KEYFIELD = 'Id';

/**
 * Columns definition
 * :: used in examples
 */
export const EXAMPLES_COLUMNS_DEFINITION_BASIC = [
        // { label: 'Nucleo', fieldName: 'PTF_UrlNucleo', type: 'url', typeAttributes: {label: { fieldName: 'NucleoName' }} },
        { label: NDG, fieldName: 'PTF_Url', type: 'url', typeAttributes: {label: { fieldName: 'CRM_NDG__c' }} },
        { label: Nominativo, fieldName: 'Name', type: 'text', cellAttributes:{class:{fieldName: 'typeCSSClass' }} },
        { label: NaturaGiuridica, fieldName: 'PTF_NaturaGiuridica__c', type: 'text' },
        // { label: 'OFS', fieldName: 'PTF_OFS__c', type: 'text' },
        { label: OFS, fieldName: '', type: 'Boolean',cellAttributes: {
            iconName: { fieldName: 'PTF_IsOFSIcon' },
            iconPosition: 'left'
        }},
        { label: "Sportello leggero", fieldName: 'nomeSL', type: 'text', 
            typeAttributes: {
                label: { fieldName: 'PTF_MiniPortafoglio__r' }
            },
        },
        { label: GruppoGestionale, fieldName: 'PTF_GruppoComportamentale__c', type: 'text' },
        { label: NumeroMembri, fieldName: 'PTF_NumTotGruppo', type: 'text' },
        { label: Caponucleo, fieldName: '', type: 'Boolean', hideDefaultActions: "true", cellAttributes: {
            iconName: { fieldName: 'PTF_IsCaponucleoIcon' },
            iconPosition: 'left'
        }},
        { label: "TAG", fieldName: 'PTF_RiportafogliazioneTAG__c', type: 'text' },
        { label: "TAG BCP", fieldName: 'PTF_TAGBCP__c', type: 'text' },
        // {"type":"action","typeAttributes":{"rowActions":[{"label":"Mostra Dettaglio", "name": "show_details"}]}}
];

import getAllData from '@salesforce/apex/TreeGridNucleiController.getAllData';

// import { getRecord } from 'lightning/uiRecordApi';
// import ACCOUNT_RECORDTYPE_FIELD from '@salesforce/schema/nucleo.RecordTypeId';
export default class TreeGridNuclei extends NavigationMixin(LightningElement) {
    @track loaded = false;
    @track error;
    @track ndgAttivi=0;
    @track PTFDicuiTeste=0;
    @track PTFDicuiTesteAttive=0;
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

    // definition of columns for the tree grid
    gridColumns = EXAMPLES_COLUMNS_DEFINITION_BASIC;

    // data provided to the tree grid
    gridData = [];
    gridDataAll = [];
    totNumRows = 0;
    totNumAccounts = 0;

    // @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_RECORDTYPE_FIELD] })
    // getAccount({ error, data }){
    //     if(data){
    //         alert('wire');

    //         var result = JSON.parse(JSON.stringify(data));
    //         console.log('acc data: ', result);
    //         this.nucleo = result;
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

        getAllData({ recordId: this.recordId })
        .then(result => {
            console.log('DK getAllData result', result);

            let dataTableGlobalStyle = document.createElement('style');
            dataTableGlobalStyle.innerHTML = `
            .scossi-red {
                font-weight: bold;
                color: red;
            }
            .slds-text-heading_small.slds-truncate{
                width: 100%;
            }
                                        `;

            document.head.appendChild(dataTableGlobalStyle);

            let allData = result;
            
            let rows = [];
            let rowsAll = [];
            let nucleiMap = {}
            let NDGscossi = {}
            

            for(let key in allData['accInNucleiMap']){
                
                if(allData['accInNucleiMap'][key].PTF_Caponucleo__c){   
                    if(allData['accInNucleiMap'][key].PTF_MiniPortafoglio__c){
                       allData['accInNucleiMap'][key].nomeSL=allData['accInNucleiMap'][key].PTF_MiniPortafoglio__r.PTF_SL__r.Name;
                    }
                    allData['accInNucleiMap'][key]._children = [];
                    allData['accInNucleiMap'][key].PTF_Url = '/' + key;
                    allData['accInNucleiMap'][key].NucleoName = allData['nucleiMap'][allData['accInNucleiMap'][key].PTF_Nucleo__c].Name;
                    allData['accInNucleiMap'][key].PTF_UrlNucleo = '/' + allData['accInNucleiMap'][key].PTF_Nucleo__c;
                    allData['accInNucleiMap'][key].PTF_IsOFSIcon = allData['accInNucleiMap'][key].PTF_OFS__c ? 'utility:ban' : '';
                    allData['accInNucleiMap'][key].PTF_IsCaponucleoIcon = allData['accInNucleiMap'][key].PTF_Caponucleo__c ? 'utility:check' : '';
                    
                    
                    nucleiMap[allData['accInNucleiMap'][key].PTF_Nucleo__c] = allData['accInNucleiMap'][key];
                    
                }
                if(allData['accInNucleiMap'][key].PTF_StatoCRM__c=='ATT'){
                    this.ndgAttivi++;
                }
                if(allData['accInNucleiMap'][key].PTF_Di_cui_Teste_Attive__c==1){
                        this.PTFDicuiTesteAttive++;
                }
                if(allData['accInNucleiMap'][key].PTF_Di_cui_Teste__c==1){
                        this.PTFDicuiTeste++;
                } 
            }
             

            
            if(Boolean(nucleiMap)){

                for(let key in allData['accInNucleiMap']){
                    
                    if(!allData['accInNucleiMap'][key].PTF_Caponucleo__c){
                        if(allData['accInNucleiMap'][key].PTF_MiniPortafoglio__c){
                            allData['accInNucleiMap'][key].nomeSL=allData['accInNucleiMap'][key].PTF_MiniPortafoglio__r.PTF_SL__r.Name;
                         }
                        allData['accInNucleiMap'][key].PTF_Url = '/' + key;
                        allData['accInNucleiMap'][key].NucleoName = allData['nucleiMap'][allData['accInNucleiMap'][key].PTF_Nucleo__c].Name;
                        allData['accInNucleiMap'][key].PTF_UrlNucleo = '/' + allData['accInNucleiMap'][key].PTF_Nucleo__c;
                        allData['accInNucleiMap'][key].PTF_IsOFSIcon = allData['accInNucleiMap'][key].PTF_OFS__c ? 'utility:ban' : '';
                        allData['accInNucleiMap'][key].PTF_IsCaponucleoIcon = allData['accInNucleiMap'][key].PTF_Caponucleo__c ? 'utility:check' : '';

                        
                        if(Boolean(nucleiMap[allData['accInNucleiMap'][key].PTF_Nucleo__c])){
                            if(allData['accInNucleiMap'][key].PTF_OFS__c && nucleiMap[allData['accInNucleiMap'][key].PTF_Nucleo__c].PTF_IsOFSIcon == ''){
                                nucleiMap[allData['accInNucleiMap'][key].PTF_Nucleo__c].PTF_IsOFSIcon = 'utility:warning';
                            }
                            nucleiMap[allData['accInNucleiMap'][key].PTF_Nucleo__c]._children.push(allData['accInNucleiMap'][key]);
                        }else{
                            allData['accInNucleiMap'][key]._children = [];
                            if(allData['accInNucleiMap'][key].Name)
                            (allData['accInNucleiMap'][key]).typeCSSClass = 'scossi-red';
                            NDGscossi[allData['accInNucleiMap'][key].PTF_Nucleo__c] = allData['accInNucleiMap'][key];
                            allData['accInNucleiMap'][key]._children = [];
                            nucleiMap = {...nucleiMap,...NDGscossi};
                        }

                    }
                }
            }
            for(let key in nucleiMap){
                
                nucleiMap[key].PTF_NumTotGruppo = nucleiMap[key]._children.length + 1;
                if(rows.length < this.numRows){
                    rows.push(nucleiMap[key]);
                }
                rowsAll.push(nucleiMap[key]);
            }
            
            this.gridData = rows;
            this.gridDataAll = rowsAll;
            this.setPages(this.gridDataAll);
            this.totNumRows = rowsAll.length;
            this.totNumAccounts = Object.keys(allData['accInNucleiMap']).length;

            this.isRendered = true;
            this.showComponent = true;
        })
        .catch(error => {
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