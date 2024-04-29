/**
 * Progetto:         Revisione componenti core per CRM 2.0.
 * Sviluppatore      Marco Bonin <marco.bonin@bancaifis.it>
 * Descrizione:      Classe di utility di inquiry sull'account ed oggetti correlati (Contatti/Comuni/etc..)
 *
*/

public class BI_COM_UtilitiesAnagrafiche_CODE {

	private static final String ORIGINE_CRM = 'CRM';
	private static final String ORIGINE_CEDACRI = 'Cedacri';
	private static final String ORIGINE_RIBES = 'Cerved';

	public class Specialisti {

		public String specialistaFactoring;
		public String specialistaFiloDiretto;

	}

	// RITORNA UNA LISTA DI COMUNI ANCHE IN BASE AL CAP
	// NEL CASO NON VENGA RITORNATO UN RISULTATO NELLA RICERCA CON CAP
	// VIENE TENTATA UNA RICERCA SUL CAP TESTA DI SERIE (AD EX. PER 30175 CERCA SU 30100).

	public static List<Comune__c> getComuni(Boolean includiStorici, String cap) {

		String actualQuery = 'SELECT id, Name, Provincia__c, Cap__c, FlagStorico__c FROM Comune__c WHERE FlagStorico__c = : includiStorici';

		if (String.isNotBlank(cap)) {

			actualQuery = actualQuery + ' AND Cap__c = : cap';

		}

		actualQuery = actualQuery + ' ORDER BY Name ASC';

		Comune__c[] actualComuni = Database.query(actualQuery);

		if (actualComuni.size() == 0 && !String.isEmpty(cap)) {
			if (cap.length() == 5) {

				if (!cap.substring(3).equals('00')) {

					cap = cap.substring(0, 3) + '00';

					return getComuni(includiStorici, cap);
				}

			}
		}

		return actualComuni;

	}

	public static String getNDGByPivaOverCRM(String piva, String instituteCode) {

		Account actualAccount = [SELECT Id, NDGGruppo__c FROM Account WHERE PIVA__c = :piva AND CodiceIstituto3N__c = :instituteCode LIMIT 1];

		return actualAccount.NDGGruppo__c;

	}

	public static String getNDGByPivaOverCedacri(String piva, String instituteCode) {

		List<Account> actualAccounts = WsAnagrafeUtils.searchPG(null, null, piva, null);

		if (actualAccounts.size() != 1)
		return null;

		return actualAccounts[0].NDGGruppo__c;

	}

	/*
	 *  Metodo che tronca a "6" il numero civico di un account in modo da essere salvabile
	 *  su Cedacri.
	 */

	public static Account truncateNumeroCivicoForCedacri(Account actualAccount) {

		String numeroCivicoForCedacri = actualAccount.BillingStreetNumber__c;

		if (!String.isEmpty(numeroCivicoForCedacri)) {

			if (numeroCivicoForCedacri.length() > 6) {
				actualAccount.BillingStreetNumber__c = numeroCivicoForCedacri.substring(0, 6);
			}

		}

		return actualAccount;

	}

	/*
	 *  Metodo che ricerca un account in cascata, su CRM / CEDACRI / RIBES
	 *  Se non trova nulla ritorna "null" in modo che chi chiama possa fare la gestione
	 *  più opportuna rispetto al suo contesto. 
	 */

