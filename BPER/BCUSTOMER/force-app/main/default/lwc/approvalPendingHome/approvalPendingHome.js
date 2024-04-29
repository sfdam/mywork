import { LightningElement, api, track } from 'lwc';

import getAllData from '@salesforce/apex/ApprovalPendingHomeController.getAllData';

import Numero_richiesta from '@salesforce/label/c.approvalPendingHome_CLM_NumeroRichiesta';
import Portafoglio_destinazione from '@salesforce/label/c.approvalPendingHome_CLM_PortafoglioDestinazione';
import Filiale_destinazione from '@salesforce/label/c.approvalPendingHome_CLM_FilialeDestinazione';
/**
 * Columns definition
 * :: used in examples
 */
const columns = [
    { label: Numero_richiesta, fieldName: 'PTF_UrlRequest', type: 'url',
        typeAttributes: {
            label: { fieldName: 'workOrderName' }
        },
        hideDefaultActions: "true",
        cellAttributes:{class:{fieldName: 'typeCSSClass' }}
    },
    { label: 'NDG', fieldName: 'PTF_UrlNDG', type: 'url',
        typeAttributes: {
            label: { fieldName: 'NDG' }
        },
        hideDefaultActions: "true"},
    { label: Portafoglio_destinazione, fieldName: 'PTF_UrlPTFDestinazione', type: 'url',
        typeAttributes: {
            label: { fieldName: 'PTFDestinazionename' }
        },
        hideDefaultActions: "true"},
    { label: 'M-MDS', fieldName: 'DestinazioneMMDS', type: 'text'},
    { label: Filiale_destinazione, fieldName: 'PTF_UrlFilialeDestinazione', type: 'url',
        typeAttributes: {
            label: { fieldName: 'FilialeDestinazioneName' }
        },
        hideDefaultActions: "true"}
];



// 56280 - VS 02/09/2022
const modalColumns = [
    // NUMERO RICHIESTA DI SPOSTAMENTO
    { label: Numero_richiesta, fieldName: 'PTF_UrlRequest', type: 'url',
        typeAttributes: {
            label: { fieldName: 'workOrderName' }
        },
        hideDefaultActions: "true",
        cellAttributes:{class:{fieldName: 'typeCSSClass' }}
    },
    // NDG
    { label: 'NDG', fieldName: 'PTF_UrlNDG', type: 'url',
        typeAttributes: {
            label: { fieldName: 'NDG' }
        },
        hideDefaultActions: "true"},
    // DENOMINAZIONE NDG
    { label: 'Denominazione', fieldName: 'Denominazione', type: 'text'},
    // FILIALE DI PARTENZA
    { label: "Filiale Di partenza", fieldName: 'PTF_UrlFilialeOrigine', type: 'url',
        typeAttributes: {
            label: { fieldName: 'FilialeOrigineName' }
        },
        hideDefaultActions: "true"},
    // FILIALE DI DESTINAZIONE
    { label: Filiale_destinazione, fieldName: 'PTF_UrlFilialeDestinazione', type: 'url',
        typeAttributes: {
            label: { fieldName: 'FilialeDestinazioneName' }
        },
        hideDefaultActions: "true"},
    // M-MDS DI PARTENZA
    { label: 'M-MDS Partenza', fieldName: 'OrigineMMDS', type: 'text'},
    // M-MDS DI DESTINAZIONE
    { label: 'M-MDS Destinazione', fieldName: 'DestinazioneMMDS', type: 'text'},
    // PORTAFOGLIO DI PARTENZA
    { label: "Portafoglio Di partenza", fieldName: 'PTF_UrlPTFOrigine', type: 'url',
        typeAttributes: {
            label: { fieldName: 'PTFOriginename' }
        },
        hideDefaultActions: "true"},
    // PORTAFOGLIO DI DESTINAZIONE
    { label: Portafoglio_destinazione, fieldName: 'PTF_UrlPTFDestinazione', type: 'url',
        typeAttributes: {
            label: { fieldName: 'PTFDestinazionename' }
        },
        hideDefaultActions: "true"},
    { label: 'Note', fieldName: 'Description', type: 'text'},
];
// 56280 - VS 02/09/2022

export default class ApprovalPendingHome extends LightningElement {

