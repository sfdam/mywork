//Author : Dam Kebe @Lutech
import { LightningElement, api, track } from 'lwc';
//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

//import controller Methods
import init from '@salesforce/apex/MultipleAssignmentController.init';
import loadAssenteNdgList from '@salesforce/apex/MultipleAssignmentController.loadAssenteNdgList';
import checkCointestazione from '@salesforce/apex/MultipleAssignmentController.checkCointestazione';
import loadAssenteMwList from '@salesforce/apex/MultipleAssignmentController.loadAssenteMwList';
import executeAssignmentAssente from '@salesforce/apex/MultipleAssignmentController.executeAssignmentAssente';
import sendMovementRequest from '@salesforce/apex/SpostaNdgIterController.sendMovementRequest';
import createQueues from '@salesforce/apex/SpostaNdgIterController.createQueues';

import Name from '@salesforce/label/c.multipleAssignmentAssente_CLM_Name';
import NDG from '@salesforce/label/c.multipleAssignmentAssente_CLM_NDG';
import NaturaGiuridica from '@salesforce/label/c.multipleAssignmentAssente_CLM_NaturaGiuridica';
import GruppoGestionale from '@salesforce/label/c.multipleAssignmentAssente_CLM_GruppoGestionale';
import StatoCRM from '@salesforce/label/c.multipleAssignmentAssente_StatoCRM';
import NomePortafoglio from '@salesforce/label/c.multipleAssignmentAssente_MwCLM_NomePortafoglio';
import ModelloServizio from '@salesforce/label/c.multipleAssignmentAssente_MwCLM_ModelloServizio';
import Filiale from '@salesforce/label/c.multipleAssignmentAssente_MwCLM_Filiale';
import Referente from '@salesforce/label/c.multipleAssignmentAssente_MwCLM_Referente';


const COLUMNS = [
    {
        label: Name,
        fieldName: 'Name',
        type: 'text'
    },
    {
        label: NDG,
        fieldName: 'PTF_Url',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'CRM_NDG__c' }
        },
    },
    {
        label: NaturaGiuridica,
        fieldName: 'PTF_NaturaGiuridica__c',
        type: 'text'
    },
    {
        label: GruppoGestionale,
        fieldName: 'PTF_GruppoComportamentale__c',
        type: 'text'
     },
    {
        label: StatoCRM,
        fieldName: 'PTF_StatoCRM__c',
        type: 'text'
    }
];

const MWCOLUMNS = [
    {
        label: NomePortafoglio,
        fieldName: 'Name',
        type: 'text',
        cellAttributes:{class:{fieldName: 'typeCSSClass' }}
    },
    {
        label: ModelloServizio,
        fieldName: 'PTF_ModelloDiServizio__c',
        type: 'text'
    },
    {
        label: Filiale,
        fieldName: 'Filiale',
        type: 'text'
    },
    {
        label: Referente,
        fieldName: 'Referente',
        type: 'text'
    }
];
export default class MultipleAssignmentAssente extends NavigationMixin(LightningElement) {

    @api recordId;
    @api defaultLimit;
    @track showNDGs = false;
    @track hasNDGRows = false;
    @track hasMWRows = false;
    @track showAllMwButton = false;
    @track isLoadAll = false;
    @track showMessage = false;
    @track message = '';
    @track lastMessage = '';
    @track ndgList = [];

    @track ndgListComplete = [];
    // @track searchedNome;
    // @track searchedNDG;

    @track selectedNDGs = [];
    //check if needed
    @track selectedNDGRows = [];
    @track searchedNome = '';
    @track searchedNDG = '';
    @track mwList = [];
    @track filteredMwList = [];
    @track mwListCount;
    @track ndgLimit = 50000;
    @track mwLimit = 50000;

    @track portafogliInEvidenzaEligible = [];
    @track portafogliInEvidenzaEligibleIds = [];

    @track ruolo;
    @track mdsPrimario;
    @track filialePrimario;
    @track microportafogliCointestazioniFiliali = [];
    @track hasDifferent;
    @track isAlone;
    @track allInSame = false;

    @track tableTarget = {};

    @track loaded = false;

    columns = COLUMNS;
    mwColumns = MWCOLUMNS;

    mdsConfigurazioniMap = {};
    currentUser = {};
    superUser = false;
    currentPF = {};
    currentContact = {};
    mdsEligible = [];

    @track primari = [];

    //Test Pagination
    @track page = 1;
    @track pageMW = 1;
    perpage = 50;
    @track pages = [];
    @track pagesMW = [];
    set_size = 50;

