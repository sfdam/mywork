import { LightningElement,track, api, wire } from 'lwc';
import getUserInfo from '@salesforce/apex/SV_Utilities.getUserInfo';
import getNDG from '@salesforce/apex/NucleiAppartenenzaController.crm_GetNDG';
import getNDGAppartenenza from '@salesforce/apex/NucleiAppartenenzaController.crm_GetNDGAppartenenza';
import loadNdgList from '@salesforce/apex/NucleiAppartenenzaController.crm_LoadNdgList';
import assignToNucleo from '@salesforce/apex/NucleiAppartenenzaController.assignToNucleo';

// import NDG from '@salesforce/label/c.nucleiAppartenenza_CLM_Ndg';
// import Nominativo from '@salesforce/label/c.nucleiAppartenenza_CLM_Nominativo';
// import Caponucleo from '@salesforce/label/c.nucleiAppartenenza_CLM_Caponucleo';
// import NaturaGiuridica from '@salesforce/label/c.nucleiAppartenenza_CLM_NaturaGiuridica';
// import GruppoGestionale from '@salesforce/label/c.nucleiAppartenenza_CLM_GruppoGestionale';
// import Filiale from '@salesforce/label/c.nucleiAppartenenza_CLM_Filiale';
// import ModelloServizio from '@salesforce/label/c.nucleiAppartenenza_CLM_ModelloServizio';
// import MicroPortafoglio from '@salesforce/label/c.nucleiAppartenenza_CLM_MicroPortafoglio';
// import Privati from '@salesforce/label/c.nucleiAppartenenza_CLM_Privati';



const columns = [
    { label: 'NDG', fieldName: 'PTF_Url', type: 'url',
        typeAttributes: {
            label: { fieldName: 'CRM_NDG__c' }
        },
        initialWidth: 110,
        hideDefaultActions: "true"},
    { label: 'NOME', fieldName: 'Name', type: 'text', hideDefaultActions: "true", cellAttributes:{class:{fieldName: 'typeCSSClass' }},initialWidth: 180,},
    { label: 'CAPONUCLEO', fieldName: '', type: 'Boolean', hideDefaultActions: "true", cellAttributes: {
        iconName: { fieldName: 'PTF_IsCaponucleoIcon' },
        iconPosition: 'left'
    },initialWidth: 180,},
    {
        type: 'text',
        fieldName: 'PTF_StatoCRMFull__c',
        label: 'STATO CRM',
        initialWidth: 120,
    },
    { label: 'NATURA GIURIDICA', fieldName: 'PTF_NaturaGiuridica__c', type: 'text', hideDefaultActions: "true",initialWidth: 180,},
    {
        type: 'text',
        fieldName: 'ModelloDiServizio__c',
        label: 'M-MDS',
        initialWidth: 140,
    },
    { label: 'GRUPPO GESTIONALE', fieldName: 'PTF_GruppoComportamentale__c', type: 'text', hideDefaultActions: "true",initialWidth: 180,}
];

export default class Crm_nucleiAppartenenza extends LightningElement {
    @api userInfo;
    @api profiliAutorizzati;

    @track isRendered;
    @track isViewAll = false;
    @track columns = columns;
    @track data = [];
    @track allData = [];
    @api recordId;
    @track number = '0';
    @track numberAll = 0;
    @track offsetFirst=0;
    @track pageSizeFirst=15;
    @api isAggiungi;
    @api listViewFirst;
    @api getSelectedDataFirst;
    @track isFamilyOrPersonal= false;
    @track isGestore = false;


    columnsAggiungi = [
        { label: 'NDG', fieldName: 'PTF_Url', type: 'url', typeAttributes: {label: { fieldName: 'CRM_NDG__c' }} },
        { label: 'NOME', fieldName: 'Name', type: 'text' },
        { label: 'CAPONUCLEO', fieldName: '', type: 'Boolean',cellAttributes: {
            iconName: { fieldName: 'PTF_IsCaponucleoIcon' },
            iconPosition: 'left'
        }},
        { label: 'FILIALE', fieldName: 'PTF_FilialeName', type: 'text' },
        { label: 'MODELLO DI SERVIZIO', fieldName: 'ModelloDiServizio__c', type: 'text' },
        { label: 'PORTAFOGLIO', fieldName: 'PTF_MPUrl', type: 'url', typeAttributes: {label: { fieldName: 'PTF_PortafoglioName' }}},
        {
            type: 'text',
            fieldName: 'PTF_StatoCRMFull__c',
            label: 'STATO CRM',
        },
        { label: 'NATURA GIURIDICA', fieldName: 'PTF_NaturaGiuridica__c', type: 'text' },
        {
            type: 'text',
            fieldName: 'ModelloDiServizio__c',
            label: 'M-MDS',
        },
        {
            type: 'text',
            fieldName: 'CRM_CrossSelling__c',
            label: 'CS',
        },
        {
            type: 'text',
            fieldName: 'CRM_MargineIntermediazione__c',
            label: 'MINTER',
        },
        {
            type: 'text',
            fieldName: 'CRM_ProdottoBancarioLordo__c',
            label: 'PBL',
        }
        
    ];

