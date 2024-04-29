/**
* Progetto:         Revisione componenti core per CRM 2.0.
* Sviluppatore      Marco Bonin <marco.bonin@bancaifis.it>
* Descrizione:      Classe di utility a supporto dei test con metodi comuni di utilità
*
*/

@isTest
public class BI_COM_UtilitiesSupportoTest_CODE  {

	public static final String MOCK_PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_PG = '{"payload":{"anagrafica":[{"ndg":2731775,"denominazione":"RACCORFERS.N.C.DIBRIVIOFABIO&C","tipologia":"IMPRESA","segmento":null,"agenzia":100,"gestore":{"codice":0,"descrizione":null},"telefono":{"prefisso":3,"numero":99241116},"cellulare":null,"codiceFiscale":"00748820131","sesso":null,"residenzaLegale":{"indirizzo":{"tipo":"VIA","nome":"GIOACCHINOROSSINI","numero":null},"comune":"MISSAGLIA","provincia":"LC","cap":23873},"nazione":"ITALIA","dataDiNascita":null,"luogoDiNascita":null,"email":null}]},"headers":{"headers":{"tech_header":{"id":"tech_header","applicationCode":"CRM","correlationId":null,"channel":null,"timeStamp":null,"workstationId":null,"clientIpAddress":null,"clientHostname":null},"user_header":{"id":"user_header","archUser":{"name":null,"surname":null,"emailAddress":null,"phoneNumber":null,"userId":"ATELNEXT","actualUserId":"AdminTelnext","institute":null,"userGroups":null,"userRoles":null}}}}}';
	public static final String MOCK_PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_PG_KO = '{"payload":{"anagrafica":[]},"headers":{"headers":{"tech_header":{"id":"tech_header","applicationCode":"CRM","correlationId":"abcd-1539867688086-efgh","channel":"B2B","timeStamp":1539867688086,"workstationId":null,"clientIpAddress":null,"clientHostname":null},"user_header":{"id":"user_header","archUser":{"name":"CRM Salesforce","surname":"SFDC","emailAddress":null,"phoneNumber":null,"userId":"ext.crm","actualUserId":"ext.crm","institute":null,"userGroups":[{"name":"Users","description":""},{"name":"NoLocalLogon","description":""}],"userRoles":[]}}}}}';
	public static final String MOCK_PAYLOAD_RIBES_GETLISTAAZIENDE = '{"payload": {"data": 1492182023634,"risposta": {"prodotto": {"cd": "BICLISAZ","Imprese": {"idBicLista": "47935","posizioni": "14","Impresa": [{"completa": "S","Cciaa": "PD","NRea": "383414","Denominazione": "CLICK BUSINESS S.R.L. IN LIQUIDAZIONE","CodFisc": "04361070289","PIva": "04361070289","NatGiu": {"cod": "SR","gruppo": "1","content": "SOCIETA A RESPONSABILITA LIMITATA"},"DataCessazioneIC": "2012-01-26","StatoAttivitaR": {"cod": "C","semaforo": "R","content": "CESSATA"},"Ateco07": {"cod": "6202","content": "Consulenza nel settore delle tecnologie dellinformatica"},"Indirizzo": {"Provincia": {"regione": "05","content": "PD"},"Comune": "PADOVA","Toponimo": "VIA","Via": "BORDIGA","NCivico": "7","Cap": "35136"}}]},"fmt": "FLD"}},"ticketId": "10809196"},"headers": {"headers": {"tech_header": {"id": "tech_header","applicationCode": "CRM","correlationId": "randomID","channel": "DSK","timeStamp": null,"workstationId": null,"clientIpAddress": "clientIP","clientHostname": null},"user_header": {"id": "user_header","archUser": {"name": "rendimax/contomax","surname": null,"emailAddress": null,"phoneNumber": null,"userId": "rendimax/contomax","actualUserId": null,"institute": "IFIS","userGroups": [{"name": "Group1","description": "IFIS Group1"}, {"name": "Group2","description": "IFIS Group2"}],"userRoles": [{"name": "Role1","description": "IFIS Role1"}, {"name": "Role2","description": "IFIS Role2"}]}}}}}';

	public static ImpostazioniServizi__c getImpostazioniServizi() {

		ImpostazioniServizi__c impostazioneServizi = new ImpostazioniServizi__c(
			SetupOwnerId=UserInfo.getOrganizationId(),
			CodiceIstituto3N__c = '881'
		);

		return impostazioneServizi;
	}