	public static Account searchAccountOverAllSystems(String partitaIva, String provincia) {

		Account[] accsSuCrm = [
		                       SELECT Id, OwnerId, RecordType.DeveloperName, Ateco__c,
		                       BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingCity__c, BillingCountry__c, BillingPostalCode__c, BillingState__c, BillingStreetName__c, BillingStreetNumber__c, BillingStreetType__c,
		                       BU__c,
		                       CF__c,
		                       ComportamentoRilevato__c,
		                       ConsensoAllaProfilazione__c,
		                       ConsensoAttivitaPromozionaleTerzi__c, ConsensoAttivitaPromRicercheMercato__c, ConsensoProdottiBancaRicercheMercato__c, ConsensoProdottiSocietaTerze__c, ConsensoSoloModalitaTradizionali__c,
		                       DataFatturato__c,
		                       DataInserimentoConsensi__c,
		                       DataIscrizioneCCIAA__c,
		                       DettaglioCensimento__c,
		                       Email__c,
		                       Fatturato__c,
		                       Fax,
		                       GestoreCliente__c,
		                       GestoreDebitore__c,
		                       Name,
		                       NaturaGiuridica__c,
		                       NDGGruppo__c,
		                       Owner.NDGGruppo__c,
		                       PaeseSvolgimentoAttivitaPrevalente__c,
		                       PIVA__c,
		                       ProvinciaAttivitaPrevalente__c,
		                       ProvinciaCCIAA__c,
		                       CCIAA__c,
		                       QualificaCliente__c,
		                       REA__c,
		                       SAE__c,
		                       ScopoRapporto__c,
		                       ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingCity__c, ShippingCountry__c, ShippingPostalCode__c, ShippingState__c, ShippingStreetName__c, ShippingStreetNumber__c, ShippingStreetType__c,
		                       StatoCensimento__c,
		                       TAG_Controllante__c,
		                       Tag_Caricamento__c,
		                       TipologiaCliente__c,
		                       WGC_Canale_di_sviluppo__c,
		                       WGC_Censimento__c,
		                       TAECode__c,
		                       TelefonoNumero__c,
		                       TelefonoPrefisso__c,
		                       NumberOfEmployees,
		                       WGC_Filo_Diretto_Attivo__c,
		                       WGC_Giorni_Inattivita_Filo_Diretto__c,
		                       WGC_Giorni_Ex_cliente_Filo_Diretto__c,
		                       WGC_Numero_Dipendenti__c,
		                       WGC_Originator__c, WGC_Originator_dettaglio__c,
		                       Origine__c,
		                       WGC_Specialista_Factoring__c, WGC_Specialista_Filo_Diretto__c,
		                       WGC_Specialista_Factoring__r.Name,
		                       WGC_Specialista_Factoring__r.EMail,
		                       WGC_Factoring_Attivo__c,
							   WGC_Qualifica_Corporate__c
		                       FROM Account
		                       WHERE(PIVA__c = :partitaIva OR CF__c = :partitaIva)
		                       AND CodiceIstituto3N__c = :CtrlWizardAccount.CI3N_FACTORING
		                      ];

		Account foundAccount;

		if (accsSuCrm.size() <= 0) {

			// NESSUN ACCOUNT SU CRM, LA RICERCA PASSA SU CEDACRI

			List<Account> result_cedacri = WsAnagrafeUtils.searchPG(null, null, partitaIva, null);

			if (result_cedacri.size() <= 0) {

				// NESSUN ACCOUNT SU CEDACRI, LA RICERCA PASSA SU RIBES

				Account[] accsCervedAttivi = new Account[] { };
				List<Account> result_ribes = CtrlWizardAccount.searchAnagraficaRibes(null, partitaIva, null);

				for (Account a : result_ribes) {

					accsCervedAttivi.add(a);

				}
				if (accsCervedAttivi.size() > 0) {

					foundAccount = accsCervedAttivi[0];
					foundAccount.Origine__c = ORIGINE_RIBES;
					WsRestRibesUtils ribesUtils = new WsRestRibesUtils();
					foundAccount = ribesUtils.updateDatiAnagraficiRibesPg(foundAccount);

				}

			} else {

				foundAccount = result_cedacri[0];
				foundAccount.Origine__c = ORIGINE_CEDACRI;

			}

		} else {

			if (accsSuCrm.size() > 1) throw new Ex.BtcConvertLeadException('Non è stato possibile qualificare il lead perchè esiste più di un account con la stessa partita iva su CRM');
			foundAccount = accsSuCrm[0];
			foundAccount.Origine__c = ORIGINE_CRM;

		}

		if (foundAccount == null) {

			return foundAccount;

		}

		// MARCO BONIN: IN VIA SPERIMENTALE COMMENTO QUESTO PEZZO CHE DOVREBBE AVER PERSO SENSO PER 2 MOTIVI:
		// ABBIAMO SEMPRE UN NDG
		// IL DWH SI RIVERSA SU CRM OGNI NOTTE

		foundAccount = CtrlWizardAccount.setupAccount(foundAccount);

		foundAccount = truncateNumeroCivicoForCedacri(foundAccount);

		return foundAccount;
	}

