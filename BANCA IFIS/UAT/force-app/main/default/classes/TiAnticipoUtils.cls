public without sharing class TiAnticipoUtils {
	static OrgWideEmailAddress owa = [SELECT id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'Portale TiAnticipo' limit 1];
	static ParametriTiAnticipo__c paramTA = ParametriTiAnticipo__c.getInstance();
	//metodi allineamento Cessione -> Opportunity per TiAnticipo

	/**
	 * Allineamento Cessione -> pConfigurati per TiAnticipo:
	 * Da alcuni valori relativi a una cessione vengono popolati alcuni pConfigurati
	 * @param  cessioni
	 */
	public static void syncParametri(Cessione__c[] cessioni) {
		PConfigurato__c[] pConfigurati = [SELECT Id,
		                                  Codice__c,
		                                  Valore__c,
		                                  Linea__r.Opportunity__r.Cessione__c
		                                  FROM PConfigurato__c
		                                  WHERE Linea__r.Opportunity__r.Cessione__c IN :U.getSet(cessioni, 'Id')
		                                  AND Linea__r.Opportunity__r.StageName = 'In Istruttoria'];
		Map<String, PConfigurato__c[]> pConfiguratiPerCessione = U.groupBy(pConfigurati, '{Linea__r.Opportunity__r.Cessione__c}_{Codice__c}', true);
		for (Cessione__c cessione : cessioni) {
			if (pConfiguratiPerCessione.containsKey((cessione.Id + '_C150')) && cessione.SpeseIstruttoriaDebitore__c != null && cessione.SpeseIstruttoriaCedente__c != null)
			pConfiguratiPerCessione.get(cessione.Id + '_C150') [0].Valore__c = String.valueOf(cessione.SpeseIstruttoriaDebitore__c + cessione.SpeseIstruttoriaCedente__c);
			if (pConfiguratiPerCessione.containsKey((cessione.Id + '_SF5')))
			pConfiguratiPerCessione.get(cessione.Id + '_SF5') [0].Valore__c = String.valueOf(cessione.ImportoTotaleCertificazioni__c);
			if (pConfiguratiPerCessione.containsKey((cessione.Id + '_SF6')))
			pConfiguratiPerCessione.get(cessione.Id + '_SF6') [0].Valore__c = String.valueOf(cessione.ImportoTotaleCertificazioni__c);
		}
		upsert pConfigurati;
	}

	public static Id getUserAccountId() {
		User u = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
		return(String.isNotBlank(u.Contact.AccountId)) ? u.Contact.AccountId : UtenzeDefault__c.getInstance().IdAccountDiDefault__c;
	}

	public static Id getUserContactId() {
		User u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		return(u != null) ? u.ContactId : UtenzeDefault__c.getInstance().IdReferenteDiDefault__c;
	}

	public static Decimal calcoloCostoPreventivoPubblico(String segmentoRischio, Decimal importoFattura, Integer deltaGiorni) {
		Decimal costo;

		CommissioneATD__mdt[] commissioniAtd = [SELECT Id,
		                                        CommissioneATDMese__c,
		                                        SegmentoRischio__c,
		                                        EstremoInferiore__c,
		                                        EstremoSuperiore__c
		                                        FROM CommissioneATD__mdt
		                                        WHERE SegmentoRischio__c = :segmentoRischio];

		SpesaIstruttoria__mdt[] spese = [SELECT Id,
		                                 SpeseCedente__c,
		                                 SpeseDebitore__c,
		                                 EstremoInferiore__c,
		                                 EstremoSuperiore__c
		                                 FROM SpesaIstruttoria__mdt];

		CommissioneATD__mdt commissioneAtd = getCommissioneAtd(commissioniAtd, segmentoRischio, importoFattura);
		SpesaIstruttoria__mdt spesa = getSpesaIstruttoria(spese, importoFattura);
		if (commissioneAtd != null && spesa != null) {
			Decimal commissione = commissioneAtd.CommissioneATDMese__c / 100;
			costo = importoFattura * commissione / 30 * deltaGiorni + spesa.SpeseCedente__c + spesa.SpeseDebitore__c;
		}
		return costo;
	}

	/**
	 * Data una lista di certificazioni (relative ad un debitore), calcola la durata credito (relativa al debitore)
	 * La durata credito è necessaria per il calcolo della C138
	 **/
	public static Decimal calcoloDurataCredito(Certificazione__c[] certificazioniPerDebitore) {
		Decimal durataCredito = 0;
		Decimal totaleOriginarioPerDebitore = U.sumBy(certificazioniPerDebitore, 'ImportoCertificato__c');

		// Caso 1: una sola certificazione
		if (certificazioniPerDebitore != null && certificazioniPerDebitore.size() == 1) {
			durataCredito = certificazioniPerDebitore[0].DeltaGiorni__c;
			// Caso 2: più di una certificazione
		} else if (certificazioniPerDebitore != null && certificazioniPerDebitore.size() > 1) {
			for (Certificazione__c cert : certificazioniPerDebitore) {
				durataCredito += cert.DeltaGiorni__c * cert.ImportoCertificato__c;
			}
			durataCredito = durataCredito / totaleOriginarioPerDebitore;
		}
		return durataCredito;
	}

	//il calcolo della c138 deve includere anche certificazioni bocciate e riviste
	public static Decimal calcoloC138(Certificazione__c[] certificazioniPerDebitore, Account debitore, CommissioneATD__mdt commissioneAtd) {
		Decimal costoPerDebitore = 0;
		Decimal totaleOriginarioPerDebitore = U.sumBy(certificazioniPerDebitore, 'ImportoCertificato__c');
		for (Certificazione__c c : certificazioniPerDebitore) {
			try {
				costoPerDebitore += c.ImportoCertificato__c * commissioneAtd.CommissioneATDMese__c / 100 / 30 * c.DeltaGiorni__c;
			} catch(Exception ex) {
				// Se viene lanciata l'eccezione è perchè non è accettata la certificazione in fase di upload. Verrà quindi
				// successivamente rieseguito questo calcolo, popolando correttamente i valori.
				costoPerDebitore = 0;
			}
		}
		Decimal c138 = costoPerDebitore / totaleOriginarioPerDebitore;
		return c138;
	}

	public static void calcolaSpeseIstruttoria(Set<Id> idCessioni) {
		//questo calcolo prende in considerazione ANCHE le certficiazioni bocciate, come da richiesta di Keoma
		//e quindi deve usare ImportoTotaleCertificazioniOriginario__c
		Cessione__c[] cessioni = [SELECT Id,
		                          ImportoTotaleCertificazioniOriginario__c,
		                          NumeroCertificazioni__c,
		(SELECT Id,
		 Debitore__c
		 FROM Certificazioni__r
		 WHERE CertificazioneValida__c = true)
		                          FROM Cessione__c
		                          WHERE Id IN :idCessioni];

		SpesaIstruttoria__mdt[] spese = [SELECT Id,
		                                 SpeseCedente__c,
		                                 SpeseDebitore__c,
		                                 EstremoInferiore__c,
		                                 EstremoSuperiore__c
		                                 FROM SpesaIstruttoria__mdt];

		for (Cessione__c c : cessioni) {
			Decimal speseCedente, speseDebitore;
			if (c.NumeroCertificazioni__c == 0) {
				speseCedente = 0;
				speseDebitore = 0;
			} else {
				Integer numeroDebitori = getNumeroDebitori(c.Certificazioni__r);
				Decimal mediaImportoCertificazioni = c.ImportoTotaleCertificazioniOriginario__c / numeroDebitori;

				SpesaIstruttoria__mdt spesa = getSpesaIstruttoria(spese, mediaImportoCertificazioni);
				if (spesa != null) {
					speseDebitore = spesa.SpeseDebitore__c * numeroDebitori;
				}
				spesa = getSpesaIstruttoria(spese, c.ImportoTotaleCertificazioniOriginario__c);
				if (spesa != null) {
					speseCedente = spesa.SpeseCedente__c;
				}
			}
			c.SpeseIstruttoriaCedente__c = speseCedente;
			c.SpeseIstruttoriaDebitore__c = speseDebitore;
		}

		update cessioni;
	}

	private static Integer getNumeroDebitori(Certificazione__c[] certificazioni) {
		return U.groupBy(certificazioni, 'Debitore__c')
		.keySet()
		.size();
	}

	public static CommissioneATD__mdt getCommissioneAtd(CommissioneATD__mdt[] commissioni, String segmento, Decimal importo) {
		for (CommissioneATD__mdt c : commissioni) {
			if (c.SegmentoRischio__c == segmento
			    && c.EstremoInferiore__c<importo
			    && c.EstremoSuperiore__c >= importo) {
				return c;
			}
		}
		return null;
	}

	private static SpesaIstruttoria__mdt getSpesaIstruttoria(SpesaIstruttoria__mdt[] spese, Decimal importo) {
		for (SpesaIstruttoria__mdt s : spese) {
			if (s.EstremoInferiore__c<importo
			    && s.EstremoSuperiore__c >= importo) {
				return s;
			}
		}
		return null;
	}

	/**
	 * Imposta l'utente di portale TA come titolare TA dell'Account TA
	 */
	public static Boolean setUtenteTitolare() {
		if (canBeUtenteTitolare()) {
			Contact c = new Contact(Id = TiAnticipoUtils.getUserContactId(), TitolareTa__c = true);
			update c;
			return true;
		}
		return false;
	}

	/**
	 * verifica se l'utente di portale TA è titolare dell'Account TA
	 */
	public static Boolean isUtenteTitolare() {
		Id contactId = TiAnticipoUtils.getUserContactId();
		Id accId = TiAnticipoUtils.getUserAccountId();
		Contact contatto = [SELECT Id, TitolareTa__c
		                    FROM Contact
		                    WHERE AccountId = :accId
		                    AND Id = :contactId];

		return contatto.TitolareTa__c;
	}

	/**
	 * verifica se l'Account TA non è già assegnato ad un altro Contatto
	 * p.e. un altro cliente già registrato al portale è associato come titolare TA dell'Account 
	 */
	public static Boolean canBeUtenteTitolare() {
		Id contactId = TiAnticipoUtils.getUserContactId();
		Id accId = TiAnticipoUtils.getUserAccountId();
		Contact[] contatti = [SELECT Id, TitolareTa__c
		                      FROM Contact
		                      WHERE AccountId = :accId
		                      AND Id != :contactId
		                      AND TitolareTa__c = true];

		return contatti.size() == 0;
	}

	public static String getCommunityUsername(String email) {
		return email + '.' + ParametriTiAnticipo__c.getOrgDefaults().UsernameSuffix__c;
	}

	public static String creaCommunityUsername(String email) {
		String username = getCommunityUsername(email);
		testUniqueUsername(username);
		return username;
	}

	private static void testUniqueUsername(String username) {
		User[] existingUsers = [SELECT Id FROM User WHERE Username = :username];
		if (existingUsers.size()> 0) throw new Ex.GenericException('Esiste già un\'utenza associata a questo indirizzo email. Contatta Banca IFIS per maggiori informazioni.');
	}

	@Future
	public static void sendInfoMail(String input) {

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setOrgWideEmailAddressId(owa.id);
		mail.setToAddresses(new String[] {
			                   paramTA.Mail_Segnalazione_Errori__c
		                    });
		mail.setReplyTo('noreply@bancaifis.it');
		mail.setSubject('TiAnticipo - Informazioni attività');
		String body = 'Informazioni attività su portale TiAnticipo \n';
		body += 'SFDC Instance: ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '\n';
		body = body + '------------------------------------------------------------------------------------------------\n\n';
		body = body + input;
		body = body + '\n\n------------------------------------------------------------------------------------------------';
		mail.setPlainTextBody(body);

		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

	@Future
	public static void sendErrorMail(String exMsg, String input) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setOrgWideEmailAddressId(owa.id);
		mail.setToAddresses(new String[] {
			                   paramTA.Mail_Segnalazione_Errori__c
		                    });
		mail.setReplyTo('noreply@bancaifis.it');
		mail.setSubject('TiAnticipo Errore elaborazione');
		String body = 'Errore non gestito su elaborazione TiAnticipo \n';
		body += 'SFDC Instance: ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '\n';
		body = body + '------------------------------------------------------------------------------------------------\n\n';
		body = body + exMsg;
		body = body + '\n\n------------------------------------------------------------------------------------------------\n\n';
		body = body + input;
		body = body + '\n\n------------------------------------------------------------------------------------------------';
		mail.setPlainTextBody(body);

		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

	@Future
	public static void trackWork(String msg, String input, String output, String codFunz, String idOp) {
		Log__c l = [SELECT Id, ErorrMessage__c, OutputPayload__c, InputPayload__c FROM Log__c WHERE CodiceOperatore__c = :idOp LIMIT 1];

		if (l == null) {
			l = new Log__c(
			               Source__c = 'TiAnticipo',
			               CodiceFunzione__c = codFunz,
			               ErorrMessage__c = msg,
			               InputPayload__c = input,
			               OutputPayload__c = output,
			               CodiceOperatore__c = idOp
			);
		} else {
			l.ErorrMessage__c += '\n' + msg;
			l.InputPayload__c += '\n' + input;
			l.OutputPayload__c += '\n' + output;
		}

		upsert l;
	}

}