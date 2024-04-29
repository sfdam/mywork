public with sharing class WsAnagraficaBean {

	public Decimal codiceIstituto3N;

	//NDG
	public String ndg;

	//Natura giuridica
	public String naturaGiuridica;
	public String amministrativa;

	//Attività economica
	public Decimal sae;
	public Decimal rae;
	public String ateco;
	public String codiceTAE;

	//Intestazione
	public String cognome;
	public String nome;
	public String attivita;

	//Intestazione x variazione. WORKAROUND BUG CEDACRI SU MAPPATURA INTESTAZIONE
	public String cognomeV;
	public String nomeV;
	public String attivitaV;

	//CCIAA
	public Date dataIscrizioneLegale;
	public Decimal rea;

	//Documento contact
	public String tipoDoc;
	public String numeroDoc;
	public Date dataEmissioneDoc;
	public String enteDoc;
	public Date dataScadenzaDocumento;

	//Indirizzi
	public String billingCity;
	public String billingStreetName;
	public String billingStreetType;
	public String billingStreetNumber;
	public Decimal billingPostalCode;
	public String billingCountry;
	public String billingState;

	public String shippingCity;
	public String shippingStreetName;
	public String shippingStreetType;
	public String shippingStreetNumber;
	public Decimal shippingPostalCode;
	public String shippingCountry;
	public String shippingState;

	//Dati contact
	public String sesso;
	public Date dataDiNascita;
	public String luogoDiNascita;
	public String provinciaDiNascita;
	public String codiceProfessione;

	//Piva-CF
	public String codiceFiscale;
	public String partitaIVA;

	//Dati di contatto
	public String email;
	public String numeroCellulare;
	public String prefissoTelefonoFisso;
	public String numeroTelefonoFisso;
	public String numeroFax;
	public String numeroTelefonoAlternativo;

	//Privacy
	public String consensoProfilazione;
	public String consensoProdMkt;
	public String consensoProdTerzi;
	public String consensoPromozMkt;
	public String consensoPromozTerzi;
	public String consensoModTradiz;
	public Datetime dataConsensi;

	// Dati aggiuntivi
	public Boolean partecipazioneSocietaFiduciarie;
	public Boolean presenzaDatiAggiuntivi;
	public DatiAggiuntivi[] datiAggiuntivi;
	public Boolean presenzaDatiAggiuntiviComplementari;
	public DatiAggiuntiviComplementari datiAggiuntiviComplementari;

	// Altro
	public String numeroAddetti;

	class DatiAggiuntivi {
		public Integer codiceDato;
		public String valoreCodiceDato;
		public DatiAggiuntivi(Integer codice, String valore) {
			this.codiceDato = codice;
			this.valoreCodiceDato = valore;
		}
	}

	public class DatiAggiuntiviComplementari {
		public String CodNazCasaMadre;
		public String IndirizzoInternet;
		public String emailPec;
		public String DataRifFatt;
		public String ImpFatt;
		public String CodNazPaese1;
		public String CodNazPaese2;
		public String CodNazPaese3;
		public String SedeProfessione;
		public String FatturatoBilancio;
		public String CapitaleSociale;
		public String ImportoRisultatoEconomico;
		public String NumeroDipendenti;
		public String Patrimonio;
		//FACTORY SV -- START
		public String EmissioniAzioniPortatore;
		public String PartecipazFidTrustFond;
		public String SedeFidTrustSaFond;
		public String StrutVeicoliInternPatrim;
		public String AssetPropAnomComplessi;
		public String RelazClienteEsecutore;
		public String UltimaProfesSvolta;
		public String FormaGiurSocAppart;
		//FACTORY SV -- END
	}

	public static final String[] REQUIRED_ACCOUNT_FIELDS = new String[] {
		'Ateco__c',
		'BillingCity',
		'BillingCountry',
		'BillingPostalCode',
		'BillingState',
		'BillingStreetName__c',
		'BillingStreetNumber__c',
		'BillingStreetType__c',
		'BU__c',
		'CF__c',
		'ComportamentoRilevato__c',
		'ConsensoAllaProfilazione__c',
		'ConsensoAttivitaPromozionaleTerzi__c',
		'ConsensoAttivitaPromRicercheMercato__c',
		'ConsensoProdottiBancaRicercheMercato__c',
		'ConsensoProdottiSocietaTerze__c',
		'ConsensoSoloModalitaTradizionali__c',
		'DataFatturato__c',
		'DataInserimentoConsensi__c',
		'DataIscrizioneCCIAA__c',
		'DettaglioCensimento__c',
		'Email__c',
		'EmailPEC__c',
		'Fatturato__c',
		'Fax',
		'GestoreCliente__c',
		'GestoreDebitore__c',
		'Id',
		'Name',
		'NaturaGiuridica__c',
		'NDGGruppo__c',
		'Owner.NDGGruppo__c',
		'OwnerId',
		'PaeseSvolgimentoAttivitaPrevalente__c',
		'PIVA__c',
		'ProvinciaAttivitaPrevalente__c',
		'ProvinciaCCIAA__c',
		'CCIAA__c',
		'QualificaCliente__c',
		'RAE__c',
		'REA__c',
		'SAE__c',
		'ScopoRapporto__c',
		'ShippingCity',
		'ShippingCountry',
		'ShippingPostalCode',
		'ShippingState',
		'ShippingStreetName__c',
		'ShippingStreetNumber__c',
		'ShippingStreetType__c',
		'StatoCensimento__c',
		'WGC_Censimento__c',
		'TAECode__c',
		'TelefonoNumero__c',
		'TelefonoPrefisso__c',
		'NumberOfEmployees',
		'Website',
		'PaeseCasaMadre__c',
		'PaeseRelazioni1__c',
		'PaeseRelazioni2__c',
		'PaeseRelazioni3__c',
		'ProvinciaSvolgimentoAttivitaPrevalente__c',
		'WGC_Numero_dipendenti__c'
	};

	public static final String[] REQUIRED_CONTACT_FIELDS = new String[] {
		'Birthdate',
		'CF__c',
		'CodCatastaleLocNascita__c',
		'ConsensoAllaProfilazione__c',
		'ConsensoAttivitaPromozionaleTerzi__c',
		'ConsensoAttivitaPromRicercheMercato__c',
		'ConsensoProdottiBancaRicercheMercato__c',
		'ConsensoProdottiSocietaTerze__c',
		'ConsensoSoloModalitaTradizionali__c',
		'DataEmissioneDoc__c',
		'DataInserimentoConsensi__c',
		'DataScadenzaDoc__c',
		'DettaglioCensimento__c',
		'Email',
		'EnteEmitettenteDocumento__c',
		'Fax',
		'FirstName',
		'Id',
		'LastName',
		'LuogoEmissioneDoc__c',
		'LuogoNascita__c',
		'MailingCity',
		'MailingCountry',
		'MailingPostalCode',
		'MailingState',
		'MailingStreetName__c',
		'MailingStreetNumber__c',
		'MailingStreetType__c',
		'MobilePhone',
		'NDGGruppo__c',
		'NumeroDoc__c',
		'Phone',
		'ProvinciaNascita__c',
		'SAE__c',
		'Sesso__c',
		'StatoCensimento__c',
		'WGC_Censimento_MAV__c',
		'TAECode__c',
		'TelefonoNumero__c',
		'TelefonoPrefisso__c',
		'TipoDocumentoId__c',
		'Phone',
		'Professione__c'
	};
	public final static String NATURAGIURIDICA_PF = 'PF';
	public static final String ERR_DI_SENZA_CONTACT = 'La ditta individuale non ha un titolare su CRM. Inserire il titolare e riprovare la convalida';
	private Set<String> dateFields = new Set<String> { 'dataIscrizioneLegale', 'dataEmissioneDoc', 'dataDiNascita', 'dataScadenzaDocumento' };
	private Set<String> datetimeFields = new Set<String> { 'dataConsensi' };
	private Set<String> objectFields = new Set<String> { 'datiAggiuntivi', 'datiAggiuntiviComplementari' };
	private Set<String> numericFields = new Set<String> { 'codiceIstituto3N', 'sae' };

	/**
	 * SOQL per i campi obbligatori dell'account/contatto. Nel caso dell'account viene presa anche l'area.
	 * @param  oId id dell'account/contatto
	 * @return     account/contatto
	 */
	public static SObject getEntity(Id oId) {
		String oName = oId.getSobjectType().getDescribe().getName();
		String[] accountFields = new List<String> (REQUIRED_ACCOUNT_FIELDS);
		accountFields.addAll(new String[] { 'Area__c', 'PartecipazioneSocietaFiduciarie2__c' });
		String[] fields = oName == 'Account' ? accountFields : REQUIRED_CONTACT_FIELDS;
		SObject o = (Sobject) Database.query(QueryBuilder.newInstance(oName, fields).withId(oId).getQuery());
		return o;
	}

	private Contact getRelatedContact(String codiceFiscale, Id accId) {
		if (accId == null) throw new Ex.AnagrafeDiGruppoException(ERR_DI_SENZA_CONTACT);

		Contact[] cL = (Contact[]) Database.query(QueryBuilder.newInstance('Contact', REQUIRED_CONTACT_FIELDS)
		                                          .beginFilter()
		                                          .add('CF__c', QBOp.QEQUAL, codiceFiscale, true)
		                                          .addUntyped('Id IN (SELECT ContactId FROM AccountContactRelation WHERE AccountId = \'' + accId + '\')')
		                                          .endFilter()
		                                          .getQuery()
		);

		if (cL.isEmpty()) throw new Ex.AnagrafeDiGruppoException(ERR_DI_SENZA_CONTACT);
		return cL[0];
	}

	private void fixDatiIntestazioneBugCedacri() {
		System.debug('fixDatiIntestazioneBugCedacri');
		if (naturaGiuridica == 'DI' || naturaGiuridica == 'PF') {
			nomeV = nome;
			cognomeV = cognome;
			attivitaV = attivita;
		} else {
			if (attivita.length() <= 60) {
				cognomeV = attivita;
				nomeV = '${NULL}';
			} else {
				cognomeV = attivita.substring(0, 60);
				nomeV = attivita.substring(60);
			}
			attivitaV = '${NULL}';
		}
	}

	private void fillDatiServizio() {
		codiceIstituto3N = Decimal.valueOf(ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c);
	}

	public void fillFrom(Id oId) {
		SObject o = getEntity(oId);
		if (o.getSObjectType() == Account.SObjectType) fillFrom((Account) o);
		else fillFrom((Contact) o);
	}

	public void fillFrom(Account a) {
		fillFrom(a, null);
	}

	public void fillFrom(Account a, Contact c) {
		System.debug('SV Account fillFrom: ' + a);
		System.debug('SV Contact fillFrom: ' + c);
		if (a.NaturaGiuridica__c == 'DI') {
			fillFrom(c == null ? getRelatedContact(a.CF__c, a.Id) : c);
		}

		System.debug('SV Contact fillFrom EXIT: ' + c);

		amministrativa = '${NULL}';
		ndg = a.NDGGruppo__c;
		naturaGiuridica = a.NaturaGiuridica__c;
		attivita = a.Name.replace('"', '').toUpperCase(UserInfo.getLocale());
		sae = String.isBlank(a.SAE__c) ? 0 : Decimal.valueOf(a.SAE__c);
		rae = String.isBlank(a.RAE__c) ? 0 : Decimal.valueOf(a.RAE__c);
		fillAteco(a.Ateco__c);
		codiceTAE = a.TAECode__c;
		dataIscrizioneLegale = a.DataIscrizioneCCIAA__c;
		rea = String.isBlank(a.REA__c) ? 0 : Decimal.valueOf(a.REA__c);
		billingCity = String.isBlank(a.BillingCity) ? null : a.BillingCity.toUpperCase();
		billingStreetName = String.isBlank(a.BillingStreetName__c) ? null : a.BillingStreetName__c.toUpperCase();
		billingStreetType = String.isBlank(a.BillingStreetType__c) ? null : a.BillingStreetType__c.toUpperCase();
		billingStreetNumber = a.BillingStreetNumber__c;
		billingPostalCode = String.isBlank(a.BillingPostalCode) ? null : Decimal.valueOf(a.BillingPostalCode);
		billingCountry = String.isBlank(a.BillingCountry) ? null : a.BillingCountry.toUpperCase();
		billingState = String.isBlank(a.BillingState) ? null : a.BillingState.toUpperCase();
		System.debug('AFTER billingState');

		shippingCity = String.isBlank(a.ShippingCity) ? null : a.ShippingCity.toUpperCase();
		shippingStreetName = String.isBlank(a.ShippingStreetName__c) ? null : a.ShippingStreetName__c.toUpperCase();
		shippingStreetType = String.isBlank(a.ShippingStreetType__c) ? null : a.ShippingStreetType__c.toUpperCase();
		shippingStreetNumber = String.isBlank(a.ShippingStreetNumber__c) ? null : a.ShippingStreetNumber__c;
		shippingPostalCode = String.isBlank(a.ShippingPostalCode) ? null : Decimal.valueOf(a.ShippingPostalCode);
		shippingCountry = String.isBlank(a.ShippingCountry) ? null : a.ShippingCountry.toUpperCase();
		shippingState = String.isBlank(a.ShippingState) ? null : a.ShippingState.toUpperCase();
		System.debug('AFTER shippingState');

    //adione SDHDFNZ-94034
    codiceFiscale = a.CF__c.toUpperCase().trim();
		partitaIVA = a.PIVA__c;
		email = a.Email__c;
		prefissoTelefonoFisso = a.TelefonoPrefisso__c;
		numeroTelefonoFisso = a.TelefonoNumero__c;
		numeroFax = a.Fax;
		numeroAddetti = (a.WGC_Numero_dipendenti__c == null || a.WGC_Numero_dipendenti__c == 0) ? null : String.valueOf(a.WGC_Numero_dipendenti__c);
		fillPrivacy(a);
		fillDatiAggiuntivi(a);
		fillDatiAggiuntiviComplementari(a);

		fixDatiIntestazioneBugCedacri();
		fillDatiServizio();

		System.debug('EXIT');
	}

	// Contact:{CI3N_NDGGruppo__c=881-1830018, CodCatastaleLocNascita__c=L424, ConsensoAttivitaPromozionaleTerzi__c=false, Email=null, MailingCountry=ITALIA, ConsensoProdottiBancaRicercheMercato__c=false, ConsensoProdottiSocietaTerze__c=false, CI3N_CF__c=881-BRNGRG48E12L424Q, Origine__c=Cedacri, MailingState=MI, CF__c=BRNGRG48E12L424Q, CodiceIstituto3N__c=881, ProvinciaNascita__c=TS, NaturaGiuridica__c=PF, MailingPostalCode=20100, TAECode__c=984, Sesso__c=M, MailingStreetType__c=LARGO, ConsensoAttivitaPromRicercheMercato__c=false, FirstName=GIORGIO, CABLocNascita__c=2200, MailingStreetName__c=MONS. G. B. SCALABRINI, MailingCity=MILANO, Birthdate=1948-05-12 00:00:00, ConsensoSoloModalitaTradizionali__c=false, ConsensoAllaProfilazione__c=false, LuogoNascita__c=TRIESTE, NDGGruppo__c=1830018, LastName=BRONZIN, SAE__c=600, MailingStreetNumber__c=6, MailingStreet=null}

	public void fillFrom(Contact c) {
		System.debug('SV dentro fillFrom Contact: ' + c);
		ateco = '${NULL}';
		ndg = c.NDGGruppo__c;
		naturaGiuridica = NATURAGIURIDICA_PF;
		sae = String.isBlank(c.SAE__c) ? 0 : Decimal.valueOf(c.SAE__c);
		codiceTAE = c.TAECode__c;
		cognome = String.isBlank(c.LastName) ? null : c.LastName.toUpperCase(UserInfo.getLocale());
		nome = String.isBlank(c.FirstName) ? null : c.FirstName.toUpperCase(UserInfo.getLocale());
		billingCity = String.isBlank(c.MailingCity) ? null : c.MailingCity.toUpperCase();
		billingStreetName = String.isBlank(c.MailingStreetName__c) ? null : c.MailingStreetName__c.toUpperCase();
		billingStreetType = String.isBlank(c.MailingStreetType__c) ? null : c.MailingStreetType__c.toUpperCase();
		billingStreetNumber = c.MailingStreetNumber__c;
		billingPostalCode = String.isBlank(c.MailingPostalCode) ? null : Decimal.valueOf(c.MailingPostalCode);
		billingCountry = String.isBlank(c.MailingCountry) ? null : c.MailingCountry.toUpperCase();
		billingState = String.isBlank(c.MailingState) ? null : c.MailingState.toUpperCase();
		sesso = c.Sesso__c;
		dataDiNascita = c.Birthdate;
		luogoDiNascita = String.isBlank(c.LuogoNascita__c) ? null : c.LuogoNascita__c.toUpperCase();
		provinciaDiNascita = String.isBlank(c.ProvinciaNascita__c) ? null : c.ProvinciaNascita__c.toUpperCase();
		fillLocalitaDiNascita(c.CodCatastaleLocNascita__c);
    //adione SDHDFNZ-94034
    codiceFiscale = c.CF__c.toUpperCase().trim();
		email = c.Email;
		numeroCellulare = c.MobilePhone;
		numeroFax = c.Fax;
		numeroTelefonoAlternativo = c.Phone;
		prefissoTelefonoFisso = c.TelefonoPrefisso__c;
		numeroTelefonoFisso = c.TelefonoNumero__c;
		if (c.TipoDocumentoId__c != null && c.NumeroDoc__c != null && c.DataEmissioneDoc__c != null && c.DataScadenzaDoc__c != null && c.LuogoEmissioneDoc__c != null){
		   tipoDoc = c.TipoDocumentoId__c;
		   numeroDoc = c.NumeroDoc__c;
		   dataEmissioneDoc = c.DataEmissioneDoc__c;
		   dataScadenzaDocumento = c.DataScadenzaDoc__c;
		   enteDoc = String.isBlank(c.LuogoEmissioneDoc__c) ? null : c.LuogoEmissioneDoc__c.toUpperCase();
		}
		codiceProfessione = String.isBlank(String.ValueOf(c.Professione__c)) ? null : String.ValueOf(c.Professione__c);

		fillPrivacy(c);

		fixDatiIntestazioneBugCedacri();
		fillDatiServizio();
	}

	private void fillPrivacy(SObject o) {
		consensoProfilazione = o.get('ConsensoAllaProfilazione__c') == true ? 'S' : 'N';
		consensoPromozTerzi = o.get('ConsensoAttivitaPromozionaleTerzi__c') == true ? 'S' : 'N';
		consensoPromozMkt = o.get('ConsensoAttivitaPromRicercheMercato__c') == true ? 'S' : 'N';
		consensoProdMkt = o.get('ConsensoProdottiBancaRicercheMercato__c') == true ? 'S' : 'N';
		consensoProdTerzi = o.get('ConsensoProdottiSocietaTerze__c') == true ? 'S' : 'N';
		consensoModTradiz = o.get('ConsensoSoloModalitaTradizionali__c') == true ? 'S' : 'N';
		dataConsensi = (Datetime) o.get('DataInserimentoConsensi__c');
	}

	private void fillDatiAggiuntivi(SObject o) {
		partecipazioneSocietaFiduciarie = o.get('PartecipazioneSocietaFiduciarie2__c') == true;
		List<DatiAggiuntivi> datiAggiuntiviList = new List<DatiAggiuntivi> ();
		if (partecipazioneSocietaFiduciarie && o.getSObjectType() == Account.SObjectType) datiAggiuntiviList.add(new DatiAggiuntivi(1906, 'D'));
		if (datiAggiuntiviList.size() != 0) {
			presenzaDatiAggiuntivi = true;
			datiAggiuntivi = datiAggiuntiviList;
		}
	}

	private void fillDatiAggiuntiviComplementari(SObject o) {
		System.debug('@SObject: ' + o);

		DatiAggiuntiviComplementari datiAggiuntiviComplementariTemp = new DatiAggiuntiviComplementari();
		presenzaDatiAggiuntiviComplementari = false;

		if (o.getSObjectType() == Account.SObjectType) {

			// emailPec 
			String emailPec = (String) o.get('EmailPec__c');
			if (emailPec != null && emailPec != '') {
				datiAggiuntiviComplementariTemp.emailPec = emailPec;
				presenzaDatiAggiuntiviComplementari = true;
			}

			// CodNazCasaMadre 
			String codNazCasaMadre = (String) o.get('PaeseCasaMadre__c');
			if (codNazCasaMadre != null && codNazCasaMadre != '') {
				BI_UIC__mdt BI = [select UIC__c from BI_UIC__mdt WHERE Label = :codNazCasaMadre];
				datiAggiuntiviComplementariTemp.CodNazCasaMadre = BI.UIC__c;
				presenzaDatiAggiuntiviComplementari = true;
			}

			// WEBSITE
			String website = (String) o.get('Website');
			if (website != null && website != '') {
				datiAggiuntiviComplementariTemp.IndirizzoInternet = website;
				presenzaDatiAggiuntiviComplementari = true;
			}

			// FatturatoBilancio - il fatturato è in migliaia di euro
			Decimal fatturato = (Decimal) o.get('Fatturato__c');
			String codiceFatturato;
			Integer anno;
			if (fatturato == null)
				codiceFatturato = '00006'; //equivale a DATO NON DICHIARATO O NON PRESENTE
			else if (fatturato >= 0 && fatturato < 2000)
					codiceFatturato = '00002';
			else if (fatturato >= 2000 && fatturato < 10000)
					codiceFatturato = '00003';
			else if (fatturato >= 10000 && fatturato <= 50000)
					codiceFatturato = '00004';
			else if (fatturato > 50000)
					codiceFatturato = '00005';
			
			System.debug('SV FATTURATO: ' + (fatturato != null? String.valueOf(fatturato) : 'null'));

			Date dataFatturato = (Date) o.get('DataFatturato__c');
			if (dataFatturato != null) 
				anno = DateTime.newInstance(dataFatturato, Time.newInstance(0, 0, 0, 0)).year();
			else {
				Date today = System.Date.today();
				anno = today.year();
			}
			
			datiAggiuntiviComplementariTemp.FatturatoBilancio = codiceFatturato + String.valueOf(anno);
			presenzaDatiAggiuntiviComplementari = true;

			// Decimal fatturatoInMigliaia = fatturato;
			// cancello tutte le cifre sotto le migliaia
			// es. il valore "123.456.030,01" verrà inviato come "123456"
			// String tmp = String.valueOf((fatturatoInMigliaia.setScale(2) + 0.001));
			// String fatturatoInMigliaiaS = tmp.substring(0, tmp.length()-4);

			// ImpFatt contiene il fatturato annuo in migliaia di euro
			if(fatturato != null)
				datiAggiuntiviComplementariTemp.ImpFatt = String.valueOf(Integer.valueOf(fatturato));

			// DataRifFatt contiene il la data di riferimento del fatturato in formato yyyyMMdd
			if (dataFatturato != null) {
				String dataFatturatoS = DateTime.newInstance(dataFatturato, Time.newInstance(0, 0, 0, 0)).format('yyyyMMdd');
				datiAggiuntiviComplementariTemp.DataRifFatt = dataFatturatoS;
				presenzaDatiAggiuntiviComplementari = true;
			}

			// CodNazPaese1 
			String codNazPaese1 = (String) o.get('PaeseRelazioni1__c');
			if (codNazPaese1 != null && codNazPaese1 != '') {
				BI_UIC__mdt BI = [select UIC__c from BI_UIC__mdt WHERE Label = :codNazPaese1];
				datiAggiuntiviComplementariTemp.CodNazPaese1 = BI.UIC__c;
				presenzaDatiAggiuntiviComplementari = true;
			}

			// CodNazPaese2 
			String codNazPaese2 = (String) o.get('PaeseRelazioni2__c');
			if (codNazPaese2 != null && codNazPaese2 != '') {
				BI_UIC__mdt BI = [select UIC__c from BI_UIC__mdt WHERE Label = :codNazPaese2];
				datiAggiuntiviComplementariTemp.CodNazPaese2 = BI.UIC__c;
				presenzaDatiAggiuntiviComplementari = true;
			}

			// CodNazPaese3
			String codNazPaese3 = (String) o.get('PaeseRelazioni3__c');
			if (codNazPaese3 != null && codNazPaese3 != '') {
				BI_UIC__mdt BI = [select UIC__c from BI_UIC__mdt WHERE Label = :codNazPaese3];
				datiAggiuntiviComplementariTemp.CodNazPaese3 = BI.UIC__c;
				presenzaDatiAggiuntiviComplementari = true;
			}

			// SedeProfessione
			String sedeProfessione = (String) o.get('PaeseSvolgimentoAttivitaPrevalente__c');
			if (sedeProfessione != null && sedeProfessione != '') {
				if (sedeProfessione.equals('ITALIA'))
				sedeProfessione = (String) o.get('ProvinciaSvolgimentoAttivitaPrevalente__c');
				else {
					BI_UIC__mdt BI = [select UIC__c from BI_UIC__mdt WHERE Label = :sedeProfessione];
					sedeProfessione = BI.UIC__c;
				}
				datiAggiuntiviComplementariTemp.SedeProfessione = sedeProfessione;
				presenzaDatiAggiuntiviComplementari = true;
			}

			WGC_Bilancio__c bilancio = null;
			String idAccount = (String) o.get('Id');
			List<WGC_Bilancio__c> listaBilancio = [select Capitale__c, DataFatturato__c, UTILE_CORRENTE_UC__c, PatrimonioNetto__c FROM WGC_Bilancio__c WHERE Account__c = :idAccount order by DataFatturato__c desc limit 1];
			if (listaBilancio.size() > 0)
			bilancio = listaBilancio.get(0);

			// CapitaleSociale
			String capitale = '';
			if (bilancio != null && bilancio.Capitale__c != null && bilancio.Capitale__c >= 0) {
				datiAggiuntiviComplementariTemp.CapitaleSociale = String.valueOf(Integer.valueOf(bilancio.Capitale__c));
				presenzaDatiAggiuntiviComplementari = true;
			}

			// ImportoRisultatoEconomico
			String importoRisultatoEconomico = '';
			if (bilancio != null && bilancio.DataFatturato__c != null && bilancio.UTILE_CORRENTE_UC__c != null) {
				if (bilancio.UTILE_CORRENTE_UC__c > 0)
				importoRisultatoEconomico = '00001' + bilancio.DataFatturato__c.year();
				else
				importoRisultatoEconomico = '00002' + bilancio.DataFatturato__c.year();
				datiAggiuntiviComplementariTemp.ImportoRisultatoEconomico = importoRisultatoEconomico;
				presenzaDatiAggiuntiviComplementari = true;
			}

			// NumeroDipendenti
			Decimal numeroDipendenti = (Decimal) o.get('WGC_Numero_dipendenti__c');
			String codiceDipendenti;

			if (numeroDipendenti == null)
				codiceDipendenti = '00005'; //equivale a DATO NON DICHIARATO O NON PRESENTE
			else if (numeroDipendenti > 0 && numeroDipendenti < 10)
					codiceDipendenti = '00001';
			else if (numeroDipendenti >= 10 && numeroDipendenti < 50)
					codiceDipendenti = '00002';
			else if (numeroDipendenti >= 50 && numeroDipendenti <= 250)
					codiceDipendenti = '00003';
			else if (numeroDipendenti > 250)
					codiceDipendenti = '00004';
			
			System.debug('SV NUM. DIPENDENTI: ' + (numeroDipendenti != null? String.valueOf(numeroDipendenti) : 'null'));

			Date today = System.Date.today();
			String annoCorrente = String.valueOf(today.year());
			datiAggiuntiviComplementariTemp.NumeroDipendenti = codiceDipendenti + annoCorrente;

			// Patrimonio
			if (bilancio != null && bilancio.PatrimonioNetto__c != null) {
				datiAggiuntiviComplementariTemp.Patrimonio = String.valueOf(Integer.valueOf(bilancio.PatrimonioNetto__c));
				presenzaDatiAggiuntiviComplementari = true;
			}

			//FACTORY SV -- START
			//Emissioni Azioni Portarore
			Boolean emissioniAzioniPortatore = (Boolean)o.get('WGC_Emissioni_di_Azioni_al_Portatore_PNF__c');
			if(emissioniAzioniPortatore){
				datiAggiuntiviComplementariTemp.EmissioniAzioniPortatore = 'S';
				presenzaDatiAggiuntiviComplementari = true;
			}else{
				datiAggiuntiviComplementariTemp.EmissioniAzioniPortatore = 'N';
				presenzaDatiAggiuntiviComplementari = true;
			}
			//Partecipazione fiduciaria trust
			String partecipazioneFiduciariaTrust = (String)o.get('WGC_Partecipazione_societa_fiduciarie__c');
			if(partecipazioneFiduciariaTrust != null && partecipazioneFiduciariaTrust !=''){
				datiAggiuntiviComplementariTemp.PartecipazFidTrustFond = partecipazioneFiduciariaTrust;
				presenzaDatiAggiuntiviComplementari = true;
			}
			//Cod paese fiduciaria
			String codNazFid = (String)o.get('WGC_Partecipazione_Trust__c');
			if (codNazFid != null && codNazFid != '') {
				BI_UIC__mdt BI = [select UIC__c from BI_UIC__mdt WHERE Label = :codNazFid];
				datiAggiuntiviComplementariTemp.SedeFidTrustSaFond = BI.UIC__c;
				presenzaDatiAggiuntiviComplementari = true;
			}
			//Struttire qualificabili come veicoli di interposizione patrimoniale
			String partFiduciarie = (String)o.get('WGC_Partecipazione_societa_fiduciarie__c');
			if(partFiduciarie != null && partFiduciarie == '00'){
				datiAggiuntiviComplementariTemp.StrutVeicoliInternPatrim = 'N';
				presenzaDatiAggiuntiviComplementari = true;
			}else if(partFiduciarie != null && partFiduciarie != '00'){
				datiAggiuntiviComplementariTemp.StrutVeicoliInternPatrim = 'S';
				presenzaDatiAggiuntiviComplementari = true;
			}
			//Assetti proprietari
			Boolean assetProp = (Boolean)o.get('WGC_Assetti_Attivita_Svolta__c');
			if(assetProp){
				datiAggiuntiviComplementariTemp.AssetPropAnomComplessi = 'S';
				presenzaDatiAggiuntiviComplementari = true;
			}else{
				datiAggiuntiviComplementariTemp.AssetPropAnomComplessi = 'N';
				presenzaDatiAggiuntiviComplementari = true;
			}
			//Relazione cliente esecutore
			String accId = (String)o.get('Id');
            if(!Test.isRunningTest()){
               AccountContactRelation accRel = [SELECT Id, WGC_Relazioni_Tra_Cliente_ed_Esecutore__c FROM AccountContactRelation WHERE AccountId = :accId AND Contact.IsReferenteCampagna__c = false AND WGC_Ruolo__c != null LIMIT 1];
                if(accRel != null){
                    datiAggiuntiviComplementariTemp.RelazClienteEsecutore = accRel.WGC_Relazioni_Tra_Cliente_ed_Esecutore__c;
                    presenzaDatiAggiuntiviComplementari = true;
                } 
            }
			
			//Ultima professione svolta
			Contact con = [SELECT Ultima_professione_svolta__c, Forma_Giuridica_Societ_di_appartenenza__c FROM Contact WHERE AccountId = :accId LIMIT 1];
			if(con != null){
				datiAggiuntiviComplementariTemp.UltimaProfesSvolta = con.Ultima_professione_svolta__c;
				datiAggiuntiviComplementariTemp.FormaGiurSocAppart = con.Forma_Giuridica_Societ_di_appartenenza__c;
				presenzaDatiAggiuntiviComplementari = true;
			}
			
			
			//FACTORY SV --END


			if (presenzaDatiAggiuntiviComplementari) datiAggiuntiviComplementari = datiAggiuntiviComplementariTemp;
		}
	}

	private void fillAteco(String ateco) {
		Ateco__c[] aL = [SELECT Id, Name, Cedacri__c FROM Ateco__c WHERE Name = :ateco OR Cedacri__c = :ateco];
		if (aL.isEmpty() || aL[0].Name == '0') this.ateco = null;
		else this.ateco = aL[0].Cedacri__c;
	}

	private void fillLocalitaDiNascita(String codCatastale) {
		if (String.isBlank(codCatastale)) return;
		Comune__c c = UtilAnagrafiche.getComune(codCatastale);
		System.debug('SV COMUNE: ' + c);
		if (c != null) {
			provinciaDiNascita = c.Provincia__c;
			luogoDiNascita = c.Name;
		}
	}

	public String toJSON(String templateName) {
		StaticResource doc = [SELECT Id, Body FROM StaticResource WHERE Name = :templateName];
		String template = doc.Body.toString();

		String j = JSON.serialize(this);
		Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(j);

		template = evaluateIf(template, objMap);

		for (String k : objMap.keySet()) {
			if (numericFields.contains(k)) {
				template = template.replace('%' + k + '%', convert(k, objMap.get(k)));
			} else {
				template = template.replace('"%' + k + '%"', convert(k, objMap.get(k)));
			}
		}
        
		System.debug('PAYLOAD GENERATO!! ' + (String.isBlank(template) ? '' : template.replaceAll('\n', ' ')));
		return template;
	}

	private String evaluateIf(String template, Map<String, Object> context) {
		System.debug('context: ' + JSON.serialize(context));
		String t = template;
		final String BEGIN_IF = '//if %';
		final String END_IF = '//endif\n';
		final Pattern ISNOTBLANK = Pattern.compile('ISNOTBLANK\\(([^\\)]+)\\)');

		Integer prevIdx = 0;
		do {
			prevIdx = t.indexOf(BEGIN_IF);

			if (prevIdx != - 1) {
				Integer keyIdx = prevIdx + BEGIN_IF.length();

				Integer endIdx = t.indexOf(END_IF, keyIdx);

				Integer keyEndlineIdx = t.indexOf('\n', keyIdx) + 1;

				String key = t.substring(keyIdx, t.indexOf('%', keyIdx));
				Matcher m = ISNOTBLANK.matcher(key);
				Boolean checkNotBlank = false;
				if (m.matches()) {
					key = m.group(1);
					checkNotBlank = true;
				}
				Object v = context.get(key);
				t = t.substring(0, prevIdx) +
				(v == null || v == '' || (checkNotBlank && (v == '0' || v == 0)) ? '' : t.substring(keyEndlineIdx, endIdx)) +
				t.substring(endIdx + END_IF.length());
			}
		} while (prevIdx != - 1);

		return t;
	}

	private String convert(String k, Object v) {
		if (v == null) {
			return 'null';
		} else if (dateFields.contains(k)) {
			Date d = (Date) JSON.deserialize('"' + v + '"', Date.class);
			return String.valueOf(UDate.getLongValue(d));
		} else if (datetimeFields.contains(k)) {
			Datetime d = (Datetime) JSON.deserialize('"' + v + '"', Datetime.class);
			return String.valueOf(d.getTime());
		} else if (v == 'true' || v == 'false') {
			return String.valueOf(v);
		} else if (objectFields.contains(k)) {
			return JSON.serialize(v);
		} else if (numericFields.contains(k)) {
			return JSON.serialize(v);
		} else {
			return '"' + String.valueOf(v) + '"';
		}
	}

	public void validate(Boolean fullValidation) {
		Set<String> types = new Set<String> ();
		String type = naturaGiuridica == 'PF' ? 'PF' : (naturaGiuridica == 'DI' ? 'DI' : 'PG');
		types.add('light' + type);
		if (fullValidation) types.add('full' + type);

		CampoAnagrafe__mdt[] campiObbligatori = [SELECT
		                                         Label
		                                         FROM CampoAnagrafe__mdt
		                                         WHERE Mandatory__c = TRUE
		                                         AND Tipo__c IN :types
		                                        ];

		String[] campiMancantiLabel = new String[] { }; // UtilAnagrafiche.getCampiMancanti(acc, campiObbligatori); TODO FINIRE
		if (!campiMancantiLabel.isEmpty()) {
			throw new Ex.AnagrafeDiGruppoException('Mancano i seguenti campi obbligatori per il censimento: ' + String.join(campiMancantiLabel, ', '));
		}
	}
}