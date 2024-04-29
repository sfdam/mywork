//AdF LWC di visualizzazione data table
import { LightningElement, api, wire, track } from 'lwc';
import searchAccountByCF from '@salesforce/apex/TXT_AccountHandler.searchAccountByCF';
import searchAccountByName from '@salesforce/apex/TXT_AccountHandler.searchAccountByName';
import searchAccountByCFPIVA from '@salesforce/apex/TXT_AccountHandler.searchAccountByCFPIVA';
import insertAccount from '@salesforce/apex/TXT_AccountHandler.insertAccount';
import searchAccountById from '@salesforce/apex/TXT_AccountHandler.searchAccountById';
import executeCall from '@salesforce/apex/TXT_CalloutHandler.executeCall';
import getProdottoPG from '@salesforce/apex/TXT_CalloutHandler.getProdottoPG';
import { NavigationMixin } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import DENOSOCIALE_FIELD from '@salesforce/schema/Account.denosociale__c';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import PARTITA_IVA_FIELD from '@salesforce/schema/Account.Partita_iva__c';
import BillingCountry__FIELD from '@salesforce/schema/Account.BillingCountry';
import BillingState__FIELD from '@salesforce/schema/Account.BillingState';
import BillingCity_FIELD from '@salesforce/schema/Account.BillingCity';
import BillingStreet_FIELD from '@salesforce/schema/Account.BillingStreet';
import CCIAA_REA_FIELD from '@salesforce/schema/Account.CCIAA_REA__c';
import CCIAA_CMK_FIELD from '@salesforce/schema/Account.CCIAA_CMK__c';
import Codice_Fiscale_FIELD from '@salesforce/schema/Account.Codice_fiscale__c';
import FORMA_GIURIDICA_FIELD from '@salesforce/schema/Account.Forma_giuridica__c';
import BillingPostalCode_FIELD from '@salesforce/schema/Account.BillingPostalCode';
import INN_Societa_FIELD from '@salesforce/schema/Account.INN_societa__c';
import REV_societa_FIELD from '@salesforce/schema/Account.REV_societa__c';

import UserId from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import Soc from '@salesforce/schema/User.Societa__c';
// Blocco PickList
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
// Fine

import TXT_PickList_Fatturato from '@salesforce/apex/TXT_ProcessiLeadAccountUtils.TXT_PickList_Fatturato';
import TXT_PickList_Dipendenti from '@salesforce/apex/TXT_ProcessiLeadAccountUtils.TXT_PickList_Dipendenti';

import txtCAccount_Load from '@salesforce/label/c.txtCAccount_Load';
import txtCAccount_cf_pf from '@salesforce/label/c.txtCAccount_cf_pf';
import txtCAccount_cfpiva_pg from '@salesforce/label/c.txtCAccount_cfpiva_pg';
import txtCAccount_recap_acc from '@salesforce/label/c.txtCAccount_recap_acc';
import txtCAccount_manuale from '@salesforce/label/c.txtCAccount_manuale';
import txtCProcessi_SpinnerMessage from '@salesforce/label/c.txtCProcessi_SpinnerMessage';
import txtCAccount_CosaCensire from '@salesforce/label/c.txtCAccount_CosaCensire';
import txtCAccount_PersonaFisica from '@salesforce/label/c.txtCAccount_PersonaFisica';
import txtCAccount_PersonaGiuridica from '@salesforce/label/c.txtCAccount_PersonaGiuridica';
import txtCAccount_Esci from '@salesforce/label/c.txtCAccount_Esci';
import txtCAccount_Avanti from '@salesforce/label/c.txtCAccount_Avanti';
import txtCAccount_CercaPersonaFisica from '@salesforce/label/c.txtCAccount_CercaPersonaFisica';
import txtCAccount_CodiceFiscale from '@salesforce/label/c.txtCAccount_CodiceFiscale';
import txtCAccount_PIVACF from '@salesforce/label/c.txtCAccount_PIVACF';
import txtCAccount_Estero from '@salesforce/label/c.txtCAccount_Estero';
import txtCAccount_Cerca from '@salesforce/label/c.txtCAccount_Cerca';
import txtCAccount_InnolvaSearch from '@salesforce/label/c.txtCAccount_InnolvaSearch';
import txtCAccount_Denominazione from '@salesforce/label/c.txtCAccount_Denominazione';
import txtCAccount_PartitaIVA from '@salesforce/label/c.txtCAccount_PartitaIVA';
import txtCAccount_FormaGiuridica from '@salesforce/label/c.txtCAccount_FormaGiuridica';
import txtCAccount_CittaLegale from '@salesforce/label/c.txtCAccount_CittaLegale';
import txtCAccount_Paese from '@salesforce/label/c.txtCAccount_Paese';
import txtCAccount_ProvinciaLegale from '@salesforce/label/c.txtCAccount_ProvinciaLegale';
import txtCAccount_IndirizzoLegale from '@salesforce/label/c.txtCAccount_IndirizzoLegale';
import txtCAccount_Nuovo from '@salesforce/label/c.txtCAccount_Nuovo';
import txtCAccount_Indietro from '@salesforce/label/c.txtCAccount_Indietro';
import txtCAccount_NoResultsFound from '@salesforce/label/c.txtCAccount_NoResultsFound';
import txtCAccount_RagioneSociale from '@salesforce/label/c.txtCAccount_RagioneSociale';
import txtCAccount_ServerNoResult from '@salesforce/label/c.txtCAccount_ServerNoResult';
import txtCAccount_Aggiungi from '@salesforce/label/c.txtCAccount_Aggiungi';
import txtCAccount_stato_attivita from '@salesforce/label/c.txtCAccount_stato_attivita';
import txtCAccount_Sto_ottenendo_le_informazioni_da_Innolva from '@salesforce/label/c.txtCAccount_Sto_ottenendo_le_informazioni_da_Innolva';
import txtCAccount_Sto_cercando_informazioni_su_CRM from '@salesforce/label/c.txtCAccount_Sto_cercando_informazioni_su_CRM';
import txtCAccount_servizio_non_garantito from '@salesforce/label/c.txtCAccount_servizio_non_garantito';
import txtCAccount_dati_incompleti from '@salesforce/label/c.txtCAccount_dati_incompleti';
import txtCAccount_Censimento_Effettuato from '@salesforce/label/c.txtCAccount_Censimento_Effettuato';
import txtCAccount_errore_durante_creazione from '@salesforce/label/c.txtCAccount_errore_durante_creazione';

export default class txtCensimentoAccount extends NavigationMixin(LightningElement) {

    // Labels
    label = {
        txtCProcessi_SpinnerMessage: txtCProcessi_SpinnerMessage,
        txtCAccount_CosaCensire: txtCAccount_CosaCensire,
        txtCAccount_PersonaFisica: txtCAccount_PersonaFisica,
        txtCAccount_PersonaGiuridica: txtCAccount_PersonaGiuridica,
        txtCAccount_Esci: txtCAccount_Esci,
        txtCAccount_Avanti: txtCAccount_Avanti,
        txtCAccount_CercaPersonaFisica: txtCAccount_CercaPersonaFisica,
        txtCAccount_CodiceFiscale: txtCAccount_CodiceFiscale,
        txtCAccount_PIVACF: txtCAccount_PIVACF,
        txtCAccount_Estero: txtCAccount_Estero,
        txtCAccount_Cerca: txtCAccount_Cerca,
        txtCAccount_InnolvaSearch: txtCAccount_InnolvaSearch,
        txtCAccount_Denominazione: txtCAccount_Denominazione,
        txtCAccount_PartitaIVA: txtCAccount_PartitaIVA,
        txtCAccount_FormaGiuridica: txtCAccount_FormaGiuridica,
        txtCAccount_CittaLegale: txtCAccount_CittaLegale,
        txtCAccount_Paese: txtCAccount_Paese,
        txtCAccount_ProvinciaLegale: txtCAccount_ProvinciaLegale,
        txtCAccount_IndirizzoLegale: txtCAccount_IndirizzoLegale,
        txtCAccount_Nuovo: txtCAccount_Nuovo,
        txtCAccount_Indietro: txtCAccount_Indietro,
        txtCAccount_NoResultsFound: txtCAccount_NoResultsFound,
        txtCAccount_RagioneSociale: txtCAccount_RagioneSociale,
        txtCAccount_ServerNoResult: txtCAccount_ServerNoResult,
        txtCAccount_Aggiungi: txtCAccount_Aggiungi,
        txtCAccount_stato_attivita: txtCAccount_stato_attivita,
        txtCAccount_Sto_ottenendo_le_informazioni_da_Innolva: txtCAccount_Sto_ottenendo_le_informazioni_da_Innolva,
        txtCAccount_Sto_cercando_informazioni_su_CRM: txtCAccount_Sto_cercando_informazioni_su_CRM,
        txtCAccount_servizio_non_garantito: txtCAccount_servizio_non_garantito,
        txtCAccount_dati_incompleti: txtCAccount_dati_incompleti,
        txtCAccount_Censimento_Effettuato: txtCAccount_Censimento_Effettuato,
        txtCAccount_errore_durante_creazione: txtCAccount_errore_durante_creazione
    }

    //Input Values
    @track titlemodal = txtCAccount_Load;
    @track estero;
    @track accountNameData = null;
    @track ragioneSocialeDenominazioneData = null;
    @track cCIAAData = null;
    @track cCIAAREAData = null;
    @track codiceFiscaleData = null;
    @track clienteEsteroData = false;
    @track partitaIVAData = null;
    @track naturaGiuridicaData = null;
    @track viaIndirizzoSedeLegaleData = null;
    @track cittaIndirizzoSedeLegaleData = null;
    @track provinciaIndirizzoSedeLegaleData = null;
    @track cAPIndirizzoSedeLegaleData = null;
    @track paeseIndirizzoSedeLegaleData = null;
    @track InserimentoManuale = false;
    @track PIManuale = false;
    @track CFManuale = false;

    @track dataBilancioData = null;
    @track acquistiTotaliData = null;
    @track dataCessazioneData = null;
    @track annorilevazioneAddettiData = null;
    @track dataInizioAttivitaData = null;
    @track annualRevenueData = null;
    @track livelloAttenzioneNegativitaData = null;
    @track capitaleSocialeData = null;
    @track creditiVsClientiData = null;
    @track risultatoOperativoLordoData = null;
    @track phoneData = null;
    @track emailData = null;
    @track totalePatrimonioNettoData = null;
    @track faxData = null;
    @track utilePerditaData = null;
    @track statoAttivitaData = null;
    @track fatturatoData = null;
    @track ratingData = null;
    @track dipendentiData = null;
    @track codiceAtecoData = null;
    @track descrizioneAtecoData = null;
    @track censimentomanualeData = false;
    @track gruppoIvaData = null;
    @track denominazioneGruppoIvaData = null;
    @track erroreMonitoraggioData = false;
    @track societasuctmdata = null;
    @track societainndata = null;
    @track societarevdata = null;
    //End

    @api tableSource = '';
    @track selectedRows = [];
    @track tableData = [];
    @track disableSelectedRows;
    @track censimentTypes = [{ label: this.label.txtCAccount_PersonaFisica, value: 'personaFisica' }, { label: this.label.txtCAccount_PersonaGiuridica, value: 'personaGiuridica' }];

