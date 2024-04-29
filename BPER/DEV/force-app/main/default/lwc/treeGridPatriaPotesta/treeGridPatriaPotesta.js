import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';

import { NavigationMixin } from 'lightning/navigation';

import cssTreeGrid from '@salesforce/resourceUrl/reassignAccountToWallet';

import NDG from '@salesforce/label/c.treeGridPatriaPotesta_CLM_NDG';
import Nominativo from '@salesforce/label/c.treeGridPatriaPotesta_CLM_Nominativo';
import Filiale from '@salesforce/label/c.treeGridPatriaPotesta_CLM_Filiale';
import NaturaGiuridica from '@salesforce/label/c.treeGridPatriaPotesta_CLM_NaturaGiuridica';
import Tipo from '@salesforce/label/c.treeGridPatriaPotesta_CLM_Tipo';
import Descrizione from '@salesforce/label/c.treeGridPatriaPotesta_CLM_Descrizione';


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
        fieldName: 'PTF_Filiale_Name',
        label: Filiale,
    },
    {
        type: 'text',
        fieldName: 'PTF_NaturaGiuridica__c',
        label: NaturaGiuridica
    },
    {
        type: 'text',
        fieldName: 'CRM_LinkCode__c',
        label: Tipo,
    },
    {
        type: 'text',
        fieldName: 'CRM_LinkType__c',
        label: Descrizione,
    },
    // {"type":"action","typeAttributes":{"rowActions":[{"label":"Mostra Dettaglio", "name": "show_details"}]}}
];

import getAllData from '@salesforce/apex/treeGridPatriaPotestaController.getAllData';
import getRecordInfo from '@salesforce/apex/treeGridPatriaPotestaController.getRecordInfo';
export default class TreeGridPatriaPotesta extends NavigationMixin(LightningElement) {
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
    gridData = [];
    gridDataAll = [];

    connectedCallback() {
        this.isRendered = false;
        loadStyle(this, cssTreeGrid);
        getRecordInfo({ recordId: this.recordId }).then(result=>{
            console.log('EDB getRecordInfo result', result);
            this.account = result;
            this.showComponent = this.recordTypes.includes(this.account.RecordType.DeveloperName);
            return getAllData({ recordId: this.recordId, recordType: this.account.RecordType.DeveloperName });
        }).then(result=>{
            // getAllData result
            console.log('EDB getAllData result', result);
            this.getAllData = result;
            let mFigli = this.getAllData;
            let currentKey = undefined;
            let currentObj = undefined;
            for (var key in mFigli) {
                let cKey = key.split('_');
                if (currentKey!=cKey[0]) {
                    currentKey = cKey[0];
                    if (currentObj!=undefined) {
                        this.gridDataAll.push(this.cloneJSON(currentObj));
                        currentObj = undefined;
                    }
                    currentObj = this.flattenQueryResult(this.cloneJSON(mFigli[key]))[0];
                    currentObj._children = [];
                    if (currentObj.CRM_Account__r.Id==this.recordId) {
                        currentObj.typeCSSClass = 'treeGrid-green';
                    }
                    currentObj.PTF_Url_NDG = "/"+currentObj.CRM_Account__r.Id;
                    currentObj.CRM_NDG__c = currentObj.CRM_Account__r.CRM_NDG__c;
                    currentObj.Name = currentObj.CRM_Account__r.Name;
                    currentObj.Filiale__c = currentObj.CRM_Account__r.Filiale__c;
                    if (currentObj.CRM_Account__r.PTF_Filiale__c!=undefined) {
                        currentObj.PTF_Filiale_Name = currentObj.CRM_Account__r.PTF_Filiale__r.Name;
                    }
                    currentObj.PTF_NaturaGiuridica__c = currentObj.CRM_Account__r.PTF_NaturaGiuridica__c;
                    currentObj.CRM_LinkCode__c = undefined;
                    currentObj.CRM_LinkType__c = undefined;
                    debugger;
                }
                if (currentObj!=undefined) {
                    let flatObj = this.flattenQueryResult(this.cloneJSON(mFigli[key]))[0];
                    if (flatObj.CRM_RelatedAccount__r.Id==this.recordId) {
                        flatObj.typeCSSClass = 'treeGrid-green';
                    }
                    flatObj.PTF_Url_NDG = "/"+flatObj.CRM_RelatedAccount__r.Id;
                    flatObj.CRM_NDG__c = flatObj.CRM_RelatedAccount__r.CRM_NDG__c;
                    flatObj.Name = flatObj.CRM_RelatedAccount__r.Name;
                    flatObj.Filiale__c = flatObj.CRM_RelatedAccount__r.Filiale__c;
                    if (flatObj.CRM_RelatedAccount__r.PTF_Filiale__c!=undefined) {
                        flatObj.PTF_Filiale_Name = flatObj.CRM_RelatedAccount__r.PTF_Filiale__r.Name;
                    }
                    flatObj.PTF_NaturaGiuridica__c = flatObj.CRM_RelatedAccount__r.PTF_NaturaGiuridica__c;
                    currentObj._children.push(this.cloneJSON(flatObj));
                }
            }
            if (currentObj!=undefined) {
                this.gridDataAll.push(this.cloneJSON(currentObj));
            }
            for (var i=0; i<this.gridDataAll.length; i++) {
                if (i<this.numRows) {
                    let obj = this.cloneJSON(this.gridDataAll[i]);
                    if (obj._children.length>this.numRows) {
                        do {
                            obj._children.pop();
                        }while(obj._children.length>this.numRows)
                    }
                    this.gridData.push(obj);
                }
                else {
                    break;
                }
            }
        }).catch(error=>{
            this.error = error;
            console.log('EDB ERROR', error);
            this.gridData = [];
            this.gridDataAll = [];
        }).finally(()=>{
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

    flattenObject(propName, obj) {
        var flatObject = [];
        
        for(var prop in obj) {
            //if this property is an object, we need to flatten again
            var propIsNumber = isNaN(propName);
            var preAppend = propIsNumber ? propName+'.' : '';
            if(typeof obj[prop] == 'object') {
                flatObject[preAppend+prop] = Object.assign(flatObject, this.flattenObject(preAppend+prop,obj[prop]));
            }    
            else {
                flatObject[preAppend+prop] = obj[prop];
            }
        }
        return flatObject;
    } 

    flattenQueryResult(listOfObjects) {
        if(!Array.isArray(listOfObjects)) {
            var listOfObjects = [listOfObjects];
        }
        
        console.log('List of Objects is now....');
        console.log(listOfObjects);
        for(var i = 0; i < listOfObjects.length; i++) {
            var obj = listOfObjects[i];
            for(var prop in obj) {      
                if (!obj.hasOwnProperty(prop)) continue;
                if (typeof obj[prop] == 'object' && typeof obj[prop] != 'Array') {
                    obj = Object.assign(obj, this.flattenObject(prop,obj[prop]));
                }
                else if(typeof obj[prop] == 'Array') {
                    for(var j = 0; j < obj[prop].length; j++) {
                        obj[prop+'.'+j] = Object.assign(obj,this.flattenObject(prop,obj[prop]));
                    }
                }
            }
        }
        return listOfObjects;
    }

    cloneJSON(obj) {
        return JSON.parse(JSON.stringify(obj));
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