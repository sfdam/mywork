import { LightningElement, api, track } from 'lwc';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import init from '@salesforce/apex/Cib_SimulazioneController.init';
import save from '@salesforce/apex/Cib_SimulazioneController.save';
import clone from '@salesforce/apex/Cib_SimulazioneController.clone';
import calculateSim from '@salesforce/apex/Cib_SimulazioneController.calculateSim';
import deleteLinea from '@salesforce/apex/Cib_SimulazioneController.deleteLinea';

import getResponse from '@salesforce/apex/MakeRequestV2Controller.getResponse';
import './cibSimulazione.css';

export default class CibSimulazione extends NavigationMixin(LightningElement) {
    @api recordId;
    @api certificateName = 'salesforceprodclient2024';
    @api disableLog = false;
    @track currentUser;
    
    @track isLoading;
    @track loaded = false;

    @api hideFooter = false;

    isNew = true;
    @api titoloSezione1 = 'Anagrafica';
    @api titoloSezione2 = 'Rischio controparte';
    @api titoloSezione3 = 'Informazioni di Base';
    @api titoloSezione4 = 'SAL';
    @api titoloMacroSezione1 = 'Caratteristiche della Controparte';
    @api titoloMacroSezione2 = 'Linee';
    @api labelBottone = 'Aggiungi linea';

    @track macroSezioniAttive = ['macroSezione1', 'macroSezione2'];
    @track sezioniAttive = ['sezione1', 'sezione2', 'sezione3', 'sezione4'];

    naturaGiuridicaMap = {
        'SPA': 'Società per azioni (S.p.a.)',
        'GF': 'Società finanziaria',
        'SRL': 'Società a responsabilità limitata (S.r.l.)',
        'COP': 'Società cooperativa',
        'SAPA': 'Società in accomandita per azioni (S.a.p.a.)'
    }

    @api opportunityId;
    @api accountId;
    //---------------------------- Simulazione__C Fields
    @track simulazione = {};
    
    //Anagrafica
    @track gestoreId
    @track gestore = {obj: {}, objId: undefined, name: undefined, sObjectName: 'User', iconName: 'standard:user'};

    @track titolareOperazioneId
    @track titolareOperazione = {obj: {}, objId: null, name: null, sObjectName: 'User', iconName: 'standard:user'};

    @track lineeSimulazione = [];
    @track lineeSimulazioneMap = new Map();
    @track lineeSimulazioneCounter = 1;


    //OPTIONS
    @api optionsMap = {};
    @track optionsMDS
    @track optionsProvincia
    @track optionsSegmentoRischio
    @track optionsSegmentoModello
    @track optionsClasseRating
    @track optionsGiudizioSlottingCriteria
    @track optionsClasseMerito
    @track optionsSogliaFatturatoDiGruppo
    @track optionsNaturaGiuridica
    
    @track isProvinciaRequired = false;
    @track showClasseRating = false;
    @track showGiudizioSlottingCriteria = false;
    @track showClasseMerito = false;

    get optionsSINO() {
        return [
            { label: 'SI', value: true },
            { label: 'NO', value: false },
        ];
    }
    @track hasAnagrafica = false;
    @track mdsDisabled = false;
    @track hasNaturaGiuridica = false;
    connectedCallback(){
        let dataTableGlobalStyle = document.createElement('style');
        dataTableGlobalStyle.innerHTML = `
        .bper-green-header header.slds-media{
            background-color: #015256;
            color: white;
        }`;
        document.head.appendChild(dataTableGlobalStyle);
        try {
            console.log('DK START CibSimulazione connectedCallback');
            this.recordId = this.recordId !== 'null' ? this.recordId : null;
            console.log('DK CibSimulazione connectedCallback recordId', typeof this.recordId);
            console.log('DK CibSimulazione connectedCallback opportunityId', this.opportunityId);
            console.log('DK CibSimulazione connectedCallback accountId', this.accountId);
            this.isLoading = true;
            console.log('DK SET isLoading', this.isLoading);
            return init({recordId: this.recordId, opportunityId: this.opportunityId, accountId: this.accountId})
            .then(result =>{
                console.log('DK CibSimulazione.init result', result);
                if(result){
                    this.optionsMap = result['optionsMap'];
                    this.currentUser = result['currentUser'][0];
                    if(result['recordInfo']){
                        this.isNew = false;
                        //MODIFICA SIMULAIONE
                        console.log('DK MODIFICA SIMULAIONE');
                        this.simulazione = result['recordInfo'];
                        // this.simulazione.Segmento_Modello__c = result['segmentoModello'];
                        if(!this.simulazione.Preammortamento__c)this.simulazione.Preammortamento__c = '';
                        this.hasAnagrafica = this.simulazione.Opportunity__r ? Boolean(this.simulazione.Opportunity__r.AccountId) : Boolean(this.simulazione.Account__c);
                        console.log('DK CibSimulazione connectedCallback titolareOperazione START', JSON.stringify(this.titolareOperazione));
                        if(this.simulazione.Nome_titolare_operazione__r){
                            this.titolareOperazioneId = this.currentUser.Id;
                            this.titolareOperazione.objId = this.simulazione.Nome_titolare_operazione__c;
                            this.titolareOperazione.obj.Id = this.simulazione.Nome_titolare_operazione__c;
                            this.titolareOperazione.obj.name = this.simulazione.Nome_titolare_operazione__r.Name;
                            this.titolareOperazione.name = this.simulazione.Nome_titolare_operazione__r.Name;
                            this.titolareOperazione.sObjectName = 'User';
                            this.titolareOperazione.iconName = 'standard:user';
                        }else{
                            this.titolareOperazione = null;
                        }
                        console.log('DK CibSimulazione connectedCallback titolareOperazione START final', JSON.stringify(this.titolareOperazione));

                        if(this.simulazione.Nome_del_Gestore__r){
                            this.gestoreId = this.simulazione.Nome_del_Gestore__c;
                            this.gestore.objId = this.simulazione.Nome_del_Gestore__c;
                            this.gestore.obj.Id = this.simulazione.Nome_del_Gestore__c;
                            this.gestore.obj.name = this.simulazione.Nome_del_Gestore__r.Name;
                            this.gestore.name = this.simulazione.Nome_del_Gestore__r.Name;
                            this.gestore.sObjectName = 'user';
                            this.gestore.iconName = 'standard:user';
                        }else{
                            this.gestore = null;
                        }

                        this.lineeSimulazione = result['recordInfo'].Linee__r ? result['recordInfo'].Linee__r : [];
                    }else{

                        //NUOVA SIMULAIONE
                        console.log('DK NUOVA SIMULAIONE', JSON.stringify(this.currentUser));
                        let opportunity;
                        let ndg;
                        if(result['opportunity']){
                            opportunity = result['opportunity'][0];
                            ndg = opportunity.Account;
                        }else if(result['account']){
                            ndg = result['account'][0];
                        }
                        this.titolareOperazioneId = this.currentUser.Id;
                        this.titolareOperazione.objId = this.currentUser.Id;
                        this.titolareOperazione.obj.Id = this.currentUser.Id;
                        this.titolareOperazione.obj.name = this.currentUser.Name;
                        this.titolareOperazione.name = this.currentUser.Name;
                        this.titolareOperazione.sObjectName = 'User';
                        this.titolareOperazione.iconName = 'standard:user';

                        if(ndg && ndg.PTF_Portafoglio__r && ndg.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r){
                            this.gestoreId = ndg.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_User__c;
                            this.gestore.objId = ndg.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_User__c;
                            this.gestore.obj.Id = ndg.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_User__c;
                            this.gestore.obj.name = ndg.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.Name;
                            this.gestore.name = ndg.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.Name;
                            this.gestore.sObjectName = 'user';
                            this.gestore.iconName = 'standard:user';
                        }else{
                            this.gestore = null;
                        }
                        this.hasAnagrafica = Boolean(ndg);
                        this.simulazione.Opportunity__c = this.opportunityId;
                        this.simulazione.Account__c = this.accountId;
                        this.simulazione.Nome_del_Gestore__c = this.hasAnagrafica ? ndg.CRM_NomeCognomeReferente__c : null;
                        this.simulazione.Nome_titolare_operazione__c = this.currentUser.Name;
                        this.simulazione.Data_di_Valutazione__c = new Date().toISOString().split('T')[0];
                        this.simulazione.NDG__c = this.hasAnagrafica ? ndg.CRM_NDG__c : null;
                        this.simulazione.Segmento_di_Rischio__c = this.hasAnagrafica ? ndg.CRM_SegmentoRischioUfficiale__c : 'SMA00';
                        this.simulazione.Classe_di_rating__c = this.hasAnagrafica ? ndg.CRM_CreditRating__c : null;
                        this.simulazione.Denominazione__c = this.hasAnagrafica ? ndg.Name : null;
                        this.simulazione.Natura_Giuridica__c = this.hasAnagrafica && ndg.CRM_NaturaGiuridica__c && this.naturaGiuridicaMap[ndg.CRM_NaturaGiuridica__c] ? this.naturaGiuridicaMap[ndg.CRM_NaturaGiuridica__c] : null;
                        this.hasNaturaGiuridica = Boolean(this.simulazione.Natura_Giuridica__c);
                        console.log('DK this.simulazione.Natura_Giuridica__c', this.simulazione.Natura_Giuridica__c);
                        this.simulazione.NDG_di_Gruppo__c = this.hasAnagrafica ? ndg.NDG_Gruppo_Aziendale__c : null;
                        this.simulazione.Modello_di_Servizio__c = this.hasAnagrafica ? ndg.ModelloDiServizio__c : null;
                        this.simulazione.Provincia__c = this.hasAnagrafica && ndg.CRM_ProvinciaIscrizioneCCIAA__c ? this.provinciaValueMap[ndg.CRM_ProvinciaIscrizioneCCIAA__c.toUpperCase()] : null;
                        this.simulazione.AreaGeografica__c = this.simulazione.Provincia__c ? this.areaGeograficaMapping[this.simulazione.Provincia__c] : null;
                        this.simulazione.Infrastructure_support_factor__c = false;
                        this.simulazione.Soglia_fatturato_di_gruppo__c = '>=50MLN';
                    }
                    for(var i = 0; i < this.lineeSimulazione.length; i++){
                        this.lineeSimulazione[i].Number__c = i+1;
                        this.lineeSimulazione[i].Rate_Linee__r = result['rateLineaMap'] && result['rateLineaMap'][this.lineeSimulazione[i].Id] ? result['rateLineaMap'][this.lineeSimulazione[i].Id] : [];
                    }

                    this.lineeSimulazioneCounter = this.lineeSimulazione.length+1;
                    this.optionsMDS = this.optionsMap['Modello_di_Servizio__c'];
                    if(this.simulazione.Modello_di_Servizio__c && !this.optionsMDS.map(element => element.value.toLowerCase()).includes(this.simulazione.Modello_di_Servizio__c.toLowerCase())){
                        this.simulazione.Modello_di_Servizio__c = null;
                    }
                    this.optionsProvincia = this.optionsMap['Provincia__c'];
                    this.optionsSegmentoRischio = this.optionsMap['Segmento_di_Rischio__c'];
                    this.optionsSegmentoModello = this.optionsMap['Segmento_Modello__c']
                    this.optionsClasseRating = this.optionsMap['Classe_di_rating__c'];
                    this.optionsGiudizioSlottingCriteria = this.optionsMap['Giudizio_slotting_criteria__c'];
                    this.optionsClasseMerito = this.optionsMap['Classe_di_merito_altre_variabili__c'];
                    this.optionsSogliaFatturatoDiGruppo = this.optionsMap['Soglia_fatturato_di_gruppo__c'];
                    this.optionsNaturaGiuridica = this.optionsMap['Natura_Giuridica__c'];
                    console.log('DK CibSimulazione connectedCallback titolareOperazione', JSON.stringify(this.titolareOperazione));
                    console.log('DK CibSimulazione connectedCallback simulazione', JSON.stringify(this.simulazione));
                }
                this.mdsDisabled = this.hasAnagrafica && this.simulazione.Modello_di_Servizio__c && ['corporate', 'large corporate'].includes(this.simulazione.Modello_di_Servizio__c.toLowerCase());
                this.isLoading = false;
                console.log('DK SET isLoading', this.isLoading);
            })
            .catch(err =>{
                console.log('DK CibSimulazione.init.err', err.message);
                this.isLoading = false;
                console.log('DK SET isLoading', this.isLoading);
            })
            .finally(() =>{
                this.loaded = true;
                this.extendSimulazione();
            })
        } catch (err) {
            console.log('DK CibSimulazione connectedCallback.err', err.message);
        }
    }

