import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContact from '@salesforce/apex/AssegnaAzioniController.getContact';
import getCampaignMember from '@salesforce/apex/AssegnaAzioniController.getCampaignMember';
import getEventMember from '@salesforce/apex/AssegnaAzioniController.getEventMember';
import getOppsMember from '@salesforce/apex/AssegnaAzioniController.getOppsMember';
import reassignItem from '@salesforce/apex/AssegnaAzioniController.reassignItem';
import setCampaignMember from '@salesforce/apex/AssegnaAzioniController.setCampaignMember';
import setOpportunity from '@salesforce/apex/AssegnaAzioniController.setOpportunity';
import { refreshApex } from '@salesforce/apex';
import {TABELLA_ELENCOCAMPAGNE, TABELLA_ELENCOEVENTI,TABELLA_ELENCOMMDS,TABELLA_ELENCOREF,TABELLA_ELENCOOPP,TABELLA_ELENCOREFDAASSEGNARE,JSON_ElegibleRoleMMDS,COLUMNSLISTAREFRENTI,COLUMNSREFERENTI1, optionsStato, optionsMMDS, optionsPriorita, optionsCanale, optionsBisogno, optionsEsito, optionsFase, optionsEsitoOpp, extendCampaignEventMembers } from './utils/assegnaAzioniTabHandler';

export default class AssegnaAzioniTab extends NavigationMixin(LightningElement) {

    @track nLoad = 0;
    @api asyncThreshold;
    @track loaded = false;
    @track userNotEnabled = false;
    @track loadedAssRef = false;
    @track loadedAssOpp = false;
    @track loadedAssEvt = false;
    @track CMTabLoadedAssCmp;
    @track EVTabLoadedAssCmp;
    @track OPPTabLoadedAssCmp;
    @track error;
    @track contact;
    @track account;
    @track user;
    @track ptf;

    @track isReload = false;
    @track isCMTABReload = false;
    @track isEVTABReload = false;
    @track isOPPTABReload = false;
    @track isREFTABReload = false;

    @track activeTab = 'assEvt';

    optionsStato = optionsStato();
    optionsMMDS = optionsMMDS(); 
    optionsPriorita = optionsPriorita();
    optionsCanale = optionsCanale(); 
    optionsBisogno = optionsBisogno(); 
    optionsEsito = optionsEsito(); 
    optionsFase = optionsFase(); 
    optionsEsitoOpp = optionsEsitoOpp();

    //ELENCO CAMPAGNE
    columnsElencoCampagne = TABELLA_ELENCOCAMPAGNE;
    campMembColumns = [];
    oppColumns = TABELLA_ELENCOOPP;
    refAssColumns = TABELLA_ELENCOREFDAASSEGNARE;
    @track campaignMember;
    @api campaignData;
    @track filteredMembersCMTab = [];
    @api membersCMTab = [];
    @api assCamStep1;
    @api assCamStep2;
    @api assCamStep3;
    @api selectedCampagna;
    @api selectedCampagne = [];
    @api selectedCampagneIds = [];
    @api selectedCMTabRow = [];
    @api selectedCMTabRowIds = [];
    @api contactElegibleRoleMDS;
    @api idReferentiCMTabAssegnate = [];
    @api CMTabSelectedReferenteRowIds = [];
    @api currentReferentData;
    @track disabledButtonAssegnaCampagne = true;
    @track disabledButtonAssegnaMassivamenteCampagne = true;
    @track disabledButtonAssegnaCampagneStep2 = true;
    @track disabledButtonAssegnaCampagneStep3 = true;
    @track isAggiungiMassivamenteCM = false;

    @track counterCMTab = 0;
    //ATTRIBUTI DINAMICI
        @track typeMapCMTab = {};
        @track optionsAttributo1CMTab = [{
            label: '---Nessun filtro---',
            value: ''
        }];
        @track foundAttributo1CMTab = [];
        @track optionsAttributo2CMTab = [{
            label: '---Nessun filtro---',
            value: ''
        }];
        @track foundAttributo2CMTab = [];
        @track selectedNomeAttributo1CMTab;
        @track showRangeNum1CMTab = false;
        @track showRangeDate1CMTab = false;
        @track showSearchtext1CMTab = false;
        @track selectedNomeAttributo2CMTab;
        @track showRangeNum2CMTab = false;
        @track showRangeDate2CMTab = false;
        @track showSearchtext2CMTab = false;

        @track selectedNomeAttributo1CMTab = '';
        @track selectedValoreAttributo1StartCMTab = '';
        @track selectedValoreAttributo1EndCMTab = '';
        @track selectedNomeAttributo2CMTab = '';
        @track selectedValoreAttributo2StartCMTab = '';
        @track selectedValoreAttributo2EndCMTab = '';
        @track searchedValoreAttributo1CMTab = '';
        @track searchedValoreAttributo2CMTab = '';
        //ATTRIBUTI DINAMICI

    //ELENCO EVENTI
    columnsElencoEventi = TABELLA_ELENCOEVENTI;
    @track eventMember;
    @api eventData;
    @track filteredMembersEVTab = [];
    @api membersEVTab = [];
    @api assEvStep1 = false;
    @api assEvStep2 = false;
    @api assEvStep3 = false;
    @api selectedEvent;
    @api selectedEvents = [];
    @api selectedEventsIds = [];
    @api selectedEVTabRow = [];
    @api selectedEVTabRowIds = [];
    @api EVTabReferenteData;
    @api EVTabClientData;
    @api idReferentiEVTabAssegnate = [];
    @api EVTabSelectedReferenteRowIds = [];
    @track typeMapEVTab = {};
    @track disabledButtonAssegnaEventi = true;
    @track disabledButtonAssegnaMassivamenteEventi = true;
    @track disabledButtonAssegnaEventiStep2 = true;
    @track disabledButtonAssegnaEventiStep3 = true;
    @track isAggiungiMassivamenteEV = false;

    @track counterEVTab = 0;

        //ATTRIBUTI DINAMICI
        @track typeMapEVTab = {};
        @track optionsAttributo1EVTab = [{
            label: '---Nessun filtro---',
            value: ''
        }];
        @track foundAttributo1EVTab = [];
        @track optionsAttributo2EVTab = [{
            label: '---Nessun filtro---',
            value: ''
        }];
        @track foundAttributo2EVTab = [];
        @track showRangeNum1EVTab = false;
        @track showRangeDate1EVTab = false;
        @track showSearchtext1EVTab = false;
        @track showRangeNum2EVTab = false;
        @track showRangeDate2EVTab = false;
        @track showSearchtext2EVTab = false;
        @track selectedNomeAttributo1EVTab = '';
        @track selectedValoreAttributo1StartEVTab = '';
        @track selectedValoreAttributo1EndEVTab = '';
        @track selectedNomeAttributo2EVTab = '';
        @track selectedValoreAttributo2StartEVTab = '';
        @track selectedValoreAttributo2EndEVTab = '';
        @track searchedValoreAttributo1EVTab = '';
        @track searchedValoreAttributo2EVTab = '';
        //ATTRIBUTI DINAMICI

    //ELENCO OPPORTUNITY
    // columnsElencoOpp = TABELLA_ELENCOOPP;
    @track oppMap;
    @api filteredMembersOPPTab = [];
    @api membersOPPTab = [];
    @api assOppStep1;
    @api assOppStep2;
    @api selectedOPPTabRow = [];
    @api selectedOPPTabRowIds = [];
    @api OPPTabReferenteData;
    @api OPPTabClientData;
    @api idReferentiOPPTabAssegnate = [];
    @api OPPTabSelectedReferenteRowIds = [];
    @track disabledButtonAssegnaOpp = true;
    @track disabledButtonAssegnaOppStep2 = true;
    @track counterOPPTab = 0;

    //ELENCO CLIENTI
    columnsMDS = TABELLA_ELENCOMMDS;
    @track clientListData;
    @api CMTabClientData;

    //ELENCO REFERENTI
    columnsRef = TABELLA_ELENCOREF;
    @track referentiListData;
    @api CMTabReferenteData;

    @track membersCMREFTab = [];
    @track membersEVREFTab = [];
    @track membersOPPREFTab = [];

    @track filteredMembersCMREFTab = [];
    @track filteredMembersEVREFTab = [];
    @track filteredMembersOPPREFTab = [];

    @track selectedCMREFTabRowIds = [];
    @track selectedEVREFTabRowIds = [];
    @track selectedOPPREFTabRowIds = [];

    @track tableCMREFTabShow = false;
    @track tableEVREFTabShow = false;
    @track tableOPPREFTabShow = false;

    //ATTRIBUTI DINAMICI
    @track typeMapREFTab = {};
    @track optionsAttributo1REFTab = [{
        label: '---Nessun filtro---',
        value: ''
    }];
    @track foundAttributo1REFTab = [];
    @track optionsAttributo2REFTab = [{
        label: '---Nessun filtro---',
        value: ''
    }];
    @track foundAttributo2REFTab = [];
    @track selectedNomeAttributo1REFTab;
    @track showRangeNum1REFTab = false;
    @track showRangeDate1REFTab = false;
    @track showSearchtext1REFTab = false;
    @track selectedNomeAttributo2REFTab;
    @track showRangeNum2REFTab = false;
    @track showRangeDate2REFTab = false;
    @track showSearchtext2REFTab = false;
    @track selectedNomeAttributo1REFTab = '';
    @track selectedValoreAttributo1StartREFTab = '';
    @track selectedValoreAttributo1EndREFTab = '';
    @track selectedNomeAttributo2REFTab = '';
    @track selectedValoreAttributo2StartREFTab = '';
    @track selectedValoreAttributo2EndREFTab = '';
    @track searchedValoreAttributo1REFTab = '';
    @track searchedValoreAttributo2REFTab = '';
    //ATTRIBUTI DINAMICI
    startTimeGetContact;
    endTimeGetContact;
    startTimeHandleGetEventMember;
    endTimeHandleGetEventMember;
    startTimeHandleGetCampaignMember;
    endTimeHandleGetCampaignMember;
    startTimeHandleGetOppsMember;
    endTimeHandleGetOppsMember;
    startTimeHandleGetRefrenti;
    endTimeHandleGetRefrenti;
    startTimeFinally;
    endTimeFinally;

    connectedCallback(){
        this.loaded = false;
        //TAB REFERENTI
        this.columnsListaRefrenti = COLUMNSLISTAREFRENTI;

        if(!Boolean(this.defaultLimit)){

            this.defaultLimit = this.perpage;
        }

        let dataTableGlobalStyle = document.createElement('style');
            dataTableGlobalStyle.innerHTML = `
            lightning-tree-grid lightning-primitive-header-actions {
                display: none;
            }`;
            document.head.appendChild(dataTableGlobalStyle);
        this.startTimeGetContact = new Date();
        getContact()
        .then(result => {
            this.endTimeGetContact = new Date();
            console.log('GetContact Time: ', this.endTimeGetContact - this.startTimeGetContact);
            console.log('SV getContact result', result);
            this.user = result.userMap;
            console.log('Permissionset: ', this.user.PTF_User__r.CRM_PermissionSet__c);
            if(!this.user.PTF_User__r.CRM_HasLab__c && this.user.PTF_ProfiloLDAP__c !='NEC_ADMIN' && this.user.PTF_User__r.CRM_PermissionSet__c!='NEC_CRM.CEN.IMPR.RESP.SPEC.1'){
                this.userNotEnabled = true;
                
                return
            }else{
                this.userNotEnabled = false;
            }
            
            this.asyncThreshold = result.AssegnazioniAzioniConfig.Async_Threshold__c;
            this.contact = result.contactMap; 
            this.account = result.accMap;
            this.ptf = result.ptfMap;
            this.startTimeHandleGetEventMember = new Date();
            this.handleGetEventMember()
            .then(() =>{
                this.endTimeHandleGetEventMember = new Date();
                console.log('GetEventMember Time: ', this.endTimeHandleGetEventMember - this.startTimeHandleGetEventMember);
                this.loaded = true;
                if(!this.isReload){
                    this.assEvStep1 = true;
                }
                this.startTimeHandleGetCampaignMember = new Date();
                this.handleGetCampaignMember()
                .then(() =>{
                    this.endTimeHandleGetCampaignMember = new Date();
                    console.log('GetCampaignMember Time: ', this.startTimeHandleGetCampaignMember - this.endTimeHandleGetCampaignMember);
                    this.startTimeHandleGetOppsMember = new Date();
                    this.handleGetOppsMember()
                    .then(() =>{
                        this.endTimeHandleGetOppsMember = new Date();
                        console.log('GetOppsMember Time: ', this.endTimeHandleGetOppsMember - this.startTimeHandleGetOppsMember);
                        this.handleGetRefrenti();
                    });
                });
            });
        })
        .catch(error => {
            this.error = error;
            console.log('ERROR', error);
        })
        .finally(() => {
            if(this.userNotEnabled){
                //this.loaded = true;
                return
            }
            this.startTimeFinally = new Date();
            let contactMap = this.contact;
            // console.log('contactMap', contactMap);
            let obj = {};
            obj.Family = [];
            obj.POE = [];
            obj.POE_Family = [];
            obj.Tecnico = [];
            for(let key in contactMap){
                let x = {};
                x = contactMap[key];
                let keySplit = key.split('_');
                if(JSON_ElegibleRoleMMDS.POE.includes(keySplit[0])){
                    obj.POE.push(x)
                }
                if(JSON_ElegibleRoleMMDS.Family.includes(keySplit[0])){
                    obj.Family.push(x)
                }
                if(JSON_ElegibleRoleMMDS.POE_Family.includes(keySplit[0])){
                    obj.POE_Family.push(x)
                }
                if(!JSON_ElegibleRoleMMDS.ruoliDisattivi.includes(keySplit[0])){
                    obj.Tecnico.push(x)
                }
            }
            this.contactElegibleRoleMDS = JSON.parse(JSON.stringify(obj));
            this.endTimeFinally = new Date();
            console.log('Finally Time: ', this.endTimeFinally - this.startTimeFinally);
        });
    }

    handleGetCampaignMember(){
        console.log('DK START getCampaignMember');
        return getCampaignMember({ })
        .then(result => {
            console.log('SV getCampaignMember result', result);
            this.campaignMember = {};
            this.campaignMemberList = [];
            result.campaignMemberList.forEach(element =>{
                if(Boolean(element.CRM_AssegnatarioUser__c) /*&& this.user.PTF_IdCED__c === element.CRM_AssegnatarioUser__r.idced__c*/){
                    this.campaignMemberList.push(element);
                }
                this.campaignMember[element.Campaign__c + '_' + element.CRM_CampaignMemberId__c + '_' + element.PTF_ModelloDiServizio__c] = element;
            });
        })
        .catch(error => {
            this.error = error;
            console.log('ERROR', error);
        })
        .finally(() => {
            
            let response = extendCampaignEventMembers(this.campaignMember);
            this.campaignData = response.data;

            var ordering = {}, // map for efficient lookup of sortIndex
            sortOrder = ['Family','POE','Non Portafogliati','Assente','Residuale'];
            for (var i=0; i<sortOrder.length; i++)
                ordering[sortOrder[i]] = i;

            response.clientListData.sort( function(a, b) {
                return (ordering[a.modelloServizio] - ordering[b.modelloServizio]);
            });

            this.CMTabClientData = response.clientListData;
            response.referentiListData.sort((a, b) => {
                if (a.nomeRisorsa === b.nomeRisorsa) return 0;
                return a.nomeRisorsa > b.nomeRisorsa ? 1 : -1;
              });
            this.CMTabReferenteData = response.referentiListData;

            this.foundAttributo1CMTab = response.foundAttributo1;
            this.foundAttributo2CMTab = response.foundAttributo2;
            this.typeMapCMTab = response.typeMap;
            this.idReferentiCMTabAssegnate = response.idReferentiAssegnate;
            if(!this.isReload){

                this.CMTabLoadedAssCmp = true;
            }
        });
    }

