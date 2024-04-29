//AdF LWC di visualizzazione data table
import { LightningElement, api, track, wire } from 'lwc';
// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from "lightning/actions";

import TXT_UpdateLead from '@salesforce/apex/TXT_ConversioneLead.TXT_UpdateLead';
import TXT_RetriveDataLead from '@salesforce/apex/TXT_ConversioneLead.TXT_RetriveDataLead';
import TXT_RecapInfo from '@salesforce/apex/TXT_ConversioneLead.TXT_RecapInfo';
import TXT_ProcessoDiConversione from '@salesforce/apex/TXT_ConversioneLead.TXT_ProcessoDiConversione';
import TXT_UpdateLeadBeforeConversion from '@salesforce/apex/TXT_ConversioneLead.TXT_UpdateLeadBeforeConversion';
import handleCTM from '@salesforce/apex/TXT_ConversioneLead.handleCTM';

//import executeCallMock  from '@salesforce/apex/TXT_CalloutHandler.executeCallMock';
import executeCall  from '@salesforce/apex/TXT_CalloutHandler.executeCall';
import getProdottoPG from '@salesforce/apex/TXT_CalloutHandler.getProdottoPG';
import handleSessionCacheArricchimento from '@salesforce/apex/TXT_CalloutHandler.handleSessionCacheArricchimento';
//Import Campi Lead
//import TEST_FIELD from '@salesforce/schema/Lead.test__c';

import UserId from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import Soc from '@salesforce/schema/User.Societa__c';
import SocUser from '@salesforce/schema/User.Societ_di_riferimento__c';

import FORMA_GIURIDICA_LEAD from '@salesforce/schema/Lead.Forma_giuridica__c';
import CLIENTE_ESTERO from '@salesforce/schema/Lead.YOR_Cliente_Estero__c';
import company_lead from '@salesforce/schema/Lead.Company';
import CCIAA_LEAD from '@salesforce/schema/Lead.CCIAA_CMK__c';
import CCIAA_REA_LEAD from '@salesforce/schema/Lead.CCIAA_REA_Innolva__c';
import PartivaIva_LEAD from '@salesforce/schema/Lead.Partiva_Iva__c';
import Street_LEAD from '@salesforce/schema/Lead.Street';
import Country_LEAD from '@salesforce/schema/Lead.Country';
import City_LEAD from '@salesforce/schema/Lead.City';
import State_LEAD from '@salesforce/schema/Lead.State';
import PostalCode_LEAD from '@salesforce/schema/Lead.PostalCode';
import Codice_Fiscale_LEAD from '@salesforce/schema/Lead.Codice_Fiscale__c';
import Natura_Giuridica_Innolva_LEAD from '@salesforce/schema/Lead.Natura_Giuridica_Innolva__c';
import GruppoIva_Field from '@salesforce/schema/Lead.TXT_Gruppo_IVA__c';
import DenominazioneGruppoIva_Field from '@salesforce/schema/Lead.TXT_Denominazione_Gruppo_IVA__c';

//Import Campi Account
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
const pfields = [FORMA_GIURIDICA_FIELD];
import FORMA_GIURIDICA_FIELD from '@salesforce/schema/Account.Forma_giuridica__c';

import DENOSOCIALE_FIELD from '@salesforce/schema/Account.denosociale__c';
import NAME_FIELD from '@salesforce/schema/Account.Name';

import TXT_PickList_Fatturato from '@salesforce/apex/TXT_ProcessiLeadAccountUtils.TXT_PickList_Fatturato';
import TXT_PickList_Dipendenti from '@salesforce/apex/TXT_ProcessiLeadAccountUtils.TXT_PickList_Dipendenti';

import txtCLead_Load from '@salesforce/label/c.txtCLead_Load';
import txtCLead_cfpiva_pg from '@salesforce/label/c.txtCLead_cfpiva_pg';
import txtCLead_recap_acc from '@salesforce/label/c.txtCLead_recap_acc';
import txtCLead_manuale from '@salesforce/label/c.txtCLead_manuale';
import txtCLead_recap_info from '@salesforce/label/c.txtCLead_recap_info';
import txtCProcessi_SpinnerMessage from '@salesforce/label/c.txtCProcessi_SpinnerMessage';
import txtCLead_Denominazione from '@salesforce/label/c.txtCLead_Denominazione';
import txtCLead_Estera from '@salesforce/label/c.txtCLead_Estera';
import txtCLead_Cerca from '@salesforce/label/c.txtCLead_Cerca';
import txtCLead_Nazione from '@salesforce/label/c.txtCLead_Nazione';
import txtCLead_SearchInnolva from '@salesforce/label/c.txtCLead_SearchInnolva';
import txtCLead_ServerNoResult from '@salesforce/label/c.txtCLead_ServerNoResult';
import txtCLead_NoResultsFound from '@salesforce/label/c.txtCLead_NoResultsFound';
import txtCLead_ConversioneManuale from '@salesforce/label/c.txtCLead_ConversioneManuale';
import txtCLead_Indietro from '@salesforce/label/c.txtCLead_Indietro';
import txtCLead_CreareOpty from '@salesforce/label/c.txtCLead_CreareOpty';
import txtCLead_AvviaConversione from '@salesforce/label/c.txtCLead_AvviaConversione';
import txtCLead_Avanti from '@salesforce/label/c.txtCLead_Avanti';
import txtCAccount_Denominazione from '@salesforce/label/c.txtCAccount_Denominazione';
import txtCAccount_PartitaIVA from '@salesforce/label/c.txtCAccount_PartitaIVA';
import txtCAccount_CodiceFiscale from '@salesforce/label/c.txtCAccount_CodiceFiscale';
import txtCAccount_FormaGiuridica from '@salesforce/label/c.txtCAccount_FormaGiuridica';
import txtCAccount_CittaLegale from '@salesforce/label/c.txtCAccount_CittaLegale';
import txtCAccount_ProvinciaLegale from '@salesforce/label/c.txtCAccount_ProvinciaLegale';
import txtCAccount_IndirizzoLegale from '@salesforce/label/c.txtCAccount_IndirizzoLegale';
import txtCAccount_stato_attivita from '@salesforce/label/c.txtCAccount_stato_attivita';
import txtCAccount_Sto_ottenendo_le_informazioni_da_Innolva from '@salesforce/label/c.txtCAccount_Sto_ottenendo_le_informazioni_da_Innolva';
import txtCAccount_Sto_cercando_informazioni_su_CRM from '@salesforce/label/c.txtCAccount_Sto_cercando_informazioni_su_CRM';
import txtCAccount_servizio_non_garantito from '@salesforce/label/c.txtCAccount_servizio_non_garantito';
import txtCAccount_dati_incompleti from '@salesforce/label/c.txtCAccount_dati_incompleti';
import txtCLead_conversione_effettuata from '@salesforce/label/c.txtCLead_conversione_effettuata';
import txtCLead_errore_conversione from '@salesforce/label/c.txtCLead_errore_conversione';
import txtCAccount_nessun_riscontro_piva_e_cf from '@salesforce/label/c.txtCAccount_nessun_riscontro_piva_e_cf';
import txtCLead_aggiornamento_lead from '@salesforce/label/c.txtCLead_aggiornamento_lead';
import txtCLead_sto_facendo_la_conversione from '@salesforce/label/c.txtCLead_sto_facendo_la_conversione';
import Richiesta_Approvatore_Account__c from '@salesforce/schema/TXT_FastManager_User__c.Richiesta_Approvatore_Account__c';

