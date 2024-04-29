/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api, track, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getNDG from '@salesforce/apex/CreateDoppioPresidioController.getNDG';
import getContactRoleFinanziario from '@salesforce/apex/CreateDoppioPresidioController.getContactRoleFinanziario';
import getDoppioPresidio from '@salesforce/apex/CreateDoppioPresidioController.getDoppioPresidio';
import deleteDoppioPresidio from '@salesforce/apex/CreateDoppioPresidioController.deleteDoppioPresidio';
import creaDoppioPresidioFinanziario from '@salesforce/apex/CreateDoppioPresidioController.creaDoppioPresidioFinanziario';
import { NavigationMixin } from 'lightning/navigation';

import Nominativo from '@salesforce/label/c.doppioPresidioFinanziario_CLM_Nominativo';
import Matricola from '@salesforce/label/c.doppioPresidioFinanziario_CLM_Matricola';
import TipologiaRuolo from '@salesforce/label/c.doppioPresidioFinanziario_CLM_TipologiaRuolo';
import UnitaOrganizzativa from '@salesforce/label/c.doppioPresidioFinanziario_CLM_UnitaOrganizzativa';
import Referente from '@salesforce/label/c.doppioPresidioFinanziario_CLM_Referente';
import Email from '@salesforce/label/c.doppioPresidioFinanziario_CLM_Email';
import Ruolo from '@salesforce/label/c.doppioPresidioFinanziario_CLM_Ruolo';

const columns = [
    {label:Nominativo,fieldName:"Name", type:"text", hideDefaultActions: "true"},
    {label:Matricola,fieldName:"PTF_RegistrationNumber__c", type:"text", hideDefaultActions: "true"},
    {label:TipologiaRuolo,fieldName:"Ruolo", type:"text", hideDefaultActions: "true"},
    {label:UnitaOrganizzativa,fieldName:"PTF_UnitaOrganizzativa__c", type:"text", hideDefaultActions: "true"}
];

const columnsDoppioPresidio = [
    {label:Referente,fieldName:"Name", type:"text", hideDefaultActions: "true"},
    {label:Matricola,fieldName:"RegistrationNumber", type:"text", hideDefaultActions: "true"},
    {label:Email,fieldName:"Email", type:"text", hideDefaultActions: "true"},
    {label:Ruolo,fieldName:"Role", type:"text", hideDefaultActions: "true"},
    {label:UnitaOrganizzativa,fieldName:"Unita", type:"text", hideDefaultActions: "true"}
];

export default class DoppioPresidioFinanziario extends NavigationMixin(LightningElement) {
    @api modelliDiServizio;
    @track modelli;
    @api recordId;
    @track error;
    @track openmodal = false;
    @track columns = columns;
    @track columnsDoppioPresidio = columnsDoppioPresidio;
    @track data = [];
    @track dataAll = [];
    @track retValue;
    @track ndgLimit = 5;
    @track ndgOffset = 0;
    @track listCount;
    @track tableTarget = {};
    @track oldvalue=[];
    @track oldIdList=[];
    @track searchedNominativo;
    @track searchedMatricola;
    @track searchedTipologia;
    @api selectedRows;
    @track isRendered;
    @track showButton;
    @track referentiList=[];
    @api doppioPresidioList=[];
    @api notEmptyListDoppioPresidioAssegnato = false;
    @api title;

    connectedCallback(){
        if(this.modelliDiServizio!=null){
            this.modelli=this.modelliDiServizio.split(',');
        }

        getDoppioPresidio({recordId:this.recordId}).then(result=>{
            
            console.log('SV getDoppioPresidio', result);
            this.doppioPresidioList = this.setObjectForDatatable(result);

            if(result.length>0){
                this.notEmptyListDoppioPresidioAssegnato = true;
            } else {
                this.notEmptyListDoppioPresidioAssegnato = false;
            }
        });
        
        getContactRoleFinanziario({recordId:this.recordId}).then(result=>{
            this.isRendered=true;
            if (result==false){
                this.showButton=false;
            }
            else{
                this.showButton=true;
            }
            
        });
        
    }
    
