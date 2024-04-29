import { LightningElement, api, track} from 'lwc';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

import getUserInfo from '@salesforce/apex/SV_Utilities.getUserInfo';
import init from '@salesforce/apex/SpostaNdgIterController.init';
import loadMwList from '@salesforce/apex/SpostaNdgIterDataLoader.loadMwList';
import loadNdgList from '@salesforce/apex/SpostaNdgIterController.loadNdgList';
import sendMovementRequest from '@salesforce/apex/SpostaNdgIterController.sendMovementRequest';
import moveNdgsToWallet from '@salesforce/apex/SpostaNdgIterController.moveNdgsToWallet';
import createQueues from '@salesforce/apex/SpostaNdgIterController.createQueues';
import approveWorkOrders from '@salesforce/apex/SpostaNdgIterController.approveWorkOrders';
import UserPreferencesNewLightningReportRunPageEnabled from '@salesforce/schema/User.UserPreferencesNewLightningReportRunPageEnabled';

import MicroPortafoglio from '@salesforce/label/c.spostaNdgIter_CLM_MicroPortafoglio';
import ModelloServizio from '@salesforce/label/c.spostaNdgIter_CLM_ModelloServizio';
import Filiale from '@salesforce/label/c.spostaNdgIter_CLM_Filiale';
import Referente from '@salesforce/label/c.spostaNdgIter_CLM_Referente';
import NdgCLM_NDG from '@salesforce/label/c.spostaNdgIter_NdgCLM_NDG';
import NdgCLM_Nominativo from '@salesforce/label/c.spostaNdgIter_NdgCLM_Nominativo';
import NdgCLM_Capogruppo from '@salesforce/label/c.spostaNdgIter_NdgCLM_Capogruppo';
import NdgCLM_NaturaGiuridica from '@salesforce/label/c.spostaNdgIter_NdgCLM_NaturaGiuridica';
import NdgCLM_Patrimonio from '@salesforce/label/c.spostaNdgIter_NdgCLM_Patrimonio';
import NdgCLM_Utilizzato from '@salesforce/label/c.spostaNdgIter_NdgCLM_Utilizzato';
import CoCLM_NDG from '@salesforce/label/c.spostaNdgIter_CoCLM_NDG';
import CoCLM_Nominativo from '@salesforce/label/c.spostaNdgIter_CoCLM_Nominativo';
import CoCLM_NaturaGiuridica from '@salesforce/label/c.spostaNdgIter_CoCLM_NaturaGiuridica';
import CoCLM_Patrimonio from '@salesforce/label/c.spostaNdgIter_CoCLM_Patrimonio';
import CoCLM_Utilizzato from '@salesforce/label/c.spostaNdgIter_CoCLM_Utilizzato';
import CoCLM_Fatturato from '@salesforce/label/c.spostaNdgIter_CoCLM_Fatturato';
import CoCLM_Accordato from '@salesforce/label/c.spostaNdgIter_CoCLM_Accordato';

const mwColumns = [
    {
        label: MicroPortafoglio,
        fieldName: 'Name',
        type: 'text',
        cellAttributes:{class:{fieldName: 'typeCSSClass' }}
    },
    {
        label: ModelloServizio,
        fieldName: 'PTF_ModelloDiServizio__c',
        type: 'text'
    },
    {
        label: Filiale,
        fieldName: 'Filiale',
        type: 'text'
    },
    {
        label: Referente,
        fieldName: 'Referente',
        type: 'text'
    }
];

const ndgColumns = [
    { label: NdgCLM_NDG, fieldName: 'PTF_Url', type: 'url', 
    cellAttributes:{ iconName: { fieldName: 'provenanceIconName' } },
        typeAttributes: {
            label: { fieldName: 'CRM_NDG__c' }
        },
        hideDefaultActions: "true"},
    { label: NdgCLM_Nominativo, fieldName: 'Name', type: 'text' },
    { label: NdgCLM_Capogruppo, fieldName: '', type: 'Boolean', hideDefaultActions: "true", cellAttributes: {
        iconName: { fieldName: 'PTF_IsCaponugruppoIcon' },
        iconPosition: 'left'
    }},
    { label: NdgCLM_NaturaGiuridica, fieldName: 'PTF_NaturaGiuridica__c', type: 'text' },
    { label: NdgCLM_Patrimonio, fieldName: 'PTF_Patrimonio__c', type: 'currency', cellAttributes: { alignment: 'left' }},
    { label: NdgCLM_Utilizzato, fieldName: 'PTF_Utilizzato__c', type: 'currency', cellAttributes: { alignment: 'left' }}
    // { label: 'Coerenza Gruge', fieldName: '', type: 'text',cellAttributes:{class:{fieldName:"typeCSSClass"}} }
];

const coColumns = [
    { label: CoCLM_NDG, fieldName: 'PTF_Url', type: 'url', 
    cellAttributes:{ iconName: { fieldName: 'provenanceIconName' } },
        typeAttributes: {
            label: { fieldName: 'CRM_NDG__c' }
        },
        hideDefaultActions: "true"},
    { label: CoCLM_Nominativo, fieldName: 'Name', type: 'text' },
    { label: CoCLM_NaturaGiuridica, fieldName: 'PTF_NaturaGiuridica__c', type: 'text' },
    { label: CoCLM_Patrimonio, fieldName: 'PTF_Patrimonio__c', type: 'currency', cellAttributes: { alignment: 'left' }},
    { label: CoCLM_Utilizzato, fieldName: 'PTF_Utilizzato__c', type: 'currency', cellAttributes: { alignment: 'left' }},
    { label: CoCLM_Fatturato, fieldName: 'AnnualRevenue', type: 'currency', cellAttributes: { alignment: 'left' }},
    { label: CoCLM_Accordato, fieldName: 'PTF_Accordato__c', type: 'currency', cellAttributes: { alignment: 'left' }}
    // { label: 'Coerenza Gruge', fieldName: '', type: 'text',cellAttributes:{class:{fieldName:"typeCSSClass"}} }
];
export default class SpostaNdgIter extends NavigationMixin(LightningElement) {

    @api recordId;

    @api userInfo;
    @api profiliAutorizzati;
    @api profiloAutorizzatoShow = false;
    @api messaggioDiBloccoTitle;
    @api bloccoIter;

    @api modelliDiServizio;
    @api titolo;
    @api labelBottone;
    @track openAddNdgmodal = false;
    @track isStep1 = false;
    @track isStep2 = false;
    @track showAvanti = false;
    @track showIndietro = false;
    @track showSalva = false;
    currentNDG = {};
    ruolo;
    superUser = false;
    gruppoFinanziarioId;
    hasDifferent;
    mdsPrimario = '';
    filialePrimario = '';
    mdsCo = '';
    isCapoGruppo = false;
    portafogliInEvidenza = {};
    portafogliInEvidenzaEligible = [];
    portafogliInEvidenzaEligibleIds = [];
    cointestazioni = [];
    microportafogliCointestazioniFiliali = [];
    @track hasCointestazione = false;
    @track allInSame = false;
    currentUser = {};
    currentContact = {};
    currentPF = {};
    mdsConfigurazioniMap = {};
    filialeConfigurazioniMap = {};
    filialeMDSConfigurazioniMap = {};
    referentiConfigurazioniMap = {};
    mdsEligible = [];
    branchEligible = [];
    modelliNames = [];
    servceModelMap = {};
    modelloDiServizioList = [];

    mwColumns = mwColumns;
    ndgColumns = ndgColumns;
    coColumns = coColumns;

    hasOFS;

    @track titoloSimulazione = 'Volumi complessivi';
    
    @track searchedBancaMw;
    @track searchedDrMw;
    @track searchedAreaMw;
    @track searchedFilialeMw;
    @track searchedMDSMw;
    @track searchedReferenteMw;
    @track searchedNomeMw;
    @track mwList = [];
    @track filteredMwList = [];
    @track selectedMWRows = [];
    @track selectedMWRowIds = [];
    @track mwListCount;
    @track mwOffset = 0;
    @track mwLimit = 50000;
    @track searchedNomeNDG;
    @track searchedNdgNDG;
    @track ndgList = [];
    @track selectedNDGRows = [];
    @track selectedNDGRowIds = [];
    @track ndgListCount;
    @track ndgOffset = 0;
    @track ndgLimit = 50000;
    @track tableTarget = {};
    @track simulazioneAccordato = 0;
    @track simulazioneFatturato = 0;
    @track simulazionePartimonio = 0;
    @track simulazioneUtilizzato = 0;
    @track startMDS;
    @track startFiliale;
    @track startFilialeBranch;
    @track note;
    @track noteIsRequired = false;

    @track showMessage = false;
    @track message;
    @track lastMessage;

    errorMessage = '';

    bloccoSpostamenti = false;

    @track primari = [];
    @track loaded = false;
    

    //START EVO - SPOSTAMENTO REFRENTI(MULTIOPTION)
    @track controlloPicklist = [];
    @track controlloPicklistMap = {};
    @track controllo = '';
    @track multiOption = false;
    //END EVO - SPOSTAMENTO REFRENTI(MULTIOPTION)

