/**
 * Progetto:         Revisione componenti core per CRM 2.0.
 * Sviluppatore      Marco Bonin <marco.bonin@bancaifis.it>
 * Descrizione:      Batch che converte i lead provenienti da web o da importazione liste
 *                   in prospect. Nel caso di lead web, i prospect convertiti vengono collegati alla campagna web,
 *                   e viene creato un task di contatto telefonico assegnato all'operatore di filo diretto interessato.
 *					  Il batch è la versione evoluta del precedente "BtcConvertLead" riadattato e semplificato per le nuove
 *					  esigenze nate dalla diversa strutturazione dei form web.
*/

global class BI_COM_ConversioneLead_BTCH implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

	@TestVisible private static final String CANALE_WEB = '5';
	public static final String ID_CAMPAGNA_WEB = Impostazioni__c.getInstance().IdCampagnaWeb__c;
	public static Boolean disableTrigger = false;

	Set<Id> leadIds;

	global BI_COM_ConversioneLead_BTCH() { }
	global BI_COM_ConversioneLead_BTCH(Set<Id> leadIds) {
		this.leadIds = leadIds;
	}

	public Boolean rilanciaBatchPerCensimento = false;
	public Id actualLeadId;

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(QueryBuilder.newInstance('Lead', new String[] {
			                                                        'Id',
			                                                        'IFISIdUnicoForm__c',
			                                                        'FirstName',
			                                                        'LastName',
			                                                        'RagioneSociale__c',
			                                                        'Name',
			                                                        'Phone',
			                                                        'MobilePhone',
			                                                        'Email',
			                                                        'PIVA__c',
			                                                        'TipoAccount__c',
			                                                        'State',
			                                                        'PostalCode',
			                                                        'Street',
			                                                        'City',
			                                                        'Tag__c',
			                                                        'Tag_Caricamento__c',
			                                                        'CodiceOwner__c',
			                                                        'IFISForm__c',
			                                                        'Messaggio__c',
			                                                        'PrivacyMarketing__c',
			                                                        'WGC_TAG_Controllante__c',
			                                                        'WGC_Canale_Di_Sviluppo__c',
			                                                        'WGC_Originator__c',
			                                                        'WGC_Originator_Dettaglio__c',
			                                                        'WGC_Tipo_Via__c',
			                                                        'WGC_Codice_Fiscale__c',
			                                                        'WGC_Sesso__c',
			                                                        'WGC_Specialista_Factoring__c',
			                                                        'WGC_Specialista_Filo_Diretto__c',
			                                                        'BI_StackTrace__c',
			                                                        'BI_Tipologia_Inserimento__c',
			                                                        'BI_Target_Form_MCC__c',
																	'BI_TargetForm__c',
			                                                        'BI_ModalitaApproccio__c',
			                                                        'BI_ModalitaApproccioDescrizione__c',
																	'AIGIS_NDG__c'
		                                                         })
		                                .beginFilter()
		                                .add('Status', QBOp.QEQUAL, 'Da qualificare')
		                                .add('Id', QBOp.QIN, leadIds)
		                                .endFilter()
		                                .getQuery()
		);
	}

	global void execute(Database.BatchableContext BC, List<SObject> scope) {

		Lead actualLead = (Lead) scope[0];

		String LEAD_partitaIva = actualLead.PIVA__c;
		Boolean checkPIVA = false;

		//Semplice controllo formato P.Iva per form provenienti da Facebook
		if (LEAD_partitaIva != null) {
			String PIva = LEAD_partitaIva.trim();
			if (PIva.isNumeric() && PIva.length() == 11) {
				checkPIVA = true;
			} else if (PIva.length() == 16) {
				checkPIVA = true;
			}
		}
		if (!checkPIVA) {
			String shortDescription = 'Formato errato del campo: P.IVA';

			BI_COM_AppLogFacade_CODE.insertAppLog(BI_COM_AppLogFacade_CODE.Threshold.ERROR, BI_COM_ConversioneLead_BTCH.class.getName(), LEAD_partitaIva, shortDescription, '');

			actualLead.Status = 'Non qualificabile';

			actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

			actualLead.ConversionMessage__c = shortDescription;

			update actualLead;

			return;
		}

		// VALIDAZIONI

		Boolean isLeadWeb = actualLead.IFISIdUnicoForm__c != null;

		// CONTROLLI TECNICI PRELIMINARI

		if (scope.size() > 1) {

			String shortDescription = 'Il batch di conversione va eseguito con un batchsize = 1';

			BI_COM_AppLogFacade_CODE.insertAppLog(BI_COM_AppLogFacade_CODE.Threshold.ERROR, BI_COM_ConversioneLead_BTCH.class.getName(), '', shortDescription, '');

			actualLead.Status = 'Non qualificato';

			actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

			actualLead.ConversionMessage__c = shortDescription;

			update actualLead;

			return;

		}

		// INIZIO CONTESTO TRANSAZIONALE

		System.SavePoint sp;

		// ARRIVO QUI PERCHE' O SI TRATTA DI UNA CAMPAGNA, OPPURE SI TRATTA DI UN FORM WEB 

		try {

			// IL METODO SOTTO VERIFICA SE LA PARTITA IVA E' PRESENTE IN CRM / CEDACRI / RIBES.

			// SE VIENE RITORNATO UN OGGETTO NULLO ALLORA SONO NELLA CASISTICA DI CENSIMENTO LIGHT
			// CON I DATI RICHIESTI DA PARTE DEL FORM (QUESTO PERCHE' IL FORM HA GIA' FATTO UNA LOOKUP
			// PREVENTIVA E SAPEVA CHE DOVEVA CHIEDERE I DATI EXTRA.

			Account actualAccount;

			try {

				actualAccount = BI_COM_UtilitiesAnagrafiche_CODE.searchAccountOverAllSystems(LEAD_partitaIva, actualLead.State);

			}

			catch(Exception ex) {

				// RAMO UTILIZZATO AD ESEMPIO IN CASO DI PIVA FORMALMENTE SCORRETTA

				String shortDescription = 'Non è stato possibile censire il lead per un anomalia nella ricerca anagrafica (' + ex.getMessage() + ')';

				BI_COM_AppLogFacade_CODE.insertAppLog(BI_COM_AppLogFacade_CODE.Threshold.ERROR, BI_COM_ConversioneLead_BTCH.class.getName(), LEAD_partitaIva, shortDescription, '');

				actualLead.Status = 'Non qualificato';

				actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

				actualLead.ConversionMessage__c = shortDescription;

				update actualLead;

				return;

			}

			if (actualAccount == null) {

				// DIFFERENZIAZIONE PER RETROCOMPATIBILITA' CON FORM WEB "VECCHI"

				if (isLeadWeb && actualLead.BI_Tipologia_Inserimento__c != null && actualLead.BI_Tipologia_Inserimento__c != 'TRADIZIONALE') {

					rilanciaBatchPerCensimento = true;

					actualLeadId = actualLead.Id;

					String shortDescription = 'La partita IVA del Lead non ha riscontri nei sistemi. Si richiede un censimento light';

					BI_COM_AppLogFacade_CODE.insertAppLog(BI_COM_AppLogFacade_CODE.Threshold.WARNING, BI_COM_ConversioneLead_BTCH.class.getName(), LEAD_partitaIva, shortDescription, '');

					actualLead.Status = 'Da censire';

					actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

					actualLead.ConversionMessage__c = '';

					update actualLead;

					return;

				}
				else {

					String shortDescription = 'Non è stato possibile censire il lead perchè non esiste la partita iva (' + actualLead.PIVA__c + ') sui sistemi';

					BI_COM_AppLogFacade_CODE.insertAppLog(BI_COM_AppLogFacade_CODE.Threshold.ERROR, BI_COM_ConversioneLead_BTCH.class.getName(), LEAD_partitaIva, shortDescription, '');

					actualLead.Status = 'Non qualificato';

					actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

					actualLead.ConversionMessage__c = shortDescription;

					update actualLead;

					return;

				}

			}

			else {

				rilanciaBatchPerCensimento = false;

				String shortDescription = 'La partita IVA del Lead (' + actualLead.PIVA__c + ') è stata trovata nei sistemi (' + actualAccount.Origine__c + ')';

				actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

			}

			// SV TEN aggiunda la condizione per la conversione del Lead in account
			Map<String, SObject> canaleDiSviluppoMap = U.keyBy([
			                                                   SELECT Id, DeveloperName, MasterLabel, NamespacePrefix, Label,
			                                                   QualifiedApiName, Originator__c, Originator_dettaglio__c,
			                                                   Forzatura__c, Canale_di_sviluppo__c, Qualifica_Utente__c, IFISForm__c
			                                                   FROM WGC_Originator__mdt
			                                                   WHERE IFISForm__c != null], 'IFISForm__c');

			// CRITERI DI SOVRASCRITTURA PER ASSEGNAZIONE TERRITORIALE

			User u = [SELECT Id, Qualifica_Utente__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
			String CAP = actualAccount.BillingPostalCode__c;

			List<AssegnazioneAnagrafica__c> assegnazioniFD = [SELECT Id, IdUtente__c, Filiale__c, FiloDiretto__c, RefPrincipale__c, SviluppoDiretto__c,
			                                                  ProvinciaComune__c, CAP__c, SviluppoIndiretto__c, Web__c, Comune__r.Cap__c,
			                                                  Comune__r.Cin__c, Comune__r.CodiceCatastale__c, Comune__r.Name, Utente__c,
			                                                  Utente__r.Qualifica_Utente__c, Utente__r.Profile.Name, Utente__r.ManagerId, WGC_Filo_Diretto_Web__c
			                                                  FROM AssegnazioneAnagrafica__c
			                                                  WHERE CAP__c = :actualAccount.BillingPostalCode__c AND(Utente__r.Qualifica_Utente__c = 'Filo Diretto')];

			// se non trovo assegnazioni con il cap presente nell'account ripeto la ricerca con il cap generico
			if (assegnazioniFD != null && assegnazioniFD.size() == 0) {
				if (!String.isEmpty(CAP) && CAP.length() == 5) {
					List<Comune__c> AComuni = [SELECT Id, Name, Cap__c FROM Comune__c WHERE Cap__c = :CAP AND FlagStorico__C = false];
					if (AComuni.isEmpty()) {
						string CAP3 = CAP.substring(0, 3);
						CAP = CAP3.rightPad(5, '0');
					}

					assegnazioniFD = [SELECT Id, IdUtente__c, Filiale__c, FiloDiretto__c, RefPrincipale__c, SviluppoDiretto__c,
					                  ProvinciaComune__c, CAP__c, SviluppoIndiretto__c, Web__c, Comune__r.Cap__c,
					                  Comune__r.Cin__c, Comune__r.CodiceCatastale__c, Comune__r.Name, Utente__c,
					                  Utente__r.Qualifica_Utente__c, Utente__r.Profile.Name, Utente__r.ManagerId, WGC_Filo_Diretto_Web__c
					                  FROM AssegnazioneAnagrafica__c
					                  WHERE CAP__c = :CAP AND(Utente__r.Qualifica_Utente__c = 'Filo Diretto')];
				}
			}

			// se non trovo assegnazioni con il cap presente nell'account ripeto la ricerca con il cap generico
			List<AssegnazioneAnagrafica__c> assegnazioniSC = [SELECT Id, IdUtente__c, Filiale__c, FiloDiretto__c, RefPrincipale__c, SviluppoDiretto__c,
			                                                  ProvinciaComune__c, CAP__c, SviluppoIndiretto__c, Web__c, Comune__r.Cap__c,
			                                                  Comune__r.Cin__c, Comune__r.CodiceCatastale__c, Comune__r.Name, Utente__c,
			                                                  Utente__r.Qualifica_Utente__c, Utente__r.Profile.Name, Utente__r.ManagerId, WGC_Filo_Diretto_Web__c
			                                                  FROM AssegnazioneAnagrafica__c
			                                                  WHERE CAP__c = :actualAccount.BillingPostalCode__c AND(Utente__r.Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali')];

			if (assegnazioniSC != null && assegnazioniSC.size() == 0) {
				if (CAP == null || CAP == '') {
					CAP = actualAccount.BillingPostalCode__c;
					if (!String.isEmpty(CAP) && CAP.length() == 5) {
						List<Comune__c> AComuni = [SELECT Id, Name, Cap__c FROM Comune__c WHERE Cap__c = :CAP AND FlagStorico__C = false];
						if (AComuni.isEmpty()) {
							string CAP3 = CAP.substring(0, 3);
							CAP = CAP3.rightPad(5, '0');
						}
					}
				}

				assegnazioniSC = [SELECT Id, IdUtente__c, Filiale__c, FiloDiretto__c, RefPrincipale__c, SviluppoDiretto__c,
				                  ProvinciaComune__c, CAP__c, SviluppoIndiretto__c, Web__c, Comune__r.Cap__c,
				                  Comune__r.Cin__c, Comune__r.CodiceCatastale__c, Comune__r.Name, Utente__c,
				                  Utente__r.Qualifica_Utente__c, Utente__r.Profile.Name, Utente__r.ManagerId, WGC_Filo_Diretto_Web__c
				                  FROM AssegnazioneAnagrafica__c
				                  WHERE CAP__c = :CAP AND(Utente__r.Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali')];
			}

			//String shortDescription = 'Assegnazione territoriale trovata: FD = ' + assegnazioniFD + ' COMMERCIALE = ' + assegnazioniSC;
			//actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;


			// ORIGINATOR - ORIGINATOR DETTAGLIO
			if (isLeadWeb && String.isNotBlank(ID_CAMPAGNA_WEB)) {
				if ((actualAccount.WGC_Originator_dettaglio__c == null || actualAccount.WGC_Originator_dettaglio__c == '') && (actualAccount.WGC_Originator__c == null || actualAccount.WGC_Originator__c == '')) {

					actualAccount.WGC_Originator__c = ((WGC_Originator__mdt) canaleDiSviluppoMap.get(actualLead.IFISForm__c)).Originator__c;
					actualAccount.WGC_Originator_dettaglio__c = ((WGC_Originator__mdt) canaleDiSviluppoMap.get(actualLead.IFISForm__c)).Originator_dettaglio__c;
				}
			} else {
				if ((actualAccount.WGC_Originator_dettaglio__c == null || actualAccount.WGC_Originator_dettaglio__c == '') && (actualAccount.WGC_Originator__c == null || actualAccount.WGC_Originator__c == '')) {

					if (String.isNotBlank(actualLead.WGC_Originator__c)) actualAccount.WGC_Originator__c = actualLead.WGC_Originator__c;
					if (String.isNotBlank(actualLead.WGC_Originator_Dettaglio__c)) actualAccount.WGC_Originator_Dettaglio__c = actualLead.WGC_Originator_Dettaglio__c;
				}
			}

			String shortDescription = 'Esecuzione operazioni di censimento / variazione dell\'anagrafica e del contatto';

			actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

			Contact contactDI = new Contact();

			if (actualAccount.NaturaGiuridica__c == 'DI') {

				contactDI = CreateAccount.getContactFromDI(actualAccount);
				Id accountId = CtrlWizardAccount.WGC_insertAccount(actualAccount, '', false, 'light', contactDI);

			} else {

				Id accountId = CtrlWizardAccount.WGC_insertAccount(actualAccount, '', false, 'full', null);
			}

			if (actualAccount.WGC_Qualifica_Corporate__c == null)
			actualAccount.WGC_Qualifica_Corporate__c = 'Prospect';

			if (isLeadWeb && String.isNotBlank(ID_CAMPAGNA_WEB)) {

				if (actualAccount.TAG_Controllante__c == null) {
					//Se è una form Mutuo MCC
					if (actualLead.IFISForm__c == '21')
					actualAccount.TAG_Controllante__c = 'NB Ti Finanzio';
					else
					actualAccount.TAG_Controllante__c = 'Inbound';
				}

				// SE CI SONO INFORMAZIONI SUL CANALE MARKETING
				actualAccount.BI_ModalitaApproccio__c = actualLead.BI_ModalitaApproccio__c;
				actualAccount.BI_ModalitaApproccioDescrizione__c = actualLead.BI_ModalitaApproccioDescrizione__c;

				// AGGIORNAMENTO DELLA DATA DI ULTIMA IMPORTAZIONE WEB
				actualAccount.DataUltimaImportazioneDaWeb__c = Datetime.now();

				actualAccount.CanaleSviluppo__c = CANALE_WEB;
				actualAccount.Sottocanale__c = actualLead.IFISForm__c;
				//Se è nuovo prospect, lo assegno all'utenza specificata nel lead se c'è, altrimenti a utenza default
				if (actualAccount.Id == null) actualAccount.OwnerId = getOwner(actualLead, null);
				if (String.isNotBlank(actualLead.Phone)) actualAccount.Phone = actualLead.Phone;
				if (String.isNotBlank(actualLead.Email)) actualAccount.Email__c = actualLead.Email;
				if (String.isNotBlank(actualLead.State)) actualAccount.ShippingState = actualLead.State;
				if (String.isNotBlank(actualLead.PostalCode)) actualAccount.ShippingPostalCode = actualLead.PostalCode;
				if (String.isNotBlank(actualLead.TipoAccount__c)) actualAccount.TipologiaCliente__c = actualLead.TipoAccount__c;
				if (String.isNotBlank(actualLead.BI_Target_Form_MCC__c)) actualAccount.Target_Form_MCC__c = actualLead.BI_Target_Form_MCC__c;
				if (String.isNotBlank(actualLead.Tag__c)) actualAccount.Tag__c = actualLead.Tag__c;

				if (actualAccount.BillingCity__c == null || actualAccount.BillingCity__c == '') {
					actualAccount.BillingCity__c = actualAccount.BillingCity;
				}

				if (actualAccount.BillingCountry__c == null || actualAccount.BillingCountry__c == '') {
					actualAccount.BillingCountry__c = actualAccount.BillingCountry;
				}

				if (actualAccount.BillingPostalCode__c == null || actualAccount.BillingPostalCode__c == '') {
					actualAccount.BillingPostalCode__c = actualAccount.BillingPostalCode;
				}

				if (actualAccount.BillingState__c == null || actualAccount.BillingState__c == '') {
					actualAccount.BillingState__c = actualAccount.BillingState;
				}

				Map<String, Set<Id>> specialistiFiloDiretto = new Map<String, Set<Id>> ();
				Map<String, Set<Id>> managersFiloDiretto = new Map<String, Set<Id>> ();

				for (AssegnazioneAnagrafica__c aa : assegnazioniFD) {
					if (specialistiFiloDiretto.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c) == null) specialistiFiloDiretto.put(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c, new Set<Id> ());
					specialistiFiloDiretto.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c).add(aa.IdUtente__c);
					
					if (aa.Utente__r.ManagerId != null) {
						if (managersFiloDiretto.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c) == null) managersFiloDiretto.put(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c, new Set<Id> ());
						managersFiloDiretto.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c).add(aa.Utente__r.ManagerId);
					}
				}
				//A.M. -> Modifica per gestione errore "FORM SCESE CON COMPETENZA ERRATA"
				//	if(!actualAccount.WGC_Filo_Diretto_Attivo__c && actualAccount.WGC_Giorni_Inattivita_Filo_Diretto__c > 13 && actualAccount.WGC_Giorni_Ex_cliente_Filo_Diretto__c > 24){
				if (!actualAccount.WGC_Filo_Diretto_Attivo__c && (actualAccount.WGC_Giorni_Inattivita_Filo_Diretto__c > 13 || actualAccount.WGC_Giorni_Inattivita_Filo_Diretto__c == null) && (actualAccount.WGC_Giorni_Ex_cliente_Filo_Diretto__c > 24 || actualAccount.WGC_Giorni_Ex_cliente_Filo_Diretto__c == null)) {
					actualAccount.WGC_Specialista_Filo_Diretto__c = WGC_TrgAccount.getSpecialista(CAP + '_' + actualAccount.BillingCity + '_' + actualAccount.BillingState, specialistiFiloDiretto, managersFiloDiretto, actualAccount.WGC_Specialista_Filo_Diretto__c);
				}

				shortDescription = 'FD assegnato: ' + actualAccount.WGC_Specialista_Filo_Diretto__c;
				actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

				// AGGIORNAMENTO DEI FLAG PRIVACY DELL'ACCOUNT IN BASE AL VALORE DEL FLAG SUL LEAD
				// SE PrivacyMarketing__c  == null O PrivacyMarketing__c == '' NON ALTERO L'ACCOUNT
				// REGOLE DA APPLICARE:
				// 1. Nuovo prospect: il sistema compila la sezione relativa ai consensi privacy secondo la selezione effettuata dal prospect sulla form
				// 2. Prospect già censito in Salesforce senza una opportunità aperta / Ex cliente senza alcuna linea attiva: il sistema sovrascrive i dati relativi ai consensi, aggiornandoli con la nuova selezione
				// 3. Prospect già censito e con un’opportunità aperta / cliente con rapporti attivi: il sistema non sovrascrive il dato (rimane valido quanto raccolto tramite modulo nell’opportunità / in sede di attivazione del rapporto)

				// USO UNA LISTA DI OPPORTUNITA' CREATA IN PRECEDENZA E CHE HA VALORE COMUNE ANCHE USATA POI

				List<Opportunity> activeOpportunityList;

				if (actualAccount.Id != null) {
					activeOpportunityList = [SELECT Id, StageName FROM Opportunity WHERE AccountId = :actualAccount.Id AND StageName NOT IN('Vinta', 'Persa')];
				} else {
					activeOpportunityList = new List<Opportunity> ();
				}
				if (actualLead.PrivacyMarketing__c != null && actualLead.PrivacyMarketing__c != '') { // se la stringa passata al servizio talend è vuota allora non prendo in considerazione la privacy

					if (activeOpportunityList.size() == 0) {

						shortDescription = 'Valorizzazione dei flag privacy dell\'account relativo al Lead: ' + actualLead.PrivacyMarketing__c;

						actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

						if (actualLead.PrivacyMarketing__c == 'true' || actualLead.PrivacyMarketing__c == '1') {
							actualAccount.ConsensoAttivitaPromRicercheMercato__c = true; // (2)
							actualAccount.ConsensoProdottiBancaRicercheMercato__c = true; // (4)
						} else if (actualLead.PrivacyMarketing__c == 'false' || actualLead.PrivacyMarketing__c == '0') {
							actualAccount.ConsensoAttivitaPromRicercheMercato__c = false; // (2)
							actualAccount.ConsensoProdottiBancaRicercheMercato__c = false; // (4)
						}

					}
				}

				upsert TrgAccount.gestisciOwner(new Account[] { actualAccount });


				// CREAZIONE DELL'CONTATTO DI DEFAULT RELATIVO ALL'ACCOUNT (PER DITTE NON INDIVIDUALI)

				Contact defaultContactForNewAccount = BI_COM_UtilitiesAnagrafiche_CODE.createNewContactFromLead(actualLead, actualAccount);

				if (actualAccount.NaturaGiuridica__c == 'DI') {
					// OVERRIDE DEL CONTATTO CON QUELLO GIA' CREATO IN CASO DI DI
					defaultContactForNewAccount = contactDI;
					//adione SDHDFNZ-77918 il num. inserito nella web-form va mantenuto
					String webFormPhone = '';
					webFormPhone += (String.isNotBlank(actualLead.Phone)) ? actualLead.Phone : '';
					webFormPhone += (String.isNotBlank(actualLead.MobilePhone)) ? ((String.isNotBlank(webFormPhone)) ? ' ' + actualLead.MobilePhone : actualLead.MobilePhone) : '';

					defaultContactForNewAccount.OtherPhone = webFormPhone;
					defaultContactForNewAccount.Email = actualLead.Email;
				}

				// AGGIORNAMENTO DEI FLAG PRIVACY DEL CONTATTO IN BASE AL VALORE DEL FLAG SUL LEAD

				if (actualLead.PrivacyMarketing__c != null && actualLead.PrivacyMarketing__c != '') {

					if (activeOpportunityList.size() == 0) {

						shortDescription = 'Valorizzazione dei flag privacy del defaultContact relativo al Lead: ' + actualLead.PrivacyMarketing__c;

						actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

						if (actualLead.PrivacyMarketing__c == 'true' || actualLead.PrivacyMarketing__c == '1') {
							defaultContactForNewAccount.ConsensoAttivitaPromRicercheMercato__c = true; // (2)
							defaultContactForNewAccount.ConsensoProdottiBancaRicercheMercato__c = true; // (4)
						} else if (actualLead.PrivacyMarketing__c == 'false' || actualLead.PrivacyMarketing__c == '0') {
							defaultContactForNewAccount.ConsensoAttivitaPromRicercheMercato__c = false; // (2)
							defaultContactForNewAccount.ConsensoProdottiBancaRicercheMercato__c = false; // (4)
						}

					}

				}

				try {

					upsert defaultContactForNewAccount;

				}

				catch(Exception ex) {

					shortDescription = 'Non è stato possibile aggiornare il contatto relativo al lead';

					BI_COM_AppLogFacade_CODE.insertAppLog(BI_COM_AppLogFacade_CODE.Threshold.ERROR, BI_COM_ConversioneLead_BTCH.class.getName(), LEAD_partitaIva, shortDescription, '');

					actualLead.Status = 'Non qualificato';

					actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

					actualLead.ConversionMessage__c = ex.getMessage();

					update actualLead;

					return;

				}

				actualLead.AccountCollegato__c = actualAccount.Id;

				update actualLead;

				CampaignMember[] cmL = [SELECT
				                        Id,
				                        ContactId,
				                        IsActiveCampagna__c,
				                        CampaignId
				                        FROM CampaignMember
				                        WHERE Contact.AccountId = :actualAccount.Id
				                        AND CampaignId = :ID_CAMPAGNA_WEB
				                        AND ContactId = :defaultContactForNewAccount.Id
				                        LIMIT 1
				                        FOR UPDATE
				                       ];

				Campaign[] defaultCampaign = [SELECT id, IsActive FROM Campaign where Id = :ID_CAMPAGNA_WEB];

				// CASO DI CONTROLLO UTILE QUANDO SI OPERA SU SANDBOX DIVERSE (VA CAMBIATO l'ID SU 'Impostazioni__c.getInstance().IdCampagnaWeb__c;').

				if (defaultCampaign.size() != 1) {

					shortDescription = 'Non è stato possibile qualificare il lead in quanto la campagna di default non è correttamente impostata';

					BI_COM_AppLogFacade_CODE.insertAppLog(BI_COM_AppLogFacade_CODE.Threshold.ERROR, BI_COM_ConversioneLead_BTCH.class.getName(), LEAD_partitaIva, shortDescription, '');

					actualLead.Status = 'Non qualificato';

					actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

					update actualLead;

					return;
				}

				if (!defaultCampaign[0].IsActive) {

					shortDescription = 'Non è stato possibile qualificare il lead in quanto la campagna di default non è attiva';

					BI_COM_AppLogFacade_CODE.insertAppLog(BI_COM_AppLogFacade_CODE.Threshold.ERROR, BI_COM_ConversioneLead_BTCH.class.getName(), LEAD_partitaIva, shortDescription, '');

					actualLead.Status = 'Non qualificato';

					actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

					actualLead.ConversionMessage__c = shortDescription;

					update actualLead;

					return;
				}

				//Aggiornando la data ultima importazione da web, si riscatena il sistema che crea i task di contatto telefonico
				CampaignMember cmTarget = !cmL.isEmpty() ? cmL[0] : new CampaignMember(ContactId = defaultContactForNewAccount.Id, CampaignId = ID_CAMPAGNA_WEB, Status = 'Target');

				BI_COM_ConversioneLead_BTCH.disableTrigger = true;

				try {

					upsert cmTarget; // workaround: ricalcolo le formule sacrificando 1 DML

					// SETTO IL MESSAGGIO CHE E' STATO SCRITTO NEL FORM WEB

					cmTarget.MessaggioFormWeb__c = actualLead.Messaggio__c;

					// SETTO I CAMPI TECNICI DEL LEAD IN MODO DA IDENTIFICARLO

					cmTarget.IFISForm__c = actualLead.IFISForm__c;
					cmTarget.IFISIdUnicoForm__c = actualLead.IFISIdUnicoForm__c;

					// SETTO L'INFORMAZIONE DEL FUORI TARGET CHE E' UNA DELLE CAUSE CHE FA O NON FA GENERARE IL TASK TELEFONICO (ASSIEME AL TIPO ACCOUNT 3)


					cmTarget.BI_Target_Form_MCC__c = actualLead.BI_Target_Form_MCC__c;
					cmTarget.BI_TargetForm__c = actualLead.BI_TargetForm__c;
				}

				catch(Exception ex) {

					shortDescription = 'Non è stato possibile associare il contatto telefonico relativo al lead';

					BI_COM_AppLogFacade_CODE.insertAppLog(BI_COM_AppLogFacade_CODE.Threshold.ERROR, BI_COM_ConversioneLead_BTCH.class.getName(), LEAD_partitaIva, shortDescription, '');

					actualLead.Status = 'Non qualificato';

					actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

					actualLead.ConversionMessage__c = ex.getMessage();

					update actualLead;

					return;

				}

				BI_COM_ConversioneLead_BTCH.disableTrigger = false;

				//A.M. SDCHG-5465 CRM - Nuovi task Segafredo - Aggiunta condizione actualLead.BI_Target_Form_MCC__c == '4'
				//if (actualAccount.TipologiaCliente__c == '3' || actualLead.TipoAccount__c == '3' || actualLead.BI_Target_Form_MCC__c == '2' || actualLead.BI_Target_Form_MCC__c == '3' || actualLead.BI_Target_Form_MCC__c == '4') {
				//M.N. non considero più la tipologia clientela ma il sito stesso elabora i dati raccolti e indica al CRM se aprire o meno il CT (SDCHG-5359 Classificazione In Target/Fuori Target )
				if (actualLead.BI_TargetForm__c == '0' || actualLead.BI_Target_Form_MCC__c == '2' || actualLead.BI_Target_Form_MCC__c == '3' || actualLead.BI_Target_Form_MCC__c == '4') {
				
					shortDescription = 'Nessuna associazione del contatto telefonico relativo al lead. Registrazione di un chatter di avviso.';

					actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

					// INVIO DI UN CHATTER DI REMIND ALTERNATIVO

					String outOfTargetLeadReason = 'Per questa anagrafica è arrivata una richiesta dal Form Web a nome di ' + actualLead.Name + ' che non è possibile lavorare in quanto la tipologia azienda non è pertinente. \r\n Messaggio originario: ' + actualLead.Messaggio__c;

					if (actualLead.BI_Target_Form_MCC__c == '2')
					outOfTargetLeadReason = 'Per questa anagrafica è arrivata una richiesta dal Form Web a nome di ' + actualLead.Name + ' che non è possibile lavorare in quanto fuori target. \r\n Messaggio originario: ' + actualLead.Messaggio__c;

					if (actualLead.BI_Target_Form_MCC__c == '3') {

						outOfTargetLeadReason = 'Per questa anagrafica è arrivata una richiesta dal Form Web a nome di ' + actualLead.Name + ' in target ma non già cliente. \r\n Messaggio originario: ' + actualLead.Messaggio__c;

						shortDescription = 'Registrazione di una task specifico già esitato.';

						actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

					}
					//A.M. SDCHG-5465 CRM - Nuovi task Segafredo
					if (actualLead.BI_Target_Form_MCC__c == '4')
					outOfTargetLeadReason = 'Per questa anagrafica è arrivata una richiesta dal Form Web a nome di ' + actualLead.Name + ' \r\n Messaggio originario: ' + actualLead.Messaggio__c;

					ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), actualAccount.Id, ConnectApi.FeedElementType.FeedItem, outOfTargetLeadReason);

					update actualLead;

					// SETTAGGIO FISSO DELLA PRIORITA' DI LAVORAZIONE DEL FORM
					// REQUISITO INTRODOTTO CON I LEAD PER MUTUI MCC

					cmTarget.BI_IFISFormPriority__c = '0';

					// GESTIONE PARTICOLARE IN CASO DI TARGET FORM MCC = 3 (In target ma non cliente)

					if (actualLead.BI_Target_Form_MCC__c == '3') {

						// CREAZIONE DI UN TASK FITTIZIO ESITATI SECONDO QUESTI REQUISITI (A.GOLA):

						// viene aperta una visita già esitata (esito = “Individuata Opportunità”) su un utente fittizio “Portale Mutui” che diventa al tempo stesso referente Crediti Commerciali (blu) nel Team Ifis come oggi avviene con Centax

						Task newTask = bifis_crm_c_CommonUtils.createTaskForDigitalContact(cmTarget, actualAccount, actualLead, true);

						insert newTask;

						// NUOVA ASSEGNAZIONE REFERENTE COMMERCIALE FACTORING IN ACCORDO CON L'UTENTE DEL TASK AUTOMATICO

						//actualAccount.WGC_Specialista_Digital_Lending__c = newTask.OwnerId;
						actualAccount.WGC_Specialista_Factoring__c = newTask.OwnerId;
						actualAccount.WGC_Factoring_Attivo__c = true;

						update actualAccount;

					}

				}

				else {

					shortDescription = 'Associazione del contatto telefonico relativo al lead ' + cmTarget;

					// SETTAGGIO FISSO DELLA PRIORITA' DI LAVORAZIONE DEL FORM
					// REQUISITO INTRODOTTO CON I LEAD PER MUTUI MCC

					cmTarget.BI_IFISFormPriority__c = '1';



					actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

					update actualLead;

				}

				// AGGIORNO LA DATA DI ULTIMA IMPORTAZIONE

				cmTarget.DataUltimaImportazioneDaWeb__c = Datetime.now();

				upsert cmTarget;


			} else {

				shortDescription = 'Associazione al contatto telefonico relativo al lead non richiesta in caso di campagna';

				actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

				// Nel caso di un import manuale, se è stato specificato il codiceOwner sul lead, lo uso come owner preferenziale, ma solo
				// se l'account non è già assegnato a qualcun altro. In questo caso, inoltre, non devo creare nessun contatto telefonico.
				// Questi verranno creati in un momento successivo, quando filo diretto segmenterà la lista importata in n campagne e le attiverà
				actualAccount.OwnerId = getOwner(actualLead, actualAccount.OwnerId);
				if (String.isNotBlank(actualLead.Phone)) actualAccount.Phone = actualLead.Phone;
				if (String.isNotBlank(actualLead.Tag__c)) actualAccount.Tag__c = actualLead.Tag__c;
				
				//Campo tecnico per riconoscere anagrafiche exAigis (NDG Clienti Fenice)
				actualAccount.AIGIS_NDG__c = actualLead.AIGIS_NDG__c;

				// SV TEN ADD NEW PARAMS            
				if (String.isNotBlank(actualLead.WGC_Specialista_Filo_Diretto__c) && String.isBlank(actualAccount.WGC_Specialista_Filo_Diretto__c)) actualAccount.WGC_Specialista_Filo_Diretto__c = actualLead.WGC_Specialista_Filo_Diretto__c;
				if (String.isNotBlank(actualLead.WGC_Specialista_Factoring__c) && String.isBlank(actualAccount.WGC_Specialista_Factoring__c)) actualAccount.WGC_Specialista_Factoring__c = actualLead.WGC_Specialista_Factoring__c;

				if (actualAccount.Email__c == null || actualAccount.Email__c == '') {
					if (String.isNotBlank(actualLead.Email)) actualAccount.Email__c = actualLead.Email;
				}

				if (actualAccount.ShippingState == null || actualAccount.ShippingState == '') {
					if (String.isNotBlank(actualLead.State)) actualAccount.ShippingState = actualLead.State;
				}

				if (actualAccount.ShippingPostalCode == null || actualAccount.ShippingPostalCode == '') {
					if (String.isNotBlank(actualLead.PostalCode)) actualAccount.ShippingPostalCode = actualLead.PostalCode;
				}

				if (actualAccount.TAG_Controllante__c == null || actualAccount.TAG_Controllante__c == '') {
					if (String.isNotBlank(actualLead.WGC_TAG_Controllante__c)) actualAccount.TAG_Controllante__c = actualLead.WGC_TAG_Controllante__c;
				}

				if (actualAccount.Tag_Caricamento__c == null || actualAccount.Tag_Caricamento__c == '') {
					if (String.isNotBlank(actualLead.Tag_Caricamento__c)) actualAccount.Tag_Caricamento__c = actualLead.Tag_Caricamento__c;
				}

				if (actualAccount.WGC_Canale_di_Sviluppo__c == null || actualAccount.WGC_Canale_di_Sviluppo__c == '') {
					if (String.isNotBlank(actualLead.WGC_Canale_di_Sviluppo__c)) actualAccount.WGC_Canale_di_Sviluppo__c = actualLead.WGC_Canale_di_Sviluppo__c;
				}

				if (actualAccount.BillingCity__c == null || actualAccount.BillingCity__c == '') {
					actualAccount.BillingCity__c = actualAccount.BillingCity;
				}

				if (actualAccount.BillingCountry__c == null || actualAccount.BillingCountry__c == '') {
					actualAccount.BillingCountry__c = actualAccount.BillingCountry;
				}

				if (actualAccount.BillingPostalCode__c == null || actualAccount.BillingPostalCode__c == '') {
					actualAccount.BillingPostalCode__c = actualAccount.BillingPostalCode;
				}

				if (actualAccount.BillingState__c == null || actualAccount.BillingState__c == '') {
					actualAccount.BillingState__c = actualAccount.BillingState;
				}

				Map<String, Set<Id>> specialistiFactoring = new Map<String, Set<Id>> ();
				Map<String, Set<Id>> managersFactoring = new Map<String, Set<Id>> ();
				Map<String, Set<Id>> specialistiFilo_Diretto = new Map<String, Set<Id>> ();
				Map<String, Set<Id>> managersFilo_Diretto = new Map<String, Set<Id>> ();

				System.debug('SV GESTIONE SPECIALISTA FACTORING');
				// SV TEN LOTTO 3.2 GESTIONE SPECIALISTA FACTORING
				if (String.isBlank(actualLead.WGC_Specialista_Factoring__c)) {
					if (String.isBlank(actualAccount.Id)) {
						for (AssegnazioneAnagrafica__c aa : assegnazioniSC) {
							if (specialistiFactoring.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c) == null)
							specialistiFactoring.put(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c, new Set<Id> ());
							specialistiFactoring.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c).add(aa.IdUtente__c);

							if (aa.Utente__r.ManagerId != null) {
								if (managersFactoring.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c) == null)
								managersFactoring.put(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c, new Set<Id> ());
								managersFactoring.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c).add(aa.Utente__r.ManagerId);
							}
						}
						actualAccount.WGC_Specialista_Factoring__c = WGC_TrgAccount.getSpecialista(CAP + '_' + actualAccount.BillingCity + '_' + actualAccount.BillingState, specialistiFactoring, managersFactoring, actualAccount.WGC_Specialista_Factoring__c);
					} else {
						if (String.isBlank(actualAccount.WGC_Specialista_Factoring__c)) { // Se Account.WGC_Specialista_Factoring__c  == null
							for (AssegnazioneAnagrafica__c aa : assegnazioniSC) {
								if (specialistiFactoring.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c) == null)
								specialistiFactoring.put(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c, new Set<Id> ());
								specialistiFactoring.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c).add(aa.IdUtente__c);

								if (aa.Utente__r.ManagerId != null) {
									if (managersFactoring.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c) == null)
									managersFactoring.put(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c, new Set<Id> ());
									managersFactoring.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c).add(aa.Utente__r.ManagerId);
								}
							}
							actualAccount.WGC_Specialista_Factoring__c = WGC_TrgAccount.getSpecialista(CAP + '_' + actualAccount.BillingCity + '_' + actualAccount.BillingState, specialistiFactoring, managersFactoring, actualAccount.WGC_Specialista_Factoring__c);
						}
						shortDescription = 'Specialista Factoring assegnato: ' + actualAccount.WGC_Specialista_Factoring__c;
						actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

					}
				} else {
					if (String.isBlank(actualAccount.Id)) {
						actualAccount.WGC_Specialista_Factoring__c = actualLead.WGC_Specialista_Factoring__c;
					} else {
						if (String.isBlank(actualAccount.WGC_Specialista_Factoring__c) || actualAccount.WGC_Factoring_Attivo__c == false) { // Se Account.WGC_Specialista_Factoring__c  == null
							actualAccount.WGC_Specialista_Factoring__c = actualLead.WGC_Specialista_Factoring__c;
						}
					}
					shortDescription = 'Specialista Factoring assegnato: ' + actualAccount.WGC_Specialista_Factoring__c;
					actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

				}

				System.debug('SV GESTIONE SPECIALISTA FILO DIRETTO');
				// SV TEN LOTTO 3.2 GESTIONE SPECIALISTA FILO DIRETTO              
				if (String.isBlank(actualLead.WGC_Specialista_Filo_Diretto__c)) { // Se Lead.WGC_Specialista_Filo_Diretto__c == null
					System.debug('SV GESTIONE SPECIALISTA FILO DIRETTO DENTRO IF');
					if (String.isBlank(actualAccount.Id)) {
						for (AssegnazioneAnagrafica__c aa : assegnazioniFD) {
							if (specialistiFilo_Diretto.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c) == null)
							specialistiFilo_Diretto.put(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c, new Set<Id> ());
							specialistiFilo_Diretto.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c).add(aa.IdUtente__c);

							if (aa.Utente__r.ManagerId != null) {
								if (managersFilo_Diretto.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c) == null)
								managersFilo_Diretto.put(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c, new Set<Id> ());
								managersFilo_Diretto.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c).add(aa.Utente__r.ManagerId);
							}
						}
						actualAccount.WGC_Specialista_Filo_Diretto__c = WGC_TrgAccount.getSpecialista(CAP + '_' + actualAccount.BillingCity + '_' + actualAccount.BillingState, specialistiFilo_Diretto, managersFilo_Diretto, actualAccount.WGC_Specialista_Filo_Diretto__c);
						shortDescription = 'FD assegnato: ' + actualAccount.WGC_Specialista_Filo_Diretto__c;
						actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

					} else {
						if (actualAccount.WGC_Specialista_Filo_Diretto__c == null) {
							// Se Account.WGC_Specialista_Filo_Diretto__c  == null
							for (AssegnazioneAnagrafica__c aa : assegnazioniFD) {
								if (specialistiFilo_Diretto.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c) == null)
								specialistiFilo_Diretto.put(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c, new Set<Id> ());
								specialistiFilo_Diretto.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c).add(aa.IdUtente__c);

								if (aa.Utente__r.ManagerId != null) {
									if (managersFilo_Diretto.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c) == null)
									managersFilo_Diretto.put(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c, new Set<Id> ());
									managersFilo_Diretto.get(aa.CAP__c + '_' + aa.Comune__r.Name + '_' + aa.ProvinciaComune__c).add(aa.Utente__r.ManagerId);
								}
							}
							actualAccount.WGC_Specialista_Filo_Diretto__c = WGC_TrgAccount.getSpecialista(CAP + '_' + actualAccount.BillingCity + '_' + actualAccount.BillingState, specialistiFilo_Diretto, managersFilo_Diretto, actualAccount.WGC_Specialista_Filo_Diretto__c);
						}
						shortDescription = 'FD assegnato: ' + actualAccount.WGC_Specialista_Filo_Diretto__c;
						actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

					}
				} else { // Se Lead.WGC_Specialista_Filo_Diretto__c != null
					actualAccount.WGC_Specialista_Filo_Diretto__c = actualLead.WGC_Specialista_Filo_Diretto__c;
					shortDescription = 'FD assegnato: ' + actualAccount.WGC_Specialista_Filo_Diretto__c;
					actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

				}


				upsert actualAccount;

			}

			// CONCLUSIONE POSITIVA DEL PROCESSO DI QUALIFICA

			actualLead.Status = 'Qualificato';

			shortDescription = 'Il lead è stato qualificato con successo';

			actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

			actualLead.ConversionMessage__c = '';

			actualLead.AccountCollegato__c = actualAccount.Id;

			update actualLead;

		} catch(Ex.BtcConvertLeadException e) {

			if (sp != null) Database.rollback(sp);

			String shortDescription = 'Eccezione \'BtcConvertLeadException\'';

			BI_COM_AppLogFacade_CODE.insertAppLog(BI_COM_AppLogFacade_CODE.Threshold.ERROR, BI_COM_ConversioneLead_BTCH.class.getName(), LEAD_partitaIva, shortDescription, '');

			actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

			actualLead.Status = 'Non qualificato';

			actualLead.ConversionMessage__c = e.getMessage();

			update actualLead;

		} catch(CalloutException e) {

			if (sp != null) Database.rollback(sp);

			String shortDescription = 'Eccezione \'CalloutException\' in fase di Callout';

			BI_COM_AppLogFacade_CODE.insertAppLog(BI_COM_AppLogFacade_CODE.Threshold.ERROR, BI_COM_ConversioneLead_BTCH.class.getName(), LEAD_partitaIva, shortDescription, '');

			actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

			actualLead.Status = 'Non qualificato';

			actualLead.ConversionMessage__c = e.getMessage();

			update actualLead;

		} catch(Exception e) {

			if (sp != null) Database.rollback(sp);

			String shortDescription = 'Eccezione generica (Vedi Dettaglio Conversione)';

			BI_COM_AppLogFacade_CODE.insertAppLog(BI_COM_AppLogFacade_CODE.Threshold.ERROR, BI_COM_ConversioneLead_BTCH.class.getName(), LEAD_partitaIva, shortDescription, '');

			actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

			actualLead.Status = 'Non qualificato';

			actualLead.ConversionMessage__c = e.getMessage();

			update actualLead;
		}

	}

	@testVisible
	private Id getOwner(Lead l, Id oldOwnerId) {
		User oldOwner = oldOwnerId != null ? [SELECT Id, IsActive FROM User WHERE Id = :oldOwnerId] : null;

		if (String.isNotBlank(l.CodiceOwner__c)) {
			User[] uL = [SELECT Id FROM User WHERE LoginSiebel__c = :l.CodiceOwner__c AND IsActive = TRUE];
			return uL.isEmpty() ? UtenzeDefault__c.getInstance().IdUtente__c : uL[0].Id;
		} else if (oldOwner != null && oldOwner.IsActive) {
			return oldOwner.Id;
		} else {
			return UtenzeDefault__c.getInstance().IdUtente__c;
		}
	}

	global void finish(Database.BatchableContext BC) {

		if (rilanciaBatchPerCensimento) {

			Set<Id> leadIds = new Set<Id> ();
			leadIds.add(actualLeadId);
			BI_COM_CensimentoLead_BTCH b = new BI_COM_CensimentoLead_BTCH(leadIds);
			Database.executeBatch(b, 1);
		}
	}
}