    handleGetEventMember(){
        console.log('DK START getEventMember');
        return getEventMember({ })
        .then(result => {
            console.log('SV getEventMember result', result);
            this.eventMember = {};
            this.eventsMemberList = [];
            result.eventsMemberList.forEach(element =>{
                if(Boolean(element.CRM_AssegnatarioUser__c) /*&& this.user.PTF_IdCED__c === element.CRM_AssegnatarioUser__r.idced__c*/){
                    this.eventsMemberList.push(element);
                }
                this.eventMember[element.Campaign__c + '_' + element.CRM_CampaignMemberId__c + '_' + element.PTF_ModelloDiServizio__c] = element;
            });
        })
        .catch(error => {
            this.error = error;
            console.log('ERROR', error);
        }).finally(() => {
            let response = extendCampaignEventMembers(this.eventMember);
            // console.log('SV eventListData', response.data);
            this.eventData = response.data;

            // console.log('SV clientListData', response.clientListData);
            var ordering = {}, // map for efficient lookup of sortIndex
            sortOrder = ['Family','POE','Non Portafogliati','Assente','Residuale'];
            for (var i=0; i<sortOrder.length; i++)
                ordering[sortOrder[i]] = i;

            response.clientListData.sort( function(a, b) {
                return (ordering[a.modelloServizio] - ordering[b.modelloServizio]);
            });
            this.EVTabClientData = response.clientListData;

            // console.log('SV referentiListData', response.referentiListData);
            response.referentiListData.sort((a, b) => {
                if (a.nomeRisorsa === b.nomeRisorsa) return 0;
                return a.nomeRisorsa > b.nomeRisorsa ? 1 : -1;
            });
            
            this.EVTabReferenteData = response.referentiListData;
            this.typeMapEVTab = response.typeMap;
            this.idReferentiEVTabAssegnate = response.idReferentiAssegnate;
            if(!this.isReload){

                this.EVTabLoadedAssCmp = true; 
            }
        });
    }

    handleGetOppsMember(){
        console.log('DK START getOppsMember');
        return getOppsMember({idCed: this.user.PTF_IdCED__c})
        .then(result => {
            console.log('SV getOppsMember result', result);
            this.oppMap = {};
            this.oppsList = [];
            result.oppsList.forEach(element =>{
                if(Boolean(element.Owner) && this.user.PTF_IdCED__c === element.Owner.idced__c){
                    this.oppsList.push(element);
                }
                this.oppMap[element.Id + '_' + element.OwnerId + '_' + element.DescrizioneMds__c] = element;
            });
        })
        .catch(error => {
            this.error = error;
            console.log('ERROR', error);
        })
        .finally(() =>{
            let opp = this.oppMap;
            let oppListData = [];
            let clientListData = [];
            let referentiListData = [];
            for(let keyC in opp){
                
                let keyArray = keyC.split('_');
                opp[keyC] = JSON.parse(JSON.stringify(opp[keyC]));
                opp[keyC].CRM_NDG = opp[keyC].Account.CRM_NDG__c;
                opp[keyC].CRM_OppName = opp[keyC].Name;
                opp[keyC].CRM_Esito__c = opp[keyC].CRM_EsitoContatto__c;
                opp[keyC].PTF_OppUrl = '/' + opp[keyC].Id;
                opp[keyC].PTF_ModelloDiServizio = Boolean(opp[keyC].DescrizioneMds__c) ? opp[keyC].DescrizioneMds__c : 'Non Portafogliati';
                opp[keyC].CRM_StatoAssegnazione = opp[keyC].hasOwnProperty('CRM_Assegnatario__c') ? 'Assegnato' : 'Non assegnato';
                opp[keyC].CRM_ReferenteName = opp[keyC].hasOwnProperty('CRM_Assegnatario__c') ? opp[keyC].CRM_Assegnatario__r.Name : '';
                opp[keyC].CRM_AccName =opp[keyC].hasOwnProperty('Account') ? opp[keyC].Account.Name : '';
                opp[keyC].PTF_AccountUrl = '/' + opp[keyC].AccountId;
                opp[keyC].dataScadenza = opp[keyC].CloseDate;
                oppListData.push(opp[keyC]);

                let findClient = clientListData.filter(obj => {
                    return obj.modelloServizio === keyArray[2]
                })

                let findReferente = [];
                if(opp[keyC].hasOwnProperty('Owner')){
                    this.idReferentiOPPTabAssegnate.push(opp[keyC].OwnerId);
                    findReferente = referentiListData.filter(obj => {
                        return obj.Id === opp[keyC].OwnerId
                    })
                }
                
                if(opp[keyC].Owner.idced__c === this.user.PTF_IdCED__c){

                    if(findClient.length === 0){
                        let obj = {};
                        obj.modelloServizio = keyArray[2];
    
                        obj.countNum = 1;
                        obj.countDaAss = opp[keyC].hasOwnProperty('Owner') ? 0 : 1;
    
                        clientListData.push(obj);
    
                    } else {
                        findClient[0].countNum = findClient[0].countNum + 1;
                        findClient[0].countDaAss = opp[keyC].hasOwnProperty('Owner') ? findClient[0].countDaAss : findClient[0].countDaAss + 1;
                    }
                    
                    if(findReferente.length === 0){
                        let obj = {};
                        obj.Id = opp[keyC].OwnerId;
                        obj.nomeRisorsa = opp[keyC].Owner.Name;

                        obj.numeroContatti = 1;

                        obj._children = [];
                        let objChild = {};
                        objChild.Id = keyArray[0];
                        objChild.nomeRisorsa = opp[keyC].CRM_Bisogno__c;
                        objChild.numeroContatti = 1;

                        obj._children.push(objChild);
                        referentiListData.push(obj);

                    } else {
                        findReferente[0].numeroContatti = findReferente[0].numeroContatti + 1;
                        let findEventRef = findReferente[0]._children.filter(obj => {
                            return obj.Id === keyArray[0]
                        })

                        if(findEventRef.length === 0){

                            if(findReferente[0].hasOwnProperty('_children')){
                                let trovato = false;

                                findReferente[0]._children.forEach(elementChild =>{
                                    if(elementChild.nomeRisorsa === opp[keyC].CRM_Bisogno__c){
                                        elementChild.numeroContatti = elementChild.numeroContatti + 1;
                                        trovato = true;
                                    }
                                });
                                if(!trovato){
                                    let objChild = {};
                                    objChild.Id = keyArray[0];
                                    objChild.nomeRisorsa = opp[keyC].CRM_Bisogno__c;
                                    objChild.numeroContatti = 1;

                                    findReferente[0]._children.push(objChild);
                                }
                            } else {
                                let objChild = {};
                                objChild.Id = keyArray[0];
                                objChild.nomeRisorsa = opp[keyC].CRM_Bisogno__c;
                                objChild.numeroContatti = 1;

                                findReferente[0]._children.push(objChild);
                            }
                        } else {
                            findEventRef[0].numeroContatti = findEventRef[0].numeroContatti + 1;
                        }
                    }
                }
            }

            oppListData.sort((a, b) => { return a.CloseDate === b.CloseDate ? 0 : (a.CloseDate > b.CloseDate ? 1 : -1)});

            this.membersOPPTab = oppListData;
            this.filteredMembersOPPTab = this.membersOPPTab;
            this.varTab = 'OPPTab';
            this.handleReset();
            this.handleSearch();
            this.setPages(this.filteredMembersOPPTab);

            this.OPPTabClientData = clientListData;
            referentiListData.sort((a, b) => {
                if (a.nomeRisorsa === b.nomeRisorsa) return 0;
                return a.nomeRisorsa > b.nomeRisorsa ? 1 : -1;
            });
            console.log('SV referentiListData', referentiListData);
            this.OPPTabReferenteData = referentiListData;

            if(!this.isReload){

                this.OPPTabLoadedAssCmp = true; 
            }
        });
    }

    @track campaignColumnsIsSet = {};

    //START - TAB CAMPAGNE
    handleCampaignSelection(event){
        let cMFromSelectedCampaign = [];
        let selectedRowsArray = event.detail.selectedRows.map(element => element.Id);
        this.selectedCampagne = event.detail.selectedRows;
        let selectedRow = selectedRowsArray.length == 1 ? selectedRowsArray[0] : '';
        let campaign = this.campaignMember;
        let set = this.campaignColumnsIsSet[selectedRow.Id] ? this.campaignColumnsIsSet[selectedRow.Id] : false;
        try {
            
            for(let keyC in campaign){
                let keyArray = keyC.split('_');
                if(selectedRowsArray.includes(keyArray[0])){
                    cMFromSelectedCampaign.push(campaign[keyC]);
                    if(!set){
                        this.campMembColumns = [
                            { label: 'NDG', fieldName: 'PTF_AccountUrl', type: 'url', sortable: "true", hideDefaultActions: true, typeAttributes: {hideDefaultActions: true, label: { fieldName: 'CRM_NDG' }}},
                            { label: 'Nome Cliente', fieldName: 'CRM_AccountName', sortable: "true", hideDefaultActions: true, wrapText: true,target: '_self' },
                            { label: 'M-MDS', fieldName: 'PTF_ModelloDiServizio', sortable: "true", hideDefaultActions: true, wrapText: true },
                            //{ label: 'Portafoglio', fieldName: 'PTF_PortafoglioUrl', sortable: "true", type: 'url', typeAttributes: {label: { fieldName: 'PTF_Portafoglio' }} },
                            { label: 'Portafoglio', fieldName: 'PTF_Portafoglio', sortable: "true", hideDefaultActions: true, wrapText: true },
                            { label: 'Miniportafoglio', fieldName: 'PTF_Miniportafoglio', sortable: "true", hideDefaultActions: true, wrapText: true },
                            
                            { label: 'Stato Assegnazione', fieldName: 'CRM_StatoAssegnazione', sortable: "true", hideDefaultActions: true, wrapText: true },
                            { label: 'Nome Referente', fieldName: 'CRM_ReferenteName', sortable: "true", hideDefaultActions: true, wrapText: true },
                            { label: 'Esito Contatto', fieldName: 'CRM_Esito__c', sortable: "true", hideDefaultActions: true, wrapText: true },
                            { label: 'Autore Esitazione', fieldName: 'CRM_Autore__c', sortable: "true", hideDefaultActions: true, wrapText: true }
                        ];
                        if(Boolean(campaign[keyC].Campaign__r.CRM_Nome_Attributo_1_formula__c)){

                            this.campMembColumns.push({ label: campaign[keyC].Campaign__r.CRM_Nome_Attributo_1_formula__c, fieldName: 'CRM_ValoreAttributo1', type: this.typeMapCMTab[campaign[keyC].Campaign__r.CRM_Nome_Attributo_1_formula__c], sortable: "true", cellAttributes: { alignment: 'left' }});
                            this.optionsAttributo1CMTab = [];
                            this.optionsAttributo1CMTab.push({
                                label: campaign[keyC].Campaign__r.CRM_Nome_Attributo_1_formula__c,
                                value: campaign[keyC].Campaign__r.CRM_Nome_Attributo_1_formula__c
                            });
                        }
                        if(Boolean(campaign[keyC].Campaign__r.CRM_Nome_Attributo_2_formula__c)){

                            this.campMembColumns.push({ label: campaign[keyC].Campaign__r.CRM_Nome_Attributo_2_formula__c, fieldName: 'CRM_ValoreAttributo2', type: this.typeMapCMTab[campaign[keyC].Campaign__r.CRM_Nome_Attributo_2_formula__c], sortable: "true", cellAttributes: { alignment: 'left' }});
                            this.optionsAttributo2CMTab = [];
                            this.optionsAttributo2CMTab.push({
                                label: campaign[keyC].Campaign__r.CRM_Nome_Attributo_2_formula__c,
                                value: campaign[keyC].Campaign__r.CRM_Nome_Attributo_2_formula__c
                            }); 
                        }
                        set = true;
                        this.campaignColumnsIsSet[selectedRow] = true;
                    }
                }
            }
    
            this.membersCMTab = JSON.parse(JSON.stringify(cMFromSelectedCampaign));
            this.varTab = 'CMTab';
            this.handleReset();
            this.handleSearch();
            this.setPages(this.filteredMembersCMTab);
            if(event.detail.selectedRows.length > 1){

                this.disabledButtonAssegnaMassivamenteCampagne = false; 
                this.disabledButtonAssegnaCampagne = true;
            }else if(event.detail.selectedRows.length == 1){
    
                this.disabledButtonAssegnaCampagne = false;
                this.disabledButtonAssegnaMassivamenteCampagne = false; 
                this.selectedCampagna = event.detail.selectedRows[0];
            }else{
    
                this.disabledButtonAssegnaCampagne = true;
                this.disabledButtonAssegnaMassivamenteCampagne = true; 
            }
        } catch (error) {
            console.log('DK handleCampaignSelection error: ', error);
        }
    }

    handleCampaignSelectionStep2(event){
        let countSelectedOppRows = event.detail.selectedRows.length;
        this.counterCMTab = countSelectedOppRows;
        for(let currentPage of Object.keys(this.CMTabSelectRowsMap)) {
            if(currentPage != this.CMTabPage){

                this.counterCMTab += this.CMTabSelectRowsMap[currentPage].length
            }
        }
        if(this.counterCMTab > 0){          
            this.disabledButtonAssegnaCampagneStep2 = false;
        } else {
            this.disabledButtonAssegnaCampagneStep2 = true;
        }
    }

    handleAssegnaCMTabRequest(event){
        let selectedNdgRows = [];
        if(event.target.name == 'assegnaMassivamenteCampagne'){

            console.log('DK this.membersCMTab.length', this.membersCMTab.length);
            selectedNdgRows = this.membersCMTab.filter(record => {return record.CRM_StatoAssegnazione === 'Non assegnato'});
            console.log('DK selectedNdgRows.length', selectedNdgRows.length);
            this.isAggiungiMassivamenteCM = true;
        }else{
            
            let campaignMembersTable = this.template.querySelector("[data-item='campaignMembersTable']");
            // aggiungo alla lista degli elementi selzionati le righe nelle pagina corrente
            if(campaignMembersTable){
                selectedNdgRows = campaignMembersTable.getSelectedRows();
            }
            for(let currentPage of Object.keys(this.CMTabSelectRowsMapValues)){
                if(currentPage != this.CMTabPage){
                    this.CMTabSelectRowsMapValues[currentPage].forEach(element =>{
    
                        selectedNdgRows.push(element);
                    });
                }
            }
            this.isAggiungiMassivamenteCM = false;
        }
        // aggiungo alla lista degli elementi selzionati le righe nelle altre pagine
        this.selectedCMTabRow = JSON.parse(JSON.stringify(selectedNdgRows));
        
        let userToShow = this.handleGetCurrentReferenteData(selectedNdgRows);
        
        this.currentReferentData = userToShow;
        this.assCamStep1 = false;
        this.assCamStep2 = false;
        this.assCamStep3 = true;
    }

    handleReferenteSelection(event){
        let selectedReferentRows = event.detail.selectedRows[0].PTF_User__c;
        this.CMTabSelectedReferenteRowIds = event.detail.selectedRows[0].PTF_User__c;
        this.disabledButtonAssegnaCampagneStep3 = false;
    }

