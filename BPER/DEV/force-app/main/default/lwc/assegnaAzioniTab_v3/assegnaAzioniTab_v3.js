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

//import {TABELLA_ELENCOCAMPAGNE, TABELLA_ELENCOEVENTI,TABELLA_ELENCOMMDS,TABELLA_ELENCOREF,TABELLA_ELENCOOPP,TABELLA_ELENCOREFDAASSEGNARE,JSON_ElegibleRoleMMDS,COLUMNSLISTAREFRENTI,COLUMNSREFERENTI1  } from 'c/assegnaAzioniTabv3Utility';

import {TABELLA_ELENCOCAMPAGNE, TABELLA_ELENCOEVENTI,TABELLA_ELENCOMMDS,TABELLA_ELENCOREF,TABELLA_ELENCOOPP,TABELLA_ELENCOREFDAASSEGNARE,JSON_ElegibleRoleMMDS,COLUMNSLISTAREFRENTI,COLUMNSREFERENTI1  } from './assegnaAzioniTab_v3Utility';


export default class AssegnaAzioniTab extends NavigationMixin(LightningElement) {
    @track loaded = false;
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
    @api selectedCMTabRow = [];
    @api selectedCMTabRowIds = [];
    @api contactElegibleRoleMDS;
    @api idReferentiCMTabAssegnate = [];
    @api CMTabSelectedReferenteRowIds = [];
    @api currentReferentData;
    @track disabledButtonAssegnaCampagne = true;
    @track disabledButtonAssegnaCampagneStep2 = true;
    @track disabledButtonAssegnaCampagneStep3 = true;
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
    @api selectedEVTabRow = [];
    @api selectedEVTabRowIds = [];
    @api EVTabReferenteData;
    @api EVTabClientData;
    @api idReferentiEVTabAssegnate = [];
    @api EVTabSelectedReferenteRowIds = [];
    @track typeMapEVTab = {};
    @track disabledButtonAssegnaEventi = true;
    @track disabledButtonAssegnaEventiStep2 = true;
    @track disabledButtonAssegnaEventiStep3 = true;

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

