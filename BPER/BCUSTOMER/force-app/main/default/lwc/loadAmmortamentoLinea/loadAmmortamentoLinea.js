import { LightningElement, track, api, wire } from 'lwc';
import init from '@salesforce/apex/LoadAmmortamentoLineaController.init';
import getResponse from '@salesforce/apex/MakeRequestV2Controller.getResponse';
import save from '@salesforce/apex/LoadAmmortamentoLineaController.save';
import jsonWrapper from '@salesforce/resourceUrl/jsonWrapper_v2';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LoadAmmortamentoLinea extends LightningElement {
    @api recordId;
    record;
    rate;

    @api apiRequests = 'loadAmmortamentoLinea';
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

    @track servizioCalled = false;
    @track errorServizioCalled = false;
    connectedCallback(){

        let dataTableGlobalStyle = document.createElement('style');
        dataTableGlobalStyle.innerHTML = `
        .success-box{
            background-color: darkgreen;
            color: white;
        }
        .warning-box{
            background-color: orange;
            color: white;
        }`;
        document.head.appendChild(dataTableGlobalStyle);

        // Create a request for the JSON data and load it synchronously,
        // parsing the response as JSON into the tracked property
        let request = new XMLHttpRequest();
        request.open("GET", jsonWrapper, false);
        request.send(null);
        this.parsedJson = JSON.parse(request.responseText);
        let parseJSONMap = {};
        let conditionsMap = {};
        console.log('TEST --> ' + JSON.stringify(this.parsedJson));
        console.log('TEST --> ' + this.apiRequests);
        console.log('TEST --> ' + this.parsedJson[this.apiRequests]);
        parseJSONMap[this.apiRequests] = this.parsedJson[this.apiRequests].fields;
        conditionsMap[this.apiRequests] = this.parsedJson[this.apiRequests].conditionList ? this.parsedJson[this.apiRequests].conditionList : null;

        init({recordId: this.recordId, parseJSONMap: parseJSONMap, conditionsMap: conditionsMap, additionalFields : null})
        .then(result => {
            console.log('DK result', result);
            if(result['record'].length > 0){
                this.record = result['record'][0];
                console.log('record:', this.record);
                this.isRendered = true;
                if(!this.record.ServizioAmmortamento__c){
    
                    this.handleSendRequest();
                }else{
                    this.servizioCalled = true;
                }
            }
        }).catch((error) => {
            console.log('DK LoadAmmortamentoLinea connectedCallback init.error:', error.message);
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
                //let payload = JSON.parse('{"engineAmmortamentoOutputVm":{"ammortamentoResultOutput":[{"parametriAnnualiTassoAttivo":{"baseFisso": 0,"baseVariabile": 0,"commissioneDiFirma": 0,"deltaTassoSpread1": 0,"deltaTassoSpread2": 0,"deltaTassoSpread3": 0,"deltaTassoSpread4": 0,"deltaTassoSpread5": 0,"interestStepCumulato": 0,"spreadFisso": 0,"spreadVariabile": 0,"tassoFisso": 0,"tassoPeriodaleCommissioneDiFirmaPeriodaleApplicata": 0,"tassoVariabile": 0},"pianoAmmortamento":{"accordato": 0,"debitoResiduoFinePeriodo": 0,"debitoResiduoInizioPeriodo": 0,"erogatoComulatoSAL": 0,"nonUtilizzato": 0,"numeroPeriodoNellAnno": 0,"numeroRata": 0,"percentualeNonUtilizzato": 0,"percentualeUtilizzo": 0,"percentualeUtilizzoPerSAL": 0,"quotaCapitale": 0,"quotaCapitaleResidua": 0,"quotaInteressi": 0,"riferimentoAnno": 0,"totaleRata": 0}}],"idAmmortamentoLinea": "string"}}');
                console.log('Dk payload', JSON.stringify(payload));
                this.record.ServizioAmmortamento__c = true;
                let recordToInsertList = [];
                payload.engineAmmortamentoOutputVm.ammortamentoResultOutput.forEach(element =>{
                    let ratatoInsert = {};
                    ratatoInsert.Linea__c = this.record.Id;
                    ratatoInsert.Type__c = 'Piano Ammortamento Output';
                    ratatoInsert.Numerorata__c = element.pianoAmmortamento.numeroRata;
                    ratatoInsert.Riferimentoanno__c = element.pianoAmmortamento.riferimentoAnno;
                    ratatoInsert.Numeroperiodonellanno__c = element.pianoAmmortamento.numeroPeriodoNellAnno;
                    ratatoInsert.Nonutilizzato__c = element.pianoAmmortamento.nonUtilizzato;
                    ratatoInsert.erogatoComulatoSAL__c = element.pianoAmmortamento.erogatoComulatoSAL;
                    ratatoInsert.debitoResiduoInizioPeriodo__c = element.pianoAmmortamento.debitoResiduoInizioPeriodo;
                    ratatoInsert.debitoResiduoFinePeriodo__c = element.pianoAmmortamento.debitoResiduoFinePeriodo;
                    ratatoInsert.quotaInteressiAmmortamento__c = element.pianoAmmortamento.quotaInteressi;
                    ratatoInsert.QuotaCapAmmortamento__c = element.pianoAmmortamento.quotaCapitale;
                    ratatoInsert.totaleRataAmmortamento__c = element.pianoAmmortamento.totaleRata;
                    ratatoInsert.PercNonutilizzato__c = element.pianoAmmortamento.percentualeNonUtilizzato;
                    ratatoInsert.percentualeUtilizzoAmmortamento__c = element.pianoAmmortamento.percentualeUtilizzo;
                    ratatoInsert.quotaCapitaleResiduaAmmortamento__c = element.pianoAmmortamento.quotaCapitaleResidua;
                    ratatoInsert.percentualeUtilizzoPerSAL__c = element.pianoAmmortamento.percentualeUtilizzoPerSAL;
                    ratatoInsert.Accordato__c = element.pianoAmmortamento.accordato;
                    ratatoInsert.tassoCommissioneDiFirmaPeriodale__c = element.parametriAnnualiTassoAttivo.tassoPeriodaleCommissioneDiFirmaPeriodaleApplicata;
                    ratatoInsert.commissioneDiFirma__c = element.parametriAnnualiTassoAttivo.commissioneDiFirma;
                    ratatoInsert.tassoFisso__c = element.parametriAnnualiTassoAttivo.tassoFisso;
                    ratatoInsert.baseFisso__c = element.parametriAnnualiTassoAttivo.baseFisso;
                    ratatoInsert.spreadFisso__c = element.parametriAnnualiTassoAttivo.spreadFisso;
                    ratatoInsert.tassoVariabile__c = element.parametriAnnualiTassoAttivo.tassoVariabile;
                    ratatoInsert.baseVariabile__c = element.parametriAnnualiTassoAttivo.baseVariabile;
                    ratatoInsert.spreadVariabile__c = element.parametriAnnualiTassoAttivo.spreadVariabile;
                    ratatoInsert.interestStepCumulato__c = element.parametriAnnualiTassoAttivo.interestStepCumulato;
                    ratatoInsert.deltaTassoSpread1__c = element.parametriAnnualiTassoAttivo.deltaTassoSpread1;
                    ratatoInsert.deltaTassoSpread2__c = element.parametriAnnualiTassoAttivo.deltaTassoSpread2;
                    ratatoInsert.deltaTassoSpread3__c = element.parametriAnnualiTassoAttivo.deltaTassoSpread3;
                    ratatoInsert.deltaTassoSpread4__c = element.parametriAnnualiTassoAttivo.deltaTassoSpread4;
                    ratatoInsert.deltaTassoSpread5__c = element.parametriAnnualiTassoAttivo.deltaTassoSpread5;
                    recordToInsertList.push(ratatoInsert);
                })
                console.log('DK recordToInsertList', recordToInsertList);
                save({record: this.record, rateToInsert: recordToInsertList})
                .then(() =>{
                    this.servizioCalled = true;
                    const toastEvent = new ShowToastEvent({
                        title: "Operazione conclusa!",
                        message: 'Rate Ammortamento inserite correttamente',
                        variant: "success"
                    });
                    this.dispatchEvent(toastEvent);
                })
                .catch(err =>{
                    console.log('DK loadAmmortamentoLinea save err', err);
                })
                .finally(() =>{
                    this.isRendered = true;
                })
            }else{
                this.errorServizioCalled = true;
                const toastEvent = new ShowToastEvent({
                    title: "Attenzione!",
                    message: 'La richiesta non è andata a buon fine.',
                    variant: "warning"
                });
                this.dispatchEvent(toastEvent);
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