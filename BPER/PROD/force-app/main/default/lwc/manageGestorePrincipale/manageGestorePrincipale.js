import { LightningElement, api, track  } from 'lwc';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getUserInfo from '@salesforce/apex/SV_Utilities.getUserInfo';
import init from '@salesforce/apex/ManageGestoriController.init';
import getGestoriList from '@salesforce/apex/ManageGestoriController.getGestoriList';
import searchGestoriList from '@salesforce/apex/ManageGestoriController.searchGestoriList';
import deleteSelectedGestori from '@salesforce/apex/ManageGestoriController.deleteSelectedGestori';
import insertNewGestori from '@salesforce/apex/ManageGestoriController.insertNewGestori';
import getPercentage from '@salesforce/apex/ManageGestoriController.getPercentage';
//CR 52359 SV start
import searchGestoriPrivateList from '@salesforce/apex/ManageGestoriController.searchGestoriPrivateList';
//CR 52359 SV end

import Nominativo from '@salesforce/label/c.manageGestorePrincipale_CLM_Nominativo';
import Matricola from '@salesforce/label/c.manageGestorePrincipale_CLM_Matricola';
import Filiale from '@salesforce/label/c.manageGestorePrincipale_CLM_Filiale';
import ModelloServizio from '@salesforce/label/c.manageGestorePrincipale_CLM_ModelloServizio';
import SPER_ModelloServizio from '@salesforce/label/c.manageGestorePrincipale_CLMSPER_ModelloServizio';
import Percentuale from '@salesforce/label/c.manageGestorePrincipale_CLMSPER_Percentuale';

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
const COLUMNSPER=[{
        label: SPER_ModelloServizio,
        fieldName: 'Modello',
        type: 'text',
    },
    {
        label: Percentuale,
        fieldName: 'Perc',
        type: 'text',
    }
];

export default class ManageGestorePrincipale extends LightningElement {

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
    @track gestoriPrincipaleList = [];
    @track gestoriPrincipaleToDelete = [];
    @track searchedMatricola = '';
    @track searchedNome = '';
    @track searchedCognome = '';
    // @track selectedreferentiList = [];
    @track filteredReferentiList = [];
    @track referentiList = [];
    @track referentiListCount = 0;
    @track isAssigned = false;
    @track hasGestori = false;
    @track hasSearched = false;
    @track perBeforeData=[];
    @track perAfterData=[];
    @track selected;

    @track disableSaveButton = false;

    @track limit = 5;
    @track offset = 0;

    hasOFS;
    
    columns = COLUMNS;
    columnsPer=COLUMNSPER;

    @track loaded = false;
    @track searchLoaded = false;
    @track profileName = '';
    @track isCheck999 = false;
    @track isPTFSvil = false;

    @track tableTarget = {};
    