    loadNDGRecords(){
        return getNDG({recId: this.recordId, nominativo:this.searchedNominativo, matricola:this.searchedMatricola, tipologia:this.searchedTipologia, modelli:this.modelli})
        .then(result => {
            let oldIdList = this.data.map(item => item.Id);
            let newValueList =[];
            this.retValue = result;
            for (var i=0; i<this.retValue.consulentiFinanziari.length; i++) {
                if (this.retValue.consulentiFinanziari[i].PTF_TipologiaRuolo__c!=undefined && this.retValue.consulentiFinanziari[i].PTF_TipologiaRuolo__r.Name!=undefined) {
                    this.retValue.consulentiFinanziari[i].Ruolo = this.retValue.consulentiFinanziari[i].PTF_TipologiaRuolo__r.Name;
                }
                let index = oldIdList.indexOf(this.retValue.consulentiFinanziari[i].Id);
                if(index <= -1){

                   if(this.doppioPresidioList.length==0 || this.retValue.consulentiFinanziari[i].Id!==this.doppioPresidioList[0].PTF_Gestore__c){
                        newValueList.push(this.retValue.consulentiFinanziari[i]);
                    }
                }
            }
            this.data = this.data.concat(newValueList);
            this.setPages(this.data);
            this.listCount=this.data.length;
            this.dataAll=this.data;
            
        }).catch(error=>{
            this.error = error;
            this.openmodal=false;
            console.log('EDB ERROR', error);
            const x = new ShowToastEvent({
                "title": "Errore!",
                "variant": "error",
                "message": this.error.body.message
            });
            this.dispatchEvent(x);
        });
    }

    openModal() {
        this.openmodal = true;
        
        this.loadNDGRecords();
        
    }

    /*loadMoreNDGData(event){

        try {
            this.tableTarget = event;
            if(this.listCount > this.ndgOffset){
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

    closeModal() {
        this.openmodal = false;
        this.searchedNominativo='';
        this.searchedMatricola='';
        this.searchedTipologia='';
        this.ndgOffset=0;
        this.data=[];

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Account', // objectApiName is optional
                actionName: 'view'
            }
        });
    }

    creaDoppioPresidioFinanziario(event) {
        if(this.notEmptyListDoppioPresidioAssegnato){
            const x = new ShowToastEvent({
                "title": "Errore!",
                "variant": "error",
                "message": "Eliminare il Consulente Finanziario già assegnato"
            });
            this.dispatchEvent(x);
        }
        else{
            creaDoppioPresidioFinanziario({ recId : this.recordId,contId:this.selectedRows[0]}).then(result=>{
                const x = new ShowToastEvent({
                    "title": "Successo!",
                    "variant": "success",
                    //"message": "consulente finanziario aggiunto con successo"
                    "message": "Referente doppio presidio aggiunto con successo"
                });
                this.dispatchEvent(x);
                this.closeModal();
                
            }).catch(error=>{
                this.error = error;
                console.log('EDB ERROR', error);
                const x = new ShowToastEvent({
                    "title": "Errore!",
                    "variant": "error",
                    "message": this.error.body.message
                });
                this.dispatchEvent(x);
                this.closeModal();
            });
        }
        
    }

    handleFilter(event){
        try {
            
            if(event.target.name == 'searchedNominativo'){
                this.searchedNominativo = event.target.value;

            }else if(event.target.name == 'searchedMatricola'){
                this.searchedMatricola = event.target.value;

            }else if(event.target.name == 'searchedTipologia'){
                this.searchedTipologia = event.detail.value;
            }
        
            
        } catch(error) {
            // invalid regex, use full list
            console.log('handleFilter.error: ' + error);
        }
    }

    getSelectedRows(event){
        let selectedR = event.detail.selectedRows;
        // Display that fieldName of the selected rows
        let rows = [];
        for (let i = 0; i < selectedR.length; i++){
            rows.push(selectedR[i].Id);
        }

        this.selectedRows = rows;
    }
    @track filteredReferentiList=[];
    handleSearch(){
        this.filteredReferentiList = [];
        this.referentiList=this.dataAll;
        this.page = 1;
        try {
            for(var i in this.referentiList){   
                if(Boolean(this.searchedNominativo)){
                    if(!this.referentiList[i].Name.toLowerCase().includes(this.searchedNominativo.toLowerCase())){
                        continue;
                    }
                }
                if(Boolean(this.searchedMatricola)){
                    if(!this.referentiList[i].PTF_RegistrationNumber__c.toLowerCase().includes(this.searchedMatricola.toLowerCase())){
                        continue;
                    }
                }
                if(Boolean(this.searchedTipologia)){
                    if(!this.referentiList[i].PTF_UnitaOrganizzativa__c.toLowerCase().includes(this.searchedTipologia.toLowerCase())){
                        continue;
                    }
                }
                this.filteredReferentiList.push(this.referentiList[i]);
            }
            this.data=this.filteredReferentiList;
            this.setPages(this.filteredReferentiList);
        } catch (error) {
            console.log('MC error: ' + error);
        }
    }
    handleReset(){
        this.searchedNominativo='';
        this.searchedMatricola='';
        this.searchedTipologia='';
        this.selectedRows=[];
        this.data=this.dataAll;
        this.setPages(this.data);
    }

    /*handleSearch(event){
        this.ndgOffset=0;
        this.data=[];
        console.log('MC searchMatricola',this.searchedMatricola);
        getNDG({recId: this.recordId, nominativo:this.searchedNominativo, matricola:this.searchedMatricola, tipologia:this.searchedTipologia,  modelli:this.modelli})
        .then(result => {
            this.retValue = result;
            for (var i=0; i<this.retValue.consulentiFinanziari.length; i++) {
                if (this.retValue.consulentiFinanziari[i].PTF_TipologiaRuolo__c!=undefined && this.retValue.consulentiFinanziari[i].PTF_TipologiaRuolo__r.Name!=undefined) {
                    this.retValue.consulentiFinanziari[i].Ruolo = this.retValue.consulentiFinanziari[i].PTF_TipologiaRuolo__r.Name;
                }
            }
            this.data = this.retValue.consulentiFinanziari;
            this.setPages(this.retValue.consulentiFinanziari);
            this.page=1;
            this.listCount=this.retValue.consulentiFinanziari.length;
        });

    }*/

