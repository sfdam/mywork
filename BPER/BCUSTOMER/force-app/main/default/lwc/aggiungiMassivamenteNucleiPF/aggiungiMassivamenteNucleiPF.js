import { LightningElement, api, track} from 'lwc';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { NavigationMixin } from 'lightning/navigation';


import getUserInfo from '@salesforce/apex/SV_Utilities.getUserInfo';
import init from '@salesforce/apex/AggiungiMassivamenteNucleiController.init';
import loadMwList from '@salesforce/apex/AggiungiMassivamenteNucleiController.loadMwList';
import loadNdgList from '@salesforce/apex/AggiungiMassivamenteNucleiController.loadNdgList';
import moveNdgsToWallet from '@salesforce/apex/AggiungiMassivamenteNucleiController.moveNdgsToWallet';
import createQueues from '@salesforce/apex/SpostaNdgIterController.createQueues';
import sendMovementRequest from '@salesforce/apex/SpostaNdgIterController.sendMovementRequest';

import NDG from '@salesforce/label/c.aggiungiMassivamenteNucleiPF_CLM_NDG';
import Nominativo from '@salesforce/label/c.aggiungiMassivamenteNucleiPF_CLM_Nominativo';
import Caponucleo from '@salesforce/label/c.aggiungiMassivamenteNucleiPF_CLM_Caponucleo';
import NaturaGiuridica from '@salesforce/label/c.aggiungiMassivamenteNucleiPF_CLM_NaturaGiuridica';
import Patrimonio from '@salesforce/label/c.aggiungiMassivamenteNucleiPF_CLM_Patrimonio';
import Utilizzato from '@salesforce/label/c.aggiungiMassivamenteNucleiPF_CLM_Utilizzato';
import MicroPortafoglio from '@salesforce/label/c.aggiungiMassivamenteNucleiPF_CLM_MicroPortafoglio';
import ModelloServizio from '@salesforce/label/c.aggiungiMassivamenteNucleiPF_CLM_ModelloServizio';
import Filiale from '@salesforce/label/c.aggiungiMassivamenteNucleiPF_CLM_Filiale';
import Referente from '@salesforce/label/c.aggiungiMassivamenteNucleiPF_CLM_Referente';


const ndgcolumns = [
    { label: NDG, fieldName: 'PTF_Url', type: 'url',
    cellAttributes:{ iconName: { fieldName: 'provenanceIconName' } },
        typeAttributes: {
            label: { fieldName: 'CRM_NDG__c' }
        },
        hideDefaultActions: "true"},
    { label: Nominativo, fieldName: 'Name', type: 'text', hideDefaultActions: "true", sortable: "true"},
    { label: Caponucleo, fieldName: '', type: 'Boolean', hideDefaultActions: "true", cellAttributes: {
        iconName: { fieldName: 'PTF_IsCaponucleoIcon' },
        iconPosition: 'left'
    }},
    { label: NaturaGiuridica, fieldName: 'PTF_NaturaGiuridica__c', type: 'text', hideDefaultActions: "true"},
    { label: Patrimonio, fieldName: 'PTF_Patrimonio__c', type: 'text', hideDefaultActions: "true"},
    { label: Utilizzato, fieldName: 'PTF_Utilizzato__c', type: 'text', hideDefaultActions: "true"}
];

