//Author : Dam Kebe @Lutech
import { LightningElement, api, track } from 'lwc';
//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//import controller Methods
import loadNdgList from '@salesforce/apex/MultipleAssignmentController.loadNdgList';
import loadMwList from '@salesforce/apex/MultipleAssignmentController.loadMwList';
import executeAssignment from '@salesforce/apex/MultipleAssignmentController.executeAssignment';
import loadRelatedRecords from '@salesforce/apex/MultipleAssignmentController.loadRelatedRecords';
import loadMws from '@salesforce/apex/MultipleAssignmentController.loadMws';

import Name from '@salesforce/label/c.multipleAssignment_CLM_Name';
import NDG from '@salesforce/label/c.multipleAssignment_CLM_NDG';
import PIVA from '@salesforce/label/c.multipleAssignment_CLM_PIVA';
import TAG from '@salesforce/label/c.multipleAssignment_CLM_TAGRiportafogliazione';
import Filiale from '@salesforce/label/c.multipleAssignment_CLM_Filiale';
import ModelloServizio from '@salesforce/label/c.multipleAssignment_CLM_ModelloServizio';
import NaturaGiuridica from '@salesforce/label/c.multipleAssignment_CLM_NaturaGiuridica';
import GruppoGestionale from '@salesforce/label/c.multipleAssignment_CLM_GruppoGestionale';
import MicroPortafoglio from '@salesforce/label/c.multipleAssignment_MwCLM_MicroPortafoglio';
import Mw_ModelloServizio from '@salesforce/label/c.multipleAssignment_MwCLM_ModelloServizio';
import Mw_Filiale from '@salesforce/label/c.multipleAssignment_MwCLM_Filiale';
import Referente from '@salesforce/label/c.multipleAssignment_MwCLM_Referente';


const COLUMNS = [
    {
        label: Name,
        fieldName: 'Name',
        type: 'text',
        sortable:"true"
    },
    {
        label: NDG,
        fieldName: 'PTF_Url',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'CRM_NDG__c' }
        },
        sortable:"true"
    },
    {
        label: TAG,
        fieldName: 'PTF_RiportafogliazioneTAG__c',
        type: 'text'
    },
    {
        label: Filiale,
        fieldName: 'PTF_UrlFiliale',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'PTF_NameFiliale' }
        }
    },
    {
        label: ModelloServizio,
        fieldName: 'ModelloDiServizio__c',
        type: 'text'
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
        label: 'Patrimonio',
        fieldName: 'PTF_Patrimonio__c',
        type: 'text'
    },
    {
        label: 'Fatturato',
        fieldName: 'AnnualRevenue',
        type: 'text'
    },
   /*{
        label: 'Concordato',
        fieldName: 'PTF_Concordato__c',
        type: 'text'
    },
    {
        label: 'Accordato',
        fieldName: 'PTF_Accordato__c',
        type: 'text'
    }*/
];

const MWCOLUMNS = [
    {
        label: MicroPortafoglio,
        fieldName: 'Name',
        type: 'text'
    },
    {
        label: Mw_ModelloServizio,
        fieldName: 'PTF_ModelloDiServizio__c',
        type: 'text'
    },
    {
        label: Mw_Filiale,
        fieldName: 'Filiale',
        type: 'text'
    },
    {
        label: Referente,
        fieldName: 'CRM_ReferenteFormula__c',
        type: 'text'
    }
];
export default class MultipleAssignment extends LightningElement {

    @api recordId;
    @track clickedSalva=false;
    @api defaultLimit;
    @track showNDGs = false;
    @api ndgList = [];
    @track filteredRecords=[];
    @track selectedNdgList = [];
    @track ndgListCount;
    @track hasNDGRows = false;
    @track selectedNDGs = [];
    @track selectedNDGRows = [];
    @track searchedNome = '';
    @track searchedNDG = '';
    @track mwList = [];
    @track mwListCount;
    @track hasMWRows = false;
    @track ndgOffset = 0;
    @track ndgLimit = 5;
    @track mwOffset = 0;
    @track mwLimit = 5;
    @track selectedNdgIdRows=[];
    @track sortBy;
    @track sortByAll;
    @track sortDirection;
    @track sortDirectionAll;
    @track allData=[];
    @api stopLoading = false;

    //valerio.salvati
    @track listaCointestazioni = [];
    @track listaPF = [];
    @track listaCointestazioniId = [];
    @track listaPfId = [];
    @track relatedRecords = [];
    @track mwError = false;;
    @track cointestazioniCorrelate = [];
    @track pfCorrelate = [];

