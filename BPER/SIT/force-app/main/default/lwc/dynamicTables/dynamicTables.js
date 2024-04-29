import {LightningElement,api,track} from 'lwc';
// Import the generic static resource. All this does is provide a URL to the resource.
import STATIC_RESOURCE from '@salesforce/resourceUrl/DinamicTables';
import getObjectInfos from '@salesforce/apex/DynamicTablesController.getObjectInfos';

export default class DinamicTables extends LightningElement {

    @track isRendered;
    @track error;
    @api recordId;
    @api userInfo;
    @api recordInfo;
    @api title;
    @api iconName;
    @api monthreference;
    @api fileJS;
    @api object_field;
    @api tbody;
    @api thead;
    @api showTable = false;
    @api noTitlenoData = false;
    @api isVisible = false; //valerio.salvati 24/09/2021
    @api toHide = false;  //valerio.salvati 24/09/2021
    @api isNullValue = false;
    isText = false;

    @api get specificRecordId() {
        return this.recordId;
    }
    set specificRecordId(value) {
        alert(value);
        alert(this.fileJS);
        alert(this.object_field);
        alert(this.title);

        this.setAttribute('specificRecordId', value);
        this.recordId = value;

        this.handleValueChange(value);
    }

    //a method called in setter
    handleValueChange(value) {
        // alert('YYYY');

        console.log(value);
        //do something
        let x = this.object_field.split('#');
        //this.getRecord(x[0], x[1], x[2]);
        this.getRecord(x[0], x[1], x[2],x[3]);//valerio.salvati 24/09/2021
    }

    connectedCallback() {

        // alert('XXX');
        
        let request = new XMLHttpRequest();
        console.log(STATIC_RESOURCE + '/js/' + this.fileJS);
        request.open("GET", STATIC_RESOURCE + '/js/' + this.fileJS, false);
        request.send(null);
        let jSONComponent = JSON.parse(request.responseText);

        this.thead = jSONComponent.thead;
        this.tbody = jSONComponent.tbody;
        console.log('SV object_field: ', this.object_field);
        let x = this.object_field.split('#');
        console.log('GB afterSplit: ', x);

        //this.getRecord(x[0], x[1], x[2]);
        this.getRecord(x[0], x[1], x[2],x[3]);//valerio.salvati 24/09/2021

        // getObjectInfos({
        //         obj: x[0],
        //         field_lookup: x[1],
        //         recordId: this.recordId
        //     })
        //     .then(result => {
        //         console.log('GB getRecordInfo', result);

        //         let recordInfo = result;
        //         if (recordInfo) {
        //             this.showTable = true;

        //         }

        //         this.lastModifiedDate = recordInfo[this.recordId].LastModifiedDate;
        //         let dd = String(new Date(this.lastModifiedDate).getDate()).padStart(2, '0');
        //         let mm = String(new Date(this.lastModifiedDate).getMonth() + 1).padStart(2, '0');
        //         let yyyy = new Date(this.lastModifiedDate).getFullYear();
        //         this.lastModifiedDate = dd + '/' + mm + '/' + yyyy;

        //         let jSONbody = this.tbody;
        //         let jSONhead = this.thead;


        //         jSONhead.forEach(element => {
        //             element.thElements.forEach(subElements => {
        //                 subElements.isText = false;
        //                 if (subElements.apiName && recordInfo[this.recordId][subElements.apiName]) {
        //                     subElements.isText = true;
        //                     subElements.value = recordInfo[this.recordId][subElements.apiName];
        //                 }
        //                 subElements.divElements.forEach(subsubElements => {
        //                     if (subsubElements.value == 'dati al:')
        //                         subsubElements.value = subsubElements.value + ' ' + this.lastModifiedDate;
        //                 })
        //             });
        //         });

        //         jSONbody.forEach(element => {
        //             element.tdElements.forEach(subElements => {
        //                 if (subElements.apiName && recordInfo[this.recordId][subElements.apiName] != undefined && recordInfo[this.recordId][subElements.apiName] != null) {
        //                     subElements.value = recordInfo[this.recordId][subElements.apiName];
        //                     if (subElements.value < 0)
        //                         subElements.style = subElements.style + 'color:red;'
        //                 } else {
        //                     if (subElements.apiName)
        //                         subElements.value = '-';
        //                 }

        //                 if (!subElements.formatted || subElements.value == '-') {
        //                     subElements.isText = true;

        //                 } else {
        //                     if (subElements.formatted.type == 'number') {

        //                         subElements.isNumber = true;
        //                     } else if (subElements.formatted.type == 'checkbox') {
        //                         subElements.isCheckbox = true;

        //                     } else {
        //                         subElements.isText = true;

        //                     }
        //                 }

        //                 console.log(' SUB ELEMENT:', ' apiname ', subElements.apiName, ' value ', subElements.value, this.isNullValue);

        //             });
        //         });

        //         this.tbody = jSONbody;
        //         //this.thead = jSONhead;

        //     }).catch(error => {
        //         if (!this.title)
        //             this.noTitlenoData = true;
        //         this.error = error;
        //         console.log('ERROR', error);
        //     })
        //     .finally(() => {
        //         console.log('HO FINITO');
        //         this.isRendered = true;

        //         var setupAssisstants = this.template.querySelectorAll('.accordion');
        //         setupAssisstants.forEach(element => {
        //             element.addEventListener('click', this.handleClick.bind(this));
        //         });

        //     });
    }

