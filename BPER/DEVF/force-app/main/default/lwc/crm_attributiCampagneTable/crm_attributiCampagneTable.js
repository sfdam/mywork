import { LightningElement,api,track } from 'lwc';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUserInfo from '@salesforce/apex/CRM_AttributiCampagneTableController.getUserInfo';
import getCampaignMember from '@salesforce/apex/CRM_AttributiCampagneTableController.getCampaignMember';
import getCampaignMemberAll from '@salesforce/apex/CRM_AttributiCampagneTableControllerAll.getCampaignMember';

//label: { fieldName: 'CRM_NDG__c' }

export default class Crm_attributiCampagneTable extends LightningElement {
    @api recordId;
    @api defaultLimit;
    @track data = [];
    @track filteredData = [];
    @track columns = [];
    sortedBy;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    @track type1;
    @track type2;
    @track showErrorMassage =false;
    @track showFilter = false;
    @track loaded = false;
    @track campaignCondition = false;

    @track typeMap = {};

    @track showRangeNum1 = false; 
    @track showRangeDate1 = false;
    @track showSearchtext1 = false;

    @track showRangeNum2 = false; 
    @track showRangeDate2 = false;
    @track showSearchtext2 = false;

    @track optionsAttributo1 = [];
    @track foundAttributo1 = [];
    @track optionsAttributo2 = [];
    @track foundAttributo2 = [];

    @track showFiltroAttributo1 = false;
    @track showFiltroAttributo2 = false;

    @track currentUserRuoloLdap ='';
    @track numMembers = 0;