    @track disabled = true;
    connectedCallback(){

        console.log('DK this.bloccoIter: ' + this.bloccoIter);

        getUserInfo()
        .then(result => {
            console.log('DK getUserInfo result', result);
            console.log('DK profiliAutorizzati', this.profiliAutorizzati);

            this.userInfo = result;
            if(!Boolean(this.profiliAutorizzati) || this.profiliAutorizzati.includes(result.Profile.Name)){
                this.profiloAutorizzatoShow = true;
            }
            console.log('DK profiloAutorizzatoShow', this.profiloAutorizzatoShow);

            if(this.profiloAutorizzatoShow){
                this.bloccoSpostamenti = Boolean(this.messaggioDiBloccoTitle);
                return init({recordId: this.recordId});
            }
        }).then(result => {
            
            let dataTableGlobalStyle = document.createElement('style');
            dataTableGlobalStyle.innerHTML = `
            .color-green {
                font-weight: 500;
                color: green;
            }
            .no-button {
                text-align: center;
                color: ##1c1f1d;
                font-weight: 800;
                text-transform: uppercase;
            }`;
            document.head.appendChild(dataTableGlobalStyle);

            console.log('DK SpostaNdgIter.init.result: ' + JSON.stringify(result));
            this.errorMessage = result['errorMessage'];
            console.log('pz SpostaNdgIter.init.result currentNDG: ' + JSON.stringify(result['currentNDG']));
            console.log('pz SpostaNdgIter.init.result mdsConfigurazioniMap: ' + JSON.stringify(result['mdsConfigurazioniMap']));
            console.log('pz SpostaNdgIter.init.result ruolo: ' + JSON.stringify(result['ruolo']));
            console.log('pz SpostaNdgIter.init.result portafogliInEvidenza: ' + JSON.stringify(result['portafogliInEvidenza']));
            console.log('pz SpostaNdgIter.init.result currentPF: ' + JSON.stringify(result['currentPF']));
            console.log('pz SpostaNdgIter.init.result currentPF ref: ' + JSON.stringify(result['currentPF.Referente']));

            if(!Boolean(this.errorMessage)){
                
                this.currentNDG = result['currentNDG'];
                this.hasOFS = this.currentNDG.PTF_OFS__c;
                this.isStep1 = true;            
                this.currentPF = result['currentPF'];
                this.extendMW(this.currentPF);
                console.log('DK this.currentPF: ' + this.currentPF.Referente);
                console.log('DK this.currentPF: ' +  result['currentPF']);
                console.log('DK this.currentPF: ' +  JSON.stringify(this.currentPF));
                
                this.currentUser = result['currentUser'];
                this.superUser = this.currentUser.Profilo__c == 'NEC_D.0';
                this.currentContact = result['currentContact'];
                this.mdsConfigurazioniMap = result['mdsConfigurazioniMap'];
                this.filialeConfigurazioniMap = result['filialeConfigurazioniMap'];
                this.filialeMDSConfigurazioniMap = result['filialeMDSConfigurazioniMap'];
                this.referentiConfigurazioniMap = result['referentiConfigurazioniMap'];
                this.ruolo = result['ruolo'];
                this.gruppoFinanziarioId = result['gruppoFinanziarioId'];
                this.hasDifferent = result['hasDifferent'];
                this.mdsPrimario = result['mdsPrimario'];
                this.filialePrimario = result['filialePrimario'];
                this.mdsCo = result['mdsCo'];
                console.log('DK mdsCo: ' + this.mdsCo);
                this.microportafogliCointestazioniFiliali = result['microportafogliCointestazioniFiliali'];
                this.servceModelMap = result['servceModelMap'];
                this.modelloDiServizioList = result['modelloDiServizioList'];

                this.startMDS = this.currentPF.PTF_ModelloDiServizio__c;
                this.startFiliale = this.currentPF.PTF_Filiale__c;
                this.startFilialeBranch = this.currentPF.PTF_Filiale__r.PTF_BranchTypeDesc__c;
                
                let mdsPortafogliInEvidenza = Boolean(result['portafogliInEvidenza']) ? result['portafogliInEvidenza'].map(item => item.PTF_ModelloDiServizio__c) : [];
                console.log('DK mdsPortafogliInEvidenza: ' + JSON.stringify(mdsPortafogliInEvidenza));
                console.log('DK this.microportafogliCointestazioniFiliali: ' + JSON.stringify(this.microportafogliCointestazioniFiliali));
                for(var key in this.mdsConfigurazioniMap){
                    
                    if(key.split('_')[0] == this.currentPF.PTF_ModelloDiServizio__c){
                        
                        console.log('DK key: ' + key);
                        //quando le cointestazioni sono in portafogli diversi da quello del primario e fanno parte di portafogli diversi tra loro
                        //gli unici portafogli eligible sono quelli di tipo Consulenti Finanziari
                        if(!this.mdsEligible.includes(key.split('_')[1])){
                            
                            if((this.ruolo == 'primario' && this.hasDifferent) ||
                                this.ruolo == 'cointestazione'){
    
                                if(key.split('_')[1] == 'Consulenti Finanziari' ||
                                    mdsPortafogliInEvidenza.includes(key.split('_')[1])){
                                    
                                    this.mdsEligible.push(key.split('_')[1]);
                                }else if(this.ruolo == 'cointestazione' &&
                                    key.split('_')[1] == this.mdsPrimario){
    
                                    this.mdsEligible.push(key.split('_')[1]);
                                }
                            }else{
    
                                this.mdsEligible.push(key.split('_')[1]);
                            }
                        }
                    }
                }

                if(this.filialeConfigurazioniMap){

                    if(!this.mdsEligible.includes(this.startMDS)){

                        this.mdsEligible.push(this.startMDS);
                    }
                }
                for(var key in this.filialeMDSConfigurazioniMap){
                    
                    if(key.split('_')[0] == this.currentPF.PTF_ModelloDiServizio__c){
                        
                        console.log('DK key: ' + key);
                        //quando le cointestazioni sono in portafogli diversi da quello del primario e fanno parte di portafogli diversi tra loro
                        //gli unici portafogli eligible sono quelli di tipo Consulenti Finanziari
                        if(!this.mdsEligible.includes(key.split('_')[1])){
                            
                            if((this.ruolo == 'primario' && this.hasDifferent) ||
                                this.ruolo == 'cointestazione'){
    
                                if(key.split('_')[1] == 'Consulenti Finanziari' ||
                                    mdsPortafogliInEvidenza.includes(key.split('_')[1])){
                                    
                                    this.mdsEligible.push(key.split('_')[1]);
                                }else if(this.ruolo == 'cointestazione' &&
                                    key.split('_')[1] == this.mdsPrimario){
    
                                    this.mdsEligible.push(key.split('_')[1]);
                                }
                            }else{
    
                                this.mdsEligible.push(key.split('_')[1]);
                            }
                        }
                    }
                }

                for(var key in this.referentiConfigurazioniMap){
                    
                    if(key.split('_')[0] == this.currentPF.PTF_ModelloDiServizio__c){
                        
                        console.log('DK key: ' + key);
                        //quando le cointestazioni sono in portafogli diversi da quello del primario e fanno parte di portafogli diversi tra loro
                        //gli unici portafogli eligible sono quelli di tipo Consulenti Finanziari
                        if(!this.mdsEligible.includes(key.split('_')[1])){
                            
                            if((this.ruolo == 'primario' && this.hasDifferent) ||
                                this.ruolo == 'cointestazione'){
    
                                if(key.split('_')[1] == 'Consulenti Finanziari' ||
                                    mdsPortafogliInEvidenza.includes(key.split('_')[1])){
                                    
                                    this.mdsEligible.push(key.split('_')[1]);
                                }else if(this.ruolo == 'cointestazione' &&
                                    key.split('_')[1] == this.mdsPrimario){
    
                                    this.mdsEligible.push(key.split('_')[1]);
                                }
                            }else{
    
                                this.mdsEligible.push(key.split('_')[1]);
                            }
                        }
                    }
                }
                console.log('DK mdsEligible: ' + JSON.stringify(this.mdsEligible));
                this.branchEligible = result['branchEligible'];
                console.log('DK branchEligible: ' + JSON.stringify(this.branchEligible));
                if(this.ruolo != 'capoGruppo'){
                    
                    this.showAvanti = false;
                    this.showIndietro = false;
                    this.showSalva = true;
                }else{
    
                    this.showAvanti = true;
                    this.showIndietro = false;
                    this.showSalva = false;
                }
                
                if(result['portafogliInEvidenza']){
                    console.log('pz js388');
                    if(result['portafogliInEvidenza'].length > 0){
    
                        
                        this.portafogliInEvidenzaEligible = result['portafogliInEvidenza'];
                        this.portafogliInEvidenzaEligibleIds = this.portafogliInEvidenzaEligible.map(item => item.Id);
                        this.portafogliInEvidenzaEligible.forEach(element => {

                            this.extendMW(element);
                        });
                    }

                    // this.portafogliInEvidenzaEligibleIds = this.portafogliInEvidenzaEligible.map(item => item.Id);
                    if(this.ruolo == 'membroGruppo'){
                        console.log('pz js402');
                        this.showMessage = true;
                        this.message = "SELEZIONANDO UN MICROPORTAFOGLIO DIFFERENTE DA QUELLO DELL'NDG CAPOGRUPPO, SARÀ GENERATA UN'ANOMALIA. IN EVIDENZA L’ATTUALE MICROPORTAFOGLIO DELL’NDG CAPOGRUPPO.";
                    }else if(this.ruolo == 'primario'){
                        console.log('pz js406');
                        this.showMessage = true;
                        //prod//this.message = "Al fine di sanare l’anomalia esistente, In evidenza i portafogli delle Cointestazioni non nello stesso microportafoglio del primario, se idonei.";
                        //pz 02.08.2023 new message fornito da valanzano
                        if(result['portafogliInEvidenza'].length > 0){
                            this.message = "AL FINE DI SANARE L'ANOMALIA PRESENTE TRA PRIMARIO E CO, IN EVIDENZA IL PORTAFOGLIO DELLA COINTESTAZIONE VERSO IL QUALE SPOSTARE L'NDG PRIMARIO 188. NON SELEZIONARE PTF DEL MDS CF SE NON DIRETTAMENTE RICHIESTO."
                        }else{
                            this.message = "SPOSTAMENTO CONSENTITO SOLO VERSO CONSULENTI FINANZIARI IN QUANTO PRESENTE ANOMALIA TRA PRIMARIO E CO. PREGASI ATTRIBUIRE NDG PRIMARIO E CO ALLO STESSO PORTAFOGLIO. NON SELEZIONARE PTF DEL MDS CF SE NON DIRETTAMENTE RICHIESTO."
                        }
                    }else if(this.ruolo == 'cointestazione'){
                        console.log('pz js412');
                        this.showMessage = true;
                        
                        //prod //this.message = "Al fine di sanare l'anomalia esistente, spostamento consentito solo verso il Portafoglio del Primario (se idoneo) o la sua filiale";
                        //prod //this.lastMessage = "Alternativamente, spostare verso portafogli con modello di servizio Consulenti Finanziari."
                        //pz 02.08.2023 new message fornito da valanzano
                        // this.message = "L'ATTRIBUZIONE DEL PORTAFOGLIO EVIDENZIATO PERMETTERA' DI SANARE L'ANOMALIA ESISTENTE";
                        this.message = "SPOSTAMENTO CONSENTITO SOLO VERSO CONSULENTI FINANZIARI IN QUANTO PRESENTE ANOMALIA TRA PRIMARIO E CO.";
                        this.lastMessage = "PREGASI ATTRIBUIRE NDG PRIMARIO E CO ALLO STESSO PORTAFOGLIO. NON SELEZIONARE PTF DEL MDS CF SE NON DIRETTAMENTE RICHIESTO";
                    }
                }else{
                    console.log('pz js422');
                    if(this.ruolo == 'membroGruppo'){
                        console.log('pz js424');
                        this.allInSame = true;
                        this.showMessage = true;
                        this.message = "Spostando l’NDG dal microportafoglio dell’NDG Capogruppo, sarà generata un’anomalia.";
                    }else if(this.ruolo == 'primario'){
                        console.log('pz js429');
                        this.allInSame = this.hasDifferent ? false : true;
                        this.showMessage = this.allInSame ? true : false;
                        this.message = this.showMessage ? "Spostando l’NDG, si sposteranno tutte le Cointestazioni per cui è primario." : "";
                    }else if(this.ruolo == 'cointestazione'){
                        console.log('pz js34');
                        //this.allInSame = true;
                        //this.showMessage = true;
                        this.allInSame = this.hasDifferent ? false : true;
                        this.showMessage = this.allInSame ? true : false;
                        this.message = this.showMessage ? "SPOSTAMENTO NON CONSENTITO IN QUANTO VERREBBE GENERATA ANOMALIA TRA PRIMARIO E CO." : "";
                        this.lastMessage = this.showMessage ? "PROCEDERE ALLO SPOSTAMENTO PARTENDO DALL'NDG PRIMARIO (IL QUALE TRASCINEREBBE CON SE' ANCHE LA CO). NON SELEZIONARE I PTF DEL MDS CF SE NON DIRETTAMENTE RICHIESTO." :"";
                        //this.message = "Spostamento consentito solo verso microportafogli con MDS Consulenti Finanziari.";
                       // this.lastMessage = "Per tutti gli altri, procedere con lo spostamento contestuale partendo dall’NDG primario.";
                       //PZ CR 70767 
                        //this.message = "SPOSTAMENTO NON CONSENTITO IN QUANTO VERREBBE GENERATA ANOMALIA TRA PRIMARIO E CO."
                        //this.lastMessage = "PROCEDERE ALLO SPOSTAMENTO PARTENDO DALL'NDG PRIMARIO (IL QUALE TRASCINEREBBE CON SE' ANCHE LA CO). NON SELEZIONARE I PTF DEL MDS CF SE NON DIRETTAMENTE RICHIESTO."
                       
                    }else if(this.ruolo == 'cointestatario'){

                        this.allInSame = this.hasDifferent ? false : true;
                        this.showMessage = this.allInSame ? true : false;
                        
                        //prod //this.message = this.showMessage ? "Presenza di anomalia 188 e CO. Valutare intervento di modifica in Anagrafe (modifica 188)." : "";
                        //prod //this.lastMessage = this.showMessage ? "Spostamento Consentito Solo Verso Consulenti Finanziari In Quanto Presente Anomalia Tra Primario E Co. Pregasi Attribuire Ndg Primario E Co Allo Stesso Portafoglio. Non Selezionare Ptf Del Mds Cf Se Non Direttamente Richiesto." :"";
                        //pz 02.08.2023 new message fornito da valanzano
                        //PZ CR 70767
                        this.message = this.showMessage ? "PRESENZA DI ANOMALIA TRA PRIMARIO E CO (PORTAFOGLI DIVERSI). VALUTARE INTERVENTO DI MODIFICA IN ANAGRAGE (MODIFICA 188)." : "";
                        this.lastMessage = this.showMessage ? "SPOSTAMENTO CONSENTITO SOLO VERSO CONSULENTI FINANZIARI. NON SELEZIONARE PTF DEL MDS CF SE NON DIRETTAMENTE RICHIESTO." :"";
                    }
                }
                this.cointestazioni = result['cointestazioni'];
                this.simulazioneFatturato = Boolean(this.currentNDG.AnnualRevenue) ? this.currentNDG.AnnualRevenue : 0;
                this.simulazioneAccordato = Boolean(this.currentNDG.PTF_Accordato__c) ? this.currentNDG.PTF_Accordato__c : 0;
                this.simulazionePartimonio = Boolean(this.currentNDG.PTF_Patrimonio__c) ? this.currentNDG.PTF_Patrimonio__c : 0;
                this.simulazioneUtilizzato = Boolean(this.currentNDG.PTF_Utilizzato__c) ? this.currentNDG.PTF_Utilizzato__c : 0;
    
                if(this.cointestazioni){
    
                    if(this.cointestazioni.length > 0){
                        
                        this.hasCointestazione = true;
                        this.cointestazioni.forEach(cointestazione => {
                            cointestazione.PTF_Url = '/' + cointestazione.Id;
                            this.simulazioneFatturato = Boolean(cointestazione.AnnualRevenue) ? this.simulazioneFatturato + cointestazione.AnnualRevenue : this.simulazioneFatturato;
                            this.simulazioneAccordato = Boolean(cointestazione.PTF_Accordato__c) ? this.simulazioneAccordato + cointestazione.PTF_Accordato__c : this.simulazioneAccordato;
                            this.simulazionePartimonio = Boolean(cointestazione.PTF_Patrimonio__c) ? this.simulazionePartimonio + cointestazione.PTF_Patrimonio__c : this.simulazionePartimonio;
                            this.simulazioneUtilizzato = Boolean(cointestazione.PTF_Utilizzato__c) ? this.simulazioneUtilizzato + cointestazione.PTF_Utilizzato__c : this.simulazioneUtilizzato;
                        });
                    }
                }
                console.log('DK showMessage: ' + this.showMessage);
                console.log('DK message: ' + this.message);
                
            }
            this.disabled = false;

        }).catch(error => {

            console.log('DK init.error: ' + JSON.stringify(error));
            console.log('DK init.error2: ' + error);
        });
    }

