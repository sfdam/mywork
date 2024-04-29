import { LightningElement, api,track } from 'lwc';
import getOrders from '@salesforce/apex/ART_OrderController.getOrders';
 
const COLUMNS = [
    { label: 'Order Number', fieldName: 'nameUrl', type: 'url', 
        typeAttributes: { 
            label: { fieldName: 'OrderNumber' }, 
            target: '_blank',
            name: 'view_details', title: 'Click to View Details' 
        },
        sortable:true 
        },
    { label: 'Status', fieldName: 'Status',type:'text', sortable: true },
    { label: 'Order Insert Date', fieldName: 'EffectiveDate', type: 'date', sortable: true },
    { label: 'Order Net Value', fieldName: 'TotalAmount', type: 'currency', sortable: true }
];
const PAGE_SIZE=5;
export default class OrderTable extends LightningElement {
    @api recordId;
    app = [];
    @track orderlist = [];
    allorderlist = [];
    @track error;
    sortedBy;
    sortDirection;
    totalNumberOfRows = 100; // stop the infinite load after this threshold count
    recordCount = 10;
    loadMoreStatus;
    totalRecountCount = 0;
    targetDatatable; // capture the loadmore event to fetch data and stop infinite loading
    _isLoading = true;

    title = 'Ordini ERP ({!totRecord})';
    
    get columns() {
        return COLUMNS;
    }

    connectedCallback(){
        getOrders({accountId: this.recordId})
            .then(result => {
                let nameUrl;
                this.app = result.map(row => { 
                    nameUrl = `/${row.Id}`;
                    return {...row , nameUrl} //questo serve per rendere cliccabile il name
                })
                this.error = null;
                this.totalRecountCount = this.app.length;
                this.title = this.title.replace('{!totRecord}', this.totalRecountCount);
                this.allorderlist = [...this.allorderlist, ...this.app];
                this.orderlist = this.allorderlist.slice(0, this.recordCount); 
                if(this.allorderlist.length<= 0){
                    this.error = 'Non sono presenti ordini da visualizzare';
                }
                this._isLoading = false
            }).catch(error => {
                console.log(error);
                this.error=error;
                this.orderlist = undefined;
                this.allorderlist = undefined;
                this._isLoading = false
            });
    }
    
    // Event to handle onloadmore on lightning datatable markup
    handleLoadMore(event) {
        debugger;
        //Set the onloadmore event taraget to make it visible to imperative call response to apex.
        this.targetDatatable = event.target;

        //Display a spinner to signal that data is being loaded
        if(this.targetDatatable){
            this.targetDatatable.isLoading = true;
        }

        //Display "Loading" when more data is being loaded
        this.loadMoreStatus = 'Loading';

        // increase the record Count by 10 on every loadmore event
        this.recordCount = this.recordCount + 10;
        // Get new set of records and append to this.orderlist
        if(this.recordCount > this.totalRecountCount){
            this.recordCount = this.totalRecountCount;
            this.targetDatatable.enableInfiniteLoading = false;
        }
        //this.recordCount = (this.recordCount > this.totalRecountCount) ? this.totalRecountCount : this.recordCount; 
        this.orderlist = this.allorderlist.slice(0, this.recordCount);
        this.loadMoreStatus = '';
        if (this.targetDatatable){
            this.targetDatatable.isLoading = false;
        }
    }    
 
    handleSort(event) {
        debugger;
        //Attivo lo spinner
        this._isLoading = true;
        this.sortedBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        //Ordino l'intera lista di record
        this.sortData(this.sortedBy, this.sortDirection);
        //Data la lista totale ordinata, vado a ricalcolare il subset di record da mostrare all'utente
        this.orderlist = this.allorderlist.slice(0, this.recordCount);
        //Disattivo lo spinner
        this._isLoading = false;
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.allorderlist));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.allorderlist = parseData;
    }  
 
    handleRowAction(event) {
        const orderId = event.detail.row.Id;
        const navigateEvent = new CustomEvent('navigate', { detail: { pageName: 'orderDetails', attributes: { orderId: orderId } } });
        this.dispatchEvent(navigateEvent);
    }     
}