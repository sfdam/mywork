import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import getCampaignMember from '@salesforce/apex/CRM_AffinamentoCampagne.getCampaignMember';
import setCampaignMember from '@salesforce/apex/CRM_AffinamentoCampagne.setCampaignMember';
import getUserInfo from '@salesforce/apex/CRM_AffinamentoCampagne.getUserInfo';

export default class Crm_affinamentoCampagne extends NavigationMixin(LightningElement){
    @api recordId;
    @track data = [];
    @track filteredData = [];
    @track columns = [];
    @track type1;
    @track type2;
    @track campMembColumns;
    @api selectedCMRow = [];
    @api selectedCMRowIds = [];
    @api contactElegibleRoleMDS;
    @api idReferentiCMAssegnate = [];
    @track filteredData = [];
    @track noteAffinamentoVal;
    @api isLoaded = false;
    @track typeMap = {};

    @track optionsAttributo1 = [];
    @track foundAttributo1 = [];
    @track optionsAttributo2 = [];
    @track foundAttributo2 = [];

    @track showRangeNum1 = false; 
    @track showRangeDate1 = false;
    @track showSearchtext1 = false;

    @track showRangeNum2 = false; 
    @track showRangeDate2 = false;
    @track showSearchtext2 = false;

    @track showFiltroAttributo1 = false;
    @track showFiltroAttributo2 = false;

    @track loaded = false;
    @track clientiInAffinati =0;
    @track clientiInCampagna;
    @track percAffinamento;
    @track disableAffinamento = false;
    @track numMembers;
    @track isUserDisabled = true;
    @api profiliAutorizzati;
    @track maxAff = 0;
    @track clientiDaAff = 0;


