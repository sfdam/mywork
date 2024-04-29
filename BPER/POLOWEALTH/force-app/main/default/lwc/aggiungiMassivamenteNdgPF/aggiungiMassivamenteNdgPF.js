import { LightningElement, api, track} from 'lwc';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

import getUserInfo from '@salesforce/apex/SV_Utilities.getUserInfo';
import init from '@salesforce/apex/AggiungiMassivamenteNdgPFController.init';
import loadMwList from '@salesforce/apex/AggiungiMassivamenteNdgPFController.loadMwList';
import loadNdgList from '@salesforce/apex/AggiungiMassivamenteNdgPFController.loadNdgList';
import moveNdgsToWallet from '@salesforce/apex/AggiungiMassivamenteNdgPFController.moveNdgsToWallet';
import createQueues from '@salesforce/apex/SpostaNdgIterController.createQueues';
import sendMovementRequest from '@salesforce/apex/SpostaNdgIterController.sendMovementRequest';

import NDG from '@salesforce/label/c.aggiungiMassivamenteNdgPf_CLM_NDG';
import Nominativo from '@salesforce/label/c.aggiungiMassivamenteNdgPf_CLM_Nominativo';
import Capogruppo from '@salesforce/label/c.aggiungiMassivamenteNdgPf_CLM_Capogruppo';
import NaturaGiuridica from '@salesforce/label/c.aggiungiMassivamenteNdgPf_CLM_NaturaGiuridica';
import Patrimonio from '@salesforce/label/c.aggiungiMassivamenteNdgPf_CLM_Patrimonio';
import Utilizzato from '@salesforce/label/c.aggiungiMassivamenteNdgPf_CLM_Utilizzato';
import MicroPortafoglio from '@salesforce/label/c.aggiungiMassivamenteNdgPf_CLM_MicroPortafoglio';
import ModelloServizio from '@salesforce/label/c.aggiungiMassivamenteNdgPf_CLM_ModelloServizio';
import Filiale from '@salesforce/label/c.aggiungiMassivamenteNdgPf_CLM_Filiale';
import Referente from '@salesforce/label/c.aggiungiMassivamenteNdgPf_CLM_Referente';