export default class txtConversioneLead extends NavigationMixin(LightningElement) {

    // Labels
    label = {
      txtCProcessi_SpinnerMessage: txtCProcessi_SpinnerMessage,
      txtCLead_Denominazione: txtCLead_Denominazione,
      txtCLead_Estera: txtCLead_Estera,
      txtCLead_Cerca: txtCLead_Cerca,
      txtCLead_Nazione: txtCLead_Nazione,
      txtCLead_SearchInnolva: txtCLead_SearchInnolva,
      txtCLead_ServerNoResult: txtCLead_ServerNoResult,
      txtCLead_NoResultsFound: txtCLead_NoResultsFound,
      txtCLead_ConversioneManuale: txtCLead_ConversioneManuale,
      txtCLead_Indietro: txtCLead_Indietro,
      txtCLead_CreareOpty: txtCLead_CreareOpty,
      txtCLead_AvviaConversione: txtCLead_AvviaConversione,
      txtCLead_Avanti: txtCLead_Avanti,
      txtCAccount_Denominazione: txtCAccount_Denominazione,
      txtCAccount_PartitaIVA: txtCAccount_PartitaIVA,
      txtCAccount_CodiceFiscale: txtCAccount_CodiceFiscale,
      txtCAccount_FormaGiuridica: txtCAccount_FormaGiuridica,
      txtCAccount_CittaLegale: txtCAccount_CittaLegale,
      txtCAccount_ProvinciaLegale: txtCAccount_ProvinciaLegale,
      txtCAccount_IndirizzoLegale: txtCAccount_IndirizzoLegale,
      txtCAccount_stato_attivita: txtCAccount_stato_attivita,
      txtCAccount_Sto_ottenendo_le_informazioni_da_Innolva: txtCAccount_Sto_ottenendo_le_informazioni_da_Innolva,
      txtCAccount_Sto_cercando_informazioni_su_CRM: txtCAccount_Sto_cercando_informazioni_su_CRM,
      txtCAccount_servizio_non_garantito: txtCAccount_servizio_non_garantito,
      txtCAccount_dati_incompleti: txtCAccount_dati_incompleti,
      txtCLead_conversione_effettuata: txtCLead_conversione_effettuata,
      txtCLead_errore_conversione: txtCLead_errore_conversione,
      txtCAccount_nessun_riscontro_piva_e_cf: txtCAccount_nessun_riscontro_piva_e_cf,
      txtCLead_aggiornamento_lead: txtCLead_aggiornamento_lead,
      txtCLead_sto_facendo_la_conversione: txtCLead_sto_facendo_la_conversione
    }
    // @api recordId;
    _recordId;

    @api title = txtCLead_Load;

    @track LrecordId;
    @track spinner = true;
    @track loaded = false;
    @track disabledinput = false;
    @track disablebutton = true;
    @track AccountDataInsert = false;
    @track requirecf = true;
    @track InserimentoManuale = false;
    @track RequiredManuale = true;

    // Innolva CallOut Modale
    @track WebDataInsert = false;
    @track DenominazioneWebData = company_lead;
    @track WebDataTable = false;
    @track selectedRows = [];
    @track hasData = false;
    @track tableData = [];

    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track sortedBy;

    @track isSaveDisabled = true;
    @track EsteroData = 'IT';
    @track EsteroDataInsert = false;
    @track estero = false;
    @track CreaOpportunityData = false;
    // Fine

    // FORM Inputs
    //@track test__c = TEST_FIELD;

    @track Forma_giuridica__c = FORMA_GIURIDICA_LEAD;
    @track clienteEstero = CLIENTE_ESTERO;
    @track CCIAA_CMK__c = CCIAA_LEAD;
    @track CCIAA_REA_Innolva__c = CCIAA_REA_LEAD;
    @track Partiva_Iva__c = PartivaIva_LEAD;
    @track Street = Street_LEAD;
    @track Country = Country_LEAD;
    @track City = City_LEAD;
    @track State = State_LEAD;
    @track PostalCode = PostalCode_LEAD;
    @track Codice_Fiscale__c = Codice_Fiscale_LEAD;
    @track Natura_Giuridica_Innolva__c = Natura_Giuridica_Innolva_LEAD;
    @track GruppoIvaField = GruppoIva_Field;
    @track DenominazioneGruppoIvaField = DenominazioneGruppoIva_Field;

    @track denosociale__c = DENOSOCIALE_FIELD;
    @track AName = NAME_FIELD;

    // Input values DATA
    @track RagioneSocialeDenominazioneData = '';
    @track CCIAAData = '';
    @track READata = '';
    @track CodiceFiscaleData = '';
    @track PartitaIVAData = '';
    @track NaturaGiuridicaData = '';
    @track FormaGiuridicaData = '';
    @track ViaIndirizzoSedeLegaleData = '';
    @track PaeseIndirizzoSedeLegaleData = '';
    @track CittaIndirizzoSedeLegaleData = '';
    @track CAPIndirizzoSedeLegaleData = '';
    @track ProvinciaIndirizzoSedeLegaleData = '';
    @track GruppoIvaData = '';
    @track DenominazioneGruppoIvaData = '';
    @track erroreMonitoraggioData = false;
    @track censimentoManualeData = false;
    // end

    @track AccountName = false;
    @track AccountNameData = '';

    @track showNewButton = false;


    @track isModalOpen = false;

    LeadData;
    WebAccounts;
    WebAccount;
    AccountData = null;

    Societa;
    SocietaUser;
    @wire(getRecord, { recordId: UserId, fields: [Soc, SocUser]}) 
    userDetails({data}) {
        if (data) {
            this.Societa = data.fields.Societa__c.value;
            this.SocietaUser = data.fields.Societ_di_riferimento__c.value;
        } 
    }

    

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


    @api get recordId(){
      return this._recordId;
    }

    set recordId(v){
      this._recordId = v;
      this.init();
    }

