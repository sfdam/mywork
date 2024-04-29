import { LightningElement, api, track, wire } from 'lwc';

// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
// import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

import getAllData from '@salesforce/apex/ProductListViewController.getAllData';
import getObjColumns from '@salesforce/apex/ProductListViewController.getObjColumns';
import getUserInfo from '@salesforce/apex/SV_Utilities.getUserInfo';
import getRecordInfo from '@salesforce/apex/ProductListViewController.getRecordInfo';

//import { subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
//import prodListViewRefresh from "@salesforce/messageChannel/productListView__c";

export default class ProductListView extends NavigationMixin(LightningElement) {

    @track loaded = false;
    @track error;
    @api recordId;
    @api userInfo;
    @api recordInfo;

    @api title;
    @api iconName;
    @api numRows;
    @api recordTypeProduct;
    @api statusFinServ;
    @api showLabelAttivi = false;
    @api showLabelEstinti = false;
    @api showLabelAttiviEstinti = false;
    // 54985 - VS 24/08/2022
    // @api showDataUltimoAggio = false;
    // 54985 - VS 24/08/2022
    @api button_new;

    @api attivi = 0;
    @api estinti = 0;

    @api isRendered;
    @api notShowComponent;
    @api openmodel = false;

    @api getAllData;
  
    @api columns;
    @api listViewData;

    @api fieldsArray;
    @api viewAllLabel;
    @track subscription = {};

    /*@wire(MessageContext)
    messageContext;*/