    handleOpenModal(){

        console.log('DK Start handleOpenModal');
        console.log('DK this.bloccoIter: ' + this.bloccoIter);
        if(this.bloccoIter){
            const toastEvent = new ShowToastEvent({
                title: "Error!",
                message: Boolean(this.messaggioDiBloccoTitle) ? this.messaggioDiBloccoTitle : 'Creazione Iter Inibita per oggi, contatta il tuo amministratore.',
                variant: "error"
            });
            this.dispatchEvent(toastEvent);
        }else{

            if(!Boolean(this.errorMessage)){
    
                this.openAddNdgmodal = true;
                this.loaded = false;
                this.getAllData().then(() =>{
                    
                    this.loaded = true;
                    console.log('DK FINISHED');
                });
            }else{
    
                const toastEvent = new ShowToastEvent({
                    title: "Error!",
                    message: this.errorMessage,
                    variant: "error"
                });
                this.dispatchEvent(toastEvent);
            }
        }
    }

    get optionsModServizio(){
        let modServizio = this.superUser ? this.modelloDiServizioList : this.mdsEligible;
        let natureGiuridiche = ['PF', 'CO'];
        let objList = [];
        modServizio.forEach(element => {

            let obj = {};
            obj.label = element;
            obj.value = element;
            if(this.superUser){

                if(natureGiuridiche.includes(this.currentNDG.PTF_NaturaGiuridica__c)){
    
                    if(element != 'POE'){
        
                        objList.push(obj);
                    }
                }else{
                    
                    if(element != 'Family'){
        
                        objList.push(obj);
                    }
                }
            }else{

                objList.push(obj);
            }
        });
        return objList;
    }