const mwColumns = [
    {
        label: MicroPortafoglio,
        fieldName: 'Name',
        type: 'text'
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
export default class AggiungiMassivamenteNucleiPF extends NavigationMixin(LightningElement) {


    @api userInfo;
    @api profiliAutorizzati;
    @api profiloAutorizzatoShow = false;
    @api recordType;
    @api title;
    @api recordId;
    @api messaggioDiBloccoTitle;
    @track selectedNDGRows;
    @api modelliDiServizio;
    @track selectedModelloDiServizio;
    @track backupOrderNDG=[];
    @track padri =[];
    @track figli;
    @track nuclei;
    @track selectedRowsStep2=[];
    @track currentRowsStep2=[];
    @track openAddNdgmodal = false;
    currentUser = {};
    currentContact = {};
    currentPF = {};
    @track isRendered;
    @track loaded;
    referentiConfigurazioniMap = {};
   selectedValuesBeforeDeselect =[] ;
    ndgColumns = ndgcolumns;
    mwColumns = mwColumns;

    bloccoSpostamenti = false;

    @track step1 = true;
    @track searchedNdg;
    @track searchedNome;
    @track ndgList = [];
    @track ndgListCount;
    @track ndgOffset = 0;
    @track ndgLimit = 5;
    @track searchedNomeMw;
    @track mwList = [];
    @track selectedMWRowIds = [];
    @track mwListCount;
    @track mwOffset = 0;
    @track mwLimit = 5;
    @track tableTarget = {};
    hasOFS;
    
    superUser;

    //SORTING
    // MS 24-01-2024 start
    @track ndgSortBy = 'Name';
    @track ndgSortDirection = 'asc';
    @track selectRowsAll = [];
    @track selectRowsValuesAll = [];
    // MS end

    //NEW
    idToexclude=[];
    allData = {};
    @track filteredNdgList = [];
    //NEW

    @track errorMessage;
    @track disabled = true;
    @track draftValues = [];
    connectedCallback(){
        getUserInfo()
        .then(result => {
            console.log('DK getUserInfo result', result);
            console.log('DK profiliAutorizzati', this.profiliAutorizzati);
            console.log('DK profiloAutorizzatoShow1', this.profiloAutorizzatoShow);
            this.userInfo = result;
            if(this.profiliAutorizzati === undefined || this.profiliAutorizzati.includes(result.Profile.Name)){
                this.profiloAutorizzatoShow = true;
            }
            console.log('DK profiloAutorizzatoShow', this.profiloAutorizzatoShow);

            if(this.profiloAutorizzatoShow){
                console.log('pz 131');
                this.bloccoSpostamenti = Boolean(this.messaggioDiBloccoTitle);
                init({ recordId: this.recordId })
                .then(result => {
                    console.log('init result', result);
                    this.isRendered = true;
                    console.log('DK AggiungiMassivamenteNucleiPF.init.result: ' + JSON.stringify(result));
                    this.errorMessage = result['errorMessage'];
        
                    if (!Boolean(this.errorMessage)) {
                        this.currentUser = result['currentUser'];
                        this.currentPF = result['currentPF'];
                        console.log('this.currentPF',  this.currentPF);
                        this.superUser = this.currentUser.Profilo__c == 'NEC_D.0';
                        this.currentContact = result['currentContact'];
                        this.hasOFS = result['hasOFS'];
                        this.referentiConfigurazioniMap = result['referentiConfigurazioniMap'];
        
                        if (this.currentPF && this.currentPF.Name && typeof this.currentPF.Name === 'string' && this.currentPF.Name.endsWith('999')) {
                            this.disabled = true;
                        } else {
                            this.disabled = false;
                        }
                    }
        
                    this.loaded = true;
                    console.log('disabled1', this.disabled);
        
                })
                .catch(error => {
                    console.error('Error calling init:', error);
                });
            }    
            
        });}

    handleOpenNdgModal(){

        console.log('DK Start handleOpenNdgModal');
        
        if(!Boolean(this.errorMessage)){
    
            this.loadMWRecords(false).then(() =>{

                this.openAddNdgmodal = true;
                console.log('DK FINISHED');
            });
        }else{

            const toastEvent = new ShowToastEvent({
                title: "Error!",
                message: this.errorMessage,
                variant: "error"
            });
            this.dispatchEvent(toastEvent);
        }
    }

    handleNdgModalStep2(){
        this.ndgOffset = 0;
        this.loadNDGRecords(false).then(() =>{

            this.step1 = false;
            console.log('DK FINISHED');
        });
    }

    handleNdgModalStep1(){

        this.reset2();
        
    }

    handleSaveAndClose(){

        this.handleSave(true);
       const delayInMilliseconds = 4000;
        setTimeout(() => {
            this.openAddNdgmodal = false;
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    actionName: 'view'
                }
            });        }, delayInMilliseconds);
    }

    handleSaveAndRedo(){

        this.handleSave(false);

        
        const delayInMilliseconds = 4000;
        setTimeout(() => {
            this.handleNdgModalStep1();
        }, delayInMilliseconds);
    }

    closeNdgModal() {

        this.openAddNdgmodal = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
    } 

    reset(){
        
        
        this.padri=[];
        this.figli=[];
        this.nuclei=[];
        this.selectedRowsStep2=[];
        this.currentRowsStep2=[];
        this.step1 = true;
        this.searchedNdg = '';
        this.searchedNome = '';
        this.ndgList = [];
        this.ndgListCount = 0;
        this.ndgOffset = 0;
        this.ndgLimit = 5;
        this.searchedNomeMw = '';
        this.selectedMWRowIds = [];
        this.tableTarget = {};
    }

    reset2(){
        
        this.padri=[];
        this.figli=[];
        this.nuclei=[];
        this.selectedRowsStep2=[];
        this.currentRowsStep2=[];
        this.step1 = true;
        this.searchedNdg = '';
        this.searchedNome = '';
        this.ndgList = [];
        this.ndgListCount = 0;
        this.ndgOffset = 0;
        this.ndgLimit = 5;
        this.tableTarget = {};
    }


    handleSave(isSaveAndClose){

        this.isRendered=false;
        let ndgTable = this.template.querySelector("[data-item='ndgTable']");
        let selectedNdgRows = [];
        let selectedNdgRowsToMove = [];

        // MS 25-01-2024 start
        if(ndgTable){

            this.updateSelectedRows();
            selectedNdgRows = this.selectRowsValuesAll
            console.log('selectedNdgRows ' + JSON.stringify(selectedNdgRows) + " " + this.page);
            
        }

        this.selectRowsValuesAll = []
        this.selectRowsAll = []
        // MS end

        //console.log('clear selectedNdgRows ' + this.selectRowsValuesAll);
        // selectedNdgRows.forEach(ndg => {

        //     if(ndg.RecordType.DeveloperName != 'GruppoFinanziario'){

        //         selectedNdgRowsToMove.push(ndg);
        //     }
        // });

        let continueProcess = true;
        console.log('DK BloccaSpostamentiInFiliale Partenza: ' + this.currentPF.PTF_Filiale__r.PTF_BloccaSpostamentiInFiliale__c);
        console.log('DK BloccaSpostamentiFiliale Partenza: ' + this.currentPF.PTF_Filiale__r.PTF_BloccaSpostamentiFiliale__c);
        if(this.superUser && !this.hasConfirmed &&
        (this.currentPF.PTF_Filiale__r.PTF_BloccaSpostamentiFiliale__c || this.currentPF.PTF_Filiale__r.PTF_BloccaSpostamentiInFiliale__c)){
            
            this.openDialog = true;
            this.hasConfirmed = false;
            continueProcess = false;
            this.loaded = false;
            this.isSaveAndClose = isSaveAndClose;
        }
        if(this.hasConfirmed){

            isSaveAndClose = this.isSaveAndClose;
        }
        console.log('DK continueProcess: ' + continueProcess);
        console.log('DK isSaveAndClose: ' + isSaveAndClose);
        this.loaded = false;
        if(continueProcess){

            let selectedNdgList = [];
            let ndgWithIter = [];
            let ndgIterMap = {};
            let ndgWithoutIter = [];
            let subjectMap = {};
            let keyMap = {};
            let selectedProcess = '';
            let giustificazione = '';
            try{
                if(selectedNdgRows.length > 0){
                    console.log('START SAVE');
                    
                    selectedNdgRows.forEach(ndg => {
                        if(this.superUser){
                            
                            ndgWithoutIter.push(ndg.Id);
                        }else{
                            let configurationMap = {};
    
                            let mapKey = this.checkEligible(ndg, this.currentPF);
                            if(this.referentiConfigurazioniMap[mapKey]){
            
                                configurationMap = this.referentiConfigurazioniMap;
                            }
                            console.log('DK mapKey: ' + mapKey);
                            console.log('DK configurationMap: ' + JSON.stringify(configurationMap));
                            if(configurationMap[mapKey]){
                            
                                console.log('SONO QUA3');
                                subjectMap[ndg.Id] = configurationMap[mapKey].MasterLabel;
                                keyMap[ndg.Id] = mapKey;
            
                                const noteValid = [...this.template.querySelectorAll("[data-item='note']")]
                                .reduce((validSoFar, inputCmp) => {
                                            inputCmp.reportValidity();
                                            return validSoFar && inputCmp.checkValidity();
                                }, true);
    
                                const controlloValid = [...this.template.querySelectorAll("[data-item='controllo']")]
                                .reduce((validSoFar, inputCmp) => {
                                            inputCmp.reportValidity();
                                            return validSoFar && inputCmp.checkValidity();
                                }, true);
            
                                /*if(!noteValid){
            
                                    throw 'Valorizzare il campo \'Motivazioni\' prima di continuare.';
                                }*/
    
                                if((!controlloValid && this.multiOption) || !noteValid){
            
                                    throw 'Valorizzare i campi richiesti prima di continuare.';
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
                                console.log('DK IterApprovativo: ' + configurationMap[mapKey].Iter_Approvativo__c);
                                console.log('DK CURRENT CHECK Check_SegComp__c', configurationMap[mapKey].Check_SegComp__c);
                                console.log('DK CURRENT CHECK PTF_SegmentoComportamentale__c', ndg.PTF_SegmentoComportamentale__c);
                                console.log('DK CURRENT CHECK PTF_ModelloDiServizio__c', this.currentPF.PTF_ModelloDiServizio__c);
                                if(configurationMap[mapKey].Check_SegComp__c && ndg.PTF_SegmentoComportamentale__c.toLowerCase().includes(this.currentPF.PTF_ModelloDiServizio__c.toLowerCase())){
                                    configurationMap[mapKey].Iter_Approvativo__c = false;
                                }
                                console.log('DK IterApprovativo: ' + configurationMap[mapKey].Iter_Approvativo__c);
                                    
                                console.log('SONO QUA2');
                                if(configurationMap[mapKey].Iter_Approvativo__c){
                                    
            
                                    ndgIterMap[ndg.Id] = configurationMap[mapKey];
                                    let parsedJSON = JSON.parse(configurationMap[mapKey].PTF_JSON_Approvatori__c);
                                    selectedProcess = Boolean(parsedJSON.takeAggiungiMassivamente) ? parsedJSON.takeAggiungiMassivamente : '';
                                    giustificazione = '';
                                    if(Boolean(selectedProcess)){
    
                                        parsedJSON.multiOption.forEach(item => {
    
                                            if(item.value == selectedProcess){
    
                                                giustificazione = item.label;
                                            }
                                        });
                                    }
                                    ndgWithIter.push(ndg);
                
                                }else{
                                    
                                    console.log('SONO QUA4');
                                    ndgIterMap[ndg.Id] = configurationMap[mapKey];
                                    ndgWithoutIter.push(ndg.Id);
                                    console.log('DK NO ITER');
                                }
                            }else{
                
                                throw "Casistica non configurata, contattare l'amministratore di sistema!!";
                            }
                        }
                    });
                    if(ndgWithIter.length > 0){
    
                        this.handleCreateQueues(ndgWithIter, ndgIterMap, this.currentPF, subjectMap, keyMap, true, selectedProcess, giustificazione).then(() => {
    
                            this.isRendered=true;
                        });
                    }
        
                    if(ndgWithoutIter.length > 0){
        
                        this.handleMoveNdg(ndgWithoutIter, isSaveAndClose).then(() => {
                            
                            this.loaded = true;
                            this.isRendered=true;
                        });
                    }
                }else{
                    this.isRendered=true;
                    const toastEvent = new ShowToastEvent({
                        title: "Warning!",
                        message: "Selezionare almeno una tra le opzioni disponibili",
                        variant: "warning"
                    });
                    this.dispatchEvent(toastEvent);
                    // MS 13-02-2024 start
                    this.loaded = true;
                    // MS end
                }
            }catch(error){
                this.isRendered=true;
                console.log('DK error: ' + JSON.stringify(error));
                console.log('DK error: ' + error);
            }
        }
    }

    handleCreateQueues(ndgWithIter, ndgIterMap, selectedMw, subjectMap, keyMap, hasIter, selectedProcess, giustificazione){
        
        return createQueues({
            accountList: ndgWithIter,
            ndgIterMap: ndgIterMap,
            portafoglioDiPartenza: selectedMw,
            portafoglioDiDestinazione: this.currentPF,
            hasIter: hasIter,
            process: selectedProcess
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
            this.handleSendRequest(ndgWithIter, ndgIterMap, subjectMap, keyMap, parsedResult['accountWorkOrderKeyMap'], hasIter ? parsedResult['woStepMap'] : {}, hasIter, selectedProcess, giustificazione).then(() => {
                        
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

    handleSendRequest(ndgWithIter, ndgIterTypeMap, subjectMap, keyMap, accountWorkOrderKeyMap, woStepMap, hasIter, selectedProcess, giustificazione){

        try{
            
            return sendMovementRequest({
                portafoglioDestinazione: this.currentPF.Id,
                ndgList: ndgWithIter, 
                ndgIterTypeMap: ndgIterTypeMap, 
                subjectMap: subjectMap, 
                note: '', 
                configurationKeyMap: keyMap, 
                primari: [], 
                accountKeyMap: accountWorkOrderKeyMap, 
                woStepMap: woStepMap, 
                ruolo: '', 
                gruppoFinanziarioId: null, 
                recordId: null, 
                referente: this.currentPF.Referente, 
                hasIter: hasIter,
                process: selectedProcess,
                motivazione: giustificazione,
                lineItemIter: false
            }).
            then(result => {
                console.log('DK sendMovementRequest.result1: ' + JSON.stringify(result));
                if(this.superUser){

                    console.log('DK sendMovementRequest.result: ' + JSON.stringify(result));
                    let parsedResult = {};
                    parsedResult = JSON.parse(JSON.parse(result));
                    return approveWorkOrders({workOrderIdSet: parsedResult['workOrderIdSet']})
                    .then(result => {
                        console.log('DK sendMovementRequest.result2: ' + JSON.stringify(result));
                        const toastEvent = new ShowToastEvent({
                            title: "Success!",
                            message: "Richiesta di spostamento inoltrata correttamente!!",
                            variant: "success"
                        });
                        this.dispatchEvent(toastEvent);
                        //this.closeNdgModal();
                    })
                    .catch(error => {

                        console.log('DK error: ' + JSON.stringify(error));
                        const toastEvent = new ShowToastEvent({
                            title: "Error!",
                            message: error.body.message,
                            variant: "error"
                        });
                        this.dispatchEvent(toastEvent);
                    });
                }else{
                    console.log('pz 583');
                    const toastEvent = new ShowToastEvent({
                        title: "Success!",
                        message: "Richiesta di spostamento inoltrata correttamente!!",
                        variant: "success"
                    });
                    this.dispatchEvent(toastEvent);
                    //this.closeNdgModal();
                }
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

    checkEligible(ndg, portafoglio){
        
        let startMDS = portafoglio.PTF_ModelloDiServizio__c;
        let currentBranchType = portafoglio.PTF_Filiale__r.PTF_BranchTypeDesc__c;
        let configurationKey = startMDS + '_' + startMDS + '_' + portafoglio.PTF_Banca__r.FinServ__BankNumber__c;
        let configurationKey2 = startMDS + '_' + startMDS + '_TUTTE';
        let configurationKey3 = startMDS + '_' + startMDS + '_' + currentBranchType + '_' + portafoglio.PTF_Banca__r.FinServ__BankNumber__c;
        let configurationKey4 = startMDS + '_' + startMDS + '_' + currentBranchType + '_TUTTE';
        let configurationMap;

        try {
            
            if(this.referentiConfigurazioniMap[configurationKey] || this.referentiConfigurazioniMap[configurationKey2] || this.referentiConfigurazioniMap[configurationKey3] || this.referentiConfigurazioniMap[configurationKey4]){
    
                configurationMap = this.referentiConfigurazioniMap;
            }
    
            if(configurationMap){
    
                let mapKey = "";
                if(configurationMap[configurationKey3]){
    
                    mapKey = configurationKey3;
                }else if(configurationMap[configurationKey]){
                    
                    mapKey = configurationKey;
                }else if(configurationMap[configurationKey4]){
                    
                    mapKey = configurationKey4;
                }else if(configurationMap[configurationKey2]){
                    
                    mapKey = configurationKey2;
                }
                console.log('DK mapKey: ' + mapKey);
    
                return mapKey;
            }else{
                
                return null;
            }
        } catch (error) {
            console.log('DK checkEligible error: ' + JSON.stringify(error));
            console.log('DK checkEligible error: ' + error);
        }
    }

    handleMoveNdg(ndgWithoutIter, isSaveAndClose){

        return moveNdgsToWallet({portafoglio: this.currentPF.Id, ndgIdList:ndgWithoutIter, portafogliopartenza:this.selectedMWRowIds[0]}).
        then(() => {

            this.isRendered=true;

            const toastEvent = new ShowToastEvent({
                title: "Success!",
                message: "NDG spostati correttamente!!",
                variant: "success"
            });
            this.dispatchEvent(toastEvent);
            this.reset();
            if(isSaveAndClose){
                
                this.closeNdgModal();
            }else{
                this.connectedCallback();
            }
        }).
        catch(error => {
            this.isRendered=true;
            const toastEvent = new ShowToastEvent({
                title: "Error!",
                message: "Purtroppo l'operazione non è andata a buon fine, conatta il tuo amministratore di sistema.",
                variant: "error"
            });
            this.dispatchEvent(toastEvent);
            console.log('error: '+JSON.stringify(error.body.message));
        });
    }

    // MicroWallets ----------------------------------------------------------------------
    loadMoreMWData(event){

        try {
            this.tableTarget = event;
            if(this.mwListCount > this.mwOffset){
                
                this.tableTarget.isLoading = true;
                this.mwOffset += this.mwLimit;
                this.loadMWRecords(false).then(() =>{

                    this.tableTarget.isLoading = false;
                });
            } else {
                this.tableTarget.isLoading = false;
            }
        } catch (error) {
            
            console.log('DK loadMoreMWData.error: ' + error);
        }
    }

    loadMWRecords(isSearch){
        
        try{
            let table = this.template.querySelector("[data-item='mwTable']");
            let selectedRows = [];
            if(table){

                selectedRows = this.template.querySelector("[data-item='mwTable']").getSelectedRows();
                if(selectedRows.length > 0){

                    console.log('DK selectedRows: ' + JSON.stringify(selectedRows));
                    this.selectedMWRowIds = selectedRows.map(item => item.Id);
                    this.selectedModelloDiServizio=selectedRows[0].PTF_ModelloDiServizio__c;
                    console.log('DK selectedMWRows: ' + JSON.stringify(this.selectedMWRowIds));
                }
            }
                console.log('this.recordType',JSON.stringify((this.recordType.split(','))));
                console.log('offset',this.mwOffset);
                console.log('nome',this.searchedNomeMw);
                console.log('portafoglio',this.currentPF);
                console.log('portafoglio id ',this.currentPF.Id);
                console.log('filiale',this.currentPF.PTF_Filiale__c);
                console.log('modelloDiServizio',this.currentPF.PTF_ModelloDiServizio__c);

            return loadMwList({
                offset: this.mwOffset,
                pagesize: this.mwLimit,
                nome: this.searchedNomeMw,
                portafoglio: this.currentPF.Id,
                filiale: this.currentPF.PTF_Filiale__c,
                modelloDiServizio: this.currentPF.PTF_ModelloDiServizio__c,
                recordType: this.recordType.split(',')
            })
            .then(result => {
                console.log('SV loadMwList: ', result);

                this.mwListCount = result["mwListCount"];
                let mwIdList = this.mwList.map(item => item.Id);
                let newValueList = [];
                result["mwList"].forEach(element => {
                    let ref = 'Non assegnato';
                    for(var mapKey in result.referenti){

                        if(mapKey === element.Id){
                            ref = result.referenti[mapKey].PTF_Gestore_Name__c;
                        }
                    }
                    element.Referente = ref;

                    element.Filiale = element.PTF_Filiale__r.Name
                    let index;
                    if(isSearch){

                        index = this.selectedMWRowIds.indexOf(element.Id);
                    }else{
                        
                        index = mwIdList.indexOf(element.Id);
                    }

                    if(index <= -1){

                        newValueList.push(element);
                    }
                });
                if(isSearch){

                    this.mwList = selectedRows.concat(newValueList);
                }else{

                    this.mwList = this.mwList.concat(newValueList);
                }
                console.log('DK mwList: ' + JSON.stringify(this.mwList));
            })
            .catch(error => { 
                console.log('DK loadMWRecords.loadMWList.error: ' + JSON.stringify(error));
            })
        }catch(error){

            console.log('DK loadMWRecords.error: ' + error);
        }
    }

    handleMWSearch(){
       
        this.mwOffset = 0;
        this.loadMWRecords(true);
    }

    // NDG -------------------------------------------------------
    loadMoreNDGData(event){
        console.log('@@@load');

        try {
            this.tableTarget = event;
            if(this.ndgListCount > this.ndgOffset){
                this.tableTarget.isLoading = true;
                this.ndgOffset += this.ndgLimit;
                this.loadNDGRecords(false).then(() =>{

                    this.tableTarget.isLoading = false;
                });
            } else {
                this.tableTarget.isLoading = false;
            }
        } catch (error) {
            
            console.log('DK loadMoreNDGData.error: ' + error);
        }
    }

    loadNDGRecords(isSearch){
        
        try{

            let mwTable = this.template.querySelector("[data-item='mwTable']");
            let selectedMwRows = [];
            if(mwTable){

                selectedMwRows = this.template.querySelector("[data-item='mwTable']").getSelectedRows();
                if(selectedMwRows.length > 0){

                    console.log('DK selectedMwRows: ' + JSON.stringify(selectedMwRows));
                    this.selectedMWRowIds = selectedMwRows.map(item => item.Id);
                    this.selectedModelloDiServizio=selectedMwRows[0].PTF_ModelloDiServizio__c;
                    console.log('DK selectedMWRows: ' + JSON.stringify(this.selectedMWRowIds));
                }
            }

            

            console.log('DK selectedMwRows: ' + JSON.stringify(selectedMwRows));
            if(selectedMwRows.length > 0 || !this.step1){
                console.log('@@@ portafoglio: '+this.selectedMWRowIds[0]);
                console.log('@@@ nome: '+this.searchedNome);
                console.log('@@@ ndg: '+JSON.stringify(this.searchedNdg));
                console.log('@@@ offset: '+JSON.stringify(this.ndgOffset));
                console.log('@@@ ndgLimit: '+JSON.stringify(this.ndgLimit));
                return loadNdgList({
                    portafoglio: selectedMwRows[0],
                    nome: this.searchedNome,
                    ndg: this.searchedNdg,
                    offset: this.ndgOffset,
                    pagesize: this.ndgLimit,
                    portafoglioDiDestinazione: this.currentPF
                })
                .then(result => {
                    this.allData = result;
                    console.log(' loadNdgList result this.allData',this.allData);
                    // console.log('@@@ risultato'+JSON.stringify(result["ndgList"]));
                    // console.log('isSeacrh: '+isSearch);
                    
                    // let ndgIdList = this.ndgList.map(item => item.Id);
                    // console.log(JSON.stringify(ndgIdList));
                    // let newValueList = [];
                    this.nuclei=this.allData['nuclei'];
                    this.padri=this.allData['parentList'];
                    console.log('this.padri1',this.padri);
                    console.log('this.padri2',this.allData['parentList']);
                    this.figli=this.allData['childList'];
                    console.log('this.figli1',this.figli);
                    console.log('this.allData["ndgList"]',this.allData["ndgList"]);
                    //OFS Start
                    if(!this.hasOFS){
                            
                        this.allData["ndgList"].forEach(element =>{
                            console.log('this.selectedModelloDiServizio',this.selectedModelloDiServizio);
                            console.log('this.modelliDiServizio',this.modelliDiServizio);
                            if(this.modelliDiServizio.split(',').includes(this.selectedModelloDiServizio)){
                                if(this.allData["nucleiOFS"].includes(element.PTF_Nucleo__c)){
                                    this.idToexclude.push(element.Id);
                                }
                                else if(element.PTF_OFS__c){
                                    this.idToexclude.push(element.Id);
                                }
                            }
                            else{
                                if(element.PTF_OFS__c){
                                    console.log('sonoquiOFS'+ element.Name);
                                    this.idToexclude.push(element.Id);
                                }
                            }
                        });
                    }
                    console.log('this.idToexclude',JSON.stringify(this.idToexclude));
                    //OFS End    
                    this.ndgList = this.allData["ndgList"];
                    this.filteredNdgList = this.ndgList;
                    console.log('this.filteredNdgList',JSON.stringify(this.filteredNdgList));
                    // MS 24-01-2024 start
                    this.filteredNdgList = this.sortData(this.ndgSortBy, this.ndgSortDirection);
                    this.ndgList = this.filteredNdgList;
                    // MS end
                    this.setPages(this.filteredNdgList);
                })
                .catch(error => { 
                    console.log('DK loadNDGRecords.loadNdgList.error: ' + error);
                    console.log('DK loadNDGRecords.loadNdgList.error: ' + JSON.stringify(error));
                })
            }else{
                
                const toastEvent = new ShowToastEvent({
                    title: "Warning!",
                    message: "Selezionare uno tra le opzioni disponibili",
                    variant: "warning"
                });
                this.dispatchEvent(toastEvent);
                console.log('handleAssignNDGs End');
                return null;
            }
        }catch(error){

            console.log('DK loadNDGRecords.error: ' + JSON.stringify(error));
        }
    }

    handleNDGSearch(){

        // MS 25-01-2024 start
        this.updateSelectedRows();
        // MS end
        
        console.log('@@@search');
        /*this.ndgOffset = 0;
        this.loadNDGRecords(true);*/
        this.filteredNdgList = [];
        this.page = 1;
        try {
            
            for(var i in this.ndgList){
                        
                if(Boolean(this.searchedNdg)){
                    
                    if(!this.ndgList[i].CRM_NDG__c.toLowerCase().includes(this.searchedNdg.toLowerCase())){
    
                        continue;
                    }
                }
                if(Boolean(this.searchedNome)){
                    
                    if(!this.ndgList[i].Name.toLowerCase().includes(this.searchedNome.toLowerCase())){
    
                        continue;
                    }
                }
    
                this.filteredNdgList.push(this.ndgList[i]);
            }
    
            console.log('DK filteredNdgList: ' + JSON.stringify(this.filteredNdgList));
            console.log('DK this.page: ' + this.page);
            this.setPages(this.filteredNdgList);
        } catch (error) {
            
            console.log('DK error: ' + error);
        }
    }

    handleSelection(event) {
        let actionName = event.detail.config.action;
        var selectedRows = event.detail.selectedRows;
        console.log('selectedRows', selectedRows);
        console.log('event.detail', JSON.stringify(event.detail));
        if (selectedRows.length > 0) {
            if (this.modelliDiServizio.split(',').includes(this.selectedModelloDiServizio)) {
    
                let srId = event.detail.selectedRows.map(item => item.Id);
                
                console.log('srId', JSON.stringify(srId));
                let tempList = srId.slice(); // Using slice to create a copy of the array
                let accList = this.allData['ndgList'];
                let pad = this.allData['parentList'];
                let fig = this.allData['childList'];
                console.log('pad', pad);
                console.log('fig', fig);
    
                if (actionName === 'rowSelect') {
                    var selectedRow = event.detail.config.value;
                    
                        if (pad.includes(selectedRow)) {
                            let acc = accList.find(item => item.Id === selectedRow);
                            for (let j = 0; j < fig.length; j++) {
                                let figlio = accList.find(item => item.Id === fig[j]);
                                if (figlio && acc && figlio.PTF_Nucleo__c === acc.PTF_Nucleo__c) {
                                    tempList.push(fig[j]);
                                }
                            }
                        } else if (fig.includes(selectedRow)) {
                            let acc = accList.find(item => item.Id === selectedRow);
                            for (let j = 0; j < pad.length; j++) {
                                let padre = accList.find(item => item.Id === pad[j]);
                                if (padre && acc && padre.PTF_Nucleo__c === acc.PTF_Nucleo__c) {
                                    tempList.push(pad[j]);
                                }
                            }
                        }
                    
                    this.selectedRowsStep2 = tempList;
                }
    
                if (actionName === 'rowDeselect') {
                    var deselectedRow = event.detail.config.value;
                    console.log('deselectedRow', JSON.stringify(deselectedRow));
                        if (pad.includes(deselectedRow)) {
                            let acc = accList.find(item => item.Id === deselectedRow);
                            for (let j = 0; j < fig.length; j++) {
                                let figlio = accList.find(item => item.Id === fig[j]);
                                if (figlio && acc && figlio.PTF_Nucleo__c === acc.PTF_Nucleo__c) {
                                    let index = tempList.indexOf(fig[j]);
                                    tempList.splice(index, 1);
                                }
                            }
                        } else if (fig.includes(deselectedRow)) {
                            let acc = accList.find(item => item.Id === deselectedRow);
                            for (let j = 0; j < pad.length; j++) {
                                let padre = accList.find(item => item.Id === pad[j]);
                                if (padre && acc && padre.PTF_Nucleo__c === acc.PTF_Nucleo__c) {
                                    let index = tempList.indexOf(pad[j]);
                                    tempList.splice(index, 1);
                                }
                            }
                        }
                    this.selectedRowsStep2 = tempList;
                }
                // MS 06-02-2024 start
                if (actionName === 'selectAllRows')
                {
                    this.selectedRowsStep2 = srId
                }
                // MS end
            } else {
                this.selectedNdgRows = event.detail.selectedRows;
                this.selectedRowsStep2 = this.selectedNdgRows.map(item => item.Id);
            }
        } else {
            console.log('this.selectedRowsStep2', this.selectedRowsStep2);
            this.selectedRowsStep2 = [];
            this.draftValues = [];
        }
    }


    handleMWReset(){

        this.searchedNomeMw = '';
        this.handleMWSearch();
    }
    handleNDGReset(){

        this.searchedNdg = '';
        this.searchedNome = '';
        this.handleNDGSearch();
    }

    handleFilter(event){

        console.log('DK handleFilter Started');
        
        try {
            
            if(event.target.name == 'searchedNomeMw'){
                
                this.searchedNomeMw = event.target.value;
            }else if(event.target.name == 'searchedNdg'){

                this.searchedNdg = event.target.value;
            }else if(event.target.name == 'searchedNome'){
                
                this.searchedNome = event.target.value;
            }
            
        } catch(error) {
            // invalid regex, use full list
            console.log('DK handleFilter.error: ' + error);
        }
    }

    //Test Pagination
    @track page = 1;
    perpage = 25;
    @track pages = [];
    set_size = 25;
    
    // MS 24-01-2024 start
    handleAvanti(){
        try {

            this.updateSelectedRows();
            //console.log('DK SELECTED ROWS: '  + JSON.stringify(this.selectedCMRow));
            ++this.page;
        } catch (error) {
            console.log('error: ', error);
        }
    }

    handleIndietro(){
        try {

            this.updateSelectedRows();
            //console.log('DK SELECTED ROWS: '  + JSON.stringify(this.selectedCMRow));
            --this.page;
        } catch (error) {
            console.log('error: ', error);
        }
    }

    updateSelectedRows(){
        // MS 25-01-2024 start
        // aggiorna la lista totale degli ndg selezionati
        let selectedRows = this.currentPageData.filter(obj => this.selectedRowsStep2.includes(obj.Id));
        let deselectedRows = this.currentPageData.filter(obj => !selectedRows.some(item => item.Id === obj.Id));
        // aggiungi le righe selezionate
        this.selectRowsValuesAll = this.selectRowsValuesAll.concat(selectedRows.filter(a => !this.selectRowsValuesAll.find(b => b.Id === a.Id)));
        // rimuovi righe deselezionate
        this.selectRowsValuesAll = this.selectRowsValuesAll.filter(obj => !deselectedRows.some(item => item.Id === obj.Id));
        this.selectRowsAll = this.selectRowsValuesAll.map(element => element.Id);
        ///console.log("selectedNDGRowIds", JSON.stringify(this.selectedNDGRowIds));
        ///console.log("selectRowsAll", JSON.stringify(this.selectRowsAll));
        console.log("selectRowsValuesAll", JSON.stringify(this.selectRowsValuesAll));
        console.log("selectedRowsStep2", JSON.stringify(this.selectedRowsStep2));
        // MS end

        //console.log('DK SELECTED ROWS: '  + JSON.stringify(this.selectRowsAll));
        this.selectedRowsStep2 = this.selectRowsAll;
        //console.log('DK SELECTED ROWS: '  + JSON.stringify(this.selectedCMRow));
    }
    // MS end

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
        let ndgToDisplay = this.filteredNdgList.slice(startIndex,endIndex);
        console.log('ndgToDisplay',ndgToDisplay);
        let finalNdgToDisplay = [];
        ndgToDisplay.forEach(element => {
            element.PTF_Url = '/' + element.Id;
            if(!this.figli.includes(element.Id)){

                finalNdgToDisplay.push(element)
            }
            if(!this.idToexclude.includes(element.Id)){
                if(this.padri.includes(element.Id)){
                    element.PTF_IsCaponucleoIcon='utility:check';
                    /*let index;
                    if(isSearch){
                        
                        console.log('@@@ selectmio: '+JSON.stringify(this.selectedRowsStep2));
                        index = this.selectedRowsStep2.indexOf(element.Id);
                        console.log('@@@ index: '+index+' element: '+element.Id);
                    }else{

                        index = ndgIdList.indexOf(element.Id);
                    }
                    if(index <= -1){

                        newValueList.push(element);
                        this.backupOrderNDG.push(element.Id);
                    }*/
                    this.allData["ndgList"].forEach(element2 =>{
                        if(!this.idToexclude.includes(element2.Id)){
                            if(this.figli.includes(element2.Id) && element2.PTF_Nucleo__c===element.PTF_Nucleo__c){
                                element2.PTF_Url = '/' + element2.Id;
                                element2.provenanceIconName='utility:level_down';
                                finalNdgToDisplay.push(element2);
                                /*let indexChild;
                                if(isSearch){

                                    indexChild = this.selectedRowsStep2.indexOf(element2.Id);
                                }else{
    
                                    indexChild = ndgIdList.indexOf(element2.Id);
                                }
                                if(indexChild <= -1){
            
                                    this.backupOrderNDG.push(element2.Id);
                                }*/
                            }
                        }
                        
                    });
                }
            }
        });

        return finalNdgToDisplay;
    }

    setPages = (data)=>{
        this.pages = [];
        let numberOfPages = Math.ceil(data.length / this.perpage);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
        console.log('DK this.pages: ' + this.pages);
    }  

    sortNdg(event) {
        // MS 13-02-2024 start
        this.updateSelectedRows();
        // MS end
        this.ndgSortBy = event.detail.fieldName;
        this.ndgSortDirection = event.detail.sortDirection;
        this.filteredNdgList = this.sortData(this.ndgSortBy, this.ndgSortDirection);
        
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.filteredNdgList));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        return parseData;
    }    

    
    get disabledButtonIndietro(){
        return this.page === 1;
    }
    
    get disabledButtonAvanti(){
        return this.page === this.pages.length || this.filteredNdgList.length === 0
    }

    

    get currentPageData(){
        return this.pageData();
    }

    // START DIALOG
    @track openDialog = false;
    @track messaggioDialog = 'Per gli ndg selezionati sono presenti blocchi di spostamento a livello di filiale. \n';
    @track hasConfirmed = false;
    //handles button clicks
    handleClickDialog(event){
        if(event.currentTarget.name == 'cancel'){
            this.openDialog = false;
            this.hasConfirmed = false;
            this.loaded = true;
        }else{
            this.hasConfirmed = true;
            this.openDialog = false;
            this.loaded = true;
            this.handleSave();
        }
    }
    // END DIALOG

    // compare( a, b ) {
    //     if ( a.CRM_LinkCode < b.CRM_LinkCode ){
    //       return -1;
    //     }
    //     if ( a.CRM_LinkCode > b.CRM_LinkCode ){
    //       return 1;
    //     }
    //     return 0;
    // }
}