    connectedCallback() {
        
        let recordTypeProduct = this.recordTypeProduct;
        let recordId = this.recordId;
        this.isRendered = false;
        this.notShowComponent = false;
    
        //window.addEventListener('beforeunload', this.beforeUnloadHandler.bind(this));
        // loadStyle(this, cssProductListView);
        console.log('SV productListView ', recordTypeProduct);

        getUserInfo()
            .then(result => {
                console.log('SV getUserInfo result', result);
                
                this.userInfo = result;

                return getRecordInfo({ recordId: this.recordId });
            })
            .then(result => {
                console.log('SV getRecordInfo result', result);
                
                this.recordInfo = result;

                return getObjColumns({ objRecordType: recordTypeProduct.split(',') });
            })
            .then(result => {

                console.log('SV getObjColumns result', recordTypeProduct, result);

                let columns = [];
                for(let key in result){
                    console.log('SV key', key);
                    let colArray = [];
                    colArray = JSON.parse(result[key].OBJ_JSON_COLUMNS__c);
                    console.log('SV colArray', colArray);

                    colArray.forEach(element => {
                        if(!this.containsObject(element, columns)){
                            if(!element.hasOwnProperty('userProfileIdToShow') && !element.hasOwnProperty('accountRecordTypeIdToShow')){
                                columns.push(element);
                            } else {
                                console.log('QUA');
                                let toAdd = true;
                                if(element.hasOwnProperty('userProfileIdToShow') && !element.userProfileIdToShow.includes(this.userInfo.ProfileId)){
                                    toAdd = false;
                                    // columns.push(element);
                                }

                                if(element.hasOwnProperty('accountRecordTypeIdToShow') && !element.accountRecordTypeIdToShow.includes(this.recordInfo.RecordTypeId)){
                                    toAdd = false;
                                    // columns.push(element);
                                }

                                if(toAdd){

                                    columns.push(element);
                                }
                            }
                        }
                    });

                };

                let col = this.columns = this.setFixedWidth(columns);
                let fieldsArray = [];
                let fieldsObj = {};

                col.forEach(element => {
                    let x = {};
                    x.field = element.fieldName;
                    x.type = element.type;
                    if(element.type === 'lookup' || element.type === 'url'){
                        x.c_object = element.object;
                        x.objectFields = element.objectField;
                    }
                    fieldsArray.push(x);
                });
                console.log('fieldsArray', fieldsArray);

                this.fieldsArray = fieldsArray;
                fieldsObj.elements = fieldsArray;

                // console.log('SV getAllData result', result);

                // this.getAllData = result;
                // this.getAllData = this.exampleData;
               

                return getAllData({ objRecordType: recordTypeProduct.split(','), statusFinServ: this.statusFinServ, recordId: recordId, fields: JSON.stringify(fieldsObj), userProfile:this.userInfo.Profile.Name })

                
            })
            .then(result => {
                console.log('SV getAllData result', recordTypeProduct, result);

                this.getAllData = result;
                // console.log('SV getObjColumns result', result);

                // this.columns = JSON.parse(result[recordTypeProduct].OBJ_JSON_COLUMNS__c);
                // this.columns = this.exampleColumns;
                
            })
            .catch(error => {
                //alert('ERROR');
                this.error = error;
                console.log('SV ERROR', error);
                this.isRendered = true;
            })
            .finally(() => {
                console.log('SV FINALLY');
                
                let columns = this.columns;
                let allData = this.getAllData;
                let numRows = this.numRows;
                let fieldsArray = this.fieldsArray;
                let attivi = 0;
                let estinti = 0;
                let nonVerificato = 0;

                let statusFinServ = this.statusFinServ;

                // 54985 - VS 24/08/2022
                // let dataUltimoAgg ='';
                // let checkData=0;
                // 54985 - VS 24/08/2022

                let rows = [];
                let rowsAll = [];
                for (let k in allData['financialAccMap']) {
                    console.log(allData['financialAccMap'][k].CreatedById);
                    for (let j in allData['financialRoleMap']) {
                        if(allData['financialRoleMap'][j].FinServ__FinancialAccount__c === allData['financialAccMap'][k].Id){
                            allData['financialAccMap'][k].FinServ__Role__c = allData['financialRoleMap'][j].FinServ__Role__c === 'Primary Owner' ? 'Intestatario Principale' : allData['financialRoleMap'][j].FinServ__Role__c === 'Joint Owner' ? 'Cointestazione' : allData['financialRoleMap'][j].FinServ__Role__c;
                        }
                    }

                    columns.forEach(element => {
                        if(element.type === 'url'){
                            console.log('1XXXXXXX');

                            if(element.object != 'FinServ__FinancialAccount__c'){
                                console.log('1YYYYYYYY');

                                let othersObj = allData['OtherObjMap'][element.object];
                                let val = {};
                                console.log('1', othersObj);
                                othersObj.forEach(obj => {
                                    if(obj.Id === allData['financialAccMap'][k][element.fieldName]) val = obj;
                                });
                                console.log('2', val);

                                allData['financialAccMap'][k][element.typeAttributes.label.fieldName] = val;
                            } else {

                            }
                        }
                    });
                    
                    if(allData['financialAccMap'][k].FinServ__Status__c === 'Closed' || allData['financialAccMap'][k].FinServ__Status__c === 'ESTINTO'){
                        estinti++;
                        // allData['financialAccMap'][k].dynamicIcon = 'action:close';
                        allData['financialAccMap'][k].FinServ__Status__c = 'E';
                    } else if(allData['financialAccMap'][k].FinServ__Status__c === 'Active' || allData['financialAccMap'][k].FinServ__Status__c === 'ATTIVO'){
                        attivi++;
                        // allData['financialAccMap'][k].dynamicIcon = 'action:check';
                        allData['financialAccMap'][k].FinServ__Status__c = 'A';
                    } else {
                        nonVerificato++;
                    }

                    if(allData['financialAccMap'][k].CRM_FormulaHolderType__c === 'Mono-intestazione'){
                        allData['financialAccMap'][k].typeCSSClass = 'mono';
                        allData['financialAccMap'][k].CRM_FormulaHolderType__c = '/resource/ndgintestatario';
                    } else if(allData['financialAccMap'][k].CRM_FormulaHolderType__c === 'Co-intestazione'){
                        allData['financialAccMap'][k].typeCSSClass = 'co-intestato';
                        allData['financialAccMap'][k].CRM_FormulaHolderType__c = '/resource/ndgcointestatario';
                    }

                    rowsAll.push( allData['financialAccMap'][k]);

                }

                let listRows = [];
                let listRowsAll = [];
                let count = 0;
                rowsAll.forEach(element => {
                    console.log(element);
                    let objRows = {};
                    objRows.columns = [];
                    objRows.Id = element.Id;
                    for (let k in columns) {
                        let objColumn = {};
                        if(columns[k].type === 'url' || columns[k].type === 'lookup'){
                            objColumn.objectApiName = columns[k].object;
                            if(columns[k].object != 'FinServ__FinancialAccount__c'){
                                objColumn.elementId = element[columns[k].fieldName];
                                objColumn.value = element[columns[k].typeAttributes.label.fieldName][columns[k].objectField[0]];
                            } else {
                                objColumn.elementId = element.Id;
                                objColumn.value = element[columns[k].fieldName];
                            }
                            if(columns[k].type === 'url') objColumn.href = '/' + element[columns[k].fieldName];

                        } else {
                            objColumn.elementId = element.Id;
                            objColumn.value = columns[k].type == 'percent' ? element[columns[k].fieldName] / 100 : element[columns[k].fieldName];
                        }
                        
                        objColumn.fieldName = columns[k].fieldName;
                        objColumn.isText   = columns[k].type == 'text' ? true : false;
                        objColumn.isBoolean   = columns[k].type == 'boolean' ? true : false;
                        objColumn.isData   = columns[k].type == 'data' ? true : false;
                        objColumn.isPercent   = columns[k].type == 'percent' ? true : false;
                        objColumn.isCurrency   = columns[k].type == 'currency' ? true : false;
                        objColumn.isLookup = columns[k].type == 'lookup' ? true : false;
                        objColumn.isImage   = columns[k].type == 'image' ? true : false;
                        objColumn.isAction   = columns[k].type == 'action' ? true : false;
                        objColumn.isUrl   = columns[k].type == 'url' ? true : false;
                        objColumn.fixedWidth = columns[k].fixedWidth;
                        objRows.columns.push(objColumn);
                    }

                    listRowsAll.push(objRows);
                    if(count < numRows){
                        count ++;
                        listRows.push(objRows);
                    }

                });

                console.log('SV listRows', recordTypeProduct, listRows);

                this.listViewData = listRows; 
                this.listViewDataAll = listRowsAll; 

                if(attivi > 0) this.attivi = attivi;
                if(estinti > 0) this.estinti = estinti;

                if(statusFinServ == 'ATTIVO'){
                    this.showLabelAttivi = true;
                } else if(statusFinServ == 'ESTINTO') {
                    this.showLabelEstinti = true;
                } else {
                    this.showLabelAttivi = true;
                    this.showLabelEstinti = true;
                    this.showLabelAttiviEstinti = true;
                }

                if(attivi === 0 && estinti === 0 && nonVerificato === 0) this.notShowComponent = true;
                this.isRendered = true;
                /*if(Object.keys(this.subscription).length === 0 && this.subscription.constructor === Object){
                    // this.handleSubscribe();
                    this.subscribeToMessageChannel();
                }*/

                // 54985 - VS 24/08/2022
                // allData['financialAccMap'].foreach((x)=> )
                // for (let x in allData['financialAccMap']) {

                //     if(Date.parse(allData['financialAccMap'][x].NDW_X_Update_TS__c)>checkData){
                //         checkData= Date.parse(allData['financialAccMap'][x].NDW_X_Update_TS__c);
                //         var strTemp =allData['financialAccMap'][x].NDW_X_Update_TS__c.replace('T','-').split('-');
                //         // console.log('@VS checkData: '+checkData);
                //         this.dataUltimoAgg = strTemp[2]+'/'+strTemp[1]+'/'+strTemp[0];
                //         // console.log('@VS dataUltimoAgg: '+dataUltimoAgg);
                //         this.showDataUltimoAggio=true;
                //     }
                // }

                // 54985 - VS 24/08/2022
            }); 

    }

    get notEmptyList(){
        return this.listViewData.length > 0;
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

  

    setFixedWidth(jscols) {
        console.log('SV jscols', jscols);
        for (var i=0; i<jscols.length;i++) {
            if (jscols[i].fixedWidth==undefined) {
                jscols[i].fixedWidth='width:10rem;';
            }
            else {
                jscols[i].fixedWidth='width:'+jscols[i].fixedWidth+';';
            }
        }
        return jscols;
    }

    containsObject(obj, list) {
        var i;
        for (i = 0; i < list.length; i++) {
            if (list[i].fieldName === obj.fieldName) {
                return true;
            }
        }
    
        return false;
    }

}