    options = [
        { label: 'PRIVATI', value: 'Privati' },
        { label: 'NDG', value: 'NDG' }

    ];

    //new
    @track currentAccount;
    @track portafoglio;
    @track primarioId;
    @api ndgList = [];
    @track selectedNDGRows = [];
    @track ndgListCount;
    @track ndgOffset = 0;
    @track ndgLimit = 5;
    @track searchedNome;
    @track searchedCognome;
    @track searchedNDG;
    @track tableTarget = {};

    connectedCallback() {
        this.isRendered = false;
        getUserInfo()
        .then(result => {
            console.log('SV getUserInfo result1111', result);

            this.userInfo = result;
            if(this.profiliAutorizzati && this.profiliAutorizzati.includes(result.Profile.Name)){
                this.profiloAutorizzatoShow = true;
            } else {
                this.profiloAutorizzatoShow = false;
            }
            console.log('SV profiloAutorizzatoShow', this.profiloAutorizzatoShow);

            return getNDG({recordId:this.recordId});
        })
        .then(result => {
            console.log('SV getNDG result 2222', result);

            this.currentAccount = result['account'];
            this.portafoglio = result['portafoglio'];
            this.primarioId = result['primario'] != null ? result['primario'].PTF_Gestore__c : null;

            if(this.currentAccount.ModelloDiServizio__c==='Family' || this.currentAccount.ModelloDiServizio__c==='Personal'){
                this.isFamilyOrPersonal=true;
            }

            if(this.profiloAutorizzatoShow){
                this.isGestore=true;
            } else {
                if(result['primario'] != null && result['primario'].hasOwnProperty('PTF_Gestore__r') && result['primario'].PTF_Gestore__r.hasOwnProperty('PTF_User__c') && result['primario'].PTF_Gestore__r.PTF_User__c === this.userInfo.Id){
                    this.isGestore=true;
                }
            }
            
            let dataTableGlobalStyle = document.createElement('style');
            dataTableGlobalStyle.innerHTML = `
            .caponucleo-green {
                font-weight: bold;
                color: green;
            }
            .slds-text-heading_small.slds-truncate{
                width: 100%;
            }
                                        `;
            document.head.appendChild(dataTableGlobalStyle);
            console.log('before get data apex');
            if (this.currentAccount.PTF_Nucleo__c!=undefined) {
                getNDGAppartenenza({nucleoId:this.currentAccount.PTF_Nucleo__c, currentAccountId:this.currentAccount.Id}).then(ndgs=>{
                    this.isRendered = true;
                    for (var i=0; i<ndgs.length; i++) {
                        ndgs[i].PTF_Url = '/'+ndgs[i].Id;
                        if (ndgs[i].PTF_Caponucleo__c) {
                            ndgs[i].PTF_IsCaponucleoIcon = 'utility:check';
                        }
                        if (ndgs[i].CRM_NDG__c==undefined) {
                            ndgs[i].CRM_NDG__c = 'N/A';
                        }
                        if (ndgs[i].Id === this.recordId) {
                            ndgs[i].typeCSSClass = 'caponucleo-green';
                        }
                    }
                    this.allData = ndgs;
                    this.number = ndgs.length;
                    if (ndgs.legth>5) {
                        for (var i=0; i<5; i++) {
                            this.data.push(ndgs[i]);
                        }
                    }
                    else {
                        this.data = ndgs;
                    }
                }).catch(error=>{
                    this.isRendered = true;
                    console.log(error);
                });
            }
            else {
                this.isRendered = true;
            }
        }).catch(error=>{
            this.isRendered = true;
            console.log(error);
        });
    }

    get dataLoaded(){
        return this.data.length > 0;
    }

    get dataLoadedViewAll(){
        return this.data.length > 5;
    }

    handleViewAll() {
        this.isViewAll = true;
        this.numberAll = this.allData.length;
    }
    closeModal() {
        this.isViewAll = false; 
    }
    openModalAggiungi(){
        this.isRendered=false;
        this.loadNDGRecords();
    }
     
    closeModalAggiungi(){
        this.isAggiungi=false;
    }


    // NEW --------------------------------------------------------------------------
    loadMoreNDGData(event){

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
    }