    connectedCallback(){

        let dataTableGlobalStyle = document.createElement('style');
        dataTableGlobalStyle.innerHTML = `
        .color-green {
            font-weight: 500;
            color: green;
        }
        .no-button {
            text-align: center;
            color: ##1c1f1d;
            font-weight: 800;
            text-transform: uppercase;
        }`;
        document.head.appendChild(dataTableGlobalStyle);
        this.handleInit().then(() => {

            this.loadNDGRecords().then(() => {
    
                this.loaded = true;
            });
        });
    }

    handleInit(){

        return init({
            recordId: this.recordId
        }).then(result => {

            this.mdsConfigurazioniMap = result['mdsConfigurazioniMap'];
            this.currentUser = result['currentUser'];
            this.superUser = this.currentUser.Profilo__c == 'NEC_D.0';
            this.currentContact = result['currentContact'];
            this.currentPF = result['currentPF'];
            for(var mapKey in this.mdsConfigurazioniMap){

                this.mdsEligible.push(mapKey.split('_')[1]);
            }
            console.log('DK mdsEligible: ' + JSON.stringify(this.mdsEligible));
        });
    }

    loadNDGRecords(){
        
        try{
            return loadAssenteNdgList({
                recordId: this.recordId,
                pagesize: this.ndgLimit
            })
            .then(result => {

                this.showNDGs = true;
                console.log(result);

                result["ndgList"].forEach(element => {
                    
                    element.PTF_Url = '/' + element.Id;
                });
                this.ndgListComplete = result["ndgList"];
                this.ndgList = this.ndgListComplete;
                this.setPages(this.ndgList);
                if(this.ndgList.length > 0){

                    this.hasNDGRows = true;
                }else{

                    this.hasNDGRows = false;
                }
                console.log('ndgList: ' + JSON.stringify(this.ndgList));
            })
            .catch(error => { 
                console.log('loadNDGRecords.loadAssenteNdgList.error: ' + JSON.stringify(error));
            })
        }catch(error){

            console.log('loadNDGRecords.error: ' + error);
        }
    }

    loadMWRecords(){
        
        console.log('DK loadMWRecords ruolo: ' + this.ruolo);
        console.log('DK loadMWRecords mdsPrimario: ' + this.mdsPrimario);
        console.log('DK loadMWRecords filialePrimario: ' + this.filialePrimario);
        console.log('DK loadMWRecords allInSame: ' + this.allInSame);
        console.log('DK loadMWRecords mwOffset: ' + this.mwOffset);
        console.log('DK loadMWRecords limit: ' + this.mwLimit);
        
        try{
            console.log('this.selectedNDGs[0]: ' + JSON.stringify(this.selectedNDGs[0]));
            return loadAssenteMwList({
                serializedNdg: JSON.stringify(this.selectedNDGs[0]),
                mdsEligible: this.mdsEligible,
                isLoadAll: this.isLoadAll,
                offset: this.mwOffset,
                pagesize: this.mwLimit,
                ruoloVar: this.ruolo,
                filialePrimarioVar: this.filialePrimario,
                allInSameVar: this.allInSame,
                currentPF: this.currentPF,
                microportafogliCointestazioniFilialiVar: this.microportafogliCointestazioniFiliali 
            })
            .then(result => {

                console.log('result: ' + JSON.stringify(result));
                try {
                    
                    let newValueList = [];
                    let oldListId = this.mwList.map(item => item.Id);
                    console.log('oldListId: ' + JSON.stringify(oldListId));
                    
                    console.log('newValueList: ' + JSON.stringify(newValueList));
                    this.mwList = result["mwList"];
                    this.mwListCount = result["mwListCount"];
                    
                    this.mwList.forEach(element => {

                        this.extendMW(element);                
                    });
                    this.filteredMwList = this.mwList;
                    if(this.filteredMwList.length == 0 &&
                        this.portafogliInEvidenzaEligible.length == 0 && 
                        (this.ruolo == 'primario' ||
                        this.ruolo == 'cointestazione')){
    
                        this.message = 'Effettuare un controllo nei collegamenti anagrafici per vedere eventuali incogruenze da sanare prima di eseguire lo spostamento desiderato.';
                        this.lastMessage = '';
                    }
                    this.setPagesMW(this.filteredMwList);
                   
                    console.log('mwList: ' + JSON.stringify(this.mwList));
                } catch (error) {
                    
                    console.log('loadMWRecords.loadAssenteMwList.then.error: ' + error);
                }
            })
            .catch(error => { 
                console.log('loadMWRecords.loadAssenteMwList.error: ' + JSON.stringify(error));
            })
        }catch(error){

            console.log('loadMWRecords.error: ' + error);
        }
        
    }