    @track handleAssegnaReferenteRequestCMTabClicked = false;
    handleAssegnaReferenteRequestCMTab(event){
        if(this.handleAssegnaReferenteRequestCMTabClicked == false){
            this.handleAssegnaReferenteRequestCMTabClicked = true;
            this.messaggioIsBatch = this.selectedEVTabRow.length > this.asyncThreshold ? 'Verrai notificato quando l\'assegnazione massiva sarà completata.\n' : '';
            this.openDialog = true;
        }else{

            this.openDialog = false;
            let selectedReferentRows = this.CMTabSelectedReferenteRowIds;
    
            let selectedCMTabRows = this.selectedCMTabRow;
    
            let listCampaignMemberIds = [];
            for(let cm of selectedCMTabRows){
                listCampaignMemberIds.push(cm.CRM_CampaignMemberId__c);
            }
            this.showSpinner = true;
            let start = new Date().getTime();

            let messaggio = listCampaignMemberIds.length > this.asyncThreshold ? 'assegnazione in corso...' : undefined;
            setCampaignMember({
                userList: selectedReferentRows,
                cmList: listCampaignMemberIds,
                asyncThreshold : this.asyncThreshold
            })
            .then(result => {
                
                console.log('result', result);
                this.isReload = true;
                this.isCMTABReload = true;
            })
            .catch(error => {
                this.error = error;
                console.log('ERROR', error);
            })
            .finally(() => {
                let end = new Date().getTime();
                let time = end - start;
                this.resetSelections();
                this.reload(messaggio);
                console.log('Execution time setCampaignMember: ' + time);
                
            });
        }
    }
    //END - TAB CAMPAGNE

    resetSelections(){
        this.selectedCMTabRow = [];
        this.selectedEVTabRow = [];
        this.selectedOPPTabRow = [];
        this.selectedCMTabRowIds = [];
        this.selectedEVTabRowIds = [];
        this.selectedOPPTabRowIds = [];
        this.CMTabSelectRowsMapValues = {}
        this.CMTabSelectRowsMap = {};
        this.EVTabSelectRowsMapValues = {}
        this.EVTabSelectRowsMap = {};
        this.OPPTabSelectRowsMapValues = {}
        this.OPPTabSelectRowsMap = {};
        this.CMREFTabSelectRowsMapValues = {}
        this.CMREFTabSelectRowsMap = {}
        this.EVREFTabSelectRowsMapValues = {}
        this.EVREFTabSelectRowsMap = {}
        this.OPPREFTabSelectRowsMapValues = {}
        this.OPPREFTabSelectRowsMap = {}
        this.counterCMREFTab = 0;
        this.counterEVREFTab = 0;
        this.counterOPPREFTab = 0;
        this.counterCMTab = 0;
        this.counterEVTab = 0;
        this.counterOPPTab = 0;
    }

    
    //START - TAB EVENT
    handleEventSelection(event){

        try {
            
            let cMFromSelectedEvent = [];
            let selectedRowsArray = event.detail.selectedRows.map(element => element.Id);
            this.selectedEvents = event.detail.selectedRows;
            let selectedRow = selectedRowsArray.length == 1 ? selectedRowsArray[0] : '';
            let evento = this.eventMember;
            let set = this.campaignColumnsIsSet[selectedRow] ? this.campaignColumnsIsSet[selectedRow] : false;
            for(let keyC in evento){
                let keyArray = keyC.split('_');
                if(selectedRowsArray.includes(keyArray[0])){
                    cMFromSelectedEvent.push(evento[keyC]);
                    if(!set){
                        this.campMembColumns = [
                            { label: 'NDG', fieldName: 'PTF_AccountUrl', type: 'url',  sortable: "true",hideDefaultActions: true, typeAttributes: {hideDefaultActions: true, label: { fieldName: 'CRM_NDG' }}},
                            { label: 'Nome Cliente', fieldName: 'CRM_AccountName', sortable: "true",hideDefaultActions: true, wrapText: true,target: '_self' },
                            { label: 'M-MDS', fieldName: 'PTF_ModelloDiServizio', sortable: "true", hideDefaultActions: true, wrapText: true },
                            //{ label: 'Portafoglio', fieldName: 'PTF_PortafoglioUrl', type: 'url', typeAttributes: {label: { fieldName: 'PTF_Portafoglio' }} },
                            { label: 'Portafoglio', fieldName: 'PTF_Portafoglio', sortable: "true", hideDefaultActions: true, wrapText: true },
                            { label: 'Miniportafoglio', fieldName: 'PTF_MiniPortafoglio', sortable: "true", hideDefaultActions: true, wrapText: true },
                            { label: 'Stato Assegnazione', fieldName: 'CRM_StatoAssegnazione', sortable: "true", hideDefaultActions: true, wrapText: true },
                            { label: 'Nome Referente', fieldName: 'CRM_ReferenteName', sortable: "true", hideDefaultActions: true, wrapText: true },
                            { label: 'Esito Contatto', fieldName: 'CRM_Esito__c', sortable: "true", hideDefaultActions: true, wrapText: true },
                            { label: 'Autore Esitazione', fieldName: 'CRM_Autore__c', sortable: "true", hideDefaultActions: true, wrapText: true }
                        ];
                        if(Boolean(evento[keyC].Campaign__r.CRM_Nome_Attributo_1_formula__c)){

                            this.campMembColumns.push({ label: evento[keyC].Campaign__r.CRM_Nome_Attributo_1_formula__c, fieldName: 'CRM_ValoreAttributo1', type: this.typeMapEVTab[evento[keyC].Campaign__r.CRM_Nome_Attributo_1_formula__c], sortable: "true", cellAttributes: { alignment: 'left' }});
                            this.optionsAttributo1EVTab = [];
                            this.optionsAttributo1EVTab.push({
                                label: evento[keyC].Campaign__r.CRM_Nome_Attributo_1_formula__c,
                                value: evento[keyC].Campaign__r.CRM_Nome_Attributo_1_formula__c
                            });
                        }
                        if(Boolean(evento[keyC].Campaign__r.CRM_Nome_Attributo_2_formula__c)){
                            this.campMembColumns.push({ label: evento[keyC].Campaign__r.CRM_Nome_Attributo_2_formula__c, fieldName: 'CRM_ValoreAttributo2', type: this.typeMapEVTab[evento[keyC].Campaign__r.CRM_Nome_Attributo_2_formula__c], sortable: "true", cellAttributes: { alignment: 'left' }});
                            this.optionsAttributo2EVTab = [];
                            this.optionsAttributo2EVTab.push({
                                label: evento[keyC].Campaign__r.CRM_Nome_Attributo_2_formula__c,
                                value: evento[keyC].Campaign__r.CRM_Nome_Attributo_2_formula__c
                            }); 
                        }
                        set = true;
                        this.campaignColumnsIsSet[selectedRow] = true;
                    }
                }
            }
    
            this.membersEVTab = JSON.parse(JSON.stringify(cMFromSelectedEvent));
            this.varTab = 'EVTab';
            this.handleReset();
            this.handleSearch();
            this.setPages(this.filteredMembersEVTab);
            if(event.detail.selectedRows.length > 1){
    
                this.disabledButtonAssegnaMassivamenteEventi = false; 
                this.disabledButtonAssegnaEventi = true;
            }else if(event.detail.selectedRows.length == 1){
    
                this.disabledButtonAssegnaEventi = false;
                this.disabledButtonAssegnaMassivamenteEventi = false; 
                this.selectedEvent = event.detail.selectedRows[0];
            }else{
    
                this.disabledButtonAssegnaEventi = true;
                this.disabledButtonAssegnaMassivamenteEventi = true; 
            }
        } catch (error) {
            console.log('DK error: ', error);
            
        }
    }

    handleEventSelectionStep2(event){
        let countSelectedOppRows = event.detail.selectedRows.length;
        this.counterEVTab = countSelectedOppRows;
        for(let currentPage of Object.keys(this.EVTabSelectRowsMap)) {
            if(currentPage != this.EVTabPage){

                this.counterEVTab += this.EVTabSelectRowsMap[currentPage].length
            }
        }
        if(this.counterEVTab > 0){          
            this.disabledButtonAssegnaEventiStep2 = false;
        } else {
            this.disabledButtonAssegnaEventiStep2 = true;
        }
    }

    handleAssegnaEVTabRequest(event){

        let selectedNdgRows = [];
        if(event.target.name == 'assegnaMassivamenteEventi'){

            selectedNdgRows = this.membersEVTab.filter(record => {return record.CRM_StatoAssegnazione === 'Non assegnato'});
            this.isAggiungiMassivamenteEV = true;
        }else{
            let eventMembersTable = this.template.querySelector("[data-item='eventMembersTable']");
            // aggiungo alla lista degli elementi selzionati le righe nelle pagina corrente
            if(eventMembersTable){
                selectedNdgRows = eventMembersTable.getSelectedRows();
            }
            // aggiungo alla lista degli elementi selzionati le righe nelle altre pagine
            for(let currentPage of Object.keys(this.EVTabSelectRowsMapValues)){
                if(currentPage != this.EVTabPage){
                    this.EVTabSelectRowsMapValues[currentPage].forEach(element =>{
    
                        selectedNdgRows.push(element);
                    });
                }
            }
            this.isAggiungiMassivamenteEV = false;
        }

        this.selectedEVTabRow = JSON.parse(JSON.stringify(selectedNdgRows));        
        let userToShow = this.handleGetCurrentReferenteData(selectedNdgRows);
        
        this.currentReferentData = userToShow;
        this.assEvStep1 = false;
        this.assEvStep2 = false;
        this.assEvStep3 = true;
    }
    
    handleReferenteEVTabSelection(event){
        let selectedReferentRows = event.detail.selectedRows[0].PTF_User__c;
        this.EVTabSelectedReferenteRowIds = event.detail.selectedRows[0].PTF_User__c;
        // console.log('selectedReferentRows: ', selectedReferentRows);
        this.disabledButtonAssegnaEventiStep3 = false;
    }
    @track messaggioIsBatch = '';

    @track handleAssegnaReferenteRequestEVTabClicked = false;
    handleAssegnaReferenteRequestEVTab(event){
        if(this.handleAssegnaReferenteRequestEVTabClicked == false){
            this.handleAssegnaReferenteRequestEVTabClicked = true;
            this.messaggioIsBatch = this.selectedEVTabRow.length > this.asyncThreshold ? 'Verrai notificato quando l\'assegnazione massiva sarà completata.\n' : '';
            this.openDialog = true;
        }else{

            // this.loaded = false;
            this.openDialog = false;
            let selectedReferentRows = this.EVTabSelectedReferenteRowIds;
            let selectedEVTabRows = this.selectedEVTabRow; 
            let listCampaignMemberIds = [];
            for(let cm of selectedEVTabRows){
                listCampaignMemberIds.push(cm.CRM_CampaignMemberId__c);
            }
            this.showSpinner = true;
            let messaggio = listCampaignMemberIds.length > this.asyncThreshold ? 'assegnazione in corso...' : undefined;
            let start = new Date().getTime();
            setCampaignMember({
                userList: selectedReferentRows,
                cmList: listCampaignMemberIds,
                asyncThreshold : this.asyncThreshold
            })
            .then(result => {
                console.log('result', result);
                this.isReload = true;
                this.isEVTABReload = true;
            })
            .catch(error => {
                this.error = error;
                console.log('ERROR', error);
            })
            .finally(() => {
                let end = new Date().getTime();
                let time = end - start;
                this.resetSelections();
                this.reload(messaggio);
                console.log('Execution time setEventMember: ' + time);
                // this.loaded = true;
            });
        }
    }
    //END - TAB EVENTI

    //START - TAB OPPORTUNITY
    handleOppSelection(event){
        let countSelectedOppRows = event.detail.selectedRows.length;
        this.counterOPPTab = countSelectedOppRows;
        for(let currentPage of Object.keys(this.OPPTabSelectRowsMap)) {
            if(currentPage != this.OPPTabPage){

                this.counterOPPTab += this.OPPTabSelectRowsMap[currentPage].length
            }
        }
        if(countSelectedOppRows > 0){          
            this.disabledButtonAssegnaOpp = false;
        } else {
            this.disabledButtonAssegnaOpp = true;
        }
    }
    handleAssegnaOPPTabRequest(event){
        let oppMembersTable = this.template.querySelector("[data-item='oppMembersTable']");
        let selectedOppRows = [];
        // aggiungo alla lista degli elementi selzionati le righe nelle pagina corrente
        if(oppMembersTable){
            selectedOppRows = oppMembersTable.getSelectedRows();
        }
        // aggiungo alla lista degli elementi selzionati le righe nelle altre pagine
        for(let currentPage of Object.keys(this.OPPTabSelectRowsMapValues)){
            // console.log('DK currentPage: ', currentPage);
            // console.log('DK this.OPPTabPage: ', this.OPPTabPage);
            if(currentPage != this.OPPTabPage){
                this.OPPTabSelectRowsMapValues[currentPage].forEach(element =>{

                    selectedOppRows.push(element);
                });
            }
        }

        this.selectedOPPTabRow = JSON.parse(JSON.stringify(selectedOppRows));
        // console.log('SV LIST: ', selectedOppRows);

        let userToShow = this.handleGetCurrentReferenteData(selectedOppRows);

        this.currentReferentData = userToShow;
        this.assOppStep1 = false;
        this.assOppStep2 = true;
    }
    
    handleReferenteOPPTabSelection(event){
        let selectedReferentRows = event.detail.selectedRows[0].PTF_User__c;
        this.OPPTabSelectedReferenteRowIds = event.detail.selectedRows[0].PTF_User__c;
        // console.log('selectedReferentRows: ', selectedReferentRows);
        this.disabledButtonAssegnaOppStep2 = false;
    }

    @track handleAssegnaReferenteRequestOPPTabClicked = false;
    handleAssegnaReferenteRequestOPPTab(event){
        // this.loaded = false;
        try {
            
            if(this.handleAssegnaReferenteRequestOPPTabClicked == false){
                this.handleAssegnaReferenteRequestOPPTabClicked = true;
                this.openDialog = true;
            }else{
                this.openDialog = false;
    
                let selectedReferentRows = this.OPPTabSelectedReferenteRowIds;
                // console.log('selectedReferentRows: ', selectedReferentRows);
        
                let selectedOPPTabRows = this.selectedOPPTabRow;
                // console.log('selectedOPPTabRows: ', selectedOPPTabRows);
        
                let listOppIds = [];
                for(let cm of selectedOPPTabRows){
                    listOppIds.push(cm.Id);
                }
                this.showSpinner = true;
                let start = new Date().getTime();
                setOpportunity({
                    userList: selectedReferentRows,
                    oppList: listOppIds,
                })
                .then(result => {
                    // console.log('result', result);
                    this.isReload = true;
                    this.isOPPTABReload = true;
                })
                .catch(error => {
                    this.error = error;
                    console.log('ERROR', error);
                })
                .finally(() => {
        
                    // this.loaded = true;
                    let end = new Date().getTime();
                    let time = end - start;
                    this.reload();
                    console.log('Execution time setOpportunity: ' + time);
                });
            }
        } catch (error) {
            console.log('error:', error);
        }
    }
    //END - TAB OPPORTUNITY


    //START - TAB REFERENTI
    @track isAssignmentDisabled = true;
    @track columnsRef1 = [];
    @track userDataRows;
    @track recId = '';
    @track showSpinner;
    @track userIdToWorkloadMap = {};
    @track campaignMemberList = [];
    @track eventsMemberList = [];
    @track oppsList = [];
    @track tableData = [];
    @track columnsListaRefrenti = [];
    @track assRefStep1 = true;
    @track assRefStep2 = false;
    @track assRefStep3 = false;
    @track disbaleRefAssignButton = true;
    @track disabledButtonAssegnaRefStep2 = true;

