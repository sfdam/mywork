import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getProdottiAssociabili from '@salesforce/apex/RelatedListProdottiAssociatiController.getProdottiAssociabili';
import getProdottiAssociati from '@salesforce/apex/RelatedListProdottiAssociatiController.getProdottiAssociati';
import removeProdotto from '@salesforce/apex/RelatedListProdottiAssociatiController.removeProdotto';
import associateProducts from '@salesforce/apex/RelatedListProdottiAssociatiController.associateProducts';
import getUserInfo from '@salesforce/apex/RelatedListProdottiAssociatiController.getUserInfo';


const COL_WITH_ACTION = [

	{ label: 'Bisogno', fieldName: 'prodBisogno',wrapText: 'true' },
	{ label: 'Categoria', fieldName: 'prodCategoria',wrapText: 'true' },
	{ label: 'Macrogruppo', fieldName: 'prodMacrogruppo',wrapText: 'true' },
	{ label: 'Gruppo', fieldName: 'prodGruppo',wrapText: 'true' },
    { label: 'Sottogruppo', fieldName: 'prodSottogruppo',wrapText: 'true' },
    { label: 'Prodotto elementare', fieldName: 'prodName', type:'text', wrapText: 'true',fixedWidth: 200}, 
	{ label: '', type: 'button', initialWidth: 75, typeAttributes: 
		{
		  iconName: 'utility:delete',
		  iconPosition: 'center',
		  label: '',
		  title: 'Rimuovi',
          variant: 'destructive'
		}
	}
];

const COLUMNS = [
	{ label: 'Bisogno', fieldName: 'prodBisogno',wrapText: 'true' },
    { label: 'Categoria', fieldName: 'prodCategoria',wrapText: 'true' },
    { label: 'Macrogruppo', fieldName: 'prodMacrogruppo',wrapText: 'true' },
    { label: 'Gruppo', fieldName: 'prodGruppo' ,wrapText: 'true'},
    { label: 'Sottogruppo', fieldName: 'prodSottogruppo',wrapText: 'true' },
    { label: 'Prodotto elementare', fieldName: 'prodName',wrapText: 'true' }
];
 
export default class RelatedListProdottiAssociati extends LightningElement {

	columnsWithAction = COL_WITH_ACTION;
	columns = COLUMNS;
    @api profiliAutorizzati;
	@api recordId;
    @api title = 'Prodotti Associati';
    @api viewAllText = 'Mostra tutto';
    @api coupleText = 'Associa';
    @api coupleModalText = 'Associa prodotti';
    @api filterResultsText = 'Filtra Risultati';
    @api iconName = 'utility:file';
    @api noElementMessage = 'Nessun elemento presente';
    @api errorMessage = 'Si è verificato un errore';
    @api successMessage = 'Operazione effettuata correttamente';
    @api deleteMessage = 'Sei sicuro di voler rimuovere il prodotto';
    @api maxAssociatedProdNum = 5;
    @track fullTitle = 'Prodotti Associati';
	@track filterBisogno = '';
	@track filterCategoria = '';
	@track filterMacrogruppo = '';
	@track filterGruppo = '';
	@track filterSottogruppo = '';
	@track filterElemetare = '';
    @track deleteProductName = '';
    @track deleteProductId = '';
    @track isLoaded = false;
    @track isProductLoaded = false;
    @track isFullProductLoaded = true;
	@track showModal = false;
    @track showProductModal = false;
    @track showDeleteModal = false;
	@track showSpinner = false;
	@track isSaveDisabled = true;
    @track isFilterDisabled = false;
	@track hasAssociatedProducts = false;
	@track hasProducts = false;
	@track productList = [];
    @track fullProductList = [];
	@track selectableProductList = [];
    @track selectedProductIds = [];
    @track pageSelectedRowIds = [];
    @track isUserEnabled = false;
	
