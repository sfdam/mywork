import { LightningElement, api, track } from 'lwc';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

export default class CustomDatatable extends NavigationMixin(LightningElement) {
    fixedWidth = "width:10rem;";
    stylePopOver = '';
    openTile = false;

    @api columns;
    @api listViewData;
    @api getAllData;

    tileCategoria = '';
    tileMacroGruppo = '';
    tileSottoGruppo = '';
    tileGruppo = '';
    tileName = '';

    //FOR HANDLING THE SIZE COLUMNS - EDB 2020-10-19
    connectedCallback() {
        debugger;
    }
 
    //FOR HANDLING THE HORIZONTAL SCROLL OF TABLE MANUALLY
    tableOuterDivScrolled(event) {
        this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
        if (this._tableViewInnerDiv) {
            if (!this._tableViewInnerDivOffsetWidth || this._tableViewInnerDivOffsetWidth === 0) {
                this._tableViewInnerDivOffsetWidth = this._tableViewInnerDiv.offsetWidth;
            }
            this._tableViewInnerDiv.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth) + "px;" + this.tableBodyStyle;
        }
        this.tableScrolled(event);
    }
 
    tableScrolled(event) {
        if (this.enableInfiniteScrolling) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('showmorerecords', {
                    bubbles: true
                }));
            }
        }
        if (this.enableBatchLoading) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('shownextbatch', {
                    bubbles: true
                }));
            }
        }
    }
 
    //#region ***************** RESIZABLE COLUMNS *************************************/
    handlemouseup(e) {
        this._tableThColumn = undefined;
        this._tableThInnerDiv = undefined;
        this._pageX = undefined;
        this._tableThWidth = undefined;
    }
 
    handlemousedown(e) {
        if (!this._initWidths) {
            this._initWidths = [];
            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            tableThs.forEach(th => {
                this._initWidths.push(th.style.width);
            });
        }
 
        this._tableThColumn = e.target.parentElement;
        this._tableThInnerDiv = e.target.parentElement;
        while (this._tableThColumn.tagName !== "TH") {
            this._tableThColumn = this._tableThColumn.parentNode;
        }
        while (!this._tableThInnerDiv.className.includes("slds-cell-fixed")) {
            this._tableThInnerDiv = this._tableThInnerDiv.parentNode;
        }
        console.log("handlemousedown this._tableThColumn.tagName => ", this._tableThColumn.tagName);
        this._pageX = e.pageX;
 
        this._padding = this.paddingDiff(this._tableThColumn);
 
        this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
        console.log("handlemousedown this._tableThColumn.tagName => ", this._tableThColumn.tagName);
    }
 
    handlemousemove(e) {
        console.log("mousemove this._tableThColumn => ", this._tableThColumn);
        if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
            this._diffX = e.pageX - this._pageX;
 
            this.template.querySelector("table").style.width = (this.template.querySelector("table") - (this._diffX)) + 'px';
 
            this._tableThColumn.style.width = (this._tableThWidth + this._diffX) + 'px';
            this._tableThInnerDiv.style.width = this._tableThColumn.style.width;
 
            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            let tableBodyRows = this.template.querySelectorAll("table tbody tr");
            let tableBodyTds = this.template.querySelectorAll("table tbody .dv-dynamic-width");
            tableBodyRows.forEach(row => {
                let rowTds = row.querySelectorAll(".dv-dynamic-width");
                rowTds.forEach((td, ind) => {
                    rowTds[ind].style.width = tableThs[ind].style.width;
                });
            });
        }
    }
 
    handledblclickresizable() {
        let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
        let tableBodyRows = this.template.querySelectorAll("table tbody tr");
        tableThs.forEach((th, ind) => {
            th.style.width = this._initWidths[ind];
            th.querySelector(".slds-cell-fixed").style.width = this._initWidths[ind];
        });
        tableBodyRows.forEach(row => {
            let rowTds = row.querySelectorAll(".dv-dynamic-width");
            rowTds.forEach((td, ind) => {
                rowTds[ind].style.width = this._initWidths[ind];
            });
        });
    }
 
    paddingDiff(col) {
 
        if (this.getStyleVal(col, 'box-sizing') === 'border-box') {
            return 0;
        }
 
        this._padLeft = this.getStyleVal(col, 'padding-left');
        this._padRight = this.getStyleVal(col, 'padding-right');
        return (parseInt(this._padLeft, 10) + parseInt(this._padRight, 10));
 
    }
 
    getStyleVal(elm, css) {
        return (window.getComputedStyle(elm, null).getPropertyValue(css))
    }

    //#region ***************** LOOKUP COLUMNS *************************************/

    showData(event){

        let allData = this.getAllData;
        let targetId = event.target.dataset.targetId;

        setTimeout(() => {
            if(!this.openTile){    
                this.left = event.clientX;
                this.top=event.clientY;
    
                this.stylePopOver = 'top:' + this.top + 'px;left:' + this.left + 'px';

                for (let k in allData['financialAccMap']) {
                    if(targetId == k){
                        this.tileCategoria = allData['financialAccMap'][k].CRM_ProductCategory__c;
                        this.tileMacroGruppo = allData['financialAccMap'][k].CRM_ProductMacroGroup__c;
                        this.tileSottoGruppo = allData['financialAccMap'][k].CRM_ProductSubGroup__c;
                        this.tileGruppo = allData['financialAccMap'][k].CRM_ProductGroup__c;
                        this.tileName = allData['financialAccMap'][k].Name;
                    }
                }
                this.openTile = true;
            }        
        }, 100);
        
    }
    
	hideData(event){
        // this.openTile = false;
        setTimeout(() => {
            this.openTile = false;
        }, 100);

    }
    
    goToData(event){
        let targetId = event.target.dataset.targetId;

        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: targetId,
                objectApiName: 'FinServ__FinancialAccount__c', // objectApiName is optional
                actionName: 'view'
            }
        });
    }

    goToDataUrl(event){
        let targetId = event.target.dataset.targetId;
        let targetObjectApiName = event.target.dataset.targetObjectApiName;

        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: targetId,
                objectApiName: targetObjectApiName, // objectApiName is optional
                actionName: 'view'
            }
        });
    }
}