	public static Contact createNewContactFromLead(Lead actualLead, Account actualAccount) {
		String webFormPhone = '';
		webFormPhone += (String.isNotBlank(actualLead.Phone)) ? actualLead.Phone : '';
		webFormPhone += (String.isNotBlank(actualLead.MobilePhone)) ? ((String.isNotBlank(webFormPhone)) ? ' ' + actualLead.MobilePhone : actualLead.MobilePhone) : '';

		Contact c = new Contact(
		                        FirstName = actualLead.FirstName,
		                        LastName = actualLead.LastName,
		                        //adione SDHDFNZ-81466 salviamo il numero nel nuovo campo, poi il trigger lo riporta sul campo phone
		                        //altrimenti il trigger lo andrebbe a sbiancare in creazione
		                        TelefonoNumero__c = webFormPhone,
		                        //adione SDHDFNZ-77918 il num. inserito nella web-form va mantenuto
		                        OtherPhone = webFormPhone,
		                        Email = actualLead.Email,
		                        MailingState = actualLead.State,
		                        MailingPostalCode = actualLead.PostalCode,
		                        MailingStreet = actualLead.Street,
		                        MailingCity = actualLead.City,
		                        MailingStreetType__c = actualLead.WGC_Tipo_Via__c,
		                        CF__c = actualLead.WGC_Codice_Fiscale__c,
		                        Sesso__c = actualLead.WGC_Sesso__c,

		                        AccountId = actualAccount.Id
		);

		Contact[] contattoDaLead = [SELECT
		                            Id,
		                            FirstName,
		                            LastName
		                            FROM Contact
		                            WHERE Id IN(SELECT ContactId FROM AccountContactRelation WHERE AccountId = :actualAccount.Id)
		                            AND FirstName = :actualLead.FirstName
		                            AND LastName = :actualLead.LastName
		                            AND Email = :actualLead.Email
		                            AND Phone = :actualLead.Phone
		                           ];

		if (!contattoDaLead.isEmpty()) {
			c.Id = contattoDaLead[0].Id;
		}

		return c;
	}

	/*
	 *  Metodo che ottiene i rispettivi specialisti secondo
	 *  le regole d'ingaggio.
	 */