    renderedCallback(){
        console.log('START renderedCallback');
        // gestione visibilità campi
        Object.keys(this.fieldVisibilityMap).forEach(masterField =>{
        
            if(this.fieldVisibilityMap[masterField]){
                let fieldVisibilitySet = [];
                Object.values(this.fieldVisibilityMap[masterField]).forEach(fieldSet =>{
                    fieldSet.forEach(field =>{
                        if(!fieldVisibilitySet.includes(field))fieldVisibilitySet.push(field);
                    })
                });
                console.log('DK fieldVisibilitySet', JSON.stringify(fieldVisibilitySet));
                if(this.fieldVisibilityMap[masterField][''+this.simulazione[masterField]]){
                    console.log('DK fieldVisibilitySet ENTRA');
                    this.template.querySelectorAll('.is-hide').forEach(inputField =>{
                        console.log('DK inputField: ' + inputField.name);
                        if(fieldVisibilitySet.includes(inputField.name)){
                            inputField.style.display = this.fieldVisibilityMap[masterField][''+this.simulazione[masterField]].includes(inputField.name) ? 'block' : 'none';
                            console.log('DK inputField.style.display: ' + inputField.style.display);
                        }
                    })
                }else{
                    console.log('DK fieldVisibilitySet NON CREDO PROPRIO');
                    this.template.querySelectorAll('.is-hide').forEach(inputField =>{
                        console.log('DK inputField: ' + inputField.name);
                        if(fieldVisibilitySet.includes(inputField.name)){
                            inputField.style.display = 'none';
                            console.log('DK inputField.style.display: ' + inputField.style.display);
                        }
                    })
                }
            }
        })

        // nascondi layout item vuoti
        this.template.querySelectorAll('.is-hide-layout-item').forEach(layoutItem =>{
            layoutItem.style.display = layoutItem.querySelector('.is-hide') ? layoutItem.querySelector('.is-hide').style.display : 'none';
        })
        //gestione RecordTypeOutput
        if(this.simulazione.RecordType && this.simulazione.RecordType.Name === 'Output'){
            this.template.querySelectorAll('.validate').forEach(field =>{
                field.disabled = true;
            });
        }
        console.log('END renderedCallback');
    }