	connectedCallback(){
		getUserInfo()
        .then(result => {
            console.log( 'UserProfile: '+result.Profile.Name )
            if(this.profiliAutorizzati && this.profiliAutorizzati.includes(result.Profile.Name)){
                this.isUserEnabled = true;
                
            } else {
                this.isUserEnabled = false;
                this.columnsWithAction = COLUMNS;
            }
            })
		getProdottiAssociati({ campaignId: this.recordId })
		.then(result => {
            console.log('test1: ');
			if(result.length > 0){
				this.hasAssociatedProducts = true;
                let tempProdList = [];
                console.log('test2: ');
                result.forEach(element => {
                    console.log('test3: ');
                    if(tempProdList.length < this.maxAssociatedProdNum){
                       // console.log('test1: '+element.prodName);
                        /*if(element.CRM_Prodotto__c!= undefined){
                            console.log('test2');
                            element.prodName = element.CRM_Prodotto__r.Name;
                            element.prodSottogruppo = element.CRM_Prodotto__r.CRM_SubGroup__c;
                            element.prodGruppo = element.CRM_Prodotto__r.CRM_Group__c;
                            element.prodMacrogruppo = element.CRM_Prodotto__r.CRM_MacroGroup__c;
                            element.prodCategoria = element.CRM_Prodotto__r.CRM_ProductCategory__c;
                            element.prodBisogno = element.CRM_Prodotto__r.CRM_Bisogno__c;
                            
                        }else{
                            console.log('test3');
                            element.prodName = element.CRM_DescrizioneProdotto__c;
                            element.prodSottogruppo = element.CRM_CodiceProdotto__c;
                        }*/

                        tempProdList.push(element);
                    }
                })
                console.log('test4: ');
				this.productList = tempProdList;
                this.fullProductList = result;
                this.setProdPages(this.fullProductList);
                console.log('NumProd: '+tempProdList);
			}else{
                console.log('test5: ');
                this.hasAssociatedProducts = false;
                this.productList = [];
                this.fullProductList = [];
                this.setProdPages(this.fullProductList);
                //console.log('NumProd: '+tempProdList);
            }
		})
		.catch(error => {
			console.error('AdF getProdottiAssociati error: ' + JSON.stringify(error));
			this.showToastMessage(this.errorMessage,'error');
		})
        .finally(() => {
            this.isProductLoaded = true;
            this.fullTitle = this.title + ' (' + this.fullProductList.length + ')';

            getProdottiAssociabili({ campaignId: this.recordId, bisogno: this.filterBisogno, gruppo: this.filterGruppo,
                                    categoria: this.filterCategoria, sottogruppo: this.filterSottogruppo,
                                    macrogruppo: this.filterMacrogruppo, elementare: this.filterElemetare,
                                    coupledProduct: this.fullProductList })
            .then(result => {
                this.hasProducts = (result.length > 0) ? true : false;
                this.selectableProductList = result;
                this.setPages(this.selectableProductList);
            })
            .catch(error => {
                console.error('AdF getProdottiAssociabili error: ' + JSON.stringify(error));
                this.showToastMessage(this.errorMessage,'error');
            })
            .finally(() => {
                this.isLoaded = true;
            });

        });
		
	}

    handleFilter(){

        this.isLoaded = false;
        this.isFilterDisabled = true;
        this.toggleSpinner();

        getProdottiAssociabili({ campaignId: this.recordId, bisogno: this.filterBisogno, gruppo: this.filterGruppo,
                                categoria: this.filterCategoria, sottogruppo: this.filterSottogruppo,
                                macrogruppo: this.filterMacrogruppo, elementare: this.filterElemetare,
                                coupledProduct: this.fullProductList })
        .then(result => {
            this.hasProducts = (result.length > 0) ? true : false;
            this.selectableProductList = result;
            this.setPages(this.selectableProductList);
        })
        .catch(error => {
            console.error('AdF getProdottiAssociabili error: ' + JSON.stringify(error));
            this.showToastMessage(this.errorMessage,'error');
        })
        .finally(() => {
            this.toggleSpinner();
            this.isLoaded = true;
            this.isFilterDisabled = false;
            this.setPages(this.selectableProductList);
            this.page = 1;
        });

    }
	