    @api title;
    @api iconName;
    @api showNF;
    // 56280 - VS 02/09/2022
    @api numberOfRows;
    @api defaultLimit;
    // 56280 - VS 02/09/2022
    @track loaded = false;
    @track approvalRequests;
    @track approvalNFRequests;
    @track approvalDelegatedRequests;
    @track notEmptyList;
    @track notEmptyNFList;
    @track notEmptyDelegatedList;
    @track hasToClose;
    @track alertDays;
    // 56280 - VS 02/09/2022
    @track isViewAll;
    @track modalDataView;
    @track approvalRequestsModal;
    @track approvalNFRequestsModal;
    @track approvalDelegatedRequestsModal;
    @track searchedNumRichiesta ='';
    @track searchedNDG ='';
    @track searchedNameNDG ='';
    @track searchedFilialePartenza ='';
    @track searchedFilialeDestinazione ='';
    @track searchedMMDSPartenza ='';
    @track searchedMMDSDestinazione ='';
    @track searchedPortafoglioPartenza ='';
    @track searchedPortafoglioDestinazione ='';
    @track modalDataViewBackup;
    @track numberOfRecord;
    // 56280 - VS 02/09/2022
    // definition of columns for the tree grid
    columns = columns;
    modalColumns= modalColumns;

    connectedCallback() {
      
        if(!this.defaultLimit){
            this.defaultLimit = this.perpage;
        }
        getAllData()
        .then(result => {
            let dataTableGlobalStyle = document.createElement('style');
            dataTableGlobalStyle.innerHTML = `
            .no-button {
                text-align: center;
                color: #D3D3D3;
                font-weight: 800;
                text-transform: uppercase;
            }
            
            .tilte-card {
                padding-left: 7px;
            }
            
            .approvalTabs ul.slds-tabs_default__nav{
                width: 150px;
                margin: 0 auto;
            }
            .color-red a {
                font-weight: 500;
                color: red;
            }`;
            document.head.appendChild(dataTableGlobalStyle);
            console.log('DK getAllData result', JSON.stringify(result));

            this.hasToClose = result['hasToClose'];
            this.alertDays = result['alertDays'];
            if(result['approvalRequests'].length){

                this.approvalRequests = this.numberOfRows != null && this.numberOfRows != undefined ? result['approvalRequests'].slice(0,this.numberOfRows) : result['approvalRequests'];
                this.approvalRequestsModal = result['approvalRequests'];
                this.notEmptyList = true;
            }else{

                this.notEmptyList = false;
            }

            if(result['approvalNFRequests'].length){

                this.approvalNFRequests = this.numberOfRows != null || this.numberOfRows != undefined ? result['approvalNFRequests'].slice(0,this.numberOfRows) : result['approvalNFRequests'];
                this.approvalNFRequestsModal = result['approvalNFRequests'];
                this.notEmptyNFList = true;
            }else{

                this.notEmptyNFList = false;
            }

            if(result['approvalDelegatedRequests'].length){

                this.approvalDelegatedRequests = this.numberOfRows != null || this.numberOfRows != undefined ? result['approvalDelegatedRequests'].slice(0,this.numberOfRows) : result['approvalDelegatedRequests'];
                this.approvalNFRequestsModal = result['approvalNFRequests'];
                this.notEmptyDelegatedList = true;
            }else{

                this.notEmptyDelegatedList = false;
            }

            this.loaded = true;
        })
        .catch(error => {
            console.log('DK ERROR', JSON.stringify(error));
            this.loaded = true;
        });
    }


    // 56280 - VS 02/09/2022
    handleViewAllapprovalRequests(){
        this.isViewAll=true;
        // console.log("handleViewAllapprovalRequests");
        this.modalDataView = this.approvalRequestsModal;
        this.setPages(this.modalDataView);  
        this.numberOfRecord =this.modalDataView.length;   

    }
    handleViewAllapprovalNFRequests(){
        this.isViewAll=true;
        // console.log("handleViewAllapprovalNFRequests");
        this.modalDataView = this.approvalNFRequestsModal;
        this.setPages(this.modalDataView);
        this.numberOfRecord =this.modalDataView.length; 

    }
    handleViewAllapprovalDelegatedRequests(){
        this.isViewAll=true;
        // console.log("handleViewAllapprovalDelegatedRequests");
        this.modalDataView = this.approvalDelegatedRequestsModal;
        this.setPages(this.modalDataView);
        this.numberOfRecord =this.modalDataView.length; 

    }
    closeModal(){
        this.isViewAll=false;
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
        let recordToDisplay = this.modalDataView.slice(startIndex,endIndex);
        console.log('@vs recordToDisplay: '+ JSON.stringify(recordToDisplay));
        //let recordToDisplayIdList = recordToDisplay.map(item => item.Id);

        

        return recordToDisplay;
    }