    handleClone(){

        clone({recordId: this.recordId})
        .then(result =>{
            if(result){

                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result,
                        actionName: 'view'
                    }
                });
            }
        })
        .catch(err =>{
            console.log(err);
        })
    }

    sendRequestCalculate(){
        try {
            
            if(this.isInputValid()){
                this.handleSave(false, false, null).then(() =>{
                    this.isLoading = true;
                    // let last = this.returnRecord();
                    // this.simulazione = last.simulazione;
                    // this.lineeSimulazione = last.lineeSimulazione;
                    console.log('DK START POST simulazione', JSON.stringify(this.simulazione));
                    console.log('DK START POST lineeSimulazione', JSON.stringify(this.lineeSimulazione));
                    let requestObject = {calcoloEffettivoSimulazioneInputVm: []}
                    let caratteristicheControparte = {};
                    caratteristicheControparte.classeDiMerito = this.simulazione.Classe_di_merito_altre_variabili__c ? this.simulazione.Classe_di_merito_altre_variabili__c : null;
                    caratteristicheControparte.classeDiRating = this.simulazione.Classe_di_rating__c ? this.simulazione.Classe_di_rating__c : null;
                    caratteristicheControparte.classeDiRischiosita = this.simulazione.Classe_di_rischiosita__c ? this.simulazione.Classe_di_rischiosita__c : null;
                    caratteristicheControparte.dataDiValutazione = this.simulazione.Data_di_Valutazione__c ? this.simulazione.Data_di_Valutazione__c : null;
                    caratteristicheControparte.denominazione = this.simulazione.Denominazione__c ? this.simulazione.Denominazione__c : null;
                    caratteristicheControparte.fatturatoDiGruppo = this.simulazione.Fatturato_di_gruppo__c ? this.simulazione.Fatturato_di_gruppo__c : null;
                    caratteristicheControparte.giudizioSlottingCriteria = this.simulazione.Giudizio_slotting_criteria__c ? this.simulazione.Giudizio_slotting_criteria__c : null;
                    caratteristicheControparte.infrastrSuppFactor = this.simulazione.Infrastructure_support_factor__c ? this.simulazione.Infrastructure_support_factor__c : null;
                    caratteristicheControparte.modelloDiRating = this.simulazione.Modello_di_rating__c ? this.simulazione.Modello_di_rating__c : null;
                    caratteristicheControparte.modelloDiServizio = this.simulazione.Modello_di_Servizio__c ? this.simulazione.Modello_di_Servizio__c : null;
                    caratteristicheControparte.naturaGiuridica = this.simulazione.Natura_Giuridica__c ? this.simulazione.Natura_Giuridica__c : null;
                    caratteristicheControparte.ndg = this.simulazione.NDG__c ? this.simulazione.NDG__c : null;
                    caratteristicheControparte.ndggruppo = this.simulazione.NDG_di_Gruppo__c ? this.simulazione.NDG_di_Gruppo__c : null;
                    caratteristicheControparte.nomeDelGestore = this.simulazione.Nome_del_Gestore__r ? this.simulazione.Nome_del_Gestore__r.Name : null;
                    caratteristicheControparte.nomeTitolareOperazione = this.simulazione.Nome_titolare_operazione__r ? this.simulazione.Nome_titolare_operazione__r.Name : null;
                    caratteristicheControparte.pdMedia = this.simulazione.Probability_of_default_media__c ? this.simulazione.Probability_of_default_media__c : null;
                    caratteristicheControparte.provincia = this.simulazione.Provincia__c ? this.simulazione.Provincia__c : 'MISSING';
                    caratteristicheControparte.segmentoDiRischio = this.simulazione.Segmento_di_Rischio__c ? this.simulazione.Segmento_di_Rischio__c : null;
                    caratteristicheControparte.segmentoModello = this.simulazione.Segmento_Modello__c ? this.simulazione.Segmento_Modello__c : null;
                    caratteristicheControparte.sogliaDiFatturatoDiGruppo = this.simulazione.Soglia_fatturato_di_gruppo__c ? this.simulazione.Soglia_fatturato_di_gruppo__c : null;
                    this.lineeSimulazione.forEach(lineaSimulazione =>{
                        
                        let requestLinea = {caratteristicheControparte:caratteristicheControparte, commissioni:{}, strutturaLinea:{periodiAmmortamento:[],pianodiRimorsoManualmente:[]}, tasso:{valoriTassoAdHocInterestStep:[]}, variabiliGaranzie:{}};
                        requestLinea.idIdentificativoLinea = lineaSimulazione.Id ? lineaSimulazione.Id : null;
                        requestLinea.commissioni.cmuAnnuale = lineaSimulazione.CMUannuale__c ? Number(parseFloat(lineaSimulazione.CMUannuale__c/100).toFixed(7)) : 0;
                        requestLinea.commissioni.upFront = lineaSimulazione.UpFrontValorePerc__c && lineaSimulazione.Up_Front__c ? lineaSimulazione.Up_Front__c : 0;
                        requestLinea.commissioni.upFrontPercent = !lineaSimulazione.UpFrontValorePerc__c && lineaSimulazione.Up_Front_perc__c ? Number(parseFloat(lineaSimulazione.Up_Front_perc__c/100).toFixed(7)) : 0;
                        requestLinea.commissioni.commissioneRunningAnnuale = lineaSimulazione.RunningValorePerc__c && lineaSimulazione.Commissione_running_annuale__c ? lineaSimulazione.Commissione_running_annuale__c : 0;
                        requestLinea.commissioni.commissioneRunningAnnualePercent = !lineaSimulazione.RunningValorePerc__c && lineaSimulazione.Commissione_running_annuale_perc__c ? Number(parseFloat(lineaSimulazione.Commissione_running_annuale_perc__c/100).toFixed(7)) : 0;
                        requestLinea.commissioni.altroEsDerivato = lineaSimulazione.AltroValorePerc__c && lineaSimulazione.Altroesderivato__c ? lineaSimulazione.Altroesderivato__c : 0;
                        requestLinea.commissioni.altroEsDerivatoPercent = !lineaSimulazione.AltroValorePerc__c && lineaSimulazione.Altro_es_derivato_perc__c ? Number(parseFloat(lineaSimulazione.Altro_es_derivato_perc__c/100).toFixed(7)) : 0;
                        requestLinea.commissioni.tassoRunningPeriodale = lineaSimulazione.Tasso_running_periodale__c ? Number(parseFloat(lineaSimulazione.Tasso_running_periodale__c/100).toFixed(7)) : 0;
                        requestLinea.commissioni.commissioneRunningPeriodale = lineaSimulazione.Commissione_running_periodale__c ? lineaSimulazione.Commissione_running_periodale__c : 0;

                        requestLinea.strutturaLinea.baloonFinalePercentuale = lineaSimulazione.baloonFinalePercentuale__c ? Number(parseFloat(lineaSimulazione.baloonFinalePercentuale__c/100).toFixed(7)) : null;
                        requestLinea.strutturaLinea.durata = lineaSimulazione.Durata__c ? lineaSimulazione.Durata__c : null;
                        requestLinea.strutturaLinea.formaTecnica = lineaSimulazione.Formatecnica__c ? lineaSimulazione.Formatecnica__c : null;
                        requestLinea.strutturaLinea.importo = lineaSimulazione.Importo__c ? lineaSimulazione.Importo__c : null;
                        requestLinea.strutturaLinea.isSAL = lineaSimulazione.SAL__c ? lineaSimulazione.SAL__c : false;
                        requestLinea.strutturaLinea.numeroPeriodiDiErogazione = lineaSimulazione.Numero_periodi_di_erogazione__c ? lineaSimulazione.Numero_periodi_di_erogazione__c : 0;
                        requestLinea.strutturaLinea.numeroRate = lineaSimulazione.Numerodirate__c ? lineaSimulazione.Numerodirate__c : null;
                        requestLinea.strutturaLinea.periodicitaRate = lineaSimulazione.Periodicita_rata__c ? lineaSimulazione.Periodicita_rata__c : null;
                        requestLinea.strutturaLinea.preammortamento = lineaSimulazione.Preammortamento__c ? lineaSimulazione.Preammortamento__c : null;
                        requestLinea.strutturaLinea.quotaDiAutoliquidante = lineaSimulazione.Linea__c	 ? Linea__c	 : null;
                        requestLinea.strutturaLinea.termOutOption = lineaSimulazione.Termoutoption__c ? lineaSimulazione.Termoutoption__c : null;
                        requestLinea.strutturaLinea.tipoAmmortamento = lineaSimulazione.Tipo_di_ammortamento__c ? lineaSimulazione.Tipo_di_ammortamento__c : null;
                        requestLinea.strutturaLinea.tipoFunding = lineaSimulazione.Tipo_funding__c ? lineaSimulazione.Tipo_funding__c : null;
                        requestLinea.strutturaLinea.utilizzoPercentuale = lineaSimulazione.Utilizzo__c ? Number(lineaSimulazione.Utilizzo__c) : 1;
                        requestLinea.strutturaLinea.valuta = lineaSimulazione.Valuta__c ? lineaSimulazione.Valuta__c : null;

                        let periodiErogazione = [];
                        let interestStepTassoFisso = [];
                        let interestStepCommissioneFirma = [];
                        let ammortamentoAdHoc = [];
                        if(lineaSimulazione.Rate_Linee__r){
                            periodiErogazione = lineaSimulazione.Rate_Linee__r.filter(element => {return element.Type__c === 'Periodo Erogazione';});
                            interestStepTassoFisso = lineaSimulazione.Rate_Linee__r.filter(element => {return element.Type__c === 'Interest Step Tasso Fisso';});
                            interestStepCommissioneFirma = lineaSimulazione.Rate_Linee__r.filter(element => {return element.Type__c === 'Interest Step Commissione Firma';});
                            ammortamentoAdHoc = lineaSimulazione.Rate_Linee__r.filter(element => {return element.Type__c === 'Piano Ammortamento';});
                        }

                        console.log('DK POST periodiErogazione', JSON.stringify(periodiErogazione));
                        console.log('DK POST interestStepTassoFisso', JSON.stringify(interestStepTassoFisso));
                        console.log('DK POST interestStepCommissioneFirma', JSON.stringify(interestStepCommissioneFirma));
                        console.log('DK POST ammortamentoAdHoc', JSON.stringify(ammortamentoAdHoc));
                        
                        if(periodiErogazione.length > 0){
                            periodiErogazione.forEach(element =>{
                                let periodoPreammortamento = {};
                                periodoPreammortamento.erogato = element.Erogato__c ? element.Erogato__c : null;
                                periodoPreammortamento.numeroRata = element.Numerorata__c ? element.Numerorata__c : null;
                                // periodoPreammortamento.numeroAnniEquivalenti = element.Numeroanniequivalenti__c;
                                // periodoPreammortamento.numeroPeriodiDiErogazione = element.Numero_periodi_di_erogazione__c;
                                // periodoPreammortamento.periodoDiErogazioneFondi = element.Periododierogazionifondi__c;
                                requestLinea.strutturaLinea.periodiAmmortamento.push(periodoPreammortamento);
                            });
                        }
                        
                        if(ammortamentoAdHoc.length > 0){
                            ammortamentoAdHoc.forEach(element =>{
                                let pianodiRimorsoManualmente = {};
                                pianodiRimorsoManualmente.progrPeriodo = element.ProgrPeriodo__c;
                                pianodiRimorsoManualmente.riferimentoAnno = element.Riferimentoanno__c;
                                pianodiRimorsoManualmente.numeroPeriodoNellAnno = element.Numeroperiodonellanno__c;
                                pianodiRimorsoManualmente.percentualeNonUtilizzato = element.PercNonutilizzato__c;
                                pianodiRimorsoManualmente.nonUtilizzato = element.Nonutilizzato__c;
                                pianodiRimorsoManualmente.percentualeUtilizzo = Number(parseFloat(element.percentualeUtilizzoAmmortamento__c/100).toFixed(7));
                                pianodiRimorsoManualmente.quotaCapitaleUtilizzato = element.QuotaCapitaleUtilizzato__c;
                                pianodiRimorsoManualmente.quotaCapAmmortamento = element.QuotaCapAmmortamento__c;
                                pianodiRimorsoManualmente.quotaCapResidua = element.QuotaCapresidua__c;
                                pianodiRimorsoManualmente.quotaInteressi = element.QuotaInteressi__c;
                                pianodiRimorsoManualmente.totaleRata = element.Totalerata__c;
                                requestLinea.strutturaLinea.pianodiRimorsoManualmente.push(pianodiRimorsoManualmente);
                            })
                        }
                        
                        requestLinea.tasso.cap = lineaSimulazione.Cap__c ? lineaSimulazione.Cap__c : false;
                        requestLinea.tasso.capValore = lineaSimulazione.Capvalore__c ? Number(parseFloat(lineaSimulazione.Capvalore__c/100).toFixed(7)) : null;
                        requestLinea.tasso.fissoCommissioneDiFirma = lineaSimulazione.tassoFisso__c ? Number(parseFloat(lineaSimulazione.tassoFisso__c/100).toFixed(7)) : lineaSimulazione.commissioneDiFirma__c ? Number(parseFloat(lineaSimulazione.commissioneDiFirma__c/100).toFixed(7)) : 0;
                        requestLinea.tasso.floor = lineaSimulazione.Floor__c ? lineaSimulazione.Floor__c : false;
                        requestLinea.tasso.floorValore = lineaSimulazione.Floorvalore__c ? Number(parseFloat(lineaSimulazione.Floorvalore__c/100).toFixed(7)) : null;
                        requestLinea.tasso.indicizzazione = lineaSimulazione.Indicizzazionetassovariabile__c ? lineaSimulazione.Indicizzazionetassovariabile__c : null;
                        requestLinea.tasso.interestStep = lineaSimulazione.Intereststep__c ? lineaSimulazione.Intereststep__c : lineaSimulazione.IntereststepCF__c ? lineaSimulazione.IntereststepCF__c : false;
                        requestLinea.tasso.sensitivity = lineaSimulazione.Sensitivity__c ? Number(lineaSimulazione.Sensitivity__c) : null;
                        requestLinea.tasso.spread = lineaSimulazione.Spread__c ? Number(parseFloat(lineaSimulazione.Spread__c/100).toFixed(7)) : null;
                        requestLinea.tasso.tipoTasso = lineaSimulazione.Formatecnica__c.toLowerCase().includes('fideiussioni') ? 'FISSO' : lineaSimulazione.Tipo_tasso__c;
                        
                        if(interestStepTassoFisso.length > 0){
                            interestStepTassoFisso.forEach(element =>{
    
                                let valoreTassoAdHocInterestStep = {};
                                valoreTassoAdHocInterestStep.deltaTassoSpread = element.Delta_Spread__c ? Number(parseFloat(element.Delta_Spread__c/100).toFixed(7)) : null;
                                // valoreTassoAdHocInterestStep.numeroAnniEquivalenti = element.Numeroanniequivalenti__c;
                                // valoreTassoAdHocInterestStep.periodicitaCorrispondente = element.Periodicitcorrispondente__c;
                                valoreTassoAdHocInterestStep.rataCorrispondenteModificaTasso = element.Ratacorrispondentemodificatasso__c ? element.Ratacorrispondentemodificatasso__c : null;
                                requestLinea.tasso.valoriTassoAdHocInterestStep.push(valoreTassoAdHocInterestStep);
                            });
                        }
                        if(interestStepCommissioneFirma.length > 0){
                            interestStepCommissioneFirma.forEach(element =>{
    
                                let valoreTassoAdHocInterestStep = {};
                                valoreTassoAdHocInterestStep.deltaTassoSpread = element.Delta_Spread__c ? Number(parseFloat(element.Delta_Spread__c/100).toFixed(7)) : null;
                                valoreTassoAdHocInterestStep.numeroAnniEquivalenti = element.Numeroanniequivalenti__c ? element.Numeroanniequivalenti__c : null;
                                valoreTassoAdHocInterestStep.periodicitaCorrispondente = element.Periodicitcorrispondente__c ? element.Periodicitcorrispondente__c : null;
                                valoreTassoAdHocInterestStep.rataCorrispondenteModificaTasso = element.Ratacorrispondentemodificatasso__c ? element.Ratacorrispondentemodificatasso__c : null;
                                requestLinea.tasso.valoriTassoAdHocInterestStep.push(valoreTassoAdHocInterestStep);
                            });
                        }
            
                        requestLinea.variabiliGaranzie.garanziaFlag = lineaSimulazione.Garanzia__c ? lineaSimulazione.Garanzia__c : false;
                        requestLinea.variabiliGaranzie.tipoGaranzia = lineaSimulazione.Tipo_garanzia__c ? lineaSimulazione.Tipo_garanzia__c : null;
                        requestLinea.variabiliGaranzie.tipoPegno = lineaSimulazione.Tipo_pegno__c ? lineaSimulazione.Tipo_pegno__c : null;
                        requestLinea.variabiliGaranzie.valoreDelBeneIpotecato = lineaSimulazione.Valore_del_bene_ipotecato__c ? lineaSimulazione.Valore_del_bene_ipotecato__c : null;
                        requestLinea.variabiliGaranzie.valoreDelPegnoOrSACE = lineaSimulazione.Valore_del_pegno_SACE__c ? lineaSimulazione.Valore_del_pegno_SACE__c : null;
            
                        requestObject.calcoloEffettivoSimulazioneInputVm.push(requestLinea);
                    });
                    console.log('DK requestBody: ' , JSON.stringify(requestObject));
                    this.isRendered = false;
                    // this.simulazione.Linee__r = this.lineeSimulazione;
                    getResponse({
                        record: this.simulazione,
                        requestToApiGateway: 'calculateSimulazione',
                        parseJSON: null,
                        conditions: null,
                        certificateName: this.certificateName,
                        disableLog: this.disableLog,
                        addingParamsMap: {},
                        bodyJSON: JSON.stringify(requestObject)
                    })
                    .then(result =>{
                        console.log('DK resolveApexPromises.result', result);
                        if(result.response.statusCode == '200'){
                            console.log('DK responseData', result.response.data);
                            let responseData = JSON.parse(result.response.data);;
                            
                            this.simulazione.Interessi_attivi_totali__c = responseData.allLineaVitainteraVm.interessiAttivi;
                            this.simulazione.Costo_del_funding_totale__c = responseData.allLineaVitainteraVm.costoDelFunding;
                            this.simulazione.Margine_di_interesse_totale__c = responseData.allLineaVitainteraVm.margineDiInteresse;
                            this.simulazione.Commissioni_Up_Front_Totale__c = responseData.allLineaVitainteraVm.commissioniUpFront;
                            this.simulazione.Commissioni_Running_Totale__c = responseData.allLineaVitainteraVm.commissioniRunning;
                            this.simulazione.Commissioni_Altro_Totale__c = responseData.allLineaVitainteraVm.commissioniAltro;
                            this.simulazione.Commissioni_Totali__c = responseData.allLineaVitainteraVm.commissioniTotali;
                            this.simulazione.Margine_di_intermediazione_Totale__c = responseData.allLineaVitainteraVm.margineDiIntermediazione;
                            this.simulazione.Costo_del_Rischio_Lordo_Totale__c = responseData.allLineaVitainteraVm.costoDelRischioLordo;
                            this.simulazione.Costo_del_capitale_totale__c = responseData.allLineaVitainteraVm.costoDelCapitale;
                            this.simulazione.Costi_operativi_totali__c = responseData.allLineaVitainteraVm.costiOperativi;
                            this.simulazione.Margine_operativo_netto_totale__c = responseData.allLineaVitainteraVm.margineOperativoNetto;
                            this.simulazione.SML_annuo_medio_totale__c = responseData.allLineaVitainteraVm.smlAnnuoMedio;
                            this.simulazione.EAD_annua_media_totale__c = responseData.allLineaVitainteraVm.eadAnnuoMedia;
                            this.simulazione.rwa_Rischio_Di_Credito_Annuo_Medio__c = responseData.allLineaVitainteraVm.rwaRischioDiCreditoAnnuoMedio;
                            this.simulazione.RWA_rischio_operativo_annui_medio__c = responseData.allLineaVitainteraVm.rwaRischioOperativoAnnuoMedio;
                            this.simulazione.rwaRischioDiCreditoAnnuoTotal__c = responseData.allLineaVitainteraVm.rwaRischioDiCreditoAnnuoTotal;
                            this.simulazione.rwaRischioOperativoAnnuoTotal__c = responseData.allLineaVitainteraVm.rwaRischioOperativoAnnuoTotal;
                            this.simulazione.RWA_totali_annui_medi_totale__c = responseData.allLineaVitainteraVm.rwaTotaliAnnuiMedio;
                            this.simulazione.capitaleAssorbitoMedio__c = responseData.allLineaVitainteraVm.capitaleAssorbitoMedio;
                            this.simulazione.RWA_totali_annui_max__c = responseData.allLineaVitainteraVm.rwaTotaliAnnuiMax;
                            this.simulazione.Capitale_assorbito_max__c = responseData.allLineaVitainteraVm.capitaleAssorbitoMax;
                            this.simulazione.RWA_Medio_perc__c = responseData.allLineaVitainteraVm.rwaMedioPercentuale*100;
                            this.simulazione.Present_NOPAT__c = responseData.allLineaVitainteraVm.presentNOPAT;
                            this.simulazione.Present_EVA__c = responseData.allLineaVitainteraVm.presentEVA;
                            this.simulazione.Present_RACE__c = responseData.allLineaVitainteraVm.presentRACE*100;
                            this.simulazione.Present_RARORAC__c = responseData.allLineaVitainteraVm.presentRARORAC*100;
                            this.simulazione.smlAttTotal__c = responseData.allLineaVitainteraVm.smlAttTotal;
                            this.simulazione.accordatoAttTotal__c = responseData.allLineaVitainteraVm.accordatoAttTotal;
                            this.simulazione.Sprad_EVA_neutral__c = responseData.allLineaVitainteraVm.spreadEVANeutral;
                            this.simulazione.Duration_finanziaria_in_anni__c = responseData.allLineaVitainteraVm.durataFinanziariaInAnni;
                            this.simulazione.Interessi_attivi1__c = responseData.allLineaPrimoAnnoVm.interessiAttiviAnnuo;
                            this.simulazione.Costo_del_funding1__c = responseData.allLineaPrimoAnnoVm.costoDelFunding;
                            this.simulazione.Margine_di_interesse1__c = responseData.allLineaPrimoAnnoVm.margineDiInteresse;
                            this.simulazione.Commissioni_up_front1__c = responseData.allLineaPrimoAnnoVm.commissioniUpFront;
                            this.simulazione.Commissioni_running1__c = responseData.allLineaPrimoAnnoVm.commissioniRunning;
                            this.simulazione.Commissioni_altro1__c = responseData.allLineaPrimoAnnoVm.commissioniAltro;
                            this.simulazione.Commissioni1__c = responseData.allLineaPrimoAnnoVm.commissioniTotali;
                            this.simulazione.Margine_di_intermediazione1__c = responseData.allLineaPrimoAnnoVm.margineDiIntermediazione;
                            this.simulazione.Costo_del_rischio_lordo1__c = responseData.allLineaPrimoAnnoVm.costoDelRischioLordo;
                            this.simulazione.Costo_del_capitale1__c = responseData.allLineaPrimoAnnoVm.costoDelCapitale;
                            this.simulazione.Costi_operativi1__c = responseData.allLineaPrimoAnnoVm.costiOperativi;
                            this.simulazione.Margine_operativo_netto1__c = responseData.allLineaPrimoAnnoVm.margineOperativoNetto;
                            this.simulazione.Erogato1__c = responseData.allLineaPrimoAnnoVm.erogato;
                            this.simulazione.SML1__c = responseData.allLineaPrimoAnnoVm.sml;
                            this.simulazione.EAD1__c = responseData.allLineaPrimoAnnoVm.ead;
                            this.simulazione.RWA_rischio_di_credito1__c = responseData.allLineaPrimoAnnoVm.rwaRischioDiCredito;
                            this.simulazione.RWA_rischio_operativo1__c = responseData.allLineaPrimoAnnoVm.rwaRischioOperativo;
                            this.simulazione.RWA_totale1__c = responseData.allLineaPrimoAnnoVm.rwaTotale;
                            this.simulazione.Capitale_Assorbito1__c = responseData.allLineaPrimoAnnoVm.capitaleAssorbito;
                            this.simulazione.NOPAT_anno1__c = responseData.allLineaPrimoAnnoVm.nopat;
                            this.simulazione.EVA1__c = responseData.allLineaPrimoAnnoVm.eva;
                            this.simulazione.RACE1__c = responseData.allLineaPrimoAnnoVm.race*100;
                            this.simulazione.RARORAC1__c = responseData.allLineaPrimoAnnoVm.rarorac*100;
                            let lineeToCalculate = [];
                            responseData.calcoloEffettivoSimulazioneOuputTotalVm.forEach(responseLinea =>{
                                const lineaToUpdate = (element) => element.Id == responseLinea.idLinea;
                                let index = this.lineeSimulazione.findIndex(lineaToUpdate);
                                console.log('DK lineaToUpdate Idset lineeSimulazione', JSON.stringify(this.lineeSimulazione.map(element => element.Id)));
                                console.log('DK lineaToUpdate responseLinea.idLinea', responseLinea.idLinea);
                                console.log('DK lineaToUpdate index', index);
                                if(index >= 0){
                                    this.lineeSimulazione[index].idAmmortamentoLinea__c = responseLinea.idAmmortamentoLinea;
                                    this.lineeSimulazione[index].TIT_base_di_partenza__c = responseLinea.calcoloEffettivoSimulazioneOuputLineaVm.titBaseDiPartenza*100;
                                    this.lineeSimulazione[index].TIT_base_medio__c = responseLinea.calcoloEffettivoSimulazioneOuputLineaVm.titBaseMedio;
                                    this.lineeSimulazione[index].Funding_spread__c = responseLinea.calcoloEffettivoSimulazioneOuputLineaVm.fundingSpread;
                                    this.lineeSimulazione[index].TIT__c = responseLinea.calcoloEffettivoSimulazioneOuputLineaVm.tit;
                                    this.lineeSimulazione[index].Costi_operativi_effettivi__c = responseLinea.calcoloEffettivoSimulazioneOuputLineaVm.costiOperativi;
                                    this.lineeSimulazione[index].costiDelRischioEffettivo__c = responseLinea.calcoloEffettivoSimulazioneOuputLineaVm.costiDelRischio;
                                    this.lineeSimulazione[index].Costo_fiscale__c = responseLinea.calcoloEffettivoSimulazioneOuputLineaVm.costoFiscale;
                                    this.lineeSimulazione[index].Costo_del_capitale_effettivo__c = responseLinea.calcoloEffettivoSimulazioneOuputLineaVm.costoDelCapitale;
                                    this.lineeSimulazione[index].Tasso_di_break_even__c = responseLinea.calcoloEffettivoSimulazioneOuputLineaVm.tassoDiBreakEven;
                                    this.lineeSimulazione[index].Differenza_tra_break_even_e_tasso_applic__c = responseLinea.calcoloEffettivoSimulazioneOuputLineaVm.differenzaTraBreakEvenETassoApplicato;
                                    this.lineeSimulazione[index].tassoFissoCommissioneTassoVariabile__c = responseLinea.calcoloEffettivoSimulazioneOuputLineaVm.tassoFissoCommissioneDiFirmaTassoVariabileMedioApplicato;
                                    this.lineeSimulazione[index].Tasso_variabile_medio_applicato__c = responseLinea.calcoloEffettivoSimulazioneOuputLineaVm.tassoVariabileMedioApplicato;
                                    this.lineeSimulazione[index].Componente_commissionale_media_annua__c = responseLinea.calcoloEffettivoSimulazioneOuputLineaVm.componenteCommissionaleMediaAnnuale;
                                    this.lineeSimulazione[index].Add_on_commissionale_medio_annuo__c = responseLinea.calcoloEffettivoSimulazioneOuputLineaVm.addOnCommissionaleMedioAnnuo;
                                    this.lineeSimulazione[index].Tasso_all_in__c = responseLinea.calcoloEffettivoSimulazioneOuputLineaVm.tassoAllIn;
                                    this.lineeSimulazione[index].Interessi_attivi_1anno__c = responseLinea.lineaPrimoAnnoVm.interessiAttiviAnnuo;
                                    this.lineeSimulazione[index].Costo_del_funding_1anno__c = responseLinea.lineaPrimoAnnoVm.costoDelFunding;
                                    this.lineeSimulazione[index].Margine_di_interesse_1anno__c = responseLinea.lineaPrimoAnnoVm.margineDiInteresse;
                                    this.lineeSimulazione[index].Commissioni_up_front_1anno__c = responseLinea.lineaPrimoAnnoVm.commissioniUpFront;
                                    this.lineeSimulazione[index].Commissioni_running_1anno__c = responseLinea.lineaPrimoAnnoVm.commissioniRunning;
                                    this.lineeSimulazione[index].Commissioni_altro_1anno__c = responseLinea.lineaPrimoAnnoVm.commissioniAltro;
                                    this.lineeSimulazione[index].CommissioniTotali1anno__c = responseLinea.lineaPrimoAnnoVm.commissioniTotali;
                                    this.lineeSimulazione[index].Margine_di_intermediazione_1anno__c = responseLinea.lineaPrimoAnnoVm.margineDiIntermediazione;
                                    this.lineeSimulazione[index].Costo_del_rischio_lordo_1anno__c = responseLinea.lineaPrimoAnnoVm.costoDelRischioLordo;
                                    this.lineeSimulazione[index].Costo_del_capitale_1anno__c = responseLinea.lineaPrimoAnnoVm.costoDelCapitale;
                                    this.lineeSimulazione[index].Costi_operativi_1anno__c = responseLinea.lineaPrimoAnnoVm.costiOperativi;
                                    this.lineeSimulazione[index].Margine_operativo_netto_1anno__c = responseLinea.lineaPrimoAnnoVm.margineOperativoNetto;
                                    this.lineeSimulazione[index].Erogato_1anno__c = responseLinea.lineaPrimoAnnoVm.erogato;
                                    this.lineeSimulazione[index].SML_1anno__c = responseLinea.lineaPrimoAnnoVm.sml;
                                    this.lineeSimulazione[index].EAD__c = responseLinea.lineaPrimoAnnoVm.ead;
                                    this.lineeSimulazione[index].RWA_rischio_di_credito_1anno__c = responseLinea.lineaPrimoAnnoVm.rwaRischioDiCredito;
                                    this.lineeSimulazione[index].RWA_rischio_operativo_1anno__c = responseLinea.lineaPrimoAnnoVm.rwaRischioOperativo;
                                    this.lineeSimulazione[index].RWA_totale_1anno__c = responseLinea.lineaPrimoAnnoVm.rwaTotale;
                                    this.lineeSimulazione[index].Capitale_Assorbito_1anno__c = responseLinea.lineaPrimoAnnoVm.capitaleAssorbito;
                                    this.lineeSimulazione[index].NOPAT_1anno__c = responseLinea.lineaPrimoAnnoVm.nopat;
                                    this.lineeSimulazione[index].RACE_1anno__c = responseLinea.lineaPrimoAnnoVm.race*100;
                                    this.lineeSimulazione[index].EVA__c = responseLinea.lineaPrimoAnnoVm.eva;
                                    this.lineeSimulazione[index].RARORAC_1anno__c = responseLinea.lineaPrimoAnnoVm.rarorac*100;
                                    this.lineeSimulazione[index].Interessi_attivi__c = responseLinea.lineaVitainteraVm.interessiAttivi;
                                    this.lineeSimulazione[index].Costo_del_funding__c = responseLinea.lineaVitainteraVm.costoDelFunding;
                                    this.lineeSimulazione[index].Margine_di_interesse__c = responseLinea.lineaVitainteraVm.margineDiInteresse;
                                    this.lineeSimulazione[index].Commissioni_up_front__c = responseLinea.lineaVitainteraVm.commissioniUpFront;
                                    this.lineeSimulazione[index].Commissioni_running__c = responseLinea.lineaVitainteraVm.commissioniRunning;
                                    this.lineeSimulazione[index].Commissioni_altro__c = responseLinea.lineaVitainteraVm.commissioniAltro;
                                    this.lineeSimulazione[index].Commissioni_Totali__c = responseLinea.lineaVitainteraVm.commissioniTotali;
                                    this.lineeSimulazione[index].Margine_di_intermediazione__c = responseLinea.lineaVitainteraVm.margineDiIntermediazione;
                                    this.lineeSimulazione[index].Costo_del_rischio_lordo__c = responseLinea.lineaVitainteraVm.costoDelRischioLordo;
                                    this.lineeSimulazione[index].Costo_del_capitale__c = responseLinea.lineaVitainteraVm.costoDelCapitale;
                                    this.lineeSimulazione[index].Costi_operativi__c = responseLinea.lineaVitainteraVm.costiOperativi;
                                    this.lineeSimulazione[index].Margine_operativo_netto__c = responseLinea.lineaVitainteraVm.margineOperativoNetto;
                                    this.lineeSimulazione[index].SML_annuo_medio__c = responseLinea.lineaVitainteraVm.smlAnnuoMedio;
                                    this.lineeSimulazione[index].EAD_annua_media__c = responseLinea.lineaVitainteraVm.eadAnnuoMedia;
                                    this.lineeSimulazione[index].RWA_rischio_di_credito_annui_medi__c = responseLinea.lineaVitainteraVm.rwaRischioDiCreditoAnnuoMedio;
                                    this.lineeSimulazione[index].RWA_rischio_operativo_annui_medi__c = responseLinea.lineaVitainteraVm.rwaRischioOperativoAnnuoMedio;
                                    this.lineeSimulazione[index].rwaRischioDiCreditoAnnuoTotal__c = responseLinea.lineaVitainteraVm.rwaRischioDiCreditoAnnuoTotal;
                                    this.lineeSimulazione[index].rwaRischioOperativoAnnuoTotal__c = responseLinea.lineaVitainteraVm.rwaRischioOperativoAnnuoTotal;
                                    this.lineeSimulazione[index].RWA_totali_annui_medi__c = responseLinea.lineaVitainteraVm.rwaTotaliAnnuiMedio;
                                    this.lineeSimulazione[index].Capitale_assorbito_medio__c = responseLinea.lineaVitainteraVm.capitaleAssorbitoMedio;
                                    this.lineeSimulazione[index].RWA_totali_annui_max__c = responseLinea.lineaVitainteraVm.rwaTotaliAnnuiMax;
                                    this.lineeSimulazione[index].Capitale_assorbito_max__c = responseLinea.lineaVitainteraVm.capitaleAssorbitoMax;
                                    this.lineeSimulazione[index].Present_NOPAT_vitaintera__c = responseLinea.lineaVitainteraVm.presentNOPAT;
                                    this.lineeSimulazione[index].Present_EVA_vitaintera__c = responseLinea.lineaVitainteraVm.presentEVA;
                                    this.lineeSimulazione[index].Present_RACE_vitaintera__c = responseLinea.lineaVitainteraVm.presentRACE*100;
                                    this.lineeSimulazione[index].Present_RARORAC_vitaintera__c = responseLinea.lineaVitainteraVm.presentRARORAC*100;
                                    this.lineeSimulazione[index].smlAttTotal__c = responseLinea.lineaVitainteraVm.smlAttTotal;
                                    this.lineeSimulazione[index].accordatoAttTotal__c = responseLinea.lineaVitainteraVm.accordatoAttTotal;
                                    this.lineeSimulazione[index].Sprad_EVA_neutral__c = responseLinea.lineaVitainteraVm.spreadEVANeutral;
                                    this.lineeSimulazione[index].Duration_finanziaria_in_anni__c = responseLinea.lineaVitainteraVm.durataFinanziaraInAnni;
                                    this.lineeSimulazione[index].RWA_Medio__c = responseLinea.lineaSintesiVm.rwaMedioPercentuale*100;
                                    this.lineeSimulazione[index].Costo_del_capitale_sintesi__c = responseLinea.lineaSintesiVm.costoDelCapitale;
                                    this.lineeSimulazione[index].Present_NOPAT__c = responseLinea.lineaSintesiVm.presentNOPAT;
                                    this.lineeSimulazione[index].Present_EVA__c = responseLinea.lineaSintesiVm.presentEVA;
                                    this.lineeSimulazione[index].Present_RACE__c = responseLinea.lineaSintesiVm.presentRACE*100;
                                    this.lineeSimulazione[index].Present_RARORAC__c = responseLinea.lineaSintesiVm.presentRARORAC*100;
                                    
                                    let deltaSpreadRaroracKeys = Object.keys(responseLinea.calcoloSensitivitySimulationOutputVm.deltaSpreadRarorac).sort(function(a, b){return b-a});
                                    this.lineeSimulazione[index].SensitivityMargineRARORACPiu30__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaSpreadRarorac[deltaSpreadRaroracKeys[0]]*100;
                                    this.lineeSimulazione[index].SensitivityMargineRARORACPiu20__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaSpreadRarorac[deltaSpreadRaroracKeys[1]]*100;
                                    this.lineeSimulazione[index].SensitivityMargineRARORACPiu10__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaSpreadRarorac[deltaSpreadRaroracKeys[2]]*100;
                                    this.lineeSimulazione[index].SensitivityMargineRARORACMeno10__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaSpreadRarorac[deltaSpreadRaroracKeys[3]]*100;
                                    this.lineeSimulazione[index].SensitivityMargineRARORACMeno20__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaSpreadRarorac[deltaSpreadRaroracKeys[4]]*100;
                                    this.lineeSimulazione[index].SensitivityMargineRARORACMeno30__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaSpreadRarorac[deltaSpreadRaroracKeys[5]]*100;
                                    
                                    let deltaSpreadRaceKeys = Object.keys(responseLinea.calcoloSensitivitySimulationOutputVm.deltaSpreadRace).sort(function(a, b){return b-a});
                                    this.lineeSimulazione[index].SensitivityMargineRACEPiu30__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaSpreadRace[deltaSpreadRaceKeys[0]]*100;
                                    this.lineeSimulazione[index].SensitivityMargineRACEPiu20__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaSpreadRace[deltaSpreadRaceKeys[1]]*100;
                                    this.lineeSimulazione[index].SensitivityMargineRACEPiu10__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaSpreadRace[deltaSpreadRaceKeys[2]]*100;
                                    this.lineeSimulazione[index].SensitivityMargineRACEMeno10__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaSpreadRace[deltaSpreadRaceKeys[3]]*100;
                                    this.lineeSimulazione[index].SensitivityMargineRACEMeno20__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaSpreadRace[deltaSpreadRaceKeys[4]]*100;
                                    this.lineeSimulazione[index].SensitivityMargineRACEMeno30__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaSpreadRace[deltaSpreadRaceKeys[5]]*100;
                                    
                                    let deltaCmuRaroracKeys = Object.keys(responseLinea.calcoloSensitivitySimulationOutputVm.deltaCmuRarorac).sort(function(a, b){return b-a});
                                    this.lineeSimulazione[index].SensitivityCMURARORACPiu30__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaCmuRarorac[deltaCmuRaroracKeys[0]]*100;
                                    this.lineeSimulazione[index].SensitivityCMURARORACPiu20__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaCmuRarorac[deltaCmuRaroracKeys[1]]*100;
                                    this.lineeSimulazione[index].SensitivityCMURARORACPiu10__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaCmuRarorac[deltaCmuRaroracKeys[2]]*100;
                                    this.lineeSimulazione[index].SensitivityCMURARORACMeno10__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaCmuRarorac[deltaCmuRaroracKeys[3]]*100;
                                    this.lineeSimulazione[index].SensitivityCMURARORACMeno20__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaCmuRarorac[deltaCmuRaroracKeys[4]]*100;
                                    this.lineeSimulazione[index].SensitivityCMURARORACMeno30__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaCmuRarorac[deltaCmuRaroracKeys[5]]*100;
                                    
                                    let deltaCmuRaceKeys = Object.keys(responseLinea.calcoloSensitivitySimulationOutputVm.deltaCmuRace).sort(function(a, b){return b-a});
                                    this.lineeSimulazione[index].SensitivityCMURACEPiu30__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaCmuRace[deltaCmuRaceKeys[0]]*100;
                                    this.lineeSimulazione[index].SensitivityCMURACEPiu20__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaCmuRace[deltaCmuRaceKeys[1]]*100;
                                    this.lineeSimulazione[index].SensitivityCMURACEPiu10__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaCmuRace[deltaCmuRaceKeys[2]]*100;
                                    this.lineeSimulazione[index].SensitivityCMURACEMeno10__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaCmuRace[deltaCmuRaceKeys[3]]*100;
                                    this.lineeSimulazione[index].SensitivityCMURACEMeno20__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaCmuRace[deltaCmuRaceKeys[4]]*100;
                                    this.lineeSimulazione[index].SensitivityCMURACEMeno30__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaCmuRace[deltaCmuRaceKeys[5]]*100;

                                    let deltaUpFrontRaroracKeys = Object.keys(responseLinea.calcoloSensitivitySimulationOutputVm.deltaUpFrontRarorac).sort(function(a, b){return b-a});
                                    this.lineeSimulazione[index].SensitivityUPfrontRARORACPiu30__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaUpFrontRarorac[deltaUpFrontRaroracKeys[0]]*100;
                                    this.lineeSimulazione[index].SensitivityUPfrontRARORACPiu20__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaUpFrontRarorac[deltaUpFrontRaroracKeys[1]]*100;
                                    this.lineeSimulazione[index].SensitivityUPfrontRARORACPiu10__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaUpFrontRarorac[deltaUpFrontRaroracKeys[2]]*100;
                                    this.lineeSimulazione[index].SensitivityUPfrontRARORACMeno10__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaUpFrontRarorac[deltaUpFrontRaroracKeys[3]]*100;
                                    this.lineeSimulazione[index].SensitivityUPfrontRARORACMeno20__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaUpFrontRarorac[deltaUpFrontRaroracKeys[4]]*100;
                                    this.lineeSimulazione[index].SensitivityUPfrontRARORACMeno30__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaUpFrontRarorac[deltaUpFrontRaroracKeys[5]]*100;

                                    let deltaUpFrontRaceKeys = Object.keys(responseLinea.calcoloSensitivitySimulationOutputVm.deltaUpFrontRace).sort(function(a, b){return b-a});
                                    this.lineeSimulazione[index].SensitivityUpFrontRACEPiu30__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaUpFrontRace[deltaUpFrontRaceKeys[0]]*100;
                                    this.lineeSimulazione[index].SensitivityUpFrontRACEPiu20__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaUpFrontRace[deltaUpFrontRaceKeys[1]]*100;
                                    this.lineeSimulazione[index].SensitivityUpFrontRACEPiu10__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaUpFrontRace[deltaUpFrontRaceKeys[2]]*100;
                                    this.lineeSimulazione[index].SensitivityUpFrontRACEMeno10__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaUpFrontRace[deltaUpFrontRaceKeys[3]]*100;
                                    this.lineeSimulazione[index].SensitivityUpFrontRACEMeno20__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaUpFrontRace[deltaUpFrontRaceKeys[4]]*100;
                                    this.lineeSimulazione[index].SensitivityUpFrontRACEMeno30__c = responseLinea.calcoloSensitivitySimulationOutputVm.deltaUpFrontRace[deltaUpFrontRaceKeys[5]]*100;

                                    this.lineeSimulazione[index].Condizione_di_BE__c = responseLinea.condizioneBreakEven*100;
                                    this.lineeSimulazione[index].addOnCommissionaleEuro__c = responseLinea.addOnCommissionaleEuro;
                                    this.lineeSimulazione[index].addOnCommissionalePercentuale__c = responseLinea.addOnCommissionalePercentuale;
                                    this.lineeSimulazione[index].commissioniUpFrontBpsMediLongLife__c = responseLinea.commissioniUpFrontBpsMediLongLife*100;
                                    this.lineeSimulazione[index].commissioniRunningBpsMediLongLife__c = responseLinea.commissioniRunningBpsMediLongLife*100;
                                    this.lineeSimulazione[index].commissioniAddOnEuroLongLife__c = responseLinea.commissioniAddOnEuroLongLife;
                                    lineeToCalculate.push(this.lineeSimulazione[index]);
                                }
                            })
                            
                            console.log('DK OUTPUT SIM', JSON.stringify(this.simulazione));
                            console.log('DK OUTPUT LINEE', JSON.stringify(lineeToCalculate));
                            calculateSim({sim: this.simulazione, simLinee: lineeToCalculate})
                            .then(() =>{
    
                                // const toastEvent = new ShowToastEvent({
                                //     title: "",
                                //     message: 'La richiesta è andata a buon fine',
                                //     variant: "success"
                                // });
                                // this.dispatchEvent(toastEvent);
                                window.location.reload();
                            })
                            .catch(err =>{
                                console.log('DK calculateSim err', err);
                            });
                        }else{
                            this.isLoading = false;
                            const toastEvent = new ShowToastEvent({
                                title: "Attenzione!",
                                message: 'La richiesta non è andata a buon fine.',
                                variant: "warning"
                            });
                            this.dispatchEvent(toastEvent);
                        }
                    })
                    .catch(error => {
                        // this.isRendered = true;
                        this.isLoading = false;
                        console.log(error.message);
                    })
                    .finally(() => {
                        this.isLoading = false;
                        console.log('Finally');
                        // this.isRendered = true;
                    });
                })
            }else{
                console.log('DK INVALID FORM' + JSON.stringify(this.invalidFields));
                console.log('DK CibSimulazione invalidFields', JSON.stringify(this.invalidFields));
                console.log('DK CibSimulazione invalidFieldsLinee', JSON.stringify(this.invalidFieldsLinee));
                this.isLoading = false;
                console.log('DK SET isLoading', this.isLoading);
                
                const toastEvent = new ShowToastEvent({
                    title: "Error!",
                    message:'Controllare valorizzazione campi!',
                    variant: "error"
                });
                this.dispatchEvent(toastEvent);
            }
        } catch (error) {
            console.log('DK sendRequestCalculate error: ', error);   
        }
    }

    get showLinee(){
        return this.lineeSimulazione.length > 0;
    }

    handleAddLineaSimulazione(){
        if(this.lineeSimulazioneCounter <= 5){

            let lineaSimulazione = {};
            lineaSimulazione.Number__c = this.lineeSimulazioneCounter;
            lineaSimulazione.Termoutoption__c = false;
            lineaSimulazione.SAL__c = false;
            lineaSimulazione.Garanzia__c = false;
            lineaSimulazione.Cap__c = false;
            lineaSimulazione.Floor__c = false;
            lineaSimulazione.Intereststep__c = false;
            lineaSimulazione.IntereststepCF__c = false;
            lineaSimulazione.UpFrontValorePerc__c = false;
            lineaSimulazione.RunningValorePerc__c = false;
            lineaSimulazione.AltroValorePerc__c = false;
            lineaSimulazione.Valuta__c = 'EUR';
            lineaSimulazione.Tipo_funding__c = 'Blended';
            lineaSimulazione.Sensitivity__c = '10';
            console.log('DK CibSimulazionelineaSimulazione', JSON.stringify(lineaSimulazione));
            this.lineeSimulazione.push(lineaSimulazione);
            this.lineeSimulazioneCounter++;
            console.log('DK CibSimulazione handleAddLineaSimulazione.lineeSimulazione: ', JSON.stringify(this.lineeSimulazione));
        }else{
            const toastEvent = new ShowToastEvent({
                title: "Attenzione!",
                message: 'Raggiunto il limite di 5 linee per Simulazione.',
                variant: "warning"
            });
            this.dispatchEvent(toastEvent);
        }
    }

    handleCloneLineaEvent(event){
        console.log('DK handleCloneLineaEvent.event.detail: ', JSON.stringify(event.detail), this.lineeSimulazioneCounter);
        try {
            if(this.lineeSimulazioneCounter <= 5){
                let lineaSimulazione = JSON.parse(JSON.stringify(event.detail));
                lineaSimulazione.Id = undefined;
                lineaSimulazione.Number__c = this.lineeSimulazioneCounter;
                lineaSimulazione.Name = undefined;
                lineaSimulazione.CreatedDate = undefined;
                lineaSimulazione.CreatedById = undefined;
                lineaSimulazione.LastModifiedDate = undefined;
                lineaSimulazione.LastModifiedById = undefined;
                lineaSimulazione.SystemModstamp = undefined;
                lineaSimulazione.LastViewedDate = undefined;
                lineaSimulazione.LastReferencedDate = undefined;
                if(lineaSimulazione.rateLineeToUpsert && !lineaSimulazione.Rate_Linee__r){
                    // if(!lineaSimulazione.Rate_Linee__r) lineaSimulazione.Rate_Linee__r = [];
                    /*lineaSimulazione.rateLineeToUpsert.forEach(rataLinea =>{
                        if(!rataLinea.Id){
                            lineaSimulazione.Rate_Linee__r.push(rataLinea);
                        }
                    })*/
                    lineaSimulazione.Rate_Linee__r = lineaSimulazione.rateLineeToUpsert;
                }
                if(lineaSimulazione.Rate_Linee__r){
                    lineaSimulazione.Rate_Linee__r.forEach(rataLinea =>{
                        rataLinea.Id = undefined;
                        rataLinea.Linea__c = undefined;
                        rataLinea.Name = undefined;
                        rataLinea.CreatedDate = undefined;
                        rataLinea.CreatedById = undefined;
                        rataLinea.LastModifiedDate = undefined;
                        rataLinea.LastModifiedById = undefined;
                        rataLinea.SystemModstamp = undefined;
                        rataLinea.LastViewedDate = undefined;
                        rataLinea.LastReferencedDate = undefined;
                        rataLinea.numberLinea = lineaSimulazione.Number__c;
                    });
                }
                lineaSimulazione.periodiErogazione = undefined;
                lineaSimulazione.interestStepTassoFisso = undefined;
                lineaSimulazione.interestStepCommissioneFirma = undefined;
                lineaSimulazione.ammortamentoAdHoc = undefined;
                lineaSimulazione.rateLineeToUpsert = undefined;
                lineaSimulazione.rateLineeToDelete = undefined;
                console.log('DK handleCloneLineaEvent.lineaSimulazione: '+JSON.stringify(lineaSimulazione)); 
                this.lineeSimulazione.push(lineaSimulazione);
                this.lineeSimulazioneCounter++;
            }else{
                const toastEvent = new ShowToastEvent({
                    title: "Attenzione!",
                    message: 'Raggiunto il limite di 5 linee per Simulazione.',
                    variant: "warning"
                });
                this.dispatchEvent(toastEvent);
            }
        } catch (error) {
            console.log('DK handleCloneLineaEvent.err', error.message);
        }
    }

    handleDeleteLineaEvent(event){
        console.log('DK handleDeleteLineaEvent.event.detail: '+JSON.stringify(event.detail));
        let lineeSimulazioneCmp = this.template.querySelectorAll(".lineaSimulazione");
        this.lineeSimulazione = [];
        lineeSimulazioneCmp.forEach(cmp =>{
            let lineaSimulazione = cmp.returnRecord();
            this.lineeSimulazione.push(lineaSimulazione);
        });
        if(event.detail.Id){
            this.isLoading = true;
            console.log('DK SET isLoading', this.isLoading);
            deleteLinea({recordId: event.detail.Id})
            .then(() =>{
                const toastEvent = new ShowToastEvent({
                    title: "Successo!",
                    message: 'Linea eliminata correttamente',
                    variant: "success"
                });
                this.dispatchEvent(toastEvent);
                this.lineeSimulazioneCounter--;
                console.log('Dk handleDeleteLineaEvent this.lineeSimulazione', JSON.stringify(this.lineeSimulazione));
                this.lineeSimulazione = this.lineeSimulazione.filter(element =>{ return element.Number__c != event.detail.number});
                this.updateNumberLinea(event.detail.number);
            })
            .catch(err =>{
                console.log('DK deleteLinea.err', err);
            })
            .finally(() =>{
                this.isLoading = false;
                console.log('DK SET isLoading', this.isLoading);
            })
        }else{
            this.lineeSimulazioneCounter--;
            console.log('Dk handleDeleteLineaEvent this.lineeSimulazione', JSON.stringify(this.lineeSimulazione));
            this.lineeSimulazione = this.lineeSimulazione.filter(element =>{ return element.Number__c != event.detail.number});
            this.updateNumberLinea(event.detail.number);
        }
    }

    updateNumberLinea(deletedNumber){
        console.log('Dk updateNumberLinea this.lineeSimulazione', JSON.stringify(this.lineeSimulazione));
        let lineeToUpdate = [];
        for(let i = 1; i <= this.lineeSimulazione.length; i++){
            // if(!this.lineeSimulazione[i-1].Id && this.lineeSimulazione[i-1].Number__c > deletedNumber){
            if(this.lineeSimulazione[i-1].Number__c > deletedNumber){
                this.lineeSimulazione[i-1].Number__c--;
                if(this.lineeSimulazione[i-1].Rate_Linee__r){
                    this.lineeSimulazione[i-1].Rate_Linee__r.forEach(rataLinea =>{
                        rataLinea.numberLinea = this.lineeSimulazione[i-1].Number__c;
                    })
                }
                if(this.lineeSimulazione[i-1].rateLineeToUpsert){
                    this.lineeSimulazione[i-1].rateLineeToUpsert.forEach(rataLinea =>{
                        rataLinea.numberLinea = this.lineeSimulazione[i-1].Number__c;
                    })
                }

                if(this.lineeSimulazione[i-1].Id){
                    lineeToUpdate.push(this.lineeSimulazione[i-1]);
                }
                console.log('DK updateNumberLinea lineaSimulazione', this.lineeSimulazione[i-1]);
            }
        }

        console.log('DK updateNumberLinea lineeToUpdate', lineeToUpdate);
        if(lineeToUpdate.length > 0){

            this.handleSave(false, true, lineeToUpdate);
        }
    }

    handleSetGestore(event) {
        console.log('DK CibSimulazione selected Gestore: '+JSON.stringify(event.detail)); 
        this.gestore = event.detail;
        this.gestoreId = event.detail !== null ? event.detail.objId : null;
        console.log('DK CibSimulazione selected Gestore: '+ this.gestoreId); 
    }

    handleSetTitolareOperazione(event) {
        console.log('DK CibSimulazione selected Titolare: '+JSON.stringify(event.detail)); 
        this.titolareOperazione = event.detail;
        this.titolareOperazioneId = event.detail !== null ? event.detail.objId : null;
        console.log('DK CibSimulazione selected Titolare: '+ this.titolareOperazioneId); 
    }

    fieldVisibilityMap = {
        'Segmento_di_Rischio__c': {
            'LARGE': ['Classe_di_rating__c', 'Classe_di_rischiosita__c', 'Modello_di_rating__c'],
            'PMIIM': ['Classe_di_rating__c', 'Classe_di_rischiosita__c', 'Modello_di_rating__c'],
            'PMIHO': ['Classe_di_rating__c', 'Classe_di_rischiosita__c', 'Modello_di_rating__c'],
            'PMICO': ['Classe_di_rating__c', 'Classe_di_rischiosita__c', 'Modello_di_rating__c'],
            'SOCFZ': ['Classe_di_rating__c', 'Classe_di_rischiosita__c', 'Modello_di_rating__c'],
            'PMISL': ['Giudizio_slotting_criteria__c', 'Modello_di_rating__c'],
            'AMMPB': ['Classe_di_merito_altre_variabili__c', 'Modello_di_rating__c'],
            'NONAT': ['Classe_di_merito_altre_variabili__c', 'Modello_di_rating__c'],
            'BANCH': ['Classe_di_merito_altre_variabili__c', 'Modello_di_rating__c'],
            'SMA00': ['Segmento_Modello__c', 'Classe_di_rating__c', 'Classe_di_rischiosita__c', 'Modello_di_rating__c'],
        }
    }

    extendSimulazione(){
        console.log('START extendSimulazione');
        if(this.simulazione.Provincia__c){
            this.simulazione.AreaGeografica__c = this.areaGeograficaMapping[this.simulazione.Provincia__c];
        }

        if(this.simulazione.Segmento_di_Rischio__c){
            this.simulazione.Modello_di_rating__c = ['LARGE','PMIIM', 'PMIHO', 'PMICO', 'SOCFZ'].includes(this.simulazione.Segmento_di_Rischio__c) ? 'AIRB':
            ['AMMPB','BANCH', 'SMA00', 'NONAT'].includes(this.simulazione.Segmento_di_Rischio__c) ? 'STANDARD' : 'SLOTTING CRITERIA';
            
            if((this.simulazione.Segmento_di_Rischio__c == 'AMMPB' && this.simulazione.AreaGeografica__c) || (this.classeRatingMapping[this.simulazione.Segmento_di_Rischio__c] && this.classeRatingMapping[this.simulazione.Segmento_di_Rischio__c].length === 1)){
                this.simulazione.Classe_di_rating__c = this.simulazione.Segmento_di_Rischio__c == 'AMMPB' ? this.areaGeograficaRatingMapping[this.simulazione.AreaGeografica__c] : this.classeRatingMapping[this.simulazione.Segmento_di_Rischio__c][0];
            }

            if(this.simulazione.Classe_di_rating__c){
                if(['LARGE','PMIHO'].includes(this.simulazione.Segmento_di_Rischio__c)){
                    this.simulazione.Classe_di_rischiosita__c = this.simulazione.Classe_di_rating__c <= 2 ? 'Rischio molto basso':
                    this.simulazione.Classe_di_rating__c <= 4 ? 'Rischio basso':
                    this.simulazione.Classe_di_rating__c <= 6 ? 'Rischio medio':
                    this.simulazione.Classe_di_rating__c == 7 ? 'Rischio rilevante': 'Rischio alto';
                }else if(['PMICO','PMIIM', 'SOCFZ', 'SMA00'].includes(this.simulazione.Segmento_di_Rischio__c)){
                    this.simulazione.Classe_di_rischiosita__c = this.simulazione.Classe_di_rating__c <= 2 ? 'Rischio molto basso':
                    this.simulazione.Classe_di_rating__c <= 4 ? 'Rischio basso':
                    this.simulazione.Classe_di_rating__c <= 7 ? 'Rischio medio':
                    this.simulazione.Classe_di_rating__c <= 9 ? 'Rischio rilevante': 'Rischio alto';
                }
            }
            console.log();
            /*if(this.segmentoModelloIsOne){
                this.simulazione.Segmento_Modello__c = this.segmentoModelloMapping[this.simulazione.Segmento_di_Rischio__c][0];
            }*/
        }
        console.log('END extendSimulazione', this.simulazione);
    }

    handleFilter(event){
        try {
            let inputFields = this.template.querySelectorAll('.validate');

            this.simulazione = JSON.parse(JSON.stringify(this.simulazione));
            this.simulazione[event.target.name] = event.target.type == 'checkbox' ? event.target.checked :
            event.target.type == 'number' ? Number(event.target.value) : ['true', 'false'].includes(event.target.value) ? /^true$/i.test(event.target.value) : event.target.value;
            
            
            if(this.fieldVisibilityMap[event.target.name]){
                let fieldDependencySet = [];
                Object.values(this.fieldVisibilityMap[event.target.name]).forEach(fieldSet =>{
                    fieldSet.forEach(field =>{
                        if(!fieldDependencySet.includes(field))fieldDependencySet.push(field);
                    })
                });
                console.log('DK fieldDependencySet', JSON.stringify(fieldDependencySet));
                if(this.fieldVisibilityMap[event.target.name][this.simulazione[event.target.name]]){
                    this.template.querySelectorAll('.is-hide').forEach(inputField =>{
                        console.log('DK inputField: ' + inputField.name);
                        if(fieldDependencySet.includes(inputField.name)){
                            inputField.style.display = this.fieldVisibilityMap[event.target.name][this.simulazione[event.target.name]].includes(inputField.name) ? 'block' : 'none';
                            console.log('DK inputField.style.display: ' + inputField.style.display);
                        }
                    })
                }else{
                    this.template.querySelectorAll('.is-hide').forEach(inputField =>{
                        console.log('DK inputField: ' + inputField.name);
                        if(fieldDependencySet.includes(inputField.name)){
                            inputField.style.display = 'none';
                            console.log('DK inputField.style.display: ' + inputField.style.display);
                        }
                    })
                }
            }
            /*if(event.target.name == 'Segmento_di_Rischio__c'){
                this.isProvinciaRequired = event.target.value == 'PMISL';
            }*/
            this.template.querySelectorAll('.is-hide-layout-item').forEach(layoutItem =>{
                layoutItem.style.display = layoutItem.querySelector('.is-hide').style.display;
            })

            this.extendSimulazione();

            console.log('DK CibSimulazione handleFilter this.simulazione', JSON.stringify(this.simulazione));
        } catch (error) {
            console.log('DK handleFilter.error: ' + JSON.stringify(error));
        }
    }

    @api
    returnRecord(){
        try {
            this.simulazione = JSON.parse(JSON.stringify(this.simulazione));
            let inputFields = this.template.querySelectorAll('.validate');
            inputFields.forEach(inputField => {
                this.simulazione[inputField.name] = inputField.style && inputField.style.display == 'none' ? null : inputField.type == 'checkbox' ? inputField.checked :
                inputField.type == 'number' ? Number(parseFloat(inputFields[i].value).toFixed(3)) : ['true', 'false'].includes(inputField.value) ? /^true$/i.test(inputField.value) : inputField.value;
            });
            
            let lineeSimulazioneCmp = this.template.querySelectorAll(".lineaSimulazione");
            this.lineeSimulazione = [];
            lineeSimulazioneCmp.forEach(cmp =>{
                let lineaSimulazione = cmp.returnRecord();
                this.lineeSimulazione.push(lineaSimulazione);
            });
        } catch (error) {
            console.log('DK returnRecord.error: ' + JSON.stringify(error));
        }
        return {'simulazione': this.simulazione, 'lineeSimulazione': [...this.lineeSimulazione]};
    }
    @api invalidFields = []; 
    @api invalidFieldsLinee = {}; 
    
    @api
    isInputValid() {
        this.invalidFields = [];
        this.invalidFieldsLinee = [];
        console.log('DK CibSimulazione isInputValid titolareOperazioneId', this.titolareOperazioneId);
        console.log('DK CibSimulazione isInputValid gestoreId', this.gestoreId);
        this.simulazione = JSON.parse(JSON.stringify(this.simulazione));
        this.simulazione.Nome_titolare_operazione__c = this.titolareOperazioneId;
        this.simulazione.Nome_del_Gestore__c = this.gestoreId;
        let isValid = true;
        try {
            console.log('DK CibSimulazione START isInputValid');
            // let inputFields = this.template.querySelectorAll('.validate');
            // this.simulazione.OwnerId = this.titolareOperazioneId;

            //validazione linee
            let lineeSimulazioneCmp = this.template.querySelectorAll(".lineaSimulazione");
            this.lineeSimulazione = [];
            lineeSimulazioneCmp.forEach(lineaSimulazioneCmp =>{
                if(!lineaSimulazioneCmp.isInputValid()){
                    isValid = false;
                }
                let lineaSimulazione = lineaSimulazioneCmp.returnRecord();
                this.invalidFieldsLinee[lineaSimulazione.Number__c] = lineaSimulazioneCmp.invalidFields;
                console.log('DK CibSimulazione lineaSimulazione' + lineaSimulazione.Number__c + ': ' + JSON.stringify(lineaSimulazione));
                // this.lineeSimulazioneMap.set(lineaSimulazione.Number__c, lineaSimulazione);
                this.lineeSimulazione.push(lineaSimulazione);
                
            })
            console.log('CHECK isValid 1', isValid);
            console.log('DK CibSimulazione isInputValid.lineeSimulazione:' + JSON.stringify(this.lineeSimulazione));
            let visibleFields = this.saveWhenHiddenSet;
            this.template.querySelectorAll('.validate').forEach(inputField => {
                if(!inputField.style || inputField.style.display != 'none'){
                    visibleFields.push(inputField.name)
                }
                if(inputField.name == 'Modello_di_Servizio__c'){
                    console.log('CHECK MDS', inputField.style.display, inputField.value, inputField.checkValidity());
                }
                if(inputField.style.display != 'none' && !inputField.checkValidity()) {
                    inputField.reportValidity();
                    isValid = false;
                    this.invalidFields.push(inputField.name);
                }
                this.simulazione[inputField.name] = inputField.type == 'checkbox' ? inputField.checked :
                inputField.type == 'number' ? Number(inputField.value) : ['true', 'false'].includes(inputField.value) ? /^true$/i.test(inputField.value) : inputField.value;
            });
            // if(visibleFields.includes('Segmento_di_Rischio__c'))visibleFields.push('Classe_di_rating__c')
            console.log('DK CibSimulazione visibleFields'+ JSON.stringify(visibleFields));
            Object.keys(this.simulazione).forEach(fieldSimulazione =>{
                if(fieldSimulazione.includes('__c') && !visibleFields.includes(fieldSimulazione)){
                    console.log('DK CibSimulazione FIELD BLANK: ', fieldSimulazione);
                    this.simulazione[fieldSimulazione] = typeof this.simulazione[fieldSimulazione] === 'boolean' ? false : null;
                }
            })

            console.log('CHECK isValid 2', isValid);
            console.log('DK CibSimulazione isInputValid.simulazione', JSON.stringify(this.simulazione));
            return isValid;
        } catch (error) {
            console.log('DK CibSimulazione isInputValid.error', error.message);
            return false;
        }
    }

    lineaPicklistWithNullValues = ['Preammortamento__c']
    saveWhenHiddenSet = ['Nome_titolare_operazione__c', 'Nome_del_Gestore__c', 'Opportunity__c', 'Account__c', 'Id', 'Segmento_Modello__c', 'Classe_di_rating__c'];

    @api
    handleSave(isNew, skipValidation, lineeToUpdateIdSet){
        console.log('DK CibSimulazione START handleSave');
        try {
            
            this.isLoading = true;
            console.log('DK SET isLoading', this.isLoading);
            if(skipValidation || this.isInputValid() === true){
                console.log('DK CibSimulazione READY TO SAVE');
                console.log('DK CibSimulazione handleSave.simulazione: ', JSON.stringify(this.simulazione));
                let rateLineeToUpsert = [];
                let rateLineeToDelete = [];
                let lineeToUpdate = [];
                this.lineeSimulazione.forEach(lineaSimulazione => {
                    if(!lineeToUpdateIdSet || lineeToUpdateIdSet.includes(lineaSimulazione.Id)){

                        this.lineaPicklistWithNullValues.forEach(field =>{
                            if(lineaSimulazione[field] == '' || lineaSimulazione[field] == 0){
                                lineaSimulazione[field] = null;
                            }
                        })
                        rateLineeToUpsert.push(...lineaSimulazione.rateLineeToUpsert);
                        rateLineeToDelete.push(...lineaSimulazione.rateLineeToDelete);
                        lineeToUpdate.push(lineaSimulazione);
                    }
                });
                console.log('DK CibSimulazione handleSave.lineeSimulazione: ', JSON.stringify(lineeToUpdate));
                console.log('DK rateLineeToUpsert', JSON.stringify(rateLineeToUpsert));
                console.log('DK rateLineeToDelete', JSON.stringify(rateLineeToDelete));
                return save({sim: this.simulazione, simLinee: lineeToUpdate, rateLineeToUpsert: rateLineeToUpsert, rateLineeToDelete: rateLineeToDelete})
                .then(result =>{
                    console.log('DK result', result);
                    console.log('DK isNew', isNew);
                    if(isNew === true && result){
                        return result;
                    }
                    this.simulazione = {};
                    this.lineeSimulazione = [];
                    return this.connectedCallback().then(() =>{
                        
                        this.isLoading = false;
                        console.log('DK SET isLoading', this.isLoading);
                        const toastEvent = new ShowToastEvent({
                            title: "Successo!",
                            message: 'Simulazione salvata con successo',
                            variant: "success"
                        });
                        this.dispatchEvent(toastEvent);
                    });
                })
                .catch(err =>{
                    this.isLoading = false;
                    console.log('DK SET isLoading', this.isLoading);
                    const toastEvent = new ShowToastEvent({
                        title: "Error!",
                        message:'Errore durante il salvataggio, contattare amministratore di sistema!',
                        variant: "error"
                    });
                    this.dispatchEvent(toastEvent);
                    console.log('DK CibSimulazione.handleSave.err', err);
                    throw err.message;
                })
            }else{
                console.log('DK INVALID FORM' + JSON.stringify(this.invalidFields));
                console.log('DK CibSimulazione invalidFields', JSON.stringify(this.invalidFields));
                console.log('DK CibSimulazione invalidFieldsLinee', JSON.stringify(this.invalidFieldsLinee));
                this.isLoading = false;
                console.log('DK SET isLoading', this.isLoading);
                
                const toastEvent = new ShowToastEvent({
                    title: "Error!",
                    message:'Controllare valorizzazione campi!',
                    variant: "error"
                });
                this.dispatchEvent(toastEvent);
            }
        } catch (error) {
            console.log('DK handleSave.error: ', error.message);   
        }
    }

    segmentoModelloMapping = {
        'LARGE': ['LARGE_CORPORATE'],
        'PMIIM': ['PMI_IMMOBILIARI'],
        'PMIHO': ['HOLDING'],
        'PMISL': ['POE'],
        'PMICO': ['PMI_CORPORATE'],
        'SOCFZ': ['SOCIETA_FINANZIARIE'],
        'AMMPB': ['PMI_CORPORATE'],
        'SMA00': ['POE', 'PMI_RETAIL'],
        'NONAT': ['POE'],
        'BANCH': ['LARGE_CORPORATE'],
    }

    areaGeograficaRatingMapping = {
        'NORD-OVEST': '6',
        'NORD-EST': '6',
        'CENTRO': '7',
        'SUD': '7',
        'ISOLE': '6',
    }

    classeRatingMapping = {
        'LARGE': ['1','2','3','4','5','6','7','8','9'],
        'PMIHO': ['1','2','3','4','5','6','7','8','9'],
        'PMISL': ['7'],
        'AMMPB': ['6','7'],
        'NONAT': ['8'],
        'BANCH': ['3'],
    }

    get optionsClasseRatingDelta(){
        if(this.loaded && this.simulazione){
            console.log('DK this.simulazione.Segmento_di_Rischio__c', this.simulazione.Segmento_di_Rischio__c);
            console.log('DK this.classeRatingMapping[this.simulazione.Segmento_di_Rischio__c]', JSON.stringify(this.classeRatingMapping[this.simulazione.Segmento_di_Rischio__c]));
            console.log('DK this.optionsClasseRating', this.areaGeograficaRatingMapping[this.simulazione.AreaGeografica__c]);
            return this.simulazione.Segmento_di_Rischio__c == 'AMMPB' && this.simulazione.AreaGeografica__c ? this.optionsClasseRating.filter(element =>{return element.value == this.areaGeograficaRatingMapping[this.simulazione.AreaGeografica__c]}): 
            this.classeRatingMapping[this.simulazione.Segmento_di_Rischio__c] ? this.optionsClasseRating.filter(element =>{return this.classeRatingMapping[this.simulazione.Segmento_di_Rischio__c].includes(element.value)}) : this.optionsClasseRating;
        }
        return this.optionsClasseRating;
    }

    get optionsSegmentoModelloDelta(){
        if(this.loaded && this.simulazione){
            console.log('DK this.simulazione.Segmento_di_Rischio__c', this.simulazione.Segmento_di_Rischio__c);
            console.log('DK this.segmentoModelloMapping[this.simulazione.Segmento_di_Rischio__c]', JSON.stringify(this.segmentoModelloMapping[this.simulazione.Segmento_di_Rischio__c]));
            console.log('DK this.optionsSegmentoModello', JSON.stringify(this.optionsSegmentoModello));
            let optionsSegmentoModelloDeltaLocal = this.simulazione.Segmento_di_Rischio__c && this.segmentoModelloMapping[this.simulazione.Segmento_di_Rischio__c] ? this.optionsSegmentoModello.filter(element =>{return this.segmentoModelloMapping[this.simulazione.Segmento_di_Rischio__c].includes(element.value)}) : this.optionsSegmentoModello;
            // console.log('DK one segmento_Modello: ', optionsSegmentoModelloDeltaLocal.length);
            if(optionsSegmentoModelloDeltaLocal && optionsSegmentoModelloDeltaLocal.length === 1){
                this.simulazione.Segmento_Modello__c = optionsSegmentoModelloDeltaLocal[0].value;
            }
            return optionsSegmentoModelloDeltaLocal;
        }
        return this.optionsSegmentoModello;
    }

    get optionsClasseMeritoDelta(){

        return this.loaded && this.simulazione && this.optionsClasseMerito && this.simulazione.Segmento_di_Rischio__c !== 'AMMPB' ? this.optionsClasseMerito.filter(element =>{return element.value !== 'UE/UEA'}) : this.optionsClasseMerito;
    }

    /*get segmentoModelloIsOne(){
        return this.loaded && this.simulazione && this.optionsSegmentoModelloDelta && this.optionsSegmentoModelloDelta.length === 1;
    }*/

    provinciaValueMap = {
        'AGRIGENTO': 'AG',
        'ALESSANDRIA':'AL',
        'ANCONA':'AN',
        'AOSTA':'AO',
        'ASCOLI PICENO':'AP',
        'L\'AQUILA':'AQ',
        'AREZZO':'AR',
        'ASTI':'AT',
        'AVELLINO':'AV',
        'BARI':'BA',
        'BERGAMO':'BG',
        'BIELLA':'BI',
        'BELLUNO':'BL',
        'BENEVENTO':'BN',
        'BOLOGNA':'BO',
        'BRINDISI':'BR',
        'BRESCIA':'BS',
        'BARLETTA ANDRIA TRANI':'BT',
        'BOLZANO':'BZ',
        'CAGLIARI':'CA',
        'CAMPOBASSO':'CB',
        'CASERTA':'CE',
        'CHIETI':'CH',
        'CARBONIA IGLESIAS':'CI',
        'CALTANISSETTA':'CL',
        'CUNEO':'CN',
        'COMO':'CO',
        'CREMONA':'CR',
        'COSENZA':'CS',
        'CATANIA':'CT',
        'CATANZARO':'CZ',
        'ENNA':'EN',
        'FORLI\' CESENA':'FC',
        'FERRARA':'FE',
        'FOGGIA':'FG',
        'FIRENZE':'FI',
        'FERMO':'FM',
        'FROSINONE':'FR',
        'GENOVA':'GE',
        'GORIZIA':'GO',
        'GROSSETO':'GR',
        'IMPERIA':'IM',
        'ISERNIA':'IS',
        'CROTONE':'KR',
        'LECCO':'LC',
        'LECCE':'LE',
        'LIVORNO':'LI',
        'LODI':'LO',
        'LATINA':'LT',
        'LUCCA':'LU',
        'MONZA E DELLA BRIANZA':'MB',
        'MACERATA':'MC',
        'MESSINA':'ME',
        'MILANO':'MI',
        'MANTOVA':'MN',
        'MODENA':'MO',
        'MASSA CARRARA':'MS',
        'MATERA':'MT',
        'NAPOLI':'NA',
        'NOVARA':'NO',
        'NUORO':'NU',
        'OGLIASTRA':'OG',
        'ORISTANO':'OR',
        'OLBIA TEMPIO':'Ot',
        'PALERMO':'PA',
        'PIACENZA':'PC',
        'PADOVA':'PD',
        'PESCARA':'PE',
        'PERUGIA':'PG',
        'PISA':'PI',
        'PORDENONE':'PN',
        'PRATO':'PO',
        'PARMA':'PR',
        'PISTOIA':'PT',
        'PESARO URBINO':'PU',
        'PAVIA':'PV',
        'POTENZA':'PZ',
        'RAVENNA':'RA',
        'REGGIO CALABRIA':'RC',
        'REGGIO EMILIA':'RE',
        'RAGUSA':'RG',
        'RIETI':'RI',
        'ROMA':'RM',
        'RIMINI':'RN',
        'ROVIGO':'RO',
        'SALERNO':'SA',
        'SIENA':'SI',
        'SONDRIO':'SO',
        'LA SPEZIA':'SP',
        'SIRACUSA':'SR',
        'SASSARI':'SS',
        'SUD SARDEGNA':'SU',
        'SAVONA':'SV',
        'TARANTO':'TA',
        'TERAMO':'TE',
        'TRENTO':'TN',
        'TORINO':'TO',
        'TRAPANI':'TP',
        'TERNI':'TR',
        'TRIESTE':'TS',
        'TREVISO':'TV',
        'UDINE':'UD',
        'VARESE':'VA',
        'VERBANO CUSIO OSSOLA':'VB',
        'VERCELLI':'VC',
        'VENEZIA':'VE',
        'VICENZA':'VI',
        'VERONA':'VR',
        'MEDIO CAMPIDANO':'VS',
        'VITERBO':'VT',
        'VIBO VALENTIA':'VV'
    }

    areaGeograficaMapping = {
        'FR': 'CENTRO',
        'LT': 'CENTRO',
        'RI': 'CENTRO',
        'RM': 'CENTRO',
        'VT': 'CENTRO',
        'AN': 'CENTRO',
        'AP': 'CENTRO',
        'FM': 'CENTRO',
        'MC': 'CENTRO',
        'PU': 'CENTRO',
        'PS': 'CENTRO',
        'CA': 'ISOLE',
        'CI': 'ISOLE',
        'VS': 'ISOLE',
        'NU': 'ISOLE',
        'OG': 'ISOLE',
        'OT': 'ISOLE',
        'OR': 'ISOLE',
        'SS': 'ISOLE',
        'AR': 'CENTRO',
        'FI': 'CENTRO',
        'GR': 'CENTRO',
        'LI': 'CENTRO',
        'LU': 'CENTRO',
        'MS': 'CENTRO',
        'PI': 'CENTRO',
        'PT': 'CENTRO',
        'PO': 'CENTRO',
        'SI': 'CENTRO',
        'PG': 'CENTRO',
        'TR': 'CENTRO',
        'GO': 'NORD-EST',
        'PN': 'NORD-EST',
        'TS': 'NORD-EST',
        'UD': 'NORD-EST',
        'BO': 'NORD-EST',
        'FE': 'NORD-EST',
        'FC': 'NORD-EST',
        'MO': 'NORD-EST',
        'PR': 'NORD-EST',
        'PC': 'NORD-EST',
        'RA': 'NORD-EST',
        'RE': 'NORD-EST',
        'RN': 'NORD-EST',
        'FO': 'NORD-EST',
        'BZ': 'NORD-EST',
        'TN': 'NORD-EST',
        'BL': 'NORD-EST',
        'PD': 'NORD-EST',
        'RO': 'NORD-EST',
        'TV': 'NORD-EST',
        'VE': 'NORD-EST',
        'VR': 'NORD-EST',
        'VI': 'NORD-EST',
        'GE': 'NORD-OVEST',
        'IM': 'NORD-OVEST',
        'SP': 'NORD-OVEST',
        'SV': 'NORD-OVEST',
        'BG': 'NORD-OVEST',
        'BS': 'NORD-OVEST',
        'CO': 'NORD-OVEST',
        'CR': 'NORD-OVEST',
        'LC': 'NORD-OVEST',
        'LO': 'NORD-OVEST',
        'MN': 'NORD-OVEST',
        'MI': 'NORD-OVEST',
        'MB': 'NORD-OVEST',
        'PV': 'NORD-OVEST',
        'SO': 'NORD-OVEST',
        'VA': 'NORD-OVEST',
        'AL': 'NORD-OVEST',
        'AT': 'NORD-OVEST',
        'BI': 'NORD-OVEST',
        'CN': 'NORD-OVEST',
        'NO': 'NORD-OVEST',
        'TO': 'NORD-OVEST',
        'VB': 'NORD-OVEST',
        'VC': 'NORD-OVEST',
        'AO': 'NORD-OVEST',
        'AQ':'SUD',
        'CH':'SUD',
        'PE':'SUD',
        'TE':'SUD',
        'MT':'SUD',
        'PZ':'SUD',
        'CZ':'SUD',
        'CS':'SUD',
        'KR':'SUD',
        'RC':'SUD',
        'VV':'SUD',
        'AV':'SUD',
        'BN':'SUD',
        'CE':'SUD',
        'NA':'SUD',
        'SA':'SUD',
        'CB':'SUD',
        'IS':'SUD',
        'BA':'SUD',
        'BT':'SUD',
        'BR':'SUD',
        'FG':'SUD',
        'LE':'SUD',
        'TA':'SUD',
        'AG': 'ISOLE',
        'CL': 'ISOLE',
        'CT': 'ISOLE',
        'EN': 'ISOLE',
        'ME': 'ISOLE',
        'PA': 'ISOLE',
        'RG': 'ISOLE',
        'SR': 'ISOLE',
        'TP': 'ISOLE',
        'SU': 'ISOLE',
    }
}