    //connectedCallback(){
    init(){
      console.log('@@@ this.recordId ' , this.recordId);
      console.log('@@@ this.loaded ' , this.loaded);
      if(this.recordId && !this.loaded){
        this.loaded = true;
        this.spinner = true;

        this.AccountDataInsert = false;
        this.WebDataInsert = false;
        this.WebDataTable = false;

      console.log('connectedCallback');
      [...this.template.querySelectorAll('input[type=checkbox]')].reduce((inputField) => { 
        inputField.checked = false;
      }, true);
      //alert('LEAD ID: '+this.recordId);
      //this.showToastMessage("Il Server non risponde, riprovare più tardi", "error");
      //this.dispatchEvent(new CloseActionScreenEvent());
      // Carico i dati del Lead
      this.showToastMessage(this.label.txtCAccount_Sto_cercando_informazioni_su_CRM, "neutral");
      TXT_RetriveDataLead({lid: this.recordId})
      .then(result => {
        console.log(JSON.stringify(result));
        this.LeadData = result;
        if(((this.LeadData.Forma_giuridica__c != 'PERSONA FISICA')) && (this.LeadData.Partiva_Iva__c== null || this.LeadData.Partiva_Iva__c.length <= 1) && (this.LeadData.Codice_Fiscale__c== null || this.LeadData.Codice_Fiscale__c.length <= 1)){
          //Innolva web necessaria, chiedo campo denominazione e mostro result come table di possibili corrispondenze
          this.AccountDataInsert = false;
          this.WebDataInsert = true;
          this.title = txtCLead_cfpiva_pg;
          this.InserimentoManuale = false;
          this.RequiredManuale = true;

          this.DenominazioneWebData = this.LeadData.Company;
          this.disablebutton = false; // attivo il cerca visto che riempio denominazione con company

          this.FormaGiuridicaData = this.LeadData.Forma_giuridica__c;
          this.spinner = false;
          this.requirecf = false;
        }else{

          this.FormaGiuridicaData = this.LeadData.Forma_giuridica__c;
          this.LrecordId = this.recordId;
          console.log('@@@ first retrieve');
          this.retriveDataCRM(true);
        }
				setTimeout(() => {
					this.isModalOpen = true;
				}, 1500);
      })
      .catch(error => {
          this.showToastMessage("Si è verificato un errore", "error");
          console.error('TXT_RetriveDataLead error: ' + JSON.stringify(error));
      });
      }
    }

    retriveDataCRM(innolva){
      this.AccountDataInsert = true;
      this.WebDataInsert = false;
      this.showToastMessage(this.label.txtCAccount_Sto_cercando_informazioni_su_CRM, "neutral");
      // Cerco e carico i dati dell'Account
      TXT_RecapInfo({lid: this.LrecordId, WA: this.WebAccount, SocietaUser : this.SocietaUser}).then(result => {
        console.log(JSON.stringify(result));
        this.disablebutton = true;

        if(result!==null){ // Account Esiste - Mostro i dati dell'account
          
          //--- inseire if per innolva-----------------
          this.title = txtCLead_recap_acc;
          if(this.Societa === 'Innolva')
          {
            console.log('dentro Innolva --- ', this.Societa);
              if(result.INN_societa__c === 'Innolva' ) this.title = txtCLead_recap_acc;
              if(result.INN_societa__c === '' || result.INN_societa__c === undefined) this.title = txtCLead_recap_info;
          }
          if(this.Societa === 'ReValuta')
          {
            console.log('dentro ReValuta --- ', this.Societa);
              if(result.REV_societa__c === 'ReValuta' ) this.title = txtCLead_recap_acc;
              if(result.REV_societa__c === '' || result.REV_societa__c === undefined) this.title = txtCLead_recap_info;
          }
          else if(this.Societa != 'Innolva' && this.Societa != 'ReValuta')
          {
            console.log('dentro altro --- ', this.Societa);
              if(result.Societa_su_CTM__c !== undefined) this.title = txtCLead_recap_acc;
              if(result.Societa_su_CTM__c === undefined && result.INN_societa__c !== undefined && result.REV_societa__c !== undefined) this.title = txtCLead_recap_info;
          }
          
          //this.LeadTemporaneo(result);
          this.WebAccount = result;
          this.disabledinput = true;
          //this.disabledinput = false;
          this.AccountNameData = result.Name;
          this.AccountName = true;

          this.AccountData = result.Id;
          this.RagioneSocialeDenominazioneData = result.denosociale__c;

          if(this.WebAccount != null && this.WebAccount.Name != null){
            this.AccountNameData = this.WebAccount.Name;
          }
          
          // metto i dati account come base
          //this.AssegnaInput(result);

          this.CodiceFiscaleData = this.WebAccount.Codice_fiscale__c;
          this.PartitaIVAData = this.WebAccount.Partita_iva__c;
          //this.NaturaGiuridicaData = this.WebAccount.Natura_Giuridica__c;
          this.FormaGiuridicaData = this.WebAccount.Forma_giuridica__c;
          
          this.GruppoIvaData = this.WebAccount.TXT_Gruppo_IVA__c;
          this.DenominazioneGruppoIvaData = this.WebAccount.TXT_Denominazione_Gruppo_IVA__c;
          this.CCIAAData = this.WebAccount.CCIAA_CMK__c;
          this.READata = this.WebAccount.CCIAA_REA__c;

          this.ViaIndirizzoSedeLegaleData = this.WebAccount.BillingStreet;
          this.PaeseIndirizzoSedeLegaleData = this.WebAccount.BillingCountry;
          this.CittaIndirizzoSedeLegaleData = this.WebAccount.BillingCity;
          this.CAPIndirizzoSedeLegaleData = this.WebAccount.BillingPostalCode;
          this.ProvinciaIndirizzoSedeLegaleData = this.WebAccount.BillingState;
          
          //this.LeadTemporaneo(this.WebAccount);
          //this.AssegnaInput(this.WebAccount);
          
          this.LeadData.Censimento_Manuale__c = false;
        }else{ // Account Non Esiste - devo mostrare i campi obbligatori per la creazione dell'account
          
          this.title = txtCLead_recap_info;
          //this.disabledinput = false;
          this.AccountData = null;
          this.AccountName = true;

          this.FormaGiuridicaData = this.LeadData.Forma_giuridica__c;

          if(this.WebAccount != null && this.WebAccount.Name != null){
            this.AccountNameData = this.WebAccount.Name;
          }

          if(this.LeadData.Forma_giuridica__c != 'PERSONA FISICA' && innolva===true){
            this.requirecf = false;

            // Verifico se è un Lead Estero
            if(this.Country!='ITALIA' && this.Country != null && this.Country != undefined){
              this.EsteroDataInsert = true;
            }else{ 
              this.EsteroData = 'IT';
            }
            // fine
            
            if(this.LeadData.Partiva_Iva__c != null && this.LeadData.Partiva_Iva__c.length>3){
              console.log('@@@ second retrieve');
                this.Type1Executecall(this.LeadData.Partiva_Iva__c);
            }else{
              console.log('@@@ second retrieve');
                this.Type1Executecall(this.LeadData.Codice_Fiscale__c);
            }
            
            

          }else if( (this.LeadData.Forma_giuridica__c == 'PERSONA FISICA' || this.LeadData.Forma_giuridica__c == 'IMPRESA INDIVIDUALE' )&& innolva===true){
            this.LeadData.Censimento_Manuale__c = false;
            this.AccountNameData = this.LeadData.Company;
            this.AssegnaInput(this.LeadData);
            this.disabledinput = true;
            //this.Type1Executecall(this.LeadData.Codice_Fiscale__c);

          }

        }
        this.spinner = false;
      })
      .catch(error => {
          this.showToastMessage("Si è verificato un errore", "error");
          console.error('error retrivecrm: ' + JSON.stringify(error));
      });
    }