	public static Specialisti calcolaSpecialistiAccount(id actualAccountId) {

		Map<String, Set<Id>> specialistiFactoring = new Map<String, Set<Id>> ();
		Map<String, Set<Id>> managersFactoring = new Map<String, Set<Id>> ();
		Map<String, Set<Id>> specialistiFilo_Diretto = new Map<String, Set<Id>> ();
		Map<String, Set<Id>> managersFilo_Diretto = new Map<String, Set<Id>> ();

		Account actualAccount = [SELECT Id, BillingPostalCode, BillingCity, BillingPostalCode__c, BillingState FROM Account WHERE Id = :actualAccountId];

		Specialisti actualSpecialisti = new Specialisti();

		// RETE COMMERCIALE

		List<AssegnazioneAnagrafica__c> assegnazioniSC = [SELECT Id, IdUtente__c, Filiale__c, FiloDiretto__c, RefPrincipale__c, SviluppoDiretto__c,
		                                                  ProvinciaComune__c, CAP__c, SviluppoIndiretto__c, Web__c, Comune__r.Cap__c,
		                                                  Comune__r.Cin__c, Comune__r.CodiceCatastale__c, Comune__r.Name, Utente__c,
		                                                  Utente__r.Qualifica_Utente__c, Utente__r.Profile.Name, Utente__r.ManagerId, WGC_Filo_Diretto_Web__c
		                                                  FROM AssegnazioneAnagrafica__c
		                                                  WHERE CAP__c = :actualAccount.BillingPostalCode__c AND(Utente__r.Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali')];

		List<AssegnazioneAnagrafica__c> assegnazioniFD = [SELECT Id, IdUtente__c, Filiale__c, FiloDiretto__c, RefPrincipale__c, SviluppoDiretto__c,
		                                                  ProvinciaComune__c, CAP__c, SviluppoIndiretto__c, Web__c, Comune__r.Cap__c,
		                                                  Comune__r.Cin__c, Comune__r.CodiceCatastale__c, Comune__r.Name, Utente__c,
		                                                  Utente__r.Qualifica_Utente__c, Utente__r.Profile.Name, Utente__r.ManagerId, WGC_Filo_Diretto_Web__c
		                                                  FROM AssegnazioneAnagrafica__c
		                                                  WHERE CAP__c = :actualAccount.BillingPostalCode__c AND(Utente__r.Qualifica_Utente__c = 'Filo Diretto')];

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

		actualSpecialisti.specialistaFactoring = WGC_TrgAccount.getSpecialista(actualAccount.BillingPostalCode + '_' + actualAccount.BillingCity + '_' + actualAccount.BillingState, specialistiFactoring, managersFactoring, actualSpecialisti.specialistaFactoring);

		// FILO DIRETTO

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

		actualSpecialisti.specialistaFiloDiretto = WGC_TrgAccount.getSpecialista(actualAccount.BillingPostalCode + '_' + actualAccount.BillingCity + '_' + actualAccount.BillingState, specialistiFilo_Diretto, managersFilo_Diretto, actualSpecialisti.specialistaFiloDiretto);

		return actualSpecialisti;

	}

	/*
	 *  Metodo che crea un task abbinato all'account secondo le specifiche
	 *  dei parametri passati in ingresso.
	 */

	public static Task creaTaskSuAccount(WorkflowSegnalatori__c actualWorkflow, id ownerId, String status, String titolo, String esitoLivello1, String recordType) {

		String originator = (actualWorkflow.Tipo_Segnalatore__c == 'Partner')? 'Cross Selling' : 'Segnalazione esterna';
		String originatorDettaglio = (actualWorkflow.Tipo_Segnalatore__c == 'Partner')? 'Leasing' : 'Segnalatore esterno';

		Task newTask = new Task(

		                        WhatId = actualWorkflow.AccountCollegato__c,
		                        OwnerId = ownerId,
		                        Status = status,
		                        Subject = titolo,
		                        ActivityDate = Date.today(),
		                        RecordTypeId = U.getRecordTypes('Task').get(recordType).Id,
		                        Data_Inizio__c = System.now(),
		                        Data_Fine__c = System.now(),
								Originator__c = originator,
								Originator_di_dettaglio__c = originatorDettaglio,
            					WGC_IsCreatedFromLead__c = true,
								WGC_Forzatura__c = true
		);

		newTask.EsitoLivello1__c = esitoLivello1;

		String testo = 'Ente segnalante: ' + actualWorkflow.Ente_segnalante_descrizione__c + '_';

		/*List<Object> mapRef = bifis_crm_c_CommonUtils.parseReferentiJSON(actualWorkflow.REFERENTI_JSON__c);

		if (mapRef != null) {
			testo = testo + 'Referente Azienda: ';
			for (Object current : mapRef) {
				Map<String, Object> entry = (Map<String, Object>) current;
				String nome = (String) entry.get('nome');
				String cognome = (String) entry.get('cognome');
				String ruolo = (String) entry.get('ruolo');
				String telefono = (String) entry.get('telefono');
				String mailRef = (String) entry.get('mail');
				testo = testo + (nome != null ? nome : '') + ' ' + (cognome != null ? cognome : '') + ' (' + (ruolo != null ? ruolo : '') + ') ' + (telefono != null ? telefono : '') + ' - ' + (mailRef != null ? mailRef : '');
				System.debug('@@@ testo mail ' + testo);
				testo = testo + '\n';
			}
		}

		testo += 'Referente ente segnalante: ' + (actualWorkflow.NomeReferente__c != null ? actualWorkflow.NomeReferente__c : '') + ' ' + (actualWorkflow.CognomeReferente__c != null ? actualWorkflow.CognomeReferente__c : '') + ' ' + (actualWorkflow.TelefonoReferente__c != null ? actualWorkflow.TelefonoReferente__c : '') + ' - ' + (actualWorkflow.EmailReferente__c != null ? actualWorkflow.EmailReferente__c : '' +'\n');
		*/

		if (actualWorkflow.Tipologia_Segnalazione__c.equals('FACTORING') || actualWorkflow.Tipologia_Segnalazione__c.equals('MISTO')) {
			Map<String, Object> prodottoFactoring = bifis_crm_c_CommonUtils.parseProdottoJSON(actualWorkflow.PRD_FACTORING_JSON__c);
			if (prodottoFactoring != null) {
				String fabbisognoFinanziarioFactoring = (String) prodottoFactoring.get('fabbisognoFinanziarioFactoring');
				String naturaClientiFactoring = (String) prodottoFactoring.get('naturaClientiFactoring');
				String nazionalitaClientiFactoring = (String) prodottoFactoring.get('nazionalitaClientiFactoring');
				String noteFactoring = (String) prodottoFactoring.get('noteFactoring');
				testo = testo + 'FACTORING, ' + (fabbisognoFinanziarioFactoring != null ? ('importo:' + fabbisognoFinanziarioFactoring) : '') + ', ' + (naturaClientiFactoring != null ? ('clienti:' + naturaClientiFactoring) : '') + ', ' + (nazionalitaClientiFactoring != null ? ('naz:' + nazionalitaClientiFactoring) : '');
			}
		}
		if (actualWorkflow.Tipologia_Segnalazione__c.equals('MISTO')) {
			testo = testo + '_';
		}
		if (actualWorkflow.Tipologia_Segnalazione__c.equals('MUTUO') || actualWorkflow.Tipologia_Segnalazione__c.equals('MISTO')) {
			Map<String, Object> prodottoMutuo = bifis_crm_c_CommonUtils.parseProdottoJSON(actualWorkflow.PRD_MUTUO_JSON__c);
			if (prodottoMutuo != null) {
				String importoMutuo = (String) prodottoMutuo.get('importoMutuo');
				String durataAmmortamentoMutuo = (String) prodottoMutuo.get('durataAmmortamentoMutuo');
				String durataPreammortamentoMutuo = (String) prodottoMutuo.get('durataPreammortamentoMutuo');
				String finalitaMutuo = (String) prodottoMutuo.get('finalitaMutuo');
				String noteMutuo = (String) prodottoMutuo.get('noteMutuo');
				testo = testo + 'MUTUO, ' + (importoMutuo != null ? ('importo:' + importoMutuo) : '') + ', ' + (durataAmmortamentoMutuo != null ? ('durata amm:' + durataAmmortamentoMutuo) : '') + ', ' + (durataPreammortamentoMutuo != null ? ('durata preamm:' + durataPreammortamentoMutuo) : '') + ', ' + (finalitaMutuo != null ? ('finalità:' + finalitaMutuo) : '');
			}
		}
		newTask.CommentiEsito__c = testo.length()>255 ? testo.substring(0,255) : testo;

		return newTask;
	}

}