/* eslint-disable no-useless-constructor */
/* eslint-disable no-unused-vars */
/* eslint-disable vars-on-top */
/* eslint-disable no-loop-func */
/* eslint-disable guard-for-in */
/* eslint-disable no-alert */
/* eslint-disable @lwc/lwc/no-api-reassignments */
/* eslint-disable no-undef */
import { LightningElement, api, track, wire } from 'lwc';

// Import ToastEvent

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

import { publish,MessageContext, subscribe, unsubscribe, APPLICATION_SCOPE } from 'lightning/messageService';
import lmsDemoMC from "@salesforce/messageChannel/knowledge__c";


import getAllArea from '@salesforce/apex/KnowledgeController.getAllArea';
import getUserInfo from '@salesforce/apex/KnowledgeController.getUserInfo';
import getOpenAreaChild from '@salesforce/apex/KnowledgeController.getOpenAreaChild';
import getOpenScopeChild from '@salesforce/apex/KnowledgeController.getOpenScopeChild';
import getOpenLevel1Child from '@salesforce/apex/KnowledgeController.getOpenLevel1Child';
import getOpenLevel2Child from '@salesforce/apex/KnowledgeController.getOpenLevel2Child';
import getOpenLevel3Child from '@salesforce/apex/KnowledgeController.getOpenLevel3Child';



export default class Knowledge_index extends NavigationMixin(LightningElement) {
    @track loaded = false;
    @track error;
    @track userInfo;

    @api title;
    @api iconName;

    @api getAllArea = [];
    @api getSelectedArea = [];
    @api getAllScope = [];

    @api openAreaChild = [];
    @api openScopeChild = [];
    @api openLevel1Child = [];
    @api openLevel2Child = [];
    @api openLevel3Child = [];

    activeSectionsArea = [];
    activeSectionsScope = [];
    activeSectionsLevel1 = [];
    activeSectionsLevel2 = [];
    activeSectionsLevel3 = [];

    channel;
    @wire(MessageContext)
    context;

    constructor() {
        super();
    }
   