    connectedCallback(){
        if(!Boolean(this.defaultLimit)){

            this.defaultLimit = this.perpage;
        }

        try {
            getUserInfo()
            .then(result => {
            console.log( 'UserProfile: '+result.Profile.Name );
            console.log( 'this.profiliAutorizzati: '+this.profiliAutorizzati );
            if(this.profiliAutorizzati && this.profiliAutorizzati.includes(result.Profile.Name)){
                this.isUserDisabled = false;
                
            } else {
                this.isUserDisabled = true;
                
            }
            console.log( 'this.isUserEnabled: '+this.isUserEnabled );
            }).catch(error => {
                // this.error = error;
                console.log('ERROR', error);
                this.loaded = true;
            })
            .finally(() => {

                console.log('FS End Finaly');
            })
            getCampaignMember({recordId:this.recordId})
            .then(result => {
                console.log('FS getData related to campaign', this.recordId);
                console.log('FS getData result', result);
                let nomeAttributo1;
                let nomeAttributo2;
                let sortedBy = '';
                let sortDirection = '';
                result.campaignMemberList.forEach(element =>{
                    element.PTF_CampaignName = element.Campaign__r.Name;
                    element.PTF_UrlCampaign = '/' + element.Campaign__c;
                    element.CRM_NDG = element.CRM_Account__r.CRM_NDG__c;
                    element.PTF_AccountUrl = '/' + element.CRM_Account__c;
                    element.CRM_AccountName = element.CRM_Account__r.Name;
                    element.PTF_Filiale = element.CRM_Account__r.PTF_Filiale__r ? element.CRM_Account__r.PTF_Filiale__r.Name : '';
                    element.PTF_Portafoglio = element.PTF_Portafoglio__r ? element.PTF_Portafoglio__r.Name : '';
                    element.PTF_Referente = (element.PTF_Portafoglio__r && element.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r)  ? element.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName +' ' +element.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName : '';
                    element.PTF_UrlPortafoglio = element.PTF_Portafoglio__r ? '/' + element.PTF_Portafoglio__c : '';
                    element.PTF_NaturaGiuridica = element.CRM_Account__r.PTF_NaturaGiuridica__c;
                    element.CRM_StatoAssegnazione = (element.CRM_AssegnatarioUser__c!=null ? 'Assegnato' : 'Da assegnare');
                    element.CRM_ReferenteName = (element.CRM_AssegnatarioUser__c!=null ? element.CRM_AssegnatarioUser__r.Name : '');
                    element.CRM_NomeAttributo1 = element.Campaign__r.CRM_Nome_Attributo_1_formula__c;
                    element.CRM_NomeAttributo2 = element.Campaign__r.CRM_Nome_Attributo_2_formula__c;
                   
                    
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

                    if(!Boolean(nomeAttributo1) && !Boolean(nomeAttributo2)){
                        nomeAttributo1 = element.Campaign__r.CRM_Nome_Attributo_1_formula__c;
                        nomeAttributo2 = element.Campaign__r.CRM_Nome_Attributo_2_formula__c;
                        console.log('DK nomeAttributo1: ' , nomeAttributo1);
                        console.log('DK nomeAttributo2: ' , nomeAttributo2);
                        console.log('DK this.foundAttributo1: ' , !this.foundAttributo1.includes(nomeAttributo1));
                        console.log('DK this.foundAttributo2: ' , !this.foundAttributo2.includes(nomeAttributo2));

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
                    }
                    this.clientiInAffinati = result.clientiAffinati;
                   
                    this.percAffinamento = element.Campaign__r.CRM_AffinamentoPerc__c;
                    
                });
                this.data = result.campaignMemberList;
                this.campMembColumns = [
                    { label: 'NDG', fieldName: 'PTF_AccountUrl', type: 'url', typeAttributes: {label: { fieldName: 'CRM_NDG' }}, sortable: "true" },
                    { label: 'Account Name', fieldName: 'CRM_AccountName',hideDefaultActions: true, wrapText: true,target: '_self', sortable: "true" },
                    { label: 'Natura Giuridica', fieldName: 'PTF_NaturaGiuridica', hideDefaultActions: true, wrapText: true, sortable: "true" },
                    { label: 'MDS', fieldName: 'PTF_ModelloDiServizio__c', hideDefaultActions: true, wrapText: true , sortable: "true"},
                    
                    { label: 'Portafoglio', fieldName: 'PTF_Portafoglio', type: 'text', sortable: "true"},
                    { label: 'Referente', fieldName: 'PTF_Referente', type: 'text', sortable: "true"},
                    /*{ label: 'Priorità Contatto', fieldName: 'CRM_PrioritaContatto__c', hideDefaultActions: true, wrapText: true },*/
                    { label: 'Stato Assegnazione', fieldName: 'CRM_StatoAssegnazione', hideDefaultActions: true, wrapText: true, sortable: "true" },
                    { label: 'Referente Assegnatario', fieldName: 'CRM_ReferenteName', hideDefaultActions: true, wrapText: true, sortable: "true" },
                    { label: 'Esito Contatto', fieldName: 'CRM_Esito__c', hideDefaultActions: true, wrapText: true, sortable: "true" },
                    { label: nomeAttributo1, fieldName: 'CRM_ValoreAttributo1', type: this.type1, sortable: "true", cellAttributes: { alignment: 'left' }},
                    { label: nomeAttributo2, fieldName: 'CRM_ValoreAttributo2', type: this.type2, sortable: "true", cellAttributes: { alignment: 'left' }}
                ];
                this.showFiltroAttributo1 = Boolean(nomeAttributo1);
                this.showFiltroAttributo2 = Boolean(nomeAttributo2);
                this.filteredData = this.data;
                this.filteredData.sort( this.sortBy( sortedBy, sortDirection === 'asc' ? 1 : -1 ) );
                this.clientiInCampagna = this.filteredData.length;
                this.numMembers = this.filteredData.length;
                console.log('numElement: '+this.clientiInCampagna);
                this.maxAff = Math.ceil((this.percAffinamento/100)*(this.clientiInCampagna + this.clientiInAffinati));
                this.clientiDaAff = this.maxAff - this.clientiInAffinati;
                this.setPages(this.filteredData);
                this.loaded = true;
            })
            .catch(error => {
                // this.error = error;
                console.log('ERROR', error);
                this.loaded = true;
            })
            .finally(() => {

                console.log('FS this.clientiInAffinati: '+this.clientiInAffinati);
                console.log('FS this.clientiInCampagna: '+this.clientiInCampagna);
                console.log('FS Start Finaly');
                console.log('FS End Finaly');
            });
        } catch (error) {
            
            console.log('ERROR', error);
            this.loaded = true;
        }
    }

