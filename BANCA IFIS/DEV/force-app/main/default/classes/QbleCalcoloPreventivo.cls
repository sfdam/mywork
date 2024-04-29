public without sharing class QbleCalcoloPreventivo implements Queueable, Database.AllowsCallouts {

	QueueItemPreventivo__c[] preventiviDaCalcolare;
	private static final Integer TENTATIVI_DISPONIBILI = 1;

	public QbleCalcoloPreventivo(QueueItemPreventivo__c[] input) {
		preventiviDaCalcolare = input.clone();
	}

	public void execute(QueueableContext context) {
		if (this.preventiviDaCalcolare.isEmpty()) return;
		QueueItemPreventivo__c preventivoDaCalcolareTemp = this.preventiviDaCalcolare.remove(0);
		QueueItemPreventivo__c preventivoDaCalcolare;

		// Recupero i vecchi QueueItemPreventivo che non sono ancora stati risolti, relativi alla Cessione del QueueItemPreventivo corrente.
		Map<Id, QueueItemPreventivo__c> preventivi = new Map<Id, QueueItemPreventivo__c> ([SELECT
		                                                                                  Id,
		                                                                                  Cessione__c,
		                                                                                  Errori__c,
		                                                                                  Status__c,
		                                                                                  Solved__c,
		                                                                                  CreatedDate,
		                                                                                  TentativiEseguiti__c
		                                                                                  FROM QueueItemPreventivo__c
		                                                                                  WHERE Cessione__c = :preventivoDaCalcolareTemp.Cessione__c
		                                                                                  AND CreatedDate <= :preventivoDaCalcolareTemp.CreatedDate
		                                                                                  AND Solved__c = false
		                                                                                  FOR UPDATE
		                                                                                  ]);

		// Utilizzo il QueueItemPreventivo corrente..
		if (preventivi != null && preventivi.containsKey(preventivoDaCalcolareTemp.Id)) {
			try {
				preventivoDaCalcolare = preventivi.get(preventivoDaCalcolareTemp.Id);
				if (preventivoDaCalcolare.Status__c == 'Failed' && preventivoDaCalcolare.TentativiEseguiti__c == TENTATIVI_DISPONIBILI)
				preventivoDaCalcolare.TentativiEseguiti__c = 0;

				Certificazione__c[] certificazioniDaAggiornare = new Certificazione__c[] { };

				// ..recuperando informazioni su Cessione e sue Certificazioni..
				Cessione__c[] cessioni = [SELECT Id,
				                          Account__r.NDGGruppo__c,
				(SELECT Id,
				 Cessione__c,
				 CertificazioneBocciata__c,
				 CertificazioneValida__c,
				 Debitore__c,
				 DeltaGiorni__c,
				 ImportoCertificato__c,
				 ImportoCertificatoCalcolo__c
				 FROM Certificazioni__r
				 WHERE CertificazioneValida__c = true)
				                          FROM Cessione__c
				                          WHERE Id = :preventivoDaCalcolare.Cessione__c
				                          FOR UPDATE];
				Cessione__c cessione = cessioni[0];

				CommissioneATD__mdt[] commissioniAtd = [SELECT Id,
				                                        CommissioneATDMese__c,
				                                        SegmentoRischio__c,
				                                        EstremoInferiore__c,
				                                        EstremoSuperiore__c
				                                        FROM CommissioneATD__mdt];

				Set<Id> debSet = U.getIdSet(cessione.Certificazioni__r, 'Debitore__c');

				Map<Id, Account> debitoriMap = new Map<Id, Account> (
				                                                     [SELECT Id,
				                                                     CF__c,
				                                                     SegmentoRischio__c,
				                                                     NDGGruppo__c
				                                                     FROM Account WHERE Id IN : debSet]
				);

				Decimal costoComplessivoC138 = 0;

				Map<String, Certificazione__c[]> certificazioniPerDebitoreMap = U.groupBy(cessione.Certificazioni__r, 'Debitore__c');

				for (Id idDebitore : certificazioniPerDebitoreMap.keySet()) {
					Account debitore = debitoriMap.get(idDebitore);
					if (String.isBlank(debitore.NDGGruppo__c)) throw new Ex.WSException('Il debitore con CF ' + debitore.CF__c + ' non ha NDG');
					Certificazione__c[] certificazioniPerDebitore = certificazioniPerDebitoreMap.get(idDebitore);
					Decimal totaleOriginarioPerDebitore = U.sumBy(certificazioniPerDebitore, 'ImportoCertificato__c');
					CommissioneATD__mdt commissioneAtd = TiAnticipoUtils.getCommissioneAtd(
					                                                                       commissioniAtd,
					                                                                       debitore.SegmentoRischio__c,
					                                                                       totaleOriginarioPerDebitore
					);

					Decimal c138debitore = TiAnticipoUtils.calcoloC138(certificazioniPerDebitore, debitore, commissioneAtd) * 100;

					Certificazione__c[] certificazioniNonBocciate = U.filter(certificazioniPerDebitore, 'CertificazioneBocciata__c', false);
					Decimal totaleCertificazioniNonBocciate = U.sumBy(certificazioniNonBocciate, 'ImportoCertificatoCalcolo__c');

					Decimal durataCredito = TiAnticipoUtils.calcoloDurataCredito(certificazioniPerDebitore);
					// ..invochiamo la callout per il calcolo di C138..
					// Invochiamo una callout per ogni debitore presente in una cessione: i limiti di Salesforce sono 100 callout:
					// considerando che il Logger potrebbe inserire un log tramite callout è ragionevole pensare che una cessione non abbia più di 50 debitori
					WsRestCrm.CalcoloC138DebitoreResponse response = WsRestCrm.calcoloC138Debitore(new WsRestCrm.CalcoloC138DebitoreInput(cessione.Account__r.NDGGruppo__c, durataCredito, c138debitore));
					Decimal valoreCommissioneEffettivoDebitore;
					if (response.isCorrect()) {
						valoreCommissioneEffettivoDebitore = response.payload.outputTiAnticipo.valoreCommissioneEffettivo;
						valoreCommissioneEffettivoDebitore = valoreCommissioneEffettivoDebitore / 100;
						for (Certificazione__c cert : certificazioniPerDebitore) {
							cert.CommissioneC138Debitore__c = valoreCommissioneEffettivoDebitore;
							certificazioniDaAggiornare.add(cert);
						}
						costoComplessivoC138 += totaleCertificazioniNonBocciate * valoreCommissioneEffettivoDebitore;
					} else {
						throw new Ex.WSException('Errore risposta servizio calcolo C138 per debitore: ' + debitore.NDGGruppo__c);
					}
				}
				// ..aggiorniamo le cessioni e le certificazioni correlate..
				cessione.CostoComplessivoC138__c = costoComplessivoC138;
				update cessione;
				update certificazioniDaAggiornare; // <-- questa dml fa scattare il trigger che ri-aggiorna i parametri con i valori della C138 corretti

				// ..aggiorniamo i QueueItemPreventivo..
				U.massSet(preventivi.values(), 'Solved__c', true);
				U.massSet(preventivi.values(), 'SolvedBy__c', preventivoDaCalcolare.Id);

				// ..e il QueueItemPreventivo utilizzato
				preventivoDaCalcolare.SolvedBy__c = null;
				preventivoDaCalcolare.Status__c = 'Completed';
				preventivoDaCalcolare.CostoComplessivoC138__c = cessione.CostoComplessivoC138__c;

			} catch(Exception e) {
				Log__c l = new Log__c();
				l.CodiceApplicazione__c = 'Portale Ti Anticipo';
				l.CodiceFunzione__c = 'QbleCalcoloPreventivo.execute';
				l.Source__c = 'TiAnticipo';
				l.Account__c = preventivoDaCalcolareTemp.Cessione__r.Account__c;
				l.InputPayload__c = JSON.serialize(preventivoDaCalcolareTemp);
				insert l;

				String errore = 'TENTATIVO ' + (preventivoDaCalcolare.TentativiEseguiti__c + 1) + ': ' + e.getMessage() + '\n' + e.getStackTraceString();
				preventivoDaCalcolare.Errori__c = (preventivoDaCalcolare.Errori__c == null) ? errore : preventivoDaCalcolare.Errori__c + '\n' + errore;
				// se il numero di tentativi disponibili è raggiunto..
				if (preventivoDaCalcolare.TentativiEseguiti__c >= TENTATIVI_DISPONIBILI - 1) {
					preventivoDaCalcolare.Status__c = 'Failed';
					// ..altrimenti re-inserisco il preventivo da calcolare in fondo alla lista, verrà tentato nuovamente il calcolo
				} else {
					this.preventiviDaCalcolare.add(preventivoDaCalcolare);
				}
			}
			preventivoDaCalcolare.TentativiEseguiti__c++;
			update preventivi.values();
		}

		if (!this.preventiviDaCalcolare.isEmpty()) {
			QbleCalcoloPreventivo nextJob = new QbleCalcoloPreventivo(this.preventiviDaCalcolare);
			System.enqueueJob(nextJob);
		}
	}
}