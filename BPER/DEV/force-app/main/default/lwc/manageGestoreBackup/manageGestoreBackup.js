import { LightningElement, api, track  } from 'lwc';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getUserInfo from '@salesforce/apex/SV_Utilities.getUserInfo';
import init from '@salesforce/apex/ManageGestoriController.init';
import getGestoriList from '@salesforce/apex/ManageGestoriController.getGestoriList';
import searchGestoriList from '@salesforce/apex/ManageGestoriController.searchGestoriList';
import deleteSelectedGestori from '@salesforce/apex/ManageGestoriController.deleteSelectedGestori';
import insertNewGestori from '@salesforce/apex/ManageGestoriController.insertNewGestori'
//CR 52359 SV start
import searchGestoriBackupPrivateList from '@salesforce/apex/ManageGestoriController.searchGetBackupPrivateList';
//CR 52359 SV end
import Nominativo from '@salesforce/label/c.manageGestoreBackup_CLM_Nominativo';
import Matricola from '@salesforce/label/c.manageGestoreBackup_CLM_Matricola';
import Filiale from '@salesforce/label/c.manageGestoreBackup_CLM_Filiale';
import ModelloServizio from '@salesforce/label/c.manageGestoreBackup_CLM_ModelloServizio';


const COLUMNS = [{
    label: Nominativo,
    fieldName: 'Name',
    type: 'text',
    sortable: true
},
{
    label: Matricola,
    fieldName: 'PTF_RegistrationNumber__c',
    type: 'text',
    sortable: true
},
{
    label: Filiale,
    fieldName: 'Filiale',
    type: 'text',
    sortable: true
},
{
    label: ModelloServizio,
    fieldName: 'PTF_ModelloDiServizio__c',
    type: 'text',
    sortable: true
}
];

export default class ManageGestoreBackup extends LightningElement {

    @api recordId;
    @api userInfo;
    @api profiliAutorizzati = [
        'NEC_D.0',
        'NEC_D.7',
        'NEC_ADMIN',
        'NEC_SYSADMIN',
        'NEC_F.1',
        'NEC_F.10',
        'System Administrator'
    ];

    @track eligibleRoles = [];
    //@track eligibleRolesGerarchia = [];
    @track idCedGerarchiaSet = [];
    @track idCedBanca;
    @track idCedDR;
    @track idCedArea;
    @track roleMDSMap = {};
    @track microPortafoglio = {};
    @track gestoriBackupList = [];
    @track gestoriBackupToDelete = [];
    @track searchedMatricola = '';
    @track searchedNome = '';
    @track searchedCognome = '';
    @track filteredReferentiList = [];
    @track referentiList = [];
    @track referentiListCount = 0;
    @track isAssigned = false;
    @track hasGestori = false;
    @track hasSearched = false;

    @track disableSaveButton = false;

    @track limit = 5;
    @track offset = 0;
    
    hasOFS;
    
    columns = COLUMNS;

    @track loaded = false;
    @track searchLoaded = false;

    @track tableTarget = {};
    @track isCheck999 = false;
    @track isCheckPTF = false; // LV CR NEC #70081
    
    connectedCallback() {
        
        getUserInfo()
        .then(result => {
            console.log('DK getUserInfo result', result);
            console.log('DK profiliAutorizzati', this.profiliAutorizzati);

            this.userInfo = result;
            if(this.profiliAutorizzati === undefined || this.profiliAutorizzati.indexOf(result.Profile.Name) > -1){
                this.profiloAutorizzatoShow = true;
            }
            console.log('DK profiloAutorizzatoShow', this.profiloAutorizzatoShow);

            if(this.profiloAutorizzatoShow){

                return this.handleInit();
            }
        })
        .then(() => {
            
            if(!this.profiloAutorizzatoShow){
                const toastEvent = new ShowToastEvent({
                    title: "Errore!",
                    message: "Profilo non autorizzato a gestire i referenti per questo Microportafoglio.",
                    variant: "error"
                });
                this.dispatchEvent(toastEvent);
                this.closeQuickAction();
            }else if(this.microPortafoglio.PTF_Pool__c || Boolean(this.microPortafoglio.PTF_DeletionDate__c )){

                const toastEvent = new ShowToastEvent({
                    title: "Errore!",
                    message: "Non è possibile gestire i referenti per questo Microportafoglio.",
                    variant: "error"
                });
                this.dispatchEvent(toastEvent);
                this.closeQuickAction();
            }else{
                
                this.handleGetGestoriBackup().then(() => {

                    this.loadSearchedGestoriBackupData(false).then(() =>{
            
                        this.searchLoaded = true;
                    });
                });
            }
        });
    }