    @track handleAffinaClicked = false;       
    @track maxNumClientAff=0;
    @track selectedNdg = false;
    @track checkError = false;
    @track messageError ='';
    handleAffinaReferenteRequestCM(event){
        // this.loaded = false;
        let campaignMembersTable = this.template.querySelector("[data-item='campaignMembersTable']");
        //let selectedCM = campaignMembersTable.getSelectedRows().length;
        /*
        console.log('selectedItem: '+selectedCM);

        console.log('selectedCM: '+selectedCM);*/
        console.log('this.clientiInAffinati: '+this.clientiInAffinati);
        console.log('this.clientiInCampagna: '+this.clientiInCampagna);
        console.log('this.percAffinamento: '+this.percAffinamento);
        
        let selectedMembersRows = [];
        // aggiungo alla lista degli elementi selzionati le righe nelle pagina corrente
        if(campaignMembersTable){
            selectedMembersRows = campaignMembersTable.getSelectedRows();
        }
        // aggiungo alla lista degli elementi selzionati le righe nelle altre pagine
        for(let currentPage of Object.keys(this.selectRowsMapValues)){
            console.log('DK currentPage: ', currentPage);
            console.log('DK this.page: ', this.page);
            if(currentPage != this.page){
                this.selectRowsMapValues[currentPage].forEach(element =>{

                    selectedMembersRows.push(element);
                });
            }
        }

        this.selectedCMRow = JSON.parse(JSON.stringify(selectedMembersRows));
        console.log('FS LIST: ', selectedMembersRows);
        console.log('FS LIST size: ', selectedMembersRows.length);
        let selectedCM = selectedMembersRows.length;
        console.log('selectedCM: '+selectedCM);
        let listCampaignMemberIds = [];
        for(let cm of selectedMembersRows){
            console.log('cm.CRM_CampaignMemberId__c ', cm.CRM_CampaignMemberId__c);
            listCampaignMemberIds.push(cm.CRM_CampaignMemberId__c);
        }


        if(this.handleAffinaClicked == false){
            this.handleAffinaClicked = true;
            this.openDialog = true;
            console.log('calcolo: '+(selectedCM+this.clientiInAffinati)/this.clientiInCampagna*100);
            console.log('check calcolo: '+(selectedCM+this.clientiInAffinati)/this.clientiInCampagna*100>=this.percAffinamento);
            this.maxNumClientAff = Math.ceil((this.percAffinamento/100)*(this.clientiInCampagna + this.clientiInAffinati));
            console.log('max aff: '+this.maxNumClientAff);
            if(selectedCM>0){
                this.selectedNdg = true;
                this.checkError = false;
               
            }else {
                this.selectedNdg = false;
                this.checkError = true;
                this.disableAffinamento = false;
            }
            if(!this.checkError){
            if((selectedCM+this.clientiInAffinati)>this.maxNumClientAff/*/this.clientiInCampagna*100>=this.percAffinamento */){
                    this.disableAffinamento = true;
                    this.checkError = true;
            }else{
                this.disableAffinamento = false;
                this.checkError = false;
            }
        }
                
        }else{
            this.isLoaded = true;
            
            
           

            setCampaignMember({
                cmList: listCampaignMemberIds,
                motivazione: this.motivazioneValue, 
                note: this.noteAffinamentoVal
            })
            .then(result => {
                console.log('result', result);
                if(result){
                    this.showToastMessage('Affinamento effettuato correttamente','success');
                    this.isLoaded = false;
                    window.location.reload();
                    this.openDialog = false;
                }else{
                    this.showToastMessage('Si è verificato un errore durante l\'affinamento','warning');
                    this.isLoaded = false;
                    this.openDialog = false;
                }
                
                this.handleAffinaClicked = false;
                
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

    //Pagination
    @api defaultLimit;
    @track page = 1;
    perpage = 50;
    @track pages = [];
    set_size = 15;
    // creata mappa che contiene per ogni pagina i valori selezionati
    // NOTE:  per far si che le righe siano selezionate bisogna evitare di usare la funzione push per aggiornare la lista, bisogna assegnarli una lista nuova
    @track selectRowsMap = {};
    @track selectRowsMapValues = {};

    handleAvanti(){
        try {
            
            let selectedRows = this.template.querySelector("[data-item='campaignMembersTable']").getSelectedRows();
            let selectedRowIds = selectedRows.map(element => element.Id);
            this.selectRowsMapValues[this.page] = selectedRows;
            this.selectRowsMap[this.page] = selectedRowIds;
            this.selectedCMRow = Boolean(this.selectRowsMapValues[this.page+1]) ? this.selectRowsMapValues[this.page+1] : [];
            this.selectedCMRowIds = Boolean(this.selectRowsMap[this.page+1]) ? this.selectRowsMap[this.page+1] : [];
            console.log('DK SELECTED ROWS: '  + JSON.stringify(this.selectedCMRow));
            ++this.page;
        } catch (error) {
            console.log('error: ', error);
        }
    }

    handleIndietro(){
        try {
            
            let selectedRows = this.template.querySelector("[data-item='campaignMembersTable']").getSelectedRows();
            let selectedRowIds = selectedRows.map(element => element.Id);
            this.selectRowsMapValues[this.page] = selectedRows;
            this.selectRowsMap[this.page] = selectedRowIds;
            this.selectedCMRow = this.selectRowsMapValues[this.page -1];
            this.selectedCMRowIds = this.selectRowsMap[this.page -1];
            console.log('DK SELECTED ROWS: '  + JSON.stringify(this.selectedCMRow));
            --this.page;
        } catch (error) {
            console.log('error: ', error);
        }
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

    showToastMessage(text, type) {
        const toastEvent = new ShowToastEvent({
            title: '',
            message: text,
            variant: type
        });
        this.dispatchEvent(toastEvent);
    }

     //START FILTER
     @track searchedStatoAssegnazione = '';
     @track searchedMMDS = '';
     @track searchedPriorita = '';
     @track searchedEsito = '';
     @track searchedNomeMw = '';
     @track searchedNDG = '';
     @track searchedRef = '';
 
     handleFilter(event){

        console.log('DK handleFilter Started');
        if(event.target.name == 'searchedStatoAssegnazione'){
            
            this.searchedStatoAssegnazione = event.target.value;
        }if(event.target.name == 'searchedRef'){
            
            this.searchedRef = event.target.value;
        }else if(event.target.name == 'searchedMMDS'){
            
            this.searchedMMDS = event.target.value;
        }else if(event.target.name == 'searchedPriorita'){
            
            this.searchedPriorita = event.target.value;
        }else if(event.target.name == 'searchedEsito'){
            
            this.searchedEsito = event.target.value;
        }else if(event.target.name == 'searchedNomeMw'){
            
            this.searchedNomeMw = event.target.value;
        }else if(event.target.name == 'searchedNDG'){
            
            this.searchedNDG = event.target.value;
        }else if(event.target.name == 'selectedNomeAttributo1'){
            
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
        }
    }

    handleReset(){
        this.searchedRef = '';
        this.searchedStatoAssegnazione = '';
        this.searchedMMDS = '';
        this.searchedPriorita = '';
        this.searchedEsito = '';
        this.searchedNomeMw = '';
        this.searchedNDG = '';
        this.selectedNomeAttributo1 = '';
        this.selectedValoreAttributo1Start = '';
        this.selectedValoreAttributo1End = '';
        this.selectedNomeAttributo2 = '';
        this.selectedValoreAttributo2Start = '';
        this.selectedValoreAttributo2End = '';
        this.searchedValoreAttributo1 = '';
        this.searchedValoreAttributo2 = '';
        this.showRangeNum1 = false; 
        this.showRangeDate1 = false;
        this.showSearchtext1 = false;
        this.showRangeNum2 = false;
        this.showRangeDate2 = false;
        this.showSearchtext2 = false;
        this.page = 1
        this.filteredData = this.data;
        this.numMembers = this.filteredData.length;
        this.setPages(this.filteredData);
    }
 
    handleSearch(){
        this.filteredData = [];
        this.page = 1;
        try {
            for(var i in this.data){
            if(Boolean(this.searchedStatoAssegnazione)){
                if(!this.data[i].CRM_StatoAssegnazione || this.data[i].CRM_StatoAssegnazione.toLowerCase() != this.searchedStatoAssegnazione.toLowerCase()){
                    continue;
                }
            }
            if(Boolean(this.searchedMMDS)){
                if(!this.data[i].PTF_ModelloDiServizio__c || this.data[i].PTF_ModelloDiServizio__c.toLowerCase() != this.searchedMMDS.toLowerCase()){
                    continue;
                }
            }
            if(Boolean(this.searchedEsito)){
                if(!this.data[i].CRM_Esito__c || this.data[i].CRM_Esito__c.toLowerCase() != this.searchedEsito.toLowerCase()){
                    continue;
                }
            }
            if(Boolean(this.searchedPriorita)){
                if(!this.data[i].CRM_PrioritaContatto__c || this.data[i].CRM_PrioritaContatto__c.toLowerCase() != this.searchedPriorita.toLowerCase()){
                    continue;
                }
            }
            if(Boolean(this.searchedNomeMw)){
                if(!this.data[i].PTF_Portafoglio || !this.data[i].PTF_Portafoglio.toLowerCase().includes(this.searchedNomeMw.toLowerCase())){
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
            if(Boolean(this.selectedNomeAttributo1)){
                if(this.data[i].CRM_NomeAttributo1 != this.selectedNomeAttributo1){
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
                if(this.data[i].CRM_NomeAttributo2 != this.selectedNomeAttributo2){
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
 
     get optionsStato() {
         return [
             { label: '---None---', value: '' },
             { label: 'Assegnato', value: 'Assegnato' },
             { label: 'Da assegnare', value: 'Da assegnare' }
         ];
     }
 
     get optionsMMDS() {
         return [
             { label: '---None---', value: '' },
             { label: 'POE', value: 'POE' },
             { label: 'Family', value: 'Family' },
             { label: 'Personal', value: 'Personal' },
             { label: 'Private', value: 'Private' },
             { label: 'Controparti Istituzionali', value: 'Controparti Istituzionali' },
            //  { label: 'Corporate', value: 'Corporate' },
             { label: 'CORPORATE', value: 'CORPORATE' },
             { label: 'Enti e Tesorerie', value: 'Enti e Tesorerie' },
             { label: 'LARGE CORPORATE', value: 'LARGE CORPORATE' },
             { label: 'Key Client Privati', value: 'Key Client Privati' },
             { label: 'Non Portafogliati', value: 'Non Portafogliati' },
             { label: 'Residuale', value: 'Residuale' },             
             { label: 'Consulenti Finanziari', value: 'Consulenti Finanziari' },
             { label: 'SMALL BUSINESS', value: 'SMALL BUSINESS' },
             


         ];
     }
 
     get optionsPriorita() {
         return [
             { label: '---None---', value: '' },
             { label: '1', value: '1' },
             { label: '2', value: '2' },
             { label: '3', value: '3' },
             { label: '4', value: '4' },
             { label: '5', value: '5' }
         ];
     }
 
     get optionsCanale() {
         return [
             { label: '---None---', value: '' },
             { label: 'Campagna commerciale', value: 'Campagna commerciale' },
             { label: 'Check-up', value: 'Check-up' },
             { label: 'Contact Center', value: 'Contact Center'}
         ];
     }
 
     get optionsBisogno() {
         return [
             { label: '---None---', value: '' },
             { label: 'Finanziamenti', value: 'Finanziamenti' },
             { label: 'Assicurativo', value: 'Assicurativo' }
         ]
     }
 
     get optionsEsito() {
         return [
             { label: '---None---', value: '' },
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
             { label: '---None---', value: '' },
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
             { label: '---None---', value: ''},
             { label: 'Da contattare', value: 'Da contattare' },
             { label: 'Da ricontattare', value: 'Da ricontattare' },
             { label: 'Fissato appuntamento', value: 'Fissato appuntamento' }
         ];
     }
     //END FILTER

     @track openDialog = false;

     //handles button clicks
     handleClickDialog(event){
         var checkPicklist=true;
         if(event.currentTarget.name == 'cancel'){
             this.openDialog = false;
             this.handleAffinaClicked =false;
             this.motivazioneValue='';
             this.noteAffinamentoVal='';

         }else{
            this.template.querySelectorAll('lightning-combobox').forEach(element => {
                checkPicklist = element.reportValidity();
                
            });

            if(checkPicklist){
                if(this.handleAffinaClicked){
                    this.handleAffinaReferenteRequestCM({});
                }else{
                    this.handleSave();
                }
            }
             
         }
     }

     get optionsMotivazioni() {
        return [
            { label: '---None---', value: '' },
            { label: 'Profilo non adatto', value: 'Profilo non adatto' },
            { label: 'Dati non Aggiornati', value: 'Dati non Aggiornati' },
            { label: 'Numerosità elevata', value: 'Numerosità elevata' }
        ];
    }

    @track motivazioneValue;
    
    handlechangeMotivazione(event) {
        this.motivazioneValue = event.detail.value;
        console.log('Motivazione selected: '+this.motivazioneValue);
    }

    handleChangeNote(event) {
        this.noteAffinamentoVal = event.detail.value;
        console.log('Note selected: '+this.noteAffinamentoVal);
    }

    onHandleSort( event ) {

        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.filteredData];
        console.log('DK sortedBy: ' + sortedBy);
        console.log('DK sortDirection: ' + sortDirection);
        cloneData.sort( this.sortBy( sortedBy != 'PTF_AccountUrl' ? sortedBy : 'CRM_NDG', sortDirection === 'asc' ? 1 : -1 ) );
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
            console.log('DK sort - reverse: ', reverse);
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