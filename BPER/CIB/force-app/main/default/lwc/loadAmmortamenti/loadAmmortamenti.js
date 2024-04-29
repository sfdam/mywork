import { LightningElement, track, api, wire } from 'lwc';
import init from '@salesforce/apex/LoadAmmortamentiController.init';
import getResponse from '@salesforce/apex/MakeRequestV2Controller.getResponse';
import save from '@salesforce/apex/LoadAmmortamentiController.save';
import jsonWrapper from '@salesforce/resourceUrl/jsonWrapper_v2';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LoadAmmortamenti extends LightningElement {

    @api recordId;
    linee;

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
        parseJSONMap[this.apiRequests] = this.parsedJson[this.apiRequests].fields;
        conditionsMap[this.apiRequests] = this.parsedJson[this.apiRequests].conditionList ? this.parsedJson[this.apiRequests].conditionList : null;

        init({recordId: this.recordId, parseJSONMap: parseJSONMap, conditionsMap: conditionsMap, additionalFields : null})
        .then(result => {
            console.log('DK LoadAmmortamenti init result', result);
            if(result['linee']){
                this.linee = result['linee'];
                console.log('linee:', this.linee);
                this.isRendered = true;
                let apexPromises = [];
                if(this.linee.length > 0){
                    this.linee.forEach(linea =>{
                        apexPromises.push(getResponse({
                            record: linea,
                            requestToApiGateway: 'loadAmmortamentoLinea',
                            parseJSON: this.parsedJson['loadAmmortamentoLinea'].fields,
                            conditions: this.parsedJson['loadAmmortamentoLinea'].conditionList ? this.parsedJson['loadAmmortamentoLinea'].conditionList : null,
                            certificateName: this.certificateName,
                            disableLog: this.disableLog,
                            addingParamsMap: null
                            }
                        ));
                    })
                    console.log('DK LoadAmmortamenti init apexPromises: ', JSON.stringify(apexPromises));
                    this.resolveApexPromises(apexPromises);
                }else{
                    this.servizioCalled = true;
                }
            }
        }).catch((error) => {
            console.log('DK LoadAmmortamenti init error:', error.message);
        })
    }

    resolveApexPromises(apexPromises) {

        let isOK = false;
        try {
            
            Promise.all(apexPromises)
            .then((resultServizi) => {
                let recordsToUpdateList = [];
                let recordToInsertList = [];
                let errorResponse = [];
                resultServizi.forEach(result => {
                    console.log('DK LoadAmmortamenti resolveApexPromises result', result);
                    let recordToUpdate = result.record;
                    if(result.response.statusCode == '200'){
                        let payload = JSON.parse(result.response.data);
                        console.log('Dk LoadAmmortamenti resolveApexPromises payload', JSON.stringify(payload));
                        console.log('Dk LoadAmmortamenti resolveApexPromises recordToUpdate', JSON.stringify(recordToUpdate));
    
                        recordToUpdate.ServizioAmmortamento__c = true;
                        recordsToUpdateList.push(recordToUpdate);
                        payload.engineAmmortamentoOutputVm.ammortamentoResultOutput.forEach(element =>{
                            let ratatoInsert = {};
                            ratatoInsert.Linea__c = recordToUpdate.Id;
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
                    }else{
                        errorResponse.push(recordToUpdate.Name)
                    }
                });
                if(errorResponse.length > 0){
    
                    this.errorServizioCalled = true;
                    const toastEvent = new ShowToastEvent({
                        title: "Attenzione!",
                        message: 'La richiesta non è andata a buon fine per le seguenti linee: ' + errorResponse.join(', '),
                        variant: "warning"
                    });
                    this.dispatchEvent(toastEvent);
                }
                console.log('DK LoadAmmortamenti resolveApexPromises recordsToUpdateList', recordsToUpdateList.length);
                console.log('DK LoadAmmortamenti resolveApexPromises recordToInsertList', recordToInsertList.length);
                if(recordsToUpdateList.length > 0 && recordToInsertList.length > 0){
                    
                    console.log('DK eseguo Save');
                    save({recordsToUpdateList: recordsToUpdateList, rateToInsert: recordToInsertList})
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
                        console.log('DK LoadAmmortamenti resolveApexPromises save err', err);
                    })
                    .finally(() =>{
                        this.isRendered = true;
                    })
                }
            })
            .catch(err =>{
                console.log(err);
            });
        } catch (error) {
            console.log('DK error', error);
        }
    }
}