    handlePaginaAvanti(){

        this.loaded = false;
        this.ndgOffset = 0;
        this.loadNDGRecords(false, true).
        then(() =>{

            this.isStep1 = false;
            this.isStep2 = true;
            this.showAvanti = false;
            this.showIndietro = true;
            this.showSalva = true;
            this.updateSimulazione(false);
            this.loaded = true;
        });
    }

    handlePaginaIndietro(){
        
        this.isStep1 = true;
        this.isStep2 = false;
        this.showAvanti = true;
        this.showIndietro = false;
        this.showSalva = false;
        this.updateSimulazione(true);
    }

    updateSimulazione(isIndietro){

        this.simulazioneFatturato = Boolean(this.currentNDG.AnnualRevenue) ? this.currentNDG.AnnualRevenue : 0;
        this.simulazioneAccordato = Boolean(this.currentNDG.PTF_Accordato__c) ? this.currentNDG.PTF_Accordato__c : 0;
        this.simulazionePartimonio = Boolean(this.currentNDG.PTF_Patrimonio__c) ? this.currentNDG.PTF_Patrimonio__c : 0;
        this.simulazioneUtilizzato = Boolean(this.currentNDG.PTF_Utilizzato__c) ? this.currentNDG.PTF_Utilizzato__c : 0;
        if(!isIndietro){

            this.selectedNDGRows.forEach(item => {
    
                this.simulazioneFatturato = Boolean(item.AnnualRevenue) ? this.simulazioneFatturato + item.AnnualRevenue : this.simulazioneFatturato;
                this.simulazioneAccordato = Boolean(item.PTF_Accordato__c) ? this.simulazioneAccordato + item.PTF_Accordato__c : this.simulazioneAccordato;
                this.simulazionePartimonio = Boolean(item.PTF_Patrimonio__c) ? this.simulazionePartimonio + item.PTF_Patrimonio__c : this.simulazionePartimonio;
                this.simulazioneUtilizzato = Boolean(item.PTF_Utilizzato__c) ? this.simulazioneUtilizzato + item.PTF_Utilizzato__c : this.simulazioneUtilizzato;
            });
        }
    }

    closeNdgModal() {

        this.openAddNdgmodal = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
    }

    getSelectedRows(tableName){

        let table = this.template.querySelector("[data-item='" + tableName + "']");
        if(table){

            return this.template.querySelector("[data-item='" + tableName + "']").getSelectedRows();
        }else {

            return [];
        }
    }

    handleSave(){

        try{
            this.loaded = false;
            if(this.isStep1){

                this.selectedMWRows = this.getSelectedRows('mwTable');
                this.selectedMWRowIds = this.selectedMWRows.map(item => item.Id);
            }
            
            if(this.selectedMWRows.length == 0){

                throw 'Selezionare almeno una tra le opzioni disponibili.';
            }
            let selectedNdgList = [];
            let ndgWithIter = [];
            let ndgIterMap = {};
            let ndgWithoutIter = [];
            let subjectMap = {};
            let keyMap = {};
            selectedNdgList.push(this.currentNDG);
            let gruppoFInanziario;
            this.selectedNDGRows.forEach(ndg =>{

                if(ndg.RecordType.DeveloperName != 'GruppoFinanziario'){

                    selectedNdgList.push(ndg);
                }else{

                    gruppoFInanziario = ndg;
                }
            });
            // selectedNdgList = selectedNdgList.concat(this.selectedNDGRows);
            console.log('DK selectedNdgList: ' + JSON.stringify(selectedNdgList));
            let continueProcess = true;
            console.log('DK this.superUser: ' + this.superUser);
            console.log('DK this.hasConfirmed: ' + this.hasConfirmed);
            console.log('DK BloccaSpostamentiVersoFiliale Destinazione: ' + this.selectedMWRows[0].PTF_Filiale__r.PTF_BloccaSpostamentiVersoFiliale__c);
            console.log('DK BloccaSpostamentiInFiliale Partenza: ' + this.currentPF.PTF_Filiale__r.PTF_BloccaSpostamentiInFiliale__c);
            console.log('DK BloccaSpostamentiFiliale Partenza: ' + this.currentPF.PTF_Filiale__r.PTF_BloccaSpostamentiFiliale__c);
            console.log('DK BloccaSpostamentiFiliale Destinazione: ' + this.selectedMWRows[0].PTF_Filiale__r.PTF_BloccaSpostamentiFiliale__c);
            if(this.superUser && !this.hasConfirmed && (this.currentPF.PTF_Filiale__r.PTF_BloccaSpostamentiFiliale__c || this.selectedMWRows[0].PTF_Filiale__r.PTF_BloccaSpostamentiFiliale__c || (this.currentPF.PTF_Filiale__c != this.selectedMWRows[0].PTF_Filiale__c && this.selectedMWRows[0].PTF_Filiale__r.PTF_BloccaSpostamentiVersoFiliale__c) ||
                (this.currentPF.PTF_Filiale__c == this.selectedMWRows[0].PTF_Filiale__c && this.currentPF.PTF_Filiale__r.PTF_BloccaSpostamentiInFiliale__c && this.currentPF.PTF_ModelloDiServizio__c != 'Assente'))){
            
                this.openDialog = true;
                this.hasConfirmed = false;
                continueProcess = false;
                this.loaded = false;
            }
            console.log('DK continueProcess: ' + continueProcess);
            if(continueProcess){

                selectedNdgList.forEach(ndg => {
                    
                    if(this.superUser){
    
                        console.log('SONO QUA4');
                        ndgIterMap[ndg.Id] = {Name: 'SUPERUSER', sobjectType: 'ConfigurazioneSpostamenti__mdt'};
                        subjectMap[ndg.Id] = 'SUPERUSER';
                        keyMap[ndg.Id] = 'SUPERUSER';
                        ndgWithoutIter.push(ndg);
                        console.log('DK NO ITER');
                    }else{
                        
                        let configurationMap = {};
    
                        let mapKey = this.checkEligible(ndg, this.selectedMWRows[0]);
                        
                        if(this.mdsConfigurazioniMap[mapKey]){
                            
                            configurationMap = this.mdsConfigurazioniMap;
                        }else if(this.filialeConfigurazioniMap[mapKey]){
            
                            configurationMap = this.filialeConfigurazioniMap;
                        }else if(this.filialeMDSConfigurazioniMap[mapKey]){
            
                            configurationMap = this.filialeMDSConfigurazioniMap;
                        }else if(this.referentiConfigurazioniMap[mapKey]){
            
                            configurationMap = this.referentiConfigurazioniMap;
                        }
                        
                        console.log('DK mapKey: ' + mapKey);
                        console.log('DK configurationMap: ' + JSON.stringify(configurationMap));
            
                        if(configurationMap[mapKey]){
                            
                            console.log('DK IterApprovativo: ' + configurationMap[mapKey].Iter_Approvativo__c);
                                
                            console.log('SONO QUA2');
                            if(configurationMap[mapKey].Iter_Approvativo__c){
                                
                                console.log('SONO QUA3');
                                subjectMap[ndg.Id] = configurationMap[mapKey].MasterLabel;
                                keyMap[ndg.Id] = mapKey;
            
                                const noteValid = [...this.template.querySelectorAll("[data-item='note']")]
                                .reduce((validSoFar, inputCmp) => {
                                            inputCmp.reportValidity();
                                            return validSoFar && inputCmp.checkValidity();
                                }, true);
    
                                const controlloValid = [...this.template.querySelectorAll("[data-item='controllo']")]
                                .reduce((validSoFar, inputCmp) => {
                                            inputCmp.reportValidity();
                                            return validSoFar && inputCmp.checkValidity();
                                }, true);
            
                                /*if(!noteValid){
            
                                    throw 'Valorizzare il campo \'Motivazioni\' prima di continuare.';
                                }*/
    
                                if((!controlloValid && this.multiOption) || !noteValid){
            
                                    throw 'Valorizzare i campi richiesti prima di continuare.';
                                }
                                console.log('DK noteValid: ' + noteValid);
                                
                                console.log('DK finestra: ' + configurationMap[mapKey].Finestra_Temporale__c);
                                if(configurationMap[mapKey].Finestra_Temporale__c){
            
                                    let today = new Date();
                                    let startDate;
                                    let endDate;
                                    let isSet = false;
    
                                    if(Boolean(ndg.PTF_Filiale__r) && !isSet){
    
                                        if(Boolean(ndg.PTF_Filiale__r.PTF_DowngradeReqStartDate__c) && Boolean(ndg.PTF_Filiale__r.PTF_DowngradeReqEndDate__c)){
                                            console.log('DK startDate1: ', JSON.stringify(ndg.PTF_Filiale__r.PTF_DowngradeReqStartDate__c));
                                            console.log('DK endDate1: ', JSON.stringify(ndg.PTF_Filiale__r.PTF_DowngradeReqEndDate__c));
                                            startDate = new Date(ndg.PTF_Filiale__r.PTF_DowngradeReqStartDate__c);
                                            endDate = new Date(ndg.PTF_Filiale__r.PTF_DowngradeReqEndDate__c);
                                            isSet = true;
                                        }
                                    }
                                    
                                    if(Boolean(ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__r) && !isSet){
                                        
                                        if(Boolean(ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c) &&
                                        Boolean(ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c)){
    
                                            startDate = new Date(ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c);
                                            endDate = new Date(ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c);
                                            isSet = true;
                                        }
                                    }
                                    
                                    if(Boolean(ndg.PTF_Portafoglio__r.PTF_Banca__r) && !isSet){
                                        
                                        if(Boolean(ndg.PTF_Portafoglio__r.PTF_Banca__r.PTF_DowngradeReqStartDate__c) &&
                                        Boolean(ndg.PTF_Portafoglio__r.PTF_Banca__r.PTF_DowngradeReqEndDate__c)){
    
                                            startDate = new Date(ndg.PTF_Portafoglio__r.PTF_Banca__r.PTF_DowngradeReqStartDate__c);
                                            endDate = new Date(ndg.PTF_Portafoglio__r.PTF_Banca__r.PTF_DowngradeReqEndDate__c);
                                            isSet = true;
                                        }
                                    }
    
                                    console.log('DK startDate: ', startDate);
                                    console.log('DK endDate: ', endDate);
                                    
                                    if(!isSet){
        
                                        throw "Non sei in una finestra temporale valida per eseguire questo spostamento";
                                    }
        
                                    if(today < startDate||
                                        today > endDate){
            
                                        throw "Non sei in una finestra temporale valida per eseguire questo spostamento";
                                    }
                                }
        
                                ndgIterMap[ndg.Id] = configurationMap[mapKey];
                                ndgWithIter.push(ndg);
            
                            }else{
                                
                                console.log('SONO QUA4');
                                ndgIterMap[ndg.Id] = configurationMap[mapKey];
                                ndgWithoutIter.push(ndg);
                                console.log('DK NO ITER');
                            }
                        }else{
            
                            throw "Casistica non configurata, contattare l'amministratore di sistema!!";
                        }
                        
                    }
                });
                
                if(Boolean(gruppoFInanziario)){
                    
                    let ndgWithIterIds = ndgWithIter.map(item => item.Id);
                    if(ndgWithIterIds.includes(this.currentNDG.Id)){
                        
                        ndgWithIter.push(gruppoFInanziario);
                    }else{
    
                        ndgWithoutIter.push(gruppoFInanziario);
                    }
                }
                console.log('DK ndgWithIter: ' + JSON.stringify(ndgWithIter));
                console.log('DK ndgWithoutIter: ' + JSON.stringify(ndgWithoutIter));
    
    
                if(ndgWithIter.length > 0){
    
                    this.handleCreateQueues(ndgWithIter, ndgIterMap, this.selectedMWRows[0], subjectMap, keyMap, true);
                }
    
                if(ndgWithoutIter.length > 0){
    
                    if(this.superUser){
    
                        this.handleCreateQueues(ndgWithoutIter, ndgIterMap, this.selectedMWRows[0], subjectMap, keyMap, false);
                    }else{
    
                        this.handleMoveNdg(ndgWithoutIter).then(() => {
                            
                            this.loaded = true;
                        });
                    }
                }
            }
        } catch (error) {
            this.loaded = true;
            console.log('DK error: ' + error);
            const toastEvent = new ShowToastEvent({
                title: "Warning!",
                message: error,
                variant: "warning"
            });
            this.dispatchEvent(toastEvent);
        }
    }

