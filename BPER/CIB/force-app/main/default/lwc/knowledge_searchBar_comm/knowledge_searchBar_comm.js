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


import getUserInfo from '@salesforce/apex/KnowledgeController.getUserInfo';

import getAllDataFromTextHCI from '@salesforce/apex/KnowledgeController.getAllDataFromTextHCI';
import getAllDataFromTextHCE from '@salesforce/apex/KnowledgeController.getAllDataFromTextHCE';
import getAllDataFromTextExUBI from '@salesforce/apex/KnowledgeController.getAllDataFromTextExUBI';
import getAllDataFromTextExISP from '@salesforce/apex/KnowledgeController.getAllDataFromTextExISP';

import Nessun_Risultato from '@salesforce/label/c.knowledge_searchBar_comm_EmptySearch';



export default class Knowledge_searchBar extends NavigationMixin(LightningElement) {

    label = {Nessun_Risultato};
    
    @track loaded = false;
    @track error;
    @track userInfo;
    @api recordId;

    @api title;
    @api iconName;
    @api numRows;
    @api usedOn;
    @api tipoArticolo;

    queryTerm;
    getAllResult = [];
    getForNumRowsResult = [];

    getAllResultToShow = [];
    getForNumRowsResultToShow = [];

    @api isRendered;
    @api openmodel = false;

    

    @api isRenderedBreadcrumbs = false;
    @track
    myBreadcrumbs = [];

    @api emptySearch = false;

    constructor() {
        super();
    }

    

    


    connectedCallback() {
        

        getUserInfo()
        .then(result => {
            console.log('SV getUserInfo result', result);

            this.userInfo = result;    
        })
        
        .catch(error => {
            this.error = error;
            console.log('ERROR', error);
        })  
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
                 if(this.usedOn === 'HC esterno'){
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
                } else if(this.usedOn === 'Ex-UBI'){
                    console.log('Ex-UBI');
                    getAllDataFromTextExUBI({ queryTerm : this.queryTerm })
                    .then(result => {
                        console.log('GB getAllDataFromEXUBI result', result);

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

                } else if(this.usedOn === 'Ex-ISP'){
                    console.log('Ex-ISP');
                    getAllDataFromTextExISP({ queryTerm : this.queryTerm })
                    .then(result => {
                        console.log('GB getAllDataFromEXISP result', result);

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

    handleInput(event){
        this.queryTerm = event.target.value;
        if(this.queryTerm === ''){
            let arrayAll = [];
            this.emptySearch = false;
            let arrayForNumRowsResult = [];
            this.getAllResult = arrayAll;
            this.getForNumRowsResult = arrayForNumRowsResult;

            this.setElementToShow();

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

    setElementToShow() {
        let listToShow = [];
        let listNumToShow = [];
        let count = 0;

            this.getAllResult.forEach(element => {
                    listToShow.push(element);
                    if(count < this.numRows) {
                        listNumToShow.push(element);
                        count++;
                    }
            });
        

        this.getAllResultToShow = listToShow;
        this.getForNumRowsResultToShow = listNumToShow;
    }
}