    handleClick(event) {
        // Your code here
        // alert('QUA ' + event.currentTarget.dataset.id);
        var accordionsChild = this.template.querySelectorAll('.accordion_' + event.currentTarget.dataset.id);
        accordionsChild.forEach(element => {
            if (element.classList.contains('slds-hide')) {
                element.classList.remove('slds-hide');
            } else {
                element.classList.add('slds-hide');
            }
        });

    }

    get jsonThead() {
        return this.thead;
    }

    get jsonTbody() {
        return this.tbody;
    }


    //getRecord(typeObj, fieldCondition,recType) {
    getRecord(typeObj, fieldCondition,recType,hideValue) { //valerio.salvati 24/09/2021

        var hidingCondition = (hideValue == undefined || hideValue == null) ? false : Boolean(hideValue); //valerio.salvati 24/09/2021
        console.log('hidingCondition', hidingCondition);
        getObjectInfos({
            obj: typeObj,
            field_lookup: fieldCondition,
            recordId: this.recordId,
            recordTypeDeveloperName: recType, 
            fileJS : this.fileJS  
        })
        .then(result => {
            console.log('GB getRecordInfo', result);
            console.log('GB this.fileJS', this.fileJS);

            let recordInfo = result;
            if (recordInfo) {
                this.showTable = true;
            }

            let indClientefieldsToCheck = ['CRM_FatturatoPeriodo1__c', 'CRM_FatturatoPeriodo2__c', 'CRM_FatturatoPeriodo3__c', 'CRM_RisultatoEsercizio1__c',  'CRM_RisultatoEsercizio2__c',  'CRM_RisultatoEsercizio3__c']; //valerio.salvati 24/09/2021

            this.lastModifiedDate = recordInfo[this.recordId][0].LastModifiedDate;
            let dd = String(new Date(this.lastModifiedDate).getDate()).padStart(2, '0');
            let mm = String(new Date(this.lastModifiedDate).getMonth() + 1).padStart(2, '0');
            let yyyy = new Date(this.lastModifiedDate).getFullYear();
            this.lastModifiedDate = dd + '/' + mm + '/' + yyyy;

            let jSONbody = this.tbody;
            let jSONhead = this.thead;

            
            jSONhead.forEach(element => {
                element.thElements.forEach(subElements => {
                    subElements.isText = false;
                    if (subElements.apiName && recordInfo[this.recordId][0][subElements.apiName]) {
                        subElements.isText = true;
                        subElements.value = recordInfo[this.recordId][0][subElements.apiName];
                    }
                    subElements.divElements.forEach(subsubElements => {
                        if (subsubElements.value == 'dati al:')
                            subsubElements.value = subsubElements.value + ' ' + this.lastModifiedDate;
                    })
                });
            });

            let newJsonBody = [];
            let jsonRow = 0;
            let rowNumber = 1;

            jSONbody.forEach(element => {

                jsonRow++;
                if(element.isRecordTypeStorico){
                    let storicoNumber = 0;
                    let storicoRecords = result[this.recordId];
                    if(storicoRecords.length > 1){
                        storicoRecords.forEach(currentRecord => {

                            if(storicoNumber != 0){
                                let newTR = JSON.parse(JSON.stringify(element));
                                let tdCounter = 1;

                                if(storicoNumber != 1 || storicoRecords.length == 2){
                                    let class2remove = storicoRecords.length != 2 ? 'slds-hint-parent accordion' : 'slds-hint-parent';
                                    let newClasses = storicoRecords.length != 2 ? 'accordion_tr_'+jsonRow +' slds-hide' : '';
                                    newTR.class = newTR.class.replace(class2remove,newClasses);
                                    newTR.tdElements[0].divElements[0].buttonAccordion = false;
                                }


                                newTR.tdElements.forEach(subElements => {
                                    if(storicoNumber != 1 && tdCounter == 1){
                                        subElements.value = '';
                                    }

                                    if (subElements.apiName && currentRecord[subElements.apiName] != undefined && currentRecord[subElements.apiName] != null) {
                                        subElements.value = currentRecord[subElements.apiName];
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
                                    tdCounter++;
                            
                                });
                                newTR.key='tr_'+rowNumber;
                                newJsonBody.push(newTR);

                                rowNumber++;

                            }

                            storicoNumber++;

                            
                        });
                    }else{ //non ci sono record di storico
                        let newTR = JSON.parse(JSON.stringify(element));
                        let tdCounter = 1;
                        let class2remove = 'slds-hint-parent';
                        let currentRecord = storicoRecords[0];
                        newTR.class = newTR.class.replace(class2remove,'');
                        newTR.tdElements[0].divElements[0].buttonAccordion = false;

                        newTR.tdElements.forEach(subElements => {
  
                            if (subElements.apiName && currentRecord[subElements.apiName] != undefined && currentRecord[subElements.apiName] != null) {
                                subElements.value = currentRecord[subElements.apiName];
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
                            tdCounter++;
                    
                        });
                        newTR.key='tr_'+rowNumber;
                        newJsonBody.push(newTR);

                        rowNumber++;
                    }


                } else {
                    let newTR = Object.assign({},element);

                    newTR.tdElements.forEach(subElements => {
                        if (subElements.apiName && recordInfo[this.recordId][0][subElements.apiName] != undefined && recordInfo[this.recordId][0][subElements.apiName] != null) {
                            subElements.value = recordInfo[this.recordId][0][subElements.apiName];
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
    
                        if(hidingCondition && typeObj == "CRM_IndicatoriCliente__c" && indClientefieldsToCheck.includes(subElements.apiName) && (subElements.value != null && subElements.value != "" && subElements.value != null && subElements.value != "-")){ //valerio.salvati 24/09/2021
                            console.log('check CRM_IndicatoriCliente__c hidingCondition:', hidingCondition);
                            hidingCondition = false;
                        }
                        
    
                    });

                    newTR.key='tr_'+rowNumber;
                    newJsonBody.push(newTR);

                    rowNumber++;

                }

            });

            this.toHide = hidingCondition;  //valerio.salvati 24/09/2021
            this.isVisible = !(this.noTitlenoData || this.toHide);  //valerio.salvati 24/09/2021


            this.tbody = newJsonBody;
            let newBody = this.jsonTbody;
            console.log(newBody);
            //this.thead = jSONhead;

        }).catch(error => {
            if (!this.title)
                this.noTitlenoData = true;
            this.error = error;
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

}