	handleRemove(event){

        this.isFullProductLoaded = false;
        this.closeDeleteModal();
        this.toggleSpinner();
		
		removeProdotto({ campaignId: this.recordId, productId: this.deleteProductId })
		.then(result => {
			if(result){
				this.showToastMessage(this.successMessage,'success');

                getProdottiAssociati({ campaignId: this.recordId })
                .then(result => {
                    if(result.length > 0){
                        this.hasAssociatedProducts = true;
                        let tempProdList = [];
                        result.forEach(element => {
                            if(tempProdList.length < this.maxAssociatedProdNum){
                                tempProdList.push(element);
                            }
                        })
                        this.productList = tempProdList;
                        this.fullProductList = result;
                        this.setProdPages(this.fullProductList);
                    }else{
                        this.hasAssociatedProducts = false;
                        this.productList = [];
                        this.fullProductList = [];
                        this.setProdPages(this.fullProductList);
                    }
                })
                .catch(error => {
                    console.error('AdF getProdottiAssociati error: ' + JSON.stringify(error));
                    this.showToastMessage(this.errorMessage,'error');
                })
                .finally(() => {
                    this.isProductLoaded = true;
                    this.fullTitle = this.title + ' (' + this.fullProductList.length + ')';
                });

			}
		})
		.catch(error => {
			console.error('AdF removeProdotto error: ' + JSON.stringify(error));
			this.showToastMessage(this.errorMessage,'error');
		})
        .finally(() => {
            this.toggleSpinner();
            this.isFullProductLoaded = true;
        });

	}

    handleSave(){

        this.toggleSpinner();
        this.isLoaded = false;
        this.isSaveDisabled = true;

        associateProducts({ campaignId: this.recordId, selectedProductIdList: this.selectedProductIds })
		.then(result => {
			if(result){
                this.showToastMessage(this.successMessage,'success');
                this.connectedCallback();
			}
		})
		.catch(error => {
			console.error('AdF associateProducts error: ' + JSON.stringify(error));
			this.showToastMessage(this.errorMessage,'error');
		})
        .finally(() => {
            this.toggleSpinner();
            this.page = 1;
        });

    }

    handleRowSelection(event){
        this.pageSelectedRowIds = [];
        this.consistantPaginationRowSelection(event, false);
        this.isSaveDisabled = (this.selectedProductIds.length > 0) ? false : true;
    }
	
	//consistant rows selection through pages Start
    consistantPaginationRowSelection(evt, isChangingPage) {
        //List of selected items from the data table event
        let eventItemsSet = new Set();
        //List of selected id to maintain.
        let selectedItemsSet = new Set(this.selectedProductIds);
        //List of items currently loaded for the current view
        let loadedItemsSet = new Set();

        this.currentPageData.map((event) => {
            loadedItemsSet.add(event.Id);
        });  

        if(!isChangingPage){
            if (evt.detail.selectedRows) {
                this.pageSelectedRowIds = evt.target.selectedRows;
                evt.detail.selectedRows.map((event) => {
                    eventItemsSet.add(event.Id);
                });    
        
                //Add any new items to the lists
                eventItemsSet.forEach((id) => {
                    if (!selectedItemsSet.has(id)) {
                        selectedItemsSet.add(id);
                    }
                });        
            }

            //Remove all the rows loaded in the page from the lists
            loadedItemsSet.forEach((id) => {
                if (selectedItemsSet.has(id) && !eventItemsSet.has(id)) {
                    selectedItemsSet.delete(id);
                }
            });
        }else{
            //Preselect all the page rows in the lists
            let tempPageSelectedRowIds = [];
            loadedItemsSet.forEach((id) => {
                if (selectedItemsSet.has(id) && !eventItemsSet.has(id)) {
                    tempPageSelectedRowIds.push(id);
                }
            });
            this.pageSelectedRowIds = tempPageSelectedRowIds;
        }
    
        this.selectedProductIds = [...selectedItemsSet];
    }
    //consistant rows selection through pages End

    //Pagination
    @track page = 1;
    perpage = 10;
    @track pages = [];
    set_size = 10;

