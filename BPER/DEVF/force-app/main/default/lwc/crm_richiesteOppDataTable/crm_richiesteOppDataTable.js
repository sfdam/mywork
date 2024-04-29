import { LightningElement, track, api } from 'lwc';
import getAllData from '@salesforce/apex/richiesteOpportunityDataTableController.getAllData';

const columns = [
    { label: 'Data Creazione', fieldName: 'dataCreazione', type: 'text', hideDefaultActions: true, sortable: true },
    { label: 'Nome', fieldName: 'Opp_Url', type: 'url',typeAttributes: {label: { fieldName: 'Name' }},hideDefaultActions: true, sortable: true },
    { label: 'Ndg', fieldName: 'CRM_NDG__c', type: 'text', hideDefaultActions: true, sortable: true },
    { label: 'Oggetto', fieldName: 'CRM_Oggetto__c', type: 'text', hideDefaultActions: true, sortable: true },
    { label: 'Origine', fieldName: 'CRM_Canale__c', type: 'text', hideDefaultActions: true, sortable: true },
    { label: 'Bisogno', fieldName: 'CRMBisogno', type: 'text', hideDefaultActions: true, sortable: true },
    { label: 'Data Scadenza', fieldName: 'dataScadenza', type: 'text', hideDefaultActions: true, sortable: true },
    { label: 'Fase', fieldName: 'StageName', type: 'text', hideDefaultActions: true, sortable: true },
    { label: 'Esito Processo', fieldName: 'CRM_EsitoContatto__c', type: 'text', hideDefaultActions: true, sortable: true },
    { label: 'Autore', fieldName: 'CRMAutore', type: 'text', hideDefaultActions: true, sortable: true },
    { label: 'Stato dell’opportunità', fieldName: 'CRM_FaseFormula__c', type: 'text', hideDefaultActions: true, sortable: true }
];

export default class Crm_richiesteOppDataTable extends LightningElement {

    @api widthc01;
    @api widthc02;
    @api widthc03;
    @api widthc04;
    @api widthc05;
    @api widthc06;
    @api widthc07;
    @api widthc08;
    @api widthc09;
    @api widthc10;
    @api widthc11;
    @api flowLabel;
    @track columnsOrder = ['widthc01','widthc02','widthc03','widthc04','widthc05','widthc06','widthc07','widthc08','widthc09','widthc10','widthc11'];
    @track isRendered;
    @track isViewAll = false;
    @track columns = [];
    @track data = [];
    @track allData = [];
    @api recordId;
    @track numberAll = 0;
    @api title;
    @api pagina;
    @track sortBy;
    @track sortByAll;
    @track sortDirection;
    @track sortDirectionAll;
    @track notShowComponent;
    @api viewAllLabel;
    @track subscription = {};

    dataFormatter(dateString) {
        const options = { year: 'numeric', month: '2-digit', day: '2-digit' };
        return new Date(dateString).toLocaleDateString(undefined, options);
    }

    connectedCallback() {
        this.columns = this.adjustColumns(columns, this.columnsOrder);
        this.isRendered = false;
        this.sortBy = 'Opp_Url';
        this.sortByAll = 'Opp_Url';
        this.sortDirection = 'desc';
        this.sortDirectionAll = 'desc';
    
        if (this.data.length === 0) {
            getAllData({ recordId: this.recordId })
                .then(result => {
                    console.log('getAllDataresult : ---> ', JSON.stringify(result));
                    let oppData = [];
                    result.forEach(element => {
                        console.log('element.Id: --->', JSON.stringify(element.Id));
                        element.CRM_NDG__c = element.Account.CRM_NDG__c;
                        //element.CRM_Oggetto__c = element.CRM_Prodotto__r.CRM_MacroGroup__c;
                        if(element.CRM_Prodotto__c!=null){
                            element.CRM_Bisogno__c = element.CRM_Prodotto__r.CRM_Bisogno__c;
                        }else{
                            element.CRMBisogno = element.CRM_Bisogno__c;
                        }
                        element.CRMAutore = element.CRM_AutoreCH__c;
                        element.dataCreazione = this.dataFormatter(element.CreatedDate);
                        element.dataScadenza = this.dataFormatter(element.CloseDate);
                        if (element.StageName === 'Closed Won' || (element.StageName === 'Closed Lost')) {
                            element.StageName = 'Chiuso';
                        }
                        element.Opp_Url = '/' + element.Id;
                        oppData.push(element);
                    });
                    this.data = oppData;
                    this.numberAll = oppData.length;
                })
                .catch(error => {
                    console.log('DK init.error: ' + JSON.stringify(error.body));
                    this.notShowComponent = true;
                }).finally(()=>{
                    this.isRendered=true;
                });
        }
    }
    doSorting(event){
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        console.log('@@@sortby: '+this.sortBy);
        console.log('@@@sortDirection: '+this.sortDirection);
        this.sortData(this.sortBy, this.sortDirection);
    }
    sortData(fieldname, direction){
        let parseData = JSON.parse(JSON.stringify(this.data));
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
        this.data = parseData;
        console.log('@@@@ LPSort: '+JSON.stringify(this.data));
    }
    handleViewAll(){
        this.isViewAll=true;
    }
    closeModal(){
        this.isViewAll=false;
    }
    handleClickNew() {  
        //fire event
        const flowEvent = new CustomEvent("flowevent", {
          });
          // Fire the custom event
          this.dispatchEvent(flowEvent);
    }
    refreshClick(){
        this.connectedCallback();
    }
    adjustColumns(col,order) {
        let values = [];
        for (var i=0; i<order.length; i++) {
            if (order[i]=='widthc01') {
                values.push(this.widthc01!=undefined && this.widthc01!=null ? this.widthc01 : 50);   
            }
            else if (order[i]=='widthc02') {
                values.push(this.widthc02!=undefined && this.widthc02!=null ? this.widthc02 : 50);   
            }
            else if (order[i]=='widthc03') {
                values.push(this.widthc03!=undefined && this.widthc03!=null ? this.widthc03 : 50);   
            }
            else if (order[i]=='widthc04') {
                values.push(this.widthc04!=undefined && this.widthc04!=null ? this.widthc04 : 50);   
            }
            else if (order[i]=='widthc05') {
                values.push(this.widthc05!=undefined && this.widthc05!=null ? this.widthc05 : 50);   
            }
            else if (order[i]=='widthc06') {
                values.push(this.widthc06!=undefined && this.widthc06!=null ? this.widthc06 : 50);   
            }
            else if (order[i]=='widthc07') {
                values.push(this.widthc07!=undefined && this.widthc07!=null ? this.widthc07 : 50);   
            }
            else if (order[i]=='widthc08') {
                values.push(this.widthc08!=undefined && this.widthc08!=null ? this.widthc08 : 50);   
            }
            else if (order[i]=='widthc09') {
                values.push(this.widthc09!=undefined && this.widthc09!=null ? this.widthc09 : 50);   
            }
            else if (order[i]=='widthc10') {
                values.push(this.widthc10!=undefined && this.widthc10!=null ? this.widthc10 : 50);   
            }
            else if (order[i]=='widthc11') {
                values.push(this.widthc11!=undefined && this.widthc11!=null ? this.widthc11 : 50);   
            }
        }
        for (var i=0; i<col.length; i++) {
            col[i].fixedWidth=values[i];
        }
        return col;
    }
}