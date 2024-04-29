public without sharing class TrgCessione {
	//adione CRM20 gestione originator
	private static String taDevName = 'Portali_TiAnticipo_Area_Riservata';

	// BEFORE INSERT
	public static void popolaDataUltimoAccesso(T tu) {
		Datetime now = Datetime.now();
		for (Cessione__c cess : (Cessione__c[]) tu.triggerNew) {
			cess.DataUltimoAccesso__c = now;
		}
	}

	//BEFORE INSERT
	public static void rinominaCessione(T tu) {
		String rename = getCessioneName();
		U.massSet(tu.triggerNew, 'Name', rename);
	}

	//BEFORE INSERT
	public static void assegnaCoda(T tu) {
		Group codaCessioni = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'AssegnazioneCessioni'];
		U.massSet(tu.triggerNew, 'OwnerId', codaCessioni.Id);
	}

	//BEFORE UPDATE
	public static void popolaTimestamp(T tu) {
		Cessione__c[] cessioni1 = tu
		.filterByOld('DataPraticaAnalisi__c', null)
		.filterByOld('Stato__c', '1')
		.filter('Stato__c', '2')
		.getChanged(new String[] { 'Stato__c' });
		U.massSet(cessioni1, 'DataPraticaAnalisi__c', Datetime.now());

		Cessione__c[] cessioni2 = tu
		.filterByOld('DataPraticaPerfezionamento__c', null)
		.filterByOld('Stato__c', '2')
		.filter('Stato__c', '3')
		.getChanged(new String[] { 'Stato__c' });
		U.massSet(cessioni2, 'DataPraticaPerfezionamento__c', Datetime.now());

		Cessione__c[] cessioni3 = tu
		.filterByOld('DataPraticaPagamento__c', null)
		.filterByOld('Stato__c', '3')
		.filter('Stato__c', '4')
		.getChanged(new String[] { 'Stato__c' });
		U.massSet(cessioni3, 'DataPraticaPagamento__c', Datetime.now());

		Cessione__c[] cessioni4 = tu
		.filterByOld('DataPraticaPersa__c', null)
		.filter('Stato__c', '5')
		.getChanged(new String[] { 'Stato__c' });
		U.massSet(cessioni4, 'DataPraticaPersa__c', Datetime.now());
	}

	//AFTER INSERT
	//prendo account e prendo contatti con titolare default e esecutore default e fare lookup da cessione
	public static void setAttoriDefault(T tu) {
		Cessione__c[] cessioni = tu.triggerNew;

		//prendo opty
		Map<String, SObject> optyByCessione = U.keyBy(
		                                              [SELECT Id, Cessione__c FROM Opportunity WHERE Cessione__c IN : cessioni],
		                                              'Cessione__c');

		Set<Id> idAccs = U.getIdSet(cessioni, 'Account__c');

		Map<String, Contact[]> contactByAcc = U.groupBy(
		                                                [SELECT Id, AccountId, EsecutoreDefault__c, TitolareDefault__c
		                                                FROM Contact
		                                                WHERE AccountId IN : idAccs
		                                                AND(EsecutoreDefault__c = true OR TitolareDefault__c = true)],
		                                                'AccountId');

		Id rt = U.getRecordTypes('NDGLinea__c').get('Referente').Id;
		NDGLinea__c[] toInsert = new NDGLinea__c[] { };
		for (Cessione__c cessione : cessioni) {
			Contact[] contacts = contactByAcc.get(cessione.Account__c);
			Opportunity opty = (Opportunity) optyByCessione.get(cessione.Id);

			if (contacts != null && opty != null) {
				for (Contact con : contacts) {
					NDGLinea__c tmpExec = new NDGLinea__c(
					                                      Cessione__c = cessione.Id,
					                                      Opportunita__c = opty.Id,
					                                      RecordTypeId = rt
					);

					if (con.EsecutoreDefault__c) {
						tmpExec.Contact__c = con.Id;
						tmpExec.Tipo__c = 'Esecutore adeguata verifica';
						toInsert.add(tmpExec);
					}

					if (con.TitolareDefault__c) {
						NDGLinea__c tmpTit = tmpExec.clone(false, true, false, false);
						tmpTit.Contact__c = con.Id;
						tmpTit.Tipo__c = 'Titolare effettivo adeguata verifica';
						toInsert.add(tmpTit);
					}
				}
			}
		}
		insert toInsert;
	}

	/**
	 * AFTER UPDATE
	 * Invio di mail per le cessioni TiAnticipo:
	 */
	public static void inviaMail(T tu) {

		if (MailUtils.isMailTiAnticipoDisabilitate) return;

		// recupero le cessioni di interesse
		Cessione__c[] cessioni = new Cessione__c[] { };
		cessioni.addAll((Cessione__c[]) tu.filter('Stato__c', '2').getChanged('Stato__c')); // cessioni diventate in stato pratica
		cessioni.addAll((Cessione__c[]) tu.filter('Stato__c', '3').getChanged('Stato__c')); // cessioni diventate in perfezionamento
		cessioni.addAll((Cessione__c[]) tu.filter('Stato__c', '4').getChanged('Stato__c')); // cessioni diventate in pagamento
		cessioni.addAll((Cessione__c[]) tu.filter('Stato__c', '5').getChanged('Stato__c')); // cessioni diventate chiuse
		Set<Id> cessioniIds = U.getIdSet(cessioni, 'Id');

		if (cessioni.size() == 0) return;

		Messaging.SingleEmailMessage[] mails = new Messaging.SingleEmailMessage[] { };
		String[] toAddresses;
		String[] ccAddresses;
		String[] bccAddresses;
		ParametriTiAnticipo__c parametriTA = ParametriTiAnticipo__c.getInstance();
		bccAddresses = new String[] { parametriTA.Mail_Segnalazione_Errori__c };

		Map<String, SObject> emailTemplates = U.keyBy([
		                                              SELECT Id,
		                                              DeveloperName
		                                              FROM EmailTemplate
		                                              WHERE DeveloperName IN('TiAnticipo1', 'TiAnticipo5', 'TiAnticipo6', 'TiAnticipo11', 'TiAnticipo12', 'TiAnticipo14', 'TiAnticipo15')], 'DeveloperName');

		// recupero gli indirizzi email delle filiali di riferimento..
		Map<String, IndirizziFiliali__mdt[]> indirizziFiliali = U.groupBy([
		                                                                  SELECT Id,
		                                                                  DeveloperName,
		                                                                  Email__c,
		                                                                  EmailGestore__c
		                                                                  FROM IndirizziFiliali__mdt
		                                                                  ], 'DeveloperName');

		// ..e la filiale salvata sull'opportunità
		Map<String, Opportunity[]> oppPerCessione = U.groupBy([
		                                                      SELECT Id,
		                                                      Cessione__c,
		                                                      Cessione__r.CreatedBy.Email,
		                                                      Account.Filiale__c
		                                                      FROM Opportunity
		                                                      WHERE Cessione__c IN :cessioniIds], 'Cessione__c');

		Map<String, OrgWideEmailAddress[]> senderIds = U.groupBy([
		                                                         SELECT Id,
		                                                         DisplayName
		                                                         FROM OrgWideEmailAddress], 'DisplayName');

		// per ognuna di queste, invio una mail:
		for (Cessione__c c : cessioni) {
			// cessioni in analisi pratica
			if (c.Stato__c == '2') {

				// Codice notifica 102
				toAddresses = new String[] { MailUtils.EMAIL_SEGRETERIA_FIDI };
				ccAddresses = new String[] { MailUtils.EMAIL_FILO_DIRETTO };

				if (emailTemplates.containsKey('TiAnticipo1') && senderIds.containsKey('Portale TiAnticipo'))
				mails.add(MailUtils.creaMailApexHTML(c.Id, emailTemplates.get('TiAnticipo1').Id, null, senderIds.get('Portale TiAnticipo') [0].Id, null, toAddresses, ccAddresses, bccAddresses));

				continue;
			}

			// cessioni in perfezionamento - approvate - totale - digitale
			if (c.Stato__c == '3' && c.ImportoTotaleCertificazioni__c == c.ImportoTotaleCertificazioniOriginario__c && c.FirmaDigitale__c) {

				// Codice notifica 108 FD / 107 FA ---> 112 D
				toAddresses = new String[] { oppPerCessione.get(c.Id) [0].Cessione__r.CreatedBy.Email };
				ccAddresses = new String[] { MailUtils.EMAIL_FILO_DIRETTO };
				if (emailTemplates.containsKey('TiAnticipo5') && senderIds.containsKey('Portale TiAnticipo'))
				mails.add(MailUtils.creaMailApexHTML(c.Id, emailTemplates.get('TiAnticipo5').Id, null, senderIds.get('Portale TiAnticipo') [0].Id, null, toAddresses, ccAddresses, bccAddresses));

				continue;
			}

			// cessioni in perfezionamento - approvate - totale - autografa
			if (c.Stato__c == '3' && c.ImportoTotaleCertificazioni__c == c.ImportoTotaleCertificazioniOriginario__c && !c.FirmaDigitale__c) {

				// Codice notifica 108 FD / 107 FA ---> 112 A
				toAddresses = new String[] { oppPerCessione.get(c.Id) [0].Cessione__r.CreatedBy.Email };
				ccAddresses = new String[] { MailUtils.EMAIL_FILO_DIRETTO };
				if (emailTemplates.containsKey('TiAnticipo6') && senderIds.containsKey('Portale TiAnticipo'))
				mails.add(MailUtils.creaMailApexHTML(c.Id, emailTemplates.get('TiAnticipo6').Id, null, senderIds.get('Portale TiAnticipo') [0].Id, null, toAddresses, ccAddresses, bccAddresses));

				continue;
			}


			// cessioni in perfezionamento - approvate - parziale - digitale
			if (c.Stato__c == '3' && c.ImportoTotaleCertificazioni__c != c.ImportoTotaleCertificazioniOriginario__c && c.FirmaDigitale__c) {

				// Codice notifica 111 FD / 110 FA ---> 113 D
				toAddresses = new String[] { oppPerCessione.get(c.Id) [0].Cessione__r.CreatedBy.Email };
				ccAddresses = new String[] { MailUtils.EMAIL_FILO_DIRETTO };
				if (emailTemplates.containsKey('TiAnticipo5') && senderIds.containsKey('Portale TiAnticipo'))
				mails.add(MailUtils.creaMailApexHTML(c.Id, emailTemplates.get('TiAnticipo5').Id, null, senderIds.get('Portale TiAnticipo') [0].Id, null, toAddresses, ccAddresses, bccAddresses));

				continue;
			}

			// cessioni in perfezionamento - approvate - parziale - autografa
			if (c.Stato__c == '3' && c.ImportoTotaleCertificazioni__c != c.ImportoTotaleCertificazioniOriginario__c && !c.FirmaDigitale__c) {

				// Codice notifica 111 FD / 110 FA ---> 113 A
				toAddresses = new String[] { oppPerCessione.get(c.Id) [0].Cessione__r.CreatedBy.Email };
				ccAddresses = new String[] { MailUtils.EMAIL_FILO_DIRETTO };
				if (emailTemplates.containsKey('TiAnticipo6') && senderIds.containsKey('Portale TiAnticipo'))
				mails.add(MailUtils.creaMailApexHTML(c.Id, emailTemplates.get('TiAnticipo6').Id, null, senderIds.get('Portale TiAnticipo') [0].Id, null, toAddresses, ccAddresses, bccAddresses));

				continue;
			}

			// cessioni in pagamento - totale
			if (c.Stato__c == '4' && c.ImportoTotaleCertificazioni__c == c.ImportoTotaleCertificazioniOriginario__c) {

				// Codice notifica 116 FA ---> 120 A
				if (!c.FirmaDigitale__c) {
					if (indirizziFiliali.containsKey('F' + oppPerCessione.get(c.Id) [0].Account.Filiale__c)) {
						IndirizziFiliali__mdt indirizziFiliale = indirizziFiliali.get('F' + oppPerCessione.get(c.Id) [0].Account.Filiale__c) [0];
						if (String.isNotBlank(indirizziFiliale.Email__c) && String.isNotBlank(indirizziFiliale.EmailGestore__c)) {
							toAddresses = new String[] { indirizziFiliale.Email__c };
							ccAddresses = new String[] { indirizziFiliale.EmailGestore__c };
							if (emailTemplates.containsKey('TiAnticipo11') && senderIds.containsKey('Gestione Debitori'))
							mails.add(MailUtils.creaMailApexHTML(c.Id, emailTemplates.get('TiAnticipo11').Id, null, senderIds.get('Gestione Debitori') [0].Id, null, toAddresses, ccAddresses, bccAddresses));
						}
					}
				}

				// Codice notifica 118 FD ---> 120 D
				if (c.FirmaDigitale__c) {
					toAddresses = new String[] { MailUtils.EMAIL_CMD };
					ccAddresses = null;
					if (emailTemplates.containsKey('TiAnticipo11') && senderIds.containsKey('Gestione Debitori'))
					mails.add(MailUtils.creaMailApexHTML(c.Id, emailTemplates.get('TiAnticipo11').Id, null, senderIds.get('Gestione Debitori') [0].Id, null, toAddresses, ccAddresses, bccAddresses));
				}


				// Codice notifica 119 FD / 117 FA ---> 121
				toAddresses = new String[] { oppPerCessione.get(c.Id) [0].Cessione__r.CreatedBy.Email };
				ccAddresses = new String[] { MailUtils.EMAIL_FILO_DIRETTO };
				if (emailTemplates.containsKey('TiAnticipo12') && senderIds.containsKey('Portale TiAnticipo'))
				mails.add(MailUtils.creaMailApexHTML(c.Id, emailTemplates.get('TiAnticipo12').Id, null, senderIds.get('Portale TiAnticipo') [0].Id, null, toAddresses, ccAddresses, bccAddresses));

				continue;
			}

			// cessioni in pagamento - parziale
			if (c.Stato__c == '4' && c.ImportoTotaleCertificazioni__c != c.ImportoTotaleCertificazioniOriginario__c) {

				// Codice notifica 118 FA ---> 122 A
				if (indirizziFiliali.containsKey('F' + oppPerCessione.get(c.Id) [0].Account.Filiale__c)) {
					IndirizziFiliali__mdt indirizziFiliale = indirizziFiliali.get('F' + oppPerCessione.get(c.Id) [0].Account.Filiale__c) [0];
					if (String.isNotBlank(indirizziFiliale.Email__c) && String.isNotBlank(indirizziFiliale.EmailGestore__c)) {
						toAddresses = new String[] { indirizziFiliale.Email__c };
						ccAddresses = new String[] { indirizziFiliale.EmailGestore__c };
						if (emailTemplates.containsKey('TiAnticipo11') && senderIds.containsKey('Gestione Debitori'))
						mails.add(MailUtils.creaMailApexHTML(c.Id, emailTemplates.get('TiAnticipo11').Id, null, senderIds.get('Gestione Debitori') [0].Id, null, toAddresses, ccAddresses, bccAddresses));
					}
				}

				// Codice notifica 120 FD ---> 122 D
				toAddresses = new String[] { MailUtils.EMAIL_CMD };
				ccAddresses = null;
				if (emailTemplates.containsKey('TiAnticipo11') && senderIds.containsKey('Gestione Debitori'))
				mails.add(MailUtils.creaMailApexHTML(c.Id, emailTemplates.get('TiAnticipo11').Id, null, senderIds.get('Gestione Debitori') [0].Id, null, toAddresses, ccAddresses, bccAddresses));

				// Codice notifica 121 FD / 119 FA ---> 123
				toAddresses = new String[] { oppPerCessione.get(c.Id) [0].Cessione__r.CreatedBy.Email };
				ccAddresses = new String[] { MailUtils.EMAIL_FILO_DIRETTO };
				if (emailTemplates.containsKey('TiAnticipo12') && senderIds.containsKey('Portale TiAnticipo'))
				mails.add(MailUtils.creaMailApexHTML(c.Id, emailTemplates.get('TiAnticipo12').Id, null, senderIds.get('Portale TiAnticipo') [0].Id, null, toAddresses, ccAddresses, bccAddresses));

				continue;
			}

			// cessioni chiuse
			if (c.Stato__c == '5') {
				// Codice notifica 120 FA ---> 124 A
				if (!c.FirmaDigitale__c && indirizziFiliali.containsKey('F' + oppPerCessione.get(c.Id) [0].Account.Filiale__c)) {
					IndirizziFiliali__mdt indirizziFiliale = indirizziFiliali.get('F' + oppPerCessione.get(c.Id) [0].Account.Filiale__c) [0];
					if (String.isNotBlank(indirizziFiliale.Email__c) && String.isNotBlank(indirizziFiliale.EmailGestore__c)) {
						toAddresses = new String[] { indirizziFiliale.Email__c };
						ccAddresses = new String[] { indirizziFiliale.EmailGestore__c };
						if (emailTemplates.containsKey('TiAnticipo14') && senderIds.containsKey('Gestione Debitori'))
						mails.add(MailUtils.creaMailApexHTML(c.Id, emailTemplates.get('TiAnticipo14').Id, null, senderIds.get('Gestione Debitori') [0].Id, null, toAddresses, ccAddresses, bccAddresses));
					}
				}

				// Codice notifica 122 FD ---> 124 D
				toAddresses = new String[] { MailUtils.EMAIL_CMD };
				ccAddresses = null;
				if (c.FirmaDigitale__c && emailTemplates.containsKey('TiAnticipo14') && senderIds.containsKey('Gestione Debitori'))
				mails.add(MailUtils.creaMailApexHTML(c.Id, emailTemplates.get('TiAnticipo14').Id, null, senderIds.get('Gestione Debitori') [0].Id, null, toAddresses, ccAddresses, bccAddresses));

				// Codice notifica 123 FD / 121 FA ---> 125
				toAddresses = new String[] { oppPerCessione.get(c.Id) [0].Cessione__r.CreatedBy.Email };
				ccAddresses = new String[] { MailUtils.EMAIL_FILO_DIRETTO };
				if (emailTemplates.containsKey('TiAnticipo15') && senderIds.containsKey('Portale TiAnticipo'))
				mails.add(MailUtils.creaMailApexHTML(c.Id, emailTemplates.get('TiAnticipo15').Id, null, senderIds.get('Portale TiAnticipo') [0].Id, null, toAddresses, ccAddresses, bccAddresses));

				continue;
			}
		}

		// Se le mail sono disabilitate o se sono in un test loggo il mancato invio delle mail
		if (!mails.isEmpty()) {
			if (Funzionalita__c.getInstance().DisabilitaInvioEmail__c || Test.isRunningTest()) {
				MailUtils.logNotSentEmail();
			} else {
				Messaging.sendEmail(mails);
			}
		}
	}

	// BEFORE DELETE
	public static void deleteOpportunity(T tu) {
		Opportunity[] opps = [SELECT Id
		                      FROM Opportunity
		                      WHERE Cessione__c IN :tu.oldMap.values()
		                      AND StageName = 'In Istruttoria'];
		JoinLineaDebitore__c[] jlds = [SELECT Id
		                               FROM JoinLineaDebitore__c
		                               WHERE Opportunita__c IN :U.getIdSet(opps, 'Id')
		                               AND Opportunita__r.StageName = 'In Istruttoria'];
		delete jlds;
		delete opps;
	}

	/**
	 * Mapping tra la cessione e l'opportunità TiAnticipo
	 * AFTER INSERT - AFTER UPDATE
	 * @param  tu
	 */
	public static void upsertOpportunity(T tu) {
		//adione-CRM20
		WGC_Originator__mdt originatorMD = [
		                                    SELECT Originator__c, Originator_dettaglio__c
		                                    FROM WGC_Originator__mdt
		                                    WHERE DeveloperName = :taDevName
		                                   ];

		// INSERT: creo opportunità, adeguata verifica, linee, pConfigurati coi default
		if (T.isAfterInsert()) {
			Prodotto__c prodottoPCTAN = [SELECT Id FROM Prodotto__c WHERE CodiceUnivoco__c = 'ATDTiAnticipo'];
			Map<String, SObject> cess = U.keyBy([
			                                    SELECT Id,
			                                    Account__r.OwnerId
			                                    FROM Cessione__c
			                                    WHERE Id IN :U.getSet(tu.triggerNew, 'Id')], 'Id');

			Map<String, SObject> advMap = U.keyBy([
			                                      SELECT Id,
			                                      Account__c,
			                                      CorrispondenzaStreetType__c,
			                                      CorrispondenzaStreetName__c,
			                                      CorrispondenzaStreetNumber__c,
			                                      CorrispondenzaCity__c,
			                                      CorrispondenzaCAP__c,
			                                      CorrispondenzaState__c,
			                                      CorrispondenzaCountry__c,
			                                      TipoIndirizzo__c
			                                      FROM AdeguataVerifica__c
			                                      WHERE Account__c IN :U.getSet(tu.triggerNew, 'Account__c')
			                                      ], 'Account__c');

			// creo oggetti "opportunità"
			Opportunity[] oppsList = new Opportunity[] { };
			Id rtId = U.getRecordTypes('Opportunity').get('IFISOpportunitaFactoring').Id;
			for (Cessione__c c : (Cessione__c[]) tu.triggerNew) {
				oppsList.add(
				             new Opportunity(
				                             Name = c.Name,
				                             AccountId = c.Account__c,
				                             RecordTypeId = rtId,
				                             OwnerId = ((Cessione__c) cess.get(c.Id)).Account__r.OwnerId,
				                             Cessione__c = c.Id,
				                             //adione-CRM20 adeguamenti valori standard
				                             StageName = 'In Istruttoria',
				                             Tipologia_Opportunit__c = 'CONC',
				                             Originator__c = originatorMD.Originator__c,
				                             Originator_di_dettaglio__c = originatorMD.Originator_dettaglio__c,
				                             TiAnticipo__c = true,
				                             HasFactoringDiretto__c = true,
				                             ModalitaDiAperturaPEF__c = 'Pre-consolidata',
				                             NoteStoricheAziendaeAttivitaSvolte__c = '.',
				                             ComposizioneDelCapitaleSociale__c = '.',
				                             NoteSuEsponentiManagementESoci__c = '.',
				                             ProgrammiEProspettiveFuture__c = '.',
				                             AnalisiDiBilancio__c = '.',
				                             RapportiBancariECR__c = '.',
				                             Approfondimenti__c = '.',
				                             Garanzie__c = '.',
				                             DescrizioneOperazioneProposta__c = 'Pratica da portale TiAnticipo. Si richiede l\'attivazione della linea ATD per l\'operazione di acquisto crediti certificati in procedura semplificata. Nei dettagli della pratica sono indicati importo e condizioni economiche dell\'operazione.',
				                             WGC_Descrizione_Operativit_Proposta__c = 'Pratica da portale TiAnticipo. Si richiede l\'attivazione della linea ATD per l\'operazione di acquisto crediti certificati in procedura semplificata. Nei dettagli della pratica sono indicati importo e condizioni economiche dell\'operazione.',
				                             WGC_NoteBilancio__c = 'Pratica TiAnticipo',
				                             WGC_NoteCR__c = 'Pratica TiAnticipo',
				                             WGC_NoteEventi__c = 'Pratica TiAnticipo',
				                             WGC_Prodotti_Selezionati__c = 'ATD Ti Anticipo',
				                             WizardCompletato__c = true,
				                             CloseDate = Date.today().addMonths(1))
				);
			}
			insert oppsList;
			Map<String, SObject[]> oppsPerCessione = U.groupBy(oppsList, 'Cessione__c');

			// creo oggetti "Adeguata Verifica"
			AdeguataVerifica__c[] advList = new AdeguataVerifica__c[] { };
			for (Cessione__c c : (Cessione__c[]) tu.triggerNew) {
				AdeguataVerifica__c adv = new AdeguataVerifica__c(
				                                                  Opportunita__c = oppsPerCessione.get(c.Id) [0].Id,
				                                                  NaturaRapportoContinuativoFD__c = 'Finanziamento',
				                                                  ScopoFD12__c = true, // valorizzazione di default dello scopo "Affidamenti Concessi",
				                                                  OrigineFondi1__c = true // valorizzazione di default dell'origine fondi "Proventi dell'attività d'impresa"
				);
				if (advMap.containsKey(c.Account__c)) {
					AdeguataVerifica__c advTemp = (AdeguataVerifica__c) advMap.get(c.Account__c);
					adv.CorrispondenzaStreetType__c = advTemp.CorrispondenzaStreetType__c;
					adv.CorrispondenzaStreetName__c = advTemp.CorrispondenzaStreetName__c;
					adv.CorrispondenzaStreetNumber__c = advTemp.CorrispondenzaStreetNumber__c;
					adv.CorrispondenzaCity__c = advTemp.CorrispondenzaCity__c;
					adv.CorrispondenzaCAP__c = advTemp.CorrispondenzaCAP__c;
					adv.CorrispondenzaState__c = advTemp.CorrispondenzaState__c;
					adv.CorrispondenzaCountry__c = advTemp.CorrispondenzaCountry__c;
					adv.TipoIndirizzo__c = advTemp.TipoIndirizzo__c;
				}
				advList.add(adv);
			}
			insert advList;

			// creo linee "ATDTiAnticipo"
			Linea__c[] lineaList = new Linea__c[] { };
			for (Cessione__c c : (Cessione__c[]) tu.triggerNew) {
				lineaList.add(
				              new Linea__c(
				                           RecordTypeId = U.getRecordTypes('Linea__c').get('FactDir').Id,
				                           Prodotto__c = prodottoPCTAN.Id,
				                           LineaATD__c = true,
				                           Mercato__c = '001',
				                           DivisaNew__c = '242',
				                           ICARAutomaticiATD__c = 'N',
				                           LineaATDSingola__c = 'S',
				                           Anatocismo__c = false,
				                           TipoLinea__c = 'lineaDiAcquisto',
				                           ICAR__c = 'ICAR manuale',
				                           DebitoreTipo__c = 'Debitore',
				                           DebitoreRotativita__c = false,
				                           Opportunity__c = oppsPerCessione.get(c.Id) [0].Id
				)
				);
			}
			insert lineaList;

			// Creo i parametri configurati associati a queste linee (popolando i valori coi default).
			// Più in basso andrò ad aggiornare quelli che variano in base a valori legati alla cessione
			// i parametri qui esclusi saranno quelli da associare ai debitori e quindi creati tramite le certificazioni.
			PConfigurato__c[] pConfiguratoList = new PConfigurato__c[] { };
			for (ParametroProdotto__c pp :[SELECT Id,
			     Default__c,
			     Parametro__r.CodiceUnivoco__c,
			     Parametro__r.Tipo__c
			     FROM ParametroProdotto__c
			     WHERE Prodotto__r.CodiceUnivoco__c = 'ATDTiAnticipo'
			     AND Parametro__r.CodiceUnivoco__c NOT IN('SF12', '009', '008', '135')]) {
				for (Linea__c l : lineaList) {
					pConfiguratoList.add(
					                     new PConfigurato__c(
					                                         Linea__c = l.Id,
					                                         Default__c = pp.Default__c,
					                                         Codice__c = pp.Parametro__r.CodiceUnivoco__c,
					                                         Valore__c = pp.Default__c != null ? pp.Default__c : '',
					                                         Tipo__c = pp.Parametro__r.Tipo__c
					)
					);
				}
			}
			//adione-CRM20 FIXME: controllare se questi paramentri sono salvati in ParametriProdotto__c
			//e in caso recuperarli a DB per non dover fare rilascio in cambio di cambio parametro
			for (Linea__c l : lineaList) {
				pConfiguratoList.add(
				                     new PConfigurato__c(
				                                         Linea__c = l.Id,
				                                         Default__c = 'N',
				                                         Codice__c = '101',
				                                         Valore__c = 'N',
				                                         Tipo__c = 'Parametro aggiuntivo'
				)
				);
				pConfiguratoList.add(
				                     new PConfigurato__c(
				                                         Linea__c = l.Id,
				                                         Default__c = 'S',
				                                         Codice__c = '280',
				                                         Valore__c = 'S',
				                                         Tipo__c = 'Parametro aggiuntivo'
				)
				);
			}
			insert pConfiguratoList;
		}

		// INSERT E UPDATE: aggiorno le linee e i pConfigurati
		if (T.isAfterInsert() || T.isAfterUpdate()) {
			// prendo le cessioni per cui sono cambiati valori che influenzano parametri configurati e li aggiorno
			Cessione__c[] cessioniParametri = tu.getChanged(new String[] { 'SpeseIstruttoriaDebitore__c', 'SpeseIstruttoriaCedente__c', 'ImportoTotaleCertificazioni__c' });
			TiAnticipoUtils.syncParametri(cessioniParametri);
		}
	}

	//AFTER INSERT - AFTER UPDATE
	public static void calcolaSpeseIstruttoria(T tu) {
		Cessione__c[] cessioni = tu.getChanged(new String[] { 'ImportoTotaleCertificazioni__c' });
		Set<Id> idCessioni = U.getIdSet(cessioni, 'Id');
		TiAnticipoUtils.calcolaSpeseIstruttoria(idCessioni);
	}

	//AFTER UPDATE
	public static void aggiornaStatoOpty(T tu) {
		Cessione__c[] cessioni = tu.filter('Stato__c', '4').getChanged(new String[] { 'Stato__c' });
		cessioni.addAll((Cessione__c[]) tu.filter('Stato__c', '5').getChanged(new String[] { 'Stato__c' }));

		if (cessioni.isEmpty()) return;

		Map<Id, Cessione__c> cessMap = new Map<Id, Cessione__c> (cessioni);
		Opportunity[] oppList = [SELECT
		                         Id,
		                         Cessione__c
		                         FROM Opportunity
		                         WHERE Cessione__c IN :cessioni
		                         FOR UPDATE
		                        ];

		for (Opportunity opp : oppList) {
			if (cessMap.get(opp.Cessione__c).Stato__c == '4') opp.StageName = 'Vinta';
			if (cessMap.get(opp.Cessione__c).Stato__c == '5') opp.StageName = 'Persa';
		}

		update oppList;
	}

	//AFTER UPDATE
	public static void aggiornaScopoRapporto(T tu) {
		Cessione__c[] cessioni = tu.filter('Stato__c', '2').getChanged(new String[] { 'Stato__c' });
		Map<Id, Account> accsMap = new Map<Id, Account> ();
		for (Cessione__c cessione : cessioni) {
			accsMap.put(cessione.Account__c, new Account(Id = cessione.Account__c, ScopoRapporto__c = '12'));
		}
		update accsMap.values();
	}

	//UTILITY
	@testVisible
	private static String getCessioneName() {
		Datetime myDate = Datetime.now();
		String formattedMyDate = myDate.format('dd/MM/yyyy - HH:mm');
		return 'Operazione del ' + formattedMyDate;
	}
}