    extendMW(element){
        
        if(this.portafogliInEvidenzaEligibleIds.includes(element.Id)){
                
            element.typeCSSClass = 'color-green';
        }

        if(!element.PTF_Pool__c){

            if(element.Backup_Assignments__r){
    
                let nomiReferenti = [];
                // let referenteId = '';
                element.Backup_Assignments__r.forEach(assignment => {
    
                    if(assignment.PTF_Gestore__r){
    
                        nomiReferenti.push(assignment.PTF_Gestore__r.Name);
                        // referenteId = assignment.PTF_Gestore__c;
                    }
                });
    
                if(nomiReferenti.length > 0){
                    
                    element.Referente = nomiReferenti.join(',');
                    element.ReferenteId = element.Backup_Assignments__r[0].PTF_Gestore__c;
                }else{
    
                    element.Referente = 'Non Assegnato';
                    element.ReferenteId = '';
                }
            }else{
    
                element.Referente = 'Non Assegnato';
                element.ReferenteId = '';
            }
        }else{

            element.Referente = 'PTF in Pool';
            element.ReferenteId = '';
        }
        element.Filiale = element.PTF_Filiale__r.Name;
    }

    handleNextPressed() {
        
        try {
            
            this.loaded = false;
            console.log('handleNextPressed Start');
            this.selectedNDGs = this.template.querySelector("[data-item='ndgTable']").getSelectedRows();
            if(this.selectedNDGs.length > 0){

                checkCointestazione({
                    currentNDG: this.selectedNDGs[0],
                    microWalletId: this.recordId,
                    recordTypeDevName: this.selectedNDGs[0].RecordType.DeveloperName,
                    currentPF: this.currentPF
                }).then(result =>{
                    
                    console.log('checkCointestazione.result: ' + JSON.stringify(result));
                    if(result.errorMessage){
                        this.loaded = true;
                        this.dispatchToast('Warning!',
                        result.errorMessage,
                                'warning');
                        console.log('handleAssignNDGs End');
                    }else{

                        this.mwOffset = 0;
                        this.isInList = result['isInList'];
                        this.ruolo = result['ruolo'];
                        this.mdsPrimario = result['mdsPrimario'];
                        this.filialePrimario = result['filialePrimario'];
                        this.hasDifferent = result['hasDifferent'];
                        this.isAlone = result['isAlone'];
                        this.microportafogliCointestazioniFiliali = result['microportafogliCointestazioniFiliali'];
                        this.allInSame = false;
                        this.portafogliInEvidenzaEligible = [];
                        this.portafogliInEvidenzaEligibleIds = [];
                        if(result['portafogliInEvidenza']){
            
                            if(result['portafogliInEvidenza'].length > 0){
                                
                                this.portafogliInEvidenzaEligible = result['portafogliInEvidenza'];
                                this.portafogliInEvidenzaEligibleIds = this.portafogliInEvidenzaEligible.map(item => item.Id);
                                this.portafogliInEvidenzaEligible.forEach(element => {
    
                                    this.extendMW(element);
                                });
                            }
        
                            if(this.ruolo == 'primario'){
            
                                this.showMessage = true;
                                this.message = "Al fine di sanare l’anomalia esistente, In evidenza i portafogli delle Cointestazioni non nello stesso microportafoglio del primario, se idonei.";
                                // this.message = "L'ATTRIBUZIONE DEL PORTAFOGLIO EVIDENZIATO PERMETTERA' DI SANARE L'ANOMALIA ESISTENTE";
                                this.lastMessage = '';
                            }else if(this.ruolo == 'cointestazione'){
            
                                this.showMessage = true;
                                this.message = "Al fine di sanare l'anomalia esistente, spostamento consentito solo verso il Portafoglio del Primario (se idoneo) o la sua filiale";
                                this.lastMessage = "Alternativamente, spostare verso portafogli con modello di servizio Consulenti Finanziari."
                                // this.message = "L'ATTRIBUZIONE DEL PORTAFOGLIO EVIDENZIATO PERMETTERA' DI SANARE L'ANOMALIA ESISTENTE";
                            }
                        }else{
                            
                            if(this.ruolo == 'primario'){
                                
                                this.allInSame = this.hasDifferent ? false : true;
                                this.showMessage = this.allInSame ? true : false;
                                this.message = this.showMessage ? this.isAlone ? "A causa delle anomalie sulla portafogliazione delle cointestazioni per cui l’NDG è Primario, lo spostamento è consentito solo verso microportafogli con MDS Consulenti Finanziari." 
                                : "Spostando l’NDG, si sposteranno tutte le Cointestazioni per cui è primario disponibili nello stesso microportafoglio." : "";
                                this.lastMessage = '';
                            }else if(this.ruolo == 'cointestazione'){
            
                                this.allInSame = true;
                                this.showMessage = true;
                                this.message = "Spostamento consentito solo verso microportafogli con MDS Consulenti Finanziari.";
                                this.lastMessage = "Per tutti gli altri, procedere con lo spostamento contestuale partendo dall’NDG primario.";
                            }else if(this.ruolo == 'cointestatario'){
    
                                this.allInSame = this.hasDifferent ? false : true;
                                this.showMessage = this.allInSame ? true : false;
                                this.message = this.showMessage ? "Presenza di anomalia 188 e CO. Valutare intervento di modifica in Anagrafe (modifica 188)." : "";
                                this.lastMessage = this.showMessage ? "Spostamento consentito solo verso Consulenti Finanziari": "";
                            }
                        }
                        this.loadMWRecords().then(() =>{
                            
                            this.template.querySelector("[data-item='searchedNome']").disabled = true;
                            this.template.querySelector("[data-item='searchedNDG']").disabled = true;
                            this.showNDGs = false;
                            this.loaded = true;
                        });
                    }
                    console.log('handleAssignNDGs End');
                }).catch( err =>{

                    console.log('handleNextPressed.error: ', err);
                });
            }else{
    
                this.dispatchToast('Warning!',
                                'Selezionare uno tra le opzioni disponibili',
                                'warning');
                console.log('handleAssignNDGs End');
            } 
        } catch (error) {
            
            console.log('handleNextPressed.error: ' + error);
        }
    }

