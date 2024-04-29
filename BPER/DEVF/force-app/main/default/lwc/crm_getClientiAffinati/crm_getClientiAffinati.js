import { LightningElement,api,track } from 'lwc';
import setRollback from '@salesforce/apex/CRM_AffinamentoRollbackActionCtrl.setRollback';
import getCampaignMemberAffinati from '@salesforce/apex/CRM_AffinamentoCampagne.getCampaignMemberAff';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COL_WITH_ACTION = [
    { label: '', type: 'button', initialWidth: 75, typeAttributes: 
        {
        iconName: 'utility:reply_all',
        iconPosition: 'center',
        label: '',
        title: 'Ripristina',
        variant: 'neutral'
        }
    },
    { label: 'NDG', fieldName: 'CRM_UrlNDG', type: 'url', cellAttributes:{ iconName: { fieldName: 'provenanceIconName' } },
    typeAttributes: {
        label: { fieldName: 'CRM_NDG' }
    },
    hideDefaultActions: "true",fixedWidth: 100, sortable: "true"},
    { label: 'Nome Account', fieldName: 'CRM_AccountName', type: 'text', hideDefaultActions: "true",fixedWidth: 300 , sortable: "true"},
    { label: 'MDS', fieldName: 'PTF_ModelloDiServizio__c', type: 'text',hideDefaultActions: "true",fixedWidth: 200, sortable: "true"},
    { label: 'Referente', fieldName: 'PTF_Referente', type: 'text',hideDefaultActions: "true",fixedWidth: 200, sortable: "true"},
    { label: 'Autore Affinamento', fieldName: 'CRM_NominativoUtente__c', type: 'text',hideDefaultActions: "true",fixedWidth: 200, sortable: "true"},
    { label: 'Data Affinamento', fieldName: 'CRM_DataEsclusione__c', type: 'date',hideDefaultActions: "true",fixedWidth: 200, sortable: "true"},
    { label: 'Motivo Affinamento', fieldName: 'Motivo_Affinamento__c', type: 'text',hideDefaultActions: "true",fixedWidth: 200, sortable: "true"},
    { label: 'Note Affinamento', fieldName: 'CRM_NoteAffinamento__c', type: 'text',hideDefaultActions: "true", wrapText: 'true', sortable: "true"}
    ];

const COLUMNS = [
    { label: 'NDG', fieldName: 'CRM_UrlNDG', type: 'url', cellAttributes:{ iconName: { fieldName: 'provenanceIconName' } },
    typeAttributes: {
        label: { fieldName: 'CRM_NDG' }
    },
    hideDefaultActions: "true",fixedWidth: 100, sortable: "true"},
    { label: 'Nome Account', fieldName: 'CRM_AccountName', type: 'text', hideDefaultActions: "true",fixedWidth: 300 , sortable: "true"},
    { label: 'MDS', fieldName: 'PTF_ModelloDiServizio__c', type: 'text',hideDefaultActions: "true",fixedWidth: 200, sortable: "true"},
    { label: 'Referente', fieldName: 'PTF_Referente', type: 'text',hideDefaultActions: "true",fixedWidth: 200, sortable: "true"},
    { label: 'Autore Affinamento', fieldName: 'CRM_NominativoUtente__c', type: 'text',hideDefaultActions: "true",fixedWidth: 200, sortable: "true"},
    { label: 'Data Affinamento', fieldName: 'CRM_DataEsclusione__c', type: 'date',hideDefaultActions: "true",fixedWidth: 200, sortable: "true"},
    { label: 'Motivo Affinamento', fieldName: 'Motivo_Affinamento__c', type: 'text',hideDefaultActions: "true",fixedWidth: 200, sortable: "true"},
    { label: 'Note Affinamento', fieldName: 'CRM_NoteAffinamento__c', type: 'text',hideDefaultActions: "true", wrapText: 'true',fixedWidth: 200, sortable: "true"}
    ];

export default class Crm_getClientiAffinati extends LightningElement {
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

    @track showFilter = false;
    @track loaded = false;

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

    @track numMembers = 0;

    @track showRollbackModal = false;
    @track showSpinner = false;
    @track checkInAffinamento = true;