    handleCreateQueues(ndgWithIter, ndgIterMap, selectedMw, subjectMap, keyMap, hasIter){
        
        return createQueues({
            accountList: ndgWithIter,
            ndgIterMap: ndgIterMap,
            portafoglioDiPartenza: this.currentPF,
            portafoglioDiDestinazione: selectedMw,
            hasIter: hasIter,
            process: this.controllo
        }).then(result => {

            console.log('DK createQueues.result: ' + JSON.stringify(result));
            let parsedResult = {};
            parsedResult = JSON.parse(JSON.parse(result));
            console.log('DK createQueues.parsedResult: ', parsedResult);
            console.log('DK createQueues.accountWorkOrderKeyMap: ', parsedResult['accountWorkOrderKeyMap']);
            Object.keys(ndgIterMap).map(function(key, index) {
                
                let newValue = ndgIterMap[key].Tipo_di_Spostamento__c; 
                ndgIterMap[key] = newValue;
            });
            console.log('DK ndgIterMap: ' + JSON.stringify(ndgIterMap));
            this.handleSendRequest(ndgWithIter, ndgIterMap, subjectMap, keyMap, parsedResult['accountWorkOrderKeyMap'], hasIter ? parsedResult['woStepMap'] : {}, hasIter).then(() => {
                        
                this.loaded = true;
            });
        }).catch(error =>{

            console.log('DK error: ' + JSON.stringify(error));
            console.log('DK error: ' + error);
            const toastEvent = new ShowToastEvent({
                title: "Error!",
                message: error.body.message,
                variant: "error"
            });
            this.dispatchEvent(toastEvent);
            this.loaded = true;
        });
    }

    handleWMRowSelection(event){
        
        let selectedRows = event.detail.selectedRows;
        
        try{

            if(!this.superUser){

                let mapKey = this.checkEligible(this.currentNDG, selectedRows[0]);
                console.log('RC mapkey: '+mapKey);
                if(mapKey != null){
                    
                    let parsedJSON;
                    if(this.mdsConfigurazioniMap[mapKey]){
                       
                        this.noteIsRequired = this.mdsConfigurazioniMap[mapKey].Iter_Approvativo__c;
                        console.log('RC case 1: '+this.noteIsRequired);
                        parsedJSON = JSON.parse(this.mdsConfigurazioniMap[mapKey].PTF_JSON_Approvatori__c);
                    }else if(this.filialeConfigurazioniMap[mapKey]){
                        this.noteIsRequired = this.filialeConfigurazioniMap[mapKey].Iter_Approvativo__c;
                        console.log('RC case 2: '+this.noteIsRequired);
                        parsedJSON = JSON.parse(this.filialeConfigurazioniMap[mapKey].PTF_JSON_Approvatori__c);
                    }else if(this.filialeMDSConfigurazioniMap[mapKey]){
                        this.noteIsRequired = this.filialeMDSConfigurazioniMap[mapKey].Iter_Approvativo__c;
                        console.log('RC case 3: '+this.noteIsRequired);
                        parsedJSON = JSON.parse(this.filialeMDSConfigurazioniMap[mapKey].PTF_JSON_Approvatori__c);
                    }else if(this.referentiConfigurazioniMap[mapKey]){
                        this.noteIsRequired = this.referentiConfigurazioniMap[mapKey].Iter_Approvativo__c;
                        console.log('RC case 4: '+this.noteIsRequired);

                        parsedJSON = JSON.parse(this.referentiConfigurazioniMap[mapKey].PTF_JSON_Approvatori__c);
                    }
                    
                    //START EVO - SPOSTAMENTO REFRENTI(MULTIOPTION)
                    if(parsedJSON){
                        console.log('parsedJSON.multiOption', parsedJSON.multiOption);
                        if(Boolean(parsedJSON.multiOption)){

                            this.multiOption = true;
                            this.controlloPicklist = parsedJSON.multiOption;
                            this.controlloPicklist.forEach(item =>{
                                
                                this.controlloPicklistMap[item.value] = item.label;
                            });
                            console.log('DK controlloPicklistMap', this.controlloPicklistMap);
                        }else{
                            this.controllo = '';
                            this.multiOption = false;
                            this.controlloPicklist = [];
                        }
                    }
                    //END EVO - SPOSTAMENTO REFRENTI(MULTIOPTION)
                }else{
                    
                    this.controllo = '';
                    this.noteIsRequired = false;
                    this.multiOption = false;
                    this.controlloPicklist = [];
                }
            }

            if(this.ruolo == 'primario'){
                
                selectedRows.forEach(element => {
                    
                    if(this.portafogliInEvidenzaEligibleIds.includes(element.Id)){
                        
                        this.lastMessage = "Spostando l’NDG, si sposteranno tutte le Cointestazioni per cui è primario disponibili nello stesso microportafoglio.";
                    }else{
                        
                        this.lastMessage = '';
                    }
                });
            }
        }catch(error){

            console.log('DK handleWMRowSelection.error: ' + error);
        }
    }