    setPages = (data)=>{
        this.pages = [];
        let numberOfPages = Math.ceil(data.length / this.defaultLimit);
        console.log('@VS numberOfPages: '+numberOfPages);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
        console.log('DK this.pages: ' + this.pages);
    }  
    
    get disabledButtonIndietro(){
        return this.page === 1;
    }
    
    get disabledButtonAvanti(){
        return this.page === this.pages.length || this.modalDataView.length === 0
    }

    get modalDataViewCurrentPage(){
        return this.pageData();
    }


    handleFilter(event){

        console.log('VS handleFilter Started');
        
        switch(event.target.name) {
            case 'searchedNumRichiesta':
                this.searchedNumRichiesta = event.target.value;
                break;
            case 'searchedNDG':
                this.searchedNDG = event.target.value;
                break;
            case 'searchedNameNDG':
                this.searchedNameNDG = event.target.value;
                break;
            case 'searchedFilialePartenza':
                this.searchedFilialePartenza = event.target.value;
                break;
            case 'searchedFilialeDestinazione':
                this.searchedFilialeDestinazione = event.target.value;
                break;
            case 'searchedMMDSPartenza':
                this.searchedMMDSPartenza = event.target.value;
                break;
            case 'searchedMMDSDestinazione':
                this.searchedMMDSDestinazione = event.target.value;
                break;
            case 'searchedPortafoglioPartenza':
                this.searchedPortafoglioPartenza = event.target.value;
                break;
            case 'searchedPortafoglioDestinazione':
                this.searchedPortafoglioDestinazione = event.target.value;
                break;
            default:
              // code block
          }
          
    }

    handleReset(){

        this.searchedNumRichiesta = '';
        this.searchedNDG = '';
        this.searchedNameNDG = '';
        this.searchedFilialePartenza = '';
        this.searchedFilialeDestinazione = '';
        this.searchedMMDSPartenza = '';
        this.searchedMMDSDestinazione = '';
        this.searchedPortafoglioPartenza = '';
        this.searchedPortafoglioDestinazione = '';
        this.modalDataView = !this.modalDataViewBackup ? this.modalDataView: this.modalDataViewBackup;
        // this.handleSearch();
        this.setPages(this.modalDataView);
        this.pageData();
    }

    handleSearch(){
        if(!this.modalDataViewBackup){
            this.modalDataViewBackup = this.modalDataView;
        }
        
        var modalFilteredData= [];
        console.log(JSON.stringify(this.searchedNumRichiesta));
        console.log(JSON.stringify(this.searchedNDG));
        console.log(JSON.stringify(this.searchedNameNDG));
        console.log(JSON.stringify(this.searchedFilialePartenza));
        console.log(JSON.stringify(this.searchedFilialeDestinazione));
        console.log(JSON.stringify(this.searchedMMDSPartenza));
        console.log(JSON.stringify(this.searchedMMDSDestinazione));
        console.log(JSON.stringify(this.searchedPortafoglioPartenza));
        console.log(JSON.stringify(this.searchedPortafoglioDestinazione));
        this.modalDataViewBackup.forEach(element => {
            console.log('vs element: '+JSON.stringify(element));
            if(( element.workOrderName.toString().toUpperCase().startsWith(this.searchedNumRichiesta.toUpperCase()) )
            && (element.NDG.toString().toUpperCase().startsWith(this.searchedNDG.toUpperCase())) 
            && (element.Denominazione.toString().toUpperCase().startsWith(this.searchedNameNDG.toUpperCase())) 
            && (element.FilialeOrigineName.toString().toUpperCase().startsWith(this.searchedFilialePartenza.toUpperCase())) 
            && (element.FilialeDestinazioneName.toString().toUpperCase().startsWith(this.searchedFilialeDestinazione.toUpperCase())) 
            && (element.OrigineMMDS.toString().toUpperCase().startsWith(this.searchedMMDSPartenza.toUpperCase())) 
            && (element.DestinazioneMMDS.toString().toUpperCase().startsWith(this.searchedMMDSDestinazione.toUpperCase())) 
            && (element.PTFOriginename.toString().toUpperCase().startsWith(this.searchedPortafoglioPartenza.toUpperCase())) 
            && (element.PTFDestinazionename.toString().toUpperCase().startsWith(this.searchedPortafoglioDestinazione.toUpperCase()))){
                modalFilteredData.push(element)
            }
        });
        
        console.log('VS modalFilteredData: '+ JSON.stringify(modalFilteredData));
        this.modalDataView = modalFilteredData;
        this.setPages(this.modalDataView);
    }
    // 56280 - VS 02/09/2022
}