    @track tableTarget = {};


    columns = COLUMNS;
    mwColumns = MWCOLUMNS;
    connectedCallback(){
        this.ndgLimit = parseInt(this.defaultLimit);
        this.mwLimit = parseInt(this.defaultLimit);
        this.loadNDGRecords();
    }

    /*loadMoreNDGData(event){

        try {
            this.tableTarget = event;
            if(this.ndgListCount > this.ndgOffset){
                
                this.tableTarget.isLoading = true;
                this.ndgOffset += this.ndgLimit;
                this.loadNDGRecords().then(() =>{

                    this.tableTarget.isLoading = false;
                });
            } else {
                this.tableTarget.isLoading = false;
            }
        } catch (error) {
            
            console.log('loadMoreNDGData.error: ' + error);
        }
    }*/

    loadNDGRecords(){
        
        try{
            return loadNdgList({
                recordId: this.recordId,
                offset: this.ndgOffset,
                pagesize: this.ndgLimit,
                name: this.searchedNome,
                ndg: this.searchedNDG
            })
            .then(result => {

                this.showNDGs = true;
                this.ndgListCount = result["ndgListCount"];
                
                let ndgIdList = this.ndgList.map(item => item.Id);
                let newValueList = [];
                result["ndgList"].forEach(element => {
                    element.PTF_Url = '/' + element.Id;
                    element.PTF_UrlFiliale = '/' + element.PTF_Filiale__c;
                    element.PTF_NameFiliale = element.PTF_Filiale__r.Name;
                    let index = ndgIdList.indexOf(element.Id);
                    if(index <= -1){

                        newValueList.push(element);
                    }
                });
                this.ndgList = this.ndgList.concat(newValueList);
                this.filteredRecords = this.ndgList;
                this.setPages(this.filteredRecords);
                if(this.ndgList.length > 0){

                    this.hasNDGRows = true;
                }else{

                    this.hasNDGRows = false;
                }
                console.log('ndgList: ' + JSON.stringify(this.ndgList));

                this.sortByAll = 'Name';
                this.sortDirectionAll = 'asc';
                this.sortDataAll(this.sortByAll, this.sortDirectionAll);
                
            })
            .catch(error => { 
                console.log('loadNDGRecords.loadNdgList.error: ' + JSON.stringify(error));
            })
        }catch(error){

            console.log('loadNDGRecords.error: ' + error);
        }
        
    }
    doSorting(event){
        let sortBy;
        this.sortByAll = event.detail.fieldName;
        if(event.detail.fieldName==='Name'){
            sortBy = 'Name';
        }
        else if(event.detail.fieldName==='PTF_Url'){
            sortBy = 'PTF_Url';
        }
        else{
            sortBy = event.detail.fieldName;
        }
        this.sortDirectionAll = event.detail.sortDirection;
        this.sortDataAll(sortBy, this.sortDirectionAll);
    }