    handleMoveNdg(ndgWithoutIter){

        if(this.selectedMWRows[0].PTF_ModelloDiServizio__c != 'Consulenti Finanziari'){

            if(this.ruolo == 'primario'){
    
                this.primari.push(this.currentNDG.Id);
            }
        }

        return moveNdgsToWallet({portafoglio: this.selectedMWRowIds[0], filiale: this.selectedMWRows[0].PTF_Filiale__c, primari: this.primari, ndgList: ndgWithoutIter}).
        then(() => {
            const toastEvent = new ShowToastEvent({
                title: "Success!",
                message: "NDG spostati correttamente!!",
                variant: "success"
            });
            this.dispatchEvent(toastEvent);
            this.closeNdgModal();
        }).
        catch(error => {
            console.log('DK error: ' + JSON.stringify(error));
        });
    }

    handleSendRequest(ndgWithIter, ndgIterTypeMap, subjectMap, keyMap, accountWorkOrderKeyMap, woStepMap, hasIter){

        try{
            
            //sposta cointestazioni solo se, quando sono in portafogli diversi da quello del primario, fanno parte dello stesso portafoglio 
            if(this.selectedMWRows[0].PTF_ModelloDiServizio__c != 'Consulenti Finanziari'){
            
                if(this.ruolo == 'primario'){

                    this.primari.push(this.currentNDG.Id);
                }
            }
            return sendMovementRequest({
                portafoglioDestinazione: this.selectedMWRowIds[0],
                ndgList: ndgWithIter, 
                ndgIterTypeMap: ndgIterTypeMap, 
                subjectMap: subjectMap, 
                note: this.note, 
                configurationKeyMap: keyMap, 
                primari: this.primari, 
                accountKeyMap: 
                accountWorkOrderKeyMap, 
                woStepMap: woStepMap, 
                ruolo: this.ruolo, 
                gruppoFinanziarioId: this.gruppoFinanziarioId, 
                recordId: this.currentNDG.Id, 
                referente: this.selectedMWRows[0].Referente, 
                hasIter: hasIter,
                process: this.controllo,
                motivazione: Boolean(this.controlloPicklistMap[this.controllo]) ? this.controlloPicklistMap[this.controllo] : '',
                lineItemIter: hasIter
            }).
            then(result => {

                if(this.superUser){

                    console.log('DK sendMovementRequest.result: ' + JSON.stringify(result));
                    let parsedResult = {};
                    parsedResult = JSON.parse(JSON.parse(result));
                    return approveWorkOrders({workOrderIdSet: parsedResult['workOrderIdSet']})
                    .then(() => {

                        const toastEvent = new ShowToastEvent({
                            title: "Success!",
                            message: "Richiesta di spostamento inoltrata correttamente!!",
                            variant: "success"
                        });
                        this.dispatchEvent(toastEvent);
                        this.closeNdgModal();
                    })
                    .catch(error => {

                        console.log('DK error: ' + JSON.stringify(error));
                        const toastEvent = new ShowToastEvent({
                            title: "Error!",
                            message: error.body.message,
                            variant: "error"
                        });
                        this.dispatchEvent(toastEvent);
                    });
                }else{

                    const toastEvent = new ShowToastEvent({
                        title: "Success!",
                        message: "Richiesta di spostamento inoltrata correttamente!!",
                        variant: "success"
                    });
                    this.dispatchEvent(toastEvent);
                    this.closeNdgModal();
                }
            }).
            catch(error => {

                console.log('DK error: ' + JSON.stringify(error));
                const toastEvent = new ShowToastEvent({
                    title: "Error!",
                    message: error.body.message,
                    variant: "error"
                });
                this.dispatchEvent(toastEvent);
            });
            
        }catch(error){

            console.log('DK handleSendRequest.error: ' + error);
        }
    }

    checkEligible(ndg, portafoglio){
        
        let startMDS = ndg.PTF_Portafoglio__r.PTF_ModelloDiServizio__c;
        let startFiliale = ndg.PTF_Filiale__c;
        let startFilialeBranch = ndg.PTF_Filiale__r.PTF_BranchTypeDesc__c;
        let endMDS = portafoglio.PTF_ModelloDiServizio__c;
        let endFiliale = portafoglio.PTF_Filiale__c;
        let endFilialeBranch = portafoglio.PTF_Filiale__r.PTF_BranchTypeDesc__c;
        // 
        let configurationKey1 = '';
        // 
        let configurationKey2 = '';
        // 
        let configurationKey3 = '';
        // 
        let configurationKey4 = '';
        // 
        let configurationKey5 = '';
        //
        let configurationKey6 = '';
        //
        let configurationKey7 = '';
        //
        let configurationKey8 = '';

        if(startMDS != endMDS){
            configurationKey2 = startMDS + '_' + endMDS;
        }
        
        let mmPartenza = Boolean(ndg.PTF_Portafoglio__r.PTF_Capofila__c) ? ndg.PTF_Portafoglio__r.PTF_Capofila__c : ndg.PTF_Portafoglio__r.PTF_Filiale__c;
        let mmDestinazione = Boolean(portafoglio.PTF_Capofila__c) ? portafoglio.PTF_Capofila__c : portafoglio.PTF_Filiale__c;
        console.log('DK this.currentPF.ReferenteId: ' + this.currentPF.ReferenteId);
        console.log('DK portafoglio.ReferenteId: ' + portafoglio.ReferenteId);
        let sameReferente = (this.currentPF.ReferenteId != '' && portafoglio.ReferenteId != '') && this.currentPF.ReferenteId == portafoglio.ReferenteId ? 'true' : 'false';
        let sameMicroMercato = mmPartenza === mmDestinazione ? 'true' : 'false';
        let sameArea = (Boolean(ndg.PTF_Portafoglio__r.PTF_Area__c) && Boolean(portafoglio.PTF_Area__c)) && (ndg.PTF_Portafoglio__r.PTF_Area__c === portafoglio.PTF_Area__c) ? 'true' : 'false';
        let sameDirReg;
        if(portafoglio.PTF_Banca__r.FinServ__BankNumber__c == '01015'){

            sameDirReg = (ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__c === portafoglio.PTF_DirezioneRegionale__c) ? 'true' : 'false';
        }else{

            sameDirReg = (Boolean(ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__c) && Boolean(portafoglio.PTF_DirezioneRegionale__c)) && (ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__c === portafoglio.PTF_DirezioneRegionale__c) ? 'true' : 'false';
        }
        if(startFiliale != endFiliale ||
            startFilialeBranch != endFilialeBranch){
            
            if(Boolean(configurationKey2)){

                configurationKey2 = configurationKey2 + '_';
            }else{

                configurationKey2 = '';
                configurationKey7 = startFilialeBranch + '_' + endFilialeBranch + '_' + startMDS + '_' + sameReferente + '_' + sameMicroMercato + '_' + sameArea + '_' + sameDirReg;
            }
            configurationKey4 = configurationKey2 == '' ?
                                configurationKey2 + startFilialeBranch + '_' + 'TUTTE' + '_' + startMDS + '_' + sameMicroMercato + '_' + sameArea + '_' + sameDirReg :
                                configurationKey2 + startFilialeBranch + '_' + endFilialeBranch + '_' + sameMicroMercato + '_' + sameArea + '_' + sameDirReg;

            configurationKey2 = configurationKey2 == '' ?
                                configurationKey2 + startFilialeBranch + '_' + endFilialeBranch + '_' + startMDS + '_' +  sameMicroMercato + '_' + sameArea + '_' + sameDirReg : 
                                configurationKey2 + startFilialeBranch + '_' + endFilialeBranch + '_' + sameMicroMercato + '_' + sameArea + '_' + sameDirReg;
                                
        }else{

            if(Boolean(configurationKey2)){

                configurationKey6 = configurationKey2 + '_' + startFilialeBranch + '_' + endFilialeBranch;
            }
        }

        if(!Boolean(configurationKey2)){

            configurationKey2 = startMDS + '_' + endMDS;
        }

        configurationKey1 = configurationKey2;
        configurationKey3 = configurationKey2;
        configurationKey5 = configurationKey4;
            
        configurationKey1 = configurationKey1 + '_' + startFilialeBranch;
        configurationKey8 = configurationKey1;

        if(Boolean(portafoglio.PTF_Banca__r)){

            configurationKey4 = configurationKey4 + '_' + portafoglio.PTF_Banca__r.FinServ__BankNumber__c;
            configurationKey1 = configurationKey1 + '_' + portafoglio.PTF_Banca__r.FinServ__BankNumber__c;
            configurationKey2 = configurationKey2 + '_' + portafoglio.PTF_Banca__r.FinServ__BankNumber__c;
            configurationKey6 = configurationKey6 + '_' + portafoglio.PTF_Banca__r.FinServ__BankNumber__c;
            configurationKey7 = configurationKey7 + '_' + portafoglio.PTF_Banca__r.FinServ__BankNumber__c;
        }
        configurationKey3 = configurationKey3 + '_TUTTE';
        configurationKey5 = configurationKey5 + '_TUTTE';
        configurationKey8 = configurationKey8 + '_TUTTE';
        let configurationMap;

        if(this.mdsConfigurazioniMap[configurationKey2] || this.mdsConfigurazioniMap[configurationKey3] || this.mdsConfigurazioniMap[configurationKey1] || this.mdsConfigurazioniMap[configurationKey6]){
            
            configurationMap = this.mdsConfigurazioniMap;
        }else if(this.filialeConfigurazioniMap[configurationKey2] || this.filialeConfigurazioniMap[configurationKey3] || this.filialeConfigurazioniMap[configurationKey1] || this.filialeConfigurazioniMap[configurationKey4] || this.filialeConfigurazioniMap[configurationKey7] || this.filialeConfigurazioniMap[configurationKey5]){

            configurationMap = this.filialeConfigurazioniMap;
        }else if(this.filialeMDSConfigurazioniMap[configurationKey2] || this.filialeMDSConfigurazioniMap[configurationKey3] || this.filialeMDSConfigurazioniMap[configurationKey1]){

            configurationMap = this.filialeMDSConfigurazioniMap;
        }else if(this.referentiConfigurazioniMap[configurationKey2] || this.referentiConfigurazioniMap[configurationKey3] || this.referentiConfigurazioniMap[configurationKey1] || this.referentiConfigurazioniMap[configurationKey8]){

            configurationMap = this.referentiConfigurazioniMap;
        }

        if(configurationMap){

            let mapKey = "";
            if(configurationMap[configurationKey1]){

                mapKey = configurationKey1;
            }else if(configurationMap[configurationKey8]){
                
                mapKey = configurationKey8;
            }else if(configurationMap[configurationKey6]){
                
                mapKey = configurationKey6;
            }else if(configurationMap[configurationKey7]){
                
                mapKey = configurationKey7;
            }else if(configurationMap[configurationKey2]){
                
                mapKey = configurationKey2;
            }else if(configurationMap[configurationKey4]){

                mapKey = configurationKey4;
            }else if(configurationMap[configurationKey3]){
                
                mapKey = configurationKey3;
            }else {

                mapKey = configurationKey5;
            }
            console.log('DK mapKey: ' + mapKey);

            return mapKey;
        }else{
            
            return null;
        }
    }

