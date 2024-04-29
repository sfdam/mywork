import {
    LightningElement,
    api,
    track
} from 'lwc';

import STATIC_RESOURCE from '@salesforce/resourceUrl/DinamicTables';
import getObjectInfos from '@salesforce/apex/MRForDynamicTablesController.getObjectInfos';
import getAvailabilityMonths from '@salesforce/apex/MRForDynamicTablesController.getAvailabilityMonths';

export default class MeseRiferimentoForDynamicTables extends LightningElement {

    @api value;
    @api isRendered;
    @track error;
    @api isError;
    @api recordId;
    @api recordInfo;
    @api json1;
    @api json2;
    @api fileJS;
    @api isNullValue = false;
    @api thead1;
    @api tbody1;
    @api thead2;
    @api tbody2;
    @api infoPicklist = [];
    

    connectedCallback() {

        getAvailabilityMonths({
                recordId: this.recordId
            })
            .then(result => {

                
                var impostaMeseRifementoFlat;

                for (let k in result) {
                    var obj = {};
                    var objFlat = {};
                    var tempObj = {};

                    /*if (!result[k].CRM_CRMeseDiRiferimento__c) {
                        objFlat.date = null;
                        objFlat.RecordTypeDeveloperName = 'Flat';
                        objFlat.meseRiferimento = null;
                        objFlat.id = k;
                        this.infoPicklist.push(objFlat);
                    }

                    if (result[k].CRM_CRMeseDiRiferimento__c != undefined && !impostaMeseRifementoFlat) {

                        let mese = new Date(new Date(result[k].CRM_CRMeseDiRiferimento__c).setMonth(new Date(result[k].CRM_CRMeseDiRiferimento__c).getMonth() + 1)).toLocaleString('default', {month: 'long'});
                        let anno = new Date(new Date(result[k].CRM_CRMeseDiRiferimento__c).setMonth(new Date(result[k].CRM_CRMeseDiRiferimento__c).getMonth() + 1)).getFullYear();
                        tempObj.date = mese + ' ' + anno;
                        impostaMeseRifementoFlat = mese + ' ' + anno;
                        this.infoPicklist.push(tempObj);

                    }*/
                    if (result[k].CRM_CRMeseDiRiferimento__c != undefined) {

                        let mese = new Date(result[k].CRM_CRMeseDiRiferimento__c).toLocaleString('default', {month: 'long'});
                        let anno = new Date(result[k].CRM_CRMeseDiRiferimento__c).getFullYear();
                        obj.date = mese + ' ' + anno;
                        obj.RecordTypeDeveloperName = result[k].RecordType.DeveloperName;
                        obj.meseRiferimento = result[k].CRM_CRMeseDiRiferimento__c;
                        obj.id = k;
                        this.infoPicklist.push(obj);
                    }

                }

                this.selectedDate = this.infoPicklist[0].meseRiferimento;
                this.currentRecordType = 'Storico';
                this.value = this.infoPicklist[0].date;
                //this.infoPicklist[0].date = this.infoPicklist[1].date;
                //this.infoPicklist.splice(1, 1);
                this.fileJS1 = 'CRM_TabellaRischioDettaglio1.js';
                this.fileJS2 = 'CRM_TabellaRischioDettaglio2.js';

                console.log('lista mesi ', this.infoPicklist);
                console.log('mese attuale', this.value);

                let request1 = new XMLHttpRequest();
                console.log(STATIC_RESOURCE + '/js/' + this.fileJS1);
                request1.open("GET", STATIC_RESOURCE + '/js/' + this.fileJS1, false);
                request1.send(null);
                let jSONComponent1 = JSON.parse(request1.responseText);


                let request2 = new XMLHttpRequest();
                console.log(STATIC_RESOURCE + '/js/' + this.fileJS2);
                request2.open("GET", STATIC_RESOURCE + '/js/' + this.fileJS2, false);
                request2.send(null);
                let jSONComponent2 = JSON.parse(request2.responseText);


                //parametri specifici per le tabelle indicatori
                this.thead1 = jSONComponent1.thead;
                this.tbody1 = jSONComponent1.tbody;
                this.thead2 = jSONComponent2.thead;
                this.tbody2 = jSONComponent2.tbody;

                return getObjectInfos({recordId: this.recordId,RecordTypeDeveloperName: this.currentRecordType,selectedDate: this.selectedDate});
            })
            .then(result => {
                console.log('GB Flat Info', result);
                let recordInfo = result;
                let jSONbody1 = this.tbody1;
                let jSONhead1 = this.thead1;
                let jSONbody2 = this.tbody2;
                let jSONhead2 = this.thead2;


                jSONhead1.forEach(element => {
                    element.thElements.forEach(subElements => {
                        subElements.isText = false;
                        if (subElements.apiName && recordInfo[this.recordId][subElements.apiName]) {
                            subElements.isText = true;
                            subElements.value = recordInfo[this.recordId][subElements.apiName];
                        }
                        subElements.divElements.forEach(subsubElements => {
                            if (subsubElements.value == 'dati al:')
                                subsubElements.value = subsubElements.value + ' ' + today;
                        })
                    });
                });

                jSONbody1.forEach(element => {
                    element.tdElements.forEach(subElements => {

                        if (subElements.apiName && recordInfo[this.recordId][subElements.apiName] != undefined && recordInfo[this.recordId][subElements.apiName] != null) {
                            subElements.value = recordInfo[this.recordId][subElements.apiName];
                            if (subElements.value < 0)
                                subElements.style = subElements.style + 'color:red;'
                        } else {
                            if (subElements.apiName)
                                subElements.value = '-';
                        }
                        if (!subElements.formatted || subElements.value == '-') {
                            subElements.isText = true;

                        } else {
                            if (subElements.formatted.type == 'number') {
                                subElements.isNumber = true;
                            } else if (subElements.formatted.type == 'checkbox') {
                                subElements.isCheckbox = true;
                            } else {
                                subElements.isText = true;
                            }
                        }
                        console.log(' SUB ELEMENT:', ' apiname ', subElements.apiName, ' value ', subElements.value, this.isNullValue);
                    });
                });

                jSONhead2.forEach(element => {
                    element.thElements.forEach(subElements => {
                        subElements.isText = false;
                        if (subElements.apiName && recordInfo[this.recordId][subElements.apiName]) {
                            subElements.isText = true;
                            subElements.value = recordInfo[this.recordId][subElements.apiName];
                        }
                        subElements.divElements.forEach(subsubElements => {
                            if (subsubElements.value == 'dati al:')
                                subsubElements.value = subsubElements.value + ' ' + today;
                        })
                    });
                });

                jSONbody2.forEach(element => {
                    element.tdElements.forEach(subElements => {

                        if (subElements.apiName && recordInfo[this.recordId][subElements.apiName] != undefined && recordInfo[this.recordId][subElements.apiName] != null) {
                            subElements.value = recordInfo[this.recordId][subElements.apiName];
                            if (subElements.value < 0)
                                subElements.style = subElements.style + 'color:red;'
                        } else {
                            if (subElements.apiName)
                                subElements.value = '-';
                        }
                        if (!subElements.formatted || subElements.value == '-') {
                            subElements.isText = true;

                        } else {
                            if (subElements.formatted.type == 'number') {
                                subElements.isNumber = true;
                            } else if (subElements.formatted.type == 'checkbox') {
                                subElements.isCheckbox = true;

                            } else {
                                subElements.isText = true;
                            }
                        }

                        console.log(' SUB ELEMENT:', ' apiname ', subElements.apiName, ' value ', subElements.value, this.isNullValue);
                    });
                });

                this.tbody1 = jSONbody1;
                this.tbody2 = jSONbody2;
                //this.thead = jSONhead;

            }).catch(error => {
                this.error = error;
                this.isError = true;
                console.log('ERROR', error);
            })
            .finally(() => {
                console.log('HO FINITO');
                this.isRendered = true;
                
                var setupAssisstants = this.template.querySelectorAll('.accordion');
                
                setupAssisstants.forEach(element => {
                    
                    element.addEventListener('click', this.handleClick.bind(this));
                   
                   
                });

            });
    }