	public static EndpointServizi__c getCustomSettingEndpointServizi () {

		EndpointServizi__c endPoint = new EndpointServizi__c(
		  Name = 'settings',
		  LAGKey__c = 'B3DAF392-AF8C-4687-8387-48261E9A63FD',
		  LAGKeyHeroku__c = 'B3DAF392-AF8C-4687-8387-48261E9A63FD',
		  // ANAG
		  UrlGetDatiAnagraficiCedacri__c = 'https://anag',
		  UrlRicercaAnagraficaCedacri__c = 'https://',
		  UrlSetAnagraficaLight__c = 'https://',
		  UrlSetAnagraficaCedacri__c = 'https://',
		  UrlSetAnagraficaVariazione__c = 'https://',
		  UrlGestioneCollNdg__c = 'https://coll',
		  UrlSetRetiAnagraficheIfis__c = 'https://',
		  // CRM
		  UrlNvAggiornamentoInnescaVendita__c = 'https://',
		  UrlNvInquiryStatoCartella__c = 'https://',
		  UrlRenderPdf__c = 'https://',
		  // DOC
		  UrlCancellaOggetti__c = 'https://',
		  UrlSearchDocument__c = 'https://',
		  UrlDettaglioOggetto__c = 'https://',
		  // PEF
		  UrlInterrogazioneBilanci__c = 'https://',
		  UrlAggiornamentoStatoCartella__c = 'https://',
		  UrlCheckStatoPef__c = 'https://',
		  //RIBES
		  URLGetListaAziendeRibes__c = 'https://',
		  URLGetInformazioniPGRibes__c = 'https://',
		  UrlDatiBilancio__c = 'https://',
		  URLGetEventiNegativiRibes__c = 'https://',
		  URLGetBilancioSinteticoRibes__c = 'https://',
		  //ALTRO
		  urlFileNet__c = 'https://',
		  UrlEsistePef__c = 'https://',
		  UrlDocumentiTaStatici__c = 'https://',
		  // QQ
		  URLModificaDatiAggiuntiviQQ__c = 'https://',
		  //PDF PARSER
		  UrlCertificazioneParser__c = 'https://'
		);

		return endPoint;
	}

	public static List<Comune__c> getComuni(){

		List<Comune__c> actualList = new List<Comune__c>();

		Comune__c c1 = new Comune__c(Name = 'VENEZIA', Cap__c = '30100', Provincia__c = 'VE', FlagStorico__c = false, CodiceCatastale__c = 'L736');

		actualList.add(c1);

		return actualList;

	}

	public static List<Account> getAccounts(){

		List<Account> actualList = new List<Account>();

		Account a1 = new Account(Name = 'PULIRAPIDA SPA ', PIVA__c = '07864443511', NDGGruppo__c = '100666', CodiceIstituto3N__c = '881', WGC_Specialista_Factoring__c = UserInfo.getUserId()); 

		actualList.add(a1);

		return actualList;

	}

	public static List<Contact> getContacts(){

		List<Contact> actualList = new List<Contact>();

		Contact c1 = new Contact(FirstName = 'GIULIO', LastName = 'CESARE', NDGGruppo__c = '100667'); 

		actualList.add(c1);

		return actualList;

	}


	public static List<Lead> getLeads(){

		List<Lead> actualList = new List<Lead>();

		Lead l1 = new Lead(BI_NaturaGiuridica__c = 'SRL', BI_Tipo_Persona__c = 'PG', Company = 'PULIRAPIDA SPA ', PIVA__c = '07864443511', Status = 'Da qualificare', FirstName = 'Marco', LastName = 'Aurelio', Phone = '00393385878987', Email = 'marco.aurelio@bancaifis.it', State = 'VE', PostalCode = '30172', Street = 'Via Gatta', City = 'Venezia', WGC_Tipo_Via__c = 'VIA', WGC_Codice_Fiscale__c = 'BNNMRC76T21L736K', WGC_Sesso__c = 'M'); 
		actualList.add(l1);

		return actualList;

	}

	public static Lead getLead_FormWeb(){

		Lead l1 = new Lead(Company = 'BANCA IFIS SPA ', PIVA__c = '02992620274', Status = 'Da qualificare', FirstName = 'Marco', LastName = 'Aurelio', Phone = '00393385878987', Email = 'marco.aurelio@bancaifis.it', State = 'VE', PostalCode = '30172', Street = 'Via Gatta', City = 'Venezia'); 
		l1.IFISIdUnicoForm__c = '9508eb208388cef657421b87a54527';
		l1.IFISForm__c = '3';
		l1.TipoAccount__c = '2';
		l1.Tag__c = '';
		l1.Messaggio__c = 'Ho bisogno di un contatto per sviluppare il mio business';

		return l1;

	}

	public static Lead getLeadPG_DaCensire(){

		Lead l1 = new Lead(BI_NaturaGiuridica__c = 'SRL', BI_Tipo_Persona__c = 'PG', Company = 'PULIRAPIDA SPA ', PIVA__c = '07864443511', Status = 'Da qualificare', FirstName = 'Marco', LastName = 'Aurelio', Phone = '00393385878987', Email = 'marco.aurelio@bancaifis.it', State = 'VE', PostalCode = '30172', Street = 'Via Gatta', City = 'Venezia', WGC_Tipo_Via__c = 'VIA', WGC_Codice_Fiscale__c = 'BNNMRC76T21L736K', WGC_Sesso__c = 'M'); 
		l1.Status = 'Da censire';

		return l1;

	}

	public static Lead getLeadDI_DaCensire(){

		Lead l2 = new Lead(BI_NaturaGiuridica__c = 'DI', BI_Tipo_Persona__c = 'DI', Company = 'NUOVA PULIRAPIDA SPA ', PIVA__c = '07864443511', Status = 'Da qualificare', FirstName = 'Marco', LastName = 'Aurelio', Phone = '00393385878987', Email = 'marco.aurelio@bancaifis.it', State = 'VE', PostalCode = '30172', Street = 'Via Gatta', City = 'Venezia', WGC_Tipo_Via__c = 'VIA', WGC_Codice_Fiscale__c = 'BNNMRC76T21L736K', WGC_Sesso__c = 'M'); 
		l2.Status = 'Da censire';

		return l2;

	}
}