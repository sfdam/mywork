/* eslint-disable vars-on-top */
/* eslint-disable no-loop-func */
/* eslint-disable no-useless-constructor */
/* eslint-disable no-alert */
/* eslint-disable guard-for-in */
/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api, track, wire } from 'lwc';

// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

import { publish,MessageContext, subscribe, unsubscribe, APPLICATION_SCOPE } from 'lightning/messageService';
import lmsDemoMC from "@salesforce/messageChannel/knowledge__c";

import getUserInfo from '@salesforce/apex/KnowledgeController.getUserInfo';
import getActiveRecordType from '@salesforce/apex/KnowledgeController.getActiveRecordType';
import getAllDataFromText from '@salesforce/apex/KnowledgeController.getAllDataFromText';
import getAllDataForCase from '@salesforce/apex/KnowledgeController.getAllDataForCase';
import getAllDataFromTextHCI from '@salesforce/apex/KnowledgeController.getAllDataFromTextHCI';
import getAllDataFromTextHCE from '@salesforce/apex/KnowledgeController.getAllDataFromTextHCE';


import getOpenAreaChild from '@salesforce/apex/KnowledgeController.getOpenAreaChild';
import getOpenScopeChild from '@salesforce/apex/KnowledgeController.getOpenScopeChild';
import getOpenLevel1Child from '@salesforce/apex/KnowledgeController.getOpenLevel1Child';
import getOpenLevel2Child from '@salesforce/apex/KnowledgeController.getOpenLevel2Child';
import getOpenLevel3Child from '@salesforce/apex/KnowledgeController.getOpenLevel3Child';

import Nessun_Risultato from '@salesforce/label/c.knowledge_searchBar_comm_EmptySearch';


export default class Knowledge_searchBar extends NavigationMixin(LightningElement) {

    label = {Nessun_Risultato};
    
    @track loaded = false;
    @track error;
    @track userInfo;
    @api recordId;

    @api tipoArticolo;
    @track recordTypeList;
    @api value = 'Tutti';

    @api title;
    @api iconName;
    @api numRows;
    @api usedOn;

    queryTerm;
    getAllResult = [];
    getForNumRowsResult = [];

    getAllResultToShow = [];
    getForNumRowsResultToShow = [];

    @api isRendered;
    @api openmodel = false;

    channel;
    @wire(MessageContext)
    context;

    @api isRenderedBreadcrumbs = false;
    @track
    myBreadcrumbs = [];

    @api emptySearch = false;

    constructor() {
        super();
    }