    loadNDGRecords(){
        
        try{
            console.log('DK this.primario: ' + this.primarioId);
            console.log('DK this.currentAccount.PTF_Nucleo__c: ' + this.currentAccount.PTF_Nucleo__c);
            return loadNdgList({
                portafoglioId: this.currentAccount.PTF_Portafoglio__c,
                primarioId: this.primarioId,
                accountMDS: this.currentAccount.ModelloDiServizio__c,
                nucleoId: this.currentAccount.PTF_Nucleo__c,
                offset: this.ndgOffset,
                pagesize: this.ndgLimit,
                nome: this.searchedNome,
                cognome: this.searchedCognome,
                ndg: this.searchedNDG
            })
            .then(result => {

                this.ndgListCount = result["ndgListCount"];
                
                let ndgIdList = this.ndgList.map(item => item.Id);
                let newValueList = [];
                result["ndgList"].forEach(element => {
                    
                    element.PTF_Url = '/' + element.Id;
                    console.log('DK element.PTF_Portafoglio__r.Name: ' + element.PTF_Portafoglio__r.Name);
                    element.PTF_PortafoglioName = element.PTF_Portafoglio__r.Name;
                    if(Boolean(element.PTF_Filiale__c)){

                        element.PTF_FilialeName = element.PTF_Filiale__r.Name;
                    }
                    if (element.PTF_Caponucleo__c) {
                        element.PTF_IsCaponucleoIcon = 'utility:check';
                    }
                    element.PTF_MPUrl = '/' + element.PTF_Portafoglio__c;
                    let index = ndgIdList.indexOf(element.Id);
                    if(index <= -1){

                        newValueList.push(element);
                    }
                });
                this.ndgList = this.ndgList.concat(newValueList);
                console.log('ndgList: ' + JSON.stringify(this.ndgList));
                this.isAggiungi=true;

                this.isRendered = true;
            })
            .catch(error => { 
                console.log('loadNDGRecords.loadNdgList.error: ' + JSON.stringify(error));
            })
        }catch(error){

            console.log('loadNDGRecords.error: ' + error);
        }
    }

    handleFilter(event){

        console.log('handleFilter Started');
        
        try {
            
            if(event.target.name == 'searchedNome'){
                
                this.searchedNome = event.target.value;
            }else if(event.target.name == 'searchedCognome'){

                this.searchedCognome = event.target.value;
            }else if(event.target.name == 'searchedNDG'){

                this.searchedNDG = event.target.value;
            }
            
        } catch(error) {
            // invalid regex, use full list
            console.log('handleFilter.error: ' + error);
        }
    }

    handleSearch(){

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
            portafoglioId: this.currentAccount.PTF_Portafoglio__c,
            primarioId: this.primarioId,
            accountMDS: this.currentAccount.ModelloDiServizio__c,
            nucleoId: this.currentAccount.PTF_Nucleo__c,
            offset: this.ndgOffset,
            pagesize: this.ndgLimit,
            nome: this.searchedNome,
            cognome: this.searchedCognome,
            ndg: this.searchedNDG
        })
        .then(result => {
            
            //this.stopLoading = true;
            console.log(JSON.stringify(result));
            this.ndgListCount = result["ndgListCount"];
            let newValueList = [];
            result["ndgList"].forEach(element => {
                
                element.PTF_Url = '/' + element.Id;
                console.log('DK element.PTF_Portafoglio__r.Name: ' + element.PTF_Portafoglio__r.Name);
                element.PTF_PortafoglioName = element.PTF_Portafoglio__r.Name;
                if(Boolean(element.PTF_Filiale__c)){

                    element.PTF_FilialeName = element.PTF_Filiale__r.Name;
                }
                if (element.PTF_Caponucleo__c) {
                    element.PTF_IsCaponucleoIcon = 'utility:check';
                }
                element.PTF_MPUrl = '/' + element.PTF_Portafoglio__c;
                let index = this.selectedNDGRows.indexOf(element.Id);
                if(index <= -1){

                    newValueList.push(element);
                }
            });
            this.ndgList = selectedRows.concat(newValueList);
            console.log("this.ndgListCount: " + this.ndgListCount);
            console.log("this.ndgList: " + JSON.stringify(this.ndgList));
        })
        .catch(error => { 
            console.log('handleFilter.loadNdgList.error: ' + error);
        });
    }

    handleAssignToNucleo(){
        
        var newThis = this;
        console.log('handleAssignToNucleo Start');
        let selectedRows = newThis.template.querySelector("[data-item='ndgTable']").getSelectedRows();
        if(selectedRows.length > 0){
            
            let selectedRowIdList = selectedRows.map(item => item.Id);
            console.log('DK selectedRowIdList: ' + JSON.stringify(selectedRowIdList));
            assignToNucleo({
                nucleoId: newThis.currentAccount.PTF_Nucleo__c,
                accountIdList: selectedRowIdList
            }).then(function(){
                
                newThis.closeModalAggiungi();
                newThis.connectedCallback();
            }).catch(error =>{

                console.log('DK handleAssignToNucleo.assignToNucleo.error: ' + error);
            });
        }else{

            const toastEvent = new ShowToastEvent({
                title: 'Warning!',
                message: 'Selezionare almeno uno tra le opzioni disponibili',
                variant: 'warning'
            });
            this.dispatchEvent(toastEvent);
        }
        console.log('handleAssignToNucleo End');
    }
}