    @track userAssignmentMap = {};
    handleGetRefrenti(){
        this.startTimeHandleGetRefrenti = new Date();
        this.userAssignmentMap = {};
        this.userIdToWorkloadMap = {};
        this.campaignMemberList.forEach(campaignMember =>{
            let userId = campaignMember.CRM_AssegnatarioUser__c;
            if(!Boolean(this.userAssignmentMap[userId])){
                this.userAssignmentMap[userId] = {};
            }
            if(!Boolean(this.userAssignmentMap[userId].campaignMembers)){
                this.userAssignmentMap[userId].campaignMembers = [];
            }
            if(Boolean(this.userIdToWorkloadMap[userId])){
                let cpw = {};
                cpw.campaignName = campaignMember.Campaign__r.Name;
                if(Boolean(this.userIdToWorkloadMap[userId].campaignWorkload) && Boolean(this.userIdToWorkloadMap[userId].campaignWorkload[cpw.campaignName])){
                    cpw = this.userIdToWorkloadMap[userId].campaignWorkload[cpw.campaignName];
                }
                cpw.campaignWorkload = Boolean(cpw.campaignWorkload) ? cpw.campaignWorkload + 1 : 1;
                this.userIdToWorkloadMap[userId].totalWorkloadCampaign += 1;
                this.userIdToWorkloadMap[userId].campaignWorkload[cpw.campaignName] = cpw;
                this.userAssignmentMap[userId].campaignMembers.push(campaignMember);
            }else{
                this.userIdToWorkloadMap[userId] = {};
                this.userIdToWorkloadMap[userId].Id = userId;
                this.userIdToWorkloadMap[userId].userName = campaignMember.CRM_AssegnatarioUser__r.Name;
                // console.log('SV contact: ',this.contact, campaignMember.CRM_AssegnatarioUser__r.PTF_RuoloLDAP__c, userId);
                this.userIdToWorkloadMap[userId].totalWorkloadCampaign = 1;
                this.userIdToWorkloadMap[userId].totalWorkloadEvent = 0;
                this.userIdToWorkloadMap[userId].totalWorkloadOpp = 0;
                this.userIdToWorkloadMap[userId].campaignWorkload = {};
                this.userIdToWorkloadMap[userId].eventWorkload = {};
                this.userIdToWorkloadMap[userId].oppWorkload = {};
                let cpw = {};
                cpw.campaignName = campaignMember.Campaign__r.Name;
                cpw.campaignWorkload = 1;
                this.userIdToWorkloadMap[userId].campaignWorkload[cpw.campaignName] = cpw;
                this.userAssignmentMap[userId].campaignMembers.push(campaignMember);
            }
        });

        this.eventsMemberList.forEach(eventMember =>{
            let userId = eventMember.CRM_AssegnatarioUser__c;
            if(!Boolean(this.userAssignmentMap[userId])){
                this.userAssignmentMap[userId] = {};
                this.userAssignmentMap[userId].eventMembers = [];
            }
            if(!Boolean(this.userAssignmentMap[userId].eventMembers)){
                this.userAssignmentMap[userId].eventMembers = [];
            }
            if(Boolean(this.userIdToWorkloadMap[userId])){
                let cpw = {};
                cpw.eventName = eventMember.Campaign__r.Name;
                if(Boolean(this.userIdToWorkloadMap[userId].eventWorkload) && Boolean(this.userIdToWorkloadMap[userId].eventWorkload[cpw.eventName])){
                    cpw = this.userIdToWorkloadMap[userId].eventWorkload[cpw.eventName];
                }else if(!Boolean(this.userIdToWorkloadMap[userId].eventWorkload)){
                    this.userIdToWorkloadMap[userId].eventWorkload = {};
                }
                cpw.eventWorkload = Boolean(cpw.eventWorkload) ? cpw.eventWorkload + 1 : 1;
                this.userIdToWorkloadMap[userId].totalWorkloadEvent += 1;
                this.userIdToWorkloadMap[userId].eventWorkload[cpw.eventName] = cpw;
                this.userAssignmentMap[userId].eventMembers.push(eventMember);
            }else{
                this.userIdToWorkloadMap[userId] = {};
                this.userIdToWorkloadMap[userId].Id = userId;
                this.userIdToWorkloadMap[userId].userName = eventMember.CRM_AssegnatarioUser__r.Name;
                this.userIdToWorkloadMap[userId].totalWorkloadEvent = 1;
                this.userIdToWorkloadMap[userId].totalWorkloadCampaign = 0;
                this.userIdToWorkloadMap[userId].totalWorkloadOpp = 0;
                this.userIdToWorkloadMap[userId].campaignWorkload = {};
                this.userIdToWorkloadMap[userId].eventWorkload = {};
                this.userIdToWorkloadMap[userId].oppWorkload = {};
                let cpw = {};
                cpw.eventName = eventMember.Campaign__r.Name;
                cpw.eventWorkload = 1;
                this.userIdToWorkloadMap[userId].eventWorkload[cpw.eventName] = cpw;
                this.userAssignmentMap[userId].eventMembers.push(eventMember);
            }
        });

        this.oppsList.forEach(oppMember =>{
            let userId = oppMember.OwnerId;
            if(!Boolean(this.userAssignmentMap[userId])){
                this.userAssignmentMap[userId] = {};
            }
            if(!Boolean(this.userAssignmentMap[userId].oppsList)){
                this.userAssignmentMap[userId].oppsList = [];
            }
            if(Boolean(this.userIdToWorkloadMap[userId])){
                let cpw = {};
                cpw.oppName = oppMember.CRM_Bisogno__c;
                if(Boolean(this.userIdToWorkloadMap[userId].oppWorkload) && Boolean(this.userIdToWorkloadMap[userId].oppWorkload[cpw.oppName])){
                    cpw = this.userIdToWorkloadMap[userId].oppWorkload[cpw.oppName];
                }else if(!Boolean(this.userIdToWorkloadMap[userId].oppWorkload)){
                    this.userIdToWorkloadMap[userId].oppWorkload = {};
                }
                cpw.oppWorkload = Boolean(cpw.oppWorkload) ? cpw.oppWorkload + 1 : 1;
                this.userIdToWorkloadMap[userId].totalWorkloadOpp += 1;
                this.userIdToWorkloadMap[userId].oppWorkload[cpw.oppName] = cpw;
                this.userAssignmentMap[userId].oppsList.push(oppMember);
            }else{
                this.userIdToWorkloadMap[userId] = {};
                this.userIdToWorkloadMap[userId].Id = userId;
                this.userIdToWorkloadMap[userId].userName = oppMember.Owner.Name;
                this.userIdToWorkloadMap[userId].totalWorkloadOpp = 1;
                this.userIdToWorkloadMap[userId].totalWorkloadEvent = 0;
                this.userIdToWorkloadMap[userId].totalWorkloadCampaign = 0;
                this.userIdToWorkloadMap[userId].campaignWorkload = {};
                this.userIdToWorkloadMap[userId].eventWorkload = {};
                this.userIdToWorkloadMap[userId].oppWorkload = {};
                let cpw = {};
                cpw.oppName = oppMember.Name;
                cpw.oppWorkload = 1;
                this.userIdToWorkloadMap[userId].oppWorkload[cpw.oppName] = cpw;
                this.userAssignmentMap[userId].oppsList.push(oppMember);
            }
        });

        let dataMap = this.userIdToWorkloadMap;
        let value;
        let serializedResults = '[';
        Object.keys(dataMap).forEach(function(key){
            
            value = dataMap[key];
            
            let idUtente = value.Id;
            let nomeRisorsa = value.userName;
            let numeroContattiCampagne = ''+value.totalWorkloadCampaign;
            let numeroContattiOpportunita = ''+value.totalWorkloadOpp;
            let numeroContattiEventi = ''+value.totalWorkloadEvent;

            serializedResults += '{"Id":"' + idUtente + '","nomeRisorsa":"' + nomeRisorsa + '","numeroContattiCampagne":' + numeroContattiCampagne+',"numeroContattiOpportunita":'+numeroContattiOpportunita+',"numeroContattiEventi":'+numeroContattiEventi;
            let allCampaign = new Map(Object.entries(value.campaignWorkload));
            let allEvent = new Map(Object.entries(value.eventWorkload));
            let allOpp = new Map(Object.entries(value.oppWorkload));
            // console.log('allcamp: ',allCampaign);
            if(allCampaign.size > 0 || allEvent.size > 0 || allOpp.size > 0){
                let listSize = [allCampaign.size,allEvent.size,allOpp.size];
                let maxSize = 0;
                for(let i=0;i<listSize.length;i++){
                    if(maxSize < listSize[i]){
                        maxSize = listSize[i];
                    }
                }
                // console.log('maxSize: ',maxSize);
                serializedResults += ',"_children":[';
                let cmp = Array.from(allCampaign.values());
                let evt = Array.from(allEvent.values());
                let opp = Array.from(allOpp.values());
                for(let i=0; i<maxSize;i++){
                    serializedResults += '{"nomeRisorsa":"",';
                    if(cmp.length > i){
                        let nameCampagna = cmp.length > 0 ? cmp[i].campaignName.replace(/['"]+/g, '') : '""'; 
                        let numeroContattiCamp = cmp.length > 0 ? cmp[i].campaignWorkload : '""';
                        serializedResults += '"campagna":"'+nameCampagna+'","numeroContattiCampagne":'+numeroContattiCamp+',';
                    }else{
                        serializedResults +='"campagna":"","numeroContattiCampagne":"",';
                    }
                    if(opp.length >i){
                        let oppName = opp.length > 0 ? opp[i].oppName.replace(/['"]+/g, '') : '""';
                        let numeroContattiOpp = opp.length > 0 ? opp[i].oppWorkload : '""';
                        serializedResults += '"opportunita":"'+oppName+'","numeroContattiOpportunita":'+numeroContattiOpp+',';
                    }else{
                        serializedResults +='"opportunita":"","numeroContattiOpportunita":"",';
                    }
                    if(evt.length >i){
                        let eventName = evt.length > 0 ? evt[i].eventName.replace(/['"]+/g, '') : '""';
                        let numeroContattiEventi = evt.length > 0 ? evt[i].eventWorkload : '""';
                        serializedResults += '"evento":"'+eventName+'","numeroConattiEventi":'+numeroContattiEventi;
                    }else{
                        serializedResults +='"evento":"","numeroContattiEventi":""';
                    }
                    serializedResults += '},';
                }
                serializedResults = serializedResults.substring(0, serializedResults.length-1);
                serializedResults += ']';
            }
            serializedResults += '},';
        });
        serializedResults = serializedResults != '[' ? serializedResults.substring(0,serializedResults.length-1) : serializedResults;
        serializedResults += ']';
        console.log('DK FULL serializedResults', serializedResults);
        this.tableData = JSON.parse(serializedResults);
        
        // this.hasdata = true;
        this.loaded = true;
        this.endTimeHandleGetRefrenti = new Date();
        // return '';
        if(this.isReload){
            this.resetTabs();
            if(this.isCMTABReload){
                this.goToTab('assCam');
                this.assCamStep1 = true;
                this.handleAssegnaReferenteRequestCMTabClicked = false;
            }else if(this.isEVTABReload){
                this.goToTab('assEvt');
                this.assEvStep1 = true;
                this.handleAssegnaReferenteRequestEVTabClicked = false;
            }else if(this.isOPPTABReload){
                this.goToTab('assOpp');
                this.searchedStatoAssegnazioneOPPTab = 'Non assegnato'; //valerio.salvati
                this.assOppStep1 = true;
                this.handleAssegnaReferenteRequestOPPTabClicked = false;
            }else if(this.isREFTABReload){
                this.goToTab('assRef');
                this.assRefStep1 = true;
                this.handleSaveClicked = false;
            }
        }
    }

    @api selectedUserRefTab;
    onRowSelectionRefTab(event){
        this.selectedUserRefTab = event.detail.selectedRows[0];
        this.disbaleRefAssignButton = false;
    }

    handleRefSelection(){
        this.showSpinner = true;
        this.counterCMREFTab = 0;
        this.counterEVREFTab = 0;
        this.counterOPPREFTab = 0;
        try {
            this.campMembColumns = [
                { label: 'NDG', fieldName: 'PTF_AccountUrl', type: 'url', hideDefaultActions: true, typeAttributes: {hideDefaultActions: true, label: { fieldName: 'CRM_NDG' }},  sortable: "true",initialWidth: 80},
                { label: 'Nome Cliente', fieldName: 'CRM_AccountName',hideDefaultActions: true, wrapText: true,target: '_self' ,  sortable: "true"},
                { label: 'Campagna', fieldName: 'CampaignName',hideDefaultActions: true, wrapText: true,target: '_self' ,  sortable: "true",initialWidth: 420},
                { label: 'M-MDS', fieldName: 'PTF_ModelloDiServizio', hideDefaultActions: true, wrapText: true ,  sortable: "true"},
                //{ label: 'Portafoglio', fieldName: 'PTF_PortafoglioUrl', type: 'url', typeAttributes: {label: { fieldName: 'PTF_Portafoglio' }} },
                { label: 'Portafoglio', fieldName: 'PTF_Portafoglio', hideDefaultActions: true, wrapText: true ,  sortable: "true"},
                { label: 'Miniportafoglio', fieldName: 'PTF_Miniportafoglio', hideDefaultActions: true, wrapText: true ,  sortable: "true"},
                { label: 'Esito Contatto', fieldName: 'CRM_Esito__c', hideDefaultActions: true, wrapText: true ,  sortable: "true"},
                { label: 'Autore Esitazione', fieldName: 'CRM_Autore__c', hideDefaultActions: true, wrapText: true ,  sortable: "true"}
            ];
            let selectedRows = this.template.querySelector("[data-item='tableREFTab']").getSelectedRows();
            let userId = selectedRows[0].Id;
            this.recId = userId;
            this.filteredMembersCMREFTab = [];
            if(this.userAssignmentMap[userId].campaignMembers){
                this.userAssignmentMap[userId].campaignMembers.forEach(element =>{
                    this.filteredMembersCMREFTab.push(this.campaignMember[element.Campaign__c + '_' + element.CRM_CampaignMemberId__c + '_' + element.PTF_ModelloDiServizio__c]);
                });
            }
            this.membersCMREFTab = this.filteredMembersCMREFTab;
            this.tableCMREFTabShow = this.membersCMREFTab.length > 0;
            this.filteredMembersEVREFTab = [];
            if(this.userAssignmentMap[userId].eventMembers){
                this.userAssignmentMap[userId].eventMembers.forEach(element =>{
                    this.filteredMembersEVREFTab.push(this.eventMember[element.Campaign__c + '_' + element.CRM_CampaignMemberId__c + '_' + element.PTF_ModelloDiServizio__c]);
                });
            }
            this.membersEVREFTab = this.filteredMembersEVREFTab;
            this.tableEVREFTabShow = this.membersEVREFTab.length > 0;
            
            this.filteredMembersOPPREFTab = [];
            if(this.userAssignmentMap[userId].oppsList ){
                this.userAssignmentMap[userId].oppsList.forEach(element =>{
                    this.filteredMembersOPPREFTab.push(this.oppMap[element.Id + '_' + element.OwnerId + '_' + element.DescrizioneMds__c]);
                });
            }
            this.membersOPPREFTab = this.filteredMembersOPPREFTab;
            this.tableOPPREFTabShow = this.membersOPPREFTab.length > 0;
            this.varTab = 'CMREFTab';
            this.setPages(this.filteredMembersCMREFTab);
            this.varTab = 'EVREFTab';
            this.setPages(this.filteredMembersEVREFTab);
            this.varTab = 'OPPREFTab';
            this.setPages(this.filteredMembersOPPREFTab);
            
            this.assRefStep1 = false;
            this.assRefStep2 = true;
            this.assRefStep3 = false;
            this.showSpinner = false;
        } catch (error) {
            console.log('DK error: ', error);
        }
    }

    @track tableEVREFTabIdRows = [];
    @track tableCMREFTabIdRows = [];
    @track tableOPPREFTabIdRows = [];

    handleAssignRef(){

        try {
            this.showSpinner = true;
            this.columnsRef1 = COLUMNSREFERENTI1;
            this.userDataRows = [];
            let countMap = {};
            let selectedRef = {};
            let mySet1 = new Set();
            this.tableData.forEach(element =>{
                countMap[element.Id] = element;
                if(element.Id == this.recId){
                    selectedRef = element;
                }
            });

            this.tableEVREFTabIdRows = [];
            this.tableCMREFTabIdRows = [];
            this.tableOPPREFTabIdRows = [];

            // EVENTI--------------------------------------------------------------------------------------------------------
            let tableEVREFTab = this.template.querySelector("[data-item='tableEVREFTab']");
            // aggiungo alla lista degli elementi selzionati le righe nelle pagina corrente
            if(tableEVREFTab){
                mySet1 = new Set([...mySet1, ...tableEVREFTab.getSelectedRows().map(element => element.PTF_ModelloDiServizio)])
                this.tableEVREFTabIdRows = tableEVREFTab.getSelectedRows().map(element => element.CRM_CampaignMemberId__c);
                this.EVREFTabSelectRowsMap[this.EVREFTabPage] = tableEVREFTab.getSelectedRows().map(element => element.Id);
            }

            // aggiungo alla lista degli elementi selzionati le righe nelle altre pagine
            for(let currentPage of Object.keys(this.EVREFTabSelectRowsMapValues)){
                if(currentPage != this.page){
                    this.EVREFTabSelectRowsMapValues[currentPage].forEach(element =>{
                        this.tableEVREFTabIdRows.push(element.CRM_CampaignMemberId__c);
                    });
                }
            }

            // CAMPAGNE--------------------------------------------------------------------------------------------------------
            let tableCMREFTab = this.template.querySelector("[data-item='tableCMREFTab']");
            
            // aggiungo alla lista degli elementi selzionati le righe nelle pagina corrente
            if(tableCMREFTab){
                mySet1 = new Set([...mySet1, ...tableCMREFTab.getSelectedRows().map(element => element.PTF_ModelloDiServizio)])
                this.tableCMREFTabIdRows = tableCMREFTab.getSelectedRows().map(element => element.CRM_CampaignMemberId__c);
                this.CMREFTabSelectRowsMap[this.CMREFTabPage] = tableCMREFTab.getSelectedRows().map(element => element.Id);
            }
            // aggiungo alla lista degli elementi selzionati le righe nelle altre pagine
            for(let currentPage of Object.keys(this.CMREFTabSelectRowsMapValues)){
                if(currentPage != this.page){
                    this.CMREFTabSelectRowsMapValues[currentPage].forEach(element =>{
                        this.tableCMREFTabIdRows.push(element.CRM_CampaignMemberId__c);
                    });
                }
            }

            // OPPORTUNITY--------------------------------------------------------------------------------------------------------
            let tableOPPREFTab = this.template.querySelector("[data-item='tableOPPREFTab']");
            
            // aggiungo alla lista degli elementi selzionati le righe nelle pagina corrente
            if(tableOPPREFTab){
                mySet1 = new Set([...mySet1, ...tableOPPREFTab.getSelectedRows().map(element => element.PTF_ModelloDiServizio)])
                this.tableOPPREFTabIdRows = tableOPPREFTab.getSelectedRows().map(element => element.Id);
                this.OPPREFTabSelectRowsMap[this.OPPREFTabPage] = tableOPPREFTab.getSelectedRows().map(element => element.Id);
            }
            // aggiungo alla lista degli elementi selzionati le righe nelle altre pagine
            for(let currentPage of Object.keys(this.OPPREFTabSelectRowsMapValues)){
                if(currentPage != this.page){
                    this.OPPREFTabSelectRowsMapValues[currentPage].forEach(element =>{
                        this.tableOPPREFTabIdRows.push(element.Id);
                    });
                }
            }
                
            let userToShow = [];
            // console.log('SV Tecnico');
            if(mySet1.has('Family') && mySet1.has('POE')){
                // console.log('SV Family POE');
                userToShow = this.contactElegibleRoleMDS.POE_Family;
            } else if(mySet1.has('Family')){
                // console.log('SV Family');
                userToShow = this.contactElegibleRoleMDS.Family;
            } else if(mySet1.has('POE')){
                // console.log('SV POE');
                userToShow = this.contactElegibleRoleMDS.POE;
            } else {
                // console.log('SV NO FAMILY NO POE');
                userToShow = this.contactElegibleRoleMDS.Tecnico;
            }
            let toAdd = true;
            for(let key in userToShow){
                if(userToShow[key].PTF_User__c == this.user.PTF_User__c){
                    toAdd = false;
                    break;
                }
            }
            if(toAdd)userToShow.push(this.user);

            for(let key in userToShow){
                if(userToShow[key].PTF_User__c != this.recId){
                    // console.log('Dk user: ', userToShow[key].PTF_User__c);
                    let tempData = {};
                    if(countMap[userToShow[key].PTF_User__c]){

                        // console.log('Dk countMap: ', JSON.stringify(countMap[userToShow[key].PTF_User__c]));
                        tempData.PTF_TipologiaRuolo = userToShow[key].PTF_TipologiaRuolo__r ? userToShow[key].PTF_TipologiaRuolo__r.Name : '';
                        tempData.id = userToShow[key].PTF_User__c;
                        tempData.nomeRisorsa = userToShow[key].Name;
                        tempData.nCampagne = countMap[userToShow[key].PTF_User__c].numeroContattiCampagne;
                                               
                        tempData.nOpportunita = countMap[userToShow[key].PTF_User__c].numeroContattiOpportunita;
                        tempData.nEventi = countMap[userToShow[key].PTF_User__c].numeroContattiEventi;

                        tempData.nCampagneToBe = countMap[userToShow[key].PTF_User__c].numeroContattiCampagne + this.tableCMREFTabIdRows.length;
                                               
                        tempData.nOpportunitaToBe = countMap[userToShow[key].PTF_User__c].numeroContattiOpportunita + this.tableOPPREFTabIdRows.length;
                        tempData.nEventiToBe = countMap[userToShow[key].PTF_User__c].numeroContattiEventi + this.tableEVREFTabIdRows.length ;
                    }else{
                        tempData.PTF_TipologiaRuolo = userToShow[key].PTF_TipologiaRuolo__r ? userToShow[key].PTF_TipologiaRuolo__r.Name : '';
                        tempData.id = userToShow[key].PTF_User__c;
                        tempData.nomeRisorsa = userToShow[key].Name;
                        tempData.nCampagne = 0;
                        tempData.nOpportunita = 0;
                        tempData.nEventi = 0;
                        tempData.nCampagneToBe = this.tableCMREFTabIdRows.length;
                                               
                        tempData.nOpportunitaToBe =  this.tableOPPREFTabIdRows.length;
                        tempData.nEventiToBe =  this.tableEVREFTabIdRows.length ;
                    }
                    this.userDataRows.push(tempData);
                }
            }
    
            // this.userDataRows = userToShow;
            this.showSpinner = false;
            this.assRefStep1 = false;
            this.assRefStep2 = false;
            this.assRefStep3 = true;
        } catch (error) {
            console.log('DK error: ', error);
        }
    }

    handleUserSelection(event){
        this.isAssignmentDisabled = (event.target.selectedRows.length > 0) ? false : true;
    }

    @track handleSaveClicked = false;

    
    handleSave(){
        try {
           // console.log('this.handleSaveClicked: '+this.handleSaveClicked);
        if(this.handleSaveClicked == false){

            this.handleSaveClicked = true;
            this.openDialog = true;
        }else{

            this.openDialog = false;
            this.showSpinner = true;
                
                let selectedRowsRef = this.template.querySelector("[data-item='referentiToAssignToTable']").getSelectedRows();

                let start = new Date().getTime();
                let messaggio = (this.tableEVREFTabIdRows.length + this.tableCMREFTabIdRows.length) > this.asyncThreshold ? 'assegnazione in corso...' : undefined;
                reassignItem({evList : this.tableEVREFTabIdRows, cmList : this.tableCMREFTabIdRows, oppList : this.tableOPPREFTabIdRows, toUser: selectedRowsRef[0].id, asyncThreshold: this.asyncThreshold})
                .then(result => {

                    console.log('DK result: ' + result);
                    this.isReload = true;
                    this.isREFTABReload = true;
                    // eval("$A.get('e.force:refreshView').fire();");
                    // this.showToastMessage('Si è verificato un errore nell\'assegnazione','error');
                })
                .catch(error => {
                    console.log('reassignItem error: ', error);
                })
                .finally(() =>{
                    let end = new Date().getTime();
                    let time = end - start;
                    this.reload(messaggio);
                    console.log('Execution time reassignItem: ' + time);
                })
            }
        } catch (error) {
            console.log('reassignItem error: ', error);
        }
    }

    @track selectedRowsRefStep2C = 0;
    @track selectedRowsRefStep2O = 0;
    @track selectedRowsRefStep2E = 0;
    onRowSelectionRefTabStep2C(event){
        this.selectedRowsRefStep2C = event.detail.selectedRows.length;
        this.counterCMREFTab = this.selectedRowsRefStep2C;
        for(let currentPage of Object.keys(this.CMREFTabSelectRowsMap)) {
            if(currentPage != this.CMREFTabPage){

                this.counterCMREFTab += this.CMREFTabSelectRowsMap[currentPage].length
            }
        }
        if(this.counterCMREFTab > 0 || this.counterEVREFTab > 0 || this.counterOPPREFTab > 0){          
            this.disabledButtonAssegnaRefStep2 = false;
        } else {
            this.disabledButtonAssegnaRefStep2 = true;
        }
    }

    onRowSelectionRefTabStep2E(event){
        this.selectedRowsRefStep2E = event.detail.selectedRows.length;
        this.counterEVREFTab = this.selectedRowsRefStep2E;
        for(let currentPage of Object.keys(this.EVREFTabSelectRowsMap)) {
            if(currentPage != this.EVREFTabPage){

                this.counterEVREFTab += this.EVREFTabSelectRowsMap[currentPage].length
            }
        }
        if(this.counterCMREFTab > 0 || this.counterEVREFTab > 0 || this.counterOPPREFTab > 0){          
            this.disabledButtonAssegnaRefStep2 = false;
        } else {
            this.disabledButtonAssegnaRefStep2 = true;
        }
    }

    onRowSelectionRefTabStep2O(event){
        this.selectedRowsRefStep2O = event.detail.selectedRows.length;
        this.counterOPPREFTab = this.selectedRowsRefStep2O;
        for(let currentPage of Object.keys(this.OPPREFTabSelectRowsMap)) {
            if(currentPage != this.OPPREFTabPage){

                this.counterOPPREFTab += this.OPPREFTabSelectRowsMap[currentPage].length
            }
        }
        if(this.counterCMREFTab > 0 || this.counterEVREFTab > 0 || this.counterOPPREFTab > 0){          
            this.disabledButtonAssegnaRefStep2 = false;
        } else {
            this.disabledButtonAssegnaRefStep2 = true;
        }
    }
    //END - TAB REFERENTI

    reload = async (message) => {
        // this.showSpinner = true;
        let functionToCall = this.isCMTABReload ? 'handleGetCampaignMember' : 
                                this.isEVTABReload ? 'handleGetEventMember' :
                                this.isOPPTABReload ? 'handleGetOppsMember' :
                                undefined;
        if(functionToCall){

            this[functionToCall]().then(() =>{
                let messaggio = message ? message : 'Assegnazione effettuata correttamente';
                let status = message ? 'warning' : 'success';
                this.showToastMessage(messaggio,status);
                this.resetTabs();
                this.handleGetRefrenti();
                this.isCMTABReload = false;
                this.isEVTABReload = false;
                this.isOPPTABReload = false;
                this.isREFTABReload = false;
                this.isReload = false;
                this.showSpinner = false;
                this.activeTab = undefined;
                // console.log('DK isReload end');
            });
        }else{

            this.handleGetEventMember()
            .then(() =>{
                this.handleGetCampaignMember()
                .then(() =>{
                    this.handleGetOppsMember()
                    .then(() =>{
                        
                        let messaggio = message ? message : 'Assegnazione effettuata correttamente';
                        let status = message ? 'warning' : 'success';
                        this.showToastMessage(messaggio,status);
                        this.resetTabs();
                        this.handleGetRefrenti();
                        this.isCMTABReload = false;
                        this.isEVTABReload = false;
                        this.isOPPTABReload = false;
                        this.isREFTABReload = false;
                        this.isReload = false;
                        this.showSpinner = false;
                        this.activeTab = undefined;
                        // console.log('DK isReload end');
                    });
                });
            });
        }
    }

    timeout(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    goToTab(activeTab){
        this.activeTab = activeTab;
    }

    handleActive(event) {
        event.preventDefault();
        event.stopPropagation();
        this.nLoad += 1;
        if(!this.isReload){
            this.resetTabs();
            if(event.target.value == 'assCam'){
                this.varTab = '';
                this.assCamStep1 = true;
            }else if(event.target.value == 'assEvt'){
                this.varTab = '';
                this.assEvStep1 = true;
            }else if(event.target.value == 'assOpp'){
                this.varTab = '';
                this.assOppStep1 = true;
                this.searchedStatoAssegnazioneOPPTab = 'Non assegnato'; //valerio.salvati
            }else if(event.target.value == 'assRef'){
                this.varTab = 'CMREFTab';
                this.assRefStep1 = true;
            }
        }
        console.log('DK activeTab ', this.activeTab);
    }

    resetTabs(){
        this.assCamStep1 = false;
        this.assCamStep2 = false;
        this.assCamStep3 = false;
        this.assEvStep1 = false;
        this.assEvStep2 = false;
        this.assEvStep3 = false;
        this.assOppStep1 = false;
        this.assOppStep2 = false;
        this.assRefStep1 = false;
        this.assRefStep2 = false;
        this.assRefStep3 = false;
    }

    //START Pagination
    @track varTab = undefined;
    handleAvanti(){
        try {
            let tab = this.assCamStep2 ? 'CMTab' : this.assEvStep2 ? 'EVTab' : this.assOppStep1 ? 'OPPTab' : this.varTab != '' && this.varTab != undefined ? this.varTab : '';
            // console.log('DK tab: ', tab);
            let selectedRows = tab == 'CMTab' ? this.template.querySelector("[data-item='campaignMembersTable']").getSelectedRows() :
            tab == 'EVTab' ? this.template.querySelector("[data-item='eventMembersTable']").getSelectedRows() : 
            tab == 'OPPTab' ? this.template.querySelector("[data-item='oppMembersTable']").getSelectedRows() :
            tab == 'CMREFTab' ? this.template.querySelector("[data-item='tableCMREFTab']").getSelectedRows() :
            tab == 'EVREFTab' ? this.template.querySelector("[data-item='tableEVREFTab']").getSelectedRows() : this.template.querySelector("[data-item='tableOPPREFTab']").getSelectedRows();
            let selectedRowIds = selectedRows.map(element => element.Id);
            
            this[tab + 'SelectRowsMapValues'][this[tab + 'Page']] = selectedRows;
            this[tab + 'SelectRowsMap'][this[tab + 'Page']] = selectedRowIds;
            this['selected' + tab +'Row'] = Boolean(this[tab + 'SelectRowsMapValues'][this[tab + 'Page']+1]) ? this[tab + 'SelectRowsMapValues'][this[tab + 'Page']+1] : [];
            this['selected' + tab +'RowIds'] = Boolean(this[tab + 'SelectRowsMap'][this[tab + 'Page']+1]) ? this[tab + 'SelectRowsMap'][this[tab + 'Page']+1] : [];
            this['counter' + tab] = 0;
            for (let currentPage of Object.keys(this[tab + 'SelectRowsMap'])) {
                this['counter' + tab] += this[tab + 'SelectRowsMap'][currentPage].length
            }
            // console.log('DK SELECTED ROWS: '  + JSON.stringify(this['selected' + tab +'Row']));
            ++this[tab + 'Page'];
        } catch (error) {
            console.log('error: ', error);
        }
    }

    handleIndietro(){
        try {
            
            let tab = this.assCamStep2 ? 'CMTab' : this.assEvStep2 ? 'EVTab' : this.assOppStep1 ? 'OPPTab' : this.varTab != '' && this.varTab != undefined ? this.varTab : '';

            let selectedRows = tab == 'CMTab' ? this.template.querySelector("[data-item='campaignMembersTable']").getSelectedRows() :
            tab == 'EVTab' ? this.template.querySelector("[data-item='eventMembersTable']").getSelectedRows() : 
            tab == 'OPPTab' ? this.template.querySelector("[data-item='oppMembersTable']").getSelectedRows() :
            tab == 'CMREFTab' ? this.template.querySelector("[data-item='tableCMREFTab']").getSelectedRows() :
            tab == 'EVREFTab' ? this.template.querySelector("[data-item='tableEVREFTab']").getSelectedRows() : this.template.querySelector("[data-item='tableOPPREFTab']").getSelectedRows();
            let selectedRowIds = selectedRows.map(element => element.Id);

            this[tab + 'SelectRowsMapValues'][this[tab + 'Page']] = selectedRows;
            this[tab + 'SelectRowsMap'][this[tab + 'Page']] = selectedRowIds;
            this['selected' + tab + 'Row'] = this[tab + 'SelectRowsMapValues'][this[tab + 'Page'] -1];
            this['selected' + tab + 'RowIds'] = this[tab + 'SelectRowsMap'][this[tab + 'Page'] -1];
            this['counter' + tab] = 0;
            for(let currentPage of Object.keys(this[tab + 'SelectRowsMap'])) {
                this['counter' + tab] += this[tab + 'SelectRowsMap'][currentPage].length
            }
            // console.log('DK SELECTED ROWS: '  + JSON.stringify(this['selected' + tab + 'Row']));
            --this[tab + 'Page'];
        } catch (error) {
            console.log('error: ', error);
        }
    }

    pageData = ()=>{
        try {
            
            let tab = this.assCamStep2 ? 'CMTab' : this.assEvStep2 ? 'EVTab' : this.assOppStep1 ? 'OPPTab' : this.varTab != '' && this.varTab != undefined ? this.varTab : '';
            let page = this[tab + 'Page'];
            let perpage = this.perpage;
            let startIndex = (page*perpage) - perpage;
            let endIndex = (page*perpage);
            let recordToDisplay = this['filteredMembers' + tab].slice(startIndex,endIndex);
            //let recordToDisplayIdList = recordToDisplay.map(item => item.Id);
            return recordToDisplay;
        } catch (error) {
            
            console.log('error: ', error);
        }
    }

    setPages = (data)=>{
        try {
            let tab = this.assCamStep2 ? 'CMTab' : this.assEvStep2 ? 'EVTab' : this.assOppStep1 ? 'OPPTab' : this.varTab != '' && this.varTab != undefined ? this.varTab : '';
            this[tab + 'Pages'] = [];
            // console.log('DK data: ' + data.length);
            let numberOfPages = Math.ceil(data.length / this.defaultLimit);
            for (let index = 1; index <= numberOfPages; index++) {
                this[tab + 'Pages'].push(index);
            }
        } catch (error) {
            console.log('DK error: ', error);
        }
        // console.log('DK Pages: ' + this[tab + 'Pages'].length);
    }

    get disabledButtonIndietro(){
        let tab = this.assCamStep2 ? 'CMTab' : this.assEvStep2 ? 'EVTab' : this.assOppStep1 ? 'OPPTab' : this.varTab != '' && this.varTab != undefined ? this.varTab : '';
        // console.log('DK tab: ', tab);
        return this[tab + 'Page'] === 1;
    }
    
    get disabledButtonAvanti(){
        let tab = this.assCamStep2 ? 'CMTab' : this.assEvStep2 ? 'EVTab' : this.assOppStep1 ? 'OPPTab' : this.varTab != '' && this.varTab != undefined ? this.varTab : '';
        // console.log('DK disabledButtonAvanti tab: ', tab);
        // console.log('DK disabledButtonAvanti filteredMembers: ', this['filteredMembers' + tab]);
        return this[tab + 'Page'] === this[tab + 'Pages'].length || this['filteredMembers' + tab].length === 0
    }

    get currentPageData(){
        return this.pageData();
    }

    // CMREFTAB
    handleAvantiCMREFTab(){
        this.varTab = 'CMREFTab';
        this.handleAvanti();
    }

    handleIndietroCMREFTab(){
        this.varTab = 'CMREFTab';
        this.handleIndietro();
    }
    
    get disabledButtonIndietroCMREFTab(){
        this.varTab = 'CMREFTab';
        return this.disabledButtonIndietro;
    }
    
    get disabledButtonAvantiCMREFTab(){
        this.varTab = 'CMREFTab';
        return this.disabledButtonAvanti;
    }

    get currentPageDataCMREFTab(){
        this.varTab = 'CMREFTab';
        return this.pageData();
    }
    // CMREFTAB

    // EVREFTAB
    handleAvantiEVREFTab(){
        this.varTab = 'EVREFTab';
        this.handleAvanti();
    }

    handleIndietroEVREFTab(){
        this.varTab = 'EVREFTab';
        this.handleIndietro();
    }
    
    get disabledButtonIndietroEVREFTab(){
        this.varTab = 'EVREFTab';
        return this.disabledButtonIndietro;
    }
    
    get disabledButtonAvantiEVREFTab(){
        this.varTab = 'EVREFTab';
        return this.disabledButtonAvanti;
    }

    get currentPageDataEVREFTab(){
        this.varTab = 'EVREFTab';
        return this.pageData();
    }
    // EVREFTAB

    // OPPREFTAB
    handleAvantiOPPREFTab(){
        // console.log('Start handleAvantiOPPREFTab');
        this.varTab = 'OPPREFTab';
        this.handleAvanti();
    }

    handleIndietroOPPREFTab(){
        this.varTab = 'OPPREFTab';
        this.handleIndietro();
    }
    
    get disabledButtonIndietroOPPREFTab(){
        this.varTab = 'OPPREFTab';
        return this.disabledButtonIndietro;
    }
    
    get disabledButtonAvantiOPPREFTab(){
        this.varTab = 'OPPREFTab';
        return this.disabledButtonAvanti;
    }

    get currentPageDataOPPREFTab(){
        this.varTab = 'OPPREFTab';
        return this.pageData();
    }
    // OPPREFTAB

    perpage = 50;
    set_size = 50;
    @api defaultLimit;

    @track CMTabPage = 1;
    @track CMTabPages = [];
    @track EVTabPage = 1;
    @track EVTabPages = [];
    @track OPPTabPage = 1;
    @track OPPTabPages = [];

    @track CMREFTabPage = 1;
    @track CMREFTabPages = [];
    @track EVREFTabPage = 1;
    @track EVREFTabPages = [];
    @track OPPREFTabPage = 1;
    @track OPPREFTabPages = [];

    // creata mappa che contiene per ogni pagina i valori selezionati
    // NOTE:  per far si che le righe siano selezionate bisogna evitare di usare la funzione push per aggiornare la lista, bisogna assegnarli una lista nuova
    @track CMTabSelectRowsMap = {};
    @track CMTabSelectRowsMapValues = {};
    @track EVTabSelectRowsMap = {};
    @track EVTabSelectRowsMapValues = {};
    @track OPPTabSelectRowsMap = {};
    @track OPPTabSelectRowsMapValues = {};


    @track CMREFTabSelectRowsMap = {};
    @track CMREFTabSelectRowsMapValues = {};
    @track counterCMREFTab = 0;
    @track EVREFTabSelectRowsMap = {};
    @track EVREFTabSelectRowsMapValues = {};
    @track counterEVREFTab = 0;
    @track OPPREFTabSelectRowsMap = {};
    @track OPPREFTabSelectRowsMapValues = {};
    @track counterOPPREFTab = 0;
    // END Pagination

    //START FILTER
    @track searchedStatoAssegnazioneCMTab = 'Non assegnato';
    @track searchedMMDSCMTab = '';
    @track searchedPrioritaCMTab = '';
    @track searchedEsitoCMTab = '';
    @track searchedNomeMwCMTab = '';
    @track searchedNomeMMwCMTab = '';
    @track searchedNDGCMTab = '';
    @track searchedRefCMTab = '';
    @track searchedAutoreCMTab = '';//valerio.salvati

    @track searchedStatoAssegnazioneEVTab = 'Non assegnato';
    @track searchedMMDSEVTab = '';
    @track searchedPrioritaEVTab = '';
    @track searchedEsitoEVTab = '';
    @track searchedNomeMwEVTab = '';
    @track searchedNDGEVTab = '';
    @track searchedRefEVTab = '';
    @track searchedAutoreEVTab = '';//valerio.salvati

    @track searchedStatoAssegnazioneOPPTab = 'Non assegnato';
    @track searchedFaseOPPTab = '';
    @track searchedMMDSOPPTab = '';
    @track searchedEsitoContattoOPPTab = '';
    @track searchedBisognoOPPTab = '';
    @track searchedCanaleOPPTab = '';
    @track searchedNDGOPPTab = '';
    @track searchedOggettoOPPTab = '';
    @track searchedRefOPPTab = '';
    @track searchedAccNameOPPTab = ''; //valerio.salvati
    @track searchedAutoreOPPTab = '';//valerio.salvati

    // @track searchedStatoAssegnazioneREFTab = 'Non assegnato';
    @track searchedMMDSREFTab = '';
    @track searchedPrioritaREFTab = '';
    @track searchedEsitoREFTab = '';
    @track searchedNomeMwREFTab = '';
    @track searchedNomeMMwREFTab = '';
    @track searchedNDGREFTab = '';
    @track searchedRefREFTab = '';
    @track searchedAutoreREFTab = '';//valerio.salvati

    handleFilter(event){
        if(event.target.name == 'searchedStatoAssegnazioneCMTab'){
            
            this.searchedStatoAssegnazioneCMTab = event.target.value;
        }else if(event.target.name == 'searchedMMDSCMTab'){
            
            this.searchedMMDSCMTab = event.target.value;
        }else if(event.target.name == 'searchedPrioritaCMTab'){
            
            this.searchedPrioritaCMTab = event.target.value;
        }else if(event.target.name == 'searchedEsitoCMTab'){
            
            this.searchedEsitoCMTab = event.target.value;
        }else if(event.target.name == 'searchedNomeMwCMTab'){
            
            this.searchedNomeMwCMTab = event.target.value;
        }else if(event.target.name == 'searchedNomeMMwCMTab'){
            
            this.searchedNomeMMwCMTab = event.target.value;
        }else if(event.target.name == 'searchedNDGCMTab'){
            
            this.searchedNDGCMTab = event.target.value;
        }else if(event.target.name == 'searchedStatoAssegnazioneEVTab'){
            
            this.searchedStatoAssegnazioneEVTab = event.target.value;
        }else if(event.target.name == 'searchedMMDSEVTab'){
            
            this.searchedMMDSEVTab = event.target.value;
        }else if(event.target.name == 'searchedPrioritaEVTab'){
            
            this.searchedPrioritaEVTab = event.target.value;
        }else if(event.target.name == 'searchedEsitoEVTab'){
            
            this.searchedEsitoEVTab = event.target.value;
        }else if(event.target.name == 'searchedNomeMwEVTab'){
            
            this.searchedNomeMwEVTab = event.target.value;
        }else if(event.target.name == 'searchedNDGEVTab'){
            
            this.searchedNDGEVTab = event.target.value;
        }else if(event.target.name == 'searchedFaseOPPTab'){
            
            this.searchedFaseOPPTab = event.target.value;
        }else if(event.target.name == 'searchedMMDSOPPTab'){
            
            this.searchedMMDSOPPTab = event.target.value;
        }else if(event.target.name == 'searchedEsitoContattoOPPTab'){
            
            this.searchedEsitoContattoOPPTab = event.target.value;
        }else if(event.target.name == 'searchedNDGOPPTab'){
            
            this.searchedNDGOPPTab = event.target.value;
        }else if(event.target.name == 'searchedOggettoOPPTab'){
            
            this.searchedOggettoOPPTab = event.target.value;
        }else if(event.target.name == 'searchedCanaleOPPTab'){
            
            this.searchedCanaleOPPTab = event.target.value;
        }else if(event.target.name == 'searchedBisognoOPPTab'){
            
            this.searchedBisognoOPPTab = event.target.value;
        }else if(event.target.name == 'searchedAccNameOPPTab'){ //valerio.salvati
            //console.log('searchedAccNameOPPTab: '+searchedAccNameOPPTab);
            this.searchedAccNameOPPTab = event.target.value;
        }else if(event.target.name == 'searchedRefCMTab'){
            
            this.searchedRefCMTab = event.target.value;
        }else if(event.target.name == 'searchedRefEVTab'){
            
            this.searchedRefEVTab = event.target.value;
        }else if(event.target.name == 'searchedRefOPPTab'){
            
            this.searchedRefOPPTab = event.target.value;
        }else if(event.target.name == 'searchedAutoreOPPTab'){ //valerio.salvati
            
            this.searchedAutoreOPPTab = event.target.value;
        }else if(event.target.name == 'searchedAutoreCMTab'){ //valerio.salvati
            
            this.searchedAutoreCMTab = event.target.value;
        }else if(event.target.name == 'searchedAutoreEVTab'){ //valerio.salvati
            
            this.searchedAutoreEVTab = event.target.value;
        }else if(event.target.name == 'searchedAutoreREFTab'){ //valerio.salvati
        
            this.searchedAutoreREFTab = event.target.value;
        }else if(event.target.name == 'searchedStatoAssegnazioneOPPTab'){ //valerio.salvati
            
            this.searchedStatoAssegnazioneOPPTab = event.target.value;

        }else if(event.target.name == 'selectedNomeAttributo1CMTab'){
            
            this.selectedNomeAttributo1CMTab = event.target.value;
            if(this.typeMapCMTab[this.selectedNomeAttributo1CMTab] == 'number'){
                this.showRangeNum1CMTab = true;
                this.showRangeDate1CMTab = false;
                this.showSearchtext1CMTab = false;
            }else if(this.typeMapCMTab[this.selectedNomeAttributo1CMTab] == 'date'){
                this.showRangeNum1CMTab = false;
                this.showRangeDate1CMTab = true;
                this.showSearchtext1CMTab = false;
            }else if(this.typeMapCMTab[this.selectedNomeAttributo1CMTab] == 'text'){
                this.showRangeNum1CMTab = false;
                this.showRangeDate1CMTab = false;
                this.showSearchtext1CMTab = true;
            }else{
                this.showRangeNum1CMTab = false;
                this.showRangeDate1CMTab = false;
                this.showSearchtext1CMTab = false;
            }
        }else if(event.target.name == 'selectedNomeAttributo2CMTab'){
            
            this.selectedNomeAttributo2CMTab = event.target.value;
            if(this.typeMapCMTab[this.selectedNomeAttributo2CMTab] == 'number'){
                this.showRangeNum2CMTab = true;
                this.showRangeDate2CMTab = false;
                this.showSearchtext2CMTab = false;
            }else if(this.typeMapCMTab[this.selectedNomeAttributo2CMTab] == 'date'){
                this.showRangeNum2CMTab = false;
                this.showRangeDate2CMTab = true;
                this.showSearchtext2CMTab = false;
            }else if(this.typeMapCMTab[this.selectedNomeAttributo2CMTab] == 'text'){
                this.showRangeNum2CMTab = false;
                this.showRangeDate2CMTab = false;
                this.showSearchtext2CMTab = true;
            }else{
                this.showRangeNum2CMTab = false;
                this.showRangeDate2CMTab = false;
                this.showSearchtext2CMTab = false;
            }
        }else if(event.target.name == 'selectedNomeAttributo1EVTab'){
            
            this.selectedNomeAttributo1EVTab = event.target.value;
            if(this.typeMapEVTab[this.selectedNomeAttributo1EVTab] == 'number'){
                this.showRangeNum1EVTab = true;
                this.showRangeDate1EVTab = false;
                this.showSearchtext1EVTab = false;
            }else if(this.typeMapEVTab[this.selectedNomeAttributo1EVTab] == 'date'){
                this.showRangeNum1EVTab = false;
                this.showRangeDate1EVTab = true;
                this.showSearchtext1EVTab = false;
            }else if(this.typeMapEVTab[this.selectedNomeAttributo1EVTab] == 'text'){
                this.showRangeNum1EVTab = false;
                this.showRangeDate1EVTab = false;
                this.showSearchtext1EVTab = true;
            }else{
                this.showRangeNum1EVTab = false;
                this.showRangeDate1EVTab = false;
                this.showSearchtext1EVTab = false;
            }
        }else if(event.target.name == 'selectedNomeAttributo2EVTab'){
            
            this.selectedNomeAttributo2EVTab = event.target.value;
            if(this.typeMapEVTab[this.selectedNomeAttributo2EVTab] == 'number'){
                this.showRangeNum2EVTab = true;
                this.showRangeDate2EVTab = false;
                this.showSearchtext2EVTab = false;
            }else if(this.typeMapEVTab[this.selectedNomeAttributo2EVTab] == 'date'){
                this.showRangeNum2EVTab = false;
                this.showRangeDate2EVTab = true;
                this.showSearchtext2EVTab = false;
            }else if(this.typeMapEVTab[this.selectedNomeAttributo2EVTab] == 'text'){
                this.showRangeNum2EVTab = false;
                this.showRangeDate2EVTab = false;
                this.showSearchtext2EVTab = true;
            }else{
                this.showRangeNum2EVTab = false;
                this.showRangeDate2EVTab = false;
                this.showSearchtext2EVTab = false;
            }
        }else if(event.target.name == 'selectedValoreAttributo1StartCMTab'){
            
            this.selectedValoreAttributo1StartCMTab = event.target.value;
        }else if(event.target.name == 'selectedValoreAttributo1EndCMTab'){
            
            this.selectedValoreAttributo1EndCMTab = event.target.value;
        }else if(event.target.name == 'selectedValoreAttributo2StartCMTab'){
            
            this.selectedValoreAttributo2StartCMTab = event.target.value;
        }else if(event.target.name == 'selectedValoreAttributo2EndCMTab'){
            
            this.selectedValoreAttributo2EndCMTab = event.target.value;
        }else if(event.target.name == 'searchedValoreAttributo1CMTab'){

            this.searchedValoreAttributo1CMTab = event.target.value;
        }else if(event.target.name == 'searchedValoreAttributo2CMTab'){

            this.searchedValoreAttributo2CMTab = event.target.value;
        }else if(event.target.name == 'selectedValoreAttributo1StartEVTab'){
            
            this.selectedValoreAttributo1StartEVTab = event.target.value;
        }else if(event.target.name == 'selectedValoreAttributo1EndEVTab'){
            
            this.selectedValoreAttributo1EndEVTab = event.target.value;
        }else if(event.target.name == 'selectedValoreAttributo2StartEVTab'){
            
            this.selectedValoreAttributo2StartEVTab = event.target.value;
        }else if(event.target.name == 'selectedValoreAttributo2EndEVTab'){
            
            this.selectedValoreAttributo2EndEVTab = event.target.value;
        }else if(event.target.name == 'searchedValoreAttributo1EVTab'){

            this.searchedValoreAttributo1EVTab = event.target.value;
        }else if(event.target.name == 'searchedValoreAttributo2EVTab'){

            this.searchedValoreAttributo2EVTab = event.target.value;
        }/*else if(event.target.name == 'searchedStatoAssegnazioneREFTab'){
            
            this.searchedStatoAssegnazioneREFTab = event.target.value;
        }*/else if(event.target.name == 'searchedMMDSREFTab'){
            
            this.searchedMMDSREFTab = event.target.value;
        }else if(event.target.name == 'searchedPrioritaREFTab'){
            
            this.searchedPrioritaREFTab = event.target.value;
        }else if(event.target.name == 'searchedEsitoREFTab'){
            
            this.searchedEsitoREFTab = event.target.value;
        }else if(event.target.name == 'searchedNomeMwREFTab'){
            
            this.searchedNomeMwREFTab = event.target.value;
        }else if(event.target.name == 'searchedNomeMMwREFTab'){
            
            this.searchedNomeMMwREFTab = event.target.value;
        }else if(event.target.name == 'searchedNDGREFTab'){
            
            this.searchedNDGREFTab = event.target.value;
        }else if(event.target.name == 'selectedNomeAttributo1REFTab'){
            
            this.selectedNomeAttributo1REFTab = event.target.value;
            if(this.typeMapREFTab[this.selectedNomeAttributo1REFTab] == 'number'){
                this.showRangeNum1REFTab = true;
                this.showRangeDate1REFTab = false;
                this.showSearchtext1REFTab = false;
            }else if(this.typeMapREFTab[this.selectedNomeAttributo1REFTab] == 'date'){
                this.showRangeNum1REFTab = false;
                this.showRangeDate1REFTab = true;
                this.showSearchtext1REFTab = false;
            }else if(this.typeMapREFTab[this.selectedNomeAttributo1REFTab] == 'text'){
                this.showRangeNum1REFTab = false;
                this.showRangeDate1REFTab = false;
                this.showSearchtext1REFTab = true;
            }else{
                this.showRangeNum1REFTab = false;
                this.showRangeDate1REFTab = false;
                this.showSearchtext1REFTab = false;
            }
        }else if(event.target.name == 'selectedNomeAttributo2REFTab'){
            
            this.selectedNomeAttributo2REFTab = event.target.value;
            if(this.typeMapREFTab[this.selectedNomeAttributo2REFTab] == 'number'){
                this.showRangeNum2REFTab = true;
                this.showRangeDate2REFTab = false;
                this.showSearchtext2REFTab = false;
            }else if(this.typeMapREFTab[this.selectedNomeAttributo2REFTab] == 'date'){
                this.showRangeNum2REFTab = false;
                this.showRangeDate2REFTab = true;
                this.showSearchtext2REFTab = false;
            }else if(this.typeMapREFTab[this.selectedNomeAttributo2REFTab] == 'text'){
                this.showRangeNum2REFTab = false;
                this.showRangeDate2REFTab = false;
                this.showSearchtext2REFTab = true;
            }else{
                this.showRangeNum2REFTab = false;
                this.showRangeDate2REFTab = false;
                this.showSearchtext2REFTab = false;
            }
        }else if(event.target.name == 'selectedValoreAttributo1StartREFTab'){
            
            this.selectedValoreAttributo1StartREFTab = event.target.value;
        }else if(event.target.name == 'selectedValoreAttributo1EndREFTab'){
            
            this.selectedValoreAttributo1EndREFTab = event.target.value;
        }else if(event.target.name == 'selectedValoreAttributo2StartREFTab'){
            
            this.selectedValoreAttributo2StartREFTab = event.target.value;
        }else if(event.target.name == 'selectedValoreAttributo2EndREFTab'){
            
            this.selectedValoreAttributo2EndREFTab = event.target.value;
        }else if(event.target.name == 'searchedValoreAttributo1REFTab'){

            this.searchedValoreAttributo1REFTab = event.target.value;
        }else if(event.target.name == 'searchedValoreAttributo2REFTab'){

            this.searchedValoreAttributo2REFTab = event.target.value;
        }else if(event.target.name == 'searchedRefREFTab'){
            
            this.searchedRefREFTab = event.target.value;
        }
    }

    handleResetREFTab(){
        this.varTab = 'CMREFTab';
        this.handleReset();
        this.varTab = 'EVREFTab';
        this.handleReset();
        this.varTab = 'OPPREFTab';
        this.handleReset();
    }

    handleReset(){
        let tab = this.assCamStep2 ? 'CMTab' : this.assEvStep2 ? 'EVTab' : this.assOppStep1 ? 'OPPTab' : this.varTab != '' && this.varTab != undefined ? this.varTab : '';
        let filterTab = ['CMREFTab', 'EVREFTab', 'OPPREFTab'].includes(tab) ? 'REFTab' : tab;
        if(Boolean(this['searchedStatoAssegnazione' + filterTab]))this['searchedStatoAssegnazione' + filterTab] = 'Non assegnato';//valerio.salvati
        if(Boolean(this['searchedAutore' + filterTab]))this['searchedAutore' + filterTab] = '';//valerio.salvati
        if(Boolean(this['searchedAccName' + filterTab]))this['searchedAccName' + filterTab] = '';//valerio.salvati
        if(Boolean(this['searchedMMDS' + filterTab]))this['searchedMMDS' + filterTab] = '';
        if(Boolean(this['searchedPriorita' + filterTab]))this['searchedPriorita' + filterTab] = '';
        if(Boolean(this['searchedEsito' + filterTab]))this['searchedEsito' + filterTab] = '';
        if(Boolean(this['searchedNomeMw' + filterTab]))this['searchedNomeMw' + filterTab] = '';
        if(Boolean(this['searchedNomeMMw' + filterTab]))this['searchedNomeMMw' + filterTab] = '';
        if(Boolean(this['searchedNDG' + filterTab]))this['searchedNDG' + filterTab] = '';
        if(Boolean(this['searchedRef' + filterTab]))this['searchedRef' + filterTab] = '';
        //if(Boolean(this['selectedNomeAttributo1' + filterTab]))this['selectedNomeAttributo1' + filterTab] = '';
        if(Boolean(this['selectedValoreAttributo1Start' + filterTab]))this['selectedValoreAttributo1Start' + filterTab] = '';
        if(Boolean(this['selectedValoreAttributo1End' + filterTab]))this['selectedValoreAttributo1End' + filterTab] = '';
        //if(Boolean(this['selectedNomeAttributo2' + filterTab]))this['selectedNomeAttributo2' + filterTab] = '';
        if(Boolean(this['selectedValoreAttributo2Start' + filterTab]))this['selectedValoreAttributo2Start' + filterTab] = '';
        if(Boolean(this['selectedValoreAttributo2End' + filterTab]))this['selectedValoreAttributo2End' + filterTab] = '';
        if(Boolean(this['searchedValoreAttributo1' + filterTab]))this['searchedValoreAttributo1' + filterTab] = '';
        if(Boolean(this['searchedValoreAttributo2' + filterTab]))this['searchedValoreAttributo2' + filterTab] = '';
        if(Boolean(this['showRangeNum1' + filterTab]))this['showRangeNum1' + filterTab] = true;
        if(Boolean(this['showRangeDate1' + filterTab]))this['showRangeDate1' + filterTab] = true;
        if(Boolean(this['showSearchtext1' + filterTab]))this['showSearchtext1' + filterTab] = true;
        if(Boolean(this['showRangeNum2' + filterTab]))this['showRangeNum2' + filterTab] = true;
        if(Boolean(this['showRangeDate2' + filterTab]))this['showRangeDate2' + filterTab] = true;
        if(Boolean(this['showSearchtext2' + filterTab]))this['showSearchtext2' + filterTab] = true;
        if(Boolean(this['filteredMembers' + tab]))this['filteredMembers' + tab] = this['members' + tab];
        if(Boolean(this['searchedFase' + filterTab]))this['searchedFase' + filterTab] = '';
        if(Boolean(this['searchedMMDS' + filterTab]))this['searchedMMDS' + filterTab] = '';
        if(Boolean(this['searchedEsitoContatto' + filterTab]))this['searchedEsitoContatto' + filterTab] = '';
        if(Boolean(this['searchedBisogno' + filterTab]))this['searchedBisogno' + filterTab] = '';
        if(Boolean(this['searchedCanale' + filterTab]))this['searchedCanale' + filterTab] = '';
        if(Boolean(this['searchedNDG' + filterTab]))this['searchedNDG' + filterTab] = '';
        if(Boolean(this['searchedOggetto' + filterTab]))this['searchedOggetto' + filterTab] = '';
        if(Boolean(this['searchedRef' + filterTab]))this['searchedRef' + filterTab] = '';
        // console.log('DK handleReset filteredMembers: ', this['filteredMembers' + tab]);
        this.setPages(this['filteredMembers' + tab]);
        this.handleSearch();
    }
    handleSearchREFTab(){
        this.varTab = 'CMREFTab';
        this.handleSearch();
        this.varTab = 'EVREFTab';
        this.handleSearch();
        this.varTab = 'OPPREFTab';
        this.handleSearch();
    }
    handleSearch(){
        try {
            let tab = this.assCamStep2 ? 'CMTab' : this.assEvStep2 ? 'EVTab' : this.assOppStep1 ? 'OPPTab' : this.varTab != '' && this.varTab != undefined ? this.varTab : '';
            let filterTab = ['CMREFTab', 'EVREFTab', 'OPPREFTab'].includes(tab) ? 'REFTab' : tab;
            let filteredList = [];
            this[tab + 'Page'] = 1;
            for(var i in this['members' + tab]){
                if(Boolean(this['searchedStatoAssegnazione' + filterTab])){
                    if(!this['members' + tab][i].CRM_StatoAssegnazione || this['members' + tab][i].CRM_StatoAssegnazione.toLowerCase() != this['searchedStatoAssegnazione' + filterTab].toLowerCase()){
                        continue;
                    }
                }
                if(Boolean(this['searchedMMDS' + filterTab])){
                    if(!this['members' + tab][i].PTF_ModelloDiServizio || this['members' + tab][i].PTF_ModelloDiServizio.toLowerCase() != this['searchedMMDS' + filterTab].toLowerCase()){
                        continue;
                    }
                }
                if(Boolean(this['searchedEsito' + filterTab])){
                    if(!this['members' + tab][i].CRM_Esito__c || this['members' + tab][i].CRM_Esito__c.toLowerCase() != this['searchedEsito' + filterTab].toLowerCase()){
                        continue;
                    }
                }
                if(Boolean(this['searchedPriorita' + filterTab])){
                    if(!this['members' + tab][i].CRM_PrioritaCampagna__c || this['members' + tab][i].CRM_PrioritaCampagna__c.toLowerCase() != this['searchedPriorita' + filterTab].toLowerCase()){
                        continue;
                    }
                }
                if(Boolean(this['searchedNomeMw' + filterTab])){
                    if(!this['members' + tab][i].PTF_Portafoglio || !this['members' + tab][i].PTF_Portafoglio.toLowerCase().includes(this['searchedNomeMw' + filterTab].toLowerCase())){
                        continue;
                    }
                }
                if(Boolean(this['searchedNomeMMw' + filterTab])){
                    if(!this['members' + tab][i].PTF_Miniportafoglio || !this['members' + tab][i].PTF_Miniportafoglio.toLowerCase().includes(this['searchedNomeMMw' + filterTab].toLowerCase())){
                        continue;
                    }
                }
                if(Boolean(this['searchedNDG' + filterTab])){
                    if(!this['members' + tab][i].CRM_NDG || !this['members' + tab][i].CRM_NDG.toLowerCase().includes(this['searchedNDG' + filterTab].toLowerCase())){
                        continue;
                    }
                }
                if(Boolean(this['searchedRef' + filterTab])){
                    if(!this['members' + tab][i].CRM_ReferenteName || !this['members' + tab][i].CRM_ReferenteName.toLowerCase().includes(this['searchedRef' + filterTab].toLowerCase())){
                        continue;
                    }
                }
                if(Boolean(this['searchedOggetto' + filterTab])){
                    if(!this['members' + tab][i].CRM_Oggetto__c || !this['members' + tab][i].CRM_Oggetto__c.toLowerCase().includes(this['searchedOggetto' + filterTab].toLowerCase())){
                        continue;
                    }
                }
                if(Boolean(this['searchedCanale' + filterTab])){
                    if(!this['members' + tab][i].CRM_Canale__c || this['members' + tab][i].CRM_Canale__c.toLowerCase() != this['searchedCanale' + filterTab].toLowerCase()){
                        continue;
                    }
                }
                if(Boolean(this['searchedBisogno' + filterTab])){
                    if(!this['members' + tab][i].CRM_Bisogno__c || this['members' + tab][i].CRM_Bisogno__c.toLowerCase() != this['searchedBisogno' + filterTab].toLowerCase()){
                        continue;
                    }
                }
                if(Boolean(this['searchedFase' + filterTab])){
                    if(this['members' + tab][i].StageName.toLowerCase() != this['searchedFase' + filterTab].toLowerCase()){
                        continue;
                    }
                }
                //valerio.salvati
                if(Boolean(this['searchedAccName' + filterTab])){
                    if(this['members' + tab][i].CRM_AccName.toLowerCase()!=this['searchedAccName' + filterTab].toLowerCase()){
                        continue;
                    }
                }if(Boolean(this['searchedAutore' + filterTab])){
                    if(this['members' + tab][i].CRM_Autore__c.toLowerCase()!=this['searchedAutore' + filterTab].toLowerCase()){
                        continue;
                    }
                }
                //

                // ATTRIBUTI DINAMICI
                if(Boolean(this['selectedNomeAttributo1' + filterTab])){
                    if(this['members' + tab][i].CRM_NomeAttributo1 != this['selectedNomeAttributo1' + filterTab]){
                        continue;
                    }
                    if(Boolean(this['selectedValoreAttributo1Start' + filterTab])){
                        if(!this['members' + tab][i].CRM_ValoreAttributo1){
                            continue;
                        }
                        if(this['typeMap' + tab][this['selectedNomeAttributo1' + filterTab]] === 'date'){
                            if(new Date(this['members' + tab][i].CRM_ValoreAttributo1) < new Date(this['selectedValoreAttributo1Start' + filterTab])){
                                continue;
                            }
                        }else{
                            if(this['members' + tab][i].CRM_ValoreAttributo1 < this['selectedValoreAttributo1Start' + filterTab]){
                                continue;
                            }
                        }
                    }
                    if(Boolean(this['selectedValoreAttributo1End' + filterTab])){
                        if(!this['members' + tab][i].CRM_ValoreAttributo1){
                            continue;
                        }
                        if(this['typeMap' + tab][this['selectedNomeAttributo1' + filterTab]] === 'date'){
                            if(new Date(this['members' + tab][i].CRM_ValoreAttributo1) > new Date(this['selectedValoreAttributo1End' + filterTab])){
                                continue;
                            }
                        }else{
    
                            if(this['members' + tab][i].CRM_ValoreAttributo1 > this['selectedValoreAttributo1End' + filterTab]){
                                continue;
                            }
                        }
                    }
                    if(Boolean(this['searchedValoreAttributo1' + filterTab])){
                        if(!this['members' + tab][i].CRM_ValoreAttributo1){
                            continue;
                        }
                        if(this['members' + tab][i].CRM_ValoreAttributo1 != this['searchedValoreAttributo1' + filterTab]){
                            continue;
                        }
                    }
                }
                if(Boolean(this['selectedNomeAttributo2' + filterTab])){
                    if(this['members' + tab][i].CRM_NomeAttributo2 != this['selectedNomeAttributo2' + filterTab]){
                        continue;
                    }
                    if(Boolean(this['selectedValoreAttributo2Start' + filterTab])){
                        if(!this['members' + tab][i].CRM_ValoreAttributo2CMTab){
                            continue;
                        }
                        if(this['typeMap' + tab][this['selectedNomeAttributo2' + filterTab]] === 'date'){
                            if(new Date(this['members' + tab][i].CRM_ValoreAttributo2) < new Date(this['selectedValoreAttributo2Start' + filterTab])){
                                continue;
                            }
                        }else{
                            if(this['members' + tab][i].CRM_ValoreAttributo2 < this['selectedValoreAttributo2Start' + filterTab]){
                                continue;
                            }
                        }
                    }
                    if(Boolean(this['selectedValoreAttributo2End' + filterTab])){
                        if(!this['members' + tab][i].CRM_ValoreAttributo2){
                            continue;
                        }
                        if(this['typeMap' + tab][this['selectedNomeAttributo2' + filterTab]] === 'date'){
                            if(new Date(this['members' + tab][i].CRM_ValoreAttributo2) > new Date(this['selectedValoreAttributo2End' + filterTab])){
                                continue;
                            }
                        }else{
    
                            if(this['members' + tab][i].CRM_ValoreAttributo2 > this['selectedValoreAttributo2End' + filterTab]){
                                continue;
                            }
                        }
                    }
                    if(Boolean(this['searchedValoreAttributo2' + filterTab])){
                        if(!this['members' + tab][i].CRM_ValoreAttributo2){
                            continue;
                        }
                        if(this['members' + tab][i].CRM_ValoreAttributo2 != this['searchedValoreAttributo2' + filterTab]){
                            continue;
                        }
                    }
                }
                // ATTRIBUTI DINAMICI
                filteredList.push(this['members' + tab][i]);
            }
            // console.log('DK handleSearch filteredList: ', filteredList);
            this['filteredMembers' + tab] = filteredList;
            this.setPages(this['filteredMembers' + tab]);
        } catch (error) {
            console.log('DK error: ' + error);
        }
    }
    //END FILTER

    handleSendRequestCMTab(event){
        this.counterCMTab = 0;
        this.CMTabSelectRowsMapValues = {};
        this.CMTabSelectRowsMap = {};
        this.varTab ='CMTab';
        this.assCamStep1 = false;
        this.assCamStep2 = true;
        this.assCamStep3 = false;
        let eventObj = {};
        eventObj.target = {};
        eventObj.target.name = 'selectedNomeAttributo1CMTab';
        eventObj.target.value = this.membersCMTab[0].Campaign__r.CRM_Nome_Attributo_1_formula__c;
        this.handleFilter(eventObj);
        eventObj.target.name = 'selectedNomeAttributo2CMTab';
        eventObj.target.value = this.membersCMTab[0].Campaign__r.CRM_Nome_Attributo_2_formula__c;
        this.handleFilter(eventObj);
        //valerio.salvati
        this.searchedStatoAssegnazioneCMTab = 'Non assegnato'
        this.handleSearch();

    }
    handleSendRequestEVTab(event){
        this.counterEVTab = 0;
        this.EVTabSelectRowsMapValues = {};
        this.EVTabSelectRowsMap = {};
        let eventObj = {};
        eventObj.target = {};
        eventObj.target.name = 'selectedNomeAttributo1EVTab';
        eventObj.target.value = this.membersEVTab[0].Campaign__r.CRM_Nome_Attributo_1_formula__c;
        this.handleFilter(eventObj);
        eventObj.target.name = 'selectedNomeAttributo2EVTab';
        eventObj.target.value = this.membersEVTab[0].Campaign__r.CRM_Nome_Attributo_2_formula__c;
        this.handleFilter(eventObj);
        this.varTab ='EVTab';
        this.assEvStep1 = false;
        this.assEvStep2 = true;
        this.assEvStep3 = false;

        //valerio.salvati
        this.searchedStatoAssegnazioneEVTab = 'Non assegnato'
        this.handleSearch();
    }

    // ----------------------------------------------------------------------------- START HELPERS -----------------------------------------------------------------------------
    
    handleGetCurrentReferenteData(selectedRows){

        let mySet1 = new Set();
        for(let record of selectedRows){
            mySet1.add(record.PTF_ModelloDiServizio)   
        }

        console.log('SV mySet1: ', mySet1);
        let userToShow = [];
            if(mySet1.has('Family') && mySet1.has('POE')){
                // console.log('SV Family POE');
                userToShow = this.contactElegibleRoleMDS.POE_Family;
            } else if(mySet1.has('Family')){
                // console.log('SV Family');
                userToShow = this.contactElegibleRoleMDS.Family;
            } else if(mySet1.has('POE')){
                // console.log('SV POE');
                userToShow = this.contactElegibleRoleMDS.POE;
            } else {
                // console.log('SV NO FAMILY NO POE');
                userToShow = this.contactElegibleRoleMDS.Tecnico;

            }
        // }
        let toAdd = true;
        for(let key in userToShow){
            if(userToShow[key].PTF_User__c == this.user.PTF_User__c){
                toAdd = false;
                break;
            }
        }
        if(toAdd)userToShow.push(this.user);
       
        
        let arr = (this.assCamStep2 || this.isAggiungiMassivamenteCM) ? this.idReferentiCMTabAssegnate : (this.assEvStep2|| this.isAggiungiMassivamenteEV) ? this.idReferentiEVTabAssegnate : this.idReferentiOPPTabAssegnate;
        console.log('this.arr: '+arr);
        for(let user of userToShow){
            user.PTF_TipologiaRuolo = user.PTF_TipologiaRuolo__r.Name;
            user.nContattiAttuali = 0;
            for (let element of arr) {
                if(element === user.PTF_User__c)
                user.nContattiAttuali += 1;
            }
            user.nContattiPrevisti = user.nContattiAttuali + selectedRows.length;
        }

        // console.log('SV userToShow: ', userToShow);
        return userToShow;
    }
    handleBack(event){
        if(this.assRefStep2){
            this.assRefStep1 = true;
            this.assRefStep2 = false;
            this.assRefStep3 = false;
        }if(this.assRefStep3){
            this.assRefStep1 = false;
            this.assRefStep2 = true;
            this.assRefStep3 = false;
            this.selectedEVREFTabRowIds = this.EVREFTabSelectRowsMap[this.EVREFTabPage];
            this.selectedCMREFTabRowIds = this.CMREFTabSelectRowsMap[this.CMREFTabPage];
            this.selectedOPPREFTabRowIds = this.OPPREFTabSelectRowsMap[this.OPPREFTabPage];
        }else if(this.assEvStep2){
            this.assEvStep1 = true;
            this.assEvStep2 = false;
            this.assEvStep3 = false;
            this.selectedEventsIds = this.selectedEvents.map(element => element.Id);
        }else if(this.assEvStep3){
            this.assEvStep3 = false;
            if(this.isAggiungiMassivamenteEV){
                this.assEvStep1 = true;
                this.assEvStep2 = false;
                this.selectedEventsIds = this.selectedEvents.map(element => element.Id);
            }else{
                this.assEvStep1 = false;
                this.assEvStep2 = true;
                this.selectedEVTabRowIds = this.selectedEVTabRow.map(element => element.Id);
                
            }
        }else if(this.assCamStep2){
            this.assCamStep1 = true;
            this.assCamStep2 = false;
            this.assCamStep3 = false;
            this.selectedCampagneIds = this.selectedCampagne.map(element => element.Id);
        }else if(this.assCamStep3){
            this.assCamStep3 = false;
            if(this.isAggiungiMassivamenteCM){
                this.assCamStep1 = true;
                this.assCamStep2 = false;
                this.selectedCampagneIds = this.selectedCampagne.map(element => element.Id);
            }else{
                this.assCamStep1 = false;
                this.assCamStep2 = true;
                this.selectedCMTabRowIds = this.selectedCMTabRow.map(element => element.Id);
            }
        }else if(this.assOppStep2){
            this.assOppStep1 = true;
            this.assOppStep2 = false;
        }
    }
    showToastMessage(text, type) {
        const toastEvent = new ShowToastEvent({
            title: '',
            message: text,
            variant: type
        });
        this.dispatchEvent(toastEvent);
    }

    // START DIALOG
    @track openDialog = false;
    //handles button clicks
    handleClickDialog(event){
        if(event.currentTarget.name == 'cancel'){
            this.openDialog = false;
            this.handleSaveClicked = false;
            this.handleAssegnaReferenteRequestCMTabClicked = false;
            this.handleAssegnaReferenteRequestEVTabClicked = false;
            this.handleAssegnaReferenteRequestOPPTabClicked = false;
        }else{

            if(this.handleAssegnaReferenteRequestCMTabClicked){
                this.handleAssegnaReferenteRequestCMTab({});
            }else if(this.handleAssegnaReferenteRequestEVTabClicked){
                this.handleAssegnaReferenteRequestEVTab({});
            }else if(this.handleAssegnaReferenteRequestOPPTabClicked){
                this.handleAssegnaReferenteRequestOPPTab({});
            }else{
                this.handleSave();
            }
        }
    }
    // END DIALOG

    // START SORT
    sortedBy;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortDirectionEVREFTab = 'asc';
    sortDirectionCMREFTab = 'asc';
    sortDirectionOPPREFTab = 'asc';
    onHandleSortCMREFTab( event ) {
        this.onHandleSort(event, 'CMREFTab');
    }

    onHandleSortEVREFTab( event ) {
        this.onHandleSort(event, 'EVREFTab');
    }

    onHandleSortOPPREFTab( event ) {
        this.onHandleSort(event, 'OPPREFTab');
    }

    onHandleSortAssRefStep1(event){
        this.onHandleSort(event, '', 'tableData')
    }
    onHandleSortAssRefStep2(event){
        this.onHandleSort(event, '', 'userDataRows')
    }

    onHandleSort( event, refTabVar, tableName) {
        try {
            
            let tab = refTabVar != '' && refTabVar != undefined ? refTabVar : this.nLoad <= 1 ? '' : this.assCamStep2 ? 'CMTab' : this.assEvStep2 ? 'EVTab' : this.assOppStep1 ? 'OPPTab' : this.varTab != '' && this.varTab != undefined ? this.varTab : '';
            console.log('DK onHandleSort.tab: ' ,tab + ' ' + refTabVar );
            let listName = Boolean(tableName) ? tableName : Boolean(tab) ? 'filteredMembers' + tab :
                        this.assCamStep1 ? 'campaignData' : 'eventData';

            let filteredList = this[listName];
            const { fieldName: sortedBy, sortDirection } = event.detail;
            const cloneData = [...filteredList];
            //cloneData.sort( this.sortBy( sortedBy, sortDirection === 'asc' ? 1 : -1 ) );
            cloneData.sort( this.sortBy( sortedBy != 'PTF_AccountUrl' ? sortedBy : 'CRM_NDG', sortDirection === 'asc' ? 1 : -1 ) );
            filteredList = cloneData;
            if(refTabVar=='CMREFTab'){
                this.sortDirectionCMREFTab = sortDirection;
                this.sortedByCMREF = sortedBy;
            }else if(refTabVar=='EVREFTab'){
                this.sortDirectionEVREFTab = sortDirection;
                this.sortedByEVREF = sortedBy;
            }else if(refTabVar=='OPPREFTab'){
                this.sortDirectionOPPREFTab = sortDirection;
                this.sortedByOPPREF = sortedBy;
            }else{
                this.sortDirection = sortDirection; 
                this.sortedBy = sortedBy; 
            }   
            console.log('DK '+sortedBy+' '+this.sortDirectionEVREFTab+' '+this.sortDirectionCMREFTab+' ' );
           
            this[listName] = filteredList;
            this.setPages(this[listName]);
        } catch (error) {
            console.log(error);
        }
    }
    sortBy( field, reverse, primer ) {

        try {
            
            const key = primer
                ? function( x ) {
                      return primer(x[field]);
                  }
                : function( x ) {
                      return x[field];
                  };
    
            return function( a, b ) {
                a = key(a);
                b = key(b);
                // console.log('DK sort - reverse: ', reverse);
                let ascending = reverse == 1;
                // equal items sort equally
                if (a === b) {
                    return 0;
                }
                // nulls sort after anything else
                else if (!Boolean(a)) {
                    return 1;
                }
                else if (!Boolean(b)) {
                    return -1;
                }
                // otherwise, if we're ascending, lowest sorts first
                else if (ascending) {
                    return a < b ? -1 : 1;
                }
                // if descending, highest sorts first
                else { 
                    return a < b ? 1 : -1;
                }
            };
        } catch (error) {
            console.log(error);
        }

    }
    // END SORT
}