    handleInit(){

        try {
            
            return init({
               recordId: this.recordId
            }).then(data => {
                
                console.log('DK init data: ' + JSON.stringify(data));
                this.microPortafoglio = data['currentPF'];
                this.idCedGerarchiaSet = data['idCedGerarchiaSet'];
                this.idCedBanca = data['idCedBanca'];
                this.idCedDR = data['idCedDR'];
                this.idCedArea = data['idCedArea'];
                this.eligibleRoles = data['eligibleRoles'];
                //this.eligibleRolesGerarchia = data['eligibleRolesGerarchia'];
                this.roleMDSMap = data['roleMDSMap'];
                this.hasOFS = data['hasOFS'];
            }).catch(error =>{
    
                console.log('init.init.error: ' + JSON.stringify(error));
            });
        } catch (error) {
            
            console.log('init.error: ' + error);
        }
    }
    
    handleGetGestoriBackup(){

        try {

            return getGestoriList({
                recordId: this.recordId,
                roleMDSMap: this.roleMDSMap,
                recordTypeName: 'Backup'
            }).then(data => {
                
                console.log('JSON.stringify(data): ' + JSON.stringify(data));
                this.gestoriBackupList = JSON.parse(JSON.stringify(data));
                if(this.gestoriBackupList.length > 0){

                    this.isAssigned = true;
                }else{
                    
                    this.isAssigned = false;
                }
                this.loaded = true;
                console.log('this.loaded: ' + this.loaded );
            }).catch(error => {
    
                console.log('handleGetGestoriBackup.error: ' + JSON.stringify(error));
            });
        } catch (error) {
            
            console.log('handleGetGestoriBackup.error: ' + error);
        }
    }