    @track recordId;
    @track selectedType;
    @api objectApiName;

    fields = [NAME_FIELD, DENOSOCIALE_FIELD, CCIAA_CMK_FIELD, CCIAA_REA_FIELD, Codice_Fiscale_FIELD, PARTITA_IVA_FIELD, FORMA_GIURIDICA_FIELD, 
        BillingStreet_FIELD, BillingPostalCode_FIELD, BillingCity_FIELD, BillingState__FIELD, BillingCountry__FIELD, INN_Societa_FIELD, REV_societa_FIELD];
    @track searchInput;
    @track searchedREA;
    //@track searchedCF;
    //@track searchedName;
    @track isTypeChoice;
    @track isPersonaFisica;
    @track isSearch;
    @track isResult;
    @track isRecap;
    // @track tableData;
    @track selectedTab;
    selectedTab_priv = "1";
    @track spinner;
    accountData;

    @track innolvaData = null;
    @track isModalOpen = false;

    @track isInnolvaResult;
    @track hasResult;

    innolvaTable = [];


    // Blocco PickList
    @track poptions;
    
    _recordTypeId;
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: FORMA_GIURIDICA_FIELD })
    setPicklistOptions({error, data}) {
        if (data) {
            this.poptions = data.values;
        } else if (error) {
            console.log(error);
        }
    }
    // FINE
    Societa;
    @wire(getRecord, { recordId: UserId, fields: Soc}) 
    userDetails({data}) {
        if (data) {
            this.Societa = data.fields.Societa__c.value;
        } 
    }

    @track disabledinput = false;
    @track disablebutton = true;
    @track disableCercaButton = true;
    @track disableTypeButton = true;
    @track NaturaGiuridicaData = '';

    


    connectedCallback(){
        this.isInnolvaResult = false;
        this.recordId='';
        this.objectApiName='Account';
        this.disableCercaButton = true;
        this.disableTypeButton = true;
        this.isPersonaFisica = false;
        this.estero = false;
        this.siglaEstera = 'IT';
        this.isTypeChoice = true;
        this.isSearch=false;
        this.isResult=false;
        this.isRecap=false;
        this.spinner = false;

        this.columns = [
            { label: this.label.txtCAccount_Denominazione, fieldName: 'Name', type: 'text' },
            {
                label: 'CRM',
                fieldName: 'crm',
                type: 'boolean',
                sortable: false,
                cellAttributes: { alignment: 'left' },
            },
            { label: this.label.txtCAccount_PartitaIVA, fieldName: 'Partita_iva__c', type: 'text' },
            { label: this.label.txtCAccount_CodiceFiscale, fieldName: 'Codice_fiscale__c', type: 'text' },
            { label: this.label.txtCAccount_FormaGiuridica, fieldName: 'Forma_giuridica__c', type: 'text' },
            { label: this.label.txtCAccount_stato_attivita, fieldName: 'Stato_Attivita__c', type: 'text' },
            { label: this.label.txtCAccount_CittaLegale, fieldName: 'BillingCity', type: 'text' },
            { label: this.label.txtCAccount_ProvinciaLegale, fieldName: 'BillingState', type: 'text' },
            { label: this.label.txtCAccount_IndirizzoLegale, fieldName: 'BillingStreet', type: 'text' },
            
          ];
          // BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet
          //BillingStreet, BillingCity, BillingState, BillingPostalCode,

        
        this.disableSelectedRows=true;
        this.disablebutton=false;
        this.isModalOpen = true;
    }

    handleNameChange(event){
        console.log('Name '+event.target.value);
        if(event.target.value != ''){
            this.disablebutton = false;
            this.accountNameData = event.target.value;
        }else{
            this.disablebutton = true;
        }
    }
    
    handlefieldchange(event){
        console.log('INPUT '+event.target.name);
        this[event.target.name] = event.target.value;
        console.log('INPUT '+event.target.name+': '+ event.target.value);

        // SM - Aggiunto controllo per non rendere obbligatori i campi di codice fiscale e partita iva per censimento manuale estero
        // if(this.InserimentoManuale && this.clienteEsteroData){
        //     // if(this.isPersonaFisica){
        //     //     this.CFManuale = false;
        //     // }else{
        //         this.CFManuale = false;
        //         this.PIManuale = false;
        //     // }
        // } else if((this.InserimentoManuale && !this.clienteEsteroData) || !this.InserimentoManuale) {
        //     if(this.isPersonaFisica==true){
        //         this.CFManuale = true;
        //         this.PIManuale = false;
        //     }else{
        //         this.CFManuale = true;
        //         this.PIManuale = true;
        //     }
        // }
        // END - SM - Aggiunto controllo per non rendere obbligatori i campi di codice fiscale e partita iva per censimento manuale estero
        this.disablebutton=false;
    }

    handleClick(event){
        this.disableCercaButton = true;
        this.disableTypeButton = true;
        if(event.target.title==this.label.txtCAccount_Esci){
            this.navigateToAccountListView()
        }else{
            if(this.isTypeChoice==true){
                if(event.target.title==this.label.txtCAccount_Avanti){
                    this.isTypeChoice= false;
                    this.isSearch=true;
                    this.isResult=false;
                    this.isRecap=false;
                }else{
                    this.navigateToAccountListView()
                }
            }
            else if(this.isSearch==true){
                if(event.target.title==this.label.txtCAccount_Avanti){
                    this.spinner = true;
                    this.isSearch=false;
                    this.isResult=true;
                    this.isRecap=false;
                    this.isInnolvaResult = false; 
                    this.disablebutton = false;  
                    this.handleSearch();
                }else if(event.target.title==this.label.txtCAccount_Indietro){
                    this.isTypeChoice = true;
                    this.isSearch=false;
                    this.isResult=false;
                    this.isRecap=false;
                    this.titlemodal = txtCAccount_Load;
                    this.InserimentoManuale = false;
                    this.CFManuale = false;
                    this.PIManuale = false;
                }else{
                    this.navigateToAccountListView()
                }
            }else if(this.isResult==true){
                if(event.target.title==this.label.txtCAccount_Avanti){
                    if(this.selectedRows[0].Forma_giuridica__c != 'PERSONA FISICA' && this.isPersonaFisica){
                        this.showToastMessage("Hai selezionato una persona giuridica, tornare indietro ed effettuare la ricerca come Persona Giuridica", "warning");
                        return;
                    }

                    // this.titlemodal = txtCAccount_cfpiva_pg;
                    this.titlemodal = txtCAccount_recap_acc

                    /* 'Censimento Manuale Anagrafica già esistente';
                    this.InserimentoManuale = true;
                    this.censimentomanualeData = true;
                    if(this.isPersonaFisica==true){
                        this.CFManuale = true;
                    }else{
                        this.CFManuale = true;
                        this.PIManuale = true;
                    }
                    */
                    this.isInnolvaResult=true;
                    console.log('Censimento_Manuale__c='+this.selectedRows[0].Censimento_Manuale__c);
                    if(this.selectedRows[0].Censimento_Manuale__c==true){

                        if(this.selectedRows[0].crm)
                        {
                            this.titlemodal =  txtCAccount_recap_acc;
                        }
                        else
                        {
                            this.titlemodal =  txtCAccount_Load;
                        }

                        this.isSearch=false;
                        this.isResult=false;
                        this.isRecap=true;
                        this.disableSelectedRows=false;
                        


                        this.accountNameData = this.selectedRows[0].Name;
                        this.partitaIVAData = this.selectedRows[0].Partita_iva__c;
                        // this.codiceFiscaleData = this.selectedRows[0].Codice_fiscale__c;
                        this.codiceFiscaleData = this.selectedRows[0].Codice_fiscale__c;
                        this.ragioneSocialeDenominazioneData = this.selectedRows[0].denosociale__c;
                        this.cCIAAData = this.selectedRows[0].CCIAA_CMK__c;
                        this.cCIAAREAData = this.selectedRows[0].CCIAA_REA__c;
                        this.viaIndirizzoSedeLegaleData = this.selectedRows[0].BillingStreet;
                        this.cittaIndirizzoSedeLegaleData = this.selectedRows[0].BillingCity;
                        this.provinciaIndirizzoSedeLegaleData = this.selectedRows[0].BillingState;
                        this.cAPIndirizzoSedeLegaleData = this.selectedRows[0].BillingPostalCode;
                        this.paeseIndirizzoSedeLegaleData = this.selectedRows[0].BillingCountry;
                        this.dataBilancioData = this.selectedRows[0].Data_Bilancio__c;
                        this.acquistiTotaliData = this.selectedRows[0].Acquisti_totali__c;
                        this.dataCessazioneData = this.selectedRows[0].Data_di_cessazione__c;
                        this.annorilevazioneAddettiData = this.selectedRows[0].Anno_rilevazione_addetti__c;
                        this.dataInizioAttivitaData = this.selectedRows[0].Data_Inizio_Attivita__c;
                        this.annualRevenueData = this.selectedRows[0].AnnualRevenue;
                        this.livelloAttenzioneNegativitaData = this.selectedRows[0].Livello_attenzione_negativita__c;
                        this.capitaleSocialeData = this.selectedRows[0].Capitale_Sociale__c;
                        this.creditiVsClientiData = this.selectedRows[0].Crediti_vs_Clienti__c;
                        this.risultatoOperativoLordoData = this.selectedRows[0].Risultato_Operativo_Lordo__c;
                        // this.phoneData = this.selectedRows[0].Phone_Warrant__c;
                        this.phoneData = this.selectedRows[0].Phone;
                        this.emailData = this.selectedRows[0].Email_Aziendale_Innolva__c;
                        this.totalePatrimonioNettoData = this.selectedRows[0].Totale_Patrimonio_Netto_Tinexta__c;
                        this.faxData = this.selectedRows[0].Fax;
                        this.utilePerditaData = this.selectedRows[0].Utile_Perdita__c;
                        this.statoAttivitaData = this.selectedRows[0].Stato_Attivita__c;
                        // this.selectedRows[0].Fatturato__c = this.fatturatoData;
                        TXT_PickList_Fatturato({annualrevenue: this.annualRevenueData }).then(result => {  this.fatturatoData = result; })
                        // this.fatturatoData = this.selectedRows[0].Fatturato__c;
                        this.ratingData = this.selectedRows[0].Rating__c;
                        this.dipendentiData = this.selectedRows[0].Dipendenti__c;
                        //TXT_PickList_Dipendenti({strnumero: this.selectedRows[0].Dipendenti__c}).then(result => {  this.dipendentiData = result; })
                        this.codiceAtecoData = this.selectedRows[0].Codice_Ateco_Innolva__c;
                        this.descrizioneAtecoData = this.selectedRows[0].Descrizione_Ateco_Innolva__c;
                        this.gruppoIvaData = this.selectedRows[0].TXT_Gruppo_IVA__c;
                        this.denominazioneGruppoIvaData = this.selectedRows[0].TXT_Denominazione_Gruppo_IVA__c;
                        this.censimentomanualeData = true;
                        this.societasuctmdata = this.selectedRows[0].Societa_su_CTM__c;
                        this.societainndata = this.selectedRows[0].INN_societa__c;
                        this.societarevdata = this.selectedRows[0].REV_societa__c;
                        
                    }else{
                        
                        if(this.selectedRows[0].crm)
                        {
                            this.titlemodal =  txtCAccount_recap_acc;
                        }
                        else
                        {
                            this.titlemodal =  txtCAccount_Load;
                        }
                            

                        if(this.isPersonaFisica==false){
                            // this.titlemodal = txtCAccount_cfpiva_pg;
                            this.showToastMessage(this.label.txtCAccount_Sto_ottenendo_le_informazioni_da_Innolva, "neutral");
                            var tmpAcc;
                            this.innolvaTable.filter(i => {
                                if(!this.estero){
                                    if(i.Partita_iva__c == this.selectedRows[0].Partita_iva__c && i.Codice_fiscale__c == this.selectedRows[0].Codice_fiscale__c){
                                        tmpAcc = {...i};
                                        tmpAcc.Name = tmpAcc.Name.replaceAll(' #XML','');
                                    } else if(i.Partita_iva__c == i.Codice_fiscale__c && ((this.selectedRows[0].Partita_iva__c == i.Partita_iva__c && this.selectedRows[0].Codice_fiscale__c == undefined) || this.selectedRows[0].Codice_fiscale__c == i.Codice_fiscale__c && this.selectedRows[0].Partita_iva__c == undefined)){
                                        tmpAcc = {...i};
                                        tmpAcc.Name = tmpAcc.Name.replaceAll(' #XML','');
                                    }
                                }
                            })
                            
                            if (tmpAcc != undefined && !tmpAcc.crm) {
                                this.titlemodal = txtCAccount_Load;
                            } else if (tmpAcc == undefined && !this.selectedRows[0].crm) {
                                this.titlemodal = txtCAccount_Load;
                            }
                            this.callsGetProdottoPG(tmpAcc != undefined ? tmpAcc : this.selectedRows[0]);
                        }else{
                            // this.titlemodal = txtCAccount_cf_pf;
                            this.isSearch=false;
                            this.isResult=false;
                            this.isRecap=true;
                            this.disableSelectedRows=true;
                        }
                    }
                    this.isSearch=false;
                    this.isResult=false;
                    this.isRecap=true;
                    this.disableSelectedRows=true;
                }else if(event.target.title==this.label.txtCAccount_Indietro){
                    this.estero = false;
                    this.isSearch=true;
                    this.isResult=false;
                    this.isRecap=false;
                    this.titlemodal = txtCAccount_Load;
                }else if(event.target.title=='notFound'){
                    this.titlemodal = txtCAccount_manuale;
                    this.censimentomanualeData = true;
                    this.InserimentoManuale = true;
                    if(this.isPersonaFisica==true){
                        this.CFManuale = true;
                    }else{
                        this.CFManuale = true;
                        this.PIManuale = true;
                    }
                    this.recordId='';
                    this.isSearch=false;
                    this.isResult=false;
                    this.isRecap=true;
                    this.isInnolvaResult = false;
                    this.disablebutton = true;
                    this.clearFields();
                    if(this.isPersonaFisica==true){
                        this.naturaGiuridicaData = 'PERSONA FISICA';
                    }
                }else{
                    this.navigateToAccountListView()
                }
            }else if(this.isRecap==true){
                console.log('Recap');
                this.titlemodal = txtCAccount_recap_acc;
                
                if(event.target.title==this.label.txtCAccount_Indietro){
                    console.log('Indietro...');
                    this.estero = false;
                    this.isSearch=true;
                    this.isResult=false;
                    this.isRecap=false;
                    this.isInnolvaResult = false;
                    this.clearFields();
                    this.titlemodal = txtCAccount_Load;
                    this.InserimentoManuale = false;
                    this.CFManuale = false;
                    this.PIManuale = false;
                }else{
                    this.navigateToAccountListView()
                }
            }else{
                this.navigateToAccountListView()
            }
        }
        console.log('Click event: ' + event.target.title);

    }

    handleApexSearchAccount(iscf){
        this.searchInput = this.searchInput.trim();
        searchAccountByCFPIVA({PIVA: this.searchInput}).then(result => {
            console.log(JSON.stringify(result));

            //ciclo result, recupero id account, chiamo metodo per query ctm, restuisce mappa (idaccount, false) (controllo innolva in ctm)

            console.log('RISULTATI CRM: ' + JSON.stringify(result));
            if(result != '' && result!=null){
                var tmpcontainer = [];

                for (var i = 0; i < result.length; i++) {
                    var tmpitem = {...result[i]};
                    if(tmpitem.Codice_fiscale__c == this.searchInput && iscf == false && (tmpitem.Partita_iva__c == null || tmpitem.Partita_iva__c.length < 4)){
                        if(tmpitem.Censimento_Manuale__c==true){
                            
                            tmpitem.Censimento_Manuale__c = false;
                            tmpitem.Forma_giuridica__c = 'PERSONA GIURIDICA';
                        }
                    }else if(tmpitem.Censimento_Manuale__c==true){
                        //tmpitem.crm = true;
                    }else{
                        //tmpitem.crm = false;
                    }
                    //console.log('societa ', this.Societa);
                    //console.log('Societa_su_CTM__c', tmpitem.INN_societa__c);
                    /*if(this.Societa === 'Innolva')
                    {
                        if(tmpitem.INN_societa__c === 'Innolva' ) tmpitem.crm = true;
                        if(tmpitem.INN_societa__c === '' ) tmpitem.crm = false;
                    }
                    else if(this.Societa != 'Innolva')
                    {
                        if(tmpitem.INN_societa__c === 'Innolva') tmpitem.crm = true;
                        if(tmpitem.INN_societa__c === '') tmpitem.crm = false;
                    }*/

                    tmpcontainer.push(tmpitem);      
                }
                this.hasResult = true;
                this.tableData = tmpcontainer;

                if(iscf==true){
                    this.spinner = false;
                }

                if(iscf==false){
                    
                    this.showToastMessage(this.label.txtCAccount_InnolvaSearch, "neutral");
                    executeCall({searchType: 2, searchedParameter: this.searchInput, siglaEstera : this.siglaEstera}).then(results => {
                        console.log('RISULTATI INNOLVA: '+JSON.stringify(results));
                        console.log('RISULTATI tabella: '+JSON.stringify(this.tableData));
                        var tmpcontainerr = [];
                        this.tableData.forEach(element => { tmpcontainerr.push(element); })
                        
                        var tmpexist = false;
                        var tmpsameexist = false;
                        if(results != '' && results!=null){
                            this.innolvaTable = results;
                            for (var i = 0; i < results.length; i++) {
                                var tmpitem = {...results[i]};

                                //SM - FIX
                                if(tmpitem.Name.indexOf('#XML', 1) !=-1){
                                    //tmpitem.crm = true;
                                    tmpitem.Censimento_Manuale__c = false;
                                    tmpitem.Name = tmpitem.Name.replaceAll(' #XML', '');
                                }

                                tmpexist = false;
                                tmpsameexist = false;
                                tmpcontainerr.forEach(element => {

                                    //SM - FIX - Estero senza PIVA e CF
                                    // console.log('@@@ element.Codice_fiscale__c ' , element.Codice_fiscale__c);
                                    // console.log('@@@ tmpitem.Codice_fiscale__c ' , tmpitem.Codice_fiscale__c);
                                    // console.log('@@@ element.Partita_iva__c ' , element.Partita_iva__c);
                                    // console.log('@@@ tmpitem.Partita_iva__c ' , tmpitem.Partita_iva__c);
                                    console.log('@@@ element.Name ' , element.Name);
                                    console.log('@@@ tmpitem.Name ' , tmpitem.Name);
                                    //console.log('@@@ element.BillingCountry ' , element.CCIAA_REA__c);
                                    //console.log('@@@ element.BillingCountry ' , tmpitem.CCIAA_REA__c);
                                    //console.log('@@@ tmpitem.BillingCountry ' , element.CCIAA_CMK__c);
                                    //console.log('@@@ tmpitem.BillingCountry ' , tmpitem.CCIAA_CMK__c);
                                    console.log('societa ', this.Societa);
                                    console.log('element.INN_societa__c', element.INN_societa__c);
                                    console.log('element.REV_societa__c', element.REV_societa__c);
                                    console.log('element.Societa_su_CTM__c' , element.Societa_su_CTM__c);
                                    if(this.Societa === 'Innolva')
                                    {
                                        if(element.INN_societa__c === 'Innolva' ) element.crm = true;
                                        if(element.INN_societa__c === undefined ) element.crm = false;
                                    }
                                    else if(this.Societa === 'ReValuta')
                                    {
                                        if(element.REV_societa__c === 'ReValuta' ) element.crm = true;
                                        if(element.REV_societa__c === undefined ) element.crm = false;
                                    }
                                    else if(this.Societa != 'Innolva' && this.Societa != 'ReValuta')
                                    {
                                        if(element.Societa_su_CTM__c !== undefined) element.crm = true;
                                        if(element.Societa_su_CTM__c === undefined && (element.INN_societa__c !== undefined || element.REV_societa__c !== undefined)) element.crm = false;
                                    }

                                    if( (element.Codice_fiscale__c==tmpitem.Codice_fiscale__c && element.Codice_fiscale__c != undefined && element.Partita_iva__c == undefined && tmpitem.Partita_iva__c == undefined) || 
                                        (element.Partita_iva__c == tmpitem.Partita_iva__c && element.Partita_iva__c != undefined && element.Codice_fiscale__c == undefined && tmpitem.Codice_fiscale__c == undefined)){
                                        tmpexist = true;
                                        //SM - FIX
                                        tmpsameexist = true;
                                    }

                                    if(element.Codice_fiscale__c==tmpitem.Codice_fiscale__c && element.Partita_iva__c == tmpitem.Partita_iva__c && element.Codice_fiscale__c != undefined && element.Partita_iva__c != undefined){
                                        tmpsameexist = true;
                                    }

                                    if(element.Partita_iva__c == undefined && element.Codice_fiscale__c == undefined && element.Name.trim() == tmpitem.Name.trim() /*&& element.BillingCountry == tmpitem.BillingCountry*/){
                                        tmpsameexist = true;
                                    }

                                    // if(element.Codice_fiscale__c==tmpitem.Codice_fiscale__c || element.Partita_iva__c == tmpitem.Partita_iva__c){
                                    //     tmpexist = true;
                                    // }

                                    // if(element.Codice_fiscale__c==tmpitem.Codice_fiscale__c && element.Partita_iva__c == tmpitem.Partita_iva__c){
                                    //     tmpsameexist = true;
                                    // }

                                    if(tmpexist==true){
                                        for (var ii = 0; ii < tmpcontainerr.length; ii++) {
                                            if(tmpcontainerr[ii].Partita_iva__c == tmpitem.Partita_iva__c || tmpcontainerr[ii].Codice_fiscale__c==tmpitem.Codice_fiscale__c){ 
                                                tmpcontainerr[ii].Censimento_Manuale__c = false; 
                                            }
                                        }
                                    }
                                    
                                });
                                if(tmpsameexist==false){
                                    tmpcontainerr.push(tmpitem);
                                }
                            }
                            this.tableData = tmpcontainerr;
                            this.hasResult = true;
                        }
                        this.spinner = false;
                    })
                }
                if(this.tableData.length<1){
                    this.hasResult = false;
                    this.showToastMessage(this.label.txtCAccount_NoResultsFound, "warning");
                }
            }else{
                if(iscf==false){
                    console.log('CHIAMATA ENDPOINT');
                    this.spinner=true;
                    
                    this.showToastMessage(this.label.txtCAccount_InnolvaSearch, "neutral");
                    executeCall({searchType: 2, searchedParameter: this.searchInput, siglaEstera : this.siglaEstera}).then(result => {
                        console.log(JSON.stringify(result));
                        if(result != '' && result!=null){
                            var tmpcontainer = [];
                            for (var i = 0; i < result.length; i++) {

                                var tmpitem = {...result[i]};
                                //tmpitem.crm = false;

                                if(tmpitem.Name.indexOf('#XML', 1) !=-1){
                                    //tmpitem.crm = true;
                                    tmpitem.Censimento_Manuale__c = false;
                                    tmpitem.Name = tmpitem.Name.replaceAll(' #XML', '');
                                }
                                
                                if(tmpitem.Censimento_Manuale__c == true){
                                    //tmpitem.crm = true;
                                }
                                //console.log('societa ', this.Societa);
                                //console.log('Societa_su_CTM__c', tmpitem.INN_societa__c);
                                /*if(this.Societa === 'Innolva')
                                {
                                    if(tmpitem.INN_societa__c === 'Innolva' ) tmpitem.crm = true;
                                    if(tmpitem.INN_societa__c === '' ) tmpitem.crm = false;
                                }
                                else if(this.Societa != 'Innolva')
                                {
                                    if(tmpitem.INN_societa__c === 'Innolva') tmpitem.crm = true;
                                    if(tmpitem.INN_societa__c === '') tmpitem.crm = false;
                                }*/
                                tmpcontainer.push(tmpitem);
                            }
                            
                            this.tableData = tmpcontainer;
                            this.innolvaData = result;
                            this.isInnolvaResult = true;
                            this.hasResult = true;
                        }else{
                            this.hasResult = false;
                            this.showToastMessage(this.label.txtCAccount_ServerNoResult, "warning");
                        }
                        this.spinner = false;
                    })
                }else{
                    this.spinner = false;
                }
            }
            
            this.isInnolvaResult = false;
        })
    }

    handleApexSearchName(){
        if(this.estero==false){ this.siglaEstera = 'IT'; }
        searchAccountByName({name: this.searchInput}).then(result => {
            console.log(JSON.stringify(result));
            
            console.log('RISULTATI CRM: ' + JSON.stringify(result));
            if(result != '' && result!=null){
                var tmpcontainer = [];
            //|| (tmpitem.Codice_fiscale__c == null && tmpitem.Partita_iva__c == null && tmpitem.Name == element.Name)
                for (var i = 0; i < result.length; i++) {
                    var tmpitem = {...result[i]};
                    tmpitem.Censimento_Manuale__c=true;
                    //tmpitem.crm = true;
                    tmpcontainer.push(tmpitem);      
                }
                this.hasResult = true;
                this.tableData = tmpcontainer;

                    
                    this.showToastMessage(this.label.txtCAccount_InnolvaSearch, "neutral");
                    executeCall({searchType: 1, searchedParameter: this.searchInput, siglaEstera : this.siglaEstera}).then(results => {
                        console.log('RISULTATI INNOLVA: '+JSON.stringify(results));
                        console.log('RISULTATI tabella: '+JSON.stringify(this.tableData));
                        var tmpcontainerr = [];
                        // SM - FIX
                        this.tableData.forEach(element => { tmpcontainerr.push(element); })

                        
                        var tmpexist = false;
                        var tmpsameexist = false;
                        if(results != '' && results!=null){
                            this.innolvaTable = results;
                            for (var i = 0; i < results.length; i++) {
                                var tmpitem = {...results[i]};
                                tmpexist = false;
                                tmpsameexist = false;

                                //SM - FIX
                                if(tmpitem.Name.indexOf('#XML', 1) !=-1){
                                    //tmpitem.crm = true;
                                    tmpitem.Censimento_Manuale__c = false;
                                    tmpitem.Name = tmpitem.Name.replaceAll(' #XML', '');
                                }
                                //console.log('societa ', this.Societa);
                                //console.log('Societa_su_CTM__c', tmpitem.INN_societa__c);
                                /*if(this.Societa === 'Innolva')
                                {
                                    if(tmpitem.INN_societa__c === 'Innolva' ) tmpitem.crm = true;
                                    if(tmpitem.INN_societa__c === '' ) tmpitem.crm = false;
                                }
                                else if(this.Societa != 'Innolva')
                                {
                                    if(tmpitem.INN_societa__c === 'Innolva') tmpitem.crm = true;
                                    if(tmpitem.INN_societa__c === '') tmpitem.crm = false;
                                }*/

                                tmpcontainerr.forEach(element => {

                                    //SM - FIX - Estero senza PIVA e CF
                                    // console.log('@@@ element.Codice_fiscale__c ' , element.Codice_fiscale__c);
                                    // console.log('@@@ tmpitem.Codice_fiscale__c ' , tmpitem.Codice_fiscale__c);
                                    // console.log('@@@ element.Partita_iva__c ' , element.Partita_iva__c);
                                    // console.log('@@@ tmpitem.Partita_iva__c ' , tmpitem.Partita_iva__c);
                                    console.log('@@@ element.Name ' , element.Name);
                                    console.log('@@@ tmpitem.Name ' , tmpitem.Name);
                                    //console.log('@@@ element.BillingCountry ' , element.CCIAA_REA__c);
                                    //console.log('@@@ element.BillingCountry ' , tmpitem.CCIAA_REA__c);
                                    //console.log('@@@ tmpitem.BillingCountry ' , element.CCIAA_CMK__c);
                                    //console.log('@@@ tmpitem.BillingCountry ' , tmpitem.CCIAA_CMK__c);
                                    console.log('societa ', this.Societa);
                                    console.log('element.INN_societa__c', element.INN_societa__c);
                                    console.log('element.REV_societa__c', element.REV_societa__c);
                                    console.log('element.Societa_su_CTM__c' , element.Societa_su_CTM__c);
                                    if(this.Societa === 'Innolva')
                                    {
                                        if(element.INN_societa__c === 'Innolva' ) element.crm = true;
                                        if(element.INN_societa__c === '' || element.INN_societa__c === undefined) element.crm = false;
                                    }
                                    else if(this.Societa === 'ReValuta')
                                    {
                                        if(element.REV_societa__c === 'ReValuta' ) element.crm = true;
                                        if(element.REV_societa__c === '' || element.REV_societa__c === undefined) element.crm = false;
                                    }
                                    else if(this.Societa != 'Innolva' && this.Societa != 'ReValuta')
                                    {
                                        if(element.Societa_su_CTM__c !== undefined) element.crm = true;
                                        if(element.Societa_su_CTM__c === undefined && (element.INN_societa__c !== undefined || element.REV_societa__c !== undefined)) element.crm = false;
                                    }

                                    if( (element.Codice_fiscale__c==tmpitem.Codice_fiscale__c && element.Codice_fiscale__c != undefined && element.Partita_iva__c == undefined && tmpitem.Partita_iva__c == undefined) || 
                                        (element.Partita_iva__c == tmpitem.Partita_iva__c && element.Partita_iva__c != undefined && element.Codice_fiscale__c == undefined && tmpitem.Codice_fiscale__c == undefined)){
                                        tmpexist = true;
                                        //SM - FIX
                                        tmpsameexist = true;
                                    }

                                    if(element.Codice_fiscale__c==tmpitem.Codice_fiscale__c && element.Partita_iva__c == tmpitem.Partita_iva__c && element.Codice_fiscale__c != undefined && element.Partita_iva__c != undefined){
                                        tmpsameexist = true;
                                    }

                                    if(element.Partita_iva__c == undefined && element.Codice_fiscale__c == undefined && element.Name.trim() == tmpitem.Name.trim() /*&& element.BillingCountry == tmpitem.BillingCountry*/){
                                        tmpsameexist = true;
                                    }

                                    if(tmpexist==true){
                                        for (var ii = 0; ii < tmpcontainerr.length; ii++) {
                                            if(tmpcontainerr[ii].Partita_iva__c == tmpitem.Partita_iva__c || tmpcontainerr[ii].Codice_fiscale__c==tmpitem.Codice_fiscale__c){ 
                                                tmpcontainerr[ii].Censimento_Manuale__c = false; 
                                            }
                                        }
                                    }
                                    
                                });
                                if(tmpsameexist==false){
                                    tmpcontainerr.push(tmpitem);
                                }
                            }
                            this.tableData = tmpcontainerr;
                        }
                        this.spinner = false;
                    })

                
            }else{
                console.log('CHIAMATA ENDPOINT');
                this.spinner=true;
                
                this.showToastMessage(this.label.txtCAccount_InnolvaSearch, "neutral");
                executeCall({searchType: 1, searchedParameter: this.searchInput, siglaEstera : this.siglaEstera}).then(result => {
                    console.log(JSON.stringify(result));
                    if (result != '' && result != null) {
                        var copyResult = result.map(r => {
                            let copyR = { ...r };
                            copyR.crm = false;
                            if(copyR.Name.indexOf('#XML', 1) !=-1){
                                copyR.crm = true;
                                copyR.Censimento_Manuale__c = false;
                                copyR.Name = copyR.Name.replaceAll(' #XML', '');
                            }
                            copyR.Name = copyR.Name.replaceAll(' #XML', '');
                            
                            if(copyR.Censimento_Manuale__c == true){
                                copyR.crm = true;
                            }
                            /*console.log('societa ', this.Societa);
                            console.log('Societa_su_CTM__c', tmpitem.INN_societa__c);
                            if(this.Societa === 'Innolva')
                            {
                                if(tmpitem.INN_societa__c === 'Innolva' ) tmpitem.crm = true;
                                if(tmpitem.INN_societa__c === '' ) tmpitem.crm = false;
                            }
                            else if(this.Societa != 'Innolva')
                            {
                                if(tmpitem.INN_societa__c === 'Innolva') tmpitem.crm = true;
                                if(tmpitem.INN_societa__c === '') tmpitem.crm = false;
                            }*/
                            return copyR;
                        });
                        console.log('@@@ copyResult ', copyResult);
                        this.tableData = copyResult;
                        this.innolvaData = copyResult;
                        this.isInnolvaResult = true;
                        this.hasResult = true;
                        // this.tableData = result;
                        // this.innolvaData = result;
                        // this.isInnolvaResult = true;
                        // this.hasResult = true;
                    }else{
                        this.hasResult = false;
                        this.showToastMessage(this.label.txtCAccount_ServerNoResult, "warning");
                    }
                    this.spinner = false;
                })
            }

        })
    }

    handleSearch(){
        if(this.isPersonaFisica == true){
            this.showToastMessage(this.label.txtCAccount_Sto_cercando_informazioni_su_CRM, "neutral");
            this.handleApexSearchAccount(true);
        }else{
            console.log('CHIAMATA ENDPOINT SWITCH');
            debugger;
            switch(this.selectedTab_priv){
                case "1":
                    this.handleApexSearchName()
                    break;
                case "2":
                    this.handleApexSearchAccount(false);
                    break;
            }
        }
    }

    @track isTabRagioneSociale = true;
    @track isTabPartitaIva = false;
    @track cButtonRagioneSociale = 'button-selected';
    @track cButtonPartitaIva = 'button-unselected';
    tabChangeHandler(event) {
        console.log('Tab attivata' + event.target.value);
        this.selectedTab = event.target.value;
        this.selectedTab_priv = event.target.value;
        this.isTabRagioneSociale = (this.selectedTab == 1) ? true : false;
        this.cButtonRagioneSociale = (this.selectedTab == 1) ? 'button-selected' : 'button-unselected';
        this.isTabPartitaIva = (this.selectedTab == 2) ? true : false;
        this.cButtonPartitaIva = (this.selectedTab == 2) ? 'button-selected' : 'button-unselected';
     }
    handleInserimento(){
        console.log('USCITA...');
        
        this.spinner = true;

        if(this.InserimentoManuale){
            const isInputsCorrect = [...this.template.querySelectorAll('lightning-input-field')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.reportValidity();
            }, true);

            if (!isInputsCorrect) {
                this.spinner = false;
                return;
            }
            // if(this.isPersonaFisica){
            //     // this.CFManuale = true;
            //     var check = true;
            //     if(this.isBlank(this.codiceFiscaleData))
            //         check = false;

            //     if(this.isBlank(this.viaIndirizzoSedeLegaleData) ||
            //         this.isBlank(this.cittaIndirizzoSedeLegaleData) ||
            //         this.isBlank(this.provinciaIndirizzoSedeLegaleData) ||
            //         this.isBlank(this.cAPIndirizzoSedeLegaleData) || 
            //         this.isBlank(this.paeseIndirizzoSedeLegaleData)){
            //             check = false;
            //     }

            //     if(!check){
            //         this.dispatchEvent(
            //             new ShowToastEvent({
            //                 title: "Attenzione!",
            //                 message: "Popolare tutti i campi obbligatori",
            //                 variant: "error"
            //             })
            //         )
            //         this.spinner = false;
            //         return;
            //     }
            // }else{
            //     // this.CFManuale = true;
            //     var check = true;
            //     if(this.isBlank(this.codiceFiscaleData) || this.isBlank(this.partitaIVAData))
            //         check = false;

            //     if(this.isBlank(this.viaIndirizzoSedeLegaleData) ||
            //         this.isBlank(this.cittaIndirizzoSedeLegaleData) ||
            //         this.isBlank(this.provinciaIndirizzoSedeLegaleData) ||
            //         this.isBlank(this.cAPIndirizzoSedeLegaleData) || 
            //         this.isBlank(this.paeseIndirizzoSedeLegaleData)){
            //             check = false;
            //     }

            //     if(!check){
            //         this.dispatchEvent(
            //             new ShowToastEvent({
            //                 title: "Attenzione!",
            //                 message: "Popolare tutti i campi obbligatori",
            //                 variant: "error"
            //             })
            //         )
            //         this.spinner = false;
            //         return;
            //     }
            // }
        }

        console.log('@@@ this.clienteEsteroData ;' , this.clienteEsteroData);
        var acc = {
            name: this.accountNameData+'###'+this.censimentomanualeData,
            partitaIva: this.partitaIVAData,
            codiceFiscale: this.codiceFiscaleData,
            ragioneSociale: this.ragioneSocialeDenominazioneData,
            cciaa: this.cCIAAREAData+'###'+this.cCIAAData,
            naturaGiuridica: this.naturaGiuridicaData,
            via: this.viaIndirizzoSedeLegaleData,
            citta: this.cittaIndirizzoSedeLegaleData,
            provincia: this.provinciaIndirizzoSedeLegaleData,
            cap: this.cAPIndirizzoSedeLegaleData,
            paese: this.paeseIndirizzoSedeLegaleData,
            dataBilancio: this.dataBilancioData,
            acquistiTotali: this.acquistiTotaliData,
            dataCessazione: this.dataCessazioneData,
            annoRilevazioneAddetti: this.annorilevazioneAddettiData,
            dataInizioAttivita: this.dataInizioAttivitaData,
            annualRevenue: this.annualRevenueData,
            livelloAttenzioneNegativita: this.livelloAttenzioneNegativitaData,
            capitaleSociale: this.capitaleSocialeData,
            creditiVsClienti: this.creditiVsClientiData,
            risultatoOperativoLordo: this.risultatoOperativoLordoData,
            phone: this.phoneData,
            email: this.emailData,
            totalePatrimonioNetto: this.totalePatrimonioNettoData,
            fax: this.faxData,
            utilePerdita: this.utilePerditaData,
            statoAttivita: this.statoAttivitaData,
            fatturato: this.fatturatoData,
            rating: this.ratingData,
            dipendenti: this.dipendentiData,
            codiceAteco: this.codiceAtecoData,
            descrizioneAteco: this.descrizioneAtecoData,
            clienteEstero: this.estero ? true : this.clienteEsteroData != undefined ? this.clienteEsteroData : false,
            gruppoIva: this.gruppoIvaData,
            denominazioneGruppoIva: this.denominazioneGruppoIvaData,
            erroreMonitoraggio: this.erroreMonitoraggioData,
            societasuctm: this.societasuctmdata,
            societainn: this.societainndata,
            societarev: this.societarevdata
        }

        console.log('@@@ acc ' , acc);
        // insertAccount({
        //     name: this.accountNameData+'###'+this.censimentomanualeData,
        //     partitaIva: this.partitaIVAData,
        //     codiceFiscale: this.codiceFiscaleData,
        //     ragioneSociale: this.ragioneSocialeDenominazioneData,
        //     cciaa: this.cCIAAREAData+'###'+this.cCIAAData,
        //     naturaGiuridica: this.naturaGiuridicaData,
        //     via: this.viaIndirizzoSedeLegaleData,
        //     citta: this.cittaIndirizzoSedeLegaleData,
        //     provincia: this.provinciaIndirizzoSedeLegaleData,
        //     cap: this.cAPIndirizzoSedeLegaleData,
        //     paese: this.paeseIndirizzoSedeLegaleData,
        //     dataBilancio: this.dataBilancioData,
        //     acquistiTotali: this.acquistiTotaliData,
        //     dataCessazione: this.dataCessazioneData,
        //     annoRilevazioneAddetti: this.annorilevazioneAddettiData,
        //     dataInizioAttivita: this.dataInizioAttivitaData,
        //     annualRevenue: this.annualRevenueData,
        //     livelloAttenzioneNegativita: this.livelloAttenzioneNegativitaData,
        //     capitaleSociale: this.capitaleSocialeData,
        //     creditiVsClienti: this.creditiVsClientiData,
        //     risultatoOperativoLordo: this.risultatoOperativoLordoData,
        //     phone: this.phoneData,
        //     email: this.emailData,
        //     totalePatrimonioNetto: this.totalePatrimonioNettoData,
        //     fax: this.faxData,
        //     utilePerdita: this.utilePerditaData,
        //     statoAttivita: this.statoAttivitaData,
        //     fatturato: this.fatturatoData,
        //     rating: this.ratingData,
        //     dipendenti: this.dipendentiData,
        //     codiceAteco: this.codiceAtecoData,
        //     descrizioneAteco: this.descrizioneAtecoData,
        //     clienteEstero: this.clienteEsteroData})
        insertAccount({ acc: acc })
            .then(result => {
            console.log(JSON.stringify(result));
            this.tableData = result;
            this.spinner = false;
            this.recordId = result;
            this.navigateToAccountListView();
        }).then(result => {
            this.showToastMessage(this.label.txtCAccount_Censimento_Effettuato, "success");
            console.log('success: ' + JSON.stringify(result));
        })
        .catch(error => {
            this.spinner = false;
            console.error('error: ' + JSON.stringify(error));

            var errorMessageToDisplay = ''
            let fieldErrors = error.body.fieldErrors;
            let pageErrors = error.body.pageErrors;
            
            for(var fieldName in fieldErrors){
                let errorList = fieldErrors[fieldName];
                for(var i=0; i < errorList.length; i++){
                    errorMessageToDisplay += errorList[i].statusCode + ' ' + fieldName + ' ' + errorList[i].message + ' ';
                }
            }

            if(pageErrors != undefined){
                pageErrors.forEach(p => {
                    errorMessageToDisplay += p.message;
                });
            }

            if(errorMessageToDisplay == '' && error.body.message != undefined){
                errorMessageToDisplay += error.body.message;
            }

            // for(var page in pageErrors){
            //     console.log('@@@ page ' , page);
            //     let errorList = pageErrors[page];
            //     console.log('@@@ errorList ' , errorList);
            //     for(var i=0; i < errorList.length; i++){
            //         // errorMessageToDisplay += errorList[i].statusCode + ' ' + page + ' ' + errorList[i].message + ' ';
            //         errorMessageToDisplay += errorList[i].message;
            //     }
            // }

            console.log('@@@ errorMessageToDisplay ' + errorMessageToDisplay);
            
            this.showToastMessage(this.label.txtCAccount_errore_durante_creazione + " " + errorMessageToDisplay, "error");

            
        });
    }

    callsGetProdottoPG(acct){
        this.spinner = true;
        console.log('CHIAMATA GETPRODOTTOPG ' + this.isInnolvaResult);
        console.log('InnolvaResult: ' + this.isInnolvaResult);
        if(this.isInnolvaResult == true){
            console.log('@@@ acct ', acct);
            //SM - FIX LOG
            acct.attributes = undefined;
            getProdottoPG({acct: acct}).then(resultx => {
                var risultato = resultx;
                console.log('RISULTATI GET PRODOTTO PG: ' + JSON.stringify(resultx));
                if(resultx != '' && resultx.Name!='error' && resultx!=null){
                    this.assignFields(risultato);
                    this.tableData = risultato;
                    this.innolvaData = risultato;
                    this.hasResult = true;
                    this.isSearch=false;
                    this.isResult=false;
                    this.isRecap=true;
                    this.disableSelectedRows=true;
                    this.isInnolvaResult = true;
                    this.erroreMonitoraggioData = resultx.Errore_Monitoraggio__c;
                }else{
                    this.hasResult = false;
                    this.erroreMonitoraggioData = this.estero === false && (acct.CCIAA_CMK__c !== null && acct.CCIAA_CMK__c !== undefined && acct.CCIAA_CMK__c !== '') &&
                                                (acct.CCIAA_REA__c !== null && acct.CCIAA_REA__c !== undefined && acct.CCIAA_REA__c !== '');
                    // this.showToastMessage("Il Server non risponde, riprovare più tardi", "error");
                    const d = new Date();
                    if(d.getHours() >= 21 || d.getHours() < 8){
                        this.showToastMessage(this.label.txtCAccount_servizio_non_garantito, "warning");
                    } else {
                        this.showToastMessage(this.label.txtCAccount_dati_incompleti, "warning");
                    }

                    this.assignFields(acct);
                }
                this.spinner = false;
            })
        }else{
            this.spinner = false;
        }
    }

    handleSelectedAccount(event){
        console.log('Target: ' + JSON.stringify(event.currentTarget));
        
        console.log('Dataset: ' + JSON.stringify(event.currentTarget.dataset.item));
        console.log('Click fatto: ' + event.currentTarget.getAttribute("data-item"));
    }
    handleInputChange(event){
        this.searchInput = event.target.value;
        console.log('SearchInput: ' +this.searchInput);
        if(this.searchInput != ''){
            this.disableCercaButton = false;
            console.log('disableCercaButton: ' +this.disableCercaButton);
        }else{
            this.disableCercaButton = true;
            console.log('disableCercaButton: ' +this.disableCercaButton);
        }
    }
    handleSiglaEsteraChange(event){
        this.siglaEstera = event.target.value;
        console.log('Siglaestera: ' + this.siglaEstera);
    }

    handleRefRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
        if(this.selectedRows.length>=1){
            this.disableSelectedRows=false;
            
            console.log('@@@ this.selectedRows[0] ' , this.selectedRows[0]);
            this.assignFields(this.selectedRows[0]);
            console.log('RECORD ID SELEZIONATO' + this.recordId);
            
        }else{
            this.disableSelectedRows=true;
            this.clearFields();
        }
    }

    handleCancel(){
        console.log('Cancel true');
    }
    // Navigation to Account List view(recent)
    navigateToAccountListView() {
        const that = this;
        var recId = this.recordId;
        if(recId != null && recId != undefined && recId != ''){
            window.setTimeout(function(){
                that[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: recId,
                        objectApiName: 'Account',
                        actionName: 'edit'
                    }
                })
            }, 3000);
        }

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        });

        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         objectApiName: 'Account',
        //         actionName: 'edit',
        //         recordId: this.recordId
        //     }
        // });
    }

    handleEsteroCehecked(event){
        this.estero = event.target.checked;
        console.log('Estero:' + this.estero);
    }
    handleTypeChoice(event){
        this.selectedType = event.detail.value;
        console.log('Tipo selezionato: ' + this.selectedType);
        if(this.selectedType != ''){
            this.disableTypeButton = false;
        }
        if(this.selectedType == 'personaFisica'){
            this.isPersonaFisica = true;
        }else{
            this.isPersonaFisica = false;
        }
    }
    assignFields(value){
        this.accountNameData = value.Name;
        this.partitaIVAData = value.Partita_iva__c;
        this.codiceFiscaleData = value.Codice_fiscale__c;
        this.ragioneSocialeDenominazioneData = value.denosociale__c;
        this.cCIAAData = value.CCIAA_CMK__c;
        // this.cCIAAREAData = this.selectedRows[0].CCIAA_REA__c;
        this.cCIAAREAData = value.CCIAA_REA__c;
        console.log('ISPERSONAFISICA:' + this.isPersonaFisica)
        if(this.isPersonaFisica == true){
            this.naturaGiuridicaData = 'PERSONA FISICA';
        }else{
            console.log('Forma_giuridica__c: '+value.Forma_giuridica__c);
            this.naturaGiuridicaData = value.Forma_giuridica__c;
        }
        this.viaIndirizzoSedeLegaleData = value.BillingStreet;
        this.cittaIndirizzoSedeLegaleData = value.BillingCity;
        this.provinciaIndirizzoSedeLegaleData = value.BillingState;
        this.cAPIndirizzoSedeLegaleData = value.BillingPostalCode;
        this.paeseIndirizzoSedeLegaleData = value.BillingCountry;

        this.dataBilancioData = value.Data_Bilancio__c;
        this.acquistiTotaliData = value.Acquisti_totali__c;
        this.dataCessazioneData = value.Data_di_cessazione__c;
        this.annorilevazioneAddettiData = value.Anno_rilevazione_addetti__c;
        this.dataInizioAttivitaData = value.Data_Inizio_Attivita__c;
        this.annualRevenueData = value.AnnualRevenue;
        this.livelloAttenzioneNegativitaData = value.Livello_attenzione_negativita__c;
        this.capitaleSocialeData = value.Capitale_Sociale__c;
        this.creditiVsClientiData = value.Crediti_vs_Clienti__c;
        this.risultatoOperativoLordoData = value.Risultato_Operativo_Lordo__c;
        // this.phoneData = value.Phone_Warrant__c;
        this.phoneData = value.Phone;
        this.emailData = value.Email_Aziendale_Innolva__c;
        this.totalePatrimonioNettoData = value.Totale_Patrimonio_Netto_Tinexta__c;
        this.faxData = value.Fax;
        this.utilePerditaData = value.Utile_Perdita__c;
        this.statoAttivitaData = value.Stato_Attivita__c;
        this.ratingData = value.Rating__c;
        try{
            TXT_PickList_Fatturato({ annualrevenue: value.AnnualRevenue }).then(result => { this.fatturatoData = result; console.log('@@@ result', this.fatturatoData); })
            TXT_PickList_Dipendenti({strnumero: value.Dipendenti__c}).then(result => {  this.dipendentiData = result; })
        }catch(error){}
        this.codiceAtecoData = value.Codice_Ateco_Innolva__c;
        this.descrizioneAtecoData = value.Descrizione_Ateco_Innolva__c;
        this.clienteEsteroData = value.Cliente_Estero__c;
        this.gruppoIvaData = value.TXT_Gruppo_IVA__c;
        this.denominazioneGruppoIvaData = value.TXT_Denominazione_Gruppo_IVA__c;
        this.societasuctmdata = value.Societa_su_CTM__c;
        this.societainndata = value.INN_societa__c;
        this.societarevdata = value.REV_societa__c;
    }
    clearFields(){
        this.recordId=null;
        this.accountNameData=null;
        this.partitaIVAData=null;
        this.accountNameData = null;
        this.ragioneSocialeDenominazioneData = null;
        this.cCIAAData = null;
        this.cCIAAREAData = null;
        this.codiceFiscaleData = null;
        this.partitaIVAData = null;
        this.naturaGiuridicaData = null;
        this.viaIndirizzoSedeLegaleData = null;
        this.cittaIndirizzoSedeLegaleData = null;
        this.provinciaIndirizzoSedeLegaleData = null;
        this.cAPIndirizzoSedeLegaleData = null;
        this.paeseIndirizzoSedeLegaleData = null;

        this.dataBilancioData = null;
        this.acquistiTotaliData = null;
        this.dataCessazioneData = null;
        this.annorilevazioneAddettiData = null;
        this.dataInizioAttivitaData = null;
        this.annualRevenueData = null;
        this.livelloAttenzioneNegativitaData = null;
        this.capitaleSocialeData = null;
        this.creditiVsClientiData = null;
        this.risultatoOperativoLordoData = null;
        this.phoneData = null;
        this.emailData = null;
        this.totalePatrimonioNettoData = null;
        this.faxData = null;
        this.utilePerditaData = null;
        this.statoAttivitaData = null;
        this.fatturatoData = null;
        this.ratingData = null;
        this.dipendentiData = null;
        this.codiceAtecoData = null;
        this.descrizioneAtecoData = null;
        this.clienteEsteroData = false;
        this.gruppoIvaData = null;
        this.denominazioneGruppoIvaData = null;
        this.societasuctmdata = null;
        this.societainndata = null;
        this.societarevdata = null;
    }

    get countryOptions() {
        return [
            { label: "Afghanistan", value: "AF" },
            { label: "Åland Islands", value: "AX" },
            { label: "Albania", value: "AL" },
            { label: "Algeria", value: "DZ" },
            { label: "American Samoa", value: "AS" },
            { label: "Andorra", value: "AD" },
            { label: "Angola", value: "AO" },
            { label: "Anguilla", value: "AI" },
            { label: "Antarctica", value: "AQ" },
            { label: "Antigua and Barbuda", value: "AG" },
            { label: "Argentina", value: "AR" },
            { label: "Armenia", value: "AM" },
            { label: "Aruba", value: "AW" },
            { label: "Australia", value: "AU" },
            { label: "Austria", value: "AT" },
            { label: "Azerbaijan", value: "AZ" },
            { label: "Bahamas", value: "BS" },
            { label: "Bahrain", value: "BH" },
            { label: "Bangladesh", value: "BD" },
            { label: "Barbados", value: "BB" },
            { label: "Belarus", value: "BY" },
            { label: "Belgium", value: "BE" },
            { label: "Belize", value: "BZ" },
            { label: "Benin", value: "BJ" },
            { label: "Bermuda", value: "BM" },
            { label: "Bhutan", value: "BT" },
            { label: "Bolivia", value: "BO" },
            { label: "Bonaire", value: "BQ" },
            { label: "Sint Eustatius", value: "0" },
            { label: "Saba", value: "0" },
            { label: "Bosnia and Herzegovina", value: "BA" },
            { label: "Botswana", value: "BW" },
            { label: "Bouvet Island", value: "BV" },
            { label: "Brazil", value: "BR" },
            { label: "British Indian Ocean Territory", value: "IO" },
            { label: "Brunei Darussalam", value: "BN" },
            { label: "Bulgaria", value: "BG" },
            { label: "Burkina Faso", value: "BF" },
            { label: "Burundi", value: "BI" },
            { label: "Cabo Verde", value: "CV" },
            { label: "Cambodia", value: "KH" },
            { label: "Cameroon", value: "CM" },
            { label: "Canada", value: "CA" },
            { label: "Cayman Islands", value: "KY" },
            { label: "Central African Republic", value: "CF" },
            { label: "Chad", value: "TD" },
            { label: "Chile", value: "CL" },
            { label: "China", value: "CN" },
            { label: "Christmas Island", value: "CX" },
            { label: "Cocos (Keeling) Islands", value: "CC" },
            { label: "Colombia", value: "CO" },
            { label: "Comoros", value: "KM" },
            { label: "Congo (the Democratic Republic of the)", value: "CD" },
            { label: "Congo", value: "CG" },
            { label: "Cook Islands", value: "CK" },
            { label: "Costa Rica", value: "CR" },
            { label: "Côte d'Ivoire", value: "CI" },
            { label: "Croatia", value: "HR" },
            { label: "Cuba", value: "CU" },
            { label: "Curaçao", value: "CW" },
            { label: "Cyprus", value: "CY" },
            { label: "Czechia", value: "CZ" },
            { label: "Denmark", value: "DK" },
            { label: "Djibouti", value: "DJ" },
            { label: "Dominica", value: "DM" },
            { label: "Dominican Republic", value: "DO" },
            { label: "Ecuador", value: "EC" },
            { label: "Egypt", value: "EG" },
            { label: "El Salvador", value: "SV" },
            { label: "Equatorial Guinea", value: "GQ" },
            { label: "Eritrea", value: "ER" },
            { label: "Estonia", value: "EE" },
            { label: "Eswatini", value: "SZ" },
            { label: "Ethiopia", value: "ET" },
            { label: "Falkland Islands", value: "FK" },
            { label: "Faroe Islands", value: "FO" },
            { label: "Fiji", value: "FJ" },
            { label: "Finland", value: "FI" },
            { label: "France", value: "FR" },
            { label: "French Guiana", value: "GF" },
            { label: "French Polynesia", value: "PF" },
            { label: "French Southern Territories", value: "TF" },
            { label: "Gabon", value: "GA" },
            { label: "Gambia", value: "GM" },
            { label: "Georgia", value: "GE" },
            { label: "Germany", value: "DE" },
            { label: "Ghana", value: "GH" },
            { label: "Gibraltar", value: "GI" },
            { label: "Greece", value: "GR" },
            { label: "Greenland", value: "GL" },
            { label: "Grenada", value: "GD" },
            { label: "Guadeloupe", value: "GP" },
            { label: "Guam", value: "GU" },
            { label: "Guatemala", value: "GT" },
            { label: "Guernsey", value: "GG" },
            { label: "Guinea", value: "GN" },
            { label: "Guinea-Bissau", value: "GW" },
            { label: "Guyana", value: "GY" },
            { label: "Haiti", value: "HT" },
            { label: "Heard Island and McDonald Islands", value: "HM" },
            { label: "Honduras", value: "HN" },
            { label: "Hong Kong", value: "HK" },
            { label: "Hungary", value: "HU" },
            { label: "Iceland", value: "IS" },
            { label: "India", value: "IN" },
            { label: "Indonesia", value: "ID" },
            { label: "Iran (Islamic Republic of)", value: "IR" },
            { label: "Iraq", value: "IQ" },
            { label: "Ireland", value: "IE" },
            { label: "Isle of Man", value: "IM" },
            { label: "Israel", value: "IL" },
            { label: "Italy", value: "IT" },
            { label: "Jamaica", value: "JM" },
            { label: "Japan", value: "JP" },
            { label: "Jersey", value: "JE" },
            { label: "Jordan", value: "JO" },
            { label: "Kazakhstan", value: "KZ" },
            { label: "Kenya", value: "KE" },
            { label: "Kiribati", value: "KI" },
            { label: "Korea (the Democratic People's Republic of)", value: "KP" },
            { label: "Korea (the Republic of)", value: "KR" },
            { label: "Kuwait", value: "KW" },
            { label: "Kyrgyzstan", value: "KG" },
            { label: "Lao People's Democratic Republic", value: "LA" },
            { label: "Latvia", value: "LV" },
            { label: "Lebanon", value: "LB" },
            { label: "Lesotho", value: "LS" },
            { label: "Liberia", value: "LR" },
            { label: "Libya", value: "LY" },
            { label: "Liechtenstein", value: "LI" },
            { label: "Lithuania", value: "LT" },
            { label: "Luxembourg", value: "LU" },
            { label: "Macao", value: "MO" },
            { label: "North Macedonia", value: "MK" },
            { label: "Madagascar", value: "MG" },
            { label: "Malawi", value: "MW" },
            { label: "Malaysia", value: "MY" },
            { label: "Maldives", value: "MV" },
            { label: "Mali", value: "ML" },
            { label: "Malta", value: "MT" },
            { label: "Marshall Islands", value: "MH" },
            { label: "Martinique", value: "MQ" },
            { label: "Mauritania", value: "MR" },
            { label: "Mauritius", value: "MU" },
            { label: "Mayotte", value: "YT" },
            { label: "Mexico", value: "MX" },
            { label: "Micronesia (Federated States of)", value: "FM" },
            { label: "Moldova (the Republic of)", value: "MD" },
            { label: "Monaco", value: "MC" },
            { label: "Mongolia", value: "MN" },
            { label: "Montenegro", value: "ME" },
            { label: "Montserrat", value: "MS" },
            { label: "Morocco", value: "MA" },
            { label: "Mozambique", value: "MZ" },
            { label: "Myanmar", value: "MM" },
            { label: "Namibia", value: "NA" },
            { label: "Nauru", value: "NR" },
            { label: "Nepal", value: "NP" },
            { label: "Netherlands", value: "NL" },
            { label: "New Caledonia", value: "NC" },
            { label: "New Zealand", value: "NZ" },
            { label: "Nicaragua", value: "NI" },
            { label: "Niger", value: "NE" },
            { label: "Nigeria", value: "NG" },
            { label: "Niue", value: "NU" },
            { label: "Norfolk Island", value: "NF" },
            { label: "Northern Mariana Islands", value: "MP" },
            { label: "Norway", value: "NO" },
            { label: "Oman", value: "OM" },
            { label: "Pakistan", value: "PK" },
            { label: "Palau", value: "PW" },
            { label: "Palestine, State of", value: "PS" },
            { label: "Panama", value: "PA" },
            { label: "Papua New Guinea", value: "PG" },
            { label: "Paraguay", value: "PY" },
            { label: "Peru", value: "PE" },
            { label: "Philippines", value: "PH" },
            { label: "Pitcairn", value: "PN" },
            { label: "Poland", value: "PL" },
            { label: "Portugal", value: "PT" },
            { label: "Puerto Rico", value: "PR" },
            { label: "Qatar", value: "QA" },
            { label: "Réunion", value: "RE" },
            { label: "Romania", value: "RO" },
            { label: "Russian Federation", value: "RU" },
            { label: "Rwanda", value: "RW" },
            { label: "Saint Barthélemy", value: "BL" },
            { label: "Saint Helena", value: "SH" },
            { label: "Ascension Island", value: "0" },
            { label: "Tristan da Cunha", value: "0" },
            { label: "Saint Kitts and Nevis", value: "KN" },
            { label: "Saint Lucia", value: "LC" },
            { label: "Saint Martin (French part)", value: "MF" },
            { label: "Saint Pierre and Miquelon", value: "PM" },
            { label: "Saint Vincent and the Grenadines", value: "VC" },
            { label: "Samoa", value: "WS" },
            { label: "San Marino", value: "SM" },
            { label: "Sao Tome and Principe", value: "ST" },
            { label: "Saudi Arabia", value: "SA" },
            { label: "Senegal", value: "SN" },
            { label: "Serbia", value: "RS" },
            { label: "Seychelles", value: "SC" },
            { label: "Sierra Leone", value: "SL" },
            { label: "Singapore", value: "SG" },
            { label: "Sint Maarten (Dutch part)", value: "SX" },
            { label: "Slovakia", value: "SK" },
            { label: "Slovenia", value: "SI" },
            { label: "Solomon Islands", value: "SB" },
            { label: "Somalia", value: "SO" },
            { label: "South Africa", value: "ZA" },
            { label: "South Georgia and the South Sandwich Islands", value: "GS" },
            { label: "South Sudan", value: "SS" },
            { label: "Spain", value: "ES" },
            { label: "Sri Lanka", value: "LK" },
            { label: "Sudan", value: "SD" },
            { label: "Suriname", value: "SR" },
            { label: "Svalbard", value: "SJ" },
            { label: "Jan Mayen", value: "0" },
            { label: "Sweden", value: "SE" },
            { label: "Switzerland", value: "CH" },
            { label: "Syrian Arab Republic", value: "SY" },
            { label: "Taiwan (Province of China)", value: "TW" },
            { label: "Tajikistan", value: "TJ" },
            { label: "Tanzania, the United Republic of", value: "TZ" },
            { label: "Thailand", value: "TH" },
            { label: "Timor-Leste", value: "TL" },
            { label: "Togo", value: "TG" },
            { label: "Tokelau", value: "TK" },
            { label: "Tonga", value: "TO" },
            { label: "Trinidad and Tobago", value: "TT" },
            { label: "Tunisia", value: "TN" },
            { label: "Turkey", value: "TR" },
            { label: "Turkmenistan", value: "TM" },
            { label: "Turks and Caicos Islands", value: "TC" },
            { label: "Tuvalu", value: "TV" },
            { label: "Uganda", value: "UG" },
            { label: "Ukraine", value: "UA" },
            { label: "United Arab Emirates", value: "AE" },
            { label: "United Kingdom of Great Britain and Northern Ireland", value: "GB" },
            { label: "United States Minor Outlying Islands", value: "UM" },
            { label: "United States of America", value: "US" },
            { label: "Uruguay", value: "UY" },
            { label: "Uzbekistan", value: "UZ" },
            { label: "Vanuatu", value: "VU" },
            { label: "Venezuela (Bolivarian Republic of)", value: "VE" },
            { label: "Viet Nam ae", value: "VN" },
            { label: "Virgin Islands (British)", value: "VG" },
            { label: "Virgin Islands (U.S.)", value: "VI" },
            { label: "Wallis and Futuna", value: "WF" },
            { label: "Western Sahara", value: "EH" },
            { label: "Yemen", value: "YE" },
            { label: "Zambia", value: "ZM" },
            { label: "Zimbabwe", value: "ZW" }

            // { label: "ALBANIA", value: "AL" },
            // { label: "ALGERIA", value: "DZ" },
            // { label: "ANDORRA", value: "AD" },
            // { label: "ANGOLA", value: "AO" },
            // { label: "ANGUILLA", value: "AI" },
            // { label: "ANTARTIDE FRANCESE", value: "TF" },
            // { label: "ANTIGUA/BARBUDA", value: "AG" },
            // { label: "ANTILLE OLANDESI", value: "AN" },
            // { label: "ARABIA SAUDITA", value: "SA" },
            // { label: "ARCIPELAGO DI COOK", value: "CK" },
            // { label: "ARGENTINA", value: "AR" },
            // { label: "ARMENIA", value: "AM" },
            // { label: "ARUBA", value: "AW" },
            // { label: "ASCENSION", value: "SH" },
            // { label: "AUSTRALIA", value: "AU" },
            // { label: "AUSTRIA", value: "AT" },
            // { label: "AZERBAIGIAN", value: "AZ" },
            // { label: "BAHAMA", value: "BS" },
            // { label: "BAHREIN", value: "BH" },
            // { label: "BANGLADESH", value: "BD" },
            // { label: "BARBADOS", value: "BB" },
            // { label: "BELGIO", value: "BE" },
            // { label: "BELIZE", value: "BZ" },
            // { label: "BENIN", value: "BJ" },
            // { label: "BERMUDE", value: "BM" },
            // { label: "BHUTAN", value: "BT" },
            // { label: "BIELORUSSIA", value: "BY" },
            // { label: "BOLIVIA", value: "BO" },
            // { label: "BOSNIA-ERZEGOVINA", value: "BA" },
            // { label: "BOTSWANA", value: "BW" },
            // { label: "BRASILE", value: "BR" },
            // { label: "BRUNEI", value: "BN" },
            // { label: "BULGARIA", value: "BG" },
            // { label: "BURKINA FASO", value: "BF" },
            // { label: "BURUNDI", value: "BI" },
            // { label: "CAMBOGIA", value: "KH" },
            // { label: "CAMERUN", value: "CM" },
            // { label: "CANADA", value: "CA" },
            // { label: "CAYMAN", value: "KY" },
            // { label: "CENTRAFRICA", value: "CF" },
            // { label: "CIAD", value: "TD" },
            // { label: "CILE", value: "CL" },
            // { label: "CINA", value: "CN" },
            // { label: "CIPRO", value: "CV" },
            // { label: "CIPRO", value: "CY" },
            // { label: "CITTA' DEL VATICANO", value: "VA" },
            // { label: "COLOMBIA", value: "CO" },
            // { label: "COMORE", value: "KM" },
            // { label: "COREA DEL NORD", value: "KP" },
            // { label: "COREA DEL SUD", value: "KR" },
            // { label: "COSTA D'AVORIO", value: "CI" },
            // { label: "COSTA RICA", value: "CR" },
            // { label: "CROAZIA", value: "HR" },
            // { label: "CUBA", value: "CU" },
            // { label: "DANIMARCA", value: "DK" },
            // { label: "DOMINICA", value: "DM" },
            // { label: "ECUADOR", value: "EC" },
            // { label: "EGITTO", value: "EG" },
            // { label: "EMIRATI ARABI UNITI", value: "AE" },
            // { label: "ERITREA", value: "ER" },
            // { label: "ESTONIA", value: "EE" },
            // { label: "ETIOPIA", value: "ET" },
            // { label: "FILIPPINE", value: "PH" },
            // { label: "FINLANDIA", value: "FI" },
            // { label: "FRANCIA", value: "FR" },
            // { label: "GABON", value: "GA" },
            // { label: "GAMBIA", value: "GM" },
            // { label: "GEORGIA", value: "GE" },
            // { label: "GEORGIA DEL SUD E S", value: "GS" },
            // { label: "GERMANIA", value: "DE" },
            // { label: "GHANA", value: "GH" },
            // { label: "GIAMAICA", value: "JM" },
            // { label: "GIAPPONE", value: "JP" },
            // { label: "GIBILTERRA", value: "GI" },
            // { label: "GIBUTI", value: "DJ" },
            // { label: "GIORDANIA", value: "JO" },
            // { label: "GRAN BRETAGNA", value: "GB" },
            // { label: "GRECIA", value: "GR" },
            // { label: "GRENADA", value: "GD" },
            // { label: "GROENLANDIA", value: "GL" },
            // { label: "GUADALUPA", value: "GP" },
            // { label: "GUAM", value: "GU" },
            // { label: "GUATEMALA", value: "GT" },
            // { label: "GUIANA", value: "GY" },
            // { label: "GUIANA FRANCESE", value: "GF" },
            // { label: "GUINEA EQUATORIALE", value: "GQ" },
            // { label: "GUINEA-BISSAU", value: "GW" },
            // { label: "HAITI", value: "HT" },
            // { label: "HONDURAS", value: "HN" },
            // { label: "HONG KONG", value: "HK" },
            // { label: "INDIA", value: "IN" },
            // { label: "INDONESIA", value: "ID" },
            // { label: "IRAN", value: "IR" },
            // { label: "IRAQ", value: "IQ" },
            // { label: "IRLANDA", value: "IE" },
            // { label: "ISLANDA", value: "IS" },
            // { label: "ISOLA DI NORFOLK", value: "NF" },
            // { label: "ISOLE CHRISTMAS", value: "CX" },
            // { label: "ISOLE COCOS", value: "CC" },
            // { label: "ISOLE FAEROER", value: "FO" },
            // { label: "ISOLE FALKLAND", value: "FK" },
            // { label: "ISOLE FIGI", value: "FJ" },
            // { label: "ISOLE MARIANNE", value: "MP" },
            // { label: "ISOLE MARSHALL", value: "MH" },
            // { label: "ISOLE MINORI (USA)", value: "UM" },
            // { label: "ISOLE PALAU", value: "PW" },
            // { label: "ISOLE SALOMONE", value: "SB" },
            // { label: "ISOLE TOKELAU", value: "TK" },
            // { label: "ISOLE VERGINI (BRIT", value: "VG" },
            // { label: "ISOLE VERGINI (USA)", value: "VI" },
            // { label: "ISRAELE", value: "IL" },
            // { label: "ITALIA", value: "IT" },
            // { label: "KAZAKISTAN", value: "KZ" },
            // { label: "KENYA", value: "KE" },
            // { label: "KIRGHIZISTAN", value: "KG" },
            // { label: "KIRIBATI", value: "KI" },
            // { label: "KOSOVO", value: "XZ" },
            // { label: "KUWAIT", value: "KW" },
            // { label: "LAOS", value: "LA" },
            // { label: "LESOTHO", value: "LS" },
            // { label: "LETTONIA", value: "LV" },
            // { label: "LIBANO", value: "LB" },
            // { label: "LIBERIA", value: "LR" },
            // { label: "LIBIA", value: "LY" },
            // { label: "LIECHTENSTEIN", value: "LI" },
            // { label: "LITUANIA", value: "LT" },
            // { label: "LUSSEMBURGO", value: "LU" },
            // { label: "MACAO", value: "MO" },
            // { label: "MACEDONIA", value: "MK" },
            // { label: "MADAGASCAR", value: "MG" },
            // { label: "MALAISIA", value: "MY" },
            // { label: "MALAWI", value: "MW" },
            // { label: "MALDIVE", value: "MV" },
            // { label: "MALI", value: "ML" },
            // { label: "MALTA", value: "MT" },
            // { label: "MAROCCO", value: "MA" },
            // { label: "MARTINICA", value: "MQ" },
            // { label: "MAURITANIA", value: "MR" },
            // { label: "MAURIZIO", value: "MU" },
            // { label: "MAYOTTE", value: "YT" },
            // { label: "MESSICO", value: "MX" },
            // { label: "MOLDAVIA", value: "MD" },
            // { label: "MONGOLIA", value: "MN" },
            // { label: "MONTECARLO", value: "MC" },
            // { label: "MONTSERRAT", value: "MS" },
            // { label: "MOZAMBICO", value: "MZ" },
            // { label: "MYANMAR (UNIONE)", value: "MM" },
            // { label: "NAMIBIA", value: "NA" },
            // { label: "NAURU", value: "NR" },
            // { label: "NEPAL", value: "NP" },
            // { label: "NICARAGUA", value: "NI" },
            // { label: "NIGER", value: "NE" },
            // { label: "NIGERIA", value: "NG" },
            // { label: "NORVEGIA", value: "NO" },
            // { label: "NUOVA CALEDONIA", value: "NC" },
            // { label: "NUOVA ZELANDA", value: "NZ" },
            // { label: "OLANDA", value: "NL" },
            // { label: "OMAN", value: "OM" },
            // { label: "PAKISTAN", value: "PK" },
            // { label: "PANAMA", value: "PA" },
            // { label: "PAPUA-NUOVA GUINEA", value: "PG" },
            // { label: "PARAGUAY", value: "PY" },
            // { label: "PERU'", value: "PE" },
            // { label: "PITCAIRN", value: "PN" },
            // { label: "POLINESIA FRANCESE", value: "PF" },
            // { label: "POLONIA", value: "PL" },
            // { label: "PORTOGALLO", value: "PT" },
            // { label: "PORTORICO", value: "PR" },
            // { label: "QATAR", value: "QA" },
            // { label: "REP. DEMOCRATICA CO", value: "CD" },
            // { label: "REPUBBLICA CECA", value: "CZ" },
            // { label: "REPUBBLICA DEL CONG", value: "CG" },
            // { label: "REPUBBLICA DI GUINE", value: "GN" },
            // { label: "REPUBBLICA DOMINICA", value: "DO" },
            // { label: "REPUBBLICA SLOVACCA", value: "SK" },
            // { label: "REUNION", value: "RE" },
            // { label: "ROMANIA", value: "RO" },
            // { label: "RUANDA", value: "RW" },
            // { label: "RUSSIA", value: "RU" },
            // { label: "SAINT VINCENT E GRE", value: "VC" },
            // { label: "SAINT-PIERRE ET MIQ", value: "PM" },
            // { label: "SALVADOR", value: "SV" },
            // { label: "SAMOA (USA)", value: "AS" },
            // { label: "SAMOA OCCIDENTALI", value: "WS" },
            // { label: "SAN CRISTOFORO E NE", value: "KN" },
            // { label: "SAN MARINO", value: "SM" },
            // { label: "SANTA LUCIA", value: "LC" },
            // { label: "SAO TOME' E PRINCIP", value: "ST" },
            // { label: "SENEGAL", value: "SN" },
            // { label: "SERBIA E MONTENEGRO", value: "YU" },
            // { label: "SEYCHELLES", value: "SC" },
            // { label: "SIERRA LEONE", value: "SL" },
            // { label: "SINGAPORE", value: "SG" },
            // { label: "SIRIA", value: "SY" },
            // { label: "SLOVENIA", value: "SI" },
            // { label: "SOMALIA", value: "SO" },
            // { label: "SPAGNA", value: "ES" },
            // { label: "SRI LANKA", value: "LK" },
            // { label: "STATI UNITI D'AMERI", value: "US" },
            // { label: "SUD AFRICA", value: "ZA" },
            // { label: "SUDAN", value: "SD" },
            // { label: "SURINAME", value: "SR" },
            // { label: "SVEZIA", value: "SE" },
            // { label: "SVIZZERA", value: "CH" },
            // { label: "SWAZILAND", value: "SZ" },
            // { label: "TAGISKISTAN", value: "TJ" },
            // { label: "TAILANDIA", value: "TH" },
            // { label: "TAIWAN", value: "TW" },
            // { label: "TANZANIA", value: "TZ" },
            // { label: "TIMOR ORIENTALE", value: "TP" },
            // { label: "TOGO", value: "TG" },
            // { label: "TONGA", value: "TO" },
            // { label: "TRINIDAD E TOBAGO", value: "TT" },
            // { label: "TUNISIA", value: "TN" },
            // { label: "TURCHIA", value: "TR" },
            // { label: "TURKMENISTAN", value: "TM" },
            // { label: "TURKS E CAICOS", value: "TC" },
            // { label: "TUVALU", value: "TV" },
            // { label: "UCRAINA", value: "UA" },
            // { label: "UGANDA", value: "UG" },
            // { label: "UNGHERIA", value: "HU" },
            // { label: "UNIONE SOVIETICA", value: "SU" },
            // { label: "URUGUAY", value: "UY" },
            // { label: "UZBEKISTAN", value: "UZ" },
            // { label: "VANUATU", value: "VU" },
            // { label: "VENEZUELA", value: "VE" },
            // { label: "VIETNAM", value: "VN" },
            // { label: "WALLIS E FUTUNA", value: "WF" },
            // { label: "YEMEN", value: "YE" },
            // { label: "ZAIRE", value: "ZR" },
            // { label: "ZAMBIA", value: "ZM" },
            // { label: "ZIMBABWE", value: "ZW" }
  
        ];
      }

    showToastMessage(text, type) {
        const toastEvent = new ShowToastEvent({
            title: '',
            message: text,
            variant: type
        });
        this.dispatchEvent(toastEvent);
    }

    isBlank(v){
        if(v == '' || v == null || v == undefined)
            return true;

        return false;
    }
}