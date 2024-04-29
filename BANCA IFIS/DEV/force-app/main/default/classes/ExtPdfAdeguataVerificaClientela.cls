/**
 * Progetto:         Banca IFIS
 * Descrizione:      Controller extension per la pagina PdfAdeguataVerifica Clientela.
 * Preleva da db tutte le informazioni necessarie per completare il pdf che non possono essere direttamente ottenute dallo standard controller
 * Sviluppata il:    16/01/2017
 * Developer:        Giuliani Luigi
*/
public without sharing class ExtPdfAdeguataVerificaClientela {
	public Opportunity o { get; set; }
	public Account a { get; set; }
	public Boolean isTiAnticipo { get; set; }
	private list<NDGLinea__c> ndgCoinvolti;
	public String[] PIVACliente { get; set; }
	public String[] VATCliente { get; set; }
	public String[] CFCliente { get; set; }
	public boolean sedeAmmUguale { get; set; }

	//variabili relative a MAV
	public List<NDGTitolareWrapper> ndgTitolariWrap { get; set; }
	public Decimal titolariSize {
		get {
			return ndgTitolariWrap.size();
		}
	}
	public Contact esecutore { get; set; }
	public String[] CFEsecutore { get; set; }
	public AdeguataVerifica__c adegVerifica { get; set; }
	public boolean indirizzoEsecUguale { get; set; }

	// variabili relative a RSF
	public Linea[] lineeMutuo { get; set; }
	public Linea lineaFidoDiCassa { get; set; }
	public Linea lineaPlafondProroga { get; set; }
	public Linea lineaIfisImpresa { get; set; }

	public String importoFidoLettere { get; set; }
	private List<Linea__c> linee { get; set; }
	public List<NDGDebitoreWrapper> ndgDebitoriWrap { get; set; }
	public List<NDGDebitoreWrapper> ndgConfirming { get; set; }

	public class Linea {
		public Decimal importo { get; set; }
		public Decimal durataDilazione { get; set; }
		public Decimal durataMaxCredito { get; set; }
		public String importoLettere { get; set; }

		public Linea() { }

		public Linea(Decimal importo, Decimal durataDilazione, Decimal durataMaxCredito) {
			this.importo = importo;
			this.durataDilazione = durataDilazione;
			this.durataMaxCredito = durataMaxCredito;
			this.importoLettere = '';
		}
	}

	public class NDGTitolareWrapper {
		public Contact titolare { get; set; }
		public String tipologia { get; set; }
		public Integer counter { get; set; }
		public String[] CFArray { get; set; }

		public NDGTitolareWrapper(Contact titolare, String tipologia, Integer counter) {
			this.titolare = titolare;
			this.tipologia = tipologia;
			this.counter = counter;
			this.CFArray = new String[] { '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '' };
			if (!String.isBlank(titolare.CF__c))
			this.CFArray = titolare.CF__c.split('');
		}
	}

	public class NDGDebitoreWrapper {
		public Account debitore { get; set; }
		public Decimal fatturato { get; set; }
		public Decimal durataNominale { get; set; }
		public Decimal plafond { get; set; }

		public NDGDebitoreWrapper(Account debitore, Decimal fatturato, Decimal durataNominale, Decimal plafond) {
			this.debitore = debitore;
			this.fatturato = fatturato;
			this.durataNominale = durataNominale;
			this.plafond = plafond;
		}
	}

	public ExtPdfAdeguataVerificaClientela() {
		//inizializzo variabili in comune
		this.o = [SELECT Id,
		          Account.Name,
		          Account.ATECO__c,
		          Account.BillingStreet,
		          Account.BillingCity,
		          Account.BillingPostalCode,
		          Account.BillingState,
		          Account.BillingCountry,
		          Account.CCIAA__c,
		          Account.ProvinciaCCIAA__c,
		          Account.ClienteDettaglio__c,
		          Account.ConsensoAllaProfilazione__c,
		          Account.ConsensoAttivitaPromozionaleTerzi__c,
		          Account.ConsensoAttivitaPromRicercheMercato__c,
		          Account.ConsensoProdottiBancaRicercheMercato__c,
		          Account.ConsensoProdottiSocietaTerze__c,
		          Account.ConsensoSoloModalitaTradizionali__c,
		          Account.DataInserimentoConsensi__c,
		          Account.DataIscrizioneCCIAA__c,
		          Account.Email__c,
		          Account.EmailPEC__c,
		          Account.Fax,
		          Account.PaeseCasaMadre__c,
		          Account.PaeseRelazioni1__c,
		          Account.PaeseRelazioni2__c,
		          Account.PaeseRelazioni3__c,
		          Account.PaeseSvolgimentoAttivitaPrevalente__c,
		          Account.PartecipazioneSocietaFiduciarie2__c,
                  Account.PartecipazioneSocietaFiduciarie__c,
		          Account.ProvinciaAttivitaPrevalente__c,
		          Account.Phone,
		          Account.TelefonoPrefisso__c,
		          Account.TelefonoNumero__c,
		          Account.REA__c,
		          Account.SAE__c,
		          Account.ShippingCity,
		          Account.ShippingCountry,
		          Account.ShippingPostalCode,
		          Account.ShippingState,
		          Account.ShippingStreet,
		          Account.SIA__c,
		          Account.NumberOfEmployees,
		          Account.Fatturato__c,
		          Account.RicaviNetti__c,
		          TiAnticipo__c,
		          Account.EmailPECFatturaElettronica__c,
		          Account.CodiceDestinatario__c,
		          //adione adeguamenti MAV
		          Account.PIVA__c,
		          Account.CF__c
		          FROM Opportunity
		          WHERE Id = :ApexPages.currentPage().getParameters().get('id')];

		this.a = o.Account;
		this.isTiAnticipo = o.TiAnticipo__c;

		ndgCoinvolti = new List<NDGLinea__c> ();
		PIVACliente = new String[] { '', '', '', '', '', '', '', '', '', '', '' };
		VATCliente = new String[] { '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '' };
		CFCliente = new String[] { '', '', '', '', '', '', '', '', '', '', '' };
		CFEsecutore = new String[] { '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '' };
		sedeAmmUguale = false;
		//inizializzo variabili MAV
		ndgTitolariWrap = new List<NDGTitolareWrapper> ();
		indirizzoEsecUguale = false;
		adegVerifica = new AdeguataVerifica__c();
		esecutore = new Contact();
		//inizializzo variabili RSF
		linee = new List<Linea__c> ();
		ndgDebitoriWrap = new List<NDGDebitoreWrapper> ();
		ndgConfirming = new List<NDGDebitoreWrapper> ();
		importoFidoLettere = '';

		getNdgCoinvolti(o);
		popolaTitolari();
		popolaDatiCliente();
		popolaAdeguataVerifica();
		popolaEsecutore();
		popolaDebitori(o);
		popolaPresenzaConfirming(o);
		popolaLinee();
	}

	public ExtPdfAdeguataVerificaClientela(ApexPages.StandardController stdController) {
		//inizializzo variabili in comune
		this.o = (Opportunity) stdController.getRecord();
		Opportunity myTestOpp = [SELECT Id,
		          Account.Name,
		          Account.ATECO__c,
		          Account.BillingStreet,
		          Account.BillingCity,
		          Account.BillingPostalCode,
		          Account.BillingState,
		          Account.BillingCountry,
		          Account.CCIAA__c,
		          Account.ProvinciaCCIAA__c,
		          Account.ClienteDettaglio__c,
		          Account.ConsensoAllaProfilazione__c,
		          Account.ConsensoAttivitaPromozionaleTerzi__c,
		          Account.ConsensoAttivitaPromRicercheMercato__c,
		          Account.ConsensoProdottiBancaRicercheMercato__c,
		          Account.ConsensoProdottiSocietaTerze__c,
		          Account.ConsensoSoloModalitaTradizionali__c,
		          Account.DataInserimentoConsensi__c,
		          Account.DataIscrizioneCCIAA__c,
		          Account.Email__c,
		          Account.EmailPEC__c,
		          Account.Fax,
		          Account.PaeseCasaMadre__c,
		          Account.PaeseRelazioni1__c,
		          Account.PaeseRelazioni2__c,
		          Account.PaeseRelazioni3__c,
		          Account.PaeseSvolgimentoAttivitaPrevalente__c,
		          Account.PartecipazioneSocietaFiduciarie2__c,
                  Account.PartecipazioneSocietaFiduciarie__c,
		          Account.ProvinciaAttivitaPrevalente__c,
		          Account.Phone,
		          Account.TelefonoPrefisso__c,
		          Account.TelefonoNumero__c,
		          Account.REA__c,
		          Account.SAE__c,
		          Account.ShippingCity,
		          Account.ShippingCountry,
		          Account.ShippingPostalCode,
		          Account.ShippingState,
		          Account.ShippingStreet,
		          Account.SIA__c,
		          Account.NumberOfEmployees,
		          Account.Fatturato__c,
		          Account.RicaviNetti__c,
		          TiAnticipo__c,
		          Account.EmailPECFatturaElettronica__c,
		          Account.CodiceDestinatario__c,
		          //adione adeguamenti MAV
		          Account.PIVA__c,
		          Account.CF__c     
                  FROM Opportunity
                  WHERE Id = :this.o.Id LIMIT 1];
system.debug('costruttore.227: '+o);
system.debug('costruttore.228: '+myTestOpp);
		ndgCoinvolti = new List<NDGLinea__c> ();
		PIVACliente = new String[] { '', '', '', '', '', '', '', '', '', '', '' };
		VATCliente = new String[] { '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '' };
		CFCliente = new String[] { '', '', '', '', '', '', '', '', '', '', '' };
		CFEsecutore = new String[] { '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '' };
		sedeAmmUguale = false;
		//inizializzo variabili MAV
		ndgTitolariWrap = new List<NDGTitolareWrapper> ();
		indirizzoEsecUguale = false;
		adegVerifica = new AdeguataVerifica__c();
		esecutore = new Contact();
		//inizializzo variabili RSF
		linee = new List<Linea__c> ();
		ndgDebitoriWrap = new List<NDGDebitoreWrapper> ();
		ndgConfirming = new List<NDGDebitoreWrapper> ();
		importoFidoLettere = '';

		getNdgCoinvolti(o);
		popolaTitolari();
		popolaDatiCliente();
		popolaAdeguataVerifica();
		popolaEsecutore();
		popolaDebitori(o);
		popolaPresenzaConfirming(o);
		popolaLinee();
system.debug('costruttore.253: '+o);
	}

	public static boolean verificaSeIndirizziUguali(String street1, String city1, String postalCode1, String street2, String city2, String postalCode2) {
		return(street1.toLowerCase(UserInfo.getLocale()).normalizeSpace().equals(street2.toLowerCase(UserInfo.getLocale()).normalizeSpace()) &&
		       city1.toLowerCase(UserInfo.getLocale()).normalizeSpace().equals(city2.toLowerCase(UserInfo.getLocale()).normalizeSpace()) &&
		       postalCode1.toLowerCase(UserInfo.getLocale()).normalizeSpace().equals(postalCode2.toLowerCase(UserInfo.getLocale()).normalizeSpace()));
	}

	//funzione che scarica tutti gli NDG relativi all'opportunity. Da invocare prima di popolare titolari, esecutori e debitori
	private void getNdgCoinvolti(Opportunity o) {
		try {
			ndgCoinvolti = [SELECT Name,
			                Contact__c,
			                Tipo__c,
			                EsecutoreAV__c,
			                Contact__r.Name,
			                Contact__r.LastName,
			                Contact__r.Firstname,
			                Contact__r.LuogoNascita__c,
			                Contact__r.Cittadinanza__c,
			                Contact__r.Sesso__c,
			                Contact__r.CF__c,
			                Contact__r.TipoDocumentoId__c,
			                Contact__r.TipoDocumentoIdMav__c,
			                Contact__r.NumeroDoc__c,
			                Contact__r.LuogoEmissioneDoc__c,
			                Contact__r.DataEmissioneDoc__c,
			                Contact__r.MailingStreet,
			                Contact__r.MailingCity,
			                Contact__r.MailingPostalCode,
			                Contact__r.MailingState,
			                Contact__r.MailingCountry,
			                Contact__r.OtherStreet,
			                Contact__r.OtherCity,
			                Contact__r.OtherPostalCode,
			                Contact__r.OtherState,
			                Contact__r.OtherCountry,
			                Contact__r.Birthdate,
			                Contact__r.ProvinciaNascita__c,
			                Contact__r.PaeseNascita__c,
			                Contact__r.DataScadenzaDoc__c,
			                Contact__r.PEP__c,
			                Contact__r.PEPTipoCarica__c,
			                Contact__r.Phone,
			                Contact__r.TelefonoPrefisso__c,
			                Contact__r.TelefonoNumero__c,
			                Contact__r.Fax,
			                tolabel(Contact__r.Professione__c),
			                Contact__r.TAECode__c,
			                Contact__r.ConsensoAllaProfilazione__c,
			                Contact__r.ConsensoAttivitaPromozionaleTerzi__c,
			                Contact__r.ConsensoAttivitaPromRicercheMercato__c,
			                Contact__r.ConsensoProdottiBancaRicercheMercato__c,
			                Contact__r.ConsensoProdottiSocietaTerze__c,
			                Contact__r.ConsensoSoloModalitaTradizionali__c,
			                Contact__r.DataInserimentoConsensi__c,
			                Contact__r.Ruolo__c,
                            Contact__r.Description,
			                Account__c,
			                Plafond__c,
			                Fatturato__c,
			                DurataNominale__c,
			                DurataMediaCredito__c,
			                TipologiaTitolareEffettivo__c,
			                Account__r.Name,
			                Account__r.CF__c,
			                Account__r.BillingStreet,
			                Account__r.BillingCity,
			                Account__r.BillingPostalCode,
			                Account__r.BillingState,
			                Account__r.PIVA__c,
                            Account__r.PartecipazioneSocietaFiduciarie2__c,
                            Account__r.PartecipazioneSocietaFiduciarie__c
			                FROM NDGLinea__c WHERE Opportunita__c = :o.Id];
		} catch(QueryException err) {
			throw new Ex.PdfException('Errore recupero NDG', err);
		}
	}

	//TODO COMPLETO CON CAMPI CORRETTO e metto where ndglinea = etc
	public void popolaTitolari() {

		//update counter
		Integer counter = 1;
		for (NDGLinea__c ndg : ndgCoinvolti) {
			if (ndg.Contact__c != null && ndg.Tipo__c == 'Titolare effettivo adeguata verifica') {
				//adione CRM 20
				String tipo = [SELECT WGC_Tipologia_Titolare_Effettivo__c
				               FROM AccountContactRelation
				               WHERE ContactId = :ndg.Contact__c AND AccountId = :o.AccountId
				               LIMIT 1].WGC_Tipologia_Titolare_Effettivo__c;

				System.debug('-----> tipo TITEF: '+tipo);
				ndgTitolariWrap.add(new NDGTitolareWrapper(ndg.Contact__r, tipo, counter));
				//ndgTitolariWrap.add(new NDGTitolareWrapper(ndg.Contact__r, ndg.TipologiaTitolareEffettivo__c, counter));
				counter++;
			}
		}
	}

	//funzione che prende i campi necessari per l'adeguata verifica
	public void popolaAdeguataVerifica() {
		try {
			List<AdeguataVerifica__c> ad = [SELECT id,
			                                Opportunita__c,
			                                TipoIndirizzo__c,
			                                NaturaRapportoContinuativoFD__c,
			                                NaturaRapportoContinuativoFI__c,
			                                NaturaRapportoContinuativoPB__c,
			                                ScopoFD11__c,
			                                ScopoFD12__c,
			                                ScopoFD13__c,
			                                ScopoFD14__c,
			                                ScopoFD15__c,
			                                ScopoFD16__c,
			                                ScopoFD17__c,
			                                ScopoFD18__c,
			                                ScopoFD19__c,
			                                OrigineFondi1__c,
			                                OrigineFondi2__c,
			                                OrigineFondi3__c,
			                                OrigineFondi4__c,
			                                OrigineFondiAltro__c,
			                                CorrispondenzaStreetName__c,
			                                CorrispondenzaStreetNumber__c,
			                                toLabel(CorrispondenzaStreetType__c),
			                                CorrispondenzaCity__c,
			                                CorrispondenzaCountry__c,
			                                CorrispondenzaCAP__c,
			                                CorrispondenzaState__c
			                                FROM AdeguataVerifica__c WHERE Opportunita__c = :o.Id];

			if (ad.size() > 0) {
				adegVerifica = ad[0];
			}

		} catch(QueryException err) {
			throw new Ex.PdfException('Errore recupero Adeguata verifica cliente', err);
		}
	}

	//funzione per prendere tutti i  dati relativi al cliente (account)
	public void popolaDatiCliente() {
		try {
			Opportunity opp = [SELECT id,
			                   Account.CF__c,
			                   Account.PIVA__c,
			                   Account.BillingStreet,
			                   Account.BillingCity,
			                   Account.BillingPostalCode,
			                   Account.ShippingStreet,
			                   Account.ShippingCity,
			                   Account.ShippingPostalCode,
			                   Account.SIA__c,
			                   Account.ATECO__c,
			                   Account.PaeseCasaMadre__c,
			                   Account.PaeseRelazioni1__c,
			                   Account.PaeseRelazioni2__c,
			                   Account.PaeseRelazioni3__c,
			                   Account.SAE__c,
			                   Account.VAT__c,
			                   Account.AttivitaEconomicaSvolta__c,
			                   Account.OperativitaContropartiEstere__c,
			                   Account.PrincipaliPaesiCoinvolti__c,
                               Account.PartecipazioneSocietaFiduciarie2__c,
                               Account.PartecipazioneSocietaFiduciarie__c
			                   FROM Opportunity WHERE id = :o.id];
			if (!String.isBlank(opp.Account.PIVA__c))
			PIVACliente = opp.Account.PIVA__c.split('');
			if (!String.isBlank(opp.Account.VAT__c))
			VATCliente = opp.Account.VAT__c.split('');
			if (!String.isBlank(opp.Account.CF__c))
			CFCliente = opp.Account.CF__c.split('');

			if (!String.isBlank(opp.Account.BillingStreet) && !String.isBlank(opp.Account.BillingCity) && !String.isBlank(opp.Account.BillingPostalCode) &&
			    !String.isBlank(opp.Account.ShippingStreet) && !String.isBlank(opp.Account.ShippingCity) && !String.isBlank(opp.Account.ShippingPostalCode)) {

				sedeAmmUguale = verificaSeIndirizziUguali(opp.Account.BillingStreet, opp.Account.BillingCity, opp.Account.BillingPostalCode,
				                                          opp.Account.ShippingStreet, opp.Account.ShippingCity, opp.Account.ShippingPostalCode);
			}

		} catch(QueryException err) {
			throw new Ex.PdfException('Errore recupero titolari PIVA o CF cliente', err);
		}
	}

	//funzione che  popola tutti i dati degli esecutori, copiandoli nella variabile "esecutore"
	public void popolaEsecutore() {

		for (NDGLinea__c ndg : ndgCoinvolti) {

			if (ndg.Contact__c != null && ndg.Tipo__c == 'Esecutore adeguata verifica') {
				esecutore = ndg.Contact__r;

				if (!String.isBlank(esecutore.CF__c)) {
					CFEsecutore = esecutore.CF__c.split('');
				}
				if (!String.isBlank(esecutore.MailingStreet) && !String.isBlank(esecutore.MailingCity) && !String.isBlank(esecutore.MailingPostalCode) &&
				    !String.isBlank(esecutore.OtherStreet) && !String.isBlank(esecutore.OtherCity) && !String.isBlank(esecutore.OtherPostalCode)) {
					indirizzoEsecUguale = verificaSeIndirizziUguali(
					                                                esecutore.MailingStreet,
					                                                esecutore.MailingCity,
					                                                esecutore.MailingPostalCode,
					                                                esecutore.OtherStreet,
					                                                esecutore.OtherCity,
					                                                esecutore.OtherPostalCode
					);
				}
                
				//adione CRM 20
				AccountContactRelation acr = [SELECT WGC_Ruolo_Pratica__c, WGC_Tipologia_Esecutore__c
				               FROM AccountContactRelation
				               WHERE ContactId = :esecutore.Id AND AccountId = :o.AccountId
                               LIMIT 1];
                if (String.isNotBlank(acr.WGC_Ruolo_Pratica__c)) {
                    if (acr.WGC_Ruolo_Pratica__c.contains('Z1')) {
                        //Legale
                        esecutore.Description = 'legale';
                    } else if (acr.WGC_Ruolo_Pratica__c.contains('Z3')) {
                        esecutore.Description = 'procuratore';
                    } else {
                        //altro
                        Schema.DescribeFieldResult fieldResult = AccountContactRelation.WGC_Ruolo__c.getDescribe();
                        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                        for (Schema.PicklistEntry pickListVal : ple) {
                            if (acr.WGC_Tipologia_Esecutore__c == pickListVal.getValue()) {
                                   System.debug('@@@ pickListVal.getLabel(); ' + pickListVal.getLabel());
                                   esecutore.Description = pickListVal.getLabel();
                               }
                        }
                    }
                } else {
                    esecutore.Description='';
                }
				break;
			}
		}
	}

	private void popolaDebitori(Opportunity o) {
		for (NDGLinea__c ndg : ndgCoinvolti) {
			if (ndg.Account__c != null && ndg.Tipo__c == 'Debitore') {
				ndgDebitoriWrap.add(new NDGDebitoreWrapper(ndg.Account__r, ndg.Fatturato__c, ndg.DurataNominale__c, ndg.Plafond__c));
			}
		}
	}

	private void popolaPresenzaConfirming(Opportunity opp) {
		for (NDGLinea__c ndg : ndgCoinvolti) {
			if (ndg.Tipo__c == 'Valutazione portafoglio') {
				ndgConfirming.add(new NDGDebitoreWrapper(ndg.Account__r, ndg.Fatturato__c, ndg.DurataNominale__c, ndg.Plafond__c));
			}
		}
	}

	//funzione che preleva tutte le linee associat alla opportunity e le classifica nelle 4 linee  corrispondenti ai 4 prodotti
	private void popolaLinee() {
		linee = [SELECT Name,
		         Durata__c,
		         DurataDilazione__c,
		         DurataMaxCredito__c,
		         FinalitaMutuo__c,
		         GiorniFree__c,
		         Importo__c,
		         Opzioni__c,
		         Prodotto__c,
		         QuotaProSoluto__c,
		         Prodotto__r.Name,
		         Prodotto__r.CodiceUnivoco__c
		         FROM Linea__c WHERE Opportunity__c = :o.Id
		        ];

		Map<String, SObject> lMap = U.keyBy(linee, 'Prodotto__r.CodiceUnivoco__c');
		Linea__c[] lineeMutuoTmp = new Linea__c[] { };
		if ((Linea__c) lMap.get(K.CODPROD_MUTUO) != null) {
			lineeMutuoTmp.add((Linea__c) lMap.get(K.CODPROD_MUTUO));
		}
		if ((Linea__c) lMap.get(K.CODPROD_MUTUO_BRT) != null) {
			lineeMutuoTmp.add((Linea__c) lMap.get(K.CODPROD_MUTUO_BRT));
		}
		if ((Linea__c) lMap.get(K.CODPROD_MUTUO_PCNSA) != null) {
			lineeMutuoTmp.add((Linea__c) lMap.get(K.CODPROD_MUTUO_PCNSA));
		}
		Linea__c lineaFidoDiCassaTmp = (Linea__c) lMap.get(K.CODPROD_FIDO);
		Linea__c lineaPlafondProrogaTmp = (Linea__c) lMap.get(K.CODPROD_CON_PROROGA);
		Linea__c lineaIfisImpresaTmp = (Linea__c) lMap.get(K.CODPROD_IFIS_IMPRESA);
		Linea__c lineaIfisImpresaNonAffidatoTmp = (Linea__c) lMap.get(K.CODPROD_IFIS_IMPRESA_NON_AFFIDATO);

		if (!lineeMutuoTmp.isEmpty()) {
			lineeMutuo = new Linea[] { };
			for (Linea__c lmt : lineeMutuoTmp) {
				Linea lineaTemp = new Linea(lmt.Importo__c, null, null);
				lineaTemp.importoLettere = UtilNumeri.convertiInLettere((Double) lmt.Importo__c);
				lineeMutuo.add(lineaTemp);
			}
		}

		if (lineaFidoDiCassaTmp != null) lineaFidoDiCassa = new Linea(lineaFidoDiCassaTmp.Importo__c, null, null);
		if (lineaPlafondProrogaTmp != null) lineaPlafondProroga = new Linea(null, lineaPlafondProrogaTmp.DurataDilazione__c, lineaPlafondProrogaTmp.DurataMaxCredito__c);
		if (lineaIfisImpresaTmp != null || lineaIfisImpresaNonAffidatoTmp != null) lineaIfisImpresa = new Linea();

		importoFidoLettere = lineaFidoDiCassa != null ? UtilNumeri.convertiInLettere((Double) lineaFidoDiCassaTmp.Importo__c) : null;
	}
}