    loadSearchedGestoriBackupData(isSearch){

        try {
            //CR 52359 SV start
            if(this.microPortafoglio.PTF_ModelloDiServizio__c === 'Private'/* && this.microPortafoglio.PTF_ABI__c === '05387'*/){
                
                console.log('rec: '+this.recordId);
                console.log('fil: '+this.microPortafoglio.PTF_Filiale__c );
                this.hasSearched = true;
                /*if(isSearch){

                    this.searchLoaded = false;
                    this.offset = 0;
                }*/
                let idCed = this.microPortafoglio.PTF_UffPrivate__r ? this.microPortafoglio.PTF_UffPrivate__r.PTF_IdCED__c : this.microPortafoglio.PTF_Executive__r.PTF_IdCED__c;
                let idCedPadre = this.microPortafoglio.PTF_UffPrivate__r ? this.microPortafoglio.PTF_UffPrivate__r.Parent.PTF_IdCED__c : null;
                console.log('id: '+idCed);
                console.log('idpadre: '+idCedPadre);
                var params = {
                    idCed: idCed,
                    idCedPadre : idCedPadre,
                    abi: this.microPortafoglio.PTF_ABI__c,
                    //SV Centri Private start
                    idCedCentroPrivate: this.microPortafoglio.PTF_CentrPrivate__c ? this.microPortafoglio.PTF_CentrPrivate__r.PTF_IdCED__c : null,
                    idCedPadreCentroPrivate: this.microPortafoglio.PTF_CentrPrivate__c ? this.microPortafoglio.PTF_CentrPrivate__r.Parent.PTF_IdCED__c : null,
                    //SV Centri Private start
                    isExecutive: Boolean(this.microPortafoglio.PTF_Executive__r)
                }
                return searchGestoriBackupPrivateList({
                    params: JSON.stringify(params),
                    recordId: this.recordId,
                    modelloServizio: this.microPortafoglio.PTF_ModelloDiServizio__c,
                    filiale: this.microPortafoglio.PTF_Filiale__c  
                })
                .then(result => {
                        
                    console.log('result searchGestoriBackupPrivateList: ' + JSON.stringify(result));
                    this.referentiListCount = result["referentiListCount"];
                    this.referentiList = result["referentiList"];
                    this.filteredReferentiList = result["referentiList"];
                    console.log(result["referentiList"]);
                    console.log('refcount: '+this.referentiListCount);
                    console.log('reflist: ',this.referentiList);
                    console.log('refilt: ',this.filteredReferentiList);

                    if(this.referentiListCount > 0){
        
                        this.hasGestori = true;
                    } else{
        
                        this.hasGestori = false;
                    }
                    this.setPages(this.filteredReferentiList);
                }).catch(error => {
        
                    console.log('loadGestoriList.searchGestori.error: ' + JSON.stringify(error));
                });

            }else{
                let contactIdList = this.gestoriBackupList.map(item => item.contactId);
                this.hasSearched = true;
                if(isSearch){

                    this.searchLoaded = false;
                    this.offset = 0;
                }
                var params = {
                    recordId: this.recordId,
                    recordTypeName: 'Backup',
                    mds: this.microPortafoglio.PTF_ModelloDiServizio__c,
                    nome: this.searchedNome,
                    hasOFS: this.hasOFS,
                    matricola: this.searchedMatricola,
                    contactIdList: contactIdList,
                    //eligibleRolesGerarchia: this.eligibleRolesGerarchia,
                    idCedGerarchiaSet: this.idCedGerarchiaSet,
                    idCedBanca: this.idCedBanca,
                    idCedDR: this.idCedDR,
                    idCedArea: this.idCedArea
                }
                return searchGestoriList({
                    params: JSON.stringify(params),
                    filiale: this.microPortafoglio.PTF_Filiale__c,
                    eligibleRoles: this.eligibleRoles,
                    offset: this.offset,
                    pagesize: this.limit,
                    isChecked999: this.isCheck999,
                    isCheckedPTF: this.isCheckPTF // LV CR NEC #70081
                }).then(result => {
                    
                    console.log('result searchGestoriList: ' + JSON.stringify(result));
                    this.referentiListCount = result["referentiListCount"];
                    this.referentiList = result["referentiList"];
                    this.filteredReferentiList = result["referentiList"];

                    if(this.referentiListCount > 0){
        
                        this.hasGestori = true;
                    } else{
        
                        this.hasGestori = false;
                    }
                    this.setPages(this.filteredReferentiList);
                }).catch(error => {
        
                    console.log('loadGestoriList.searchGestori.error: ' + JSON.stringify(error));
                });
            }
            
        } catch (error) {

            console.log('handleChangeGestore.error: ' + error);
        }
    }

    handleReset(){

        this.searchedNome = '';
        this.searchedMatricola = '';
        this.handleSearch();
    }

    handleSearch(){

        this.filteredReferentiList = [];
        this.page = 1;
        try {
            
            for(var i in this.referentiList){
                        
                if(Boolean(this.searchedNome)){

                    if(!this.referentiList[i].Name.toLowerCase().includes(this.searchedNome.toLowerCase())){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedMatricola)){

                    if(!this.referentiList[i].PTF_RegistrationNumber__c.toLowerCase().includes(this.searchedMatricola.toLowerCase())){
    
                        continue;
                    }
                }
    
                this.filteredReferentiList.push(this.referentiList[i]);
            }
    
            console.log('DK filteredReferentiList: ' + JSON.stringify(this.filteredReferentiList));
            console.log('DK this.page: ' + this.page);
            if(this.filteredReferentiList.length > 0){
    
                this.hasGestori = true;
            } else{

                this.hasGestori = false;
            }
            this.setPages(this.filteredReferentiList);
        } catch (error) {
            
            console.log('DK error: ' + error);
        }
    }