    connectedCallback(){
        
        if(!this.defaultLimit){
            this.defaultLimit = this.perpage;
        }
        try {
            console.log('FS Start recordId: ', this.recordId);
            getUserInfo()
            .then(result => {
            console.log( 'UserProfile: '+result.Profile.Name );
            console.log( 'this.ruololdap: '+result.PTF_RuoloLDAP__c );
            this.currentUserRuoloLdap=result.PTF_RuoloLDAP__c;
            console.log( 'this.currentUserRuoloLdap: '+this.currentUserRuoloLdap );
            if(this.currentUserRuoloLdap==='016' || this.currentUserRuoloLdap==='013' || result.idced__c==='27938'){
                getCampaignMemberAll({recordId:this.recordId})
                .then(result => {
                console.log('FS then result: ', result);
                console.log('PZ init result: ', result);
                if (result.errorMessage){
                    const event = new ShowToastEvent({
                    });
                    this.dispatchEvent(event);
                    this.loaded = true;
                    this.showErrorMassage = true;
                }else{
                let nomeAttributo1 = '';
                let nomeAttributo2 = '';
                let sortedBy = '';
                let sortDirection = '';
                console.log('FS getData related to campaign', this.recordId);
                console.log('FS getData result', result);
                let firstEl = result.campaignMemberList[0];
                let campaignEl = firstEl.Campaign__r;
                let tipologia = campaignEl.Tipologia_Azione__c;
                let devNameRT = campaignEl.RecordType.DeveloperName;
                this.campaignCondition = tipologia == 'Dinamica' || devNameRT == 'Trigger_Monostep';

                result.campaignMemberList.forEach(element =>{
                    element.PTF_CampaignName = element.Campaign__r.Name;
                    element.PTF_UrlCampaign = '/' + element.Campaign__c;
                    element.CRM_NDG = element.CRM_Account__r.CRM_NDG__c;
                    element.CRM_UrlNDG = '/' + element.CRM_Account__c;
                    element.CRM_AccountName = element.CRM_Account__r.Name;
                    element.CRM_Assegnatario = element.CRM_AssegnatarioFormula__c ? element.CRM_AssegnatarioFormula__c : '';
                    element.PTF_Filiale = element.CRM_Account__r.PTF_Filiale__r ? element.CRM_Account__r.PTF_Filiale__r.Name : (element.CRM_Account__r.CRM_Filiale__r ? element.CRM_Account__r.CRM_Filiale__r.Name : '');
                    element.PTF_Portafoglio = element.PTF_Portafoglio__r ? element.PTF_Portafoglio__r.Name : '';
                    element.PTF_Referente = (element.PTF_Portafoglio__r && element.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r)  ? element.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName +' ' +element.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName : '';
                    element.CRM_Autor = element.CRM_Autore__c; 
                    element.PTF_UrlPortafoglio = element.PTF_Portafoglio__r ? '/' + element.PTF_Portafoglio__c : '';
                    element.CRM_NomeAttributo1 = element.Campaign__r.CRM_Nome_Attributo_1_formula__c;
                    element.CRM_NomeAttributo2 = element.Campaign__r.CRM_Nome_Attributo_2_formula__c;
                    // MS - Cambiato in Data_ingresso__c
                    element.Data_ingresso__c  = element.Data_ingresso__c;
                    element.ID_P2 = element.Priorita_Campaign_Member__c;
                    element.ID_P3 = element.ID_P3__c;
                    
                    if(element.CRM_CheckNewInsert__c)
                        element.newIcon= 'standard:work_queue';
                    
                    if(element.checkNewExit__c)
                        element.newIcon= 'standard:return_order_line_item';
                    
                    if(!nomeAttributo1 && !nomeAttributo2){
                        nomeAttributo1 = element.Campaign__r.CRM_Nome_Attributo_1_formula__c;
                        nomeAttributo2 = element.Campaign__r.CRM_Nome_Attributo_2_formula__c;
                    }
                    
                    if(!element.Campaign__r.CRM_Ordinamento_Attributo__c || !element.Campaign__r.Ordinamento__c &&
                        (!sortedBy && !sortDirection)){
                        
                        sortedBy = element.Campaign__r.CRM_Ordinamento_Attributo__c == 'Attributo 1' ? 'CRM_ValoreAttributo1' : 'CRM_ValoreAttributo2';
                        sortDirection = element.Campaign__r.Ordinamento__c == 'Crescente' ? 'asc' : 'desc';
                    }

                    if(Boolean(element.CRM_ValoreAttributo1_Date__c)){
                        element.CRM_ValoreAttributo1 = element.CRM_ValoreAttributo1_Date__c;
                        if(!this.type1)this.type1 = 'date'
                        element.type1 = 'date';
                    }else if(Boolean(element.CRM_ValoreAttributo1_Number__c)){
                        element.CRM_ValoreAttributo1 = element.CRM_ValoreAttributo1_Number__c;
                        if(!this.type1)this.type1 = 'number'
                        element.type1 = 'number';
                    }else{
                        element.CRM_ValoreAttributo1 = element.CRM_ValoreAttributo1_Text__c;
                        if(!this.type1)this.type1 = 'text'
                        element.type1 = 'text';
                    }

                    if(Boolean(element.CRM_ValoreAttributo2_Date__c)){
                        element.CRM_ValoreAttributo2 = element.CRM_ValoreAttributo2_Date__c;
                        if(!this.type2)this.type2 = 'date'
                        element.type2 = 'date';
                    }else if(Boolean(element.CRM_ValoreAttributo2_Number__c)){
                        element.CRM_ValoreAttributo2 = element.CRM_ValoreAttributo2_Number__c;
                        if(!this.type2)this.type2 = 'number'
                        element.type2 = 'number';
                    }else{
                        element.CRM_ValoreAttributo2 = element.CRM_ValoreAttributo2_Text__c;
                        if(!this.type2)this.type2 = 'text'
                        element.type2 = 'text';
                    }

                    if(!this.foundAttributo1.includes(element.Campaign__r.CRM_Nome_Attributo_1_formula__c)){
                        this.optionsAttributo1.push({
                            label : element.Campaign__r.CRM_Nome_Attributo_1_formula__c,
                            value: element.Campaign__r.CRM_Nome_Attributo_1_formula__c
                        })
                        this.foundAttributo1.push(element.Campaign__r.CRM_Nome_Attributo_1_formula__c);
                        this.typeMap[element.Campaign__r.CRM_Nome_Attributo_1_formula__c] = element.type1;
                        let eventObj = {};
                        eventObj.target = {};
                        eventObj.target.name = 'selectedNomeAttributo1';
                        eventObj.target.value = element.Campaign__r.CRM_Nome_Attributo_1_formula__c;
                        this.handleFilter(eventObj);
                    }
                    if(!this.foundAttributo2.includes(element.Campaign__r.CRM_Nome_Attributo_2_formula__c)){
                        this.optionsAttributo2.push({
                            label : element.Campaign__r.CRM_Nome_Attributo_2_formula__c,
                            value: element.Campaign__r.CRM_Nome_Attributo_2_formula__c
                        })
                        this.foundAttributo2.push(element.Campaign__r.CRM_Nome_Attributo_2_formula__c);
                        this.typeMap[element.Campaign__r.CRM_Nome_Attributo_2_formula__c] = element.type2;
                        let eventObj = {};
                        eventObj.target = {};
                        eventObj.target.name = 'selectedNomeAttributo2';
                        eventObj.target.value = element.Campaign__r.CRM_Nome_Attributo_2_formula__c;
                        this.handleFilter(eventObj);
                    }

                    if(this.campaignCondition) {
                        element.Data_Uscita = element.Data_Uscita__c;       
                    }                 
                    //

                });
                this.data = result.campaignMemberList;
                this.filteredData = this.data;
                if(this.campaignCondition) {
                    this.columns = [
                        { label: '', fieldName: '', type: 'text', cellAttributes: { iconName: { fieldName: 'newIcon' }} ,hideDefaultActions: true, fixedWidth: 50},
                        { label: 'NDG', fieldName: 'CRM_UrlNDG', type: 'url', cellAttributes:{ iconName: { fieldName: 'provenanceIconName' } },
                            typeAttributes: {
                                label: { fieldName: 'CRM_NDG' }
                            },
                            hideDefaultActions: "true", sortable: "true"},
                        { label: 'Nome Account', fieldName: 'CRM_AccountName', type: 'text', sortable: "true", hideDefaultActions: true,},
                        { label: 'MDS', fieldName: 'PTF_ModelloDiServizio__c', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Assegnatario', fieldName: 'CRM_Assegnatario', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Filiale', fieldName: 'PTF_Filiale', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Nome Portafoglio', fieldName: 'PTF_Portafoglio', type: 'text', sortable: "true",hideDefaultActions: true,},                    
                        { label: 'Referente', fieldName: 'PTF_Referente', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Esito', fieldName: 'CRM_Esito__c', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Autore', fieldName: 'CRM_Autore__c', type: 'text', sortable: "true", hideDefaultActions: true},
                        // MS - Cambiato in Data_ingresso__c
                        
                        { label: 'Data Ingresso', fieldName: 'Data_ingresso__c', type: 'date', sortable: "true"},
                        { label: 'Data Uscita', fieldName: 'Data_Uscita__c', type: 'date', sortable: "true", hideDefaultActions: true},
                        { label: nomeAttributo1, fieldName: 'CRM_ValoreAttributo1', type: this.type1, sortable: "true", cellAttributes: { alignment: 'left' }},
                        { label: nomeAttributo2, fieldName: 'CRM_ValoreAttributo2', type: this.type2, sortable: "true", cellAttributes: { alignment: 'left' }},    
                        //{ label: 'ID_P2', fieldName: 'ID_P2', type: 'number', sortable: "true"}, 
                        //{ label: 'ID_P3', fieldName: 'ID_P3', type: 'number', sortable: "true"},                 
                    ];
                }else{
                    this.columns = [
                        { label: '', fieldName: '', type: 'text', cellAttributes: { iconName: { fieldName: 'newIcon' }} ,hideDefaultActions: true, fixedWidth: 50},
                        { label: 'NDG', fieldName: 'CRM_UrlNDG', type: 'url', cellAttributes:{ iconName: { fieldName: 'provenanceIconName' } },
                            typeAttributes: {
                                label: { fieldName: 'CRM_NDG' }
                            },
                            hideDefaultActions: "true", sortable: "true"},
                        { label: 'Nome Account', fieldName: 'CRM_AccountName', type: 'text', sortable: "true", hideDefaultActions: true,},
                        { label: 'MDS', fieldName: 'PTF_ModelloDiServizio__c', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Assegnatario', fieldName: 'CRM_Assegnatario', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Filiale', fieldName: 'PTF_Filiale', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Nome Portafoglio', fieldName: 'PTF_Portafoglio', type: 'text', sortable: "true",hideDefaultActions: true,},                    
                        { label: 'Referente', fieldName: 'PTF_Referente', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Esito', fieldName: 'CRM_Esito__c', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Autore', fieldName: 'CRM_Autore__c', type: 'text', sortable: "true", hideDefaultActions: true},
                        // MS - Cambiato in Data_ingresso__c
                        
                        { label: 'Data Ingresso', fieldName: 'Data_ingresso__c', type: 'date', sortable: "true"},
                        { label: nomeAttributo1, fieldName: 'CRM_ValoreAttributo1', type: this.type1, sortable: "true", cellAttributes: { alignment: 'left' }},
                        { label: nomeAttributo2, fieldName: 'CRM_ValoreAttributo2', type: this.type2, sortable: "true", cellAttributes: { alignment: 'left' }},    
                        //{ label: 'ID_P2', fieldName: 'ID_P2', type: 'number', sortable: "true"}, 
                        //{ label: 'ID_P3', fieldName: 'ID_P3', type: 'number', sortable: "true"},                 
                    ];
                }
                //console.log('nomeAttributo2 ' + nomeAttributo2);
               
                this.filteredData.sort( this.sortBy( sortedBy, sortDirection === 'asc' ? 1 : -1 ) );
                this.numMembers = this.filteredData.length;
                this.showFiltroAttributo1 = Boolean(nomeAttributo1);
                this.showFiltroAttributo2 = Boolean(nomeAttributo2);
                this.setPages(this.filteredData);
                this.showFilter = true;
                this.loaded = true;
            }})
                .catch(error => {
                    // this.error = error;
                    console.log('ERROR', error);
                })
                .finally(() => {
                    console.log('FS End FinalyAll');
                });
            }else{
                getCampaignMember({recordId:this.recordId})
                .then(result => {
                console.log('PZ init result: ', result);
                if (result.errorMessage){
                    const event = new ShowToastEvent({
                    });
                    this.dispatchEvent(event);
                    this.loaded = true;
                    this.showErrorMassage = true;
                }else{
                let nomeAttributo1 = '';
                let nomeAttributo2 = '';
                let sortedBy = '';
                let sortDirection = '';
                console.log('FS getData related to campaign', this.recordId);
                console.log('FS getData result', result);
                let firstEl = result.campaignMemberList[0];
                let campaignEl = firstEl.Campaign__r;
                let tipologia = campaignEl.Tipologia_Azione__c;
                let devNameRT = campaignEl.RecordType.DeveloperName;
                this.campaignCondition = tipologia == 'Dinamica' || devNameRT == 'Trigger_Monostep';

                result.campaignMemberList.forEach(element =>{
                    element.PTF_CampaignName = element.Campaign__r.Name;
                    element.PTF_UrlCampaign = '/' + element.Campaign__c;
                    element.CRM_NDG = element.CRM_Account__r.CRM_NDG__c;
                    element.CRM_UrlNDG = '/' + element.CRM_Account__c;
                    element.CRM_AccountName = element.CRM_Account__r.Name;
                    element.CRM_Assegnatario = element.CRM_AssegnatarioFormula__c ? element.CRM_AssegnatarioFormula__c : '';
                    element.PTF_Filiale = element.CRM_Account__r.PTF_Filiale__r ? element.CRM_Account__r.PTF_Filiale__r.Name : (element.CRM_Account__r.CRM_Filiale__r ? element.CRM_Account__r.CRM_Filiale__r.Name : '');
                    element.PTF_Portafoglio = element.PTF_Portafoglio__r ? element.PTF_Portafoglio__r.Name : '';
                    element.PTF_Referente = (element.PTF_Portafoglio__r && element.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r)  ? element.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName +' ' +element.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName : '';
                    element.CRM_Autor = element.CRM_Autore__c; 
                    element.PTF_UrlPortafoglio = element.PTF_Portafoglio__r ? '/' + element.PTF_Portafoglio__c : '';
                    element.CRM_NomeAttributo1 = element.Campaign__r.CRM_Nome_Attributo_1_formula__c;
                    element.CRM_NomeAttributo2 = element.Campaign__r.CRM_Nome_Attributo_2_formula__c;
                    // MS - Cambiato in Data_ingresso__c
                    element.Data_ingresso__c  = element.Data_ingresso__c;
                    element.ID_P2 = element.Priorita_Campaign_Member__c;
                    element.ID_P3 = element.ID_P3__c;
                    
                    if(element.CRM_CheckNewInsert__c)
                        element.newIcon= 'standard:work_queue';
                    
                    if(element.checkNewExit__c)
                        element.newIcon= 'standard:return_order_line_item';
                    
                    if(!nomeAttributo1 && !nomeAttributo2){
                        nomeAttributo1 = element.Campaign__r.CRM_Nome_Attributo_1_formula__c;
                        nomeAttributo2 = element.Campaign__r.CRM_Nome_Attributo_2_formula__c;
                    }
                    
                    if(!element.Campaign__r.CRM_Ordinamento_Attributo__c || !element.Campaign__r.Ordinamento__c &&
                        (!sortedBy && !sortDirection)){
                        
                        sortedBy = element.Campaign__r.CRM_Ordinamento_Attributo__c == 'Attributo 1' ? 'CRM_ValoreAttributo1' : 'CRM_ValoreAttributo2';
                        sortDirection = element.Campaign__r.Ordinamento__c == 'Crescente' ? 'asc' : 'desc';
                    }

                    if(Boolean(element.CRM_ValoreAttributo1_Date__c)){
                        element.CRM_ValoreAttributo1 = element.CRM_ValoreAttributo1_Date__c;
                        if(!this.type1)this.type1 = 'date'
                        element.type1 = 'date';
                    }else if(Boolean(element.CRM_ValoreAttributo1_Number__c)){
                        element.CRM_ValoreAttributo1 = element.CRM_ValoreAttributo1_Number__c;
                        if(!this.type1)this.type1 = 'number'
                        element.type1 = 'number';
                    }else{
                        element.CRM_ValoreAttributo1 = element.CRM_ValoreAttributo1_Text__c;
                        if(!this.type1)this.type1 = 'text'
                        element.type1 = 'text';
                    }

                    if(Boolean(element.CRM_ValoreAttributo2_Date__c)){
                        element.CRM_ValoreAttributo2 = element.CRM_ValoreAttributo2_Date__c;
                        if(!this.type2)this.type2 = 'date'
                        element.type2 = 'date';
                    }else if(Boolean(element.CRM_ValoreAttributo2_Number__c)){
                        element.CRM_ValoreAttributo2 = element.CRM_ValoreAttributo2_Number__c;
                        if(!this.type2)this.type2 = 'number'
                        element.type2 = 'number';
                    }else{
                        element.CRM_ValoreAttributo2 = element.CRM_ValoreAttributo2_Text__c;
                        if(!this.type2)this.type2 = 'text'
                        element.type2 = 'text';
                    }

                    if(!this.foundAttributo1.includes(element.Campaign__r.CRM_Nome_Attributo_1_formula__c)){
                        this.optionsAttributo1.push({
                            label : element.Campaign__r.CRM_Nome_Attributo_1_formula__c,
                            value: element.Campaign__r.CRM_Nome_Attributo_1_formula__c
                        })
                        this.foundAttributo1.push(element.Campaign__r.CRM_Nome_Attributo_1_formula__c);
                        this.typeMap[element.Campaign__r.CRM_Nome_Attributo_1_formula__c] = element.type1;
                        let eventObj = {};
                        eventObj.target = {};
                        eventObj.target.name = 'selectedNomeAttributo1';
                        eventObj.target.value = element.Campaign__r.CRM_Nome_Attributo_1_formula__c;
                        this.handleFilter(eventObj);
                    }
                    if(!this.foundAttributo2.includes(element.Campaign__r.CRM_Nome_Attributo_2_formula__c)){
                        this.optionsAttributo2.push({
                            label : element.Campaign__r.CRM_Nome_Attributo_2_formula__c,
                            value: element.Campaign__r.CRM_Nome_Attributo_2_formula__c
                        })
                        this.foundAttributo2.push(element.Campaign__r.CRM_Nome_Attributo_2_formula__c);
                        this.typeMap[element.Campaign__r.CRM_Nome_Attributo_2_formula__c] = element.type2;
                        let eventObj = {};
                        eventObj.target = {};
                        eventObj.target.name = 'selectedNomeAttributo2';
                        eventObj.target.value = element.Campaign__r.CRM_Nome_Attributo_2_formula__c;
                        this.handleFilter(eventObj);
                    }

                    if(this.campaignCondition) {
                        element.Data_Uscita = element.Data_Uscita__c;       
                    }                 
                    //

                });
                this.data = result.campaignMemberList;
                this.filteredData = this.data;
                if(this.campaignCondition) {
                    this.columns = [
                        { label: '', fieldName: '', type: 'text', cellAttributes: { iconName: { fieldName: 'newIcon' }} ,hideDefaultActions: true, fixedWidth: 50},
                        { label: 'NDG', fieldName: 'CRM_UrlNDG', type: 'url', cellAttributes:{ iconName: { fieldName: 'provenanceIconName' } },
                            typeAttributes: {
                                label: { fieldName: 'CRM_NDG' }
                            },
                            hideDefaultActions: "true", sortable: "true"},
                        { label: 'Nome Account', fieldName: 'CRM_AccountName', type: 'text', sortable: "true", hideDefaultActions: true,},
                        { label: 'MDS', fieldName: 'PTF_ModelloDiServizio__c', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Assegnatario', fieldName: 'CRM_Assegnatario', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Filiale', fieldName: 'PTF_Filiale', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Nome Portafoglio', fieldName: 'PTF_Portafoglio', type: 'text', sortable: "true",hideDefaultActions: true,},                    
                        { label: 'Referente', fieldName: 'PTF_Referente', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Esito', fieldName: 'CRM_Esito__c', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Autore', fieldName: 'CRM_Autore__c', type: 'text', sortable: "true", hideDefaultActions: true},
                        // MS - Cambiato in Data_ingresso__c
                        
                        { label: 'Data Ingresso', fieldName: 'Data_ingresso__c', type: 'date', sortable: "true"},
                        { label: 'Data Uscita', fieldName: 'Data_Uscita__c', type: 'date', sortable: "true", hideDefaultActions: true},
                        { label: nomeAttributo1, fieldName: 'CRM_ValoreAttributo1', type: this.type1, sortable: "true", cellAttributes: { alignment: 'left' }},
                        { label: nomeAttributo2, fieldName: 'CRM_ValoreAttributo2', type: this.type2, sortable: "true", cellAttributes: { alignment: 'left' }},    
                        //{ label: 'ID_P2', fieldName: 'ID_P2', type: 'number', sortable: "true"}, 
                        //{ label: 'ID_P3', fieldName: 'ID_P3', type: 'number', sortable: "true"},                 
                    ];
                }else{
                    this.columns = [
                        { label: '', fieldName: '', type: 'text', cellAttributes: { iconName: { fieldName: 'newIcon' }} ,hideDefaultActions: true, fixedWidth: 50},
                        { label: 'NDG', fieldName: 'CRM_UrlNDG', type: 'url', cellAttributes:{ iconName: { fieldName: 'provenanceIconName' } },
                            typeAttributes: {
                                label: { fieldName: 'CRM_NDG' }
                            },
                            hideDefaultActions: "true", sortable: "true"},
                        { label: 'Nome Account', fieldName: 'CRM_AccountName', type: 'text', sortable: "true", hideDefaultActions: true,},
                        { label: 'MDS', fieldName: 'PTF_ModelloDiServizio__c', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Assegnatario', fieldName: 'CRM_Assegnatario', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Filiale', fieldName: 'PTF_Filiale', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Nome Portafoglio', fieldName: 'PTF_Portafoglio', type: 'text', sortable: "true",hideDefaultActions: true,},                    
                        { label: 'Referente', fieldName: 'PTF_Referente', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Esito', fieldName: 'CRM_Esito__c', type: 'text', sortable: "true",hideDefaultActions: true,},
                        { label: 'Autore', fieldName: 'CRM_Autore__c', type: 'text', sortable: "true", hideDefaultActions: true},
                        // MS - Cambiato in Data_ingresso__c
                        
                        { label: 'Data Ingresso', fieldName: 'Data_ingresso__c', type: 'date', sortable: "true"},
                        { label: nomeAttributo1, fieldName: 'CRM_ValoreAttributo1', type: this.type1, sortable: "true", cellAttributes: { alignment: 'left' }},
                        { label: nomeAttributo2, fieldName: 'CRM_ValoreAttributo2', type: this.type2, sortable: "true", cellAttributes: { alignment: 'left' }},    
                        //{ label: 'ID_P2', fieldName: 'ID_P2', type: 'number', sortable: "true"}, 
                        //{ label: 'ID_P3', fieldName: 'ID_P3', type: 'number', sortable: "true"},                 
                    ];
                }
                //console.log('nomeAttributo2 ' + nomeAttributo2);
               
                this.filteredData.sort( this.sortBy( sortedBy, sortDirection === 'asc' ? 1 : -1 ) );
                this.numMembers = this.filteredData.length;
                this.showFiltroAttributo1 = Boolean(nomeAttributo1);
                this.showFiltroAttributo2 = Boolean(nomeAttributo2);
                this.setPages(this.filteredData);
                this.showFilter = true;
                this.loaded = true;
            }})
            .catch(error => {
                // this.error = error;
                console.log('ERROR', error);
            })
            .finally(() => {
                console.log('FS End Finaly');
            });
            }
            }).catch(error => {
                // this.error = error;
                console.log('ERROR', error);
                this.loaded = true;
            })
            .finally(() => {

                console.log('FS End FinalyUser');
            })
            console.log('this.currentUserRuoloLdap: '+this.currentUserRuoloLdap);
 
            
            
        } catch (error) {
            
            console.log('ERROR', error);
        }
    }

    onHandleSort( event ) {

        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.filteredData];
        cloneData.sort( this.sortBy( sortedBy, sortDirection === 'asc' ? 1 : -1 ) );
        // this.data = cloneData;
        this.filteredData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        this.setPages(this.filteredData);
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
    @track searchedEsito;
    @track selectedNomeAttributo1;
    @track selectedValoreAttributo1Start;
    @track selectedValoreAttributo1End;
    @track selectedNomeAttributo2;
    @track selectedValoreAttributo2Start;
    @track selectedValoreAttributo2End;
    @track searchedValoreAttributo1;
    @track searchedValoreAttributo2;
    @track searchedRef;
    @track searchedNDG;
    @track searchedUnitaorg;
    @track searchedAssegnatario;
    @track searchedMMDS;
    @track searchedAuthor; 
    @track seachedDataUscita; 
    @track searchedDataInserimento;
    @track selectedValoreID_P2Start;
    @track selectedValoreID_P2End;

    handleFilter(event){

        console.log('DK handleFilter Started');
        if(event.target.name == 'selectedNomeAttributo1'){
            
            this.selectedNomeAttributo1 = event.target.value;
            if(this.typeMap[this.selectedNomeAttributo1] == 'number'){
                this.showRangeNum1 = true;
                this.showRangeDate1 = false;
                this.showSearchtext1 = false;
            }else if(this.typeMap[this.selectedNomeAttributo1] == 'date'){
                this.showRangeNum1 = false;
                this.showRangeDate1 = true;
                this.showSearchtext1 = false;
            }else if(this.typeMap[this.selectedNomeAttributo1] == 'text'){
                this.showRangeNum1 = false;
                this.showRangeDate1 = false;
                this.showSearchtext1 = true;
            }else{
                this.showRangeNum1 = false;
                this.showRangeDate1 = false;
                this.showSearchtext1 = false;
            }
        }else if(event.target.name == 'selectedValoreAttributo1Start'){
            
            this.selectedValoreAttributo1Start = event.target.value;
        }else if(event.target.name == 'selectedValoreAttributo1End'){
            
            this.selectedValoreAttributo1End = event.target.value;
        }else if(event.target.name == 'selectedNomeAttributo2'){
            
            this.selectedNomeAttributo2 = event.target.value;
            if(this.typeMap[this.selectedNomeAttributo2] == 'number'){
                this.showRangeNum2 = true;
                this.showRangeDate2 = false;
                this.showSearchtext2 = false;
            }else if(this.typeMap[this.selectedNomeAttributo2] == 'date'){
                this.showRangeNum2 = false;
                this.showRangeDate2 = true;
                this.showSearchtext2 = false;
            }else if(this.typeMap[this.selectedNomeAttributo2] == 'text'){
                this.showRangeNum2 = false;
                this.showRangeDate2 = false;
                this.showSearchtext2 = true;
            }else{
                this.showRangeNum2 = false;
                this.showRangeDate2 = false;
                this.showSearchtext2 = false;
            }
        }else if(event.target.name == 'selectedValoreAttributo2Start'){
            
            this.selectedValoreAttributo2Start = event.target.value;
        }else if(event.target.name == 'selectedValoreAttributo2End'){
            
            this.selectedValoreAttributo2End = event.target.value;
        }else if(event.target.name == 'searchedValoreAttributo1'){

            this.searchedValoreAttributo1 = event.target.value;
        }else if(event.target.name == 'searchedValoreAttributo2'){

            this.searchedValoreAttributo2 = event.target.value;
        }else if(event.target.name == 'selectedValoreID_P2Start'){
            
            this.selectedValoreID_P2Start = event.target.value;
            console.log('searchedMMDS: '+this.selectedValoreID_P2Start);
        }else if(event.target.name == 'selectedValoreID_P2End'){
            
            this.selectedValoreID_P2End = event.target.value;
            console.log('searchedMMDS: '+this.selectedValoreID_P2End);
        }else if(event.target.name == 'searchedEsito'){
            
            this.searchedEsito = event.target.value;
        }else if(event.target.name == 'searchedNDG'){
            
            this.searchedNDG = event.target.value;
        }else if(event.target.name == 'searchedRef'){
            
            this.searchedRef = event.target.value;
            console.log('searchedRef: '+this.searchedRef);
        }else if(event.target.name == 'searchedUnitaorg'){
            
            this.searchedUnitaorg = event.target.value;
            console.log('searchedUnitaorg: '+this.searchedUnitaorg);
        }
        else if(event.target.name == 'searchedAssegnatario'){
            
            this.searchedAssegnatario = event.target.value;
            console.log('searchedAssegnatario: '+this.searchedAssegnatario);
        }else if(event.target.name == 'searchedMMDS'){
            
            this.searchedMMDS = event.target.value;
            console.log('searchedMMDS: '+this.searchedMMDS);
        } else if(event.target.name == 'searchedAuthor') {
            this.searchedAuthor = event.target.value;
            console.log('searchedAuthor: ' + this.searchedAuthor);
        } else if(event.target.name == 'seachedDataUscita') {
            this.seachedDataUscita = event.target.value;
            console.log('seachedDataUscita: ' + this.seachedDataUscita);
        } else if(event.target.name == 'searchedDataInserimento') {

            this.searchedDataInserimento = event.target.value;
            console.log('searchedDataInserimento: ' + this.searchedDataInserimento);
        }
    }

    handleReset(){
        
        this.searchedEsito = '';
        this.searchedRef = '';
        this.searchedNDG = '';
        this.searchedUnitaorg = '';
        this.searchedAssegnatario = '';
        this.searchedMMDS  = '';
        this.searchedAuthor = '';
        this.seachedDataUscita = '';  
        this.searchedDataInserimento = ''; 
        this.searchedValoreAttributo1 = '';
        this.selectedValoreAttributo1Start = '';
        this.selectedValoreAttributo1End = '';
        this.searchedValoreAttributo2 = '';
        this.selectedValoreAttributo2Start = '';
        this.selectedValoreAttributo2End = '';
        this.selectedValoreID_P2Start = '';
        this.selectedValoreID_P2End = '';
        this.filteredData = this.data;
        this.numMembers = this.filteredData.length;
        this.setPages(this.filteredData);
    }

    handleSearch(){
        this.filteredData = [];
        this.page = 1;
        try {
            for(var i in this.data){
                if(Boolean(this.searchedEsito)){
                    if(!this.data[i].CRM_Esito__c || this.data[i].CRM_Esito__c.toLowerCase() != this.searchedEsito.toLowerCase()){
                        continue;
                    }
                }
                //
                if(Boolean(this.searchedAuthor)){
                    if(!this.data[i].CRM_Autore__c || this.data[i].CRM_Autore__c.toLowerCase() != this.searchedAuthor.toLowerCase()){
                        continue;
                    }
                }
                if(Boolean(this.seachedDataUscita)){
                    if(new Date(this.data[i].Data_Uscita__c) != new Date(this.searchedAuthor.toLowerCase())){
                        continue;
                    }
                }
                if(Boolean(this.searchedDataInserimento)){
                    if(new Date(this.data[i].CreatedDate) != new Date(this.searchedDataInserimento)){
                        continue;
                    }
                }
                //
                if(Boolean(this.searchedMMDS)){
                    if(!this.data[i].PTF_ModelloDiServizio__c || this.data[i].PTF_ModelloDiServizio__c.toLowerCase() != this.searchedMMDS.toLowerCase()){
                        continue;
                    }
                }
                if(Boolean(this.searchedNDG)){
                    if(!this.data[i].CRM_NDG || !this.data[i].CRM_NDG.toLowerCase().includes(this.searchedNDG.toLowerCase())){
                        continue;
                    }
                }
                if(Boolean(this.searchedRef)){
                    if(!this.data[i].PTF_Referente || !this.data[i].PTF_Referente.toLowerCase().includes(this.searchedRef.toLowerCase())){
                        continue;
                    }
                }
                if(Boolean(this.searchedUnitaorg)){
                    if(!this.data[i].PTF_Filiale || !this.data[i].PTF_Filiale.toLowerCase().includes(this.searchedUnitaorg.toLowerCase())){
                        continue;
                    }
                }
                if(Boolean(this.searchedAssegnatario)){
                    if(!this.data[i].CRM_Assegnatario || !this.data[i].CRM_Assegnatario.toLowerCase().includes(this.searchedAssegnatario.toLowerCase())){
                        continue;
                    }
                }
                console.log('Boolean(this.selectedValoreID_P2Start) ' +Boolean(this.selectedValoreID_P2Start) );
                if(Boolean(this.selectedValoreID_P2Start)){
                    console.log('this.selectedValoreID_P2Start ' +this.selectedValoreID_P2Start );
                    console.log('this.data[i].ID_P2 ' +this.data[i].ID_P2 );
                    if(!this.data[i].ID_P2){
                        continue;
                    }
                    if(this.data[i].ID_P2 < this.selectedValoreID_P2Start){
                            continue;
                    }
                }
                console.log('Boolean(this.selectedValoreID_P2End) ' +Boolean(this.selectedValoreID_P2End) );
                if(Boolean(this.selectedValoreID_P2End)){
                    console.log('this.selectedValoreID_P2End ' +this.selectedValoreID_P2End );
                    console.log('this.data[i].ID_P2 ' +this.data[i].ID_P2 );
                    if(!this.data[i].ID_P2){
                        continue;
                    }
                    if(this.data[i].ID_P2 > this.selectedValoreID_P2End){
                            continue;
                    }
                }
                if(Boolean(this.selectedNomeAttributo1)){
                    if(this.data[i].CRM_NomeAttributo1 != this.selectedNomeAttributo1 &&
                        (Boolean(this.selectedValoreAttributo1Start) ||
                        Boolean(this.selectedValoreAttributo1End) ||
                        Boolean(this.searchedValoreAttributo1))){
                        continue;
                    }
                    if(Boolean(this.selectedValoreAttributo1Start)){
                        if(!this.data[i].CRM_ValoreAttributo1){
                            continue;
                        }
                        if(this.typeMap[this.selectedNomeAttributo1] === 'date'){
                            if(new Date(this.data[i].CRM_ValoreAttributo1) < new Date(this.selectedValoreAttributo1Start)){
                                continue;
                            }
                        }else{
                            if(this.data[i].CRM_ValoreAttributo1 < this.selectedValoreAttributo1Start){
                                continue;
                            }
                        }
                    }
                    if(Boolean(this.selectedValoreAttributo1End)){
                        if(!this.data[i].CRM_ValoreAttributo1){
                            continue;
                        }
                        if(this.typeMap[this.selectedNomeAttributo1] === 'date'){
                            if(new Date(this.data[i].CRM_ValoreAttributo1) > new Date(this.selectedValoreAttributo1End)){
                                continue;
                            }
                        }else{
    
                            if(this.data[i].CRM_ValoreAttributo1 > this.selectedValoreAttributo1End){
                                continue;
                            }
                        }
                    }
                    if(Boolean(this.searchedValoreAttributo1)){
                        if(!this.data[i].CRM_ValoreAttributo1){
                            continue;
                        }
                        if(!this.data[i].CRM_ValoreAttributo1.toLowerCase().includes(this.searchedValoreAttributo1.toLowerCase())){
                            continue;
                        }
                    }
                }

                if(Boolean(this.selectedNomeAttributo2)){
                    if(this.data[i].CRM_NomeAttributo2 != this.selectedNomeAttributo2 &&
                        (Boolean(this.selectedValoreAttributo2Start) ||
                        Boolean(this.selectedValoreAttributo2End) ||
                        Boolean(this.searchedValoreAttributo2))){
                        continue;
                    }
                    if(Boolean(this.selectedValoreAttributo2Start)){
                        if(!this.data[i].CRM_ValoreAttributo2){
                            continue;
                        }
                        if(this.typeMap[this.selectedNomeAttributo2] === 'date'){
                            if(new Date(this.data[i].CRM_ValoreAttributo2) < new Date(this.selectedValoreAttributo2Start)){
                                continue;
                            }
                        }else{
                            if(this.data[i].CRM_ValoreAttributo2 < this.selectedValoreAttributo2Start){
                                continue;
                            }
                        }
                    }
                    if(Boolean(this.selectedValoreAttributo2End)){
                        if(!this.data[i].CRM_ValoreAttributo2){
                            continue;
                        }
                        if(this.typeMap[this.selectedNomeAttributo2] === 'date'){
                            if(new Date(this.data[i].CRM_ValoreAttributo2) > new Date(this.selectedValoreAttributo2End)){
                                continue;
                            }
                        }else{
    
                            if(this.data[i].CRM_ValoreAttributo2 > this.selectedValoreAttributo2End){
                                continue;
                            }
                        }
                    }
                    if(Boolean(this.searchedValoreAttributo2)){
                        if(!this.data[i].CRM_ValoreAttributo2){
                            continue;
                        }
                        if(!this.data[i].CRM_ValoreAttributo2.toLowerCase().includes(this.searchedValoreAttributo2.toLowerCase())){
                            continue;
                        }
                    }

                    
                }


                this.filteredData.push(this.data[i]);
            }
            console.log('DK filteredData: ' + JSON.stringify(this.filteredData));
            console.log('DK this.page: ' + this.page);
            this.numMembers = this.filteredData.length;
            this.setPages(this.filteredData);
        } catch (error) {
            
            console.log('DK error: ' + error);
        }
    }

    //Pagination
    @track page = 1;
    perpage = 15;
    @track pages = [];
    set_size = 15;
    handleAvanti(){
        try {
            ++this.page;
        } catch (error) {
            console.log('error: ', error);
        }
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
        let perpage = this.defaultLimit;
        let startIndex = (page*perpage) - perpage;
        let endIndex = (page*perpage);
        let recordToDisplay = this.filteredData.slice(startIndex,endIndex);
        //let recordToDisplayIdList = recordToDisplay.map(item => item.Id);

        

        return recordToDisplay;
    }

    setPages = (data)=>{
        this.pages = [];
        let numberOfPages = Math.ceil(data.length / this.defaultLimit);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
        console.log('DK this.pages: ' + this.pages);
    }  
    
    get disabledButtonIndietro(){
        return this.page === 1;
    }
    
    get disabledButtonAvanti(){
        return this.page === this.pages.length || this.filteredData.length === 0
    }

    get currentPageData(){
        return this.pageData();
    }

    get optionsEsito() {
        return [
            { label: '---None---', value: '' },
            { label: 'Da contattare', value: 'Da contattare' },
            { label: 'Non contattabile', value: 'Non contattabile' },
            { label: 'Cliente non adatto', value: 'Cliente non adatto' },
            { label: 'Cliente interessato', value: 'Cliente interessato' },
            { label: 'Prodotto target venduto', value: 'Prodotto target venduto' },
            { label: 'Prodotto venduto', value: 'Prodotto venduto' },
            { label: 'Da ricontattare', value: 'Da ricontattare' },
            { label: 'Fissato appuntamento', value: 'Fissato appuntamento' },
            { label: 'Altro prodotto venduto', value: 'Altro prodotto venduto' },
            { label: 'Ingaggio agente', value: 'Ingaggio agente' },
            { label: 'Cliente non contattabile', value: 'Cliente non contattabile' },
            { label: 'Cliente non interessato', value: 'Cliente non interessato' },    
            { label: 'Cliente soddisfatto', value: 'Cliente soddisfatto' },
            { label: 'Risultato non raggiunto', value: 'Risultato non raggiunto' },   
            { label: 'Risultato raggiunto', value: 'Risultato raggiunto' },   
            { label: 'Risultato raggiunto in parte', value: 'Risultato raggiunto in parte' }               
        ];
    }

    get optionsMMDS() {
        return [
            { label: '---None---', value: '' },
            { label: 'Assente', value: 'Assente' },
            { label: 'Small Business', value: 'SMALL BUSINESS' },
            { label: 'Consulenti Finanziari', value: 'Consulenti Finanziari' },
            { label: 'Controparti Istituzionali', value: 'Controparti Istituzionali' },
            // { label: 'Corporate', value: 'Corporate' },
            { label: 'Corporate', value: 'CORPORATE' },
            { label: 'Enti e Tesorerie', value: 'Enti e Tesorerie' },
            { label: 'Family', value: 'Family' },
            { label: 'Large Corporate', value: 'LARGE CORPORATE' },
            { label: 'Key Client Privati', value: 'Key Client Privati' },
            { label: 'Non Portafogliati', value: 'Non Portafogliati' },
            { label: 'POE', value: 'POE' },
            { label: 'Private', value: 'Private' },
            { label: 'Personal', value: 'Personal' },      
            { label: 'Residuale', value: 'Residuale' },               
        ];
    }
}