const ndgcolumns = [
    { label: NDG, fieldName: 'PTF_Url', type: 'url', 
    cellAttributes:{ iconName: { fieldName: 'provenanceIconName' } },
        typeAttributes: {
            label: { fieldName: 'CRM_NDG__c' }
        },
        hideDefaultActions: "true"},
    { label: Nominativo, fieldName: 'Name', type: 'text', sortable:"true"},
    { label: Capogruppo, fieldName: '', type: 'Boolean', hideDefaultActions: "true", cellAttributes: {
        iconName: { fieldName: 'PTF_IsCaponugruppoIcon' },
        iconPosition: 'left'
    }},
    { label: NaturaGiuridica, fieldName: 'PTF_NaturaGiuridica__c', type: 'text' },
    { label: Patrimonio, fieldName: 'PTF_Patrimonio__c', type: 'currency', cellAttributes: { alignment: 'left' }},
    { label: Utilizzato, fieldName: 'PTF_Utilizzato__c', type: 'currency', cellAttributes: { alignment: 'left' }}
    // { label: 'Coerenza Gruge', fieldName: '', type: 'text',cellAttributes:{class:{fieldName:"typeCSSClass"}} }
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
export default class AggiungiMassivamenteNdgPF extends NavigationMixin(LightningElement) {

    @api recordId;

    @api userInfo;
    @api profiliAutorizzati;
    @api profiloAutorizzatoShow = false;
    
    @api modelliDiServizio;
    @api titolo;
    @api labelBottone;
    @track openAddNdgmodal = false;
    currentUser = {};
    currentContact = {};
    currentPF = {};
    hasOFS;

    referentiConfigurazioniMap = {};

    ndgColumns = ndgcolumns;
    mwColumns = mwColumns;

    @track step1 = true;
    @track searchedNdg;
    @track searchedNome;
    allData = {};
    @track ndgList = [];
    @track filteredNdgList = [];
    @track selectedNDGRows = [];
    @track selectedNDGRowIds = [];
    @track ndgListCount;
    @track ndgOffset = 0;
    @track ndgLimit = 5;
    @track searchedNomeMwMw;
    @track mwList = [];
    @track selectedMWRowIds = [];
    @track mwListCount;
    @track mwOffset = 0;
    @track mwLimit = 5;
    @track tableTarget = {};
    @track loaded;
    @track ndgSortBy;
    @track ndgSortDirection;
    
    superUser;

    @track errorMessage;
    @track disabled = true;
    connectedCallback(){
        getUserInfo()
        .then(result => {
            console.log('DK getUserInfo result', result);
            console.log('DK profiliAutorizzati', this.profiliAutorizzati);
            console.log('DK profiloAutorizzatoShow1', this.profiloAutorizzatoShow);
            this.userInfo = result;
            if(!Boolean(this.profiliAutorizzati) || this.profiliAutorizzati.includes(result.Profile.Name)){
                this.profiloAutorizzatoShow = true;
            }
            console.log('DK profiloAutorizzatoShow', this.profiloAutorizzatoShow);

            if(this.profiloAutorizzatoShow){
                console.log('pz 131');
                this.bloccoSpostamenti = Boolean(this.messaggioDiBloccoTitle);
                init({recordId: this.recordId}).then(result => {
                    console.log('pz 131');
                    this.isRendered=true;
                    console.log('DK AggiungiMassivamenteNucleiPF.init.result: ' + JSON.stringify(result));
                    this.errorMessage = result['errorMessage'];
                    if(!Boolean(this.errorMessage)){
                        this.currentUser = result['currentUser'];
                        this.currentPF = result['currentPF'];
                        this.superUser = this.currentUser.Profilo__c == 'NEC_D.0';
                        this.currentContact = result['currentContact'];
                        this.hasOFS = result['hasOFS'];
                        this.referentiConfigurazioniMap = result['referentiConfigurazioniMap'];
                    }
                    if (this.currentUser.Profilo__c != 'NEC_D.0' &&  this.currentPF.Name.endsWith('999') ){
                        this.disabled = true;
                    }else{
                        this.disabled = false;
                    }
                    this.loaded = true;
                    console.log('disabled1', this.disabled);
                });
            }
            console.log('disabled', this.disabled);
        });
    }

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
        this.loadNDGRecords(false, true).then(() =>{

            this.step1 = false;
            console.log('DK FINISHED');
        });
    }

    handleNdgModalStep1(){

        this.step1 = true;
        this.searchedNdg = '';
        this.ndgList = [];
        this.selectedNDGRowIds = [];
        this.ndgListCount = 0;
        this.ndgOffset = 0;
        this.tableTarget = {};
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
        
        this.step1 = true;
        this.searchedNdg = '';
        this.ndgList = [];
        this.selectedNDGRowIds = [];
        this.ndgListCount = 0;
        this.ndgOffset = 0;
        this.searchedNomeMw = '';
        this.selectedMWRowIds = [];
        this.tableTarget = {};
    }

    @track isSaveAndClose = true;
    handleSave(isSaveAndClose){
        let ndgTable = this.template.querySelector("[data-item='ndgTable']");
        let selectedNdgRows = [];
        let selectedNdgRowsToMove = [];
        if(ndgTable){
            
            selectedNdgRows = ndgTable.getSelectedRows();
        }
        
        selectedNdgRows.forEach(ndg => {
            
            if(ndg.RecordType.DeveloperName != 'GruppoFinanziario'){
                
                selectedNdgRowsToMove.push(ndg);
            }
        });
        
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
    
                if(selectedNdgRowsToMove.length > 0){
    
                    selectedNdgRowsToMove.forEach(ndg => {
    
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
    
                        this.handleCreateQueues(ndgWithIter, ndgIterMap, this.currentPF, subjectMap, keyMap, true, selectedProcess, giustificazione);
                        
                        this.isRendered=true;
                    }
        
                    if(ndgWithoutIter.length > 0){
        
                        this.handleMoveNdg(ndgWithoutIter, isSaveAndClose).then(() => {
                            
                            this.loaded = true;
                            this.isRendered=true;
                        });
                    }
                }else{
                    this.loaded = true;
                    const toastEvent = new ShowToastEvent({
                        title: "Warning!",
                        message: "Selezionare almeno una tra le opzioni disponibili",
                        variant: "warning"
                    });
                    this.dispatchEvent(toastEvent);
                }
            }catch(error){
    
                console.log('DK handleSave.error: ' + error);
                console.log('DK handleSave.error: ' + JSON.stringify(error));
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

                // if(this.superUser){

                //     console.log('DK sendMovementRequest.result: ' + JSON.stringify(result));
                //     let parsedResult = {};
                //     parsedResult = JSON.parse(JSON.parse(result));
                //     return approveWorkOrders({workOrderIdSet: parsedResult['workOrderIdSet']})
                //     .then(() => {

                //         const toastEvent = new ShowToastEvent({
                //             title: "Success!",
                //             message: "Richiesta di spostamento inoltrata correttamente!!",
                //             variant: "success"
                //         });
                //         this.dispatchEvent(toastEvent);
                //         this.closeNdgModal();
                //     })
                //     .catch(error => {

                //         console.log('DK error: ' + JSON.stringify(error));
                //         const toastEvent = new ShowToastEvent({
                //             title: "Error!",
                //             message: error.body.message,
                //             variant: "error"
                //         });
                //         this.dispatchEvent(toastEvent);
                //     });
                // }else{

                    const toastEvent = new ShowToastEvent({
                        title: "Success!",
                        message: "Richiesta di spostamento inoltrata correttamente!!",
                        variant: "success"
                    });
                    this.dispatchEvent(toastEvent);
                   // this.closeNdgModal();
                // }
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

        return moveNdgsToWallet({portafoglio: this.currentPF.Id, ndgIdList: ndgWithoutIter}).
        then(() => {

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

            console.log('DK error: ' + error);
            console.log('DK error: ' + JSON.stringify(error));
            const toastEvent = new ShowToastEvent({
                title: "Error!",
                message: "Purtroppo l'operazione non è andata a buon fine, conatta il tuo amministratore di sistema.",
                variant: "error"
            });
            this.dispatchEvent(toastEvent);
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
                    console.log('DK selectedMWRows: ' + JSON.stringify(this.selectedMWRowIds));
                }
            }

            return loadMwList({
                offset: this.mwOffset,
                pagesize: this.mwLimit,
                nome: this.searchedNomeMw,
                portafoglio: this.currentPF.Id,
                filiale: this.currentPF.PTF_Filiale__c,
                modelloDiServizio: this.currentPF.PTF_ModelloDiServizio__c
            })
            .then(result => {
                console.log('SV loadMwList: ', result);

                this.mwListCount = result["mwListCount"];
                let mwIdList = this.mwList.map(item => item.Id);
                let newValueList = [];
                result["mwList"].forEach(element => {
                    let ref = 'Non assegnato';
                    /*for(var mapKey in result.referenti){

                        if(mapKey === element.Id){
                            ref = result.referenti[mapKey].PTF_Gestore_Name__c;
                        }
                    }
                    element.Referente = ref;
                    element.Filiale = element.PTF_Filiale__r.Name*/
                    this.extendMW(element);
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

    extendMW(element){

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

    handleMWReset(){

        this.searchedNomeMw = '';
        this.handleMWSearch();
    }
    handleMWSearch(){
       
        this.mwOffset = 0;
        this.loadMWRecords(true);
    }

    // NDG -------------------------------------------------------
    loadMoreNDGData(event){

        try {
            this.tableTarget = event;
            if(this.ndgListCount > this.ndgOffset){
                
                this.tableTarget.isLoading = true;
                this.ndgOffset += this.ndgLimit;
                this.loadNDGRecords(false, false).then(() =>{

                    this.tableTarget.isLoading = false;
                });
            } else {
                this.tableTarget.isLoading = false;
            }
        } catch (error) {
            
            console.log('DK loadMoreNDGData.error: ' + error);
        }
    }

    loadNDGRecords(isSearch, isChange){
        
        try{

            let mwTable = this.template.querySelector("[data-item='mwTable']");
            let selectedMwRows = [];
            if(mwTable){

                selectedMwRows = this.template.querySelector("[data-item='mwTable']").getSelectedRows();
                if(selectedMwRows.length > 0){

                    console.log('DK selectedMwRows: ' + JSON.stringify(selectedMwRows));
                    this.selectedMWRowIds = selectedMwRows.map(item => item.Id);
                    console.log('DK selectedMWRows: ' + JSON.stringify(this.selectedMWRowIds));
                }
            }

            let ndgTable = this.template.querySelector("[data-item='ndgTable']");
            let selectedNdgRows = [];
            if(ndgTable){

                selectedNdgRows = ndgTable.getSelectedRows();
                if(selectedNdgRows.length > 0){

                    console.log('DK selectedNdgRows: ' + JSON.stringify(selectedNdgRows));
                    this.selectedNDGRowIds = selectedNdgRows.map(item => item.Id);
                    this.selectedNDGRows = selectedNdgRows;
                    console.log('DK selectedNDGRowIds: ' + JSON.stringify(this.selectedNDGRowIds));
                }
            }
            
            console.log('DK selectedMwRows: ' + JSON.stringify(selectedMwRows));
            if(selectedMwRows.length > 0 || !this.step1){

                return loadNdgList({
                    portafoglio: selectedMwRows[0],
                    isOFS: this.hasOFS,
                    nome: this.searchedNome,
                    ndg: this.searchedNdg,
                    offset: this.ndgOffset,
                    pagesize: this.ndgLimit,
                    portafoglioDiDestinazione: this.currentPF
                })
                .then(result => {
                    
                    console.log('SV result: ' + JSON.stringify(result));
                    // console.log('DK loadNdgList.result: ' + JSON.stringify(result));
                    // this.ndgListCount = result["ndgListCount"];
                    // let childMap = result["childMap"];
                    // let capoGruppoIdSet = result['capoGruppoIdSet'];
                    // let ndgGFMap = result['ndgGFMap'];
                    
                    // let ndgIdList = this.ndgList.map(item => item.Id);
                    // let newValueList = [];
                    // result["ndgList"].forEach(element => {

                    //     let isEligible = true;

                    //     if(element.PTF_OFS__c){

                    //         if(!this.hasOFS){

                    //             isEligible = false;
                    //         }
                    //     }

                    //     if(isEligible){

                    //         element.PTF_Url = '/' + element.Id;
                    //         let index;
    
                    //         if(isSearch){
    
                    //             index = this.selectedNDGRowIds.indexOf(element.Id);
                    //         }else{
    
                    //             index = ndgIdList.indexOf(element.Id);
                    //         }
                    //         if(index <= -1){
        
                    //             if(capoGruppoIdSet.includes(element.Id)){
    
                                    
                    //                 console.log('DK element.Id: ' + element.Id);
                    //                 if(element.Id in childMap){
                                        
                    //                     element.children = [];
                    //                     element.PTF_IsCaponugruppoIcon='utility:check';
                    //                     console.log('Has Children');
                    //                     childMap[element.Id].forEach(child => {
                                            
                    //                         child.PTF_Url = '/' + child.Id;
                    //                         child.provenanceIconName='utility:level_down';
                    //                         if(child.RecordType.DeveloperName == 'GruppoFinanziario'){
    
                    //                             child.parentId = element.Id;
                    //                         }
                    //                         element.children.push(child);
                    //                     });
                    //                     newValueList = [element].concat(element.children).concat(newValueList);
                    //                 }else{
                                        
                    //                     if(!Boolean(ndgGFMap[element.Id])){

                    //                         newValueList.push(element);
                    //                     }
                    //                 }
                    //             }else{

                    //                 if(!Boolean(ndgGFMap[element.Id])){

                    //                     newValueList.push(element);
                    //                 }
                    //             }
                    //             ndgIdList = ndgIdList.concat(newValueList.map(item => item.Id));
                    //         }
                    //     }
                    // });

                    // if(isSearch){

                    //     if(selectedNdgRows){

                    //         this.ndgList = selectedNdgRows.concat(newValueList);
                    //     }else{

                    //         this.ndgList = newValueList;
                    //     }
                    // }else{

                    //     if(isChange){

                    //         this.ndgList = newValueList;
                    //     }else{

                    //         this.ndgList = this.ndgList.concat(newValueList);
                    //     }
                    // }
                    // console.log('DK ndgList: ' + JSON.stringify(this.ndgList));
                
                    
                    
                    this.allData = result;
                    let newValueList = [];

                    for(let keyA in this.allData['accMap']){
                        this.allData['accMap'][keyA].PTF_Url = '/' + keyA;
                        newValueList.push(this.allData['accMap'][keyA]);
                    }

                    console.log('SV newValueList: ' + JSON.stringify(newValueList));

                    this.ndgList = newValueList;
                    this.filteredNdgList = this.ndgList;
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

            console.log('DK loadNDGRecords.error: ' + error);
        }
    }

    handleNDGRowSelection(event){
        
        try {
            
            let selectedRows = event.detail.selectedRows;
            console.log('DK onRow Start selectedRows: ' + JSON.stringify(selectedRows));
            console.log('DK onRow this.selectedNDGRows: ' + JSON.stringify(this.selectedNDGRows));
            let oldSelectedRowsId = this.selectedNDGRows.map(item => item.Id);
            let selectedRowsId = selectedRows.map(item => item.Id);
            selectedRows.forEach(element => {
    
                if(Boolean(element.children)){
                    
                    if(!this.selectedNDGRowIds.includes(element.Id)){
                        
                        element.children.forEach(child => {
                            
                            if(child.RecordType.DeveloperName == 'GruppoFinanziario'){

                                selectedRows.push(child);
                            }
                        });
                    }
                }else if(Boolean(element.parentId)){
    
                    if(!this.selectedNDGRowIds.includes(element.Id)){
                        
                        this.ndgList.forEach(item => {
                            
                            if(item.Id == element.parentId){

                                selectedRows.push(item);
                            }
                        });
                    }
                }
            });
    
            this.selectedNDGRows.forEach(element => {
    
                if(!selectedRowsId.includes(element.Id)){
    
                    if(Boolean(element.children)){
                    
                        console.log('DK PARENT REMOVED');
                        console.log('DK PARENT REMOVED element: ' + JSON.stringify(element));
                        let childrenIds = element.children.map(child => child.Id);
                        childrenIds.forEach(childId => {
                        
                            selectedRows.forEach(row =>{
                                
                                if(childId == row.Id){
                                    
                                    let index = selectedRows.indexOf(row);
                                    console.log('DK index: ' + index);
                                    selectedRows.splice(index, 1);
                                }
                            });
                        });
                    }else if(Boolean(element.parentId)){
    
                        selectedRows.forEach(item => {
    
                            if(item.Id == element.parentId){
                                
                                const index = selectedRows.indexOf(item);
                                selectedRows.splice(index, 1);
                            }
                        });
                    }
                }
            });
            
            console.log('DK onRow END selectedRows: ' + JSON.stringify(selectedRows));
            this.selectedNDGRows = selectedRows;
            this.selectedNDGRowIds = selectedRows.map(element => element.Id);
            console.log('DK this.selectedNDGRowIds: ' + JSON.stringify(this.selectedNDGRowIds));
        } catch (error) {
            
            console.log('DK onRow error: ' + error);
        }
    }

    handleNDGReset(){

        this.searchedNome = '';
        this.searchedNdg = '';
        this.handleNDGSearch();
    }

    // handleNDGSearch(){

    //     this.ndgOffset = 0;
    //     this.loadNDGRecords(true, false);
    // }

    handleNDGSearch(){

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
    

    handleAvanti(){
        ++this.page;
    }
    handleIndietro(){
        --this.page;
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
        let ndgToDisplay = this.filteredNdgList.slice(startIndex,endIndex);
        let finalNdgToDisplay = [];
        ndgToDisplay.forEach(element => {
            
            // console.log('DK HASCHILD: ' + Boolean(this.allData['relazioneDiAccountMap'][element.Id]));
            console.log('DK HASCHILD: ' + this.allData['relazioneDiAccountMap'].hasOwnProperty(element.Id));
            finalNdgToDisplay.push(element);
            if(this.allData['relazioneDiAccountMap'].hasOwnProperty(element.Id)){

                element.children = [];
                element.PTF_IsCaponugruppoIcon='utility:check';
                this.allData['relazioneDiAccountMap'][element.Id].forEach(ndg =>{
                    
                    ndg.PTF_Url = '/' + ndg.Id;
                    ndg.provenanceIconName='utility:level_down';
                    if(ndg.RecordType.DeveloperName == 'GruppoFinanziario'){

                        ndg.parentId = element.Id;
                    }
                    element.children.push(ndg);
                    finalNdgToDisplay.push(ndg);
                });
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