    handlereset(){
      this.showNewButton = false;
      this.hasData = false;
      this.WebDataInsert = true;
    }

    handleManuale(){
      this.WebDataInsert = false;
      this.title = txtCLead_manuale;
      this.InserimentoManuale = true;
      this.RequiredManuale = false;
      this.AccountDataInsert = true;
      
      this.AccountName = true;
      this.AccountNameData = this.LeadData.Company;

      this.LeadData.Censimento_Manuale__c = true;
      this.disabledinput = false;
      this.AssegnaInput(this.LeadData);
    }

    handleConversione(){
      console.log('Avvio Conversione');
      
      const isInputsCorrect = [...this.template.querySelectorAll('lightning-input-field')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.reportValidity();
            }, true);
        if (isInputsCorrect) {
          this.spinner = true;
          //this.disabledinput = false;
          console.log('Forma_giuridica: '+this.FormaGiuridicaData);
          console.log('Natura_Giuridica: '+this.NaturaGiuridicaData);
          console.log('CCIAA_CMK: '+this.CCIAAData);
          console.log('CCIAA_REA: '+this.READata);
          console.log('denosociale: '+this.RagioneSocialeDenominazioneData);
          console.log('Partita_iva: '+this.PartitaIVAData);
          console.log('Codice_fiscale: '+this.CodiceFiscaleData);
          console.log('Via_Sede_Legale: '+this.ViaIndirizzoSedeLegaleData);
          console.log('Provincia_Sede_Legale: '+this.ProvinciaIndirizzoSedeLegaleData);
          console.log('CAP_Sede_Legale: '+this.CAPIndirizzoSedeLegaleData);
          console.log('Paese_Sede_Legale: '+this.PaeseIndirizzoSedeLegaleData);
          console.log('Citta_Sede_Legale: '+this.CittaIndirizzoSedeLegaleData);
          console.log('Opportnunitad: '+this.CreaOpportunityData);
          this.showToastMessage(this.label.txtCLead_aggiornamento_lead, "neutral");

          // UPDATE LEAD RECORDID con i dati
          console.log('aaaaaaaaaaaaa quanto è manuale!!! ----- ',this.LeadData.Censimento_Manuale__c);
          console.log('bbbbbbbbbbbbbb troppo manuale!!! ------ ',this.censimentoManualeData);

          if(this.WebAccount==null){
            this.WebAccount = {
              Name: this.AccountNameData,
              CCIAA_CMK__c:  this.CCIAAData,
              CCIAA_REA__c:  this.READata,
              Forma_giuridica__c:  this.FormaGiuridicaData,
              Partita_iva__c:  this.PartitaIVAData,
              Codice_fiscale__c:  this.CodiceFiscaleData,
              BillingStreet:  this.ViaIndirizzoSedeLegaleData,
              BillingState:  this.ProvinciaIndirizzoSedeLegaleData,
              BillingPostalCode:  this.CAPIndirizzoSedeLegaleData,
              BillingCountry:  this.PaeseIndirizzoSedeLegaleData,
              BillingCity: this.CittaIndirizzoSedeLegaleData,
              Fatturato__c: this.FatturatoData,
              Dipendenti__c: this.DipendentiData,
              TXT_Gruppo_IVA__c: this.GruppoIvaData,
              TXT_Denominazione_Gruppo_IVA__c: this.DenominazioneGruppoIvaData,
              Censimento_Manuale__c: this.LeadData.Censimento_Manuale__c
            };
          }
          
          this.WebAccount.Errore_Monitoraggio__c = this.erroreMonitoraggioData;
          
          TXT_UpdateLead({lid: this.recordId, WA: this.WebAccount, Fake: false })
          .then(result => {
            this.showToastMessage(this.label.txtCLead_sto_facendo_la_conversione, "neutral");
              console.log('TXT_UpdateLead True' + JSON.stringify(result));
              if(this.LeadData.Censimento_Manuale__c!=true && this.LeadData.Censimento_Manuale__c!=false){
                this.LeadData.Censimento_Manuale__c = false;
              }

              // SM - FIX
              TXT_UpdateLeadBeforeConversion({ Lid: this.recordId, Id: this.AccountData, ACName: this.AccountNameData,
                Forma_giuridica: this.FormaGiuridicaData, 
                Natura_Giuridica: this.NaturaGiuridicaData,
                CCIAA_CMK: this.CCIAAData,
                CCIAA_REA: this.READata,
                denosociale: this.RagioneSocialeDenominazioneData,
                Partita_iva: this.PartitaIVAData,
                Codice_fiscale: this.CodiceFiscaleData,
                Via_Sede_Legale: this.ViaIndirizzoSedeLegaleData,
                Provincia_Sede_Legale: this.ProvinciaIndirizzoSedeLegaleData,
                CAP_Sede_Legale: this.CAPIndirizzoSedeLegaleData,
                Paese_Sede_Legale: this.PaeseIndirizzoSedeLegaleData,
                Citta_Sede_Legale: this.CittaIndirizzoSedeLegaleData,
                Censimento_Manuale: this.LeadData.Censimento_Manuale__c,
                Fatturato: this.LeadData.Fatturato_Warrant__c,
                Dipendenti: this.LeadData.Dipendenti__c,
                GruppoIVA: this.LeadData.TXT_Gruppo_IVA__c ?? this.GruppoIvaData,
                DenominazioneGruppoIVA: this.LeadData.TXT_Denominazione_Gruppo_IVA__c ?? this.DenominazioneGruppoIvaData,
                convertStatus: 'Convertito',
                Opportnunity: this.CreaOpportunityData,
                clienteEstero: this.estero != undefined ? this.estero : false}).then(resultUpdateLead => {

                  console.log('@@@ resultUpdate ' , resultUpdateLead + ' --- ' + this.recordId);
                  
                  // SM - FIX -- OLD Version without before update
                  TXT_ProcessoDiConversione({ Lid: this.recordId, Id: this.AccountData, ACName: this.AccountNameData,
                    Forma_giuridica: this.FormaGiuridicaData, 
                    Natura_Giuridica: this.NaturaGiuridicaData,
                    CCIAA_CMK: this.CCIAAData,
                    CCIAA_REA: this.READata,
                    denosociale: this.RagioneSocialeDenominazioneData,
                    Partita_iva: this.PartitaIVAData,
                    Codice_fiscale: this.CodiceFiscaleData,
                    Via_Sede_Legale: this.ViaIndirizzoSedeLegaleData,
                    Provincia_Sede_Legale: this.ProvinciaIndirizzoSedeLegaleData,
                    CAP_Sede_Legale: this.CAPIndirizzoSedeLegaleData,
                    Paese_Sede_Legale: this.PaeseIndirizzoSedeLegaleData,
                    Citta_Sede_Legale: this.CittaIndirizzoSedeLegaleData,
                    Censimento_Manuale: this.LeadData.Censimento_Manuale__c,
                    Fatturato: this.LeadData.Fatturato_Warrant__c,
                    Dipendenti: this.LeadData.Dipendenti__c,
                    EmailAziendale: this.LeadData.Email_Aziendale_Innolva__c,
                    convertStatus: 'Convertito',
                    Opportnunity: this.CreaOpportunityData
                  })
                    .then(result => {

                      // this.showToastMessage("Conversione Effettuata", "success");
                      // this.spinner = true;
                      // console.log('success: ' + JSON.stringify(result));
                      // this.navigateToAccountRecordPage(result.Id);

                      handleCTM({ accountId: result.Id, leadId: this.recordId }).then(res => {
                        console.log('@@@ res ' , res);
                        this.showToastMessage(this.label.txtCLead_conversione_effettuata, "success");
                        this.spinner = true;
                        console.log('success: ' + JSON.stringify(result));
                        // Utilizzato per chiudere i tab delle app console
                        this.dispatchEvent(
                          new CustomEvent('cstmcloseconsoletab')
                        )

                        this.navigateToAccountRecordPage(result.Id);
                      }).catch(err => {
                        console.log('@@@ err ' , err);
                        this.handleErrorMessage(err);
                      });
                    })
                    .catch(error => {
                        this.handleErrorMessage(error);
                        // this.spinner = false;
                        // console.error('error: ' + JSON.stringify(error));
                        // var errorMessageToDisplay = ''
                        // var pageErrors = error.body.pageErrors;
                        // if(pageErrors && pageErrors.length > 0){
                        //     for(let i=0; i < pageErrors.length; i++){
                        //         errorMessageToDisplay += pageErrors[i].statusCode + ' '+ pageErrors[i].message.split(" For help")[0]+" ";
                        //     }
                        // }
    
                        // let fieldErrors = error.body.fieldErrors;
                
                        // for(var fieldName in fieldErrors){
                        //     let errorList = fieldErrors[fieldName];
                        //     for(var i=0; i < errorList.length; i++){
                        //         errorMessageToDisplay += errorList[i].statusCode + ' ' + fieldName + ' ' + errorList[i].message + ' ';
                        //     }
                        // }
                        
                        // this.showToastMessage("Si è verificato un errore durante la conversione: "+errorMessageToDisplay, "error");
    
                        
                    });
                }).catch(err => {
                  // console.log('@@@ error updating lead ' , err);
                  this.handleErrorMessage(err);
                })
              
          })
          .catch(error => {
              console.error('TXT_UpdateLead error: ' + JSON.stringify(error));
              this.handleErrorMessage(error);
          });
          // FINE
          
        }
      
  }

  handleErrorMessage(error){
    this.spinner = false;
    console.error('error: ' + JSON.stringify(error));
    var errorMessageToDisplay = ''
    var pageErrors = error.body.pageErrors;
    if(pageErrors && pageErrors.length > 0){
        for(let i=0; i < pageErrors.length; i++){
            errorMessageToDisplay += pageErrors[i].statusCode + ' '+ pageErrors[i].message.split(" For help")[0]+" ";
        }
    }

    let fieldErrors = error.body.fieldErrors;

    for(var fieldName in fieldErrors){
        let errorList = fieldErrors[fieldName];
        for(var i=0; i < errorList.length; i++){
            errorMessageToDisplay += errorList[i].statusCode + ' ' + fieldName + ' ' + errorList[i].message + ' ';
        }
    }
    
    this.showToastMessage(this.label.txtCLead_errore_conversione + " " + errorMessageToDisplay, "error");
  }

  /*
  sortBy(field, reverse, primer) {
      const key = primer
          ? function (x) {
                return primer(x[field]);
            }
          : function (x) {
                return x[field];
            };

      return function (a, b) {
          a = key(a);
          b = key(b);
          return reverse * ((a > b) - (b > a));
      };
  }

  onHandleSort(event) {
      const { fieldName: sortedBy, sortDirection } = event.detail;
      const cloneData = [...this.tabledata];

      cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
      this.tabledata = cloneData;
      this.sortDirection = sortDirection;
      this.sortedBy = sortedBy;
  }
*/

  handleCercaWeb(){
    const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
    .reduce((validSoFar, inputField) => {
        inputField.checkValidity();
        return validSoFar && inputField.checkValidity();
    }, true);
    if (isInputsCorrect) {
      
      this.requirecf = false;
      console.log('Avvio Ricerca');
      this.spinner = true;
      // ricevo list record Account e lo metto nel table
      this.WebDataTable = true;
      
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
      //BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
      this.showToastMessage(this.label.txtCLead_SearchInnolva, "neutral");
      executeCall({ searchType: 1, searchedParameter: this.DenominazioneWebData, siglaEstera: this.EsteroData })
      .then(result => {
          console.log('executeCall result ' + JSON.stringify(result));
          if(result.length>0 && result!=null){
            for (var i = 0; i < result.length; i++) {

              result[i].crm = false;

              if(result[i].Name.indexOf('#XML', 1) !=-1){
                result[i].crm = true;
                result[i].Censimento_Manuale__c = false;
                result[i].Name = result[i].Name.replaceAll(' #XML', '');
              }

              if(result[i].Censimento_Manuale__c == true){
                result[i].crm = true;
              }

            }

            this.tableData = result;
            /*
            let reverse = sortDirection !== 'asc';
            let data_clone = JSON.parse(JSON.stringify(this.tableData));
            this.tabledata = data_clone.sort(this.sortBy('Censimento_Manuale__c', reverse));
            */
            this.WebAccounts = result;
            if(result.length > 0){
                this.hasData = true;
            }
            this.disabledinput = true;
            this.spinner = false;
            this.showNewButton = true;
            
          }else{
            this.showToastMessage(this.label.txtCLead_ServerNoResult, "warning");
            this.showNewButton = true;
            this.hasData = false;
            this.WebDataInsert = true;
            //this.dispatchEvent(new CloseActionScreenEvent());
            this.spinner = false;
          }
      })
      .catch(error => {
          console.error('executeCall2 error: ' + JSON.stringify(error));
          this.showToastMessage("Il Server non risponde, riprovare più tardi", "error");
          this.dispatchEvent(new CloseActionScreenEvent());
          this.spinner = false;
      });

    }
    
  }


  handleRefRowSelection(event) {
    this.selectedRows = event.detail.selectedRows;
    if(this.selectedRows.length >= 1){
      this.isSaveDisabled = false;
    }else{
      this.isSaveDisabled = true;
    }
  }

  handleWebPGData(){
    if(this.selectedRows.length >= 1){
      this.title = txtCLead_recap_info;

      for (var i = 0; i < this.WebAccounts.length; i++) {
          if(this.selectedRows[0].Censimento_Manuale__c===true){
            this.WebDataInsert = false;
            this.title = txtCLead_recap_acc;
            this.AccountDataInsert = true;
            
            this.AccountName = true;
            this.AccountNameData = this.LeadData.Company;
            
            this.LeadData.Censimento_Manuale__c = false;
            //this.AssegnaInput(this.LeadData);

          }else if(this.WebAccounts[i].Name==this.selectedRows[0].Name){
            
            this.WebAccount = this.WebAccounts[i];
            this.WebAccount.Company = this.WebAccount.Name;
            this.LeadTemporaneo(this.WebAccount);
            console.log('WebAccount ' + JSON.stringify(this.WebAccount));
            //SM - FIX LOG
            this.WebAccount.attributes = undefined;
            
            this.spinner = true;

            if (!this.WebAccount.crm) {
              //Richiedo REA
              this.showToastMessage(this.label.txtCAccount_Sto_ottenendo_le_informazioni_da_Innolva, "neutral");
              getProdottoPG({ acct: this.WebAccount })
                .then(result => {
                  console.log('getProdottoPG result ' + JSON.stringify(result));
                  if (result != '' && result != null && result.Name != 'error') {
                    //SM - FIX LOG
                    result.attributes = undefined;
                    this.erroreMonitoraggioData = result.Errore_Monitoraggio__c;
                    this.WebAccount = result;
                    // UPDATE LEAD RECORDID con i dati WebAcc
                    TXT_UpdateLead({ lid: this.recordId, WA: this.WebAccount, Fake: true })
                      .then(results => {
                        console.log('TXT_UpdateLead Fake' + JSON.stringify(results));

                        this.LrecordId = null;
                        this.WebDataInsert = true;
                        
                        this.retriveDataCRM();
                        this.LeadTemporaneo(result);
                        this.AssegnaInput(result);
                      })
                      .catch(error => {
                        console.error('TXT_UpdateLead error: ' + JSON.stringify(error));
                      });
                    // FINE

                  } else {
                    this.erroreMonitoraggioData = this.estero !== undefined && this.estero === false && (this.WebAccount.CCIAA_CMK__c !== null && this.WebAccount.CCIAA_CMK__c !== undefined && this.WebAccount.CCIAA_CMK__c !== '') &&
                      (this.WebAccount.CCIAA_REA__c !== null && this.WebAccount.CCIAA_REA__c !== undefined && this.WebAccount.CCIAA_REA__c !== '');
                    //SM - FIX
                    const d = new Date();
                    if (d.getHours() >= 21 || d.getHours() < 8) {
                      this.showToastMessage(this.label.txtCAccount_servizio_non_garantito, "warning");
                    } else {
                      this.showToastMessage(this.label.txtCAccount_dati_incompleti, "warning");
                    }

                    if (this.WebAccount.length < 1) {
                      // this.showToastMessage("Il Server non risponde, riprovare più tardi", "error");
                      // this.dispatchEvent(new CloseActionScreenEvent());
                    } else {
                      this.AccountDataInsert = true;
                      this.retriveDataCRM();
                      this.LeadTemporaneo(this.WebAccount);
                      this.AssegnaInput(this.WebAccount);
                      this.disabledinput = true;
                    }
                    this.spinner = false;
                  }
                  
                })
                .catch(error => {
                  console.error('getProdottoPG2 error: ' + JSON.stringify(error));
                  // SM - FIX
                  const d = new Date();
                  if (d.getHours() >= 21 || d.getHours() < 8) {
                    this.showToastMessage(this.label.txtCAccount_servizio_non_garantito, "warning");
                  } else {
                    this.showToastMessage(this.label.txtCAccount_dati_incompleti, "warning");
                  }
                });
            } else {
              TXT_UpdateLead({ lid: this.recordId, WA: this.WebAccount, Fake: true })
                .then(results => {
                  console.log('TXT_UpdateLead Fake' + JSON.stringify(results));

                  this.LrecordId = null;
                  this.WebDataInsert = true;
                  
                  this.retriveDataCRM();
                  this.LeadTemporaneo(results);
                  this.AssegnaInput(results);
                })
                .catch(error => {
                  console.error('TXT_UpdateLead error: ' + JSON.stringify(error));
                });
            }
            
            

            
            break;
          }
      }
    }else{
        this.showToastMessage("Seleziona una Persona Giuridica", "warning");
    }
}


  navigateToAccountRecordPage(accid) {
    try{
      console.log('View Account Record ID: ' + accid);
        this[NavigationMixin.Navigate]({
              type: 'standard__recordPage',
              attributes: {
                  recordId: accid,
                  actionName: 'view'
              },
          });
    }catch(error){
        console.error(error);
        this.showToastMessage("Non è stato possibile aprire la pagina dell'Account", "error");
    }      
  }


  handlefieldchange(event){
    console.log('INPUT '+event.target.name);
    this[event.target.name] = event.target.value;
     console.log('INPUT '+event.target.name+': '+ event.target.value);
    
    if(event.target.name == 'EsteroDataInsert'){
        console.log('@@@ checked ' , event.target.checked);
        this.estero = event.target.checked !== undefined ? event.target.checked : event.target.value;
    }

    if(event.target.tagName=='lightning-input-field'){

        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input-field')]
        .reduce((validSoFar, inputField) => {
           return validSoFar && inputField.reportValidity();
        }, true);

        if (isInputsCorrect) {  
          this.disablebutton = false;
        }else{
          this.disablebutton = true;
        }

    }else{
        this.disablebutton = false;
        if(event.target.type=='checkbox'){
          this[event.target.name] = event.target.checked;
          console.log('INPUT '+event.target.name+': '+ this[event.target.name]);
        }
    }
  }
  
  async handleCache() {
    var success = false;
    try {
      while (!success) {
        let resultCache = await handleSessionCacheArricchimento({ acct: this.WebAccount })
        console.log('@@@ resultCache ', resultCache);
        if (resultCache.success && !resultCache.retry) {
          success = true;
        }
      }
    } catch (err) {
      console.log('@@@ err ', err);
    }
    
    return success;
  }
  
  Type1Executecall(CFPI){

    executeCall({ searchType: 2, searchedParameter: CFPI, siglaEstera: this.EsteroData })
    .then(result => {
        console.log('executeCall result ' + JSON.stringify(result));
        if(result.length>0 && result!=null){
          //SM - Fix
          for (var i = 0; i < result.length; i++) {

            result[i].crm = false;

            if(result[i].Name.indexOf('#XML', 1) !=-1){
              result[i].crm = true;
              result[i].Censimento_Manuale__c = false;
              result[i].Name = result[i].Name.replaceAll(' #XML', '');
            }

            if(result[i].Censimento_Manuale__c == true){
              result[i].crm = true;
            }

          }

          this.WebAccounts = result;
          this.WebAccount = this.WebAccounts[0];
          this.LeadTemporaneo(this.WebAccount);
          console.log('WebAccount ' + JSON.stringify(this.WebAccount));
          //SM - FIX LOG
          this.WebAccount.attributes = undefined
          this.spinner = true;
          //SM - Fix LOG 2
          this.handleCache().then(cache => {
            console.log('@@@ cache ', cache);
            //Richiedo REA
            this.showToastMessage(this.label.txtCAccount_Sto_ottenendo_le_informazioni_da_Innolva, "neutral");
            getProdottoPG({ acct: this.WebAccount })
            .then(result => {
                console.log('getProdottoPG result ' + JSON.stringify(result));
                if(result != '' && result!=null && result.Name!='error'){
                  // SM - FIX LOG
                  result.attributes = undefined;
                  this.WebAccount = result;
                  this.erroreMonitoraggioData = result.Errore_Monitoraggio__c;
                  // UPDATE LEAD RECORDID con i dati WebAcc
                  TXT_UpdateLead({lid: this.recordId, WA: this.WebAccount, Fake: true })
                  .then(results => {
                      console.log('TXT_UpdateLead Fake' + JSON.stringify(results));
                      this.LrecordId = null;
                      console.log('@@@ third retrive');
                      this.retriveDataCRM();
                      this.LeadTemporaneo(result);
                      this.AssegnaInput(result);
                      this.disabledinput = true;
                  })
                  .catch(error => {
                      console.error('TXT_UpdateLead error: ' + JSON.stringify(error));
                  });
                  // FINE

                }else{
                  // SM - FIX
                  this.erroreMonitoraggioData = this.estero !== undefined && this.estero === false && (this.WebAccount.CCIAA_CMK__c !== null && this.WebAccount.CCIAA_CMK__c !== undefined && this.WebAccount.CCIAA_CMK__c !== '') &&
                      (this.WebAccount.CCIAA_REA__c !== null && this.WebAccount.CCIAA_REA__c !== undefined && this.WebAccount.CCIAA_REA__c !== '');

                  const d = new Date();
                  if(d.getHours() >= 21 || d.getHours() < 8){
                      this.showToastMessage(this.label.txtCAccount_servizio_non_garantito, "warning");
                  } else {
                      this.showToastMessage(this.label.txtCAccount_dati_incompleti, "warning");
                  }
                  
                  if(this.WebAccount.length<1){
                    // this.showToastMessage("Il Server non risponde, riprovare più tardi", "error");
                    // this.dispatchEvent(new CloseActionScreenEvent());
                  }else{
                    this.AccountDataInsert = true;
                    this.retriveDataCRM();
                    this.LeadTemporaneo(this.WebAccount);
                    this.AssegnaInput(this.WebAccount);
                    this.disabledinput = true;
                  }
                  this.spinner = false;
                }
                
            })
            .catch(error => {
                console.error('getProdottoPG1 error: ' + JSON.stringify(error));
            });
          });
          
        }else{
          this.showToastMessage(this.label.txtCAccount_nessun_riscontro_piva_e_cf, "warning");
          //this.dispatchEvent(new CloseActionScreenEvent());
          this.handleManuale();
          this.spinner = false;
        }
        
    }).catch(error => {
        console.error('executeCall1 error: ' + JSON.stringify(error));
        this.showToastMessage(this.label.txtCAccount_nessun_riscontro_piva_e_cf, "warning");
        this.handleManuale();
        //this.dispatchEvent(new CloseActionScreenEvent());
        this.spinner = false;
    });

  }

  AssegnaInput(Data){
    /*
    for (var k in Data) {
      if(Data[k].length>=2 && k !='Id'){
        console.log('K: '+k+' Data: '+Data[k]);
        if(this.template.querySelector('[data-name="'+k+'"]')!=null){
          this.template.querySelector('[data-name="'+k+'"]').value = Data[k];
        }
      }
    }*/
    console.log('Ass.: '+JSON.stringify(Data));
    if(Data.Codice_Fiscale__c!=null){
      this.CodiceFiscaleData = Data.Codice_Fiscale__c;
    }
    
    if (Data.Codice_fiscale__c != null) {
      this.CodiceFiscaleData = Data.Codice_fiscale__c;
    }
    
    if(Data.Partiva_Iva__c!=null){
      this.PartitaIVAData = Data.Partiva_Iva__c;
    }

    if(Data.Partita_iva__c!=null){
      this.PartitaIVAData = Data.Partita_iva__c;
    }

    if(Data.Forma_giuridica__c!=null){
      this.FormaGiuridicaData = Data.Forma_giuridica__c;
    }
    
    if(Data.CCIAA_CMK__c!=null){
      this.CCIAAData = Data.CCIAA_CMK__c;
    }

    if(Data.CCIAA_REA_Innolva__c!=null){
      this.READata = Data.CCIAA_REA_Innolva__c;
    }

    if(Data.CCIAA_REA__c!=null){
      this.READata = Data.CCIAA_REA__c;
    }

    if(Data.Via_Sede_Legale__c!=null){
      this.ViaIndirizzoSedeLegaleData = Data.Street;
    }

    if(Data.Paese_Sede_Legale__c!=null){
      this.PaeseIndirizzoSedeLegaleData = Data.Country;
    }

    if(Data.Citta_Sede_Legale__c!=null){
      this.CittaIndirizzoSedeLegaleData = Data.City;
    }

    if(Data.CAP_Sede_Legale__c!=null){
      this.CAPIndirizzoSedeLegaleData = Data.PostalCode;
    }

    if(Data.Provincia_Sede_Legale__c!=null){
      this.ProvinciaIndirizzoSedeLegaleData = Data.State;
    }


    if(Data.Street!=null){
      this.ViaIndirizzoSedeLegaleData = Data.Street;
    }

    if(Data.Country!=null){
      this.PaeseIndirizzoSedeLegaleData = Data.Country;
    }

    if(Data.City!=null){
      this.CittaIndirizzoSedeLegaleData = Data.City;
    }

    if(Data.PostalCode!=null){
      this.CAPIndirizzoSedeLegaleData = Data.PostalCode;
    }

    if(Data.State!=null){
      this.ProvinciaIndirizzoSedeLegaleData = Data.State;
    }

    if(Data.BillingStreet!=null){
      this.ViaIndirizzoSedeLegaleData = Data.BillingStreet;
    }

    if(Data.BillingCountry!=null){
      this.PaeseIndirizzoSedeLegaleData = Data.BillingCountry;
    }

    if(Data.BillingCity!=null){
      this.CittaIndirizzoSedeLegaleData = Data.BillingCity;
    }

    if(Data.BillingPostalCode!=null){
      console.log('BillingPostalCode: '+Data.BillingPostalCode);
      this.CAPIndirizzoSedeLegaleData = Data.BillingPostalCode;
      console.log('CAPIndirizzoSedeLegaleData: '+this.CAPIndirizzoSedeLegaleData);
    }

    if(Data.BillingState!=null){
      this.ProvinciaIndirizzoSedeLegaleData = Data.BillingState;
    }

    if(Data.Dipendenti__c!=null){
      this.DipendentiData = Data.Dipendenti__c;
    }

    if(Data.Fatturato__c!=null){
      this.FatturatoData = Data.Fatturato__c;
    }
    
    if (Data.TXT_Gruppo_IVA__c != null) {
      this.GruppoIvaData = Data.TXT_Gruppo_IVA__c;
    }
    
    if (Data.TXT_Denominazione_Gruppo_IVA__c != null) {
      this.DenominazioneGruppoIvaData = Data.TXT_Denominazione_Gruppo_IVA__c;
    }
    
    if (this.PaeseIndirizzoSedeLegaleData === null || this.PaeseIndirizzoSedeLegaleData === undefined || this.PaeseIndirizzoSedeLegaleData === '') {
      this.PaeseIndirizzoSedeLegaleData = 'ITALIA';
    }

    if(Data.Censimento_Manuale__c != null)
    {
      this.censimentoManualeData = Data.Censimento_Manuale__c;
    }
  }

    LeadTemporaneo(Data){
      this.LeadData.CCIAA_CMK__c = Data.CCIAA_CMK__c;
      this.LeadData.CCIAA_REA_Innolva__c = Data.CCIAA_REA__c;

      this.LeadData.Partiva_Iva__c = Data.Partita_iva__c;
      this.LeadData.Codice_Fiscale__c = Data.Codice_fiscale__c;

      if(Data.BillingStreet!=null){
        this.LeadData.Street = Data.BillingStreet;
      }
      if(Data.BillingState!=null){
        this.LeadData.State = Data.BillingState;
      }
      if(Data.BillingPostalCode!=null){
        this.LeadData.PostalCode = Data.BillingPostalCode;
      }
      if(Data.BillingCountry!=null){
        this.LeadData.Country = Data.BillingCountry;
      }
      if(Data.BillingCity!=null){
        this.LeadData.City = Data.BillingCity;
      }
      
      if(Data.Street!=null){
        this.LeadData.Street = Data.Street;
      }
      if(Data.State!=null){
        this.LeadData.State = Data.State;
      }
      if(Data.PostalCode!=null){
        this.LeadData.PostalCode = Data.PostalCode;
      }
      if(Data.Country!=null){
        this.LeadData.Country = Data.Country;
      }
      if(Data.City!=null){
        this.LeadData.City = Data.City;
      }
      
      
      
      this.LeadData.Forma_giuridica__c = Data.Forma_giuridica__c;

      this.LeadData.Data_Bilancio_Innolva__c = Data.Data_Bilancio__c;
      this.LeadData.Acquisti_totali_Innolva__c = Data.Acquisti_totali__c;
      this.LeadData.Data_di_Iscrizione_Innolva__c = Data.Data_di_Iscrizione__c;
      this.LeadData.Data_di_cessazione_Innolva__c = Data.Data_di_cessazione__c;
      this.LeadData.Anno_rilevazione_addetti_Innolva__c = Data.Anno_rilevazione_addetti__c;
      this.LeadData.Data_Inizio_Attivita_Innolva__c = Data.Data_Inizio_Attivita__c;
      this.LeadData.AnnualRevenue = Data.AnnualRevenue;
      this.LeadData.Livello_attenzione_negativita_Innolva__c = Data.Livello_attenzione_negativita__c;
      this.LeadData.Capitale_Sociale_Innolva__c = Data.Capitale_Sociale__c;
      this.LeadData.Crediti_vs_Clienti_Innolva__c = Data.Crediti_vs_Clienti__c;
      this.LeadData.Risultato_Operativo_Lordo_Innolva__c = Data.Risultato_Operativo_Lordo__c;
      // this.LeadData.Telefono_personale_Warrant__c = Data.Phone_Warrant__c;
      this.LeadData.Phone = Data.Phone;
      this.LeadData.Totale_Patrimonio_Netto_Innolva__c = Data.Totale_Patrimonio_Netto_Tinexta__C;
      this.LeadData.Fax = Data.Fax;
      this.LeadData.Utile_Perdita_Innolva__c = Data.Utile_Perdita__c;
      this.LeadData.Stato_Attivita_Innolva__c = Data.Stato_Attivita__c;
      this.LeadData.Email_Aziendale_Innolva__c = Data.Email_Aziendale_Innolva__c;
      this.LeadData.TXT_Gruppo_IVA__c = Data.TXT_Gruppo_IVA__c;
      this.LeadData.TXT_Denominazione_Gruppo_IVA__c = Data.TXT_Denominazione_Gruppo_IVA__c;
      // console.log('Fatturato: '+Data.Fatturato__c);
      TXT_PickList_Fatturato({annualrevenue: Data.AnnualRevenue }).then(result => {  this.LeadData.Fatturato_Warrant__c = result; console.log('Fatturato: '+result);})
      console.log('Dipendenti: '+Data.Dipendenti__c);
      TXT_PickList_Dipendenti({strnumero: Data.Dipendenti__c}).then(result => {  this.LeadData.Dipendenti__c = result; console.log('Dipendenti: '+result);})
        
      //this.LeadData.FatturatoFascia_Innolva__c = Data.Fatturato__c;
      // this.LeadData.Rating_Lead__c = Data.Rating__c;
      this.LeadData.Rating_Lead__c = Data.Rating__c;
      //this.LeadData.Dipendenti__c = Data.Dipendenti__c;
      this.LeadData.Codice_Ateco_Innolva__c = Data.Codice_Ateco_Innolva__c;
      this.LeadData.Descrizione_Ateco_Innolva__c = Data.Descrizione_Ateco_Innolva__c;
    }

		chiudiModale(){
      // Utilizzato per chiudere i tab delle app console
      this.dispatchEvent(
        new CustomEvent('cstmcloseconsoletab')
      )
			window.history.back();
		}

    showToastMessage(text, type) {
        const toastEvent = new ShowToastEvent({
            title: '',
            message: text,
            variant: type
        });
        this.dispatchEvent(toastEvent);
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
    
}