/**
  * Progetto:         Banca IFIS - Ti Anticipo
  * Sviluppata il:    14/06/2016
  * Developer:        Stefano Brivio
*/
//adione - CRM20 col nuovo schema visibilità l'utente community non ha accesso agli Account
//per cui rilassiamo il controllo a livello di classe apex
//public with sharing class TaCtrlDettaglio {
public without sharing class TaCtrlDettaglio {

	public class DettaglioCessione {
		@AuraEnabled public Cessione__c cessione;
		@AuraEnabled public String idOpportunity;

		public DettaglioCessione(Cessione__c cessione, String idOpportunity) {
			this.cessione = cessione;
			this.idOpportunity = idOpportunity;
		}
	}

	public class UploadCertificazioneInfo {
		@AuraEnabled public Cessione__c cessione;
		@AuraEnabled public Certificazione__c[] certificazioni;

		public UploadCertificazioneInfo(Cessione__c cessione, Certificazione__c[] certificazioni) {
			this.cessione = cessione;
			this.certificazioni = certificazioni;
		}
	}

	public static Boolean editNomeCessione(Id idCessione, String nomeCessione) {
		update new Cessione__c(Id = idCessione, Name = nomeCessione);
		return true;
	}

	public static Cessione__c[] fetchCessioni() {
		return[SELECT Id,
		Name,
		CreatedDate,
		Account__c,
		Account__r.IBAN__c,
		AnomalieAperte__c,
		CostoTotaleOperazione__c,
		DataPraticaAnalisi__c,
		DataPraticaPagamento__c,
		DataPraticaPerfezionamento__c,
		DataPraticaPersa__c,
		Errore__c,
		ImportoErogato__c,
		ImportoTotaleCertificazioni__c,
		ImportoTotaleCertificazioniOriginario__c,
		NumeroCertificazioni__c,
		NumeroCertificazioniNoTermini__c,
		NumeroFatture__c,
		OffertaTotaleOperazione__c,
		Passo__c,
		Stato__c,
		toLabel(Stato__c) StatoLabel,
		(SELECT Id,
		 Name,
		 toLabel(TipoAnomalia__c),
		 SottotipoAnomalia__c,
		 DescrizioneAnomalia__c
		 FROM Anomalie__r
		 WHERE Risolta__c = false)
		FROM Cessione__c
		WHERE Account__c = : TiAnticipoUtils.getUserAccountId()
		AND CreatedById = : UserInfo.getUserId()
		ORDER BY CreatedDate DESC];
	}

	public static void popolaUltimoAccesso(Id idCessione) {
		if (idCessione == null) return;
		if (UserInfo.getUserType() == 'CspLitePortal') {
			try {
				Cessione__c cess = [SELECT Id, CreatedById FROM Cessione__c WHERE Id = :idCessione FOR UPDATE];
				if (cess.CreatedById == UserInfo.getUserId()) {
					cess.DataUltimoAccesso__c = Datetime.now();
					update cess;
				}
			} catch(Exception e) { }
		}
	}

	public static DettaglioCessione fetchCessione(Id idCessione) {
		Cessione__c cessione = [SELECT Id,
		                        Name,
		                        CreatedDate,
		                        Account__c,
		                        Account__r.IBAN__c,
		                        AnomalieAperte__c,
		                        CostoTotaleOperazione__c,
		                        Errore__c,
		                        ImportoErogato__c,
		                        ImportoTotaleCertificazioni__c,
		                        ImportoTotaleCertificazioniOriginario__c,
		                        NumeroCertificazioni__c,
		                        NumeroCertificazioniNoTermini__c,
		                        NumeroFatture__c,
		                        OffertaTotaleOperazione__c,
		                        Passo__c,
		                        Stato__c,
		                        toLabel(Stato__c) StatoLabel
		                        FROM Cessione__c
		                        WHERE Id = :idCessione
		                        AND CreatedById = :UserInfo.getUserId()
		                       ];

		Opportunity[] opps = [SELECT Id FROM Opportunity
		                      WHERE Cessione__c = :cessione.Id];

		return new DettaglioCessione(cessione, opps.size() > 0 ? opps[0].Id : null);
	}

	/**
	 * fetchAnomalie Ritorna la lista delle cessioni con anomalia
	 * @return   Lista delle cessioni con anomalia
	 */
	public static Anomalia__c[] fetchAnomalie() {
		return[SELECT Id,
		Attore__c,
		Attore__r.Name,
		TipoAnomalia__c,
		toLabel(TipoAnomalia__c) TipoAnomaliaLabel,
		SottotipoAnomalia__c,
		DescrizioneAnomalia__c,
		Cessione__c,
		Stato__c,
		CreatedDate
		FROM Anomalia__c
		WHERE TipoAnomalia__c != null
		AND Risolta__c = false
		AND Cessione__r.Account__c = : TiAnticipoUtils.getUserAccountId()
		AND Cessione__r.CreatedById = : UserInfo.getUserId()
		ORDER BY CreatedDate DESC];
	}

	public static Boolean setReadedMessage(Id idAnomalia) {
		update new Anomalia__c(Id = idAnomalia, Stato__c = 'Letto', DataLettura__c = System.now());
		return true;
	}

	public static Fattura__c[] fetchFatture(Id idCessione) {
		return[SELECT Id,
		Name,
		CertificazioneParent__r.Name,
		NumeroFattura__c,
		DataFattura__c,
		ImportoFattura__c,
		ImportoFatturaCertificato__c,
		ScadenzaFattura__c
		FROM Fattura__c
		WHERE CertificazioneParent__r.Cessione__c = : idCessione
		ORDER BY CertificazioneParent__r.Name];
	}

	/**
	  * Verifica che il preventivo per la cessione il cui id è "idCessione" sia calcolato correttamente.
	  * Se necessario, ritenta il calcolo del preventivo
	*/
	public static Cessione__c fetchPreventivoCorretto(Id idCessione, Boolean retryCalcoloSeNecessario) {
		// Se necessario, ritento il calcolo del preventivo
		if (retryCalcoloSeNecessario) {
			QueueItemPreventivo__c[] qip = [SELECT
			                                Status__c
			                                FROM QueueItemPreventivo__c
			                                WHERE Cessione__c = :idCessione
			                                ORDER BY CreatedDate DESC
			                                LIMIT 1];
			if (qip.isEmpty() || qip[0].Status__c == 'Failed') {
				insert new QueueItemPreventivo__c(Cessione__c = idCessione);
			}
		}

		// Ritorno lo stato della cessione
		Cessione__c[] cess = [SELECT
		                      IsPreventivoCorretto__c,
		                      LastModifiedDate,
		                      OffertaTotaleOperazione__c
		                      FROM Cessione__c
		                      WHERE Id = :idCessione];
		if (!cess.isEmpty()) return cess[0];
		return null;
	}

	public static Boolean updateFatture(String input) {
		Fattura__c[] fatture = (Fattura__c[]) JSON.deserialize(input, Fattura__c[].class);
		update fatture;
		return true;
	}

	public static Boolean deleteCertificazione(Id idCertificazione) {
		delete new Certificazione__c(Id = idCertificazione);
		return true;
	}

	public static Certificazione__c[] fetchCertificazioniFatture(Id idCessione) {
		return[SELECT Id,
		Name,
		AmmontareComplessivoCredito__c,
		CertificazioneValida__c,
		Cessione__c,
		CodiceCertificazione__c,
		DataPagamento__c,
		Debitore__c,
		Errore__c,
		IdFileCertificazione__c,
		ImportoCertificato__c,
		ImportoCertificatoCalcolo__c,
		NumeroFatture__c,
		PartitaIvaDebitore__c,
		RagioneSocialeDebitore__c,
		TerminiPagamento__c,
		TerminiPagamentoUnici__c,
		ATI__c,
		(SELECT Id,
		 Name,
		 DataFattura__c,
		 CertificazioneParent__r.Debitore__r.Name,
		 CertificazioneParent__r.Name,
		 ImportoFattura__c,
		 ImportoFatturaCertificato__c,
		 NumeroFattura__c,
		 ScadenzaFattura__c
		 FROM Fatture__r)
		FROM Certificazione__c
		WHERE Cessione__c = : idCessione];
	}

	public static UploadCertificazioneInfo fetchUploadCertificazioneInfo(Id idCessione) {
		return new UploadCertificazioneInfo(
		                                    fetchCessione(idCessione).cessione,
		                                    fetchCertificazioniFatture(idCessione)
		);
	}

	public static Account[] fetchDebitoriTA() {
		return[SELECT Name, PIVA__c, CF__c
		FROM Account
		WHERE SegmentoRischio__c != null
		AND SegmentoRischio__c != '6'];
	}

	public static DettaglioCessione upsertCessione(String input) {
		Cessione__c cessione = (Cessione__c) JSON.deserialize(input, Cessione__c.class);
		System.debug('-----> TaCtrlDettaglio.upsertCessione: ' + input);
		if (String.isBlank(cessione.Account__c)) {
			cessione.Account__c = TiAnticipoUtils.getUserAccountId();
		}
		upsert cessione;

		Log__c l = new Log__c();
		l.CodiceApplicazione__c = 'Portale Ti Anticipo';
		l.CodiceFunzione__c = 'TaCtrlDettaglio.upsertCessione';
		l.Source__c = 'TiAnticipo';
		l.Account__c = cessione.Account__c;
		l.InputPayload__c = input.abbreviate(131072);
		insert l;

		return fetchCessione(cessione.Id);
	}

	public static UploadCertificazioneInfo associaDebitoriCertificazioni(Certificazione__c[] certificazioni) {
		Set<String> partiteIve = U.getSet(certificazioni, 'PartitaIvaDebitore__c');
		Map<String, SObject> accMap = U.keyBy([SELECT Id, CF__c FROM Account WHERE CF__c IN :partiteIve], 'CF__c');
		for (Certificazione__c c : certificazioni) {
			Account acc = (Account) accMap.get(c.PartitaIvaDebitore__c);
			c.Debitore__c = acc != null ? acc.Id : null;
		}
		update certificazioni;

		Fattura__c[] toUpdate = [SELECT Id,
		                         DataFattura__c,
		                         CertificazioneParent__r.TerminiPagamento__c
		                         FROM Fattura__c
		                         WHERE CertificazioneParent__c IN :certificazioni
		                         AND DataFattura__c != null
		                         AND CertificazioneParent__r.TerminiPagamento__c != null];

		for (Fattura__c f : toUpdate) {
			f.ScadenzaFattura__c = f.DataFattura__c + Integer.valueOf(f.CertificazioneParent__r.TerminiPagamento__c);
		}

		try {
			update toUpdate;
		} catch(System.DmlException e) {
			String message = e.getMessage();
			if (e.getDmlType(0) == StatusCode.FIELD_INTEGRITY_EXCEPTION
			    && e.getMessage().contains('ScadenzaFattura__c')) {
				message = 'Attenzione, il valore inserito deve corrispondere al numero giorni (es 60, 90, 120...) di pagamento della fattura/ delle fatture caricate con la Certificazione.';
			}
			throw new Ex.GenericException(message);
		}

		return fetchUploadCertificazioneInfo(certificazioni[0].Cessione__c);
	}
}