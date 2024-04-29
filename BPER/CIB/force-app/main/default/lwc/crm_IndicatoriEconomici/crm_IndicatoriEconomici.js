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

                        /*if(!allAccountIds.includes(value.CRM_Account__c)){
                                let ndgDataRow = {'Id' : value.CRM_Account__c, 'ndgValue' : value.CRM_Account__r.CRM_NDG__c, 'ndg' : value.CRM_Account__r.CRM_NDG__c, "name" : value.CRM_Account__r.Name};
                            dataMap.set(value.CRM_Account__c, ndgDataRow);
                            allAccountIds.push(value.CRM_Account__c);
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
                        console.log('recordInfo getIndicatoriCliente: ', recordInfo);
                        console.log('accountDataMap getIndicatoriCliente: ', this.accountDataMap);
                        let accountMap = this.accountDataMap;
                        let accountArray = this.accountData = []; 
                        let preSelectedArray = this.preSelectedRows = []; 
                        let recordId = this.recordId;
        
                        if (recordInfo){
                            //this.tableData = recordInfo;
                            //Modifica
                                //let idArray = [];  //Modifica
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
                            //Modifica
                                this.indicatoriDataObjMap = recordInfo;
                                console.log('getIndicatoriCliente indicatoriDataObjMap: ',this.indicatoriDataObjMap);
                                if(recordInfo[this.recordId] == undefined){

                                    getIndicatoriPF({accId : this.recordId})
                                    .then(result => {
                                        if (recordInfo){
                                            //this.tableData = recordInfo;
                                                if(recordInfo != {}){
                                                    this.preSelectedRows.push(this.recordId);
                                                    this.indicatoriDataObjMap.push(recordInfo[this.recordId])
                                                }; //Modifica
                                                let idArray = this.preSelectedRows;
                                                console.log('getIndicatoriPF indicatoriDataObjMap: ',this.indicatoriDataObjMap);

                                                this.calculateTableValues(idArray); //Modifica
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
                                    this.calculateTableValues(preSelectedArray); //Modifica
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
        selectedRows.forEach(row => {
            console.log('currentId: ', row);
            if(row.Id == this.recordId)
                found = true;
        });
        if(!found)
            idArray.push((this.recordId));

        for (let i = 0; i < selectedRows.length; i++) {
            idArray.push(selectedRows[i].Id);
        }
        console.log('idArray: ', idArray);

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

        let sumQuotaGiorno;
        let sumQuotaAPP;
        let currentTableValue;

        let currentBaseCalcolo;
        let currentValoreDaSottrarre;

        let erroreConsistenza;
        let recordErrore;

        console.log('crm_IndicatoriEconomici calculateTableValues tableFieldsMap: ',this.tableFieldsMap);
        for (const [key, value] of this.tableFieldsMap.entries()) {
            console.log('crm_IndicatoriEconomici calculateTableValues current key: ',key, 'crm_IndicatoriEconomici calculateTableValues current value: ',value);


            currentTableValue = 0;
            sumQuotaGiorno = 0;
            sumQuotaAPP = 0;

            erroreConsistenza = false;
            recordErrore = {};

            idArray.forEach(element => {

                currentRecord = this.indicatoriDataObjMap[element];
                currentBaseCalcolo = !currentRecord[value.campoBase] ? 0 : currentRecord[value.campoBase];
                currentValoreDaSottrarre = (currentRecord[value.campoSottrazione] != undefined && value.campoSottrazione != "" && currentRecord[value.campoSottrazione] != undefined && currentRecord[value.campoSottrazione] != null)  ? currentRecord[value.campoSottrazione] : 0;


                if(element != this.recordId){

                    currentCointestatari = this.accountDataMap.get(element).numeroCointestatari;

                    //if(value.campoSottrazione === "" || (value.campoSottrazione != "" && currentValoreDaSottrarre != 0)){
                    currentBaseCalcolo = currentBaseCalcolo / currentCointestatari;
                    currentValoreDaSottrarre = currentValoreDaSottrarre / currentCointestatari;

                    sumQuotaGiorno += currentBaseCalcolo;
                    sumQuotaAPP += currentValoreDaSottrarre;
                    /*}else{
                        erroreConsistenza = true;
                        recordErrore = {accountId : element, indicatoriId : currentRecord.Id, variabile: key, checkFields : value.campoBase+', '+value.campoSottrazione};
                        console.log('Consistency Error: ',recordErrore);
                    }*/

                }else{
                    if(value.totale){
                        sumQuotaGiorno += currentBaseCalcolo;
                        sumQuotaAPP += currentValoreDaSottrarre;

                    }                    
                }
            });

                if(idArray.length>0){
                    if(value.tipo == 'percentuale'){
                        currentTableValue = (sumQuotaAPP != 0) ? Math.round( ((sumQuotaGiorno - sumQuotaAPP) / sumQuotaAPP) * 100) : '-';
                    }else{
                        currentTableValue = Math.round(sumQuotaGiorno);
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
                //prime due colonne
                    if (subElements.apiName && indicatoriRecord != undefined && indicatoriRecord[subElements.apiName] != undefined && indicatoriRecord[subElements.apiName] != null) { //modifica
                        subElements.value = indicatoriRecord[subElements.apiName];
                        if (subElements.value < 0 || (!subElements.value === "" && subElements.value.includes('-') && subElements.value.length>1))
                            subElements.style = subElements.style + 'color:red;'
                    } else {
                        if (subElements.apiName) //valore mancante
                            subElements.value = '-';
                        //altre colonne
                        else{
                            if(subElements.key != 'td_1'){
                                let cellValues = subElements.value.split('.');
                                subElements.value = this.tableValues.get(cellValues[1].replace('}',''));
                                if (subElements.value < 0 || (!subElements.value === "" && subElements.value.includes('-') && subElements.value.length>1))
                                    subElements.style = subElements.style + 'color:red;'
                            }
                        }
                    }

                if (!subElements.formatted || subElements.value == '-' || subElements.apiName.includes('Variazione_') || subElements.apiName.includes('CRM_Variazione')) {
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
                subElements.isText = false;
                if (subElements.apiName && recordInfo[this.recordId] != undefined && recordInfo[this.recordId][subElements.apiName]) { //Modifica
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

        objMap.set("raccoltaCoGiorno",{tipo: "numerico", campoBase: "CRM_RaccoltaComplessiva_t_1__c", campoSottrazione:""}) ;
        objMap.set("liquiditaCoGiorno",{tipo: "numerico", campoBase: "CRM_Liquidita_t_1__c", campoSottrazione:""});
        objMap.set("racDirCoGiorno",{tipo: "numerico", campoBase: "CRM_RaccoltaDiretta_t_1__c", campoSottrazione:""});
        objMap.set("racAmmCoGiorno",{tipo: "numerico", campoBase: "CRM_RaccoltaAmministrata_t_1__c", campoSottrazione:""});
        objMap.set("racGestitaCoGiorno",{tipo: "numerico", campoBase: "CRM_RaccoltaGestita_t_1__c", campoSottrazione:""});
        objMap.set("polizzaCoGiorno",{tipo: "numerico", campoBase: "CRM_PolizzeVita_t_1__c", campoSottrazione:""});
        objMap.set("ImpieghiCoGiorno",{tipo: "numerico", campoBase: "CRM_Impieghi_t_1__c", campoSottrazione:""});
        
        objMap.set("raccoltaCoVariazione",{tipo: "percentuale", campoBase: "CRM_RaccoltaComplessiva_t_1__c", campoSottrazione:"CRM_RaccComplFineAPPunt__c"});
        objMap.set("liquiditaCoVariazione",{tipo: "percentuale", campoBase: "CRM_Liquidita_t_1__c", campoSottrazione:"CRM_LiquidFineAPPunt__c"});
        objMap.set("racDirCoVariazione",{tipo: "percentuale", campoBase: "CRM_RaccoltaDiretta_t_1__c", campoSottrazione:"CRM_RaccDirFineAPPunt__c"});
        objMap.set("racAmmCoVariazione",{tipo: "percentuale", campoBase: "CRM_RaccoltaAmministrata_t_1__c", campoSottrazione:"CRM_RaccAmmFineAPPunt__c"});
        objMap.set("racGestitaCoVariazione",{tipo: "percentuale", campoBase: "CRM_RaccoltaGestita_t_1__c", campoSottrazione:"CRM_RaccGestFineAPPunt__c"});
        objMap.set("polizzaCoVariazione",{tipo: "percentuale", campoBase: "CRM_PolizzeVita_t_1__c", campoSottrazione:"CRM_PolVitaFineAPPunt__c"});
        objMap.set("ImpieghiCoVariazione",{tipo: "percentuale", campoBase: "CRM_Impieghi_t_1__c", campoSottrazione:"CRM_ImpieghiFineAPPunt__c"});
        
        objMap.set("raccoltaTotGiorno",{tipo: "numerico", campoBase: "CRM_RaccoltaComplessiva_t_1__c", campoSottrazione:"", totale: true});
        objMap.set("liquiditaTotGiorno",{tipo: "numerico", campoBase: "CRM_Liquidita_t_1__c", campoSottrazione:"", totale: true});
        objMap.set("racDirTotGiorno",{tipo: "numerico", campoBase: "CRM_RaccoltaDiretta_t_1__c", campoSottrazione:"", totale: true});
        objMap.set("racAmmTotGiorno",{tipo: "numerico", campoBase: "CRM_RaccoltaAmministrata_t_1__c", campoSottrazione:"", totale: true});
        objMap.set("racGestitaTotGiorno",{tipo: "numerico", campoBase: "CRM_RaccoltaGestita_t_1__c", campoSottrazione:"", totale: true});
        objMap.set("polizzaTotGiorno",{tipo: "numerico", campoBase: "CRM_PolizzeVita_t_1__c", campoSottrazione:"", totale: true});
        objMap.set("ImpieghiTotGiorno",{tipo: "numerico", campoBase: "CRM_Impieghi_t_1__c", campoSottrazione:"", totale: true});
        
        objMap.set("raccoltaTotVariazione",{tipo: "percentuale", campoBase: "CRM_RaccoltaComplessiva_t_1__c", campoSottrazione:"CRM_RaccComplFineAPPunt__c", totale: true});
        objMap.set("liquiditaTotVariazione",{tipo: "percentuale", campoBase: "CRM_Liquidita_t_1__c", campoSottrazione:"CRM_LiquidFineAPPunt__c", totale: true,});
        objMap.set("racDirTotVariazione",{tipo: "percentuale", campoBase: "CRM_RaccoltaDiretta_t_1__c", campoSottrazione:"CRM_RaccDirFineAPPunt__c", totale: true});
        objMap.set("racAmmTotVariazione",{tipo: "percentuale", campoBase: "CRM_RaccoltaAmministrata_t_1__c", campoSottrazione:"CRM_RaccAmmFineAPPunt__c", totale: true});
        objMap.set("racGestitaTotVariazione",{tipo: "percentuale", campoBase: "CRM_RaccoltaGestita_t_1__c", campoSottrazione:"CRM_RaccGestFineAPPunt__c", totale: true});
        objMap.set("polizzaTotVariazione",{tipo: "percentuale", campoBase: "CRM_PolizzeVita_t_1__c", campoSottrazione:"CRM_PolVitaFineAPPunt__c", totale: true});
        objMap.set("ImpieghiTotVariazione",{tipo: "percentuale", campoBase: "CRM_Impieghi_t_1__c", campoSottrazione:"CRM_ImpieghiFineAPPunt__c", totale: true});     

        return objMap;
    }

}