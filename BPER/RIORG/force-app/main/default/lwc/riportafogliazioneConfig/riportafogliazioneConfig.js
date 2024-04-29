import { LightningElement, api, track  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllData from '@salesforce/apex/RiportafogliazioneConfig_Controller.getAllData';
import updatePercent from '@salesforce/apex/RiportafogliazioneConfig_Controller.updatePercent';



const COLUMNS = [
    {
        label: 'Direzione Territoriale',
        fieldName: 'PTF_Direzione_Territoriale__c',
        type: 'text'
    },
    {
        label: 'Id Ced',
        fieldName: 'PTF_Id_Ced__c',
        type: 'text'
    },
    {
        label: 'ABI',
        fieldName: 'PTF_ABI__c',
        type: 'text'
    },
    {
        label: 'Tipologia Spostamento',
        fieldName: 'Tipologia_Spostamento__c',
        type: 'text'
    },
    {
        label: 'Sottotipologia Spostamento__c ',
        fieldName: 'Sottotipologia_Spostamento__c',
        type: 'text'
    },
    {
        label: 'Percentuale Affinamento',
        fieldName: 'Perc_Affinamento__c',
        type: 'percent',
        
        typeAttributes: {
            step: '0.01',
            minimumFractionDigits: '2',
            maximumFractionDigits: '3',
        },
        editable: true
    }
];

const ROWS_PER_PAGE = 10;


export default class RiportafogliazioneConfig extends LightningElement {

    @api showSpinner = false;
    @api isRifiuta= false;

    @api saveDraftValues;
    @api draftValues;

    @api selectedWallet;
    
    @track searchedDirezioneTerr;
    @track searchedIdCed;
    @track searchedAbi;
    @track searchedTipologiaSpostamento;
    @track searchedSottoTipologiaSpostamento;

    @track filteredRecords =[];

    columns=COLUMNS;
    connectedCallback() {
        getAllData().
        then(result => {
            this.getAllData = result;
            this.getAllData.forEach(element =>{
                if(element.hasOwnProperty('PTF_Direzione_Territoriale__c')){
                    element.PTF_Direzione_Territoriale__c= element.PTF_Direzione_Territoriale__r.Name;
                } 
                // if (element.hasOwnProperty('Perc_Affinamento__c')) {
                //     element.Perc_Affinamento__c = element.Perc_Affinamento__c / 10;
                // }
                
            });
            console.log('GR allDataConf: ' + JSON.stringify(this.getAllData));
            this.filteredRecords= this.getAllData;
            this.setPages(this.filteredRecords);
            
        }).catch(error => {
            console.log('GR error: ', error);
        });
    }

    handleReset(){
        this.searchedDirezioneTerr = '';
        this.searchedIdCed = null;
        this.searchedAbi= null;
        this.searchedTipologiaSpostamento='';
        this.searchedSottoTipologiaSpostamento ='';
        this.handleSearch();
    }

    handleFilter(event){
    
        if(event.target.name == 'searchedDirezioneTerr'){
            this.searchedDirezioneTerr = event.target.value;
        }
        else if(event.target.name == 'searchedIdCed'){
            this.searchedIdCed = event.target.value;
        }
        else if(event.target.name == 'searchedAbi'){
            this.searchedAbi = event.target.value;
        }
        else if(event.target.name == 'searchedTipologiaSpostamento'){
            this.searchedTipologiaSpostamento = event.target.value;
        }
        else if(event.target.name == 'searchedSottoTipologiaSpostamento'){
            this.searchedSottoTipologiaSpostamento = event.target.value;
        }
       
    }

    handleSearch(){
        this.filteredRecords = [];
        this.page = 1;
        try {
            
            for(var i in this.getAllData){
                  
                if(Boolean(this.searchedDirezioneTerr)){

                    if(!this.getAllData[i].PTF_Direzione_Territoriale__c.toLowerCase().includes(this.searchedDirezioneTerr.toLowerCase())){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedIdCed)){

                    if(!this.getAllData[i].PTF_Id_Ced__c.toLowerCase().includes(this.searchedIdCed.toLowerCase())){
    
                        continue;
                    }
                }

                
                if(Boolean(this.searchedAbi)){

                    if(!this.getAllData[i].PTF_ABI__c.toLowerCase().includes(this.searchedAbi.toLowerCase())){
    
                        continue;
                    }
                }

                
                if(Boolean(this.searchedTipologiaSpostamento)){

                    if(!this.getAllData[i].Tipologia_Spostamento__c.toLowerCase().includes(this.searchedTipologiaSpostamento.toLowerCase())){
    
                        continue;
                    }
                }  

                if(Boolean(this.searchedSottoTipologiaSpostamento)){

                    if(!this.getAllData[i].Sottotipologia_Spostamento__c.toLowerCase().includes(this.searchedSottoTipologiaSpostamento.toLowerCase())){
    
                        continue;
                    }
                }

                this.filteredRecords.push(this.getAllData[i]);
            }
            this.setPages(this.filteredRecords);
        } catch (error) {
            console.log('GR error: ' + error);
        }
    } 

   
    handleSave(event) {
        this.saveDraftValues = event.detail.draftValues.slice();
        this.saveDraftValues.forEach(row => {
            if (row.hasOwnProperty('Perc_Affinamento__c')) {
                row.Perc_Affinamento__c = row.Perc_Affinamento__c / 100;
            }
        });

        updatePercent({ recordsToUpdate: this.saveDraftValues })
        .then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Successo',
                    message: 'Salvataggio avvenuto con successo!',
                    variant: 'success'
                })
            );
            this.draftValues = [];
            eval("$A.get('e.force:refreshView').fire();");
            this.setPages(this.filteredRecords);
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore',
                    message: 'Qualcosa è andato storto.',
                    variant: 'error'
                })
            );
            console.error('gr err:', error);
        });
    }


    handleCustomEvent(event) {
        if(event.detail!=null ){
            this.selectedWallet=event.detail.objId;
        }
        else{
            this.selectedWallet=null;
        }
                }

    //Pagination
     @track page = 1;
     perpage = ROWS_PER_PAGE;
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
         let recordToDisplay = this.filteredRecords.slice(startIndex,endIndex);
        return recordToDisplay;      
     }
     setPages = (data)=>{
         this.pages = [];
         let numberOfPages = Math.ceil(data.length / this.perpage);
         for (let index = 1; index <= numberOfPages; index++) {
             this.pages.push(index);
         }
         console.log('GR this.pages: ' + this.pages);
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

   
}