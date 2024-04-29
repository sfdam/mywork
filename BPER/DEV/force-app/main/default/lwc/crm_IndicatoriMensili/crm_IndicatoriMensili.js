import {LightningElement,api,track} from 'lwc';
import getAccountData from '@salesforce/apex/CRM_EconomicIndicatorController.getAccountData';
import getRelazioniAccount from '@salesforce/apex/CRM_EconomicIndicatorController.getRelazioniAccount';
import getIndicatoriCliente from '@salesforce/apex/CRM_EconomicIndicatorController.getIndicatoriCliente';
import getIndicatoriPF from '@salesforce/apex/CRM_EconomicIndicatorController.getIndicatoriPF';
import getCointestazioni from '@salesforce/apex/CRM_EconomicIndicatorController.getCointestazioni';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import STATIC_RESOURCE from '@salesforce/resourceUrl/DinamicTables';

const columns = [
    { label: 'NDG', fieldName: 'ndg', hideDefaultActions: true, wrapText: false },
    { label: 'Nome', fieldName: 'name', hideDefaultActions: true, wrapText: true }
];

export default class Crm_IndicatoriEconomici extends LightningElement {

    @api recordId; //accountId
    @api accountData = []; //data array filtro
    @api accountDataMap; //Id->Record Filtro
    @api indicatoriDataObjMap;
    @api previousSelectedRowsNumber = 0;
    @api preSelectedRows = [];
    @api tableValues;
    
    @api tableFieldsMap;
    columns = columns;

    //visibilità
    @api isVisible = false;
    @api isRendered = false;
    @api showTable = false;


    //struttura tabelle
    @api fileJS;
    @api thead;
    @api tbody;

    @api tbodyOriginal;

    get jsonThead() {
        console.log('jsonThead : ',this.thead);
        return this.thead;
    }

    get jsonTbody() {
        console.log('jsonTbody : ',this.tbody);
        return this.tbody;
    }

    connectedCallback(){
        this.tableFieldsMap = this.generateFieldMapping();

        //tabella 1
        console.log('recordID: ',this.recordId);
        console.log('fileJS: ',this.fileJS);

        let request = new XMLHttpRequest();
        console.log(STATIC_RESOURCE + '/js/' + this.fileJS);
        request.open("GET", STATIC_RESOURCE + '/js/' + this.fileJS, false);
        request.send(null);
        console.log('check callout');
        let jSONComponent = JSON.parse(request.responseText);
        console.log('SV JSON: ', jSONComponent);


        this.thead = jSONComponent.thead;
        this.tbody = jSONComponent.tbody;
        this.tbodyOriginal = JSON.parse(JSON.stringify(this.tbody));

        this.getTabledata();
    }

