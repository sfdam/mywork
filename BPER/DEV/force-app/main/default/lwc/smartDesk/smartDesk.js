import { LightningElement, track, api, wire } from 'lwc';
import init from '@salesforce/apex/MakeRequestV2Controller.init';
//import getResponse from '@salesforce/apex/MakeRequestV2Controller.getResponse';
import jsonWrapper from '@salesforce/resourceUrl/jsonWrapper_v2';
import getResponse from '@salesforce/apex/SmartDeskController.getTestResponse';
//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SmartDesk extends LightningElement {
    
    @api recordId;
    @api apiRequests = 'searchBox';
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

    columns =
    [
         { label: 'Id Pratica', fieldName: 'IdPratica', type: 'text' },
         { label: 'Id Documento', fieldName: 'IdDocument', type: 'text' },
         { label: 'Stato', fieldName: 'stato', type: 'text' },
         { label: 'Nome Pratica', fieldName: 'nomePratica', type: 'text' },
         { label: 'Data Creazione', fieldName: 'dataCreazione', type: "date-local", typeAttributes:{ month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit" } },
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
            //console.log('record:', this.record);
            console.log('result:', JSON.stringify(result));
            //this.isRendered = true;
            this.loadRows()
        }).catch((error) => {
            console.log('DK init.error:', error);
        })
    }

    loadRows(){
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
            //if(result.response.statusCode == '200'){
            if(true){
                //let payload = JSON.parse(result.response.data);
                let payload = JSON.parse(result);
                console.log('Dk payload', payload);
                let newList = [];
                payload.list.forEach(element =>{
                    newList.push(
                    {
                        //IdPratica: 1,
                        //IdDocument: 2,
                        IdPratica: element.boxDocumentList[0].boxId,
                        IdDocument: element.boxDocumentList[0].id,
                        stato: element.status.descrizione,
                        nomePratica: element.boxDocumentList[0].customTitle,
                        dataCreazione: element.dataCreazione
                    })
                    //element.CRM_dataContabile = new Date(element.dataContabile.split('T')[0]);
                    //element.CRM_dataValuta = new Date(element.dataValuta.split('T')[0]);
                })
                console.log('MS newList', JSON.stringify(newList));
                this.listaMovimenti = newList;
                this.filteredListaMovimenti = this.listaMovimenti;
                this.setPages(this.filteredListaMovimenti);
            }
        })
        .catch((error) => {
            this.isRendered = true;
            console.log('MS error ', JSON.stringify(error));
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