    sortDataAll(fieldname, direction){
        let parseData = JSON.parse(JSON.stringify(this.ndgList));
        let keyValue = (a) => {
        return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : ''; 
        y = keyValue(y) ? keyValue(y) : '';
        return isReverse * ((x > y) - (y > x));
        });
        this.ndgList=parseData;
        this.filteredRecords=this.ndgList;
     }

    /*loadMoreMWData(event){

        try {
            
            //Display a spinner to signal that data is being loaded
            const { target } = event;
            if(this.mwListCount > this.mwOffset){
             
                target.isLoading = true;
                this.mwOffset += this.mwLimit;
                this.loadMWRecords().then(() =>{

                    target.isLoading = false;
                });
            } else {
                target.isLoading = false;
            }
        } catch (error) {
         
            console.log('loadMoreMWData.error: ' + error);
        }
    }*/

    loadMWRecords(){

        var filialeSet = [];
        var modelloDiServizioSet = [];
        if(this.selectedNDGs.length > 0){
            //valerio.salvati START
            var moveToPrimaryWallet = false;
            var portafoglioPrimarioId;
            console.log('loadMWRecords - selectedNDG Length: ' + this.selectedNDGs.length);

            if(this.selectedNDGs.length == 1 && this.selectedNDGs[0].PTF_NaturaGiuridica__c == 'CO'){
                console.log('loadMWRecords - pfCorrelate Length: ' + this.pfCorrelate.length);

                if(this.pfCorrelate.length > 0){
                    var cointestazione = this.selectedNDGs[0];
                    var pf = this.pfCorrelate[0];
                    console.log('loadMWRecords - cointestazione: ', cointestazione);
                    console.log('loadMWRecords - pf: ', pf);
                    if(pf.CRM_Account__r.PTF_Portafoglio__c != cointestazione.PTF_Portafoglio__c){
                        //filialeSet.push(pf.CRM_Account__r.PTF_Filiale__c);
                        //modelloDiServizioSet.push(pf.CRM_Account__r.ModelloDiServizio__c);
                        moveToPrimaryWallet = true;
                        portafoglioPrimarioId = pf.CRM_Account__r.PTF_Portafoglio__c;
                    }
                }

                /*if(this.cointestazioniCorrelate.length > 0){
                    filialeSet.push(this.cointestazioniCorrelate[0].CRM_JointOwnership__r.PTF_Filiale__c);
                    modelloDiServizioSet.push(this.cointestazioniCorrelate[0].CRM_JointOwnership__r.ModelloDiServizio__c);
                }*/

            }
            if(!moveToPrimaryWallet){
            //valerio.salvati END
                for(var i=0; i< this.selectedNDGs.length; i++){
        
                    if(Boolean(this.selectedNDGs[i].Id)){
        
                        filialeSet.push(this.selectedNDGs[i].PTF_Filiale__c);
                    }
        
                    if(Boolean(this.selectedNDGs[i].ModelloDiServizio__c)){
        
                        modelloDiServizioSet.push(this.selectedNDGs[i].ModelloDiServizio__c);
                    }
                }
            } //valerio.salvati
            console.log('loadMWRecords - filialeSet: ' + JSON.stringify(filialeSet));
            console.log('loadMWRecords - modelloDiServizioSet: ' + JSON.stringify(modelloDiServizioSet));
            console.log('loadMWRecords - moveToPrimaryWallet: ' + moveToPrimaryWallet);

            try{
                //valerio.salvati START
                return loadMws({
                    filiale: filialeSet,
                    modello: modelloDiServizioSet,
                    offset: this.mwOffset,
                    pagesize: this.mwLimit,
                    exactMatch: moveToPrimaryWallet, 
                    idPortafoglio: portafoglioPrimarioId 
                }) //valerio.salvati END
                /*return loadMwList({
                    filiale: filialeSet,
                    modello: modelloDiServizioSet,
                    offset: this.mwOffset,
                    pagesize: this.mwLimit,
                    exactMatch: moveToPrimaryWallet //valerio.salvati
                })*/
                .then(result => {
    
                    try {
                        console.log('result: ' + JSON.stringify(result));

                        let newValueList = [];
                        let oldListId = this.mwList.map(item => item.Id);
                        result["mwList"].forEach(element => {
    
                            element.Referente = element.Owner.Name;
                            element.Filiale = element.PTF_Filiale__r.Name;
                            let index = oldListId.indexOf(element.Id);
                            if(index <= -1){
                                
                                newValueList.push(element);
                            }
                        });
                        console.log('newValueList: ' + JSON.stringify(newValueList));
                        this.mwList = this.mwList.concat(newValueList);
                        this.mwListCount = result["mwListCount"];
                        if(this.mwListCount > 0){
        
                            this.hasMWRows = true;
                        }else{
            
                            this.hasMWRows = false;
                        }
                        console.log('mwList: ' + JSON.stringify(this.mwList));
    
                        if(this.mwOffset < this.mwListCount && this.mwList.length == 0){
                            
                            this.mwOffset = this.mwOffset + this.mwLimit;
                            this.loadMWRecords();
                        }
                        console.log('mwList: ' + JSON.stringify(this.mwList));
                    } catch (error) {
                        
                        console.log('loadMWRecords.loadMwList.then.error: ' + error);
                    }
                })
                .catch(error => { 
                    console.log('loadMWRecords.loadMwList.error: ' + JSON.stringify(error));
                })
            }catch(error){
    
                console.log('loadMWRecords.error: ' + error);
            }
        }else{

            const toastEvent = new ShowToastEvent({
                title: "Warning!",
                message: "Selezionare almeno una tra le opzioni disponibili",
                variant: "warning"
            });
            this.dispatchEvent(toastEvent);
            return null;
        }
    }

    handleNextPressed() {
        
        try {
            
            console.log('handleNextPressed Start');
            let selectedRows = this.template.querySelector("[data-item='ndgTable']").getSelectedRows();
            this.selectedNDGs = selectedRows;

            console.log('selectedNDGs: ' + JSON.stringify(this.selectedNDGs));
            if(this.selectedNDGs.length > 0){

                this.getRelatedRecords().then(() =>{ //valerio.salvati

                    this.loadMWRecords().then(() =>{

                        this.template.querySelector("[data-item='searchedNome']").disabled = true;
                        this.template.querySelector("[data-item='searchedNDG']").disabled = true;
                        this.template.querySelector("[data-name='myButtonReset']").disabled = true;
                        this.template.querySelector("[data-name='myButtonCerca']").disabled = true;
                        let ndgTable = this.template.querySelector("[data-item='ndgTable']");
                        let selectedNdgRows = [];
                        let selectedNdgIdRows = [];
                            
                        // aggiungo alla lista degli elementi selzionati le righe nelle pagina corrente
                        if(ndgTable){
                            selectedNdgRows = ndgTable.getSelectedRows();
                        }
                        // aggiungo alla lista degli elementi selzionati le righe nelle altre pagine
                        for(let currentPage of Object.keys(this.selectRowsMapValues)){
                            if(currentPage != this.page){
                                this.selectRowsMapValues[currentPage].forEach(element =>{
                                    selectedNdgRows.push(element);
                                });
                            }
                        }
                        this.selectedNDGRows=selectedNdgRows;
                        this.selectedNDGs=selectedNdgRows;
    
                        this.showNDGs = false;
                    });
                });

                console.log('handleAssignNDGs End');
            }else{
    
                const toastEvent = new ShowToastEvent({
                    title: "Warning!",
                    message: "Selezionare uno tra le opzioni disponibili",
                    variant: "warning"
                });
                this.dispatchEvent(toastEvent);
                console.log('handleAssignNDGs End');
            } 
        } catch (error) {
            
            console.log('handleNextPressed.error: ' + error);
            console.log('handleNextPressed error: ', error);
        }
    }

    handleAssignNDGs() {
        
        try {
            console.log('handleAssignNDGs Start');
            this.clickedSalva=true;
            var mwSelected = this.template.querySelector("[data-item='mwTable']").getSelectedRows();
            this.template.querySelector("[data-name='myButtonSalva']").disabled = true;
            console.log('mwSelected: ' + JSON.stringify(mwSelected));
        
            if(mwSelected.length > 0){

                let hasOFS = false;

                for(var i=0; i< this.selectedNDGs.length; i++){
                    
                    if(this.selectedNDGs[i].PTF_OFS__c){

                        hasOFS = true;
                        break;
                    }
                }

                if(hasOFS && !mwSelected[0].Backup_Assignments__r){

                    throw 'Referente del portafoglio selezionato non abilitato a gestione OFS';
                }
                console.log('selectedNDGs: ' + JSON.stringify(this.selectedNDGs));

                //valerio.salvati
                //var ndgsIdList = this.selectedNDGRows.map(item => item.Id);
                var mainList = this.selectedNDGRows.map(item => item.Id);
                var ndgsIdList = mainList.concat(this.relatedRecords);
                console.log('this.relatedRecords: ' + JSON.stringify(this.relatedRecords));

                
                var params = {
                    ndgIds: ndgsIdList,
                    mwId: mwSelected[0].Id
                }
                executeAssignment({
                    params : JSON.stringify(params)
                }).then(data => {
                    window.location.reload();
                }).catch(error => {
                    
                    const toastEvent = new ShowToastEvent({
                        title: "Error!",
                        message: "Purtroppo l'operazione non è andata a buon fine, conatta il tuo amministratore di sistema.",
                        variant: "error"
                    });
                    this.dispatchEvent(toastEvent);
                    console.log('handleAssignNDGs.executeAssignment.error: ' + JSON.stringify(error));
                    console.log('handleAssignNDGs End');
                    this.template.querySelector("[data-name='myButtonSalva']").disabled = false;
                    this.clickedSalva=false;
                });
            } else{
    
                const toastEvent = new ShowToastEvent({
                    title: "Warning!",
                    message: "Selezionare uno tra le opzioni disponibili",
                    variant: "warning"
                });
                this.dispatchEvent(toastEvent);
                console.log('handleAssignNDGs End');
            } 
        } catch (error) {
            
            const toastEvent = new ShowToastEvent({
                title: "Warning!",
                message: error,
                variant: "warning"
            });
            this.dispatchEvent(toastEvent);
            console.log('handleAssignNDGs.error: ' + error);
            this.template.querySelector("[data-name='myButtonSalva']").disabled = false;
            this.clickedSalva=false;
        }
    }    

    handlePreviousSelected(){

        console.log('handlePreviousSelected Start');
        this.template.querySelector("[data-item='searchedNome']").disabled = false;
        this.template.querySelector("[data-item='searchedNDG']").disabled = false;
        this.template.querySelector("[data-name='myButtonReset']").disabled = false;
        this.template.querySelector("[data-name='myButtonCerca']").disabled = false;
        this.showNDGs = true;
        var selectedRows = this.selectedNDGs.map(item => item.Id);
        this.selectedNDGRows = selectedRows;
       
    }

    handleFilter(event){

        console.log('handleFilter Started');
        if(event.target.name == 'searchedNome'){
                
            this.searchedNome = event.target.value;
        }else{

            this.searchedNDG = event.target.value;
        }
        /*try {
            
            if(event.target.name == 'searchedNome'){
                
                this.searchedNome = event.target.value;
            }else{

                this.searchedNDG = event.target.value;
            }
            let table = this.template.querySelector("[data-item='ndgTable']");
            let selectedRows = [];
            if(table){

                selectedRows = this.template.querySelector("[data-item='ndgTable']").getSelectedRows();
                if(selectedRows.length > 0){

                    console.log('selectedRows: ' + JSON.stringify(selectedRows));
                    this.selectedNDGRows = selectedRows.map(item => item.Id);
                    console.log('selectedNDGRows: ' + JSON.stringify(this.selectedNDGRows));
                }
            }
            
            this.ndgOffset = 0;
            loadNdgList({
                recordId: this.recordId,
                offset: this.ndgOffset,
                pagesize: this.ndgLimit,
                name: this.searchedNome,
                ndg: this.searchedNDG
            })
            .then(result => {
                
                //this.stopLoading = true;
                console.log(JSON.stringify(result));
                this.ndgListCount = result["ndgListCount"];
                let newValueList = [];
                result["ndgList"].forEach(element => {
                    
                    let index = this.selectedNDGRows.indexOf(element.Id);
                    if(index <= -1){

                        newValueList.push(element);
                    }
                });
                this.ndgList = selectedRows.concat(newValueList);
                if(this.ndgList.length > 0){
                    
                    this.hasNDGRows = true;
                }else{

                    this.hasNDGRows = false;
                }
                console.log("this.ndgListCount: " + this.ndgListCount);
                console.log("this.ndgList: " + JSON.stringify(this.ndgList));
            })
            .catch(error => { 
                console.log('handleFilter.loadNdgList.error: ' + error);
            })
        } catch(error) {
            // invalid regex, use full list
            console.log('handleFilter.error: ' + error);
        }*/
    }

    handleReset(){

        this.searchedNome = '';
        this.searchedNDG = '';
        this.handleSearch();
    }

    handleSearch(){

        this.filteredRecords = [];
        this.page = 1;
        try {
            
            for(var i in this.ndgList){
                  
                if(Boolean(this.searchedNome)){

                    if(!this.ndgList[i].Name.toLowerCase().includes(this.searchedNome.toLowerCase().trim())){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedNDG)){

                    if(!this.ndgList[i].CRM_NDG__c.toLowerCase().includes(this.searchedNDG.toLowerCase().trim())){
    
                        continue;
                    }
                }

                this.filteredRecords.push(this.ndgList[i]);
            }
    
            
           
            this.setPages(this.filteredRecords);
        } catch (error) {
            
            console.log('DK error: ' + error);
        }
    }

    //Pagination
    @track page = 1;
    perpage = 15;
    @track pages = [];
    set_size = 15;
    
    // creata mappa che contiene per ogni pagina i valori selezionati
    // NOTE:  per far si che le righe siano selezionate bisogna evitare di usare la funzione push per aggiornare la lista, bisogna assegnarli una lista nuova
    @track selectRowsMap = {};
    @track selectRowsMapValues = {};
    @track selectedNDGRows = [];
    handleAvanti(){
        try {
            let selectedRows = this.template.querySelector("[data-item='ndgTable']").getSelectedRows();
            let selectedRowIds = selectedRows.map(element => element.Id);
            this.selectRowsMapValues[this.page] = selectedRows;
            this.selectRowsMap[this.page] = selectedRowIds;
            this.selectedNDGRows = Boolean(this.selectRowsMap[this.page+1]) ? this.selectRowsMap[this.page+1] : [];
            ++this.page;
        } catch (error) {
            console.log('error: ', error);
        }
    }
    handleIndietro(){
        
        let selectedRows = this.template.querySelector("[data-item='ndgTable']").getSelectedRows();
        let selectedRowIds = selectedRows.map(element => element.Id);
        this.selectRowsMap[this.page] = selectedRowIds;
        this.selectRowsMapValues[this.page] = selectedRows;
        this.selectedNDGRows = this.selectRowsMap[this.page -1];
        --this.page;
    }

    /*loadMWjs(filialeSet, modelloDiServizioSet, moveToPrimaryWallet, portafoglioPrimarioId){

        if(!moveToPrimaryWallet){
            return loadMwList({
                filiale: filialeSet,
                modello: modelloDiServizioSet,
                offset: this.mwOffset,
                pagesize: this.mwLimit
            });
        }else{
            return loadPortafoglioPrimario({
                idPortafoglio : portafoglioPrimarioId
            });
        }
    }*/
    
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
        let recordToDisplay = this.filteredRecords.slice(startIndex,endIndex);
        //let recordToDisplayIdList = recordToDisplay.map(item => item.Id);
        return recordToDisplay;
    }

    setPages = (data)=>{
        this.pages = [];
        let numberOfPages = Math.ceil(data.length / this.defaultLimit);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
    }  
    
    get disabledButtonIndietro(){
        return this.page === 1;
    }
    
    get disabledButtonAvanti(){
        return this.page === this.pages.length || this.filteredRecords.length === 0
    }

    

    get currentPageData(){
        return this.pageData();
    }
    //Pagination

    //valerio.salvati
    getRelatedRecords(){
        this.mwError = false;
        this.listaCointestazioni = [];
        this.listaPF = [];
        this.listaCointestazioniId = [];
        this.listaPfId = [];
        this.pfCorrelate = []; //record cointestazione legati alle persone fisiche
        this.cointestazioniCorrelate = []; //record pf legati alle cointestazioni

        let listaCointestazioniId = [];
        let listaPFId = [];
        let listaCointestazioni = [];
        let listaPF = [];
        let relatedRecords = [];

        for(let currentRow of this.selectedNDGs){
            console.log('getRelatedRecords - currentRow natura giuridica: ', currentRow.PTF_NaturaGiuridica__c);
            if('CO' == currentRow.PTF_NaturaGiuridica__c){
                listaCointestazioniId.push(currentRow.Id);
                listaCointestazioni.push(currentRow);
            }
            if('PF' == currentRow.PTF_NaturaGiuridica__c){
                listaPFId.push(currentRow.Id);
                listaPF.push(currentRow);
            }
        }
        console.log('getRelatedRecords - listaCointestazioniId: ', listaCointestazioniId);
        console.log('getRelatedRecords -listaPFId: ', listaPFId);

        this.listaCointestazioni = listaCointestazioni;
        this.listaPF = listaPF;
        this.listaCointestazioniId = listaCointestazioniId;
        this.listaPfId = listaPFId;

        if(listaPFId.length > 0 || listaCointestazioniId.length > 0){

            return loadRelatedRecords({
                personeFisiche: listaPFId,
                cointestazioni: listaCointestazioniId
            })
            .then(result => {
                let errorFound = false;
                console.log('loadRelatedRecords result: ', result);
                console.log('pfCorrelate: ', result["pfCorrelate"]);
                console.log('cointestazioniCorrelate: ', result["cointestazioniCorrelate"]);

                result["pfCorrelate"].forEach(element => {
                    relatedRecords.push(element.CRM_Account__c);
                    this.pfCorrelate.push(element);
                    if(!errorFound){
                        for(let currentCointestazione of this.listaCointestazioni){
                            if(!errorFound && currentCointestazione.Id == element.CRM_JointOwnership__c && currentCointestazione.PTF_Portafoglio__r.Name != element.CRM_Account__r.PTF_Portafoglio__r.Name) {
                                errorFound = true;
                            }
                        }
                    }
                });
                result["cointestazioniCorrelate"].forEach(element => {
                    relatedRecords.push(element.CRM_JointOwnership__c);
                    this.cointestazioniCorrelate.push(element);
                    if(!errorFound){
                        for(let currentPF of this.listaPF){
                            if(!errorFound && currentPF.Id == element.CRM_Account__c && currentPF.PTF_Portafoglio__r.Name != element.CRM_JointOwnership__r.PTF_Portafoglio__r.Name) {
                                errorFound = true;
                                break;
                            }
                        }
                    }

                });
                console.log('mwError: ' + errorFound);

                this.mwError = errorFound;
                this.relatedRecords = relatedRecords;

            });
        }


    }
}