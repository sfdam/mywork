import { LightningElement, track, api, wire } from 'lwc';
import getAllData from '@salesforce/apex/CRM_MemoController.getAllData';
import { NavigationMixin } from "lightning/navigation";

import img_ndgcointestatario from '@salesforce/resourceUrl/ndgcointestatario';
import img_ndgintestatario from '@salesforce/resourceUrl/ndgintestatario';

const columns = [
    //{ label: 'Tipo', type: 'image',initialWidth: 70, typeAttributes:{url: {fieldName:'immagine'}},},
    { label: 'TITOLO', fieldName: 'elementId', type:'url',sortable:"true",
        typeAttributes: {
            label: { fieldName: 'titolo' }
        },
    },
    { label: 'TIPOLOGIA', fieldName: 'tipologia', type: 'text' },
    { label: 'FINE VALIDITA\'', fieldName: 'fineValidita', type: 'date',sortable:"true"},
    { label: 'POPUP DI CASSA', fieldName: 'popupCassa', type: 'boolean'},
];


export default class Crm_memo extends NavigationMixin(LightningElement) {


    @track isRendered;
    @track isViewAll = false;
    @track columns = [];
    @track data = [];
    @track allData = [];
    @api recordId;
    @track numberAll = 0;
    @api title;
    @api pagina;
    /*@track sortBy;
    @track sortByAll;
    @track sortDirection;
    @track sortDirectionAll;*/
    @track notShowComponent;
    @api viewAllLabel;
    @track recTypeId;
    @api objectApiName;
    @api builderIcon;
    @track record = null;
    @track subscription = {};
    @track noDataMessage='';
    

    connectedCallback() {
        //console.log("ICONA->",builderIcon);
        this.columns = columns;
        this.noDataMessage='';
        //this.registerErrorListener();
        var description;
        //window.addEventListener('beforeunload', this.beforeUnloadHandler.bind(this));
        this.isRendered = false;
        console.log('CRM_MEMO - recordId: ' + this.recordId);

        getAllData({ recordId: this.recordId }).
            then(result => {
                console.log('CRM_MEMO - query result: ' ,result);
                this.notShowComponent = false;

                let memoList = [];
                result.forEach(element => {

                    element.elementId='/'+element.elementId;
                        
                    memoList.push(element);
                });
                
                this.allData = memoList;
                this.data=[];

               

                let sortBy = 'fineValidita';
                let sortDirection = 'desc';
                this.sortDataAll(sortBy, sortDirection);
                memoList= this.allData;

                if (memoList.length > 5) {
                    for (let i = 0; i < 5; i++) {
                        this.data.push(memoList[i]);
                    }
                }
                else {
                    this.data = memoList;
                }
                this.numberAll = memoList.length;

                if(this.numberAll==0)
                    this.noDataMessage="No data returned";

            }).catch(error => {
                console.log('DK init.error 1: ' + JSON.stringify(error));
            }).finally(() => {
                this.isRendered = true;

            });
    }


    /*doSortingAll(event){
        let sortBy;
        this.sortByAll = event.detail.fieldName;
        if(event.detail.fieldName==='fineValidita'){
            sortBy = 'fineValidita';
        }
        else{
            sortBy = event.detail.fieldName;
        }
        this.sortDirectionAll = event.detail.sortDirection;
        console.log('@@@sortby: '+this.sortByAll);
        console.log('@@@sortby: '+sortBy);
        console.log('@@@sortDirection: '+this.sortDirectionAll);

        this.sortDataAll(sortBy, this.sortDirectionAll);
    }*/

    sortDataAll(fieldname, direction){

       // if(this.isViewAll){
            let parseData = this.allData;
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
            // set the sorted data to data table data
            this.allData = parseData;
      //  }

    }

    sortData(fieldname, direction) {
         let parseData = this.data;
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        // set the sorted data to data table data
        this.data = parseData;
        console.log('@@@@ LPSort: ' + JSON.stringify(this.data.length));
    }

    handleViewAll(){
        this.isViewAll=true;
    }
    closeModal(){
        this.isViewAll=false;
    }

    refreshClick(){
        this.connectedCallback();
    }

}