    subscribeToMessageChannel() {
        const parentPage = this;
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
            
        }
    }

    connectedCallback() {
        this.subscribeToMessageChannel();

        getUserInfo()
        .then(result => {
            console.log('SV getUserInfo result', result);

            this.userInfo = result;
            return getAllArea();
        })
        .then(result => {

            let index = 1;
            let arrayAree = [];
            result.forEach(element => {
                let obj = {};
                obj.Name = element;
                obj.index = index;
                obj.scopeChild = [];
                arrayAree.push(obj);
                index++;
                
            });
            this.getAllArea = arrayAree;
            console.log('SV getAllArea result', this.getAllArea);

            
        })
        .catch(error => {
            this.error = error;
            console.log('ERROR', error);
        })
        .finally(() => {

        });
    }

    handleSectionToggle(event) {
        let openSections = event.detail.openSections;
        

        if(openSections.length > this.openAreaChild.length){
            openSections.forEach(element => {
                if(this.openAreaChild.indexOf(element) === -1){
                    const payload = {
                        source: 'getOpenAreaChild',
                        messageBody: { method : 'getOpenAreaChild', result : element }
                    }; 
                    publish(this.context, lmsDemoMC, payload);
                }
            });
        }

        this.openAreaChild = openSections;

        
        getOpenAreaChild({ picklistValue: openSections })
        .then(result => {
            console.log('SV getOpenAreaChild result', result);
            let allAree = this.getAllArea;

            for (var key in result) {
                result[key].level1Child = [];
                let keySplit = key.split('_');
                allAree.forEach(element => {
                    if(element.Name === keySplit[0]){
                        let notFind = true;
                        element.scopeChild.forEach(elementChild => {
                            if(elementChild.CRM_Scope__c === keySplit[1]) notFind = false;
                        });
                        if(notFind && result[key].hasOwnProperty('CRM_Scope__c')) element.scopeChild.push(result[key]);
                    }
                });

            }

            // const payload = {
            //     source: 'getOpenAreaChild',
            //     messageBody: { method : 'getOpenAreaChild', source: event.detail.openSections, result : allAree }
            // }; 
            // publish(this.context, lmsDemoMC, payload);

            console.log('SV allAree result', allAree);
            this.getAllArea = allAree;


        })
        .catch(error => {
            this.error = error;
            console.log('ERROR', error);
        })
        .finally(() => {

        });

    }

    handleSectionToggleScope(event) {
        let openSections = event.detail.openSections;

        if(openSections.length > this.openScopeChild.length){
            openSections.forEach(element => {
                if(this.openScopeChild.indexOf(element) === -1){
                    const payload = {
                        source: 'getOpenScopeChild',
                        messageBody: { method : 'getOpenScopeChild', result : element }
                    }; 
                    publish(this.context, lmsDemoMC, payload);
                }
            });
        }

        this.openScopeChild = openSections;

        getOpenScopeChild({ picklistValue: openSections })
        .then(result => {
            console.log('SV getOpenScopeChild result', result);
            let allAree = this.getAllArea;

            for (var key in result) {
                result[key].level2Child = [];
                let keySplit = key.split('_');
                allAree.forEach(elementArea => {
                    elementArea.scopeChild.forEach(elementScope => {
                        if(elementScope.CRM_Scope__c === keySplit[0]){
                            let notFind = true;
                            elementScope.level1Child.forEach(elementChild => {
                                if(elementChild.CRM_Level1__c === keySplit[1]) notFind = false;
                            });
                            if(notFind && result[key].hasOwnProperty('CRM_Level1__c')) elementScope.level1Child.push(result[key]);
                        }
                    });
                });

            }

            console.log('SV allAree result', allAree);

            this.getAllArea = allAree;


        })
        .catch(error => {
            this.error = error;
            console.log('ERROR', error);
        })
        .finally(() => {

        });

    }

    handleSectionToggleLevel1(event) {
        let openSections = event.detail.openSections;

        if(openSections.length > this.openLevel1Child.length){
            openSections.forEach(element => {
                if(this.openLevel1Child.indexOf(element) === -1){
                    const payload = {
                        source: 'getOpenLevel1Child',
                        messageBody: { method : 'getOpenLevel1Child', result : element }
                    }; 
                    publish(this.context, lmsDemoMC, payload);
                }
            });
        }

        this.openLevel1Child = openSections;
        
        getOpenLevel1Child({ picklistValue: openSections })
        .then(result => {
            console.log('SV getOpenLevel1Child result', result);
            let allAree = this.getAllArea;

            for (var key in result) {
                result[key].level3Child = [];
                let keySplit = key.split('_');
                allAree.forEach(elementArea => {
                    elementArea.scopeChild.forEach(elementScope => {
                        elementScope.level1Child.forEach(elementLevel1 => {
                            if(elementLevel1.CRM_Level1__c === keySplit[0]){
                                let notFind = true;
                                elementLevel1.level2Child.forEach(elementChild => {
                                    if(elementChild.CRM_Level2__c === keySplit[1]) notFind = false;
                                });
                                if(notFind && result[key].hasOwnProperty('CRM_Level2__c')) elementLevel1.level2Child.push(result[key]);
                            }
                        });
                    });
                });

            }

            console.log('SV allAree result', allAree);
            this.getAllArea = allAree;


        })
        .catch(error => {
            this.error = error;
            console.log('ERROR', error);
        })
        .finally(() => {

        });

    }

    handleSectionToggleLevel2(event) {
        let openSections = event.detail.openSections;

        if(openSections.length > this.openLevel2Child.length){
            openSections.forEach(element => {
                if(this.openLevel2Child.indexOf(element) === -1){
                    const payload = {
                        source: 'getOpenLevel2Child',
                        messageBody: { method : 'getOpenLevel2Child', result : element }
                    }; 
                    publish(this.context, lmsDemoMC, payload);
                }
            });
        }

        this.openLevel2Child = openSections;
        
        getOpenLevel2Child({ picklistValue: openSections })
        .then(result => {
            console.log('SV getOpenLevel2Child result', result);
            let allAree = this.getAllArea;

            for (var key in result) {
                result[key].level3Child = [];
                let keySplit = key.split('_');
                allAree.forEach(elementArea => {
                    elementArea.scopeChild.forEach(elementScope => {
                        elementScope.level1Child.forEach(elementLevel1 => {
                            elementLevel1.level2Child.forEach(elementLevel2 => {
                                if(elementLevel2.CRM_Level2__c === keySplit[0]){
                                    let notFind = true;
                                    elementLevel2.level3Child.forEach(elementChild => {
                                        if(elementChild.CRM_Level3__c === keySplit[1]) notFind = false;
                                    });
                                    if(notFind && result[key].hasOwnProperty('CRM_Level3__c')) elementLevel2.level3Child.push(result[key]);
                                }
                            });
                        });
                    });
                });

            }

            console.log('SV allAree result', allAree);
            this.getAllArea = allAree;


        })
        .catch(error => {
            this.error = error;
            console.log('ERROR', error);
        })
        .finally(() => {

        });

    }

    handleSectionToggleLevel3(event) {
        let openSections = event.detail.openSections;

        if(openSections.length > this.openLevel3Child.length){
            openSections.forEach(element => {
                if(this.openLevel3Child.indexOf(element) === -1){
                    const payload = {
                        source: 'getOpenLevel3Child',
                        messageBody: { method : 'getOpenLevel3Child', result : element }
                    }; 
                    publish(this.context, lmsDemoMC, payload);
                }
            });
        }

        this.openLevel3Child = openSections;
        
    }

    handleMenuSelectArea(event) {
        // retrieve the selected item's value
        // const selectedItemValue = event.detail.value;

        // INSERT YOUR CODE HERE
        // alert(selectedItemValue);

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Knowledge__kav',
                actionName: 'list'
            },
            state: {
                filterName: '00B1X000003501GUAQ'
            },
        });
    }
}