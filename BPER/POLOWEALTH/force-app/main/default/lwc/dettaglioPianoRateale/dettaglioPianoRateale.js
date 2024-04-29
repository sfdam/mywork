import { LightningElement, track, api, wire } from 'lwc';
import init from '@salesforce/apex/MakeRequestV2Controller.init';
import getResponse from '@salesforce/apex/MakeRequestV2Controller.getResponse';
import jsonWrapper from '@salesforce/resourceUrl/jsonWrapper_v2';
//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DettaglioPianoRateale extends LightningElement {
    
    @api recordId;
    @api apiRequests = 'dettaglioPianoRateale';
    @api certificateName;
    @api disableLog;
    @api title;
    @api buttonLabel;

    @track isRendered = false;

    @track pageSizeOptions = [
        {label: '10', value: '10'},
        {label: '20', value: '20'},
        {label: '50', value: '50'},
        {label: '100', value: '100'}
    ];

    columns = [
        { label: 'Descrizione Movimento', fieldName: 'descrizione', type: 'text', wrapText: true, initialWidth: 800},
        { label: 'Importo Movimento', fieldName: 'importo', type: 'currency', cellAttributes: { alignment: 'left' }, typeAttributes: { maximumFractionDigits: '2'}, wrapText: true},
        { label: 'Causale Movimento', fieldName: 'causaleMovimento', type: 'text', wrapText: true},
        { label: 'Data Contabile', fieldName: 'CRM_dataContabile', type: 'date', wrapText: true},
        { label: 'Data Valuta', fieldName: 'CRM_dataValuta', type: 'date', wrapText: true},
    ];

    parsedJson;

    @track listaMovimenti;
    @track filteredListaMovimenti = [];
    connectedCallback(){

        // Create a request for the JSON data and load it synchronously,
        // parsing the response as JSON into the tracked property
        let request = new XMLHttpRequest();
        request.open("GET", jsonWrapper, false);
        request.send(null);
        this.parsedJson = JSON.parse(request.responseText);
        let parseJSONMap = {};
        let conditionsMap = {};

        parseJSONMap[this.apiRequests] = this.parsedJson[this.apiRequests].fields;
        conditionsMap[this.apiRequests] = this.parsedJson[this.apiRequests].conditionList ? this.parsedJson[this.apiRequests].conditionList : null;

        init({recordId: this.recordId, parseJSONMap: parseJSONMap, conditionsMap: conditionsMap, additionalFields : null})
        .then(result => {
            
            this.record = result['record'];
            this.relatedListMap = result['relatedListMap'];
            console.log('record:', this.record);
            this.isRendered = true;
        }).catch((error) => {
            console.log('DK init.error:', error);
        })
    }

    handleSendRequest(){
        this.isRendered = false;
        getResponse({
            record: this.record,
            requestToApiGateway: this.apiRequests,
            parseJSON: this.parsedJson[this.apiRequests].fields,
            conditions: this.parsedJson[this.apiRequests].conditionList ? this.parsedJson[this.apiRequests].conditionList : null,
            certificateName: this.certificateName,
            disableLog: this.disableLog,
            addingParamsMap: {}
        })
        .then(result =>{
            console.log('DK resolveApexPromises.result', result);
            if(result.response.statusCode == '200'){
                let payload = JSON.parse(result.response.data);
                console.log('Dk payload', payload);
                payload.listaMovimenti.forEach(element =>{
                    element.CRM_dataContabile = new Date(element.dataContabile.split('T')[0]);
                    element.CRM_dataValuta = new Date(element.dataValuta.split('T')[0]);
                })
                this.listaMovimenti = payload.listaMovimenti;
                this.filteredListaMovimenti = payload.listaMovimenti;
                this.setPages(this.filteredListaMovimenti);
            }
        })
        .catch((error) => {
            this.isRendered = true;
            console.log(error);
        })
        .finally(() => {
            console.log('Finally');
            this.isRendered = true;
        });
    }

    //Test Pagination
    @track page = 1;
    perpage = 20;
    perpageStr = '20';
    @track pages = [];
    set_size = 20;
    

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
        let listaMovimentiToDisplay = this.filteredListaMovimenti.slice(startIndex,endIndex);
        return listaMovimentiToDisplay;
    }

    setPages = (data)=>{
        this.pages = [];
        let numberOfPages = Math.ceil(data.length / this.perpage);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
        console.log('DK this.pages: ' + this.pages);
    }  
    
    get disabledButtonIndietro(){
        return this.page === 1;
    }
    
    get disabledButtonAvanti(){
        return this.page === this.pages.length || this.filteredListaMovimenti.length === 0
    }

    get currentPageData(){
        return this.pageData();
    }

    handlePageSizePick(event){
        let oldPerPage = this.perpage;
        this.perpageStr = event.target.value;
        this.perpage=Number(event.target.value);
        this.set_size=Number(event.target.value);
        console.log('DK oldPerPage:' + oldPerPage);
        console.log('DK perpage:' + this.perpage);
        this.page = 1;
        this.setPages(this.filteredListaMovimenti);
    }
}