    getTabledata(){
        getAccountData({accId: this.recordId
        }).then(result => { //creazione tabella filtro e retrieve dei degli indicatori
            let dataMap = new Map();
            let preSelected = [];

            let ndgDataRow = {'Id' : result.Id, 'ndgValue' : result.CRM_NDG__c, 'ndg' : result.CRM_NDG__c, "name" : result.Name};
            dataMap.set(result.Id, ndgDataRow);
            preSelected.push(result.Id);
            
            this.preSelectedRows = preSelected;
            this.accountDataMap = dataMap;
            console.log('getAccountData preSelectedRows: ', this.preSelectedRows);
            console.log('getAccountData accountDataMap: ', this.accountDataMap);

            // chiamata per la retrieve dei cc
            getRelazioniAccount({accId: this.recordId
            }).then(result => { //creazione tabella filtro e retrieve dei degli indicatori
                let recordInfo = result;
                console.log('recordInfo: ', recordInfo);
                let dataMap = this.accountDataMap;
                let preSelected = this.preSelectedRows;
                let accountIdArray = []; 

                if (recordInfo){

                    let value;
                    let dataRow;
                    Object.keys(recordInfo).forEach(function(key) {

                        value = recordInfo[key];

                        /*if(!preSelected.includes(value.CRM_Account__c)){
                            let ndgDataRow = {'Id' : value.CRM_Account__c, 'ndgValue' : value.CRM_Account__r.CRM_NDG__c, 'ndg' : value.CRM_Account__r.CRM_NDG__c, "name" : value.CRM_Account__r.Name};
                            dataMap.set(value.CRM_Account__c, ndgDataRow);
                            preSelected.push(value.CRM_Account__c);
                        }*/
                        if(value.CRM_Active__c == true){
                            dataRow = {'Id' : value.CRM_JointOwnership__c, 'ndgValue' : value.CRM_JointOwnership__r.CRM_NDG__c, 'ndg' : ('CO (quota parte): '+value.CRM_JointOwnership__r.CRM_NDG__c), "name" : value.CRM_JointOwnership__r.Name, numeroCointestatari:""};
                            dataMap.set(value.CRM_JointOwnership__c, dataRow);
                            accountIdArray.push(value.CRM_JointOwnership__c);
                            if(!preSelected.includes(value.CRM_JointOwnership__c)){
                                preSelected.push(value.CRM_JointOwnership__c);
                            }
                        }

                    }); 

                }
                //let resultArray = Array.from(dataMap.values());
                //console.log('resultArray: ',resultArray);

                this.preSelectedRows = preSelected;
                this.accountDataMap = dataMap;
                
                let resultArray = Array.from(this.accountDataMap.values());
                this.accountData = resultArray;
                console.log('getRelazioniAccount resultArray: ',resultArray);

                console.log('getRelazioniAccount preSelectedRows: ', this.preSelectedRows);
                console.log('getRelazioniAccount accountDataMap: ', this.accountDataMap);
    

                getCointestazioni( {accIdList : accountIdArray })
                .then(result => {// retrieve aggregate cointestatari
                    let recordInfo = result;
                    console.log('recordInfo getCointestazioni: ', recordInfo);

                    if (recordInfo){
                        for (const [key, value] of Object.entries(recordInfo)) {
                            this.accountDataMap.get(key).numeroCointestatari = value.numeroCointestatari;
                        }

                    }

                    getIndicatoriCliente({accIdList : Array.from( this.accountDataMap.keys() ) })
                    .then(result => { //costruisce le tabelle
                        let recordInfo = result;
                        let accountMap = this.accountDataMap;
                        let accountArray = this.accountData = []; 
                        let preSelectedArray = this.preSelectedRows = []; 
                        let recordId = this.recordId;
        
                        console.log('recordInfo getIndicatoriCliente: ', recordInfo);
        
                        if (recordInfo){
                                Object.keys(recordInfo).forEach(function(key) {
                                    if(key == recordId){
                                        let newSortedArray = [];
                                        newSortedArray.push(accountMap.get(key));
                                        accountArray = newSortedArray.concat(accountArray);
                                    }else{
                                        accountArray.push(accountMap.get(key));
                                    }
                                    preSelectedArray.push(key);


                                });
                                console.log('accountArray getIndicatoriCliente: ', accountArray);
                                console.log('preSelectedArray getIndicatoriCliente: ', preSelectedArray);

                                this.accountData = accountArray;
                                this.preSelectedRows = preSelectedArray;

                                this.indicatoriDataObjMap = recordInfo;
                                console.log('indicatoriDataObjMap: ',this.indicatoriDataObjMap);
                                if(recordInfo[this.recordId] == undefined){

                                    getIndicatoriPF({accId : this.recordId})
                                    .then(result => {
                                        if (recordInfo){
                                            if(recordInfo != {}){
                                                this.preSelectedRows.push(this.recordId);
                                                this.indicatoriDataObjMap.push(recordInfo[this.recordId])
                                            }; 

                                                let idArray = this.preSelectedRows;
                                                console.log('indicatoriDataObjMap: ',this.indicatoriDataObjMap);

                                                this.calculateTableValues(idArray);
                                                this.loadJsonHeader(this.thead,this.indicatoriDataObjMap);
                                                this.loadJsonBody(this.tbody,this.indicatoriDataObjMap[this.recordId]);   
                                                this.isVisible = true;
                                                this.showTable = true;
                                        }
                                    }).catch(error => {
                                        console.error('getIndicatoriPF error: ' + JSON.stringify(error));
                                        console.log('SV ERROR: ', error);
                                    })
                                }else{
                                    this.calculateTableValues(preSelectedArray);
                                    this.loadJsonHeader(this.thead,recordInfo);
                                    this.loadJsonBody(this.tbody,this.indicatoriDataObjMap[this.recordId]);   
                                    this.isVisible = true;
                                    this.showTable = true;
                                }   
                        }
                                
                    }).catch(error => {
                        console.error('getIndicatoriCliente error: ' + JSON.stringify(error));
                        console.log('SV ERROR: ', error);
                    })        
                    .finally(() => {
                        this.isRendered = true;
                        var setupAssisstants = this.template.querySelectorAll('.accordion');
                        setupAssisstants.forEach(element => {
                            element.addEventListener('click', this.handleClick.bind(this));
                        });
            
                    });
            

                }).catch(error => {
                    console.error('getCointestazioni error: ' + JSON.stringify(error));
                    console.log('SV ERROR: ', error);
                });

            }).catch(error => {
                console.error('getRelazioniAccount error: ' + JSON.stringify(error));
                console.log('SV ERROR: ', error);
            })
        }).catch(error => {
            console.error('getAccountData error: ' + JSON.stringify(error));
            console.log('SV ERROR: ', error);
        })

    }