    deleteDoppioPresidioAssegnato(event){

        let doppioPresidioTable = this.template.querySelector('[data-item="doppioPresidioTable"]');
        let doppioPresidioToDelete = doppioPresidioTable.getSelectedRows();

        if (doppioPresidioToDelete.length > 0) {
            let idsToDelete = doppioPresidioToDelete.map(item => item.Id);
            deleteDoppioPresidio({idDPList: idsToDelete})
            .then(result => {
                console.log('SV result ', JSON.stringify(result));

                this.doppioPresidioList = this.setObjectForDatatable(result);

                if(result.length>0){
                    this.notEmptyListDoppioPresidioAssegnato = true;
                } else {
                    this.notEmptyListDoppioPresidioAssegnato = false;
                }

                const toastEvent = new ShowToastEvent({
                    title: "Successo!",
                    //message: "Consulente Finanziario eliminato con successo!!",
                    message: "Referente doppio presidio eliminato con successo!", 
                    variant: "success"
                });
                this.dispatchEvent(toastEvent);

            }).catch(error => {

                console.log('deleteDoppioPresidio: ' + JSON.stringify(error));
            });

        }


        if(this.doppioPresidioList.length === 0) this.notEmptyListDoppioPresidioAssegnato = true;
    }

    setObjectForDatatable(result){

        let tempData=[];
                result.forEach(element =>{
                    
                    if(element.hasOwnProperty('PTF_Gestore__r') && element.PTF_Gestore__r.hasOwnProperty('Name')){
                        element.Name=element.PTF_Gestore__r.Name;
                    }
                    
                    if(element.hasOwnProperty('PTF_Gestore__r') && element.PTF_Gestore__r.hasOwnProperty('PTF_RegistrationNumber__c')){
                        element.RegistrationNumber=element.PTF_Gestore__r.PTF_RegistrationNumber__c;
                    }

                    if(element.hasOwnProperty('PTF_Gestore__r') && element.PTF_Gestore__r.hasOwnProperty('PTF_Gestore__r.Email')){
                        element.Email=element.PTF_Gestore__r.Email;
                    }

                    if(element.hasOwnProperty('PTF_Gestore__r') && element.PTF_Gestore__r.hasOwnProperty('PTF_TipologiaRuolo__r') && element.PTF_Gestore__r.PTF_TipologiaRuolo__r.hasOwnProperty('Name')){
                        element.Role=element.PTF_Gestore__r.PTF_TipologiaRuolo__r.Name;
                    }

                    if(element.hasOwnProperty('PTF_Gestore__r') && element.PTF_Gestore__r.hasOwnProperty('PTF_Gestore__r.PTF_UnitaOrganizzativa__c')){
                        element.Unita=element.PTF_Gestore__r.PTF_UnitaOrganizzativa__c;
                    }
                      
                    tempData.push(element);
               });

        return tempData;
    }

    //Test Pagination
    @track page = 1;
    perpage = 100;
    @track pages = [];
    set_size = 100;
    

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
          return this.data.slice(startIndex,endIndex);
       }
  
      setPages = (data)=>{
          this.pages=[];
          let numberOfPages = Math.ceil(data.length / this.perpage);
          for (let index = 1; index <= numberOfPages; index++) {
              this.pages.push(index);
          }
          /*console.log(this.pages);
          console.log(this.pages.length)
          console.log(this.page);
          console.log(this.page === this.pages.length);*/
       }  
      
      get disabledButtonIndietro(){
          return this.page === 1;
      }
      
      get disabledButtonAvanti(){
          return this.page === this.pages.length
      }
  
      get options() {
        return [
            { label: 'Key Client Privati', value: 'Key Client Privati' },
            { label: 'Private', value: 'Private' },
            { label: 'Consulenti Finanziari', value: 'Consulenti Finanziari' }
        ];
    }
  
      get currentPageData(){
          return this.pageData();
      }
  
  
    //Test Pagination
}