    connectedCallback() {

        getUserInfo()
        .then(result => {
            console.log('DK getUserInfo result', result);
            console.log('DK profiliAutorizzati', this.profiliAutorizzati);
            this.profileName=result.Profile.Name;
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
                
                this.handleGetGestoriPrincipale().then(() => {

                    this.loadSearchedGestoriPrincipaleData(false).then(() =>{
        
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
                this.isCheck999 = data['isChecked999'];
                this.isPTFSvil = data['isPTFSvil'];
            }).catch(error =>{
    
                console.log('init.init.error: ' + JSON.stringify(error));
            });
        } catch (error) {
            
            console.log('init.error: ' + error);
        }
    }
    
    handleGetGestoriPrincipale(){

        try {

            return getGestoriList({
                recordId: this.recordId,
                roleMDSMap: this.roleMDSMap,
                recordTypeName: 'Primario'
            }).then(data => {
                
                console.log('JSON.stringify(data): ' + JSON.stringify(data));
                this.gestoriPrincipaleList = JSON.parse(JSON.stringify(data));
                if(this.gestoriPrincipaleList.length > 0){

                    this.isAssigned = true;
                }else{
                    
                    this.isAssigned = false;
                }
                this.loaded = true;
            }).catch(error => {
    
                console.log('handleGetGestoriPrincipale.error: ' + JSON.stringify(error));
            });
        } catch (error) {
            
            console.log('handleGetGestoriPrincipale.error: ' + error);
        }
    }
    
    loadSearchedGestoriPrincipaleData(){
        
        try {
            let contactIdList = this.gestoriPrincipaleList.map(item => item.contactId);
            //CR 52359 SV strat
            if(this.microPortafoglio.PTF_ModelloDiServizio__c === 'Private'/* && this.microPortafoglio.PTF_ABI__c === '05387'*/){
                this.hasSearched = true;
                console.log('pz sono qua ');
                console.log('pz sono qua ',JSON.stringify(this.microPortafoglio.PTF_UffPrivate__r));
                let idCed = this.microPortafoglio.PTF_UffPrivate__r ? this.microPortafoglio.PTF_UffPrivate__r.PTF_IdCED__c : this.microPortafoglio.PTF_Executive__r.PTF_IdCED__c;
                let idCedPadre = this.microPortafoglio.PTF_UffPrivate__r ? this.microPortafoglio.PTF_UffPrivate__r.Parent.PTF_IdCED__c : null;
                var params = {
                    contactIdList: contactIdList,
                    idCed: idCed,
                    idCedPadre : idCedPadre,
                    abi: this.microPortafoglio.PTF_ABI__c,
                    //SC Centri Private start
                    idCedCentroPrivate: this.microPortafoglio.PTF_CentrPrivate__c ? this.microPortafoglio.PTF_CentrPrivate__r.PTF_IdCED__c : null,
                    idCedPadreCentroPrivate: this.microPortafoglio.PTF_CentrPrivate__c ? this.microPortafoglio.PTF_CentrPrivate__r.PTF_IdCEDPadre__c : null,
                    //SC Centri Private start
                    isExecutive: Boolean(this.microPortafoglio.PTF_Executive__r)
                }
                console.log('pz sono qua 2');
                return searchGestoriPrivateList({
                    params: JSON.stringify(params),
                    recordId: this.recordId,
                    modelloServizio: this.microPortafoglio.PTF_ModelloDiServizio__c,
                    filiale: this.microPortafoglio.PTF_Filiale__c,
                    isCheck999: this.isCheck999,
                    isPTFSvil: this.isPTFSvil   
                })
                .then(result => {
                    this.referentiListCount = result["referentiListCount"];
                    this.referentiList = result["referentiList"];
                    this.filteredReferentiList = result["referentiList"];
                    console.log(result["referentiList"]);
                    console.log('refcount: '+this.referentiListCount);
                    console.log('reflist: ',this.referentiList);
                    console.log('refilt: ',this.filteredReferentiList);

                    if(this.referentiListCount > 0){
        
                        this.hasGestori = true;
                        console.log('gestori: '+this.hasGestori);
                    } else{
        
                        this.hasGestori = false;
                    }
                    this.setPages(this.filteredReferentiList);
                })
                .catch(error => {
                    console.log('loadGestoriList.searchGestoriPrivate.error: ' + error);
                    console.log('loadGestoriList.searchGestoriPrivate.error: ' + JSON.stringify(error));
                })
            }else{
                this.hasSearched = true;
                var params = {
                    recordId: this.recordId,
                    recordTypeName: 'Primario',
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
                    profileName:this.profileName,
                    isChecked999: this.isCheck999,
                    isCheckedPTF: this.isPTFSvil
                }).then(result => {
                    
                    console.log('result: ' + JSON.stringify(result));
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
        
                    console.log('loadGestoriList.searchGestori.error: ' + error);
                    console.log('loadGestoriList.searchGestori.error: ' + JSON.stringify(error));
                });
            }
            //CR 52359 SV end
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
            if(this.isAssigned){
                const x = new ShowToastEvent({
                    "title": "Errore!",
                    "variant": "error",
                    "message": "Eliminare il Referente principale già assegnato"
                });
                this.dispatchEvent(x);
            }
            else{
                let searchedPrincipaleTable = this.template.querySelector('[data-item="searchedGestoriTable"]');
            let gestoriPrincipaleToInsert = [];
            if(searchedPrincipaleTable){

                gestoriPrincipaleToInsert = searchedPrincipaleTable.getSelectedRows();
            }
            if(gestoriPrincipaleToInsert.length > 0){

                this.disableSaveButton = true;
                insertNewGestori({
                    recordId: this.recordId,
                    gestoriToInsert: gestoriPrincipaleToInsert.map(item => item.Id),
                    recordTypeName: 'Primario'
                }).then(data => {
                    
                    this.disableSaveButton = false;
                    const toastEvent = new ShowToastEvent({
                        title: "Successo!",
                        message: "Gestore principale aggiunto con successo!!",
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
            }
            
        } catch (error) {
            
            const toastEvent = new ShowToastEvent({
                title: "Attenzione!",
                message: error,
                variant: "warning"
            });
            this.dispatchEvent(toastEvent);
            console.log('handleChangeGestore.error1: ' + error);
        }
    }

    deleteGestoriPrincipale(){

        try {
            
            let gestoriPrincipaleTable = this.template.querySelector('[data-item="gestoriPrincipaleTable"]');
            let gestoriPrincipaleToDelete = gestoriPrincipaleTable.getSelectedRows();
            if (gestoriPrincipaleToDelete.length > 0) {
                
                let idsToDelete = gestoriPrincipaleToDelete.map(item => item.Id)
                deleteSelectedGestori({
                    recordId: this.recordId,
                    gestoriToDelete: idsToDelete,
                    recordTypeName: 'Primario'
                }).then(data => {

                    this.gestoriPrincipaleList = this.gestoriPrincipaleList.filter(gestore => !idsToDelete.includes(gestore.Id));
                    if(this.gestoriPrincipaleList.length > 0){

                        this.isAssigned = true;
                    }else{

                        this.isAssigned = false;
                    }

                    this.refreshPage();
                    const toastEvent = new ShowToastEvent({
                        title: "Successo!",
                        message: "Gestore Principale eliminato con successo!!",
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

    handleRowSelection(event){
        let srId=event.detail.selectedRows.map(item=>item.Id);
        getPercentage({
            recordId: this.recordId,
            selectedRef: srId[0]
        })
        .then(result =>{
            let tempDataBefore=[];
            let tempDataAfter=[];
            for(let key in result["beforeMap"]){
                let item ={};
                item.Modello=key;
                item.Perc=(result["beforeMap"][key] * 100) + '%';
                tempDataBefore.push(item);
            }
            for(let key in result["afterMap"]){
                let item ={};
                item.Modello=key;
                item.Perc=(result["afterMap"][key] *100) + '%';
                tempDataAfter.push(item);
            }
            if(srId.length > 0){

                this.selected=true;
            }else{

                this.selected=false;
            }
            this.perBeforeData=tempDataBefore;
            this.perAfterData=tempDataAfter;
        })
        .catch(error=>{
            console.log("errorSelection: "+JSON.stringify(error));
            this.selected=false;
        });

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
        console.log('pageData');
        let page = this.page;
        let perpage = this.perpage;
        let startIndex = (page*perpage) - perpage;
        let endIndex = (page*perpage);
        let referentiToDisplay = this.filteredReferentiList.slice(startIndex,endIndex);
        let referentiToDisplayIdList = referentiToDisplay.map(item => item.Id);
        console.log('refDisp: '+referentiToDisplay);

        referentiToDisplay.forEach(element => {
            
            element.Filiale = element.Account.Name;
            if(this.roleMDSMap[element.PTF_TipologiaRuolo__c]){

                element.PTF_ModelloDiServizio__c = this.roleMDSMap[element.PTF_TipologiaRuolo__c].join(', ');
            }
        });
        console.log('refDispdp: '+referentiToDisplay);
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