    handleAvanti(event){
        ++this.page;
        this.consistantPaginationRowSelection(event, true);
        this.isSaveDisabled = (this.selectedProductIds.length > 0) ? false : true;
    }
    handleIndietro(event){
        --this.page;
        this.consistantPaginationRowSelection(event, true);
        this.isSaveDisabled = (this.selectedProductIds.length > 0) ? false : true;
    }

    get pagesList(){
        let mid = Math.floor(this.set_size/2);
        if(this.page > mid){
            return this.pages.slice(this.page - mid, this.page + mid - 1);
        } 
        return this.pages.slice(0,this.set_size);
    }

    pageData = ()=>{
        let page = this.page;
        let perpage = this.perpage;
        let startIndex = (page*perpage) - perpage;
        let endIndex = (page*perpage);
        let recordToDisplay = this.selectableProductList.slice(startIndex,endIndex);
        return recordToDisplay;
    }

    setPages = (data)=>{
        this.pages = [];
        let numberOfPages = Math.ceil(data.length / this.perpage);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
    } 

    get disabledButtonIndietro(){
        return this.page === 1;
    }

    get disabledButtonAvanti(){
        return this.page === this.pages.length || this.selectableProductList.length === 0
    }

    get currentPageData(){
        return this.pageData();
    }
    //End Pagination

    //Product List Pagination
    @track prodPage = 1;
    perProdPage = 5;
    @track prodPages = [];
    set_size = 5;

    handleProdAvanti(event){
        ++this.prodPage;
    }
    handleProdIndietro(event){
        --this.prodPage;
    }

    get prodPagesList(){
        let mid = Math.floor(this.set_size/2);
        if(this.prodPage > mid){
            return this.prodPages.slice(this.prodPage - mid, this.prodPage + mid - 1);
        } 
        return this.prodPages.slice(0,this.set_size);
    }

    prodPageData = ()=>{
        let page = this.prodPage;
        let perpage = this.perProdPage;
        let startIndex = (page*perpage) - perpage;
        let endIndex = (page*perpage);
        let recordToDisplay = this.fullProductList.slice(startIndex,endIndex);
        return recordToDisplay;
    }

    setProdPages = (data)=>{
        this.prodPages = [];
        let numberOfPages = Math.ceil(data.length / this.perProdPage);
        for (let index = 1; index <= numberOfPages; index++) {
            this.prodPages.push(index);
        }
    } 

    get disabledProdButtonIndietro(){
        return this.prodPage === 1;
    }

    get disabledProdButtonAvanti(){
        return this.prodPage === this.prodPages.length || this.fullProductList.length === 0
    }

    get currentProdPageData(){
        return this.prodPageData();
    }
    //End Product List Pagination
	
	handleBisognoChange(event){
		this.filterBisogno = (event.target.value != null) ? event.target.value.trim() : '';
	}
	
	handleCategoriaChange(event){
		this.filterCategoria = (event.target.value != null) ? event.target.value.trim() : '';
	}
	
	handleMacrogruppoChange(event){
		this.filterMacrogruppo = (event.target.value != null) ? event.target.value.trim() : '';
	}
	
	handleGruppoChange(event){
		this.filterGruppo = (event.target.value != null) ? event.target.value.trim() : '';
	}
	
	handleSottogruppoChange(event){
		this.filterSottogruppo = (event.target.value != null) ? event.target.value.trim() : '';
	}
	
	handleElementareChange(event){
		this.filterElemetare = (event.target.value != null) ? event.target.value.trim() : '';
	}

    openDeleteModal(event){
        this.deleteProductId = (event.detail.row.Id) ? event.detail.row.Id : '';
        this.deleteProductName = (event.detail.row.Name) ? event.detail.row.Name : '';
        this.showDeleteModal = true;
    }

    closeDeleteModal(){
        this.showDeleteModal = false;
    }

	toggleProductModal(){
        this.prodPage = 1;
        this.showProductModal = !this.showProductModal;
        this.filterBisogno = '';
	    this.filterCategoria = '';
	    this.filterMacrogruppo = '';
	    this.filterGruppo = '';
	    this.filterSottogruppo = '';
	    this.filterElemetare = '';
    }

	toggleModal(){
        this.page = 1;
		this.showModal = !this.showModal;
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