    connectedCallback(){
        
        if(!this.defaultLimit){
            this.defaultLimit = this.perpage;
        }
        try {
            getCampaignMemberAffinati({recordId:this.recordId})
            .then(result => {
                console.log('FS getData related to campaign', this.recordId);
                console.log('FS getData result', result);
                result.campaignMemberList.forEach(element =>{
                    element.CRM_NDG = element.CRM_Account__r.CRM_NDG__c;
                    element.CRM_UrlNDG = '/' + element.CRM_Account__c;
                    element.CRM_AccountName = element.CRM_Account__r.Name;   
                    element.PTF_Referente = (element.PTF_Portafoglio__r && element.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r)  ? element.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName +' ' +element.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName : '';   
                    console.log('element.Campaign__r.CRM_AffinamentoInCorso__c: '+element.Campaign__r.CRM_AffinamentoInCorso__c);
                    if(!element.Campaign__r.CRM_AffinamentoInCorso__c){
                        this.checkInAffinamento = false;
                    }
                   
                });
                this.data = result.campaignMemberList;
                this.filteredData = this.data;
                if(this.recordId){
                    if(this.checkInAffinamento)
                        this.columns = COL_WITH_ACTION;
                    else{
                        this.columns = COLUMNS;
                    }
                    //this.filteredData.sort( this.sortBy( sortedBy, sortDirection === 'asc' ? 1 : -1 ) );
                }
                this.numMembers = this.data.length;
                this.setPages(this.filteredData);
                this.showFilter = true;
                this.loaded = true;
            })
            .catch(error => {
                // this.error = error;
                console.log('ERROR', error);
            })
            .finally(() => {
                console.log('FS Start Finaly');
                console.log('FS End Finaly');
            });
        } catch (error) {
            
            console.log('ERROR', error);
        }
    }

    onHandleSort( event ) {

        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.filteredData];
        console.log('DK sortedBy: ' + sortedBy);
        console.log('DK sortDirection: ' + sortDirection);
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
    @track searchedEsito;
    @track selectedNomeAttributo1;
    @track selectedValoreAttributo1Start;
    @track selectedValoreAttributo1End;
    @track selectedNomeAttributo2;
    @track selectedValoreAttributo2Start;
    @track selectedValoreAttributo2End;
    @track searchedValoreAttributo1;
    @track searchedValoreAttributo2;

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
        }else if(event.target.name == 'searchedEsito'){
            
            this.searchedEsito = event.target.value;
        }
    }

    handleReset(){
        
        this.searchedEsito = '';
        this.searchedValoreAttributo1 = '';
        this.selectedValoreAttributo1Start = '';
        this.selectedValoreAttributo1End = '';
        this.searchedValoreAttributo2 = '';
        this.selectedValoreAttributo2Start = '';
        this.selectedValoreAttributo2End = '';
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
                        if(this.data[i].CRM_ValoreAttributo1 != this.searchedValoreAttributo1){
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
                        if(this.data[i].CRM_ValoreAttributo2 != this.searchedValoreAttributo2){
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

    closeRollbackModal(){
        this.showRollbackModal = false;
    }
    openRollbackModal(event){
        this.rollbackCmId = (event.detail.row.CRM_CampaignMemberId__c) ? event.detail.row.CRM_CampaignMemberId__c : '';
        console.log('this.rollbackCmId: '+this.rollbackCmId);
        
        this.showRollbackModal = true;
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
            { label: 'Da ricontattare', value: 'Da ricontattare' },
            { label: 'Fissato appuntamento', value: 'Fissato appuntamento' },
            { label: 'Altro prodotto venduto', value: 'Altro prodotto venduto' },
            { label: 'Ingaggio agente', value: 'Ingaggio agente' },
            { label: 'Cliente non contattabile', value: 'Cliente non contattabile' },
            { label: 'Cliente non interessato', value: 'Cliente non interessato' }                
        ];
    }

    onHandleSort( event ) {

        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.filteredData];
        console.log('DK sortedBy: ' + sortedBy);
        console.log('DK sortDirection: ' + sortDirection);
        cloneData.sort( this.sortBy( sortedBy != 'CRM_UrlNDG' ? sortedBy : 'CRM_NDG', sortDirection === 'asc' ? 1 : -1 ) );
        // this.data = cloneData;
        this.filteredData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        this.setPages(this.filteredData);
    }

    handleRollback(event){

        //this.closeRollbackModal();
        this.toggleSpinner();
		
		setRollback({ recordIdCM: this.rollbackCmId })
		.then(result => {
			if(result){
				this.showToastMessage('Cliente ripristinato correttamente','success');
                window.location.reload();
			}else{
                this.showToastMessage('Si è verificato un errore durante il ripristino','warning');
            }
		})
		.catch(error => {
			console.error('handle rollback error: ' + JSON.stringify(error));
			this.showToastMessage(this.errorMessage,'error');
		})
        .finally(() => {
            this.toggleSpinner();
            this.closeRollbackModal();
        });

	}

    toggleSpinner() {
        this.showSpinner = !this.showSpinner;
    }

    showToastMessage(text, type) {
        const toastEvent = new ShowToastEvent({
            title: '',
            message: text,
            variant: type
        });
        this.dispatchEvent(toastEvent);
    }
}