    getAllData(){
        
        try{
            
            console.log('mdsEligible: ' + JSON.stringify(this.mdsEligible));
            console.log('branchEligible: ' + JSON.stringify(this.branchEligible));
            let listaReferenti = [];
            listaReferenti.push(this.currentPF.Backup_Assignments__r);              
            console.log('listaReferenti ' + listaReferenti);
            console.log('listaReferenti1 ' + this.currentPF.Backup_Assignments__r);
            console.log('listaReferenti ' + this.currentPF);
            console.log('pz this.currentPF: ' +  JSON.stringify(this.currentPF.Backup_Assignments__r));
            return loadMwList({
                pagesize: this.mwLimit,
                mdsEligible: this.mdsEligible,
                branchEligible: this.branchEligible,
                currentPF: this.currentPF,
                ndg: this.currentNDG,
                ruoloVar: this.ruolo,
                allInSameVar: this.allInSame,
                mdsCOVar: this.mdsCo,
                filialePrimarioVar: this.filialePrimario,
                microportafogliCointestazioniFilialiVar: this.microportafogliCointestazioniFiliali,
                referenti : JSON.stringify(this.currentPF.Backup_Assignments__r)
            })
            .then(result => {

                console.log('DK result.timeQuery: ' + result.timeQuery);
                console.log('DK result.timeCheckEligible: ' + result.timeCheckEligible);
                console.log('DK result.errorMessage: ' + result.errorMessage);
                console.log('PZ result: ' + result);
                console.log('PZ resultreferenti: ' + result.referenti);
                this.mwList = result["mwList"];
                this.mwList.forEach(element => {

                    this.extendMW(element);                
                });
                this.filteredMwList = this.mwList;
                if(this.filteredMwList.length == 0 &&
                    this.portafogliInEvidenzaEligible.length == 0 && 
                    (this.ruolo == 'primario' ||
                    this.ruolo == 'cointestazione' || this.ruolo == 'cointestatario')){
                   //PZ CR 70767    \
                   console.log('pz 1299');
                   this.message = 'PRESENTE ANOMALIA TRA PRIMARIO E CO. EFFETTUARE UN CONTROLLO NEI COLLEGAMENTI ANAGRAFICI PER VEDERE EVENTUALI INCOGRUENZE DA SANARE PRIMA DI ESEGUIRE LO SPOSTAMENTO DESIDERATO.';
                   this.lastMessage = '';
                }
                this.setPages(this.filteredMwList);
                console.log('DK mwList: ' + JSON.stringify(this.mwList));
            })
            .catch(error => { 
                console.log('DK getAllData.loadMWList.error: ' + error);
                console.log('DK getAllData.loadMWList.error: ' + JSON.stringify(error));
            })
        }catch(error){

            console.log('DK getAllData.error: ' + JSON.stringify(error));
            console.log('DK getAllData.error: ' + error);
        }
    }

    extendMW(element){
        
        if(this.portafogliInEvidenzaEligibleIds.includes(element.Id)){
                
            element.typeCSSClass = 'color-green';
        }

        if(!element.PTF_Pool__c){

            if(element.Backup_Assignments__r){
    
                let nomiReferenti = [];
                // let referenteId = '';
                element.Backup_Assignments__r.forEach(assignment => {
    
                    if(assignment.PTF_Gestore__r){
    
                        nomiReferenti.push(assignment.PTF_Gestore__r.Name);
                        // referenteId = assignment.PTF_Gestore__c;
                    }
                });
    
                if(nomiReferenti.length > 0){
                    
                    element.Referente = nomiReferenti.join(',');
                    element.ReferenteId = element.Backup_Assignments__r[0].PTF_Gestore__c;
                }else{
    
                    element.Referente = 'Non Assegnato';
                    element.ReferenteId = '';
                }
            }else{
    
                element.Referente = 'Non Assegnato';
                element.ReferenteId = '';
            }
        }else{

            element.Referente = 'PTF in Pool';
            element.ReferenteId = '';
        }
        element.Filiale = element.PTF_Filiale__r.Name;
    }

    handleMWReset(){

        this.searchedBancaMw = '';
        this.searchedDrMw = '';
        this.searchedAreaMw = '';
        this.searchedFilialeMw = '';
        this.searchedMDSMw = '';
        this.searchedNomeMw = '';
        this.searchedReferenteMw = '';
        this.filteredMwList = this.mwList;
        this.setPages(this.filteredMwList);
    }
    handleMWSearch(){

        this.filteredMwList = [];
        this.page = 1;
        try {
            
            for(var i in this.mwList){
                        
                if(Boolean(this.searchedBancaMw)){
                    
                    if(!Boolean(this.mwList[i].PTF_Banca__r)){

                        continue;
                    }
                    if(!this.mwList[i].PTF_Banca__r.Name.toLowerCase().includes(this.searchedBancaMw.toLowerCase())){
    
                        continue;
                    }
                }
                if(Boolean(this.searchedDrMw)){
                    
                    if(!Boolean(this.mwList[i].PTF_DirezioneRegionale__r)){

                        continue;
                    }
                    if(!this.mwList[i].PTF_DirezioneRegionale__r.Name.toLowerCase().includes(this.searchedDrMw.toLowerCase())){
    
                        continue;
                    }
                }
                if(Boolean(this.searchedAreaMw)){
                    
                    if(!Boolean(this.mwList[i].PTF_Area__r)){

                        continue;
                    }
                    if(!this.mwList[i].PTF_Area__r.Name.toLowerCase().includes(this.searchedAreaMw.toLowerCase())){
    
                        continue;
                    }
                }
                if(Boolean(this.searchedFilialeMw)){
                    if(!Boolean(this.mwList[i].PTF_Filiale__r)){

                        continue;
                    }
                    if(!this.mwList[i].PTF_Filiale__r.Name.toLowerCase().includes(this.searchedFilialeMw.toLowerCase())){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedNomeMw)){
                    if(!this.mwList[i].Name.toLowerCase().includes(this.searchedNomeMw.toLowerCase())){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedReferenteMw)){
                    
                    if(!Boolean(this.mwList[i].Referente)){

                        continue
                    }
                    if(!this.mwList[i].Referente.toLowerCase().includes(this.searchedReferenteMw.toLowerCase())){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedMDSMw)){
                    
                    if(this.mwList[i].PTF_ModelloDiServizio__c.toLowerCase() != this.searchedMDSMw.toLowerCase()){
    
                        continue;
                    }
                }
    
                this.filteredMwList.push(this.mwList[i]);
            }
    
            console.log('DK filteredMwList: ' + JSON.stringify(this.filteredMwList));
            console.log('DK this.page: ' + this.page);
            this.setPages(this.filteredMwList);
        } catch (error) {
            
            console.log('DK error: ' + error);
        }
    }