    subscribeToMessageChannel() {
        this.channel = subscribe(
            this.context, 
            lmsDemoMC, 
            (message) => this.handleMessage(message),
            { scope: APPLICATION_SCOPE }
        );
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.channel);
        this.channel = null;
    }

    // Handler for message received by component
    handleMessage(messageResult) {
        if (messageResult != null) {
            let message = messageResult.messageBody;
            let source = messageResult.source;

            let arrayAll = [];
            let arrayForNumRows = [];
            let count = 0;
            let resultArray = [];
            resultArray.push(messageResult.messageBody.result);

            if(messageResult.messageBody.method === 'getOpenAreaChild'){
                // messageResult.messageBody.result.forEach(element => {
                //     if(messageResult.messageBody.source.includes(element.Name)){
                //         arrayAll = arrayAll.concat(element.scopeChild);
                //     }
                // });

                getOpenAreaChild({ picklistValue: resultArray })
                .then(result => {
                    console.log('search getOpenAreaChild: ', result);
                    for (let k in result) {
                        let obj = {};
                        obj.Id = result[k].Id;
                        obj.Title = result[k].Title;
                        obj.Url = '/lightning/r/Knowledge__kav/' + result[k].Id + '/view';
                        obj.ArticleNumber =  result[k].ArticleNumber;
                        obj.RecordType =  result[k].RecordType.Name;
                        obj.RecordTypeId =  result[k].RecordType.Id;
                        obj.CRM_Area__c = result[k].CRM_Area__c;
                        obj.CRM_Scope__c = result[k].CRM_Scope__c;
                        obj.CRM_Level1__c = result[k].CRM_Level1__c;
                        obj.CRM_Level2__c = result[k].CRM_Level2__c;
                        obj.CRM_Level3__c = result[k].CRM_Level3__c;
                        obj.CRM_Answer__c = result[k].CRM_Answer__c;
                        obj.CRM_Question__c = result[k].CRM_Question__c;
                        obj.CRM_Description__c = result[k].CRM_Description__c;
                        arrayAll.push(obj);
                        if(count < this.numRows) {
                            arrayForNumRows.push(obj);
                            count++;
                        }
                    }

                    console.log(arrayAll);
                    
                    this.getAllResult = arrayAll;
                    this.getForNumRowsResult = arrayForNumRows;   

                    this.setElementToShow();
                    
                    this.myBreadcrumbs = [];

                    let objBreadCrumbsArea = {};
                    // { label: 'Account', name: 'parent', id: 'account1' },
                    objBreadCrumbsArea.label = arrayAll[0].CRM_Area__c;
                    objBreadCrumbsArea.name = arrayAll[0].Title;
                    objBreadCrumbsArea.id = arrayAll[0].CRM_Area__c;
                    
                    this.myBreadcrumbs.push(objBreadCrumbsArea);
        
                })
                .catch(error => {
                    this.error = error;
                    console.log('ERROR', error);
                })
                .finally(() => {
                    this.isRendered = true;
                    this.isRenderedBreadcrumbs = true;

                });

            } else if(messageResult.messageBody.method === 'getOpenScopeChild'){
                // messageResult.messageBody.result.forEach(elementArea => {
                //     elementArea.scopeChild.forEach(elementScope => {
                //         if(messageResult.messageBody.source.includes(elementScope.CRM_Scope__c)){
                //             arrayAll = arrayAll.concat(elementScope.level1Child);
                //         }
                //     });
                // });
                getOpenScopeChild({ picklistValue: resultArray })
                .then(result => {
                    for (let k in result) {
                        let obj = {};
                        obj.Id = result[k].Id;
                        obj.Title = result[k].Title;
                        obj.Url = '/lightning/r/Knowledge__kav/' + result[k].Id + '/view';
                        obj.ArticleNumber =  result[k].ArticleNumber;
                        obj.RecordType =  result[k].RecordType.Name;
                        obj.RecordTypeId =  result[k].RecordType.Id;
                        obj.CRM_Area__c = result[k].CRM_Area__c;
                        obj.CRM_Scope__c = result[k].CRM_Scope__c;
                        obj.CRM_Level1__c = result[k].CRM_Level1__c;
                        obj.CRM_Level2__c = result[k].CRM_Level2__c;
                        obj.CRM_Level3__c = result[k].CRM_Level3__c;
                        obj.CRM_Answer__c = result[k].CRM_Answer__c;
                        obj.CRM_Question__c = result[k].CRM_Question__c;
                        obj.CRM_Description__c = result[k].CRM_Description__c;
                        arrayAll.push(obj);
                        if(count < this.numRows) {
                            arrayForNumRows.push(obj);
                            count++;
                        }
                    }
                    
                    this.getAllResult = arrayAll;
                    this.getForNumRowsResult = arrayForNumRows;   

                    this.setElementToShow();
                    
                    this.myBreadcrumbs = [];
                    
                    let objBreadCrumbsArea = {};
                    // { label: 'Account', name: 'parent', id: 'account1' },
                    objBreadCrumbsArea.label = arrayAll[0].CRM_Area__c;
                    objBreadCrumbsArea.name = arrayAll[0].Title;
                    objBreadCrumbsArea.id = arrayAll[0].CRM_Area__c;
                    
                    this.myBreadcrumbs.push(objBreadCrumbsArea);

                    let objBreadCrumbsScope = {};
                    // { label: 'Account', name: 'parent', id: 'account1' },
                    objBreadCrumbsScope.label = arrayAll[0].CRM_Scope__c;
                    objBreadCrumbsScope.name = arrayAll[0].Title;
                    objBreadCrumbsScope.id = arrayAll[0].CRM_Scope__c;

                    this.myBreadcrumbs.push(objBreadCrumbsScope);

        
                })
                .catch(error => {
                    this.error = error;
                    console.log('ERROR', error);
                })
                .finally(() => {
                    this.isRendered = true;
                    this.isRenderedBreadcrumbs = true;

                });

            } else if(messageResult.messageBody.method === 'getOpenLevel1Child'){
                // messageResult.messageBody.result.forEach(elementArea => {
                //     elementArea.scopeChild.forEach(elementScope => {
                //         elementScope.level1Child.forEach(elementLevel1 => {
                //             if(messageResult.messageBody.source.includes(elementLevel1.CRM_Level1__c)){
                //                 arrayAll = arrayAll.concat(elementLevel1.level2Child);
                //             }
                //         });
                //     });
                // });

                getOpenLevel1Child({ picklistValue: resultArray })
                .then(result => {
                    for (let k in result) {
                        let obj = {};
                        obj.Id = result[k].Id;
                        obj.Title = result[k].Title;
                        obj.Url = '/lightning/r/Knowledge__kav/' + result[k].Id + '/view';
                        obj.ArticleNumber =  result[k].ArticleNumber;
                        obj.RecordType =  result[k].RecordType.Name;
                        obj.RecordTypeId =  result[k].RecordType.Id;
                        obj.CRM_Area__c = result[k].CRM_Area__c;
                        obj.CRM_Scope__c = result[k].CRM_Scope__c;
                        obj.CRM_Level1__c = result[k].CRM_Level1__c;
                        obj.CRM_Level2__c = result[k].CRM_Level2__c;
                        obj.CRM_Level3__c = result[k].CRM_Level3__c;
                        obj.CRM_Answer__c = result[k].CRM_Answer__c;
                        obj.CRM_Question__c = result[k].CRM_Question__c;
                        obj.CRM_Description__c = result[k].CRM_Description__c;
                        arrayAll.push(obj);
                        if(count < this.numRows) {
                            arrayForNumRows.push(obj);
                            count++;
                        }
                    }

                    console.log(arrayAll);
                    
                    this.getAllResult = arrayAll;
                    this.getForNumRowsResult = arrayForNumRows; 
                    
                    this.setElementToShow();

                    this.myBreadcrumbs = [];
                    
                    let objBreadCrumbsArea = {};
                    // { label: 'Account', name: 'parent', id: 'account1' },
                    objBreadCrumbsArea.label = arrayAll[0].CRM_Area__c;
                    objBreadCrumbsArea.name = arrayAll[0].Title;
                    objBreadCrumbsArea.id = arrayAll[0].CRM_Area__c;
                    
                    this.myBreadcrumbs.push(objBreadCrumbsArea);

                    let objBreadCrumbsScope = {};
                    // { label: 'Account', name: 'parent', id: 'account1' },
                    objBreadCrumbsScope.label = arrayAll[0].CRM_Scope__c;
                    objBreadCrumbsScope.name = arrayAll[0].Title;
                    objBreadCrumbsScope.id = arrayAll[0].CRM_Scope__c;

                    this.myBreadcrumbs.push(objBreadCrumbsScope);

                    let objBreadCrumbsLevel1 = {};
                    // { label: 'Account', name: 'parent', id: 'account1' },
                    objBreadCrumbsLevel1.label = arrayAll[0].CRM_Level1__c;
                    objBreadCrumbsLevel1.name = arrayAll[0].Title;
                    objBreadCrumbsLevel1.id = arrayAll[0].CRM_Level1__c;

                    this.myBreadcrumbs.push(objBreadCrumbsLevel1);
        
                })
                .catch(error => {
                    this.error = error;
                    console.log('ERROR', error);
                })
                .finally(() => {
                    this.isRendered = true;
                    this.isRenderedBreadcrumbs = true;

                });

            } else if(messageResult.messageBody.method === 'getOpenLevel2Child'){
                // messageResult.messageBody.result.forEach(elementArea => {
                //     elementArea.scopeChild.forEach(elementScope => {
                //         elementScope.level1Child.forEach(elementLevel1 => {
                //             elementLevel1.level1Child.forEach(elementLevel2 => {
                //                 if(messageResult.messageBody.source.includes(elementLevel2.CRM_Level2__c)){
                //                     arrayAll = arrayAll.concat(elementLevel2.level3Child);
                //                 }
                //             });
                //         });
                //     });
                // });

                getOpenLevel2Child({ picklistValue: resultArray })
                .then(result => {
                    for (let k in result) {
                        let obj = {};
                        obj.Id = result[k].Id;
                        obj.Title = result[k].Title;
                        obj.Url = '/lightning/r/Knowledge__kav/' + result[k].Id + '/view';
                        obj.ArticleNumber =  result[k].ArticleNumber;
                        obj.RecordType =  result[k].RecordType.Name;
                        obj.RecordTypeId =  result[k].RecordType.Id;
                        obj.CRM_Area__c = result[k].CRM_Area__c;
                        obj.CRM_Scope__c = result[k].CRM_Scope__c;
                        obj.CRM_Level1__c = result[k].CRM_Level1__c;
                        obj.CRM_Level2__c = result[k].CRM_Level2__c;
                        obj.CRM_Level3__c = result[k].CRM_Level3__c;
                        obj.CRM_Answer__c = result[k].CRM_Answer__c;
                        obj.CRM_Question__c = result[k].CRM_Question__c;
                        obj.CRM_Description__c = result[k].CRM_Description__c;
                        arrayAll.push(obj);
                        if(count < this.numRows) {
                            arrayForNumRows.push(obj);
                            count++;
                        }
                    }

                    console.log(arrayAll);
                    
                    this.getAllResult = arrayAll;
                    this.getForNumRowsResult = arrayForNumRows;       
                    
                    this.setElementToShow();

                    this.myBreadcrumbs = [];
                    
                    let objBreadCrumbsArea = {};
                    // { label: 'Account', name: 'parent', id: 'account1' },
                    objBreadCrumbsArea.label = arrayAll[0].CRM_Area__c;
                    objBreadCrumbsArea.name = arrayAll[0].Title;
                    objBreadCrumbsArea.id = arrayAll[0].CRM_Area__c;
                    
                    this.myBreadcrumbs.push(objBreadCrumbsArea);

                    let objBreadCrumbsScope = {};
                    // { label: 'Account', name: 'parent', id: 'account1' },
                    objBreadCrumbsScope.label = arrayAll[0].CRM_Scope__c;
                    objBreadCrumbsScope.name = arrayAll[0].Title;
                    objBreadCrumbsScope.id = arrayAll[0].CRM_Scope__c;

                    this.myBreadcrumbs.push(objBreadCrumbsScope);

                    let objBreadCrumbsLevel1 = {};
                    // { label: 'Account', name: 'parent', id: 'account1' },
                    objBreadCrumbsLevel1.label = arrayAll[0].CRM_Level1__c;
                    objBreadCrumbsLevel1.name = arrayAll[0].Title;
                    objBreadCrumbsLevel1.id = arrayAll[0].CRM_Level1__c;

                    this.myBreadcrumbs.push(objBreadCrumbsLevel1);

                    let objBreadCrumbsLevel2 = {};
                    // { label: 'Account', name: 'parent', id: 'account1' },
                    objBreadCrumbsLevel2.label = arrayAll[0].CRM_Level2__c;
                    objBreadCrumbsLevel2.name = arrayAll[0].Title;
                    objBreadCrumbsLevel2.id = arrayAll[0].CRM_Level2__c;

                    this.myBreadcrumbs.push(objBreadCrumbsLevel2);
        
                })
                .catch(error => {
                    this.error = error;
                    console.log('ERROR', error);
                })
                .finally(() => {
                    this.isRendered = true;
                    this.isRenderedBreadcrumbs = true;

                });

            } else if(messageResult.messageBody.method === 'getOpenLevel3Child'){
                getOpenLevel3Child({ picklistValue: resultArray })
                .then(result => {
                    for (let k in result) {
                        let obj = {};
                        obj.Id = result[k].Id;
                        obj.Title = result[k].Title;
                        obj.Url = '/lightning/r/Knowledge__kav/' + result[k].Id + '/view';
                        obj.ArticleNumber =  result[k].ArticleNumber;
                        obj.RecordType =  result[k].RecordType.Name;
                        obj.RecordTypeId =  result[k].RecordType.Id;
                        obj.CRM_Area__c = result[k].CRM_Area__c;
                        obj.CRM_Scope__c = result[k].CRM_Scope__c;
                        obj.CRM_Level1__c = result[k].CRM_Level1__c;
                        obj.CRM_Level2__c = result[k].CRM_Level2__c;
                        obj.CRM_Level3__c = result[k].CRM_Level3__c;
                        obj.CRM_Answer__c = result[k].CRM_Answer__c;
                        obj.CRM_Question__c = result[k].CRM_Question__c;
                        obj.CRM_Description__c = result[k].CRM_Description__c;
                        arrayAll.push(obj);
                        if(count < this.numRows) {
                            arrayForNumRows.push(obj);
                            count++;
                        }
                    }

                    console.log(arrayAll);
                    
                    this.getAllResult = arrayAll;
                    this.getForNumRowsResult = arrayForNumRows;     
                    
                    this.setElementToShow();

                    this.myBreadcrumbs = [];
                    
                    let objBreadCrumbsArea = {};
                    // { label: 'Account', name: 'parent', id: 'account1' },
                    objBreadCrumbsArea.label = arrayAll[0].CRM_Area__c;
                    objBreadCrumbsArea.name = arrayAll[0].Title;
                    objBreadCrumbsArea.id = arrayAll[0].CRM_Area__c;
                    
                    this.myBreadcrumbs.push(objBreadCrumbsArea);

                    let objBreadCrumbsScope = {};
                    // { label: 'Account', name: 'parent', id: 'account1' },
                    objBreadCrumbsScope.label = arrayAll[0].CRM_Scope__c;
                    objBreadCrumbsScope.name = arrayAll[0].Title;
                    objBreadCrumbsScope.id = arrayAll[0].CRM_Scope__c;

                    this.myBreadcrumbs.push(objBreadCrumbsScope);

                    let objBreadCrumbsLevel1 = {};
                    // { label: 'Account', name: 'parent', id: 'account1' },
                    objBreadCrumbsLevel1.label = arrayAll[0].CRM_Level1__c;
                    objBreadCrumbsLevel1.name = arrayAll[0].Title;
                    objBreadCrumbsLevel1.id = arrayAll[0].CRM_Level1__c;

                    this.myBreadcrumbs.push(objBreadCrumbsLevel1);

                    let objBreadCrumbsLevel2 = {};
                    // { label: 'Account', name: 'parent', id: 'account1' },
                    objBreadCrumbsLevel2.label = arrayAll[0].CRM_Level2__c;
                    objBreadCrumbsLevel2.name = arrayAll[0].Title;
                    objBreadCrumbsLevel2.id = arrayAll[0].CRM_Level2__c;

                    this.myBreadcrumbs.push(objBreadCrumbsLevel2);

                    let objBreadCrumbsLevel3 = {};
                    // { label: 'Account', name: 'parent', id: 'account1' },
                    objBreadCrumbsLevel3.label = arrayAll[0].CRM_Level3__c;
                    objBreadCrumbsLevel3.name = arrayAll[0].Title;
                    objBreadCrumbsLevel3.id = arrayAll[0].CRM_Level3__c;

                    this.myBreadcrumbs.push(objBreadCrumbsLevel3);
        
                })
                .catch(error => {
                    this.error = error;
                    console.log('ERROR', error);
                })
                .finally(() => {
                    this.isRendered = true;
                    this.isRenderedBreadcrumbs = true;

                });
            }


        }
    }


    connectedCallback() {
        this.subscribeToMessageChannel();

        getUserInfo()
        .then(result => {
            console.log('SV getUserInfo result', result);

            this.userInfo = result;

            return getActiveRecordType();
        })
        .then(result => {
            console.log('SV getActiveRecordType result', result);

            result.forEach(element => {
                element.label = element.Name;
                element.value = element.Id;
            });

            let obj = {};
            obj.label = 'Tutti';
            obj.value = 'Tutti';
            result.unshift(obj);

            this.recordTypeList = result;
            this.value = 'Tutti';

            return this.usedOn === 'Case' ? getAllDataForCase({ recordId : this.recordId }) : null;
        })
        .then(result => {
            console.log('SV getAllDataForCase result', result);

            let arrayAll = [];
            let arrayForNumRows = [];
            let count = 0;
            for (let k in result) {
                let obj = {};
                obj.Id = result[k].Id;
                obj.Title = result[k].Title;
                obj.Url = '/lightning/r/Knowledge__kav/' + result[k].Id + '/view';
                obj.ArticleNumber =  result[k].ArticleNumber;
                obj.RecordType =  result[k].RecordType.Name;
                obj.RecordTypeId =  result[k].RecordType.Id;
                obj.CRM_Area__c = result[k].CRM_Area__c;
                obj.CRM_Scope__c = result[k].CRM_Scope__c;
                obj.CRM_Level1__c = result[k].CRM_Level1__c;
                obj.CRM_Level2__c = result[k].CRM_Level2__c;
                obj.CRM_Level3__c = result[k].CRM_Level3__c;
                obj.CRM_Answer__c = result[k].CRM_Answer__c;
                obj.CRM_Question__c = result[k].CRM_Question__c;
                obj.CRM_Description__c = result[k].CRM_Description__c;
                arrayAll.push(obj);
                if(count < this.numRows) {
                    arrayForNumRows.push(obj);
                    count++;
                }
            }
            
            this.getCaseResult = arrayAll;
            this.getAllResult = arrayAll;
            this.getForNumRowsResult = arrayForNumRows;

            this.setElementToShow();

        })
        .catch(error => {
            this.error = error;
            console.log('ERROR', error);
        })
        .finally(() => {
            if( this.usedOn === 'Case') this.isRendered = true;
        });
    }

    handleInput(event){
        this.queryTerm = event.target.value;
        if(this.queryTerm === ''){
            let arrayAll = [];
            this.emptySearch = false;
            let arrayForNumRowsResult = [];
            if(this.usedOn === 'Case') {
                arrayAll = this.getCaseResult;
                arrayForNumRowsResult = [];
                let count = 0;

                arrayAll.forEach(element => {
                    if(count < this.numRows){
                        arrayForNumRowsResult.push(element);
                    }
                    
                });
            } 

            this.getAllResult = arrayAll;
            this.getForNumRowsResult = arrayForNumRowsResult;

            this.setElementToShow();

        }
    }

    isEmpty(obj) {
        for(var key in obj) {
            if(obj.hasOwnProperty(key))
                return false;
        }
        return true;
    }

    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.queryTerm = evt.target.value;

            const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);

            if (allValid) {
                if(this.usedOn === 'Base'){
                    console.log('Base');
                    getAllDataFromText({ queryTerm : this.queryTerm })
                    .then(result => {
                        console.log('SV getAllDataFromText result', result);

                        if(this.isEmpty(result)){
                            
                            this.emptySearch = true;
                        }else{

                            this.emptySearch = false;
                        }
    
                        let arrayAll = [];
                        let arrayForNumRows = [];
                        let count = 0;
                        for (let k in result) {
                            let obj = {};
                            obj.Id = result[k].Id;
                            obj.Title = result[k].Title;
                            obj.Url = '/lightning/r/Knowledge__kav/' + result[k].Id + '/view';
                            obj.ArticleNumber =  result[k].ArticleNumber;
                            obj.RecordType =  result[k].RecordType.Name;
                            obj.RecordTypeId =  result[k].RecordType.Id;
                            obj.CRM_Area__c = result[k].CRM_Area__c;
                            obj.CRM_Scope__c = result[k].CRM_Scope__c;
                            obj.CRM_Level1__c = result[k].CRM_Level1__c;
                            obj.CRM_Level2__c = result[k].CRM_Level2__c;
                            obj.CRM_Level3__c = result[k].CRM_Level3__c;
                            obj.CRM_Answer__c = result[k].CRM_Answer__c;
                            obj.CRM_Question__c = result[k].CRM_Question__c;
                            obj.CRM_Description__c = result[k].CRM_Description__c;
                            arrayAll.push(obj);
                            if(count < this.numRows) {
                                arrayForNumRows.push(obj);
                                count++;
                            }
                        }
                        
                        this.getAllResult = arrayAll;
                        this.getForNumRowsResult = arrayForNumRows;
    
                        this.setElementToShow();
    
                    })
                    .catch(error => {
                        this.error = error;
                        console.log('ERROR', error);
                    })
                    .finally(() => {
                        this.isRendered = true;
                        this.isRenderedBreadcrumbs = false;
                    });
                }else if(this.usedOn ==='Case'){
                    console.log('Case');
                    getAllDataFromText({ queryTerm : this.queryTerm })
                    .then(result => {
                        console.log('SV getAllDataFromCase result', result);

                        if(this.isEmpty(result)){
                            
                            this.emptySearch = true;
                        }else{

                            this.emptySearch = false;
                        }
    
                        let arrayAll = [];
                        let arrayForNumRows = [];
                        let count = 0;
                        for (let k in result) {
                            let obj = {};
                            obj.Id = result[k].Id;
                            obj.Title = result[k].Title;
                            obj.Url = '/lightning/r/Knowledge__kav/' + result[k].Id + '/view';
                            obj.ArticleNumber =  result[k].ArticleNumber;
                            obj.RecordType =  result[k].RecordType.Name;
                            obj.RecordTypeId =  result[k].RecordType.Id;
                            obj.CRM_Area__c = result[k].CRM_Area__c;
                            obj.CRM_Scope__c = result[k].CRM_Scope__c;
                            obj.CRM_Level1__c = result[k].CRM_Level1__c;
                            obj.CRM_Level2__c = result[k].CRM_Level2__c;
                            obj.CRM_Level3__c = result[k].CRM_Level3__c;
                            obj.CRM_Answer__c = result[k].CRM_Answer__c;
                            obj.CRM_Question__c = result[k].CRM_Question__c;
                            obj.CRM_Description__c = result[k].CRM_Description__c;
                            arrayAll.push(obj);
                            if(count < this.numRows) {
                                arrayForNumRows.push(obj);
                                count++;
                            }
                        }
                        
                        this.getAllResult = arrayAll;
                        this.getForNumRowsResult = arrayForNumRows;
    
                        this.setElementToShow();
    
                    })
                    .catch(error => {
                        this.error = error;
                        console.log('ERROR', error);
                    })
                    .finally(() => {
                        this.isRendered = true;
                        this.isRenderedBreadcrumbs = false;
                    });
                }else if(this.usedOn === 'HC esterno'){
                    console.log('HCE');
                    getAllDataFromTextHCE({ queryTerm : this.queryTerm })
                    .then(result => {
                        console.log('SV getAllDataFromText result', result);

                        if(this.isEmpty(result)){
                            
                            this.emptySearch = true;
                        }else{

                            this.emptySearch = false;
                        }
    
                        let arrayAll = [];
                        let arrayForNumRows = [];
                        let count = 0;
                        for (let k in result) {
                            let obj = {};
                            obj.Id = result[k].Id;
                            obj.Title = result[k].Title;
                            obj.Url = '/lightning/r/Knowledge__kav/' + result[k].Id + '/view';
                            obj.ArticleNumber =  result[k].ArticleNumber;
                            obj.RecordType =  result[k].RecordType.Name;
                            obj.RecordTypeId =  result[k].RecordType.Id;
                            obj.CRM_Area__c = result[k].CRM_Area__c;
                            obj.CRM_Scope__c = result[k].CRM_Scope__c;
                            obj.CRM_Level1__c = result[k].CRM_Level1__c;
                            obj.CRM_Level2__c = result[k].CRM_Level2__c;
                            obj.CRM_Level3__c = result[k].CRM_Level3__c;
                            obj.CRM_Answer__c = result[k].CRM_Answer__c;
                            obj.CRM_Question__c = result[k].CRM_Question__c;
                            obj.CRM_Description__c = result[k].CRM_Description__c;
                            arrayAll.push(obj);
                            if(count < this.numRows) {
                                arrayForNumRows.push(obj);
                                count++;
                            }
                        }
                        
                        this.getAllResult = arrayAll;
                        this.getForNumRowsResult = arrayForNumRows;
    
                        this.setElementToShow();
    
                    })
                    .catch(error => {
                        this.error = error;
                        console.log('ERROR', error);
                    })
                    .finally(() => {
                        this.isRendered = true;
                        this.isRenderedBreadcrumbs = false;
                    });
                } else if(this.usedOn === 'HC interno'){
                    console.log('HCI');
                    getAllDataFromTextHCI({ queryTerm : this.queryTerm })
                    .then(result => {
                        console.log('SV getAllDataFromText result', result);

                        if(this.isEmpty(result)){
                            
                            this.emptySearch = true;
                        }else{

                            this.emptySearch = false;
                        }
    
                        let arrayAll = [];
                        let arrayForNumRows = [];
                        let count = 0;
                        for (let k in result) {
                            let obj = {};
                            obj.Id = result[k].Id;
                            obj.Title = result[k].Title;
                            obj.Url = '/lightning/r/Knowledge__kav/' + result[k].Id + '/view';
                            obj.ArticleNumber =  result[k].ArticleNumber;
                            obj.RecordType =  result[k].RecordType.Name;
                            obj.RecordTypeId =  result[k].RecordType.Id;
                            obj.CRM_Area__c = result[k].CRM_Area__c;
                            obj.CRM_Scope__c = result[k].CRM_Scope__c;
                            obj.CRM_Level1__c = result[k].CRM_Level1__c;
                            obj.CRM_Level2__c = result[k].CRM_Level2__c;
                            obj.CRM_Level3__c = result[k].CRM_Level3__c;
                            obj.CRM_Answer__c = result[k].CRM_Answer__c;
                            obj.CRM_Question__c = result[k].CRM_Question__c;
                            obj.CRM_Description__c = result[k].CRM_Description__c;
                            arrayAll.push(obj);
                            if(count < this.numRows) {
                                arrayForNumRows.push(obj);
                                count++;
                            }
                        }
                        
                        this.getAllResult = arrayAll;
                        this.getForNumRowsResult = arrayForNumRows;
    
                        this.setElementToShow();
    
                    })
                    .catch(error => {
                        this.error = error;
                        console.log('ERROR', error);
                    })
                    .finally(() => {
                        this.isRendered = true;
                        this.isRenderedBreadcrumbs = false;
                    });
                }
            
            } else {
                // this.loaded = !this.loaded;
                // const event = new ShowToastEvent({
                //     "variant": "error",
                //     "title": "Error!",
                //     "message": "Partita Iva e Codice Fiscale devono contenere almeno 6 caratteri."
                // });
                // this.dispatchEvent(event);
                console.log('ERROR allValid: ', allValid);
            }
        }
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

    openArticle(event) {
        var index = event.currentTarget.id.split('-')[0]; 
        // event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: index,
                objectApiName: 'Knowledge__kav',
                actionName: 'view'
            },
        });
    }

    get notEmptyList(){
        return this.getAllResult.length > 0;
    }

    handleChangeRecordType(event) {
        this.value = event.detail.value;        
        this.setElementToShow();
    }

    setElementToShow() {
        let listToShow = [];
        let listNumToShow = [];
        let count = 0;
        if(this.value === 'Tutti'){
            this.getAllResult.forEach(element => {
                    listToShow.push(element);
                    if(count < this.numRows) {
                        listNumToShow.push(element);
                        count++;
                    }
            });
        } else {
            this.getAllResult.forEach(element => {
                if(element.RecordTypeId === this.value) {
                    listToShow.push(element);
                    if(count < this.numRows) {
                        listNumToShow.push(element);
                        count++;
                    }
                }
            });
        }

        this.getAllResultToShow = listToShow;
        this.getForNumRowsResultToShow = listNumToShow;
    }
}