    connectedCallback(){
        this.loaded = false;
        //TAB REFERENTI
        this.columnsListaRefrenti = COLUMNSLISTAREFRENTI;
        console.log('COLUMNSLISTAREFRENTI: '+COLUMNSLISTAREFRENTI);
        if(!Boolean(this.defaultLimit)){

            this.defaultLimit = this.perpage;
        }


        let dataTableGlobalStyle = document.createElement('style');
            dataTableGlobalStyle.innerHTML = `
            lightning-tree-grid lightning-primitive-header-actions {
                display: none;
            }`;
            document.head.appendChild(dataTableGlobalStyle);

        getContact()
        .then(result => {
            console.log('SV getContact result', result);
            // console.log('SV Account count', Object.keys(result.accMap).length);
            // console.log('SV Contact count', Object.keys(result.contactMap).length);
            // console.log('SV PTF count', Object.keys(result.ptfMap).length);
            this.user = result.userMap;
            this.contact = result.contactMap; 
            this.account = result.accMap;
            this.ptf = result.ptfMap;
            this.handleGetEventMember()
            .then(() =>{
                this.loaded = true;
                this.assEvStep1 = true;
                this.handleGetCampaignMember()
                .then(() =>{
                    this.handleGetOppsMember()
                    .then(() =>{
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
            console.log('contactElegibleRoleMDS', this.contactElegibleRoleMDS);
            // console.log('DONE');
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
                if(Boolean(element.CRM_AssegnatarioUser__c) && this.user.PTF_IdCED__c === element.CRM_AssegnatarioUser__r.idced__c){
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
            
            let response = this.extendCampaignEventMembers(this.campaignMember);
            // console.log('SV data', response.data);
            this.campaignData = response.data;

            // console.log('SV clientListData', response.clientListData);
            var ordering = {}, // map for efficient lookup of sortIndex
            sortOrder = ['Family','POE','Non Portafogliati','Assente','Residuale'];
            for (var i=0; i<sortOrder.length; i++)
                ordering[sortOrder[i]] = i;

            response.clientListData.sort( function(a, b) {
                return (ordering[a.modelloServizio] - ordering[b.modelloServizio]);
            });

            this.CMTabClientData = response.clientListData;

            // console.log('SV referentiListData', response.referentiListData);
            this.CMTabReferenteData = response.referentiListData;

            this.foundAttributo1CMTab = response.foundAttributo1;
            this.foundAttributo2CMTab = response.foundAttributo2;
            this.typeMapCMTab = response.typeMap;
            this.optionsAttributo1CMTab = response.optionsAttributo1;
            this.optionsAttributo2CMTab = response.optionsAttributo2;
            this.idReferentiCMTabAssegnate = response.idReferentiAssegnate;

            this.CMTabLoadedAssCmp = true;
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
                if(Boolean(element.CRM_AssegnatarioUser__c) && this.user.PTF_IdCED__c === element.CRM_AssegnatarioUser__r.idced__c){
                    this.eventsMemberList.push(element);
                }
                this.eventMember[element.Campaign__c + '_' + element.CRM_CampaignMemberId__c + '_' + element.PTF_ModelloDiServizio__c] = element;
            });
        })
        .catch(error => {
            this.error = error;
            console.log('ERROR', error);
        }).finally(() => {
            let response = this.extendCampaignEventMembers(this.eventMember);
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
            this.EVTabReferenteData = response.referentiListData;

            this.foundAttributo1EVTab = response.foundAttributo1;
            this.foundAttributo2EVTab = response.foundAttributo2;
            this.typeMapEVTab = response.typeMap;
            this.optionsAttributo1EVTab = response.optionsAttributo1;
            this.optionsAttributo2EVTab = response.optionsAttributo2;
            this.idReferentiEVTabAssegnate = response.idReferentiAssegnate;

            this.EVTabLoadedAssCmp = true; 
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
                opp[keyC].CRM_StatoAssegnazione = opp[keyC].hasOwnProperty('Owner') ? 'Assegnato' : 'Non assegnato';
                opp[keyC].CRM_ReferenteName = opp[keyC].hasOwnProperty('Owner') ? opp[keyC].Owner.Name : '';
                opp[keyC].CRM_AccName = opp[keyC].Account.name;
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
                        objChild.nomeRisorsa = opp[keyC].Name;
                        objChild.numeroContatti = 1;

                        obj._children.push(objChild);
                        referentiListData.push(obj);

                    } else {
                        findReferente[0].numeroContatti = findReferente[0].numeroContatti + 1;
                        let findEventRef = findReferente[0]._children.filter(obj => {
                            return obj.Id === keyArray[0]
                        })

                        if(findEventRef.length === 0){
                            let objChild = {};
                            objChild.Id = keyArray[0];
                            objChild.nomeRisorsa = opp[keyC].Name;
                            objChild.numeroContatti = 1;

                            findReferente[0]._children.push(objChild);
                        } else {
                            findEventRef[0].numeroContatti = findEventRef[0].numeroContatti + 1;
                        }
                    }
                }
            }

            // console.log('SV oppListData', oppListData);
            this.membersOPPTab = oppListData;
            this.filteredMembersOPPTab = this.membersOPPTab;
            this.setPages(this.filteredMembersOPPTab);

            // console.log('SV clientListData', clientListData);
            this.OPPTabClientData = clientListData;

            // console.log('SV referentiListData', referentiListData);
            this.OPPTabReferenteData = referentiListData;

            this.OPPTabLoadedAssCmp = true; 
        });
    }

    @track campaignColumnsIsSet = {};

    //START - TAB CAMPAGNE
    handleCampaignSelection(event){
        let cMFromSelectedCampaign = [];
        let selectedRowsArray = event.detail.selectedRows[0].Id;
        this.selectedCampagna = event.detail.selectedRows[0];
        // console.log('selectedRowsArray: ', event.detail.selectedRows[0]);
        // console.log('selectedRowsArray: ', selectedRowsArray);
        let campaign = this.campaignMember;

        let set = this.campaignColumnsIsSet[selectedRowsArray] ? this.campaignColumnsIsSet[selectedRowsArray] : false;
        try {
            
            for(let keyC in campaign){
                let keyArray = keyC.split('_');
                if(keyArray[0] === selectedRowsArray){
                    cMFromSelectedCampaign.push(campaign[keyC]);
                    if(!set){
                        this.campMembColumns = [
                            { label: 'NDG', fieldName: 'PTF_AccountUrl', type: 'url', sortable: "true", hideDefaultActions: true, typeAttributes: {hideDefaultActions: true, label: { fieldName: 'CRM_NDG' }}},
                            { label: 'Nome Cliente', fieldName: 'CRM_AccountName', sortable: "true", hideDefaultActions: true, wrapText: true,target: '_self' },
                            { label: 'M-MDS', fieldName: 'PTF_ModelloDiServizio', sortable: "true", hideDefaultActions: true, wrapText: true },
                            //{ label: 'Portafoglio', fieldName: 'PTF_PortafoglioUrl', sortable: "true", type: 'url', typeAttributes: {label: { fieldName: 'PTF_Portafoglio' }} },
                            { label: 'Portafoglio', fieldName: 'PTF_Portafoglio', sortable: "true", hideDefaultActions: true, wrapText: true },
                            { label: 'Stato Assegnazione', fieldName: 'CRM_StatoAssegnazione', sortable: "true", hideDefaultActions: true, wrapText: true },
                            { label: 'Nome Referente', fieldName: 'CRM_ReferenteName', sortable: "true", hideDefaultActions: true, wrapText: true },
                            { label: 'Esito Contatto', fieldName: 'CRM_Esito__c', sortable: "true", hideDefaultActions: true, wrapText: true },
                            { label: 'Autore Esitazione', fieldName: 'CRM_Autore__c', sortable: "true", hideDefaultActions: true, wrapText: true }
                        ];
                        /*if(Boolean(campaign[keyC].Campaign__r.CRM_NomeAttributo1__c))this.campMembColumns.push({ label: campaign[keyC].Campaign__r.CRM_NomeAttributo1__c, fieldName: 'CRM_ValoreAttributo1', type: this.typeMapCMTab[campaign[keyC].Campaign__r.CRM_NomeAttributo1__c], sortable: "true", cellAttributes: { alignment: 'left' }});
                        if(Boolean(campaign[keyC].Campaign__r.CRM_NomeAttributo2__c))this.campMembColumns.push({ label: campaign[keyC].Campaign__r.CRM_NomeAttributo2__c, fieldName: 'CRM_ValoreAttributo2', type: this.typeMapCMTab[campaign[keyC].Campaign__r.CRM_NomeAttributo2__c], sortable: "true", cellAttributes: { alignment: 'left' }});*/
                        set = true;
                        this.campaignColumnsIsSet[selectedRowsArray] = true;
                    }
                }
            }
            // console.log('selectedRowsArray: ', cMFromSelectedCampaign);
    
            this.membersCMTab = JSON.parse(JSON.stringify(cMFromSelectedCampaign));
            this.varTab = 'CMTab';
            this.handleReset();
            this.handleSearch();
            this.setPages(this.filteredMembersCMTab);
            this.disabledButtonAssegnaCampagne = false;
        } catch (error) {
            console.log('DK handleCampaignSelection error: ', error);
        }
    }

    handleCampaignSelectionStep2(event){
        let countSelectedOppRows = event.detail.selectedRows.length;
        if(countSelectedOppRows > 0){          
            this.disabledButtonAssegnaCampagneStep2 = false;
        } else {
            this.disabledButtonAssegnaCampagneStep2 = true;
        }
    }

    handleAssegnaCMTabRequest(event){
        let campaignMembersTable = this.template.querySelector("[data-item='campaignMembersTable']");
        let selectedNdgRows = [];
        // aggiungo alla lista degli elementi selzionati le righe nelle pagina corrente
        if(campaignMembersTable){
            selectedNdgRows = campaignMembersTable.getSelectedRows();
        }
        // aggiungo alla lista degli elementi selzionati le righe nelle altre pagine
        for(let currentPage of Object.keys(this.CMTabSelectRowsMapValues)){
            // console.log('DK currentPage: ', currentPage);
            // console.log('DK this.CMTabPage: ', this.CMTabPage);
            if(currentPage != this.CMTabPage){
                this.CMTabSelectRowsMapValues[currentPage].forEach(element =>{

                    selectedNdgRows.push(element);
                });
            }
        }

        this.selectedCMTabRow = JSON.parse(JSON.stringify(selectedNdgRows));
        // console.log('SV LIST: ', selectedNdgRows);

        let userToShow = this.handleGetCurrentReferenteData(selectedNdgRows);
        
        this.currentReferentData = userToShow;
        this.assCamStep1 = false;
        this.assCamStep2 = false;
        this.assCamStep3 = true;
    }

    handleReferenteSelection(event){
        let selectedReferentRows = event.detail.selectedRows[0].PTF_User__c;
        this.CMTabSelectedReferenteRowIds = event.detail.selectedRows[0].PTF_User__c;
        // console.log('selectedReferentRows: ', selectedReferentRows);
        this.disabledButtonAssegnaCampagneStep3 = false;
    }

    @track handleAssegnaReferenteRequestCMTabClicked = false;
    handleAssegnaReferenteRequestCMTab(event){
        if(this.handleAssegnaReferenteRequestCMTabClicked == false){
            this.handleAssegnaReferenteRequestCMTabClicked = true;
            this.openDialog = true;
        }else{

            this.openDialog = false;
            let selectedReferentRows = this.CMTabSelectedReferenteRowIds;
            // console.log('selectedReferentRows: ', selectedReferentRows);
    
            let selectedCMTabRows = this.selectedCMTabRow;
            // console.log('selectedCMTabRows: ', selectedCMTabRows);
    
            let listCampaignMemberIds = [];
            for(let cm of selectedCMTabRows){
                listCampaignMemberIds.push(cm.CRM_CampaignMemberId__c);
            }
            this.showSpinner = true;
            setCampaignMember({
                userList: selectedReferentRows,
                cmList: listCampaignMemberIds,
            })
            .then(result => {
                // console.log('result', result);
                this.showToastMessage('Assegnazione effettuata correttamente','success');
                // setTimeout(window.location.reload.bind(window.location),1000);
                eval("$A.get('e.force:refreshView').fire();");
                this.showSpinner = false;
                this.assCamStep1 = true;
                this.assCamStep2 = false;
                this.assCamStep3 = false;
                this.handleAssegnaReferenteRequestCMTabClicked = false;
            })
            .catch(error => {
                this.error = error;
                console.log('ERROR', error);
            })
            .finally(() => {});
        }
    }
    //END - TAB CAMPAGNE

    
    //START - TAB EVENT
    handleEventSelection(event){
        let cMFromSelectedEvent = [];
        let selectedRowsArray = event.detail.selectedRows[0].Id;
        this.selectedEvent = event.detail.selectedRows[0];
        // this.labelCampagna = event.detail.selectedRows[0];
        // console.log('selectedRowsArray: ', event.detail.selectedRows[0]);
        // console.log('selectedRowsArray: ', selectedRowsArray);
        let evento = this.eventMember;
        let set = this.campaignColumnsIsSet[selectedRowsArray] ? this.campaignColumnsIsSet[selectedRowsArray] : false;
        for(let keyC in evento){
            let keyArray = keyC.split('_');
            if(keyArray[0] === selectedRowsArray){
                cMFromSelectedEvent.push(evento[keyC]);
                if(!set){
                    this.campMembColumns = [
                        { label: 'NDG', fieldName: 'PTF_AccountUrl', type: 'url',  sortable: "true",hideDefaultActions: true, typeAttributes: {hideDefaultActions: true, label: { fieldName: 'CRM_NDG' }}},
                        { label: 'Nome Cliente', fieldName: 'CRM_AccountName', sortable: "true",hideDefaultActions: true, wrapText: true,target: '_self' },
                        { label: 'M-MDS', fieldName: 'PTF_ModelloDiServizio', sortable: "true", hideDefaultActions: true, wrapText: true },
                        //{ label: 'Portafoglio', fieldName: 'PTF_PortafoglioUrl', type: 'url', typeAttributes: {label: { fieldName: 'PTF_Portafoglio' }} },
                        { label: 'Portafoglio', fieldName: 'PTF_Portafoglio', sortable: "true", hideDefaultActions: true, wrapText: true },
                        { label: 'Stato Assegnazione', fieldName: 'CRM_StatoAssegnazione', sortable: "true", hideDefaultActions: true, wrapText: true },
                        { label: 'Nome Referente', fieldName: 'CRM_ReferenteName', sortable: "true", hideDefaultActions: true, wrapText: true },
                        { label: 'Esito Contatto', fieldName: 'CRM_Esito__c', sortable: "true", hideDefaultActions: true, wrapText: true },
                        { label: 'Autore Esitazione', fieldName: 'CRM_Autore__c', sortable: "true", hideDefaultActions: true, wrapText: true }
                    ];
                    /*if(Boolean(evento[keyC].Campaign__r.CRM_NomeAttributo1__c))this.campMembColumns.push({ label: evento[keyC].Campaign__r.CRM_NomeAttributo1__c, fieldName: 'CRM_ValoreAttributo1', type: this.typeMapEVTab[evento[keyC].Campaign__r.CRM_NomeAttributo1__c], sortable: "true", cellAttributes: { alignment: 'left' }});
                    if(Boolean(evento[keyC].Campaign__r.CRM_NomeAttributo2__c))this.campMembColumns.push({ label: evento[keyC].Campaign__r.CRM_NomeAttributo2__c, fieldName: 'CRM_ValoreAttributo2', type: this.typeMapEVTab[evento[keyC].Campaign__r.CRM_NomeAttributo2__c], sortable: "true", cellAttributes: { alignment: 'left' }});*/
                    set = true;
                    this.campaignColumnsIsSet[selectedRowsArray] = true;
                }
            }
        }

        this.membersEVTab = JSON.parse(JSON.stringify(cMFromSelectedEvent));
        this.varTab = 'EVTab';
        this.handleReset();
        this.handleSearch();
        this.setPages(this.filteredMembersEVTab);
        this.disabledButtonAssegnaEventi = false;
    }

    handleEventSelectionStep2(event){
        let countSelectedOppRows = event.detail.selectedRows.length;
        if(countSelectedOppRows > 0){          
            this.disabledButtonAssegnaEventiStep2 = false;
        } else {
            this.disabledButtonAssegnaEventiStep2 = true;
        }
    }

    handleAssegnaEVTabRequest(event){
        let eventMembersTable = this.template.querySelector("[data-item='eventMembersTable']");
        let selectedNdgRows = [];
        // aggiungo alla lista degli elementi selzionati le righe nelle pagina corrente
        if(eventMembersTable){
            selectedNdgRows = eventMembersTable.getSelectedRows();
        }
        // aggiungo alla lista degli elementi selzionati le righe nelle altre pagine
        for(let currentPage of Object.keys(this.EVTabSelectRowsMapValues)){
            // console.log('DK currentPage: ', currentPage);
            // console.log('DK this.EVTabPage: ', this.EVTabPage);
            if(currentPage != this.EVTabPage){
                this.EVTabSelectRowsMapValues[currentPage].forEach(element =>{

                    selectedNdgRows.push(element);
                });
            }
        }

        this.selectedEVTabRow = JSON.parse(JSON.stringify(selectedNdgRows));
        console.log('SV LIST: ', selectedNdgRows);

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

    @track handleAssegnaReferenteRequestEVTabClicked = false;
    handleAssegnaReferenteRequestEVTab(event){
        if(this.handleAssegnaReferenteRequestEVTabClicked == false){
            this.handleAssegnaReferenteRequestEVTabClicked = true;
            this.openDialog = true;
        }else{

            // this.loaded = false;
            this.openDialog = false;
            let selectedReferentRows = this.EVTabSelectedReferenteRowIds;
            // console.log('selectedReferentRows: ', selectedReferentRows);
    
            let selectedEVTabRows = this.selectedEVTabRow;
            // console.log('selectedEVTabRows: ', selectedEVTabRows);
    
            let listCampaignMemberIds = [];
            for(let cm of selectedEVTabRows){
                listCampaignMemberIds.push(cm.CRM_CampaignMemberId__c);
            }
            this.showSpinner = true;
            setCampaignMember({
                userList: selectedReferentRows,
                cmList: listCampaignMemberIds,
            })
            .then(result => {
                // console.log('result', result);
                this.showToastMessage('Assegnazione effettuata correttamente','success');
                // setTimeout(window.location.reload.bind(window.location),1000);
                eval("$A.get('e.force:refreshView').fire();");
                this.showSpinner = false;
                this.assEvStep1 = true;
                this.assEvStep2 = false;
                this.assEvStep3 = false;
                this.handleAssegnaReferenteRequestEVTabClicked = false;
            })
            .catch(error => {
                this.error = error;
                console.log('ERROR', error);
            })
            .finally(() => {
    
    
                // this.loaded = true;
            });
        }
    }
    //END - TAB EVENTI

    //START - TAB OPPORTUNITY
    handleOppSelection(event){

        let countSelectedOppRows = event.detail.selectedRows.length;
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
                console.log('DK handleAssegnaReferenteRequestOPPTabClicked è:', this.handleAssegnaReferenteRequestOPPTabClicked);
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
                setOpportunity({
                    userList: selectedReferentRows,
                    oppList: listOppIds,
                })
                .then(result => {
                    // console.log('result', result);
                    this.showToastMessage('Assegnazione effettuata correttamente','success');
                    // setTimeout(window.location.reload.bind(window.location),1000);
                    eval("$A.get('e.force:refreshView').fire();");
                    this.showSpinner = false;
                    this.assOppStep1 = true;
                    this.searchedStatoAssegnazioneOPPTab = 'Non assegnato'; //valerio.salvati
                    this.assOppStep2 = false;
                    this.handleAssegnaReferenteRequestOPPTabClicked = false;
                    console.log('DK handleAssegnaReferenteRequestOPPTabClicked è: ', this.handleAssegnaReferenteRequestOPPTabClicked);
                })
                .catch(error => {
                    this.error = error;
                    console.log('ERROR', error);
                })
                .finally(() => {
        
                    // this.loaded = true;
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
                cpw.oppName = oppMember.Name;
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
                        let nameCampagna = cmp.length > 0 ? cmp[i].campaignName : '""'; 
                        let numeroContattiCamp = cmp.length > 0 ? cmp[i].campaignWorkload : '""';
                        serializedResults += '"campagna":"'+nameCampagna+'","numeroContattiCampagne":'+numeroContattiCamp+',';
                    }else{
                        serializedResults +='"campagna":"","numeroContattiCampagne":"",';
                    }
                    if(opp.length >i){
                        let oppName = opp.length > 0 ? opp[i].oppName : '""';
                        let numeroContattiOpp = opp.length > 0 ? opp[i].oppWorkload : '""';
                        serializedResults += '"opportunita":"'+oppName+'","numeroContattiOpportunita":'+numeroContattiOpp+',';
                    }else{
                        serializedResults +='"opportunita":"","numeroContattiOpportunita":"",';
                    }
                    if(evt.length >i){
                        let eventName = evt.length > 0 ? evt[i].eventName : '""';
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
        console.log('serializeResult: '+serializedResults);
        this.tableData = JSON.parse(serializedResults);
        
        // this.hasdata = true;
        this.loaded = true;
    }

    onRowSelectionRefTab(){
        this.disbaleRefAssignButton = false;
    }


    handleRefSelection(){

        this.showSpinner = true;
        console.log('DK this.userAssignmentMap', JSON.parse(JSON.stringify(this.userAssignmentMap)));

        try {
            this.campMembColumns = [
                { label: 'NDG', fieldName: 'PTF_AccountUrl', type: 'url', hideDefaultActions: true, typeAttributes: {hideDefaultActions: true, label: { fieldName: 'CRM_NDG' }}},
                { label: 'Nome Cliente', fieldName: 'CRM_AccountName',hideDefaultActions: true, wrapText: true,target: '_self' },
                { label: 'M-MDS', fieldName: 'PTF_ModelloDiServizio', hideDefaultActions: true, wrapText: true },
                //{ label: 'Portafoglio', fieldName: 'PTF_PortafoglioUrl', type: 'url', typeAttributes: {label: { fieldName: 'PTF_Portafoglio' }} },
                { label: 'Portafgolio', fieldName: 'PTF_Portafoglio', hideDefaultActions: true, wrapText: true },
                { label: 'Esito Contatto', fieldName: 'CRM_Esito__c', hideDefaultActions: true, wrapText: true },
                { label: 'Autore Esitazione', fieldName: 'CRM_Autore__c', hideDefaultActions: true, wrapText: true }
            ];
            let selectedRows = this.template.querySelector("[data-item='tableREFTab']").getSelectedRows();
            let userId = selectedRows[0].Id;
            this.recId = userId;

            // console.log();
            
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
                this.tableEVREFTabIdRows = tableEVREFTab.getSelectedRows().map(element => element.CRM_CampaignMemberId__c);
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
                this.tableCMREFTabIdRows = tableCMREFTab.getSelectedRows().map(element => element.CRM_CampaignMemberId__c);
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
                this.tableOPPREFTabIdRows = tableOPPREFTab.getSelectedRows().map(element => element.Id);
            }
            // aggiungo alla lista degli elementi selzionati le righe nelle altre pagine
            for(let currentPage of Object.keys(this.OPPREFTabSelectRowsMapValues)){
                if(currentPage != this.page){
                    this.OPPREFTabSelectRowsMapValues[currentPage].forEach(element =>{
                        this.tableOPPREFTabIdRows.push(element.Id);
                    });
                }
            }
            var numElementSelected = this.tableEVREFTabIdRows.length + this.tableOPPREFTabIdRows.length + this.tableCMREFTabIdRows.length;
            console.log('numElementSelected: '+numElementSelected);
            console.log('tableEVREFTabIdRows: '+this.tableEVREFTabIdRows.length);
            console.log('tableOPPREFTabIdRows: '+this.tableOPPREFTabIdRows.length);
            console.log('tableCMREFTabIdRows: '+this.tableCMREFTabIdRows.length);
            for(let key in this.contact){
                if(this.contact[key].PTF_User__c != this.recId){
                    // console.log('Dk user: ', this.contact[key].PTF_User__c);
                    let tempData = {};
                    if(countMap[this.contact[key].PTF_User__c]){

                        // console.log('Dk countMap: ', JSON.stringify(countMap[this.contact[key].PTF_User__c]));
                        tempData.PTF_TipologiaRuolo = this.contact[key].PTF_TipologiaRuolo__r ? this.contact[key].PTF_TipologiaRuolo__r.Name : '';
                        tempData.id = this.contact[key].PTF_User__c;
                        tempData.nomeRisorsa = this.contact[key].Name;
                        tempData.nCampagne = countMap[this.contact[key].PTF_User__c].numeroContattiCampagne;
                                               
                        tempData.nOpportunita = countMap[this.contact[key].PTF_User__c].numeroContattiOpportunita;
                        tempData.nEventi = countMap[this.contact[key].PTF_User__c].numeroContattiEventi;

                        tempData.nCampagneToBe = countMap[this.contact[key].PTF_User__c].numeroContattiCampagne + this.tableCMREFTabIdRows.length;
                                               
                        tempData.nOpportunitaToBe = countMap[this.contact[key].PTF_User__c].numeroContattiOpportunita + this.tableOPPREFTabIdRows.length;
                        tempData.nEventiToBe = countMap[this.contact[key].PTF_User__c].numeroContattiEventi + this.tableEVREFTabIdRows.length ;
                    }else{
                        tempData.PTF_TipologiaRuolo = this.contact[key].PTF_TipologiaRuolo__r ? this.contact[key].PTF_TipologiaRuolo__r.Name : '';
                        tempData.id = this.contact[key].PTF_User__c;
                        tempData.nomeRisorsa = this.contact[key].Name;
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
    
            // console.log('Dk this.userDataRows: ', JSON.stringify(this.userDataRows));
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
        if(this.handleSaveClicked == false){

            this.handleSaveClicked = true;
            this.openDialog = true;
        }else{

            this.openDialog = false;
            this.showSpinner = true;
                
                let selectedRowsRef = this.template.querySelector("[data-item='referentiToAssignToTable']").getSelectedRows();

                reassignItem({evList : this.tableEVREFTabIdRows, cmList : this.tableCMREFTabIdRows, oppList : this.tableOPPREFTabIdRows, toUser: selectedRowsRef[0].id})
                .then(result => {
                    if(result){

                        this.reload();
                        // eval("$A.get('e.force:refreshView').fire();");
                    }else{
                        this.showToastMessage('Si è verificato un errore nell\'assegnazione','error');
                    }
                })
                .catch(error => {
                    console.log('reassignItem error: ', error);
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
        if(this.selectedRowsRefStep2C > 0 || this.selectedRowsRefStep2O > 0 || this.selectedRowsRefStep2E > 0){          
            this.disabledButtonAssegnaRefStep2 = false;
        } else {
            this.disabledButtonAssegnaRefStep2 = true;
        }
    }

    onRowSelectionRefTabStep2E(event){
        this.selectedRowsRefStep2E = event.detail.selectedRows.length;
        if(this.selectedRowsRefStep2C > 0 || this.selectedRowsRefStep2O > 0 || this.selectedRowsRefStep2E > 0){          
            this.disabledButtonAssegnaRefStep2 = false;
        } else {
            this.disabledButtonAssegnaRefStep2 = true;
        }
    }

    onRowSelectionRefTabStep2O(event){
        this.selectedRowsRefStep2O = event.detail.selectedRows.length;
        if(this.selectedRowsRefStep2C > 0 || this.selectedRowsRefStep2O > 0 || this.selectedRowsRefStep2E > 0){          
            this.disabledButtonAssegnaRefStep2 = false;
        } else {
            this.disabledButtonAssegnaRefStep2 = true;
        }
    }
    //END - TAB REFERENTI

    reload = async () => {
        this.loaded = false;
        await this.timeout(2000);
        this.handleGetEventMember()
        .then(() =>{
            this.loaded = true;
            this.assEvStep1 = true;
            this.handleGetCampaignMember()
            .then(() =>{
                this.handleGetOppsMember()
                .then(() =>{
                    this.handleGetRefrenti();
                    this.assRefStep1 = true;
                    this.assRefStep2 = false;
                    this.assRefStep3 = false;
                    this.handleSaveClicked = false;
                    this.showSpinner = false;
                    this.showToastMessage('Assegnazione effettuata correttamente','success');
                });
            });
        });
    }

    timeout(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    handleActive(event) {

        // console.log('Start handleActive');
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
        // console.log('DK varTab: ', this.varTab);
    }


    //START Pagination
    @track varTab = undefined;
    handleAvanti(){
        try {
            let tab = this.assCamStep2 ? 'CMTab' : this.assEvStep2 ? 'EVTab' : this.assOppStep1 ? 'OPPTab' : this.varTab != '' && this.varTab != undefined ? this.varTab : '';
            // console.log('DK tab: ', tab);
            let selectedRows = tab == 'CMTab' ? this.template.querySelector("[data-item='campaignMembersTable']").getSelectedRows() :
            tab == 'EVTab' ? this.template.querySelector("[data-item='eventMembersTable']").getSelectedRows() : 
            this.template.querySelector("[data-item='oppMembersTable']").getSelectedRows();
            let selectedRowIds = selectedRows.map(element => element.Id);
            
            this[tab + 'SelectRowsMapValues'][this[tab + 'Page']] = selectedRows;
            this[tab + 'SelectRowsMap'][this[tab + 'Page']] = selectedRowIds;
            this['selected' + tab +'Row'] = Boolean(this[tab + 'SelectRowsMapValues'][this[tab + 'Page']+1]) ? this[tab + 'SelectRowsMapValues'][this[tab + 'Page']+1] : [];
            this['selected' + tab +'RowIds'] = Boolean(this[tab + 'SelectRowsMap'][this[tab + 'Page']+1]) ? this[tab + 'SelectRowsMap'][this[tab + 'Page']+1] : [];
            // console.log('DK SELECTED ROWS: '  + JSON.stringify(this['selected' + tab +'Row']));
            ++this[tab + 'Page'];
        } catch (error) {
            console.log('error: ', error);
        }
    }

    handleIndietro(){
        try {
            
            let tab = this.assCamStep2 ? 'CMTab' : this.assEvStep2 ? 'EVTab' : this.assOppStep1 ? 'OPPTab' : this.varTab != '' && this.varTab != undefined ? this.varTab : '';
            // console.log('DK tab: ', tab);
            let selectedRows = tab == 'CMTab' ? this.template.querySelector("[data-item='campaignMembersTable']").getSelectedRows() :
            tab == 'EVTab' ? this.template.querySelector("[data-item='eventMembersTable']").getSelectedRows() : 
            this.template.querySelector("[data-item='oppMembersTable']").getSelectedRows();
            let selectedRowIds = selectedRows.map(element => element.Id);

            this[tab + 'SelectRowsMapValues'][this[tab + 'Page']] = selectedRows;
            this[tab + 'SelectRowsMap'][this[tab + 'Page']] = selectedRowIds;
            this['selected' + tab + 'Row'] = this[tab + 'SelectRowsMapValues'][this[tab + 'Page'] -1];
            this['selected' + tab + 'RowIds'] = this[tab + 'SelectRowsMap'][this[tab + 'Page'] -1];
            // console.log('DK SELECTED ROWS: '  + JSON.stringify(this['selected' + tab + 'Row']));
            --this[tab + 'Page'];
        } catch (error) {
            console.log('error: ', error);
        }
    }

    pageData = ()=>{
        let tab = this.assCamStep2 ? 'CMTab' : this.assEvStep2 ? 'EVTab' : this.assOppStep1 ? 'OPPTab' : this.varTab != '' && this.varTab != undefined ? this.varTab : '';
        console.log('DK tab: ', tab);
        let page = this[tab + 'Page'];
        let perpage = this.perpage;
        let startIndex = (page*perpage) - perpage;
        let endIndex = (page*perpage);
        let recordToDisplay = this['filteredMembers' + tab].slice(startIndex,endIndex);
        //let recordToDisplayIdList = recordToDisplay.map(item => item.Id);
        return recordToDisplay;
    }

    setPages = (data)=>{
        let tab = this.assCamStep2 ? 'CMTab' : this.assEvStep2 ? 'EVTab' : this.assOppStep1 ? 'OPPTab' : this.varTab != '' && this.varTab != undefined ? this.varTab : '';
        // console.log('DK tab: ', tab);
        this[tab + 'Pages'] = [];
        // console.log('DK data: ' + data.length);
        let numberOfPages = Math.ceil(data.length / this.defaultLimit);
        // console.log('DK numberOfPages: ' + numberOfPages);
        for (let index = 1; index <= numberOfPages; index++) {
            this[tab + 'Pages'].push(index);
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
        this.handleindietro();
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
        this.handleindietro();
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
        this.handleindietro();
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
    @track EVREFTabSelectRowsMap = {};
    @track EVREFTabSelectRowsMapValues = {};
    @track OPPREFTabSelectRowsMap = {};
    @track OPPREFTabSelectRowsMapValues = {};
    // END Pagination

    //START FILTER
    @track searchedStatoAssegnazioneCMTab = 'Non assegnato';
    @track searchedMMDSCMTab = '';
    @track searchedPrioritaCMTab = '';
    @track searchedEsitoCMTab = '';
    @track searchedNomeMwCMTab = '';
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

    @track searchedStatoAssegnazioneREFTab = 'Non assegnato';
    @track searchedMMDSREFTab = '';
    @track searchedPrioritaREFTab = '';
    @track searchedEsitoREFTab = '';
    @track searchedNomeMwREFTab = '';
    @track searchedNDGREFTab = '';
    @track searchedRefREFTab = '';
    @track searchedAutoreREFTab = '';//valerio.salvati

    handleFilter(event){

        // console.log('DK handleFilter Started');
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
        }else if(event.target.name == 'searchedStatoAssegnazioneREFTab'){
            
            this.searchedStatoAssegnazioneREFTab = event.target.value;
        }else if(event.target.name == 'searchedMMDSREFTab'){
            
            this.searchedMMDSREFTab = event.target.value;
        }else if(event.target.name == 'searchedPrioritaREFTab'){
            
            this.searchedPrioritaREFTab = event.target.value;
        }else if(event.target.name == 'searchedEsitoREFTab'){
            
            this.searchedEsitoREFTab = event.target.value;
        }else if(event.target.name == 'searchedNomeMwREFTab'){
            
            this.searchedNomeMwREFTab = event.target.value;
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
        // console.log('DK handleReset tab: ', tab);
        // console.log('DK handleReset filterTab: ', filterTab);
        //if(Boolean(this['searchedStatoAssegnazione' + filterTab]))this['searchedStatoAssegnazione' + filterTab] = '';
        if(Boolean(this['searchedStatoAssegnazione' + filterTab]))this['searchedStatoAssegnazione' + filterTab] = 'Non assegnato';//valerio.salvati
        if(Boolean(this['searchedStatoAssegnazione' + filterTab]))this['searchedAutore' + filterTab] = '';//valerio.salvati
        if(Boolean(this['searchedStatoAssegnazione' + filterTab]))this['searchedAccName' + filterTab] = '';//valerio.salvati
        if(Boolean(this['searchedMMDS' + filterTab]))this['searchedMMDS' + filterTab] = '';
        if(Boolean(this['searchedPriorita' + filterTab]))this['searchedPriorita' + filterTab] = '';
        if(Boolean(this['searchedEsito' + filterTab]))this['searchedEsito' + filterTab] = '';
        if(Boolean(this['searchedNomeMw' + filterTab]))this['searchedNomeMw' + filterTab] = '';
        if(Boolean(this['searchedNDG' + filterTab]))this['searchedNDG' + filterTab] = '';
        if(Boolean(this['searchedRef' + filterTab]))this['searchedRef' + filterTab] = '';
        if(Boolean(this['selectedNomeAttributo1' + filterTab]))this['selectedNomeAttributo1' + filterTab] = '';
        if(Boolean(this['selectedValoreAttributo1Start' + filterTab]))this['selectedValoreAttributo1Start' + filterTab] = '';
        if(Boolean(this['selectedValoreAttributo1End' + filterTab]))this['selectedValoreAttributo1End' + filterTab] = '';
        if(Boolean(this['selectedNomeAttributo2' + filterTab]))this['selectedNomeAttributo2' + filterTab] = '';
        if(Boolean(this['selectedValoreAttributo2Start' + filterTab]))this['selectedValoreAttributo2Start' + filterTab] = '';
        if(Boolean(this['selectedValoreAttributo2End' + filterTab]))this['selectedValoreAttributo2End' + filterTab] = '';
        if(Boolean(this['searchedValoreAttributo1' + filterTab]))this['searchedValoreAttributo1' + filterTab] = '';
        if(Boolean(this['searchedValoreAttributo2' + filterTab]))this['searchedValoreAttributo2' + filterTab] = '';
        if(Boolean(this['showRangeNum1' + filterTab]))this['showRangeNum1' + filterTab] = false;
        if(Boolean(this['showRangeDate1' + filterTab]))this['showRangeDate1' + filterTab] = false;
        if(Boolean(this['showSearchtext1' + filterTab]))this['showSearchtext1' + filterTab] = false;
        if(Boolean(this['showRangeNum2' + filterTab]))this['showRangeNum2' + filterTab] = false;
        if(Boolean(this['showRangeDate2' + filterTab]))this['showRangeDate2' + filterTab] = false;
        if(Boolean(this['showSearchtext2' + filterTab]))this['showSearchtext2' + filterTab] = false;
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
        let tab = this.assCamStep2 ? 'CMTab' : this.assEvStep2 ? 'EVTab' : this.assOppStep1 ? 'OPPTab' : this.varTab != '' && this.varTab != undefined ? this.varTab : '';
        let filterTab = ['CMREFTab', 'EVREFTab', 'OPPREFTab'].includes(tab) ? 'REFTab' : tab;
        console.log('DK handleSearch tab: ', tab);
        console.log('DK handleSearch filterTab: ', filterTab);
        console.log('DK handleSearch members: ', JSON.parse(JSON.stringify(this['members' + tab])));
        let filteredList = [];
        this[tab + 'Page'] = 1;
        try {
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
                    if(this['members' + tab][i].CRM_AccName.toLowerCase() != this['searchedAccName' + filterTab].toLowerCase()){
                        continue;
                    }
                }if(Boolean(this['searchedAutore' + filterTab])){
                    if(this['members' + tab][i].CRM_Autore.toLowerCase() != this['searchedAutore' + filterTab].toLowerCase()){
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
            
            // console.log('DK error: ' + error);
        }
    }

    get optionsStato() {
        return [
            { label: '---Nessun filtro---', value: '' },
            { label: 'Assegnato', value: 'Assegnato' },
            { label: 'Non assegnato', value: 'Non assegnato' }
        ];
    }

    get optionsMMDS() {
        return [
            { label: '---Nessun filtro---', value: '' },
            { label: 'POE', value: 'POE' },
            { label: 'Family', value: 'Family' },
            { label: 'Assente', value: 'Assente' },
            { label: 'Residuale', value: 'Residuale' },
            { label: 'Non Portafogliati', value: 'Non Portafogliati' }
        ];
    }

    get optionsPriorita() {
        return [
            { label: '---Nessun filtro---', value: '' },
            { label: '1', value: '1' },
            { label: '2', value: '2' },
            { label: '3', value: '3' },
            { label: '4', value: '4' },
            { label: '5', value: '5' }
        ];
    }

    get optionsCanale() {
        return [
            { label: '---Nessun filtro---', value: '' },
            { label: 'Campagna commerciale', value: 'Campagna commerciale' },
            { label: 'Check-up', value: 'Check-up' },
            { label: 'Contact Center', value: 'Contact Center'}
        ];
    }

    get optionsBisogno() {
        return [
            { label: '---Nessun filtro---', value: '' },
            { label: 'Finanziamenti', value: 'Finanziamenti' },
            { label: 'Assicurativo', value: 'Assicurativo' }
        ]
    }

    get optionsEsito() {
        return [
            { label: '---Nessun filtro---', value: '' },
            { label: 'Da contattare', value: 'Da contattare' },
            { label: 'Non contattabile', value: 'Non contattabile' },
            { label: 'Cliente non adatto', value: 'Cliente non adatto' },
            { label: 'Cliente interessato', value: 'Cliente interessato' },
            { label: 'Prodotto target venduto', value: 'Prodotto target venduto' },
            { label: 'Da ricontattare', value: 'Da ricontattare' },
            { label: 'Fissato appuntamento', value: 'Fissato appuntamento' },
            { label: 'Altro prodotto venduto', value: 'Altro prodotto venduto' },
            { label: 'Ingaggio agente', value: 'Ingaggio agente' },
            { label: 'Cliente non contattabile', value: 'Cliente non contattabile' },
            { label: 'Cliente non interessato', value: 'Cliente non interessato' }                
        ];
    }

    get optionsFase() {
        return [
            { label: '---Nessun filtro---', value: '' },
            { label: 'Da Contattare', value: 'Da Contattare' },
            { label: 'Non Risponde 1', value: 'Non Risponde 1' },
            { label: 'Non Risponde 2', value: 'Non Risponde 2' },
            { label: 'Non Risponde 3', value: 'Non Risponde 3' },
            { label: 'Non raggiungibile', value: 'Non raggiungibile' },
            { label: 'Accettata', value: 'Accettata' },
            { label: 'Rifiutata' , value: 'Rifiutata'},
            { label: 'Eliminata', value: 'Eliminata'}
        ];
    }

    get optionsEsitoOpp() {
        return [
            { label: '---Nessun filtro---', value: ''},
            { label: 'Da contattare', value: 'Da contattare' },
            { label: 'Da ricontattare', value: 'Da ricontattare' },
            { label: 'Fissato appuntamento', value: 'Fissato appuntamento' }
        ];
    }
    //END FILTER

    handleSendRequestCMTab(event){
        this.varTab ='CMTab';
        this.assCamStep1 = false;
        this.assCamStep2 = true;
        this.assCamStep3 = false;

        //valerio.salvati
        this.searchedStatoAssegnazioneCMTab = 'Non assegnato'

    }
    handleSendRequestEVTab(event){
        console.log(event.target.dataset.id);
        if(event.target.dataset.id.split('_')[0] == 'assegna'){
            this.varTab ='EVTab';
            this.assEvStep1 = false;
            this.assEvStep2 = true;
            this.assEvStep3 = false;

            //valerio.salvati
            this.searchedStatoAssegnazioneEVTab = 'Non assegnato'
        } else {
            let evTabcampaignTable = this.template.querySelector("[data-item='EVTabcampaignTable']").getSelectedRows();
            console.log(evTabcampaignTable);

            let arr = this.idReferentiEVTabAssegnate;

            let userToShow = this.contactElegibleRoleMDS.Tecnico;
            
            







            
            this.currentReferentData = userToShow;

            this.assEvStep1 = false;
            this.assEvStep2 = false;
            this.assEvStep3 = true;
        }
    }

    // ----------------------------------------------------------------------------- START HELPERS -----------------------------------------------------------------------------
    extendCampaignEventMembers(campaignEventMembers){
        let response = {};
        let campaign = campaignEventMembers;
        let data = [];
        let clientListData = [];
        let referentiListData = [];
        let foundAttributo1 = [];
        let foundAttributo2 = [];
        let typeMap = {};
        let optionsAttributo1 = [];
        let optionsAttributo2 = [];
        let idReferentiAssegnate = [];
        
        for(let keyC in campaign){
            let keyArray = keyC.split('_');
            campaign[keyC] = JSON.parse(JSON.stringify(campaign[keyC]));
            campaign[keyC].CRM_NDG = campaign[keyC].CRM_Account__r.CRM_NDG__c;
            campaign[keyC].PTF_AccountUrl =  '/' + campaign[keyC].CRM_Account__c;
            campaign[keyC].CRM_AccountName = campaign[keyC].CRM_Account__r.Name;
            campaign[keyC].PTF_NaturaGiuridica = campaign[keyC].CRM_Account__r.PTF_NaturaGiuridica__c;
            campaign[keyC].PTF_PortafoglioUrl =  campaign[keyC].CRM_Account__r.hasOwnProperty('PTF_Portafoglio__c') ? '/' + campaign[keyC].CRM_Account__r.PTF_Portafoglio__c : '';
            campaign[keyC].PTF_Portafoglio = campaign[keyC].CRM_Account__r.hasOwnProperty('PTF_Portafoglio__c') ? campaign[keyC].CRM_Account__r.PTF_Portafoglio__r.Name : '';
            campaign[keyC].PTF_ModelloDiServizio = Boolean(campaign[keyC].CRM_Account__r.ModelloDiServizio__c) ? campaign[keyC].CRM_Account__r.ModelloDiServizio__c : 'Non Portafogliati';
            campaign[keyC].CRM_StatoAssegnazione = campaign[keyC].hasOwnProperty('CRM_AssegnatarioUser__c') ? 'Assegnato' : 'Non assegnato';
            campaign[keyC].CRM_ReferenteName = campaign[keyC].hasOwnProperty('CRM_AssegnatarioUser__c') ? campaign[keyC].CRM_AssegnatarioUser__r.Name : '';
            // ATTRIBUTI DINAMICI
            campaign[keyC].CRM_NomeAttributo1 = campaign[keyC].Campaign__r.CRM_NomeAttributo1__c;
            campaign[keyC].CRM_NomeAttributo2 = campaign[keyC].Campaign__r.CRM_NomeAttributo2__c;

            campaign[keyC].CRM_Autore = campaign[keyC].hasOwnProperty('CRM_Autore__c') ? campaign[keyC].CRM_Autore__c : '';
            if(Boolean(campaign[keyC].CRM_ValoreAttributo1_Date__c)){
                campaign[keyC].CRM_ValoreAttributo1 = campaign[keyC].CRM_ValoreAttributo1_Date__c;
                campaign[keyC].type1 = 'date';
                
            }else if(Boolean(campaign[keyC].CRM_ValoreAttributo1_Number__c)){
                campaign[keyC].CRM_ValoreAttributo1 = campaign[keyC].CRM_ValoreAttributo1_Number__c;
                campaign[keyC].type1 = 'number';
            }else{
                campaign[keyC].CRM_ValoreAttributo1 = campaign[keyC].CRM_ValoreAttributo1_Text__c;
                campaign[keyC].type1 = 'text';
            }

            if(Boolean(campaign[keyC].CRM_ValoreAttributo2_Date__c)){
                campaign[keyC].CRM_ValoreAttributo2 = campaign[keyC].CRM_ValoreAttributo2_Date__c;
                campaign[keyC].type2 = 'date';
            }else if(Boolean(campaign[keyC].CRM_ValoreAttributo2_Number__c)){
                campaign[keyC].CRM_ValoreAttributo2 = campaign[keyC].CRM_ValoreAttributo2_Number__c;
                campaign[keyC].type2 = 'number';
            }else{
                campaign[keyC].CRM_ValoreAttributo2 = campaign[keyC].CRM_ValoreAttributo2_Text__c;
                campaign[keyC].type2 = 'text';
            }

            if(Boolean(campaign[keyC].Campaign__r.CRM_NomeAttributo1__c)){
                if(!foundAttributo1.includes(campaign[keyC].Campaign__r.CRM_NomeAttributo1__c)){
                    typeMap[campaign[keyC].Campaign__r.CRM_NomeAttributo1__c] = campaign[keyC].type1;foundAttributo1.push(campaign[keyC].Campaign__r.CRM_NomeAttributo1__c);
                    optionsAttributo1.push({
                        label : campaign[keyC].Campaign__r.CRM_NomeAttributo1__c,
                        value: campaign[keyC].Campaign__r.CRM_NomeAttributo1__c
                    })
                }
            }
            if(Boolean(campaign[keyC].Campaign__r.CRM_NomeAttributo2__c)){
                if(!foundAttributo2.includes(campaign[keyC].Campaign__r.CRM_NomeAttributo2__c)){
                    typeMap[campaign[keyC].Campaign__r.CRM_NomeAttributo2__c] = campaign[keyC].type2;foundAttributo2.push(campaign[keyC].Campaign__r.CRM_NomeAttributo2__c);
                    optionsAttributo2.push({
                        label : campaign[keyC].Campaign__r.CRM_NomeAttributo2__c,
                        value: campaign[keyC].Campaign__r.CRM_NomeAttributo2__c
                    })
                }
            }
            // ATTRIBUTI DINAMICI

            let findCampaign = data.filter(obj => {
                return obj.Id === keyArray[0]
            })

            let findClient = clientListData.filter(obj => {
                return obj.modelloServizio === keyArray[2]
            })

            let findReferente = [];
            if(campaign[keyC].hasOwnProperty('CRM_AssegnatarioUser__c')){
                idReferentiAssegnate.push(campaign[keyC].CRM_AssegnatarioUser__c);
                findReferente = referentiListData.filter(obj => {
                    return obj.Id === campaign[keyC].CRM_AssegnatarioUser__c
                })
            }

            if(findCampaign.length === 0){
                let obj = {};
                obj.Id = keyArray[0];
                obj.bisogno = campaign[keyC].Campaign__r.CRM_Categoria__c;
                obj.nomeCampagna = campaign[keyC].Campaign__r.Name;
                obj.nameUrl = '/' + keyArray[0];
                obj.priorita = campaign[keyC].Campaign__r.CRM_Priorita__c;
                obj.startDate = campaign[keyC].Campaign__r.CRM_StartDateFormula__c;
                obj.endDate = campaign[keyC].Campaign__r.CRM_EndDateFormula__c;

                obj.totaleContatti = !campaign[keyC].CRM_AssegnatarioUser__r ? 1 : 0;
                obj.contattiMdsFamily = (keyArray[2] == 'Family' && !campaign[keyC].CRM_AssegnatarioUser__r) ? 1 : 0;
                obj.contattiMdsPoe = (keyArray[2] == 'POE' && !campaign[keyC].CRM_AssegnatarioUser__r) ? 1 : 0;
                obj.nonPortafogliati = (keyArray[2] == 'Non Portafogliati' && !campaign[keyC].CRM_AssegnatarioUser__r) ? 1 : 0;
                obj.assente = (keyArray[2] == 'Assente' && !campaign[keyC].CRM_AssegnatarioUser__r) ? 1 : 0;
                obj.residuale = (keyArray[2] == 'Residuale' && !campaign[keyC].CRM_AssegnatarioUser__r) ? 1 : 0;

                obj.tipologia = campaign[keyC].Campaign__r.Tipologia_Azione__c;
                data.push(obj);

            } else {
                if(!campaign[keyC].CRM_AssegnatarioUser__r){
                    findCampaign[0].totaleContatti = findCampaign[0].totaleContatti + 1;
                    findCampaign[0].contattiMdsFamily = keyArray[2] == 'Family' ? findCampaign[0].contattiMdsFamily + 1 : findCampaign[0].contattiMdsFamily;
                    findCampaign[0].contattiMdsPoe = keyArray[2] == 'POE' ? findCampaign[0].contattiMdsPoe + 1 : findCampaign[0].contattiMdsPoe;
                    findCampaign[0].nonPortafogliati =  keyArray[2] == 'Non Portafogliati' ? findCampaign[0].nonPortafogliati + 1 : findCampaign[0].nonPortafogliati;
                    findCampaign[0].assente = keyArray[2] == 'Assente' ? findCampaign[0].assente + 1 : findCampaign[0].assente;
                    findCampaign[0].residuale = keyArray[2] == 'Residuale' ? findCampaign[0].residuale + 1 : findCampaign[0].residuale;
                }
            }

            if(findClient.length === 0){
                let obj = {};
                obj.modelloServizio = keyArray[2];

                obj.countNum = 1;
                obj.countDaAss = campaign[keyC].hasOwnProperty('CRM_AssegnatarioUser__c') ? 0 : 1;

                clientListData.push(obj);

            } else {
                findClient[0].countNum = findClient[0].countNum + 1;
                findClient[0].countDaAss = campaign[keyC].hasOwnProperty('CRM_AssegnatarioUser__c') ? findClient[0].countDaAss : findClient[0].countDaAss + 1;
            }

            if(campaign[keyC].hasOwnProperty('CRM_AssegnatarioUser__c')){
                if(findReferente.length === 0){
                    let obj = {};
                    obj.Id = campaign[keyC].CRM_AssegnatarioUser__c;
                    obj.nomeRisorsa = campaign[keyC].CRM_AssegnatarioUser__r.Name;

                    obj.numeroContatti = 1;

                    obj._children = [];
                    let objChild = {};
                    objChild.Id = keyArray[0];
                    objChild.nomeRisorsa = campaign[keyC].Campaign__r.Name;
                    objChild.numeroContatti = 1;

                    obj._children.push(objChild);
                    referentiListData.push(obj);

                } else {
                    findReferente[0].numeroContatti = findReferente[0].numeroContatti + 1;
                    let findCampaignRef = findReferente[0]._children.filter(obj => {
                        return obj.Id === keyArray[0]
                    })

                    if(findCampaignRef.length === 0){
                        let objChild = {};
                        objChild.Id = keyArray[0];
                        objChild.nomeRisorsa = campaign[keyC].Campaign__r.Name;
                        objChild.numeroContatti = 1;

                        findReferente[0]._children.push(objChild);
                    } else {
                        findCampaignRef[0].numeroContatti = findCampaignRef[0].numeroContatti + 1;
                    }
                }
            }
        }

        response.data = data;
        response.clientListData = clientListData;
        response.referentiListData = referentiListData;
        response.foundAttributo1 = foundAttributo1;
        response.foundAttributo2 = foundAttributo2;
        response.typeMap = typeMap;
        response.optionsAttributo1 = optionsAttributo1;
        response.optionsAttributo2 = optionsAttributo2;
        response.idReferentiAssegnate = idReferentiAssegnate;

        return response;
    }
    handleGetCurrentReferenteData(selectedRows){
        console.log(selectedRows);
        let mySet1 = new Set();
        for(let record of selectedRows){
            mySet1.add(record.PTF_ModelloDiServizio)   
        }

        // console.log('SV mySet1: ', mySet1);


        let userToShow = [];
        if(!mySet1.has(undefined) && !mySet1.has('Residuale') && !mySet1.has('Assente')){
            // console.log('SV non Tecnico');
            if(mySet1.has('Family') && mySet1.has('POE')){
                // console.log('SV Family POE');
                userToShow = this.contactElegibleRoleMDS.POE_Family;
            } else if(mySet1.has('Family')){
                // console.log('SV Family');
                userToShow = this.contactElegibleRoleMDS.Family;
            } else if(mySet1.has('POE')){
                // console.log('SV POE');
                userToShow = this.contactElegibleRoleMDS.POE;
            } 
        } else {
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
        }

        let arr = this.assCamStep2 ? this.idReferentiCMTabAssegnate : this.assEvStep2 ? this.idReferentiEVTabAssegnate : this.idReferentiOPPTabAssegnate;
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
        }else if(this.assEvStep2){
            this.assEvStep1 = true;
            this.assEvStep2 = false;
            this.assEvStep3 = false;
        }else if(this.assEvStep3){
            this.assEvStep1 = false;
            this.assEvStep2 = true;
            this.assEvStep3 = false;
        }else if(this.assCamStep2){
            this.assCamStep1 = true;
            this.assCamStep2 = false;
            this.assCamStep3 = false;
        }else if(this.assCamStep3){
            this.assCamStep1 = false;
            this.assCamStep2 = true;
            this.assCamStep3 = false;
        }else if(this.assOppStep2){
            this.assOppStep1 = true;
            this.assOppStep2 = false;
        }
    }
    // handleToggle(event){
    //     if(event.detail.isExpanded == true){
    //         this.columnsListaRefrenti = COLUMNSLISTAREFRENTIEXPANDED;
    //     }else{
    //         this.columnsListaRefrenti = COLUMNSLISTAREFRENTI;
    //     }
    // }
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
        console.log('DK handleAssegnaReferenteRequestCMTabClicked: ' + this.handleAssegnaReferenteRequestCMTabClicked);
        console.log('DK handleAssegnaReferenteRequestEVTabClicked: ' + this.handleAssegnaReferenteRequestEVTabClicked);
        console.log('DK handleAssegnaReferenteRequestOPPTabClicked: ' + this.handleAssegnaReferenteRequestOPPTabClicked);
        if(event.currentTarget.name == 'cancel'){
            this.openDialog = false;
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
    onHandleSort( event ) {
        let tab = this.assCamStep2 ? 'CMTab' : this.assEvStep2 ? 'EVTab' : this.assOppStep1 ? 'OPPTab' : this.varTab != '' && this.varTab != undefined ? this.varTab : '';
        // console.log('DK tab: ', tab);
        let filteredList = this['filteredMembers' + tab];
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...filteredList];
        // console.log('DK sortedBy: ' + sortedBy);
        // console.log('DK sortDirection: ' + sortDirection);
        //cloneData.sort( this.sortBy( sortedBy, sortDirection === 'asc' ? 1 : -1 ) );
        cloneData.sort( this.sortBy( sortedBy != 'PTF_AccountUrl' ? sortedBy : 'CRM_NDG', sortDirection === 'asc' ? 1 : -1 ) );
        filteredList = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        this['filteredMembers' + tab] = filteredList;
        this.setPages(this['filteredMembers' + tab]);
    }
    sortBy( field, reverse, primer ) {

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

    }
    // END SORT

    sortBy2( field, reverse, primer ) {

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

    }

    sortBy3( field, reverse, primer ) {

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

    }

    sortBy4( field, reverse, primer ) {

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


        
    }

    sortBy5( field, reverse, primer ) {

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


        
    }

    sortBy6( field, reverse, primer ) {

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


        
    }

    sortBy7( field, reverse, primer ) {

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


        
    }
    

}