    handleUserSelection(event){
        this.isRendered = false;

        let selectedRows = event.detail.selectedRows;
        console.log('selectedRows: ', selectedRows);
        console.log('preSelectedRows: ', this.preSelectedRows);

        let idArray = [];

        let found = false;
        /*selectedRows.forEach(row => {
            if(row.Id == this.recordId)
                found = true;
        });
        if(!found)
            idArray.push((this.recordId));*/

        for (let i = 0; i < selectedRows.length; i++) {
            idArray.push(selectedRows[i].Id);
        }

        this.preSelectedRows = idArray;

        this.calculateTableValues(idArray);

        this.tbody = JSON.parse(JSON.stringify(this.tbodyOriginal));

        this.loadJsonBody(this.tbody,this.indicatoriDataObjMap[this.recordId]);
        this.isRendered = true;


    }

    handleClick(event) {
            console.log("accordion_ , ",event.currentTarget.dataset.id);
            var accordionsChild = this.template.querySelectorAll('.accordion_' + event.currentTarget.dataset.id);
            accordionsChild.forEach(element => {
            if (element.classList.contains('slds-hide')) {
                element.classList.remove('slds-hide');
            } else {
                element.classList.add('slds-hide');
            }
        });

    }

    calculateTableValues(idArray){
        let tableValuesMap = new Map();

        let currentRecord;
        let currentCointestatari;

        let sumQuota;
        let sumQuotaAP;
        let currentTableValue;

        let currentBaseCalcolo;
        let currentValoreDaSottrarre;

        let erroreConsistenza;
        let recordErrore;

        console.log('crm_IndicatoriMensili calculateTableValues tableFieldsMap: ',this.tableFieldsMap);
        for (const [key, value] of this.tableFieldsMap.entries()) {
            console.log('crm_IndicatoriEconomici calculateTableValues current key: ',key, 'crm_IndicatoriEconomici calculateTableValues current value: ',value);

            currentTableValue = 0;
            sumQuota = 0;
            sumQuotaAP = 0;

            erroreConsistenza = false;
            recordErrore = {};

            idArray.forEach(element => {

                currentRecord = this.indicatoriDataObjMap[element];
                console.log('crm_IndicatoriMensili calculateTableValues currentRecord: ',currentRecord);

                currentBaseCalcolo = !currentRecord[value.campoBase] ? 0 : currentRecord[value.campoBase];
                currentValoreDaSottrarre = (currentRecord[value.campoSottrazione] != undefined && value.campoSottrazione != "" && currentRecord[value.campoSottrazione] != undefined && currentRecord[value.campoSottrazione] != null)  ? currentRecord[value.campoSottrazione] : 0;


                currentCointestatari = (element != this.recordId) ? this.accountDataMap.get(element).numeroCointestatari : 1 ;

                currentBaseCalcolo = currentBaseCalcolo / currentCointestatari;
                currentValoreDaSottrarre = currentValoreDaSottrarre / currentCointestatari;

                sumQuota += currentBaseCalcolo;
                sumQuotaAP += currentValoreDaSottrarre;

                   
            });

            if(idArray.length>0){
                if(value.tipo == 'percentuale'){
                    currentTableValue = (sumQuotaAP != 0) ? Math.round( ((sumQuota - sumQuotaAP) / sumQuotaAP) * 100) : '-';
                }else{
                    currentTableValue = Math.round(sumQuota);
                }
            }else{
                currentTableValue = '-';
            }


            tableValuesMap.set(key,currentTableValue);
        }

            this.tableValues = tableValuesMap;

    }