    handleSaveGestori(){

        try {
            
            let searchedBackupTable = this.template.querySelector('[data-item="searchedGestoriTable"]');
            let gestoriBackupToInsert = [];
            if(searchedBackupTable){

                gestoriBackupToInsert = searchedBackupTable.getSelectedRows();
            }

            if(gestoriBackupToInsert.length > 0){

                this.disableSaveButton = true;
                insertNewGestori({
                    recordId: this.recordId,
                    gestoriToInsert: gestoriBackupToInsert.map(item => item.Id),
                    recordTypeName: 'Backup'
                }).then(data => {

                    this.disableSaveButton = false;
                    const toastEvent = new ShowToastEvent({
                        title: "Successo!",
                        message: "Gestori di backup aggiunti con successo!!",
                        variant: "success"
                    });
                    this.dispatchEvent(toastEvent);
                    this.closeQuickAction();
                }).catch(error => {
                    
                    this.disableSaveButton = false;
                    console.log('handleChangeGestore.changeGestore.error: ' + JSON.stringify(error));
                });
            }else{

                const toastEvent = new ShowToastEvent({
                    title: "Attenzione!",
                    message: "Selezionare almeno un elemento dalla lista.",
                    variant: "warning"
                });
                this.dispatchEvent(toastEvent);
            }
        } catch (error) {
            
            console.log('handleChangeGestore.error: ' + error);
        }
    }

    deleteGestoriBackup(){

        try {
            
            let gestoriBackupTable = this.template.querySelector('[data-item="gestoriBackUpTable"]');
            let gestoriBackupToDelete = gestoriBackupTable.getSelectedRows();
            if (gestoriBackupToDelete.length > 0) {
                
                let idsToDelete = gestoriBackupToDelete.map(item => item.Id)
                deleteSelectedGestori({
                    recordId: this.recordId,
                    gestoriToDelete: idsToDelete,
                    recordTypeName: 'Backup'
                }).then(data => {

                    this.gestoriBackupList = this.gestoriBackupList.filter(gestore => !idsToDelete.includes(gestore.Id));
                    if(this.gestoriBackupList.length > 0){

                        this.isAssigned = true;
                    }else{

                        this.isAssigned = false;
                    }

                    this.refreshPage();
                    const toastEvent = new ShowToastEvent({
                        title: "Successo!",
                        message: "Gestori di backup eliminati con successo!!",
                        variant: "success"
                    });
                    this.dispatchEvent(toastEvent);
                }).catch(error => {

                    console.log('deleteGestore.deleteSelectedGestori.error: ' + JSON.stringify(error));
                });
            }
        } catch (error) {

            console.log('error: ' + error);
        }
    }

    //Helper
    setFilter(event){

        if(event.target.name == 'searchedNome'){
                
            this.searchedNome = event.target.value;
        }
        else{

            this.searchedMatricola = event.target.value;
        }
    }

    closeQuickAction() {
        
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    refreshPage() {
        
        const refreshEvent = new CustomEvent('refresh');
        // Dispatches the event.
        this.dispatchEvent(refreshEvent);
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
        let referentiToDisplay = this.filteredReferentiList.slice(startIndex,endIndex);
        let referentiToDisplayIdList = referentiToDisplay.map(item => item.Id);

        referentiToDisplay.forEach(element => {
            
            element.Filiale = element.Account.Name;
            if(this.roleMDSMap[element.PTF_TipologiaRuolo__c]){

                element.PTF_ModelloDiServizio__c = this.roleMDSMap[element.PTF_TipologiaRuolo__c].join(', ');
            }
        });

        return referentiToDisplay;
    }

    setPages = (data)=>{
        this.pages = [];
        let numberOfPages = Math.ceil(data.length / this.perpage);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
        console.log('DK this.pages: ' + this.pages);
    }  
    
    get disabledButtonIndietro(){
        return this.page === 1;
    }
    
    get disabledButtonAvanti(){
        return this.page === this.pages.length || this.filteredReferentiList.length === 0
    }

    

    get currentPageData(){
        return this.pageData();
    }

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