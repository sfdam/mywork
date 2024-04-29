import { LightningElement, api, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getDoppioPresidio from '@salesforce/apex/CreateDoppioPresidioController.getDoppioPresidioSviluppo';
import getUserInfo from '@salesforce/apex/SV_Utilities.getUserInfo';
import getNDGSviluppo from '@salesforce/apex/CreateDoppioPresidioController.getNDGSviluppo';
import creazioneDoppioPresidioEstero from '@salesforce/apex/CreateDoppioPresidioController.creazioneDoppioPresidioSviluppo';
import deleteDoppioPresidioEstero from '@salesforce/apex/CreateDoppioPresidioController.deleteDoppioPresidioSviluppo';



import Nominativo from '@salesforce/label/c.doppioPresidioEstero_CLM_Nominativo';
import Matricola from '@salesforce/label/c.doppioPresidioEstero_CLM_Matricola';
import TipologiaRuolo from '@salesforce/label/c.doppioPresidioEstero_CLM_TipologiaRuolo';
import UnitaOrganizzativa from '@salesforce/label/c.doppioPresidioEstero_CLM_UnitaOrganizzativa';


const columns = [
    {label:Nominativo,fieldName:"Name", type:"text", hideDefaultActions: "true"},
    {label:Matricola,fieldName:"PTF_RegistrationNumber__c", type:"text", hideDefaultActions: "true"},
    {label:TipologiaRuolo,fieldName:"Ruolo", type:"text", hideDefaultActions: "true"},
    {label:UnitaOrganizzativa,fieldName:"PTF_UnitaOrganizzativa__c", type:"text", hideDefaultActions: "true"}
];

const columnsDoppioPresidioEstero = [
    {label:Nominativo,fieldName:"Name", type:"text", hideDefaultActions: "true"},
    {label:Matricola,fieldName:"RegistrationNumber", type:"text", hideDefaultActions: "true"},
    {label:TipologiaRuolo,fieldName:"Ruolo", type:"text", hideDefaultActions: "true"},
    {label:UnitaOrganizzativa,fieldName:"UnitaOrganizzativa", type:"text", hideDefaultActions: "true"}
];

export default class DoppioPresidioEstero  extends NavigationMixin (LightningElement) {

    @api recordId;
    @api title;
    @api userInfo;
    @api modelliDiServizio
    @api doppioPresidioListSviluppo=[];
    @api notEmptyListDoppioPresidioAssegnato = false;
    @api notEmptyPrincipale = false;
    @api notEmptyBackup = false;
    @api selectedRows;
    @api selectedRowsToDelete;
    @track openmodal = false;
    @track isRendered;
    @track columns = columns;
    @track searchedNominativo;
    @track searchedMatricola;
    @track ndgLimit = 5;
    @track ndgOffset = 0;
    @track data = [];
    @track columnsDoppioPresidioEstero = columnsDoppioPresidioEstero;


    connectedCallback(){

        this.isRendered=true;
        if(this.modelliDiServizio!=null){
            this.modelli=this.modelliDiServizio.split(',');   
        }
        getUserInfo()
            .then(result => {

                this.userInfo = result;

            return getDoppioPresidio({recordId:this.recordId})
            })
            .then(result=>{
            
                console.log('GB getDoppioPresidioSvil', result);
                this.doppioPresidioListSviluppo = this.setObjectForDatatable(result);
                

                if(result.length>0){
                    this.notEmptyListDoppioPresidioAssegnato = true;
                } else {
                    this.notEmptyListDoppioPresidioAssegnato = false;
                }
            });    
    }

    loadNDGRecords(){
        return getNDGSviluppo({recId: this.recordId, nominativo:this.searchedNominativo, matricola:this.searchedMatricola, modelli:this.modelli})
        .then(result => {
            let oldIdList = this.data.map(item => item.Id);
            let newValueList =[];
            console.log('lista referenti Sviluppo',result);
            this.retValue = result;
            console.log('lista referenti referenti Sviluppo',this.retValue.consulentiSviluppo.length);
            for (var i=0; i<this.retValue.consulentiSviluppo.length; i++) {
                console.log('lista referenti Sviluppo',this.retValue.consulentiSviluppo[i].PTF_TipologiaRuolo__r);
                console.log('lista referenti Sviluppo',this.retValue.consulentiSviluppo[i].PTF_TipologiaRuolo__r.Name);
                if (this.retValue.consulentiSviluppo[i].PTF_TipologiaRuolo__r!=undefined && this.retValue.consulentiSviluppo[i].PTF_TipologiaRuolo__r.Name!=undefined) {
                    this.retValue.consulentiSviluppo[i].Ruolo = this.retValue.consulentiSviluppo[i].PTF_TipologiaRuolo__r.Name;
                }
                console.log('lista referenti Sviluppo 2',this.retValue.consulentiSviluppo[i].Id);
                let index = oldIdList.indexOf(this.retValue.consulentiSviluppo[i].Id);
                console.log('lista referenti Sviluppo 3',this.retValue.consulentiSviluppo[i].Id);
                if(index <= -1){
                console.log('lista referenti Sviluppo 3.1',this.retValue.consulentiSviluppo[i].Id);
                   if(this.doppioPresidioListSviluppo.length==0 || this.retValue.consulentiSviluppo[i].Id!==this.doppioPresidioListSviluppo[0].PTF_Gestore__c){
                        newValueList.push(this.retValue.consulentiSviluppo[i]);
                    }
                }
                console.log('lista referenti Sviluppo 4',this.retValue.consulentiSviluppo[i].Id);
            }
            console.log('Step2');
            this.data = this.data.concat(newValueList);
            this.setPages(this.data);
            this.listCount=this.data.length;
            
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

    handleSearch(event){
        this.ndgOffset=0;
        this.data=[];
        getNDGSviluppo({recId: this.recordId, nominativo:this.searchedNominativo, matricola:this.searchedMatricola,  modelli:this.modelli})
        .then(result => {
            this.retValue = result;
            for (var i=0; i<this.retValue.consulentiEstero.length; i++) {
                if (this.retValue.consulentiSviconsulentiSviluppoluppo[i].PTF_TipologiaRuolo__r!=undefined && this.retValue.consulentiSviluppo[i].PTF_TipologiaRuolo__r.Name!=undefined) {
                    this.retValue.consulentiSviluppo[i].Ruolo = this.retValue.consulentiSviluppo[i].PTF_TipologiaRuolo__r.Name;
                }
            }
            this.data = this.retValue.consulentiSviluppo;
            this.setPages(this.retValue.consulentiSviluppo);
            this.page=1;
            this.listCount=this.retValue.consulentiSviluppo.length;

        });

    }

    creaDoppioPresidioEstero(event) {
        if(this.notEmptyListDoppioPresidioAssegnato){
            const x = new ShowToastEvent({
                "title": "Errore!",
                "variant": "error",
                "message": "Eliminare il doppio Presidio Estero già assegnato"
            });
            this.dispatchEvent(x);
        }
        
        else{
            creazioneDoppioPresidioEstero({ recId : this.recordId,contId:this.selectedRows[0]}).then(result=>{
                const x = new ShowToastEvent({
                    "title": "Successo!",
                    "variant": "success",
                    "message": "Sviluppatore aggiunto con successo"
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


    deleteDoppioPresidioAssegnato(event){
        
    
            deleteDoppioPresidioEstero({idDPList: this.selectedRowsToDelete})
            .then(result => {
                console.log('GB result ', JSON.stringify(result));

                this.doppioPresidioListSviluppo = this.setObjectForDatatable(result);

                if(result.length>0){
                    this.notEmptyListDoppioPresidioAssegnato = true;
                } else {
                    this.notEmptyListDoppioPresidioAssegnato = false;
                }

                const toastEvent = new ShowToastEvent({
                    title: "Successo!",
                    message: "Sviluppatore eliminato con successo!!",
                    variant: "success"
                });
                this.dispatchEvent(toastEvent);
                this.selectedRows = null;

            }).catch(error => {

                console.log('deleteDoppioPresidio: ' + JSON.stringify(error));
            });

        


        if(this.doppioPresidioListSviluppo.length === 0) this.notEmptyListDoppioPresidioAssegnato = true;
        

    }

    openModal() {
        
        if((this.userInfo.Profile.Name =='NEC_F.1' || this.userInfo.Profile.Name =='NEC_F.10' || (this.userInfo.Profile.Name =='NEC_D.7' && (this.userInfo.PTF_Division__c =='KI' || this.userInfo.PTF_MacroDivision__c =='IC'))) && this.notEmptyListDoppioPresidioAssegnato){
            
            const x = new ShowToastEvent({
                "title": "Errore!",
                "variant": "error",
                "message": "Doppio presidio già presente. Non è possibile modificare o eliminare il doppio presidio. Rivolgersi al proprio Responsabile/Coordinatore"
            });
            this.dispatchEvent(x);
            return;

        }
        this.openmodal = true;
        this.loadNDGRecords();
    }

    closeModal() {
        this.openmodal = false;
        this.searchedNominativo='';
        this.searchedMatricola='';
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

    setObjectForDatatable(result){

        let tempData=[];
                result.forEach(element =>{
                    
                    if(element.hasOwnProperty('PTF_Gestore__r') && element.PTF_Gestore__r.hasOwnProperty('Name')){
                        element.Name=element.PTF_Gestore__r.Name;
                    }
                    
                    if(element.hasOwnProperty('PTF_Gestore__r') && element.PTF_Gestore__r.hasOwnProperty('PTF_RegistrationNumber__c')){
                        element.RegistrationNumber=element.PTF_Gestore__r.PTF_RegistrationNumber__c;
                    }

                    if(element.hasOwnProperty('PTF_Gestore__r') && element.PTF_Gestore__r.hasOwnProperty('PTF_TipologiaRuolo__r') && element.PTF_Gestore__r.PTF_TipologiaRuolo__r.hasOwnProperty('Name')){
                        element.Ruolo=element.PTF_Gestore__r.PTF_TipologiaRuolo__r.Name;
                    }

                    if(element.hasOwnProperty('PTF_Gestore__r') && element.PTF_Gestore__r.hasOwnProperty('PTF_UnitaOrganizzativa__c')){
                        element.UnitaOrganizzativa=element.PTF_Gestore__r.PTF_UnitaOrganizzativa__c;
                    }
                      
                    tempData.push(element);
               });

        return tempData;
    }

    handleFilter(event){

        console.log('handleFilter Started');
        
        try {
            
            if(event.target.name == 'searchedNominativo'){
                
                this.searchedNominativo = event.target.value;
            }else if(event.target.name == 'searchedMatricola'){

                this.searchedMatricola = event.target.value;
            
            }
        
            
        } catch(error) {
            // invalid regex, use full list
            console.log('handleFilter.error: ' + error);
        }
    }

    getSelectedRows(event){
        
        let selectedR = event.detail.selectedRows;
        
        let rows = [];
        for (let i = 0; i < selectedR.length; i++){
            rows.push(selectedR[i].Id);
        }

        this.selectedRows = rows;
        console.log('referente selezionato ',rows);
        
    }

    getSelectedRowsToDelete(event){
        
        let selectedR = event.detail.selectedRows;
        
        let rows = [];
        for (let i = 0; i < selectedR.length; i++){
            rows.push(selectedR[i].Id);
        }

        this.selectedRowsToDelete = rows;
        console.log('referente da cancellare ',this.selectedRowsToDelete);
        
    }

    //Test Pagination
    @track page = 1;
    perpage = 100;
    @track pages = [];
    set_size = 100;
    
    handleReset(){
        this.searchedNominativo='';
        this.searchedMatricola='';
        this.searchedTipologia='';
        this.selectedRows=[];
        this.data=this.dataAll;
        this.setPages(this.data);
    }
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
          
       }  
      
      get disabledButtonIndietro(){
          return this.page === 1;
      }
      
      get disabledButtonAvanti(){
          
          return this.page === this.pages.length
      }
  
      
  
      get currentPageData(){
          return this.pageData();
      }

        
}