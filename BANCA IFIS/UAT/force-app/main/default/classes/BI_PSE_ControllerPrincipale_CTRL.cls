/**
 * Progetto:         Banca IFIS
 * Developer:        Marco Bonin
 * Descrizione:      Controller generico di governo della Community Segnalatori
*/

public without sharing class BI_PSE_ControllerPrincipale_CTRL {
	public static final String DESTINATARI_CC_FACT = Parametri_Segnalatori__c.getInstance().Destinatari_CC__c;
	public static final String DESTINATARI_CC_LEAS = Parametri_Segnalatori__c.getInstance().Destinatati_CC_Leasing__c;

	public class RisultatoPrevalutazione {

		@AuraEnabled
		public boolean esitoGlobale { get; set; }
		@AuraEnabled
		public String timelineAggiornata { get; set; }
		@AuraEnabled
		public String statoAggiornato { get; set; }
		@AuraEnabled
		public String erroreTecnico { get; set; }
		@AuraEnabled
		public String idAccountCreato { get; set; }
		@AuraEnabled
		public String nomeAccountCreato { get; set; }

	}

	@AuraEnabled
	public static User datiUtenteLoggato() {

		User oUser = [select id, Name, TimeZoneSidKey, Username, Alias, Country, Email, FirstName, LastName, IsActive, IsPortalEnabled, Phone, ID_Polaris__c, Codice_referente_BG__c FROM User Where id = :UserInfo.getUserId()];

		return oUser;

	}

	@AuraEnabled
	public static RisultatoPrevalutazione esitoPrevalutazioneSegnalazione(WorkflowSegnalatori__c workflowRecord, String motivazioneRifiutoPrevalutazione, String nuovoStatoSegnalazione, String descrizioneOperazione) {

		RisultatoPrevalutazione result = new RisultatoPrevalutazione();

		result.esitoGlobale = false;

		String statoPrecedente;

		// MODIFICA DELLO STATO DELLA PRATICA

		try {

			// EVENTUALE CENSIMENTO DELL'ANAGRAFE ASSOCIATA

			Account accountRicercato;
			accountRicercato = BI_COM_UtilitiesAnagrafiche_CODE.searchAccountOverAllSystems(workflowRecord.PartitaIVA__c, null);
			System.debug('accountRicercato ' + accountRicercato);
			if (accountRicercato == null) {

				// O ERRORE TECNICO O PARTITA IVA NON TROVATA NEI SISTEMI 

				result.esitoGlobale = false;
				result.statoAggiornato = '';
				result.timelineAggiornata = '';
				result.erroreTecnico = 'Ricerca della partita iva ' + workflowRecord.PartitaIVA__c + ' non riuscita';

				workflowRecord.ErroriTecnici__c = result.erroreTecnico;

				System.debug('@@@A.M. workflowRecord ' + workflowRecord);
				update workflowRecord;

				return result;

			}

			// REALE CENSIMENTO DEL SOGGETTO (nel caso non sia censito)

			Contact contactDI = new Contact();
			Id accountId;

			if (accountRicercato.NaturaGiuridica__c == 'DI') {

				contactDI = CreateAccount.getContactFromDI(accountRicercato);

				contactDI = integraDatiMancanti(contactDI, workflowRecord.REFERENTI_JSON__c);

				System.debug('CONTATTO ' + contactDI);
				accountId = CtrlWizardAccount.WGC_insertAccount(accountRicercato, '', false, 'light', contactDI);

			} else {

				accountId = CtrlWizardAccount.WGC_insertAccount(accountRicercato, '', false, 'full', null);
			}
			System.debug('accountId ' + accountId);
			// CREAZIONE DELL'CONTATTO DI DEFAULT RELATIVO ALL'ACCOUNT (PER DITTE NON INDIVIDUALI)
			/*
			  Contact defaultContactForNewAccount = BI_COM_UtilitiesAnagrafiche_CODE.createNewContactFromLead(actualLead, actualAccount);
			 
			  if (actualAccount.NaturaGiuridica__c == 'DI') {
			  // OVERRIDE DEL CONTATTO CON QUELLO GIA' CREATO IN CASO DI DI
			  defaultContactForNewAccount = contactDI;
			  //adione SDHDFNZ-77918 il num. inserito nella web-form va mantenuto
			  String webFormPhone = '';
			  webFormPhone += (String.isNotBlank(actualLead.Phone)) ? actualLead.Phone : '';
			  webFormPhone += (String.isNotBlank(actualLead.MobilePhone)) ? ((String.isNotBlank(webFormPhone)) ? ' '+actualLead.MobilePhone : actualLead.MobilePhone) : '';
			 
			  defaultContactForNewAccount.OtherPhone = webFormPhone;
			  defaultContactForNewAccount.Email = actualLead.Email;
			  }
			 */

			// OTTENIMENTO DEGLI SPECIALISTI ABBINATI ALL'ACCOUNT
			/*
			  Account actualAccount = [SELECT Id, Name FROM Account WHERE Id=:accountId]; 
			 
			  BI_COM_UtilitiesAnagrafiche_CODE.Specialisti specialisti = BI_COM_UtilitiesAnagrafiche_CODE.calcolaSpecialistiAccount(actualAccount.id);
			 
			  actualAccount.WGC_Specialista_Factoring__c = specialisti.specialistaFactoring;
			  actualAccount.WGC_Specialista_Filo_Diretto__c = specialisti.specialistaFiloDiretto;
			 
			  // AGGIORNAMENTO DELL'ACCOUNT
			 
			  update actualAccount;
			  System.debug('actualAccount ' + actualAccount);
			 
			  // JOIN CON IL WORKFLOW
			 */
			workflowRecord.AccountCollegato__c = accountId; //actualAccount.Id;
			System.debug('@@@ A.M. workflowRecord.AccountCollegato__c ' + workflowRecord.AccountCollegato__c);

			String nuovoElementoJSON;
			String motivoRifiutoPrevalutazione;

			//A.M. Gestione anche in caso di segnalazione LEEASING/RENTAL
			//if (nuovoStatoSegnalazione == 'PREVALUTAZIONE_KO' && workflowRecord.Tipo_Segnalazione__c.equals('FACTORING')) {
			if (nuovoStatoSegnalazione == 'PREVALUTAZIONE_KO') {

				Schema.DescribeFieldResult fieldResult = WorkflowSegnalatori__c.MotivazioneRifiutoPrevalutazione__c.getDescribe();
				List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
				for (Schema.PicklistEntry pickListVal : ple) {
					if (motivazioneRifiutoPrevalutazione == pickListVal.getValue()) {
						motivoRifiutoPrevalutazione = pickListVal.getLabel();
						break;
					}
				}

				workflowRecord.MotivazioneRifiutoPrevalutazione__c = motivazioneRifiutoPrevalutazione;

				workflowRecord.Stato__c = nuovoStatoSegnalazione;

				nuovoElementoJSON = '{"descrizione":"' + descrizioneOperazione + '","momento":' + System.currentTimeMillis() + ',"decoratore":"NO_GO", "utenteOperazione":"' + UserInfo.getName() + '"}';

				insert BI_COM_UtilitiesAnagrafiche_CODE.creaTaskSuAccount(workflowRecord, UserInfo.getUserId(), 'Chiuso', 'Segnalazione esterna', motivoRifiutoPrevalutazione, 'ContattoTelefonicoDiretto');
			}

			//if(nuovoStatoSegnalazione == 'PREVALUTAZIONE_OK'){
			//// OPPORTUNITA' AUTOMATICA 
			//Opportunity actualOpportunity = BI_COM_UtilitiesOpportunita_CODE.preparaOpportunitaLIGHT(actualAccount);
			//insert actualOpportunity;
			//workflowRecord.OpportunitaCollegata__c = actualOpportunity.Id;
			//// CREAZIONE DI UN TASK SPECIFICO ESITATO PER LA SEGNALAZIONE ED ABBINATO ALL'ACCOUNT
			//insert BI_COM_UtilitiesAnagrafiche_CODE.creaTaskSuAccount(actualAccount.Id,UserInfo.getUserId(),'Chiuso','Segnalazione esterna','Segnalazione elaborata','Apertura da portale segnalatori','ContattoTelefonicoDiretto');
			//nuovoElementoJSON = '{"descrizione":"'+ descrizioneOperazione +'","momento":' + System.currentTimeMillis() + ',"decoratore":"GO", "utenteOperazione":"' + UserInfo.getName() + '"}';
			//}

			if (nuovoElementoJSON != null && nuovoElementoJSON != '') {

				if (String.isBlank(workflowRecord.TIMELINE_JSON__c)) {

					nuovoElementoJSON = '[' + nuovoElementoJSON + ']';

					workflowRecord.TIMELINE_JSON__c = nuovoElementoJSON;

				}
				else {

					workflowRecord.TIMELINE_JSON__c = workflowRecord.TIMELINE_JSON__c.removeEnd(']');

					workflowRecord.TIMELINE_JSON__c = workflowRecord.TIMELINE_JSON__c + ',' + nuovoElementoJSON + ']';

				}
			}

			workflowRecord.ErroriTecnici__c = '';

			update workflowRecord;

			result.esitoGlobale = true;
			result.statoAggiornato = nuovoStatoSegnalazione;
			result.timelineAggiornata = workflowRecord.TIMELINE_JSON__c;
			result.erroreTecnico = '';
			result.idAccountCreato = workflowRecord.AccountCollegato__c;

			return result;

		}
		catch(Exception ex) {

			// ECCEZIONE GENERICA
			System.debug(ex.getStackTraceString());
			result.esitoGlobale = false;
			result.statoAggiornato = '';
			result.timelineAggiornata = '';
			result.erroreTecnico = ex.getMessage();

			workflowRecord.ErroriTecnici__c = result.erroreTecnico;

			try {

				update workflowRecord;

			}
			catch(Exception innerEx) {

				result.erroreTecnico = innerEx.getMessage();

			}

			return result;

		}

	}

	@AuraEnabled
	public static RisultatoPrevalutazione completaPrevalutazioneSegnalazione(WorkflowSegnalatori__c actualWorkflow, String recordOppId) {

		if (actualWorkflow.Tipo_Segnalazione__c.equals('LEASING'))
		recordOppId = creaOpportunita(actualWorkflow);

		RisultatoPrevalutazione result = new RisultatoPrevalutazione();
		actualWorkflow.OpportunitaCollegata__c = recordOppId;

		String nuovoElementoJSON = '{"descrizione":"Prevalutazione esitata positivamente","momento":' + System.currentTimeMillis() + ',"decoratore":"GO", "utenteOperazione":"' + UserInfo.getName() + '"}';

		actualWorkflow.TIMELINE_JSON__c = actualWorkflow.TIMELINE_JSON__c.removeEnd(']');

		actualWorkflow.TIMELINE_JSON__c = actualWorkflow.TIMELINE_JSON__c + ',' + nuovoElementoJSON + ']';

		actualWorkflow.ErroriTecnici__c = '';

		actualWorkflow.Stato__c = 'PREVALUTAZIONE_OK';

		update actualWorkflow;

		String indirizzoMail;
		String indirizzoMailResponsabile;
		List<Opportunity> specialista = [SELECT Owner.Email, BI_WorkflowSegnalatori__c, WGC_Email_Referente_Factoring_Anagrafica__c from Opportunity where Id = :recordOppId];
		System.debug('@@@ specialista mail ' + specialista);

		if (specialista.size() > 0) {
			indirizzoMail = specialista[0].Owner.Email;
			specialista[0].BI_WorkflowSegnalatori__c = actualWorkflow.Id;
			indirizzoMailResponsabile = specialista[0].WGC_Email_Referente_Factoring_Anagrafica__c;
			update specialista[0];
		}

		if (actualWorkflow.Tipo_Segnalazione__c.equals('FACTORING')) {
			//// CREAZIONE DI UN TASK SPECIFICO ESITATO PER LA SEGNALAZIONE ED ABBINATO ALL'ACCOUNT
			insert BI_COM_UtilitiesAnagrafiche_CODE.creaTaskSuAccount(actualWorkflow, UserInfo.getUserId(), 'Chiuso', 'Segnalazione esterna', 'Aperta opportunità', 'ContattoTelefonicoDiretto');

			try {
				//CREAZIONE MAIL
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

				String[] toAddresses = new String[] { indirizzoMail };
				mail.setToAddresses(toAddresses);

				String[] ccAddresses;
				System.debug('indirizzoMailResponsabile ' + indirizzoMailResponsabile);
				if (DESTINATARI_CC_FACT != null && DESTINATARI_CC_FACT.length() > 0 && indirizzoMailResponsabile != null && indirizzoMailResponsabile.length() > 0)
				ccAddresses = new String[] { DESTINATARI_CC_FACT, indirizzoMailResponsabile };
				else if (indirizzoMailResponsabile != null && indirizzoMailResponsabile.length() > 0)
				ccAddresses = new String[] { indirizzoMailResponsabile };
				else if (DESTINATARI_CC_FACT != null && DESTINATARI_CC_FACT.length() > 0)
				ccAddresses = new String[] { DESTINATARI_CC_FACT };
				if (ccAddresses != null && ccAddresses.size() > 0)
				mail.setCcAddresses(ccAddresses);

				mail.setSubject('Segnalazione esterna ' + actualWorkflow.Ragione_Sociale__c);
				mail.setBccSender(false);
				mail.setUseSignature(false);
				//mail.setReplyTo('segnalazioni.direzionecommerciale@bancaifis.it');
				//mail.setSenderDisplayName('Banca Ifis s.p.a.');

				OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Banca Ifis - Segnalazioni' LIMIT 1];
				mail.setOrgWideEmailAddressId(owea.Id);

				String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';

				String htmlBody = 'Ciao,<br>' + actualWorkflow.Ente_segnalante_descrizione__c + ' ha inviato una segnalazione per l’azienda ' + actualWorkflow.Ragione_Sociale__c + ' P.IVA ' + actualWorkflow.PartitaIVA__c + '. Di seguito i dettagli:<p>';

				List<Object> mapRef = bifis_crm_c_CommonUtils.parseReferentiJSON(actualWorkflow.REFERENTI_JSON__c);

				if (mapRef != null) {
					String testo = '<i>Referente Azienda:</i> ';
					for (Object current : mapRef) {
						Map<String, Object> entry = (Map<String, Object>) current;
						String nome = (String) entry.get('nome');
						String cognome = (String) entry.get('cognome');
						String ruolo = (String) entry.get('ruolo');
						String telefono = (String) entry.get('telefono');
						String mailRef = (String) entry.get('mail');
						testo = testo + (nome != null ? nome : '') + ' ' + (cognome != null ? cognome : '') + ' (' + (ruolo != null ? ruolo : '') + ') ' + (telefono != null ? telefono : '') + ' - ' + (mailRef != null ? mailRef : '');
						System.debug('@@@ testo mail ' + testo);
					}
					htmlBody += '<p>' + testo + '</p>';
				}

				htmlBody += '<p><i>Referente ente segnalante:</i> ' + (actualWorkflow.NomeReferente__c != null ? actualWorkflow.NomeReferente__c : '') + ' ' + (actualWorkflow.CognomeReferente__c != null ? actualWorkflow.CognomeReferente__c : '') + ' ' + (actualWorkflow.TelefonoReferente__c != null ? actualWorkflow.TelefonoReferente__c : '') + ' - ' + (actualWorkflow.EmailReferente__c != null ? actualWorkflow.EmailReferente__c : '') + '</p>';

				String testo = '<i>Prodotti:</i> ';
				if (actualWorkflow.Tipologia_Segnalazione__c.equals('FACTORING') || actualWorkflow.Tipologia_Segnalazione__c.equals('MISTO')) {
					Map<String, Object> prodottoFactoring = bifis_crm_c_CommonUtils.parseProdottoJSON(actualWorkflow.PRD_FACTORING_JSON__c);
					if (prodottoFactoring != null) {
						String fabbisognoFinanziarioFactoring = (String) prodottoFactoring.get('fabbisognoFinanziarioFactoring');
						String naturaClientiFactoring = (String) prodottoFactoring.get('naturaClientiFactoring');
						String nazionalitaClientiFactoring = (String) prodottoFactoring.get('nazionalitaClientiFactoring');
						String noteFactoring = (String) prodottoFactoring.get('noteFactoring');
						testo = testo + 'FACTORING ' + (fabbisognoFinanziarioFactoring != null ? ('fabbisogno finanziario: ' + fabbisognoFinanziarioFactoring) : '') + ' ' + (naturaClientiFactoring != null ? ('natura del cliente: ' + naturaClientiFactoring) : '') + ' ' + (nazionalitaClientiFactoring != null ? ('nazionalità: ' + nazionalitaClientiFactoring) : '') + ' ' + (noteFactoring != null ? ('note: ' + noteFactoring) : '');
					}
				}
				if (actualWorkflow.Tipologia_Segnalazione__c.equals('MISTO')) {
					testo = testo + '<br>';
				}
				if (actualWorkflow.Tipologia_Segnalazione__c.equals('MUTUO') || actualWorkflow.Tipologia_Segnalazione__c.equals('MISTO')) {
					Map<String, Object> prodottoMutuo = bifis_crm_c_CommonUtils.parseProdottoJSON(actualWorkflow.PRD_MUTUO_JSON__c);
					if (prodottoMutuo != null) {
						String importoMutuo = (String) prodottoMutuo.get('importoMutuo');
						String durataAmmortamentoMutuo = (String) prodottoMutuo.get('durataAmmortamentoMutuo');
						String durataPreammortamentoMutuo = (String) prodottoMutuo.get('durataPreammortamentoMutuo');
						String finalitaMutuo = (String) prodottoMutuo.get('finalitaMutuo');
						String noteMutuo = (String) prodottoMutuo.get('noteMutuo');
						testo = testo + 'MUTUO ' + (importoMutuo != null ? ('importo mutuo: ' + importoMutuo) : '') + ' ' + (durataAmmortamentoMutuo != null ? ('durata ammortamento: ' + durataAmmortamentoMutuo) : '') + ' ' + (durataPreammortamentoMutuo != null ? ('durata preammortamento: ' + durataPreammortamentoMutuo) : '') + ' ' + (finalitaMutuo != null ? ('finalità mutuo: ' + finalitaMutuo) : '') + ' ' + (noteMutuo != null ? ('note: ' + noteMutuo) : '');
						System.debug('@@@ testo mail ' + testo);
					}
				}
				htmlBody += '<p>' + testo + '</p>';
				htmlBody += '<p><i>Note di Direzione Commerciale</i>: ' + (actualWorkflow.CommentoEsito__c != null ? actualWorkflow.CommentoEsito__c : '') + '</p>';
				htmlBody += '<p><i>Opportunità generata:</i> ' + fullFileURL + actualWorkflow.OpportunitaCollegata__c + '</p>';
				htmlBody += '<p><i>Allegati:</i></p>';

				List<Object> mapObj = bifis_crm_c_CommonUtils.parseDocumentJSON(actualWorkflow.DOCUMENTI_JSON__c);
				if (mapObj != null) {
					Integer count = 1;
					for (Object current : mapObj) {
						Map<String, Object> entry = (Map<String, Object>) current;
						String fileid = (String) entry.get('id');
						String fileName = (String) entry.get('fileName');
						htmlBody += fileName + ': ' + fullFileURL + fileid + '</p>';
						System.debug('---> idDoc: ' + fileid);
						count++;
					}
				}
				htmlBody += '<p>Procedi gentilmente con la verifica di fattibilità della segnalazione e dai un feedback al segnalatore.<br>Buon lavoro!</p>';
				mail.setHtmlBody(htmlBody);

				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			} catch(Exception ex) {

				System.debug('Errore invio mail factoring' + ex);
			}
		} else {
			try {
				//CREAZIONE MAIL
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

				String[] toAddresses = new String[] { indirizzoMail };
				mail.setToAddresses(toAddresses);

				//A.M. Aggiunta destinatari in CC per segnalazioni Leasing
				String[] ccAddresses;
				if (DESTINATARI_CC_LEAS != null && DESTINATARI_CC_LEAS.length() > 0){
					ccAddresses = new String[] { DESTINATARI_CC_LEAS, indirizzoMail };
					System.debug('@@@A.M. DESTINATARI_CC_LEAS: ' + ccAddresses);
					mail.setCcAddresses(ccAddresses);
				}
				
				mail.setSubject('Segnalazione esterna ' + actualWorkflow.Ragione_Sociale__c);
				mail.setBccSender(false);
				mail.setUseSignature(false);

				OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Banca Ifis - Segnalazioni' LIMIT 1];
				mail.setOrgWideEmailAddressId(owea.Id);

				String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';

				String htmlBody = 'Ciao,<br>' + actualWorkflow.Ente_segnalante_descrizione__c + ' ha inviato una segnalazione per l’azienda ' + actualWorkflow.Ragione_Sociale__c + ' P.IVA ' + actualWorkflow.PartitaIVA__c + '. Di seguito i dettagli:<p>';

				List<Object> mapRef = bifis_crm_c_CommonUtils.parseReferentiJSON(actualWorkflow.REFERENTI_JSON__c);

				if (mapRef != null) {
					String testo = '<i>Referente Azienda:</i> ';
					for (Object current : mapRef) {
						Map<String, Object> entry = (Map<String, Object>) current;
						String nome = (String) entry.get('nome');
						String cognome = (String) entry.get('cognome');
						String ruolo = (String) entry.get('ruolo');
						String telefono = (String) entry.get('telefono');
						String mailRef = (String) entry.get('mail');
						testo = testo + (nome != null ? nome : '') + ' ' + (cognome != null ? cognome : '') + ' (' + (ruolo != null ? ruolo : '') + ') ' + (telefono != null ? telefono : '') + ' - ' + (mailRef != null ? mailRef : '');
						System.debug('@@@ testo mail ' + testo);
					}
					htmlBody += '<p>' + testo + '</p>';
				}

				htmlBody += '<p><i>Referente ente segnalante:</i> ' + (actualWorkflow.NomeReferente__c != null ? actualWorkflow.NomeReferente__c : '') + ' ' + (actualWorkflow.CognomeReferente__c != null ? actualWorkflow.CognomeReferente__c : '') + ' ' + (actualWorkflow.TelefonoReferente__c != null ? actualWorkflow.TelefonoReferente__c : '') + ' - ' + (actualWorkflow.EmailReferente__c != null ? actualWorkflow.EmailReferente__c : '') + '</p>';

				String testo = '<i>Prodotti:</i> ';
				if (actualWorkflow.Tipologia_Segnalazione__c.equals('LEASING') || actualWorkflow.Tipologia_Segnalazione__c.equals('LEASINGRENTAL')) {
					Map<String, Object> prodottoLeasing = bifis_crm_c_CommonUtils.parseProdottoJSON(actualWorkflow.PRD_LEASING_JSON__c);
					if (prodottoLeasing != null) {
						String importo = (String) prodottoLeasing.get('importoLeasing');
						String business = (String) prodottoLeasing.get('businessLeasing');
						String note = (String) prodottoLeasing.get('noteLeasing');
						testo = testo + 'LEASING - importo: €' + importo + ', business: ' + business + (note != null ? ', note: ' + note : '');
					}
				}
				if (actualWorkflow.Tipologia_Segnalazione__c.equals('LEASINGRENTAL')) {
					testo = testo + '<br>';
				}
				if (actualWorkflow.Tipologia_Segnalazione__c.equals('RENTAL') || actualWorkflow.Tipologia_Segnalazione__c.equals('LEASINGRENTAL')) {
					Map<String, Object> prodottoRental = bifis_crm_c_CommonUtils.parseProdottoJSON(actualWorkflow.PRD_RENTAL_JSON__c);
					if (prodottoRental != null) {
						String importo = (String) prodottoRental.get('importoRental');
						String business = (String) prodottoRental.get('businessRental');
						String note = (String) prodottoRental.get('noteRental');
						testo = testo + 'RENTAL - importo: €' + importo + ', business: ' + business + (note != null ? ', note: ' + note : '');
						System.debug('@@@ testo mail ' + testo);
					}
				}
				htmlBody += '<p>' + testo + '</p>';
				htmlBody += '<p><i>Note di Direzione Commerciale</i>: ' + (actualWorkflow.CommentoEsito__c != null ? actualWorkflow.CommentoEsito__c : '') + '</p>';
				htmlBody += '<p><i>Opportunità generata:</i> ' + fullFileURL + actualWorkflow.OpportunitaCollegata__c + '</p>';
				htmlBody += '<p><i>Allegati:</i></p>';

				List<Object> mapObj = bifis_crm_c_CommonUtils.parseDocumentJSON(actualWorkflow.DOCUMENTI_JSON__c);
				if (mapObj != null) {
					Integer count = 1;
					for (Object current : mapObj) {
						Map<String, Object> entry = (Map<String, Object>) current;
						String fileid = (String) entry.get('id');
						String fileName = (String) entry.get('fileName');
						htmlBody += fileName + ': ' + fullFileURL + fileid + '</p>';
						System.debug('---> idDoc: ' + fileid);
						count++;
					}
				}
				htmlBody += '<p>Procedi gentilmente con la verifica di fattibilità della segnalazione e dai un feedback al segnalatore.<br>Buon lavoro!</p>';
				mail.setHtmlBody(htmlBody);

				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			} catch(Exception ex) {

				System.debug('Errore invio mail leasing' + ex);
			}
		}
		result.esitoGlobale = true;
		result.timelineAggiornata = actualWorkflow.TIMELINE_JSON__c;
		result.statoAggiornato = actualWorkflow.Stato__c;
		result.erroreTecnico = '';
		return result;
	}

	private static String creaOpportunita(WorkflowSegnalatori__c actualWorkflow) {

		String importo;
		String business;
		String noteLeasing = '';
		String noteRental = '';

		WGC_ReferenteBU__mdt metadato = [SELECT WGC_Referente__c FROM WGC_ReferenteBU__mdt WHERE DeveloperName = 'Nucleo_CRM_Cross_Selling_Leasing_TR'];
		//Id ownerOpp;

		if (actualWorkflow.Tipologia_Segnalazione__c.equals('LEASING') || actualWorkflow.Tipologia_Segnalazione__c.equals('LEASINGRENTAL')) {
			Map<String, Object> prodottoLeasing = bifis_crm_c_CommonUtils.parseProdottoJSON(actualWorkflow.PRD_LEASING_JSON__c);
			if (prodottoLeasing != null) {
				importo = (String) prodottoLeasing.get('importoLeasing');
				business = (String) prodottoLeasing.get('businessLeasing');
				String note = (String) prodottoLeasing.get('noteLeasing');
				noteLeasing = 'Segnalazione LEASING - importo: €' + importo + ', business: ' + business + (note != null ? ', note: ' + note : '');
				//ownerOpp = accountSegnalazione.WGC_Specialista_Leasing_TR__c;
			}
		} if (actualWorkflow.Tipologia_Segnalazione__c.equals('RENTAL') || actualWorkflow.Tipologia_Segnalazione__c.equals('LEASINGRENTAL')) {
			Map<String, Object> prodottoRental = bifis_crm_c_CommonUtils.parseProdottoJSON(actualWorkflow.PRD_RENTAL_JSON__c);
			if (prodottoRental != null) {
				if (actualWorkflow.Tipologia_Segnalazione__c.equals('RENTAL')) {
					importo = (String) prodottoRental.get('importoRental');
					business = (String) prodottoRental.get('businessRental');
					String note = (String) prodottoRental.get('noteRental');
					noteRental = 'Segnalazione: RENTAL - importo: €' + importo + ', business: ' + business + (note != null ? ', note: ' + note : '');
					//ownerOpp = accountSegnalazione.WGC_Specialista_Leasing__c;
				} else {
					noteRental = '. Segnalazione: RENTAL - importo: €' + ((String) prodottoRental.get('importoRental')) + ', business: ' + ((String) prodottoRental.get('businessRental')) + (((String) prodottoRental.get('noteRental')) != null ? ', note: ' + ((String) prodottoRental.get('noteRental')) : '');
				}
			}
		}

		Opportunity opp = new Opportunity();
		Date calculateCloseDate = Date.today().addMonths(3);
		opp.CloseDate = Date.newInstance(calculateCloseDate.year(), calculateCloseDate.month(), calculateCloseDate.day());

		opp.Amount = Decimal.valueOf(String.valueOf(importo));
		opp.WGC_Tipologia_CrossSelling__c = 'Leasing';
		opp.WGC_Business_CrossSelling__c = String.valueOf(business);
		opp.WGC_Note_CrossSelling__c = noteLeasing + noteRental;

		opp.WGC_CrossSelling_Ownership_Sviluppo__c = 'Indiretto (Rete Leasing)';
		opp.WGC_Qualifica_Cliente_CrossSelling__c = actualWorkflow.AccountCollegato__r.WGC_Qualifica_Corporate__c;
		opp.RecordTypeId = '0124H000000sdICQAY';
		opp.AccountId = actualWorkflow.AccountCollegato__c;

		opp.OwnerId = metadato.WGC_Referente__c;
		opp.WGC_Segnalatore_CrossSelling__c = UserInfo.getUserId();
		opp.WGC_Prodotti_Selezionati__c = 'Leasing';
		opp.WGC_Prodotti_Cross_Selling_Selezionati__c = 'Leasing';
		opp.Tipologia_Opportunit__c = 'CROSS';
		opp.Originator__c = 'Segnalazione esterna';
		opp.Originator_di_dettaglio__c = 'Segnalatore esterno';
		opp.WGC_Forzatura__c = true;
		opp.WGC_Cross_Selling_JSON__c = '[]';
		opp.Name = 'TEST_' + Date.today().format() + actualWorkflow.AccountCollegato__r.Name;
		insert opp;

		return opp.Id;
	}

	public static Contact integraDatiMancanti(Contact contactDI, String referenti) {
		List<Object> mapRef = bifis_crm_c_CommonUtils.parseReferentiJSON(referenti);
		if (mapRef != null) {
			for (Object current : mapRef) {
				Map<String, Object> entry = (Map<String, Object>) current;
				if (entry.get('ruolo') != null && ((String) entry.get('ruolo')) == ('Titolare')) {
					String nome = (String) entry.get('nome');
					String cognome = (String) entry.get('cognome');
					String mailRef = (String) entry.get('mail');

					String dataNascita = (String) entry.get('dataNascita');
					String luogoNascita = (String) entry.get('luogoNascita');
					String nazioneNascita = (String) entry.get('nazioneNascita');
					String sesso = (String) entry.get('sesso');
					String codiceFiscale = (String) entry.get('codiceFiscale');
					String sae = (String) entry.get('sae');
					String tae = (String) entry.get('tae');

					String tipoDocumento = (entry.get('tipoDocumento') != null && (((String) entry.get('tipoDocumento')) == 'CI')) ? 'I' : 'S';
					String numeroDocumento = (String) entry.get('numeroDocumento');
					String luogoEmissioneDocumento = (String) entry.get('luogoEmissioneDocumento');
					String dataEmissioneDocumento = (String) entry.get('dataEmissioneDocumento');
					String dataScadenzaDocumento = (String) entry.get('dataScadenzaDocumento');

					if (contactDI.FirstName == null)
					contactDI.FirstName = nome;
					if (contactDI.LastName == null)
					contactDI.LastName = cognome;
					if (contactDI.Birthdate == null)
					contactDI.Birthdate = Date.valueOf(dataNascita);
					if (contactDI.LuogoNascita__c == null)
					contactDI.LuogoNascita__c = luogoNascita;
					if (contactDI.PaeseNascita__c == null)
					contactDI.PaeseNascita__c = nazioneNascita;
					if (contactDI.Sesso__c == null)
					contactDI.Sesso__c = sesso;
					if (contactDI.CF__c == null)
					contactDI.CF__c = codiceFiscale;
					if (contactDI.SAE__c == null)
					contactDI.SAE__c = sae;
					if (contactDI.TAECode__c == null)
					contactDI.TAECode__c = tae;
					if (contactDI.Email == null)
					contactDI.Email = mailRef;
					if (contactDI.TipoDocumentoId__c == null)
					contactDI.TipoDocumentoId__c = tipoDocumento;
					if (contactDI.NumeroDoc__c == null)
					contactDI.NumeroDoc__c = numeroDocumento;
					if (contactDI.DataEmissioneDoc__c == null)
					contactDI.DataEmissioneDoc__c = Date.valueOf(dataEmissioneDocumento);
					if (contactDI.DataScadenzaDoc__c == null)
					contactDI.DataScadenzaDoc__c = Date.valueOf(dataScadenzaDocumento);
					if (contactDI.LuogoEmissioneDoc__c == null)
					contactDI.LuogoEmissioneDoc__c = luogoEmissioneDocumento;
				}
			}
		}
		return contactDI;
	}

	public static boolean censimentoAccount(WorkflowSegnalatori__c actualWorkflow) {

		// PROCEDO AL CENSIMENTO DELL'ACCOUNT

		// ANCHE SE QUESTO ANDRA' IN ERRORE, ANDRO' COMUNQUE AVANTI, NOTIFICHERO' LA PROBLEMATICA NELLA
		// SCHEDA DELLA PRATICA (CAMPO Errori_Tecnici__c)

		// VERIFICO SE E' GIA' PRESENTE CONTROLLANDO l'ID ACCOUNT CHE HO ACQUISITO IN FASE DI CHECK NEL FLOW

		if (String.isBlank(actualWorkflow.AccountCollegato__c)) {

			// RIACQUISISCO IN TOTO I DATI SULL'ACCOUNT IN BASE ALLA FONTE CHE SARA' O RIBES O CEDACRI

			Account accountTrovato;

			List<Object> risultatoRicerca = bifis_crm_c_CommonUtils.checkPartitaIva(actualWorkflow.PartitaIVA__c);

			Boolean primaFaseControlliOK = true;

			if (risultatoRicerca.isEmpty()) {
				actualWorkflow.ErroriTecnici__c = 'Anomalia nella ricerca anagrafica. Nessun risultato trovato.';
				primaFaseControlliOK = false;
			}
			else {

				accountTrovato = (Account) risultatoRicerca[2];

				if (accountTrovato == null) {
					actualWorkflow.ErroriTecnici__c = 'Anomalia nella ricerca anagrafica. Oggetto Account nullo.';
					primaFaseControlliOK = false;
				}
			}

			// NOTIFICA DEGLI ERRORI NEL WORKFLOW

			if (!primaFaseControlliOK) {

				return false;
			}
			else {

				// SCRITTURA DELL'OGGETTO ACCOUNT TROVATO NEI SISTEMI ESETRNI
				// SE QUESTO NON GIA' PRESENTE IN CRM

				if (accountTrovato.Id == null) {
					insert accountTrovato;
				}

				// JOIN CON IL WORKFLOW

				actualWorkflow.AccountCollegato__c = accountTrovato.Id;
				actualWorkflow.ErroriTecnici__c = '';

				return true;

			}

		}

		return true;

	}

	@AuraEnabled
	public static List<Object> controlliFinali(String workflowRecordId) {

		List<Object> myResult = new List<Object> ();

		List<WorkflowSegnalatori__c> actualWorkflows = new List<WorkflowSegnalatori__c> ();

		actualWorkflows = [SELECT SAE__c, ProvinciaCCIAA__c, ATECO__c, CapLegale__c, TipoViaLegale__c, IndirizzoLegale__c, CivicoLegale__c, CittaLegale__c, ProvinciaLegale__c, NomeReferente__c, CognomeReferente__c, TelefonoReferente__c,
		                   REFERENTI_JSON__c, DOCUMENTI_JSON__c, Natura_Giuridica__c, Tipologia_Segnalazione__c, PRD_FACTORING_JSON__c, PRD_MUTUO_JSON__c, PRD_LEASING_JSON__c, PRD_RENTAL_JSON__c FROM WorkflowSegnalatori__c where Id = :workflowRecordId];

		boolean errorDetected = false;

		WorkflowSegnalatori__c actualWorkflow = actualWorkflows[0];

		String[] anagrafeErrors = new List<String> ();
		String[] configurazioneProdottoErrors = new List<String> ();
		String[] documentazioneErrors = new List<String> ();

		// ANAGRAFE

		//if(actualWorkflow.Natura_Giuridica__c == null){
		//anagrafeErrors.add('Natura Giuridica non valorizzata');errorDetected = true;
		//}
		//if(actualWorkflow.SAE__c == null){
		//anagrafeErrors.add('SAE non valorizzato');errorDetected = true;
		//}
		//if(actualWorkflow.ProvinciaCCIAA__c == null){
		//anagrafeErrors.add('Provincia CCIAA non valorizzata');errorDetected = true;
		//}
		//if(actualWorkflow.ATECO__c == null){
		//anagrafeErrors.add('ATECO non valorizzato');errorDetected = true;
		//}
		//if(actualWorkflow.CapLegale__c == null){
		//anagrafeErrors.add('CAP Sede Legale non valorizzato');errorDetected = true;
		//}
		//if(actualWorkflow.TipoViaLegale__c == null){
		//anagrafeErrors.add('Tipo Via Sede Legale non valorizzato');errorDetected = true;
		//}
		//if(actualWorkflow.IndirizzoLegale__c == null){
		//anagrafeErrors.add('Indirizzo Sede Legale non valorizzato');errorDetected = true;
		//}
		//if(actualWorkflow.CivicoLegale__c == null){
		//anagrafeErrors.add('Civico Sede Legale non valorizzato');errorDetected = true;
		//}
		//if(actualWorkflow.CittaLegale__c == null){
		//anagrafeErrors.add('Città Sede Legale non valorizzato');errorDetected = true;
		//}
		//if(actualWorkflow.ProvinciaLegale__c == null){
		//anagrafeErrors.add('Provincia Sede Legale non valorizzato');errorDetected = true;
		//}
		//if(!String.isBlank(actualWorkflow.CivicoLegale__c)){
		//if(!Pattern.matches('[a-zA-Z0-9]*', actualWorkflow.CivicoLegale__c)){
		//anagrafeErrors.add('Numero Civico Legale invalido (solo numeri e lettere)');errorDetected = true;
		//}
		//}

		// ANAGRAFE REFERENTI

		if (actualWorkflow.REFERENTI_JSON__c == '[]') {
			anagrafeErrors.add('Nessun referente inserito'); errorDetected = true;
		} else {

			if (!String.isBlank(actualWorkflow.Natura_Giuridica__c)) {

				if (actualWorkflow.Natura_Giuridica__c == 'DI') {

					List<Object> referenti = bifis_crm_c_CommonUtils.parseReferentiJSON(actualWorkflow.REFERENTI_JSON__c);
					Set<String> duplicateChecker = new Set<String> ();

					Integer codiceFiscaleCount = 0;
					Integer codiceFiscaleAnomalo = 0;

					for (Object current : referenti) {

						Map<String, Object> v = (Map<String, Object>) current;

						duplicateChecker.add((String) v.get('codiceFiscale'));
						codiceFiscaleCount++;

						String nome = (String) v.get('nome');
						String cognome = (String) v.get('cognome');
						String codiceFiscale = (String) v.get('codiceFiscale');

						UtilCodiceFiscale u = new UtilCodiceFiscale();

						if (u.calculateCognome(cognome) != codiceFiscale.substring(0, 3) || u.calculateNome(nome) != codiceFiscale.substring(3, 6)) {
							codiceFiscaleAnomalo++;
						}

					}

					if (duplicateChecker.size() <> codiceFiscaleCount) {
						anagrafeErrors.add('Codici Fiscali ripetuti tra i referenti'); errorDetected = true;
					}

					if (codiceFiscaleAnomalo > 0) {
						anagrafeErrors.add('Codice fiscale anomalo (verificare anche Nome e Cognome del referente)'); errorDetected = true;
					}
				}
			}

		}

		// CONFIGURAZIONE PRODOTTO   

		if (String.isBlank(actualWorkflow.NomeReferente__c)) {
			configurazioneProdottoErrors.add('Nome del referente della segnalazione non valorizzato'); errorDetected = true;
		}

		if (String.isBlank(actualWorkflow.CognomeReferente__c)) {
			configurazioneProdottoErrors.add('Cognome del referente della segnalazione non valorizzato'); errorDetected = true;
		}

		if (String.isBlank(actualWorkflow.TelefonoReferente__c)) {
			configurazioneProdottoErrors.add('Telefono del referente della segnalazione non valorizzato'); errorDetected = true;
		}


		if (String.isBlank(actualWorkflow.Tipologia_Segnalazione__c)) {
			configurazioneProdottoErrors.add('Tipologia Segnalazione non valorizzata'); errorDetected = true;
		}
		else {

			if (actualWorkflow.Tipologia_Segnalazione__c == 'FACTORING' || actualWorkflow.Tipologia_Segnalazione__c == 'MISTO') {

				Map<String, Object> prodotto = bifis_crm_c_CommonUtils.parseProdottoJSON(actualWorkflow.PRD_FACTORING_JSON__c);

				String fabbisognoFinanziarioFactoring = (String) prodotto.get('fabbisognoFinanziarioFactoring');

				if (String.isBlank(fabbisognoFinanziarioFactoring)) {
					configurazioneProdottoErrors.add('Fabbisogno Finanziario Factoring non valorizzato'); errorDetected = true;
				}

			}

			if (actualWorkflow.Tipologia_Segnalazione__c == 'MUTUO' || actualWorkflow.Tipologia_Segnalazione__c == 'MISTO') {

				Map<String, Object> prodotto = bifis_crm_c_CommonUtils.parseProdottoJSON(actualWorkflow.PRD_MUTUO_JSON__c);

				String importoMutuo = (String) prodotto.get('importoMutuo');
				String finalitaMutuo = (String) prodotto.get('finalitaMutuo');

				if (String.isBlank(importoMutuo)) {
					configurazioneProdottoErrors.add('Importo Mutuo non valorizzato'); errorDetected = true;
				}

				if (String.isBlank(finalitaMutuo)) {
					configurazioneProdottoErrors.add('Finalità Mutuo non valorizzata'); errorDetected = true;
				}

			}

			if (actualWorkflow.Tipologia_Segnalazione__c == 'LEASING' || actualWorkflow.Tipologia_Segnalazione__c == 'LEASINGRENTAL') {

				Map<String, Object> prodotto = bifis_crm_c_CommonUtils.parseProdottoJSON(actualWorkflow.PRD_LEASING_JSON__c);

				String importoLeasing = (String) prodotto.get('importoLeasing');
				String businessLeasing = (String) prodotto.get('businessLeasing');

				if (String.isBlank(importoLeasing)) {
					configurazioneProdottoErrors.add('Importo Leasing non valorizzato'); errorDetected = true;
				}

				if (String.isBlank(businessLeasing)) {
					configurazioneProdottoErrors.add('Business Leasing non valorizzata'); errorDetected = true;
				}

			}

			if (actualWorkflow.Tipologia_Segnalazione__c == 'RENTAL' || actualWorkflow.Tipologia_Segnalazione__c == 'LEASINGRENTAL') {

				Map<String, Object> prodotto = bifis_crm_c_CommonUtils.parseProdottoJSON(actualWorkflow.PRD_RENTAL_JSON__c);

				String importoRental = (String) prodotto.get('importoRental');
				String businessRental = (String) prodotto.get('businessRental');

				if (String.isBlank(importoRental)) {
					configurazioneProdottoErrors.add('Importo Rental non valorizzato'); errorDetected = true;
				}

				if (String.isBlank(businessRental)) {
					configurazioneProdottoErrors.add('Business Rental non valorizzata'); errorDetected = true;
				}

			}

		}

		// DOCUMENTI

		/*
		  if(actualWorkflow.DOCUMENTI_JSON__c == '[]'){
		  documentazioneErrors.add('Nessun documento caricato');errorDetected = true; 
		  }          
		 */

		myResult.add(anagrafeErrors);
		myResult.add(configurazioneProdottoErrors);
		myResult.add(documentazioneErrors);

		if (errorDetected)
		myResult.add(bifis_crm_c_CommonUtils.KO);
		else
		myResult.add(bifis_crm_c_CommonUtils.OK);

		return myResult;

	}

	@AuraEnabled
	public static void invioPratica(String workflowRecordId) {


		// CAMBIO STATO

		WorkflowSegnalatori__c actualWorkflow = new WorkflowSegnalatori__c();

		actualWorkflow = [SELECT id, Stato__c, Name, DataInvioIfis__c, Ragione_Sociale__c, PartitaIVA__c, TIMELINE_JSON__c, Ente_segnalante__c FROM WorkflowSegnalatori__c where Id = :workflowRecordId];

		if (actualWorkflow.Stato__c == 'BOZZA_DATI') {
			actualWorkflow.Stato__c = 'INVIATA';
			actualWorkflow.DataInvioIfis__c = Date.today();

			// SCRITTURA NEL WIDGET DELLA TIME LINE L'INVIO DELLA SEGNALAZIONE

			String descrizioneOperazione = 'Invio segnalazione da portale';
			String nuovoElementoJSON = '{"descrizione":"' + descrizioneOperazione + '","momento":' + System.currentTimeMillis() + ',"decoratore":"SENT", "utenteOperazione":"' + UserInfo.getName() + '"}';

			if (String.isBlank(actualWorkflow.TIMELINE_JSON__c)) {

				nuovoElementoJSON = '[' + nuovoElementoJSON + ']';

				actualWorkflow.TIMELINE_JSON__c = nuovoElementoJSON;

			}
			else {

				actualWorkflow.TIMELINE_JSON__c = actualWorkflow.TIMELINE_JSON__c.removeEnd(']');

				actualWorkflow.TIMELINE_JSON__c = actualWorkflow.TIMELINE_JSON__c + ',' + nuovoElementoJSON + ']';

			}

			if (actualWorkflow.Ente_segnalante__c.substring(0, 3) == 'LSG' || actualWorkflow.Ente_segnalante__c.substring(0, 3) == 'LSM' || actualWorkflow.Ente_segnalante__c.substring(0, 3) == 'LSF') {
				actualWorkflow.Tipo_Segnalatore__c = 'Partner';
			} else {
				actualWorkflow.Tipo_Segnalatore__c = 'Esterno';
			}
			update actualWorkflow;

			// INVIO MAIL A FINE PROCESSO

			/*String userName = UserInfo.getUserName();
			  User activeUser = [Select Email From User where Username = :userName limit 1];
			  String userEmail = activeUser.Email;
			 
			  Parametri_Segnalatori__c segnalatoriParameters = Parametri_Segnalatori__c.getInstance();
			  String destinationMail = segnalatoriParameters.Mail_Pre_Valutatore_Pratica__c;
			  String sourceMail = segnalatoriParameters.Mail_Mittente__c;
			 
			  // INVIO SOLO SE VALORIZZATA LA CUSTOM PROP
			 
			  if (!String.isBlank(descrizioneOperazione)) {
			 
			  OrgWideEmailAddress owa;
			  owa = [SELECT id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'CRM Multicanalità' limit 1];
			 
			  if (owa != null) {
			  bifis_crm_c_CommonUtils.sentMailToTheSubmitter(
			  owa.id,
			  destinationMail,
			  userEmail,
			  actualWorkflow.Ragione_Sociale__c,
			  actualWorkflow.PartitaIVA__c,
			  actualWorkflow.Id,
			  'SEGNALATORI'
			  );
			  }
			  }*/
		}

		return;

	}

	@AuraEnabled
	public static RisultatoPrevalutazione ricercaEnteSegnalante(String ownerId) {
		RisultatoPrevalutazione result = new RisultatoPrevalutazione();
		List<User> enteSegnalante = [SELECT Contact.Account.BI_CodiceAccordo__c, Contact.Account.Name from User where Id = :ownerId LIMIT 1];
		if (enteSegnalante != null && enteSegnalante.size() > 0) {
			result.esitoGlobale = true;
			result.erroreTecnico = '';
			result.idAccountCreato = enteSegnalante[0].Contact.Account.BI_CodiceAccordo__c;
			result.nomeAccountCreato = enteSegnalante[0].Contact.Account.Name;
		} else {
			result.esitoGlobale = false;
		}
		return result;
	}

	@AuraEnabled
	public static WorkflowSegnalatori__c ricaricaRecord(String recordId) {
		List<WorkflowSegnalatori__c> actualWorkflow = [select Id, OwnerId, Name, CreatedDate, ATECO__c, AccountCollegato__c, CapLegale__c, CittaLegale__c, CivicoLegale__c, CognomeReferente__c, DOCUMENTI_JSON__c, DataInvioIfis__c, EmailReferente__c, ErroriTecnici__c, IndirizzoLegale__c, MotivazioneRifiutoPrevalutazione__c, Natura_Giuridica__c, NomeReferente__c, OpportunitaCollegata__c, PRD_FACTORING_JSON__c, PRD_MUTUO_JSON__c, PartitaIVA__c FROM workflowsegnalatori__c where id = :recordId];
		System.debug(actualWorkflow);
		if (actualWorkflow.size() > 0)
		return actualWorkflow[0];
		return null;
	}

	@AuraEnabled
	public static Boolean ricercaProfiliAbilitati (String chiaveEnte) {
		System.debug('chiaveEnte: '+chiaveEnte);
		//A.M. Modificato il campo del metadato che funge da chiave di ricerca in quanto il "Developername" non può essere numerico
		//List<BI_PSE_Profili__mdt> abilitazioneProfilo = [select Id, DeveloperName, Visualizza_Prodotti_Multipli__c from BI_PSE_Profili__mdt where DeveloperName = :chiaveEnte];
		List<BI_PSE_Profili__mdt> abilitazioneProfilo = [select Id, DeveloperName, Codice_Segnalante__c, Visualizza_Prodotti_Multipli__c from BI_PSE_Profili__mdt where Codice_Segnalante__c = :chiaveEnte];
		
		if (abilitazioneProfilo != null && abilitazioneProfilo.size() > 0){
			return abilitazioneProfilo.get(0).Visualizza_Prodotti_Multipli__c;
		}
		return false;
	}

	@AuraEnabled
	public static BI_PSE_Profili__mdt getBI_PSE_Profili (String chiaveEnte) {
		System.debug('chiaveEnte: '+chiaveEnte);
		return [select Id, DeveloperName, Codice_Segnalante__c, Visualizza_Prodotti_Multipli__c, Opzioni_Business__c, Visualizza_Factoring__c, Visualizza_Leasing__c, Visualizza_Mutuo__c, Visualizza_Rental__c from BI_PSE_Profili__mdt where Codice_Segnalante__c = :chiaveEnte];
	}

	// MS
	@AuraEnabled
	public static WorkflowSegnalatori__c getEnteSegnalante (String workflowRecordCandidatoID) {
		return [select Id, Ente_segnalante__c from WorkflowSegnalatori__c WHERE Id = :workflowRecordCandidatoID];
	}
}