    handleWMRowSelection(event){
        
        const selectedRows = event.detail.selectedRows;
        
        if(this.ruolo == 'primario' && !this.isAlone){
            
            selectedRows.forEach(element => {
                
                if(this.portafogliInEvidenzaEligibleIds.includes(element.Id)){
                    
                    this.lastMessage = "Spostando l’NDG, si sposteranno tutte le Cointestazioni per cui è primario disponibili nello stesso microportafoglio.";
                }else{
                    
                    this.lastMessage = '';
                }
            });
        }
    }

    handleAssignNDGs() {
        
        try {
            this.loaded = false;
            console.log('handleAssignNDGs Start');
            var mwSelected = this.template.querySelector("[data-item='mwTable']").getSelectedRows();
            console.log('mwSelected: ' + JSON.stringify(mwSelected));
            let ndgWithIter = [];
            let ndgIterMap = {};
            let ndgWithoutIter = [];
            let subjectMap = {};
            let keyMap = {};
            this.primari = [];
            if(mwSelected.length > 0){
                
                if(this.ruolo == 'primario' && mwSelected[0].PTF_ModelloDiServizio__c != 'Consulenti Finanziari'){

                    this.primari.push(this.selectedNDGs[0].Id);
                }
                    
                if(this.superUser){

                    var params = {
                        ndg: this.selectedNDGs[0].Id,
                        mwOrigine: this.recordId,
                        ruolo: this.ruolo,
                        moveAll: mwSelected[0].PTF_ModelloDiServizio__c != 'Consulenti Finanziari',
                        portafoglioDiPartenza: this.recordId,
                        mwId: mwSelected[0].Id
                    }
                    executeAssignmentAssente({
                        params : JSON.stringify(params)
                    }).then(data => {
                        this.loaded = true;
                        const toastEvent = new ShowToastEvent({
                            title: "Success!",
                            message: "NDG assegnato correttamente!!",
                            variant: "success"
                        });
                        this.dispatchEvent(toastEvent);
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.recordId,
                                actionName: 'view'
                            }
                        });
                    }).catch(error => {
                        
                        this.dispatchToast('Error!',
                                    'Purtroppo l\'operazione non è andata a buon fine, conatta il tuo amministratore di sistema.',
                                    'error');
                        console.log('Error: ' + error);
                        console.log('handleAssignNDGs End');
                    });
                    console.log('DK NO ITER');
                }else{

                    let configurationMap = {};

                    let mapKey = this.checkEligible(this.selectedNDGs[0], mwSelected[0]);
                    
                    if(this.mdsConfigurazioniMap[mapKey]){
                        
                        configurationMap = this.mdsConfigurazioniMap;
                    }else if(this.filialeConfigurazioniMap[mapKey]){
        
                        configurationMap = this.filialeConfigurazioniMap;
                    }else if(this.filialeMDSConfigurazioniMap[mapKey]){
        
                        configurationMap = this.filialeMDSConfigurazioniMap;
                    }else if(this.referentiConfigurazioniMap[mapKey]){
        
                        configurationMap = this.referentiConfigurazioniMap;
                    }
                    
                    console.log('DK mapKey: ' + mapKey);
                    console.log('DK configurationMap: ' + JSON.stringify(configurationMap));
        
                    if(configurationMap[mapKey]){
                        
                        console.log('DK IterApprovativo: ' + configurationMap[mapKey].Iter_Approvativo__c);
                            
                        console.log('SONO QUA2');
                        if(configurationMap[mapKey].Iter_Approvativo__c){
                            
                            console.log('SONO QUA3');
                            subjectMap[this.selectedNDGs[0].Id] = configurationMap[mapKey].MasterLabel;
                            keyMap[this.selectedNDGs[0].Id] = mapKey;
        
                            const noteValid = [...this.template.querySelectorAll("[data-item='note']")]
                            .reduce((validSoFar, inputCmp) => {
                                        inputCmp.reportValidity();
                                        return validSoFar && inputCmp.checkValidity();
                            }, true);
        
                            if(!noteValid){
        
                                throw 'Valorizzare il campo \'Motivazioni\' prima di continuare.';
                            }
                            console.log('DK noteValid: ' + noteValid);
                            
                            console.log('DK finestra: ' + configurationMap[mapKey].Finestra_Temporale__c);
                            if(configurationMap[mapKey].Finestra_Temporale__c){
        
                                let today = new Date();
                                let startDate;
                                let endDate;
                                let isSet = false;
                                if(Boolean(ndg.PTF_Portafoglio__r.PTF_Filiale__r.PTF_DowngradeReqStartDate__c) &&
                                Boolean(ndg.PTF_Portafoglio__r.PTF_Filiale__r.PTF_DowngradeReqEndDate__c)){
    
                                    startDate = new Date(ndg.PTF_Portafoglio__r.PTF_Filiale__r.PTF_DowngradeReqStartDate__c);
                                    endDate = new Date(ndg.PTF_Portafoglio__r.PTF_Filiale__r.PTF_DowngradeReqEndDate__c);
                                    isSet = true;
                                }
                                
                                if(Boolean(ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__r) && !isSet){
                                    
                                    if(Boolean(ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c) &&
                                    Boolean(ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c)){

                                        startDate = new Date(ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c);
                                        endDate = new Date(ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c);
                                        isSet = true;
                                    }
                                }
                                
                                if(Boolean(ndg.PTF_Portafoglio__r.PTF_Banca__r) && !isSet){
                                    
                                    if(Boolean(ndg.PTF_Portafoglio__r.PTF_Banca__r.PTF_DowngradeReqStartDate__c) &&
                                    Boolean(ndg.PTF_Portafoglio__r.PTF_Banca__r.PTF_DowngradeReqEndDate__c)){

                                        startDate = new Date(ndg.PTF_Portafoglio__r.PTF_Banca__r.PTF_DowngradeReqStartDate__c);
                                        endDate = new Date(ndg.PTF_Portafoglio__r.PTF_Banca__r.PTF_DowngradeReqEndDate__c);
                                        isSet = true;
                                    }
                                }
                                
                                if(!isSet){
    
                                    throw "Non sei in una finestra temporale valida per eseguire questo spostamento";
                                }
    
                                if(today < startDate||
                                    today > endDate){
        
                                    throw "Non sei in una finestra temporale valida per eseguire questo spostamento";
                                }
                            }
    
                            ndgIterMap[this.selectedNDGs[0].Id] = configurationMap[mapKey];
                            ndgWithIter.push(this.selectedNDGs[0]);
                            console.log('DK ndgWithIter:', ndgWithIter);
                            console.log('DK ndgWithoutIter:', ndgWithoutIter);
                            if(ndgWithIter.length > 0){

                                this.handleCreateQueues(ndgWithIter, ndgIterMap, mwSelected[0], subjectMap, keyMap, true);
                            }  
                        }else{
                            
                            var params = {
                                ndg: this.selectedNDGs[0].Id,
                                mwOrigine: this.recordId,
                                ruolo: this.ruolo,
                                moveAll: mwSelected[0].PTF_ModelloDiServizio__c != 'Consulenti Finanziari',
                                portafoglioDiPartenza: this.recordId,
                                mwId: mwSelected[0].Id
                            }
                            executeAssignmentAssente({
                                params : JSON.stringify(params)
                            }).then(data => {
                                this.loaded = true;
                                const toastEvent = new ShowToastEvent({
                                    title: "Success!",
                                    message: "NDG assegnato correttamente!!",
                                    variant: "success"
                                });
                                this.dispatchEvent(toastEvent);
                                this[NavigationMixin.Navigate]({
                                    type: 'standard__recordPage',
                                    attributes: {
                                        recordId: this.recordId,
                                        actionName: 'view'
                                    }
                                });
                            }).catch(error => {
                                
                                this.dispatchToast('Error!',
                                            'Purtroppo l\'operazione non è andata a buon fine, conatta il tuo amministratore di sistema.',
                                            'error');
                                console.log('Error: ' + error);
                                console.log('handleAssignNDGs End');
                            });
                            console.log('DK NO ITER');
                        }
                    }else{
        
                        throw "Casistica non configurata, contattare l'amministratore di sistema!!";
                    }
                }             
            } else{
    
                throw 'Selezionare uno tra le opzioni disponibili';
            } 
        } catch (error) {
            
            this.dispatchToast('Warning!',
                                error,
                                'warning');
            console.log('handleAssignNDGs.error: ' + error);
            this.loaded = true;
        }
    }

    handleCreateQueues(ndgWithIter, ndgIterMap, selectedMw, subjectMap, keyMap, hasIter){

        return createQueues({
            accountList: ndgWithIter,
            ndgIterMap: ndgIterMap,
            portafoglioDiPartenza: this.currentPF,
            portafoglioDiDestinazione: selectedMw,
            hasIter: hasIter,
            process: ''
        }).then(result => {

            console.log('DK createQueues.result: ' + JSON.stringify(result));
            let parsedResult = {};
            parsedResult = JSON.parse(JSON.parse(result));
            console.log('DK createQueues.parsedResult: ', parsedResult);
            console.log('DK createQueues.accountWorkOrderKeyMap: ', parsedResult['accountWorkOrderKeyMap']);
            Object.keys(ndgIterMap).map(function(key, index) {
                
                let newValue = ndgIterMap[key].Tipo_di_Spostamento__c; 
                ndgIterMap[key] = newValue;
            });
            console.log('DK ndgIterMap: ' + JSON.stringify(ndgIterMap));
            this.handleSendRequest(ndgWithIter, ndgIterMap, selectedMw, subjectMap, keyMap, parsedResult['accountWorkOrderKeyMap'], hasIter ? parsedResult['woStepMap'] : {}, hasIter).then(() => {
                        
                this.loaded = true;
            });
        }).catch(error =>{

            console.log('DK error: ' + JSON.stringify(error));
            console.log('DK error: ' + error);
            const toastEvent = new ShowToastEvent({
                title: "Error!",
                message: error.body.message,
                variant: "error"
            });
            this.dispatchEvent(toastEvent);
            this.loaded = true;
        });
    }

    handleSendRequest(ndgWithIter, ndgIterTypeMap, selectedMw, subjectMap, keyMap, accountWorkOrderKeyMap, woStepMap, hasIter){

        try{
            
            return sendMovementRequest({portafoglioDestinazione: selectedMw.Id, 
                ndgList: ndgWithIter, 
                ndgIterTypeMap: ndgIterTypeMap, 
                subjectMap: subjectMap, 
                note: this.note, 
                configurationKeyMap: keyMap, 
                primari: this.primari, 
                accountKeyMap: accountWorkOrderKeyMap, 
                woStepMap: woStepMap, 
                ruolo: this.ruolo, 
                gruppoFinanziarioId: '', 
                recordId: this.selectedNDGs[0].Id, 
                referente: selectedMw.Referente, 
                hasIter: hasIter,
                process: '',
                motivazione: '',
                lineItemIter: hasIter
            }).
            then(() => {

                const toastEvent = new ShowToastEvent({
                    title: "Success!",
                    message: "Richiesta di spostamento inoltrata correttamente!!",
                    variant: "success"
                });
                this.dispatchEvent(toastEvent);
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.recordId,
                        actionName: 'view'
                    }
                });
            }).
            catch(error => {

                console.log('DK error: ' + JSON.stringify(error));
                const toastEvent = new ShowToastEvent({
                    title: "Error!",
                    message: error.body.message,
                    variant: "error"
                });
                this.dispatchEvent(toastEvent);
            });
            
        }catch(error){

            console.log('DK handleSendRequest.error: ' + error);
        }
    }

    handlePreviousSelected(){

        console.log('handlePreviousSelected Start');
        this.isLoadAll = false;
        this.showMessage = false;
        this.showAllMwButton = false;
        this.mwList = [];
        var selectedRows = this.selectedNDGs.map(item => item.Id);
        this.selectedNDGRows = selectedRows;
        this.showNDGs = true;
    }

    checkEligible(ndg, portafoglio){
       
        let startMDS = ndg.PTF_Portafoglio__r.PTF_ModelloDiServizio__c;
        let startFiliale = ndg.PTF_Filiale__c;
        let startFilialeBranch = ndg.PTF_Filiale__r.PTF_BranchTypeDesc__c;
        let endMDS = portafoglio.PTF_ModelloDiServizio__c;
        let endFiliale = portafoglio.PTF_Filiale__c;
        let endFilialeBranch = portafoglio.PTF_Filiale__r.PTF_BranchTypeDesc__c;
        // 
        let configurationKey1 = '';
        // 
        let configurationKey2 = '';
        // 
        let configurationKey3 = '';
        // 
        let configurationKey4 = '';
        // 
        let configurationKey5 = '';
        //
        let configurationKey6 = '';
        //
        let configurationKey7 = '';
        //
        let configurationKey8 = '';

        if(startMDS != endMDS){
            configurationKey2 = startMDS + '_' + endMDS;
        }
        
        let mmPartenza = Boolean(ndg.PTF_Portafoglio__r.PTF_Capofila__c) ? ndg.PTF_Portafoglio__r.PTF_Capofila__c : ndg.PTF_Portafoglio__r.PTF_Filiale__c;
        let mmDestinazione = Boolean(portafoglio.PTF_Capofila__c) ? portafoglio.PTF_Capofila__c : portafoglio.PTF_Filiale__c;
        console.log('DK this.currentPF.ReferenteId: ' + this.currentPF.ReferenteId);
        console.log('DK portafoglio.ReferenteId: ' + portafoglio.ReferenteId);
        let sameReferente = (this.currentPF.ReferenteId != '' && portafoglio.ReferenteId != '') && this.currentPF.ReferenteId == portafoglio.ReferenteId ? 'true' : 'false';
        let sameMicroMercato = mmPartenza === mmDestinazione ? 'true' : 'false';
        let sameArea = (Boolean(ndg.PTF_Portafoglio__r.PTF_Area__c) && Boolean(portafoglio.PTF_Area__c)) && (ndg.PTF_Portafoglio__r.PTF_Area__c === portafoglio.PTF_Area__c) ? 'true' : 'false';
        let sameDirReg;
        if(portafoglio.PTF_Banca__r.FinServ__BankNumber__c == '01015'){

            sameDirReg = (ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__c === portafoglio.PTF_DirezioneRegionale__c) ? 'true' : 'false';
        }else{

            sameDirReg = (Boolean(ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__c) && Boolean(portafoglio.PTF_DirezioneRegionale__c)) && (ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__c === portafoglio.PTF_DirezioneRegionale__c) ? 'true' : 'false';
        }
        if(startFiliale != endFiliale ||
            startFilialeBranch != endFilialeBranch){
            
            if(Boolean(configurationKey2)){

                configurationKey2 = configurationKey2 + '_';
            }else{

                configurationKey2 = '';
                configurationKey7 = startFilialeBranch + '_' + endFilialeBranch + '_' + startMDS + '_' + sameReferente + '_' + sameMicroMercato + '_' + sameArea + '_' + sameDirReg;
            }
            configurationKey4 = configurationKey2 == '' ?
                                configurationKey2 + startFilialeBranch + '_' + 'TUTTE' + '_' + startMDS + '_' + sameMicroMercato + '_' + sameArea + '_' + sameDirReg :
                                configurationKey2 + startFilialeBranch + '_' + endFilialeBranch + '_' + sameMicroMercato + '_' + sameArea + '_' + sameDirReg;

            configurationKey2 = configurationKey2 == '' ?
                                configurationKey2 + startFilialeBranch + '_' + endFilialeBranch + '_' + startMDS + '_' +  sameMicroMercato + '_' + sameArea + '_' + sameDirReg : 
                                configurationKey2 + startFilialeBranch + '_' + endFilialeBranch + '_' + sameMicroMercato + '_' + sameArea + '_' + sameDirReg;
                                
        }else{

            if(Boolean(configurationKey2)){

                configurationKey6 = configurationKey2 + '_' + startFilialeBranch + '_' + endFilialeBranch;
            }
        }

        if(!Boolean(configurationKey2)){

            configurationKey2 = startMDS + '_' + endMDS;
        }

        configurationKey1 = configurationKey2;
        configurationKey3 = configurationKey2;
        configurationKey5 = configurationKey4;
            
        configurationKey1 = configurationKey1 + '_' + startFilialeBranch;
        configurationKey8 = configurationKey1;

        if(Boolean(portafoglio.PTF_Banca__r)){

            configurationKey4 = configurationKey4 + '_' + portafoglio.PTF_Banca__r.FinServ__BankNumber__c;
            configurationKey1 = configurationKey1 + '_' + portafoglio.PTF_Banca__r.FinServ__BankNumber__c;
            configurationKey2 = configurationKey2 + '_' + portafoglio.PTF_Banca__r.FinServ__BankNumber__c;
            configurationKey6 = configurationKey6 + '_' + portafoglio.PTF_Banca__r.FinServ__BankNumber__c;
            configurationKey7 = configurationKey7 + '_' + portafoglio.PTF_Banca__r.FinServ__BankNumber__c;
        }
        configurationKey3 = configurationKey3 + '_TUTTE';
        configurationKey5 = configurationKey5 + '_TUTTE';
        configurationKey8 = configurationKey8 + '_TUTTE';
        let configurationMap;

        if(this.mdsConfigurazioniMap[configurationKey2] || this.mdsConfigurazioniMap[configurationKey3] || this.mdsConfigurazioniMap[configurationKey1] || this.mdsConfigurazioniMap[configurationKey6]){
            
            configurationMap = this.mdsConfigurazioniMap;
        }else if(this.filialeConfigurazioniMap[configurationKey2] || this.filialeConfigurazioniMap[configurationKey3] || this.filialeConfigurazioniMap[configurationKey1] || this.filialeConfigurazioniMap[configurationKey4] || this.filialeConfigurazioniMap[configurationKey7] || this.filialeConfigurazioniMap[configurationKey5]){

            configurationMap = this.filialeConfigurazioniMap;
        }else if(this.filialeMDSConfigurazioniMap[configurationKey2] || this.filialeMDSConfigurazioniMap[configurationKey3] || this.filialeMDSConfigurazioniMap[configurationKey1]){

            configurationMap = this.filialeMDSConfigurazioniMap;
        }else if(this.referentiConfigurazioniMap[configurationKey2] || this.referentiConfigurazioniMap[configurationKey3] || this.referentiConfigurazioniMap[configurationKey1] || this.referentiConfigurazioniMap[configurationKey8]){

            configurationMap = this.referentiConfigurazioniMap;
        }
        
        if(configurationMap){

            let mapKey = "";
            if(configurationMap[configurationKey1]){

                mapKey = configurationKey1;
            }else if(configurationMap[configurationKey8]){
                
                mapKey = configurationKey8;
            }else if(configurationMap[configurationKey6]){
                
                mapKey = configurationKey6;
            }else if(configurationMap[configurationKey7]){
                
                mapKey = configurationKey7;
            }else if(configurationMap[configurationKey2]){
                
                mapKey = configurationKey2;
            }else if(configurationMap[configurationKey4]){

                mapKey = configurationKey4;
            }else if(configurationMap[configurationKey3]){
                
                mapKey = configurationKey3;
            }else {

                mapKey = configurationKey5;
            }
            console.log('DK mapKey: ' + mapKey);

            return mapKey;
        }else{
            
            return null;
        }
    }

    dispatchToast(title, message, variant){

        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }    

    handleAvanti(){
        ++this.page;
    }
    handleIndietro(){
        --this.page;
    }

    handleAvantiMW(){
        ++this.pageMW;
    }
    handleIndietroMW(){
        --this.pageMW;
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
        let mwToDisplay = this.ndgList.slice(startIndex,endIndex);
        return mwToDisplay;
    }

    pageDataMW = ()=>{
        let page = this.pageMW;
        let perpage = this.perpage;
        let startIndex = (page*perpage) - perpage;
        let endIndex = (page*perpage);
        let mwToDisplay = this.mwList.slice(startIndex,endIndex);
        let mwToDisplayIdList = mwToDisplay.map(item => item.Id);
        this.portafogliInEvidenzaEligible.forEach(portafoglio => {

            console.log('isEligible');
            if(!mwToDisplayIdList.includes(portafoglio.Id)){
                
                console.log('isFirst');
                mwToDisplay.unshift(portafoglio);
            }
        });
        return mwToDisplay;
    }

    setPages = (data)=>{
        this.pages = [];
        let numberOfPages = Math.ceil(data.length / this.perpage);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
        console.log('DK this.pages: ' + this.pages);
    }
    
    setPagesMW = (data)=>{
        this.pagesMW = [];
        let numberOfPages = Math.ceil(data.length / this.perpage);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pagesMW.push(index);
        }
        console.log('DK this.pages: ' + this.pagesMW);
    }  
    
    get disabledButtonIndietro(){
        return this.page === 1;
    }
    
    get disabledButtonAvanti(){
        return this.page === this.pages.length || this.ndgList.length === 0
    }

    get disabledButtonIndietroMW(){
        return this.pageMW === 1;
    }
    
    get disabledButtonAvantiMW(){
        return this.pageMW === this.pagesMW.length || this.mwList.length === 0
    }

    get currentPageData(){
        return this.pageData();
    }

    get currentPageDataMW(){
        return this.pageDataMW();
    }

    handleNDGReset(){
        this.searchedNome = '';
        this.searchedNDG = '';
        this.ndgList = this.ndgListComplete; 
        this.setPages(this.ndgList);
    }

    handleNDGSearch(){
        this.ndgList = [];
        this.page = 1;
        for(var i in this.ndgListComplete){

            if(Boolean(this.searchedNome)){

                if(!this.ndgListComplete[i].Name.toLowerCase().includes(this.searchedNome.toLowerCase()))continue;
            }
            if(Boolean(this.searchedNDG)){

                if(!this.ndgListComplete[i].CRM_NDG__c.toLowerCase().includes(this.searchedNDG.toLowerCase()))continue;
            }
            this.ndgList.push(this.ndgListComplete[i]);
        }
        this.setPages(this.ndgList);
    }

    handleFilter(event){

        console.log('DK handleFilter Started');
        if(event.target.name == 'searchedNome'){
            this.searchedNome = event.target.value;
        }else if(event.target.name == 'searchedNDG'){
            
            this.searchedNDG = event.target.value;
        }
    }
}