    handleChangeMonth(event) {
        this.isError = false;
        this.isRendered = false;
        this.value = event.detail.value;
        
        for (let k in this.infoPicklist) {

            if (this.infoPicklist[k].date == this.value) {
                this.currentRecordType = this.infoPicklist[k].RecordTypeDeveloperName;
                this.selectedDate = this.infoPicklist[k].meseRiferimento;
                //this.id =  this.infoPicklist[k].id;
            }

        }
            
            getObjectInfos({recordId: this.recordId,RecordTypeDeveloperName: this.currentRecordType,selectedDate: this.selectedDate})
            .then(result => {
                console.log('GB Flat Info', result);
                let recordInfo = result;
                let jSONbody1 = this.tbody1;
                let jSONhead1 = this.thead1;
                let jSONbody2 = this.tbody2;
                let jSONhead2 = this.thead2;


                jSONhead1.forEach(element => {
                    element.thElements.forEach(subElements => {
                        subElements.isText = false;
                        if (subElements.apiName && recordInfo[this.recordId][subElements.apiName]) {
                            subElements.isText = true;
                            subElements.value = recordInfo[this.recordId][subElements.apiName];
                        }
                        subElements.divElements.forEach(subsubElements => {
                            if (subsubElements.value == 'dati al:')
                                subsubElements.value = subsubElements.value + ' ' + today;
                        })
                    });
                });

                jSONbody1.forEach(element => {
                    element.tdElements.forEach(subElements => {

                        if (subElements.apiName && recordInfo[this.recordId][subElements.apiName] != undefined && recordInfo[this.recordId][subElements.apiName] != null) {
                            subElements.value = recordInfo[this.recordId][subElements.apiName];
                            if (subElements.value < 0)
                                subElements.style = subElements.style + 'color:red;'
                        } else {
                            if (subElements.apiName)
                                subElements.value = '-';
                        }
                        if (!subElements.formatted || subElements.value == '-') {
                            subElements.isText = true;

                        } else {
                            if (subElements.formatted.type == 'number') {
                                subElements.isNumber = true;
                            } else if (subElements.formatted.type == 'checkbox') {
                                subElements.isCheckbox = true;
                            } else {
                                subElements.isText = true;
                            }
                        }
                        console.log(' SUB ELEMENT:', ' apiname ', subElements.apiName, ' value ', subElements.value, this.isNullValue);
                    });
                });

                jSONhead2.forEach(element => {
                    element.thElements.forEach(subElements => {
                        subElements.isText = false;
                        if (subElements.apiName && recordInfo[this.recordId][subElements.apiName]) {
                            subElements.isText = true;
                            subElements.value = recordInfo[this.recordId][subElements.apiName];
                        }
                        subElements.divElements.forEach(subsubElements => {
                            if (subsubElements.value == 'dati al:')
                                subsubElements.value = subsubElements.value + ' ' + today;
                        })
                    });
                });

                jSONbody2.forEach(element => {
                    element.tdElements.forEach(subElements => {

                        // console.log('SV subElements', subElements);

                        if (subElements.apiName && recordInfo[this.recordId][subElements.apiName] != undefined && recordInfo[this.recordId][subElements.apiName] != null) {
                            subElements.value = recordInfo[this.recordId][subElements.apiName];
                            if (subElements.value < 0)
                                subElements.style = subElements.style + 'color:red;'
                        } else {
                            if (subElements.apiName)
                                subElements.value = '-';
                        }
                        if (!subElements.formatted || subElements.value == '-') {

                            subElements.isText = true;
                            subElements.isNumber = false;
                            subElements.isCheckbox = false;

                        } else {

                            if (subElements.formatted.type == 'number') {

                                subElements.isNumber = true;
                                subElements.isText = false;
                                subElements.isCheckbox = false;

                            } else if (subElements.formatted.type == 'checkbox') {

                                subElements.isCheckbox = true;
                                subElements.isNumber = false;
                                subElements.isText = false;
                            } else {

                                subElements.isText = true;
                                subElements.isNumber = false;
                                subElements.isCheckbox = false;

                            }
                        }

                        console.log(' SUB ELEMENT:', ' apiname ', subElements.apiName, ' value ', subElements.value, this.isNullValue);
                    });
                });

                this.tbody1 = jSONbody1;
                this.tbody2 = jSONbody2;
                //this.thead = jSONhead;

            }).catch(error => {
                this.error = error;
                this.isError = true;
                console.log('ERROR', error);
            })
            .finally(() => {
                console.log('HO FINITO');
                this.isRendered = true;
            });
        
    }

    get jsonThead1() {
        return this.thead1;
    }

    get jsonTbody1() {
        return this.tbody1;
    }

    get jsonThead2() {
        return this.thead2;
    }

    get jsonTbody2() {
        return this.tbody2;
    }

    get optionsMonth() {

        console.log('!!');
        let options = this.infoPicklist;

        let objList = [];

        for (let k in options) {

            let obj = {};

            obj.label = options[k].date;
            obj.value = options[k].date;

            objList.push(obj);
        }

        return objList;
    }

    handleClick(event) {
        console.log('event ',event);
        console.log('***0');
        // Your code here
        //alert('QUA ' + event.currentTarget.dataset.id);
        var accordionsChild = this.template.querySelectorAll('.accordion_' + event.currentTarget.dataset.id);
        accordionsChild.forEach(element => {
            if (element.classList.contains('slds-hide')) {
                element.classList.remove('slds-hide');
            } else {
                element.classList.add('slds-hide');
            }
        });

    }
    
}