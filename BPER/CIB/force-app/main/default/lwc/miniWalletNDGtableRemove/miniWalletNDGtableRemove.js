import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getNDG from '@salesforce/apex/MiniWalletNdgTableController.getNDGToRemove';
import removeNDG from '@salesforce/apex/MiniWalletNdgTableController.removeNDG';
import getUserInfo from '@salesforce/apex/SV_Utilities.getUserInfo';
const COLS = [
    { label: 'NDG', fieldName: 'CRM_NDG__c', hideDefaultActions: true,sortable:"true" },
    { label: 'Nominativo', fieldName: 'Name', type: 'text',sortable:"true" },
    { label: 'Capogruppo', fieldName: 'PTF_Capogruppo__c', hideDefaultActions: true },
    { label: 'Natura Giuridica', fieldName: 'PTF_NaturaGiuridica__c', hideDefaultActions: true },
    { label: 'Patrimonio', fieldName: 'PTF_Patrimonio__c', hideDefaultActions: true },
    { label: 'Utilizzato', fieldName: 'PTF_Utilizzato__c', hideDefaultActions: true }
];

export default class MiniWalletNDGtableRemove extends LightningElement {

    columns = COLS;
    @api recordId;
    @api title = 'Rimuovi NDG';
    @api openmodel = false;
    @track searchedNome = '';
    @track searchedNDG = '';
    @track tableRows = [];
    @track hasData = false;
    @track isSaveDisabled = true;
    @track selectedRows = [];
    @track listaNDG = [];
    @track filteredRecords=[];
    @track isRendered = true;
    @api defaultLimit;
    @track sortBy;
    @track sortByAll;
    @track sortDirection;
    @track sortDirectionAll;

    @track buttonDisabled = true;
    connectedCallback(){
        getUserInfo()
        .then(result => {
            console.log('MC getUserInfo result', result);
            // this.isRendered=false;
            getNDG({ miniWalletId: this.recordId })
            .then(result => {
                if(result.length > 0){
                    this.hasData = true;
                    this.tableRows = result;
                    this.sortBy = 'Name';
                    this.sortDirection = 'asc';
                    this.sortDataAll(this.sortBy, this.sortDirection);
                }
                // this.isRendered=true;
                this.buttonDisabled = false;
            })
            .catch(error => {
                console.error('AdF getNDG error: ' + JSON.stringify(error));
                this.showToastMessage('Non è stato possibile caricare i NDG','error');
            });
        }).catch(error => {

            console.log('MC init.error: ' + JSON.stringify(error));
        });
    }

    openModal() {
        this.openmodel = true;
    }

    handleSave(){
        this.isRendered = false;
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
        this.selectedNDGRows.forEach(ndg => {
            selectedNdgIdRows.push(ndg.Id);
        });
        this.selectedNdgIdRows=selectedNdgIdRows;

        console.log("MC listaNDG", this.selectedNDGRows.length);
        removeNDG({ ndgIdList: this.selectedNdgIdRows })
                .then(result => {
                    if(result){
                        const toastEvent = new ShowToastEvent({
                            message: "NDG rimossi correttamente",
                            variant: "success"
                        });
                        this.dispatchEvent(toastEvent);
                        eval("$A.get('e.force:refreshView').fire();");
                        //setTimeout(window.location.reload(),3000);
                    }
                }).finally(() => {
                    console.log('GB Finally');
                    this.isSaveDisabled = true;
                    this.isRendered = true;
                    this.openmodel = false;
        
                }); 
    }

    handleRowSelection(event) {
        var countElement=0;
        for(let currentPage of Object.keys(this.selectRowsMapValues)){
            if(currentPage != this.page){
                this.selectRowsMapValues[currentPage].forEach(element =>{
                    countElement++;
                });
            }
        }
        if(countElement > 0 || event.detail.selectedRows.length>0){
            this.selectedRows = event.detail.selectedRows;
            this.isSaveDisabled = false;
        }else{
            this.selectedRows = [];
            this.isSaveDisabled = true;
        }
    }

    sortDataAll(fieldname, direction){

        let parseData = JSON.parse(JSON.stringify(this.tableRows));
        let keyValue = (a) => {
        return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : ''; 
        y = keyValue(y) ? keyValue(y) : '';
        return isReverse * ((x > y) - (y > x));
        });
        this.tableRows = parseData;
        this.filteredRecords = this.tableRows;
        this.setPages(this.filteredRecords);
     }
     doSortingAll(event){
        let sortBy;
        this.sortByAll = event.detail.fieldName;
        if(event.detail.fieldName==='Name') 
            sortBy = 'Name';
        else if(event.detail.fieldName==='CRM_NDG__c') 
            sortBy = 'CRM_NDG__c';
        else 
            sortBy = event.detail.fieldName;
        this.sortDirectionAll = event.detail.sortDirection;
        this.sortDataAll(sortBy, this.sortDirectionAll);
    }

    closeModal() {
        this.openmodel = false;
    }

    //Search
    handleReset(){
        this.searchedNome = '';
        this.searchedNDG = '';
        this.handleSearch();
    }

    handleSearch(){

        this.filteredRecords = [];
        this.page = 1;
        try {
            
            for(var i in this.tableRows){  

                if(Boolean(this.searchedNome)){
                    if(!this.tableRows[i].Name.toLowerCase().includes(this.searchedNome.toLowerCase().trim())){    
                        continue;
                    }
                }

                if(Boolean(this.searchedNDG)){
                    if(!this.tableRows[i].CRM_NDG__c.toLowerCase().includes(this.searchedNDG.toLowerCase())){    
                        continue;
                    }
                }

                this.filteredRecords.push(this.tableRows[i]);

            }            
           
            this.setPages(this.filteredRecords);

        }catch(error) {            
            console.log('AdF handleSearch error: ' + error);
        }

    }

    handleFilter(event){
        if(event.target.name == 'searchedNome'){
            this.searchedNome = event.target.value;
        }else{
            this.searchedNDG = event.target.value;
        }
    }

     //Pagination
     @track page = 1;
     perpage = this.defaultLimit;
     @track pages = [];
     set_size = this.defaultLimit;

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

    showToastMessage(text, type) {
        const toastEvent = new ShowToastEvent({
            title: '',
            message: text,
            variant: type
        });
        this.dispatchEvent(toastEvent);
    }
}