    loadJsonBody(jSONbody,indicatoriRecord){
        jSONbody.forEach(element => {
            console.log('loadJsonBody element: ',element);
            element.tdElements.forEach(subElements => {
                console.log('loadJsonBody subElements: ',subElements);
                if (subElements.apiName && indicatoriRecord != undefined && indicatoriRecord[subElements.apiName] != undefined && indicatoriRecord[subElements.apiName] != null) {
                    subElements.value = indicatoriRecord[subElements.apiName];
                    if (subElements.value < 0 || (!subElements.value === "" && subElements.value.includes('-') && subElements.value.length>1))
                        subElements.style = subElements.style + 'color:red;'
                } else {
                    if (subElements.apiName) //valore mancante
                        subElements.value = '-';
                    else{
                        if(subElements.key != 'td_1'){
                            console.log('SubElement to evaluate: ',subElements.value);
                            let cellValue = subElements.value.replace('{var}','');
                            subElements.value = this.tableValues.get(cellValue);
                            if (subElements.value < 0 || (!subElements.value === "" && subElements.value.includes('-') && subElements.value.length>1))
                                subElements.style = subElements.style + 'color:red;'
                        }
                    }
                }

                if (!subElements.formatted || subElements.value == '-' ) {
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

            });
        });

    }

    loadJsonHeader(jSONhead,recordInfo){
        jSONhead.forEach(element => {
            console.log('element: ',element);
            element.thElements.forEach(subElements => {
                console.log('subElements: ',subElements);
                console.log('recordInfo: ',recordInfo);
                subElements.isText = false;
                if (subElements.apiName && recordInfo[this.recordId] && recordInfo[this.recordId][subElements.apiName]) {
                    subElements.isText = true;
                    subElements.value = recordInfo[this.recordId][subElements.apiName];
                }
                subElements.divElements.forEach(subsubElements => {
                    if (subsubElements.value == 'dati al:'){
                        //subsubElements.value = subsubElements.value + ' ' + this.lastModifiedDate;
                        let currentDate = recordInfo[this.recordId] != undefined ? recordInfo[this.recordId]["LastModifiedDate"] : ''; //Modifica
                        subsubElements.value = subsubElements.value + ' ' + currentDate; //Modifica
                    }
                })
            });
        });
    }


    generateFieldMapping(){

        let objMap = new Map();

        objMap.set("margineIntermediazioneMese",{tipo: "numerico", campoBase: "CRM_MargineIntermediazioneMeseCorrente__c", campoSottrazione:""}) ;
        objMap.set("margineIntermediazioneMeseAP",{tipo: "numerico", campoBase: "CRM_MargineIntermediazioneStessoMeseAP__c", campoSottrazione:""}) ;
        objMap.set("margineIntermediazioneVarMese",{tipo: "percentuale", campoBase: "CRM_MargineIntermediazioneMeseCorrente__c", campoSottrazione:"CRM_MargineIntermediazioneStessoMeseAP__c"}) ;
        objMap.set("margineIntermediazioneFineAp",{tipo: "numerico", campoBase: "CRM_MargineIntermediazioneFineAP__c", campoSottrazione:""}) ;
        objMap.set("margineIntermediazioneVarAP",{tipo: "percentuale", campoBase: "CRM_MargineIntermediazioneMeseCorrente__c", campoSottrazione:"CRM_MargineIntermediazioneFineAP__c"}) ;
        
        objMap.set("margineFinanziarioMese",{tipo: "numerico", campoBase: "CRM_MargineFinanziarioMeseCorrente__c", campoSottrazione:""}) ;
        objMap.set("margineFinanziarioMeseAP",{tipo: "numerico", campoBase: "CRM_MargineFinanziarioStessoMeseAP__c", campoSottrazione:""}) ;
        objMap.set("margineFinanziarioVarMese",{tipo: "percentuale", campoBase: "CRM_MargineFinanziarioMeseCorrente__c", campoSottrazione:"CRM_MargineFinanziarioStessoMeseAP__c"}) ;
        objMap.set("margineFinanziarioFineAp",{tipo: "numerico", campoBase: "CRM_MargineFinanziarioFineAP__c", campoSottrazione:""}) ;
        objMap.set("margineFinanziarioVarAP",{tipo: "percentuale", campoBase: "CRM_MargineFinanziarioMeseCorrente__c", campoSottrazione:"CRM_MargineFinanziarioFineAP__c"}) ;
        
        objMap.set("margineServiziMese",{tipo: "numerico", campoBase: "CRM_MargineServiziMeseCorrente__c", campoSottrazione:""}) ;
        objMap.set("margineServiziMeseAP",{tipo: "numerico", campoBase: "CRM_MargineServiziStessoMeseAP__c", campoSottrazione:""}) ;
        objMap.set("margineServiziVarMese",{tipo: "percentuale", campoBase: "CRM_MargineServiziMeseCorrente__c", campoSottrazione:"CRM_MargineServiziStessoMeseAP__c"}) ;
        objMap.set("margineServiziFineAp",{tipo: "numerico", campoBase: "CRM_MargineServiziFineAP__c", campoSottrazione:""}) ;
        objMap.set("margineServiziVarAP",{tipo: "percentuale", campoBase: "CRM_MargineServiziMeseCorrente__c", campoSottrazione:"CRM_MargineServiziFineAP__c"}) ;
        
        objMap.set("raccoltaComplessivaMese",{tipo: "numerico", campoBase: "CRM_RaccoltaComplessivaMeseCorrente__c", campoSottrazione:""}) ;
        objMap.set("raccoltaComplessivaMeseAP",{tipo: "numerico", campoBase: "CRM_RaccoltaComplessivaStessoMeseAP__c", campoSottrazione:""}) ;
        objMap.set("raccoltaComplessivaVarMese",{tipo: "percentuale", campoBase: "CRM_RaccoltaComplessivaMeseCorrente__c", campoSottrazione:"CRM_RaccoltaComplessivaStessoMeseAP__c"}) ;
        objMap.set("raccoltaComplessivaFineAp",{tipo: "numerico", campoBase: "CRM_RaccoltaComplessivaFineAnnoPrec__c", campoSottrazione:""}) ;
        objMap.set("raccoltaComplessivaVarAP",{tipo: "percentuale", campoBase: "CRM_RaccoltaComplessivaMeseCorrente__c", campoSottrazione:"CRM_RaccoltaComplessivaFineAnnoPrec__c"}) ;
        
        objMap.set("liquiditaMese",{tipo: "numerico", campoBase: "CRM_LiquiditaMeseCorrente__c", campoSottrazione:""}) ;
        objMap.set("liquiditaMeseAP",{tipo: "numerico", campoBase: "CRM_LiquiditaStessoMeseAP__c", campoSottrazione:""}) ;
        objMap.set("liquiditaVarMese",{tipo: "percentuale", campoBase: "CRM_LiquiditaMeseCorrente__c", campoSottrazione:"CRM_LiquiditaStessoMeseAP__c"}) ;
        objMap.set("liquiditaFineAp",{tipo: "numerico", campoBase: "CRM_LiquiditaFineAnnoPrecedente__c", campoSottrazione:""}) ;
        objMap.set("liquiditaVarAP",{tipo: "percentuale", campoBase: "CRM_LiquiditaMeseCorrente__c", campoSottrazione:"CRM_LiquiditaFineAnnoPrecedente__c"}) ;
        
        objMap.set("raccoltaDirettaMese",{tipo: "numerico", campoBase: "CRM_RaccoltaDirettaMeseCorrente__c", campoSottrazione:""}) ;
        objMap.set("raccoltaDirettaMeseAP",{tipo: "numerico", campoBase: "CRM_RaccoltaDirettaStessoMeseAP__c", campoSottrazione:""}) ;
        objMap.set("raccoltaDirettaVarMese",{tipo: "percentuale", campoBase: "CRM_RaccoltaDirettaMeseCorrente__c", campoSottrazione:"CRM_RaccoltaDirettaStessoMeseAP__c"}) ;
        objMap.set("raccoltaDirettaFineAp",{tipo: "numerico", campoBase: "CRM_RaccoltaDirettaFineAP__c", campoSottrazione:""}) ;
        objMap.set("raccoltaDirettaVarAP",{tipo: "percentuale", campoBase: "CRM_RaccoltaDirettaMeseCorrente__c", campoSottrazione:"CRM_RaccoltaDirettaFineAP__c"}) ;
        
        objMap.set("raccoltaAmministrataMese",{tipo: "numerico", campoBase: "CRM_RaccoltaAmministrataMeseCorrente__c", campoSottrazione:""}) ;
        objMap.set("raccoltaAmministrataMeseAP",{tipo: "numerico", campoBase: "CRM_RaccoltaAmministrataStessoMeseAP__c", campoSottrazione:""}) ;
        objMap.set("raccoltaAmministrataVarMese",{tipo: "percentuale", campoBase: "CRM_RaccoltaAmministrataMeseCorrente__c", campoSottrazione:"CRM_RaccoltaAmministrataStessoMeseAP__c"}) ;
        objMap.set("raccoltaAmministrataFineAp",{tipo: "numerico", campoBase: "CRM_RaccoltaAmministrataFineAP__c", campoSottrazione:""}) ;
        objMap.set("raccoltaAmministrataVarAP",{tipo: "percentuale", campoBase: "CRM_RaccoltaAmministrataMeseCorrente__c", campoSottrazione:"CRM_RaccoltaAmministrataFineAP__c"}) ;
        
        objMap.set("raccoltaGestitaMese",{tipo: "numerico", campoBase: "CRM_RaccGestMeseCorrente__c", campoSottrazione:""}) ;
        objMap.set("raccoltaGestitaMeseAP",{tipo: "numerico", campoBase: "CRM_RaccGestStessoMeseAP__c", campoSottrazione:""}) ;
        objMap.set("raccoltaGestitaVarMese",{tipo: "percentuale", campoBase: "CRM_RaccGestMeseCorrente__c", campoSottrazione:"CRM_RaccGestStessoMeseAP__c"}) ;
        objMap.set("raccoltaGestitaFineAp",{tipo: "numerico", campoBase: "CRM_RaccGestFineAP__c", campoSottrazione:""}) ;
        objMap.set("raccoltaGestitaVarAP",{tipo: "percentuale", campoBase: "CRM_RaccGestMeseCorrente__c", campoSottrazione:"CRM_RaccGestFineAP__c"}) ;
        
        objMap.set("polizzaVitaMese",{tipo: "numerico", campoBase: "CRM_PolVitaMeseCorrente__c", campoSottrazione:""}) ;
        objMap.set("polizzaVitaMeseAP",{tipo: "numerico", campoBase: "CRM_PolVitaStessoMeseAP__c", campoSottrazione:""}) ;
        objMap.set("polizzaVitaVarMese",{tipo: "percentuale", campoBase: "CRM_PolVitaMeseCorrente__c", campoSottrazione:"CRM_PolVitaStessoMeseAP__c"}) ;
        objMap.set("polizzaVitaFineAp",{tipo: "numerico", campoBase: "CRM_PolVitaFineAP__c", campoSottrazione:""}) ;
        objMap.set("polizzaVitaVarAP",{tipo: "percentuale", campoBase: "CRM_PolVitaMeseCorrente__c", campoSottrazione:"CRM_PolVitaFineAP__c"}) ;
        
        objMap.set("impieghiMese",{tipo: "numerico", campoBase: "CRM_ImpieghiMeseCorrente__c", campoSottrazione:""}) ;
        objMap.set("impieghiMeseAP",{tipo: "numerico", campoBase: "CRM_ImpieghiStessoMeseAP__c", campoSottrazione:""}) ;
        objMap.set("impieghiVarMese",{tipo: "percentuale", campoBase: "CRM_ImpieghiMeseCorrente__c", campoSottrazione:"CRM_ImpieghiStessoMeseAP__c"}) ;
        objMap.set("impieghiFineAp",{tipo: "numerico", campoBase: "CRM_ImpieghiFineAP__c", campoSottrazione:""}) ;
        objMap.set("impieghiVarAP",{tipo: "percentuale", campoBase: "CRM_ImpieghiMeseCorrente__c", campoSottrazione:"CRM_ImpieghiFineAP__c"}) ;        
        return objMap;
    }

}