    loadNDGRecords(isSearch, isChange){
        
        try{
            if(isChange){

                this.selectedMWRows = this.getSelectedRows('mwTable');
                this.selectedMWRowIds = this.selectedMWRows.map(item => item.Id);
            }

            this.selectedNDGRows = this.getSelectedRows('ndgTable');
            this.selectedNDGRowIds = this.selectedNDGRows.map(item => item.Id);
                        
            console.log('DK ndgOffset: ' + this.ndgOffset);
            console.log('DK selectedMwRows: ' + JSON.stringify(this.selectedMWRows));
            if(this.selectedMWRows.length > 0){

                return loadNdgList({
                    gruppo: this.gruppoFinanziarioId,
                    recordId: this.recordId,
                    naturaGiuridica: this.currentNDG.PTF_NaturaGiuridica__c,
                    portafoglio: this.selectedMWRows[0],
                    currentPF: this.currentPF,
                    pagesize: this.ndgLimit
                })
                .then(result => {
                    
                    console.log('DK loadNdgList.result: ' + JSON.stringify(result));
                    this.ndgListCount = result["ndgListCount"];
                    let ndgIdList = [];
                    if(!isChange){

                        ndgIdList = this.ndgList.map(item => item.Id);
                    }
                    let newValueList = [];
                    result["ndgList"].forEach(element => {

                        let eligible = false;
                        let mapKey = null;
                        if(element.RecordType.DeveloperName != 'GruppoFinanziario'){

                            if(this.superUser){
    
                                eligible = true;
                            }else{
    
                                mapKey = this.checkEligible(element, this.selectedMWRows[0]);
                            }
                        }else{
                           
                            eligible = true;
                        }
                        if(Boolean(mapKey) || eligible){

                            element.PTF_Url = '/' + element.Id;
                            if(element.Id == this.gruppoFinanziarioId){
                                
                                if(!this.selectedNDGRowIds.includes(element.Id)){
    
                                    this.selectedNDGRows.push(element);
                                    this.selectedNDGRowIds.push(element.Id);
                                }
                            }
                            let index;
    
                            if(isSearch){
    
                                index = this.selectedNDGRowIds.indexOf(element.Id);
                            }else{
    
                                index = ndgIdList.indexOf(element.Id);
                            }
                            if(index <= -1){
        
                                newValueList.push(element);
                            }
                        }
                    });

                    if(isSearch){

                        if(this.selectedNDGRows){

                            console.log('CASE 1');
                            this.ndgList = this.selectedNDGRows.concat(newValueList);
                        }else{

                            console.log('CASE 2');
                            this.ndgList = newValueList;
                        }
                    }else{

                        if(isChange){

                            console.log('CASE 3');
                            this.ndgList = newValueList;
                        }else{

                            console.log('CASE 4');
                            this.ndgList = this.ndgList.concat(newValueList);
                        }
                    }

                    this.selectedNDGRowIds = this.selectedNDGRows.map(element => element.Id);
                    console.log('DK ndgList: ' + JSON.stringify(this.ndgList));
                    console.log('DK selectedNDGRowIds: ' + JSON.stringify(this.selectedNDGRowIds));
                })
                .catch(error => { 
                    console.log('DK loadNDGRecords.loadNdgList.error: ' + error);
                })
            }else{
                
                const toastEvent = new ShowToastEvent({
                    title: "Warning!",
                    message: "Selezionare uno tra le opzioni disponibili",
                    variant: "warning"
                });
                this.dispatchEvent(toastEvent);
                console.log('handleAssignNDGs End');
                return null;
            }
        }catch(error){

            console.log('DK loadNDGRecords.error: ' + error);
        }
    }

    handleNDGRowSelection(event){
        
        try {
            
            let selectedRows = event.detail.selectedRows;
            console.log('DK onRow Start selectedRows: ' + JSON.stringify(selectedRows));
            console.log('DK onRow this.selectedNDGRows: ' + JSON.stringify(this.selectedNDGRows));
            let selectedRowsId = selectedRows.map(item => item.Id);
    
            this.selectedNDGRows.forEach(element => {
    
                if(!selectedRowsId.includes(element.Id)){
                    
                    if(!element.PTF_Gruppo__c){

                        selectedRows.push(element);
                    }
                }
            });
            
            console.log('DK onRow END selectedRows: ' + JSON.stringify(selectedRows));
            this.selectedNDGRows = selectedRows;
            this.selectedNDGRowIds = selectedRows.map(element => element.Id);
            this.updateSimulazione(false);
            console.log('DK this.selectedNDGRowIds: ' + JSON.stringify(this.selectedNDGRowIds));
        } catch (error) {
            
            console.log('DK onRow error: ' + error);
        }
    }

    handleNDGReset(){

        this.searchedNomeNDG = '';
        this.searchedNdgNDG = '';
        this.handleNDGSearch();
    }

    handleNDGSearch(){

        this.ndgOffset = 0;
        this.loadNDGRecords(true, false);
    }

    handleFilter(event){

        console.log('DK handleFilter Started');
        if(event.target.name == 'searchedBancaMw'){
            
            this.searchedBancaMw = event.target.value;
        }else if(event.target.name == 'searchedDrMw'){
            
            this.searchedDrMw = event.target.value;
        }else if(event.target.name == 'searchedAreaMw'){
            
            this.searchedAreaMw = event.target.value;
        }else if(event.target.name == 'searchedFilialeMw'){
            
            this.searchedFilialeMw = event.target.value;
        }else if(event.target.name == 'searchedMDSMw'){
            
            this.searchedMDSMw = event.target.value;
        }else if(event.target.name == 'searchedNomeNDG'){
            
            this.searchedNomeNDG = event.target.value;
        }else if(event.target.name == 'searchedNdgNDG'){
            
            this.searchedNdgNDG = event.target.value;
        }else if(event.target.name == 'searchedNomeMw'){
            
            this.searchedNomeMw = event.target.value;
        }else if(event.target.name == 'searchedReferenteMw'){
            
            this.searchedReferenteMw = event.target.value;
        }else if(event.target.name == 'note'){

            this.note = event.target.value;
        }else if(event.target.name == 'controllo'){

            this.controllo = event.target.value;
        }
    }

    //Test Pagination
    @track page = 1;
    perpage = 25;
    @track pages = [];
    set_size = 25;
    

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
        let mwToDisplay = this.filteredMwList.slice(startIndex,endIndex);
        let mwToDisplayIdList = mwToDisplay.map(item => item.Id);
        this.portafogliInEvidenzaEligible.forEach(portafoglio => {

            console.log('isEligible');
            if(!mwToDisplayIdList.includes(portafoglio.Id)){
                
                console.log('isFirst');
                mwToDisplay.unshift(portafoglio);
            }
        });

        /*mwToDisplay.forEach(element => {
            
            // if(Boolean(element.Filiale)){

                if(this.portafogliInEvidenzaEligibleIds.includes(element.Id)){
                
                    element.typeCSSClass = 'color-green';
                }

                if(element.Backup_Assignments__r){

                    let nomiReferenti = [];
                    let referenteId = '';
                    element.Backup_Assignments__r.forEach(assignment => {

                        if(assignment.PTF_Gestore__r){

                            nomiReferenti.push(assignment.PTF_Gestore__r.Name);
                            referenteId = assignment.PTF_Gestore__c;
                        }
                    });

                    if(nomiReferenti.length > 0){
                        
                        element.Referente = nomiReferenti.join(',');
                        element.ReferenteId = element.Backup_Assignments__r[0].PTF_Gestore__c;
                    }else{

                        element.Referente = '';
                        element.ReferenteId = '';
                    }
                }else{

                    element.Referente = '';
                    element.ReferenteId = '';
                }
                element.Filiale = element.PTF_Filiale__r.Name;
            // }
        });*/

        return mwToDisplay;
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
        return this.page === this.pages.length || this.filteredMwList.length === 0
    }

    get currentPageData(){
        return this.pageData();
    }

    // START DIALOG
    @track openDialog = false;
    @track messaggioDialog = 'Per gli ndg selezionati sono presenti blocchi di spostamento a livello di filiale. \n';
    @track hasConfirmed = false;
    //handles button clicks
    handleClickDialog(event){
        if(event.currentTarget.name == 'cancel'){
            this.openDialog = false;
            this.hasConfirmed = false;
            this.loaded = true;
        }else{
            this.hasConfirmed = true;
            this.openDialog = false;
            this.loaded = true;
            this.handleSave();
        }
    }
    // END DIALOG

    // compare( a, b ) {
    //     if ( a.CRM_LinkCode < b.CRM_LinkCode ){
    //       return -1;
    //     }
    //     if ( a.CRM_LinkCode > b.CRM_LinkCode ){
    //       return 1;
    //     }
    //     return 0;
    // }
}