/**
* Progetto:         Banca IFIS
* Descrizione:      Classe di metodi utili per fare unit testing su Banca IFIS
* Sviluppata il:    05/10/2016
* Developer:        Zerbinati Francesco
*/

@isTest
public class TestUtils {

  public static final String SUPER_ALIAS = 'super';
  public static final String STANDARD_PROFILE = '00e580000014ABMAA2';
  public static final String ADMIN_PROFILE = '00e580000014ABGAA2';

  public static User creaUtente(String alias) { return creaUtente(alias, STANDARD_PROFILE); }

  public static User creaUtente(String alias, String profilo) {

    User testUser = new User(
      Alias = alias,
      Email = alias + '@testorg.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = profilo,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = alias + '@bancaifis.test.com',
      IsActive = true,
      NDGGruppo__c = String.valueOf((Math.random() * 1000000).intValue())
    );

    insert testUser;

    return testUser;
  }

  public static void impostaCS() {
    User testAdmin = creaUtente(SUPER_ALIAS, ADMIN_PROFILE);
    UtenzeDefault__c cs = new UtenzeDefault__c();
    cs.IdUtente__c = testAdmin.Id;
    cs.IdUtenteDefaultS__c = testAdmin.Id;
    cs.IdUtenteDefaultFD__c = testAdmin.Id;
    cs.IdAccountDiDefault__c = ''; // todo test: sistemare
    insert cs;

    insert new UtenzeDefault__c(
      SetupOwnerId = testAdmin.Id,
      IdUtente__c = testAdmin.Id,
      IdUtenteDefaultS__c = testAdmin.Id,
      IdUtenteDefaultFD__c = testAdmin.Id,
      AssegnatarioDiDefault__c = true
    );

    insert new ImpostazioniServizi__c(
      SetupOwnerId=UserInfo.getOrganizationId(),
      CodiceIstituto3N__c = '881'
    );
  }

  public static Account creaAccount(String nome) {
    User owner1 = creaUtente('user1');
    return creaAccount(nome, owner1);
  }

  public static Account creaAccount(String nome, User owner) {
    Account a = new Account(Name = nome, OwnerId = owner.Id, PIVA__c = (Math.random() + '').abbreviate(11), WGC_Canale_di_Sviluppo__c = 'Crediti Erariali', 
    NDGGruppo__c = String.valueOf(Math.Random()).substring(3,8), REA__c = (Math.random() + '').abbreviate(5), ProvinciaCCIAA__c = 'MI', EventiNegativiIdTicket__c = '111');
	insert a;
    return a;
  }

  public static Account creaAccountFD(String nome, User owner) {
    Account a = new Account(Name = nome, OwnerId = owner.Id, WGC_Specialista_Filo_Diretto__c = owner.Id, PIVA__c = (Math.random() + '').abbreviate(11), WGC_Canale_di_Sviluppo__c = 'Crediti Erariali', 
    NDGGruppo__c = String.valueOf(Math.Random()).substring(3,8), REA__c = (Math.random() + '').abbreviate(5), ProvinciaCCIAA__c = 'MI', EventiNegativiIdTicket__c = '111');
	insert a;
    return a;
  }

  public static Account creaAccountDEB(String nome, User owner) {
    Account a = new Account(Name = nome, OwnerId = owner.Id, WGC_Gestore_Debitore__c = owner.Id, PIVA__c = (Math.random() + '').abbreviate(11), WGC_Canale_di_Sviluppo__c = 'Crediti Erariali', 
    NDGGruppo__c = String.valueOf(Math.Random()).substring(3,8), REA__c = (Math.random() + '').abbreviate(5), ProvinciaCCIAA__c = 'MI', EventiNegativiIdTicket__c = '111');
	insert a;
    return a;
  }
  
  public static Account creaAccount(String nome, String codiceProvincia, String iva, String codFiscale) {
    User owner1 = creaUtente('user1');
    Account a = new Account(Name = nome, OwnerId = owner1.Id, ShippingState = codiceProvincia, BillingState = codiceProvincia, PIVA__c = iva, CF__c = codFiscale);
    insert a;
    return a;
  }

  public static Account creaAccount(String nome, User owner, String codiceProvincia, String iva, String codFiscale) {
    Account a = new Account(Name = nome, OwnerId = owner.id, ShippingState = codiceProvincia, BillingState = codiceProvincia, PIVA__c = iva, CF__c = codFiscale);
    insert a;
    return a;
  }

  public static Account creaAccount(String nome, User owner, String codiceProvincia, String iva, String codFiscale, String recordType) {
    Map<String, SObject> types = U.getRecordTypes('Account');
    Account a = new Account(Name = nome, OwnerId = owner.id, ShippingState = codiceProvincia, BillingState = codiceProvincia, PIVA__c = iva, CF__c = codFiscale, RecordTypeId = types.get(recordType).Id);
    insert a;
    return a;
  }

  public static Account creaAccount(String nome, User owner, String codiceProvincia, String iva, String codFiscale, String recordType, String ndg) {
    Map<String, SObject> types = U.getRecordTypes('Account');
    Account a = new Account(Name = nome, OwnerId = owner.Id, ShippingState = codiceProvincia, BillingState = codiceProvincia, PIVA__c = iva, CF__c = codFiscale, RecordTypeId = types.get(recordType).Id, NDGGruppo__c = ndg, NaturaGiuridica__c = 'AAA', BillingStreetName__c = 'AAA', BillingStreetNumber__c = 'AAA', BillingStreetType__c = 'via', BillingCity = 'AAA', BillingPostalCode = '9999');
    insert a;
    return a;
  }

  public static Ateco__c creaAteco(String codice) {
    return creaAteco(codice, 'Dettaglio ATECO Test', 'Settore attività ATECO Test', 'AAA', 'AGRICOLTURA');
  }

  public static Ateco__c creaAteco(String codice, String dettaglio, String settore, String cedacri, String mercato) {
    Ateco__c ateco = new Ateco__c(
      Name = codice,
      Descrizione__c = 'Codice ATECO Test',
      Dettaglio__c = dettaglio,
      Cedacri__c = cedacri,
      SettoreAttivita__c = settore,
      Mercato__c = mercato
    );

    insert ateco;
    return ateco;
  }

  public static Comune__c creaComune() {
    return creaComune('Comune test', 'Provincia test', '20155');
  }

  public static Comune__c creaComune(String cap) {
    return creaComune('Comune test', 'Provincia test', cap);
  }

  public static Allegato__c creaAllegato(Opportunity opp, String type) {
    Allegato__c allegato = new Allegato__c(
      Opportunita__c = opp.Id,
      Tipo__c = type
    );
    insert allegato;
    return allegato;
  }

  public static ContentDocumentLink creaContentDocumentLink(Allegato__c allegato, ContentVersion cv) {
    if (cv.ContentDocumentId == null) cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
    ContentDocumentLink link = new ContentDocumentLink(
      LinkedEntityId = allegato.Id,
      ContentDocumentId = cv.ContentDocumentId,
      ShareType = 'I'
    );
    insert link;
    return link;
  }

  public static ContentDocumentLink creaContentDocumentLink(Allegato__c allegato) {
    ContentVersion contentVersion_1 = new ContentVersion(
      Title = 'Penguins',
      PathOnClient = 'Penguins.jpg',
      VersionData = Blob.valueOf('Test Content'),
      IsMajorVersion = true
    );
    insert contentVersion_1;

    contentVersion_1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id];
    ContentDocumentLink link = new ContentDocumentLink(
      LinkedEntityId = allegato.Id,
      ContentDocumentId = contentVersion_1.ContentDocumentId,
      ShareType = 'I'
    );
    insert link;
    return link;
  }

  public static Comune__c creaStatoEstero(String nome) {
    Comune__c comune = new Comune__c(
      Name = nome,
      CodiceCatastale__c = 'Z100'
    );

    insert comune;
    return comune;
  }

  public static Comune__c creaComune(String nome, String provincia, String cap) {
    Comune__c comune = new Comune__c(
      Name = nome,
      Provincia__c = provincia,
      CAP__c = cap
    );

    insert comune;
    return comune;
  }

  public static AssegnazioneAnagrafica__c creaAssegnazioneAnagrafica(User utente, Comune__c comune) {
    return creaAssegnazioneAnagrafica(utente, comune, 'Filiale ' + comune.Name);
  }

  public static AssegnazioneAnagrafica__c creaAssegnazioneAnagrafica(User utente, Comune__c comune, String filiale) {
    AssegnazioneAnagrafica__c ass = new AssegnazioneAnagrafica__c(
      Utente__c = utente.Id,
      Comune__c = comune.Id,
      CAP__c = comune.Cap__c,
      Filiale__c = filiale
    );

    insert ass;
    return ass;
  }

  public static Contact creaReferente(Account a, String codFiscale) {
    Contact c = new Contact(FirstName = 'Referente', LastName = 'Test', AccountId = a.Id, OwnerId = a.OwnerId, CF__c = codFiscale);
    insert c;
    return c;
  }

  public static Contact creaReferente(Account a) {
    Contact c = new Contact(FirstName = 'Referente', LastName = 'Test', AccountId = a.Id, OwnerId = a.OwnerId);
    insert c;
    return c;
  }

  public static Contact creaReferente(String codFiscale, String nome, String cognome, String ndgGruppo) {
    Contact c = new Contact(FirstName = nome, LastName = cognome, CF__c = codFiscale, NDGGruppo__c = ndgGruppo);
    insert c;
    return c;
  }

  public static Contact creaReferente(Account account, String codFiscale, String nome, String cognome, String ndgGruppo) {
    Contact c = new Contact(AccountId = account.Id, FirstName = nome, LastName = cognome, CF__c = codFiscale, NDGGruppo__c = ndgGruppo);
    insert c;
    return c;
  }

  public static Task creaTask(Account a) {
    return creaTask(a, 'Contatto', 'ContattoTelefonicoDiretto');
  }

  public static Task creaTask(Account a, String subj, String recordType) {
    Date today = Date.today();
    Map<String, SObject> types = U.getRecordTypes('Task');
    Task t = new Task(OwnerId = a.OwnerId, Status = 'Aperto', Subject = subj, RecordTypeId = types.get(recordType).Id, Description = 'Test task', ActivityDate = today, WhatId = a.Id);
    insert t;
    return t;
  }

  public static Task creaTask(User owner, Account what, String subject, String status, String priority, Campaign campagna) {
    Date today = Date.today();
    Id campagnaId = campagna == null ? null : campagna.id;
    Task t = new Task(OwnerId = owner.id, WhatId = what.id, Subject = subject, Status = status, Priority = priority, Campagna__c = campagnaId, Description = 'Test task', ActivityDate = today);
    insert t;
    return t;
  }

  public static Event creaEvento(Account a, Contact c) {
    return creaEvento(a, c, 'Visita commerciale', 'VisitaCommerciale');
  }

  public static Event creaEvento(Account a, Contact c, String subj, String recordType) {
    Datetime now = Datetime.now();
    Map<String, SObject> types = U.getRecordTypes('Event');
    Event e = new Event(OwnerId = a.OwnerId, Subject = subj, RecordTypeId = types.get(recordType).Id, StartDateTime = now, EndDateTime = now, Description = 'Test event', WhoId = c.Id, WhatId = a.Id);
    insert e;
    return e;
  }

  public static Campaign creaCampagna() {
    return creaCampagna('Campagna');
  }

  public static Campaign creaCampagna(String nome) {
    Campaign camp = new Campaign(Name = nome);
    insert camp;
    return camp;
  }

  public static CampaignMember creaMembroCampagna(Campaign camp, Contact c) {
    CampaignMember m = new CampaignMember(CampaignId = camp.Id, ContactId = c.Id, status = 'Sent');
    insert m;
    return m;
  }

  public static Lead creaLead(String status, String ifisIdUnicoForm, String firstName, String lastName, String ragioneSociale, String phone, String email, String partitaIva, String tipoAccount, String state, String postalCode, String tag, String codiceOwner, String messaggio, String ifisForm, Integer webID) {

    Lead l = new Lead(Status = status,
                      IFISIdUnicoForm__c = ifisIdUnicoForm,
                      FirstName = firstName,
                      LastName = lastName,
                      RagioneSociale__c = ragioneSociale,
                      Phone = phone,
                      Email = email,
                      PIVA__c = partitaIva,
                      TipoAccount__c = tipoAccount,
                      State = state,
                      PostalCode = postalCode,
                      Tag__c = tag,
                      CodiceOwner__c = codiceOwner,
                      Messaggio__c = messaggio,
                      IFISForm__c = ifisForm,
                      WebID__c = webID,
                      Company = 'Company'
                     );
    insert l;
    return l;
  }

  public static QuestionarioQualitativo__c creaQQ(Account a) {
    QuestionarioQualitativo__c qq = new QuestionarioQualitativo__c(Account__c = a.id);
    qq.NomeModello__c = 'Small Business';
    CtrlCompilazioneQQ.Domanda domanda = new CtrlCompilazioneQQ.Domanda();
    domanda.codiceDatoDomanda =  66000;
    domanda.codiceModulo =  66000;
    domanda.domanda =  'domanda test';
    domanda.dominio =  new List<CtrlCompilazioneQQ.DominioRisposta>();
    domanda.value = 'BBBB';
    List<CtrlCompilazioneQQ.Domanda> domande = new List<CtrlCompilazioneQQ.Domanda>();
    domande.add(domanda);
    qq.Payload__c = JSON.serialize(domande);
    insert qq;
    return qq;
  }

  public static NDGLinea__c CreaNGDLinea(Contact c, Opportunity o) {
    NDGLinea__c ndg = new NDGLinea__c(Contact__c = c.id, Opportunita__c = o.id);
    insert ndg;
    return ndg;
  }

  public static NDGLinea__c CreaNGDLineaEsecutore(Contact c, Opportunity o) {
    NDGLinea__c ndg = new NDGLinea__c(Contact__c = c.id, Opportunita__c = o.id, EsecutoreAV__c = TRUE);
    insert ndg;
    return ndg;
  }

  public static NDGLinea__c CreaNGDLineaTitolare(Contact c, Opportunity o, Boolean isTitolare) {
    return TestUtils.CreaNGDLineaTitolare(c, o, isTitolare, 'Titolare effettivo adeguata verifica');
  }

  public static NDGLinea__c CreaNGDLineaTitolare(Contact c, Opportunity o, Boolean isTitolare, String tipo) {
    NDGLinea__c ndg = new NDGLinea__c(Contact__c = c.id, Opportunita__c = o.id, Tipo__c = tipo, EsecutoreAV__c = isTitolare);
    insert ndg;
    return ndg;
  }

  public static NDGLinea__c CreaNDGLineaDebitore(Contact c, Opportunity o) {
    NDGLinea__c ndg = new NDGLinea__c(Contact__c = c.id, Opportunita__c = o.id, Tipo__c = 'Debitore', RecordTypeId = U.getRecordTypes('NDGLinea__c').get('Debitore').Id);
    insert ndg;
    return ndg;
  }

  public static Opportunity CreaOpportunity(Account a) {
    // Opportunity o = new Opportunity(AccountID = a.id, StageName = 'In lavorazione' , CloseDate = Date.today());
    Opportunity o = new Opportunity(AccountID = a.id, StageName = 'In Istruttoria' , Tipologia_Opportunit__c = 'CONC', CloseDate = Date.today());
    insert o;
    return o;
  }

  public static Opportunity CreaOpportunityNSA(Account a) {
    // Opportunity o = new Opportunity(AccountID = a.id, StageName = 'In lavorazione' , CloseDate = Date.today());
    Opportunity o = new Opportunity(AccountID = a.id, StageName = 'In Istruttoria' , Tipologia_Opportunit__c = 'CONC', CloseDate = Date.today());
	o.WGC_Prodotti_Selezionati__c = 'Mutuo';
	o.Originator__c = 'Partner';
	o.Originator_di_dettaglio__c = 'Broker - NSA';
    insert o;
    return o;
  }

  public static Opportunity CreaOpportunity(Account a, String nome) {
    // Opportunity o = new Opportunity(AccountID = a.id, Name = nome, StageName = 'In lavorazione' , CloseDate = Date.today());
    Opportunity o = new Opportunity(AccountID = a.id, Name = nome, StageName = 'In Istruttoria', Tipologia_Opportunit__c = 'CONC', CloseDate = Date.today());
    insert o;
    return o;
  }

  public static TranscodificheNazioni__c CreaTranscodificaNazione(String name, Integer codiceIso, String nome) {
    TranscodificheNazioni__c tn = new TranscodificheNazioni__c(Name = name, CodiceIso__c = codiceIso, Nome__c = nome);
    insert tn;
    return tn;
  }

  public static Impostazioni__c CreaImpostazioni(Campaign campagna) {
    Impostazioni__c imp = new Impostazioni__c(IdCampagnaWeb__c = campagna.id);
    insert imp;
    return imp;
  }

  public static Impostazioni__c CreaImpostazioni() {
    Impostazioni__c imp = new Impostazioni__c(ParamPropagWiz__c = '010;050');
    insert imp;
    return imp;
  }

  public static EndpointServizi__c creaEndpointServizi () {
    EndpointServizi__c endPoint = new EndpointServizi__c(
      Name = 'settings',
      LAGKey__c = 'key',
      LAGKeyHeroku__c = 'key',
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
      WGC_Url_Dati_PEF_FF__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/lineacredito/clonedatipef',
      WGC_Url_PEF41_FF__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/lineacredito/clonerinnovopef',
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
      UrlCertificazioneParser__c = 'https://',
      WGC_CensimentoTratt__c = 'WGC_CensimentoTratt__c',
      WGC_ConfermaTratt__c = 'WGC_ConfermaTratt__c',
      WGC_CalcoloInteressi__c = 'WGC_CalcoloInteressi__c',
      WGC_CalcoloDIP__c = 'WGC_CalcoloDIP__c',
      WGC_CalcoloCompensi__c = 'WGC_CalcoloCompensi__c',
      WGC_CalcoloIRR__c = 'WGC_CalcoloIRR__c'

    );
    insert endPoint;

    GestioneLog__c gLog = new GestioneLog__c(Name = 'default');
    insert gLog;
    return endPoint;
  }

  public static Prodotto__c creaProdotto(String name, String codice, String servizio) {
    Prodotto__c prodotto = new Prodotto__c(Name = name, Codice__c = codice, Servizio__c = servizio);
    insert prodotto;
    return prodotto;
  }

  public static Prodotto__c creaProdotto(
    String name,
    String codice,
    String codiceUnivoco,
    String categoria,
    String servizio
  ) {
    Prodotto__c prodotto = new Prodotto__c(
      Name = name,
      Codice__c = codice,
      CodiceUnivoco__c = codiceUnivoco,
      CategoriaProdotto__c = categoria,
      Servizio__c = servizio
    );
    insert prodotto;
    return prodotto;
  }

  public static Garanzia__c creaGaranzia(Opportunity opportunity, String idEsterno) {
    Garanzia__c garanzia = new Garanzia__c(Opportunita__c = opportunity.Id, IdEsterno__c = idEsterno);
    insert garanzia;
    return garanzia;
  }

  public static Linea__c[] creaLinee(Opportunity o, Integer numeroDiLinee) {
    Linea__c[] linee = new Linea__c[] {};
    for (Integer i = 1; i <= numeroDiLinee; i++) {
      linee.add(new Linea__c(Opportunity__c = o.Id));
    }
    insert linee;
    return linee;
  }

  public static Prodotto__c creaProdottoPPIIM() {
    Prodotto__c prodotto = new Prodotto__c(
      Name = 'IFIS Impresa',
      Applicazione__c = '01',
      CodiceProdotto__c = 'PPIIM',
      TipoProdotto__c = 'B',
      Codice__c = '151',
      Icona__c = 'custom-custom86',
      Maturity__c = false,
      Notifica__c = false,
      Categoria__c = 'B',
      IsFactoring__c = false,
      AssociazioneDebitori__c = false
    );
    insert prodotto;
    return prodotto;
  }

  public static Prodotto__c creaProdottoPCDFO() {
    Prodotto__c prodotto = new Prodotto__c(
      Name = 'Factoring Ordinario',
      Applicazione__c = '31',
      CodiceProdotto__c = 'PCDFO',
      TipoProdotto__c = 'B',
      Codice__c = '531',
      Icona__c = 'custom-custom32',
      Maturity__c = false,
      Notifica__c = true,
      Servizio__c = 'Factoring',
      Categoria__c = 'C',
      IsFactoring__c = true,
      AssociazioneDebitori__c = true
    );
    insert prodotto;
    return prodotto;
  }

  public static Prodotto__c creaProdottoPCMCC() {
    Prodotto__c prodotto = new Prodotto__c(
      Name = 'Mutuo Garantito MCC',
      Applicazione__c = '21C',
      CodiceProdotto__c = 'PCMCC',
      TipoProdotto__c = 'C',
      Codice__c = '963',
      Icona__c = 'custom-custom17',
      Maturity__c = false,
      Notifica__c = false,
      Categoria__c = 'C',
      IsFactoring__c = false,
      AssociazioneDebitori__c = false
    );
    insert prodotto;
    return prodotto;
  }

  public static Prodotto__c creaProdottoPCFFD() {
    Prodotto__c prodotto = new Prodotto__c(
      Name = 'DFO - IVA',
      Applicazione__c = '31',
      CodiceProdotto__c = 'PCFFD',
      TipoProdotto__c = 'B',
      Codice__c = '534',
      Icona__c = 'custom-custom32',
      Maturity__c = false,
      Notifica__c = true,
      Categoria__c = 'C',
      IsFactoring__c = false,
      AssociazioneDebitori__c = true
    );
    insert prodotto;
    return prodotto;
  }

  public static Prodotto__c creaProdottoPCFII() {
    Prodotto__c prodotto = new Prodotto__c(
      Name = 'Fido',
      Applicazione__c = '09F',
      CodiceProdotto__c = 'PCFII',
      TipoProdotto__c = 'B',
      Codice__c = '',
      Icona__c = 'custom-custom86',
      Maturity__c = false,
      Notifica__c = false,
      Categoria__c = 'C',
      IsFactoring__c = false,
      AssociazioneDebitori__c = false
    );
    insert prodotto;
    return prodotto;
  }

  public static Prodotto__c creaProdottoPCVSI() {
    Prodotto__c prodotto = new Prodotto__c(
      Name = 'Mutuo Cofinanziato Veneto Sviluppo - Quota Ifis',
      Applicazione__c = '06C',
      CodiceProdotto__c = 'PCVSI',
      TipoProdotto__c = 'B',
      Codice__c = '960',
      Icona__c = 'custom-custom17',
      Maturity__c = false,
      Notifica__c = false,
      Categoria__c = 'C',
      IsFactoring__c = false,
      AssociazioneDebitori__c = false
    );
    insert prodotto;
    return prodotto;
  }

  public static PConfigurato__c creaPConfigurato(String codice, String valore, String valoreDefault, Id lineaId, Id attoreId, String tipo) {
    PConfigurato__c pConfigurato = new PConfigurato__c(
      Codice__c = codice,
      Valore__c = valore,
      Default__c = valoreDefault,
      Linea__c = lineaId,
      Attore__c = attoreId,
      Tipo__c = tipo
    );
    insert pConfigurato;
    return pConfigurato;
  }

  public static Parametro__c creaParametro(Boolean derogaFidoDiCoppia, String numeroParametro, String tipologia, String tipo) {
    Parametro__c parametro = new Parametro__c(
      DerogaFidoDiCoppia__c = derogaFidoDiCoppia,
      NumeroParametro__c = numeroParametro,
      Tipologia__c = tipologia,
      Tipo__c = tipo
    );
    insert parametro;
    return parametro;
  }

  public static Account creaDebitore() {
    Account a = new Account(Name = 'Debitore Test');
    a.SegmentoRischio__c = '1';
    insert a;
    return a;
  }

  public static Fattura__c creaFattura(Cessione__c c) {
    Account d = creaDebitore();

    //TODO: sistemare per nuovo data model
    Fattura__c f = new Fattura__c(
      //Debitore__c = d.Id,
      //Cessione__c = c.Id,
      //DataPagamentoCertificata__c = Date.today() + 90
      ImportoFatturaCertificato__c = 5000
    );
    insert f;
    return f;
  }

  public static Cessione__c creaCessioneCompleta(Account a) {
    Cessione__c cessione = new Cessione__c(Account__c = a.Id);
    insert cessione;

    Certificazione__c cert = new Certificazione__c(Cessione__c = cessione.Id, TerminiPagamento__c = 30);
    insert cert;

    Fattura__c f = new Fattura__c(CertificazioneParent__c = cert.Id, DataFattura__c = Date.today());
    insert f;

    return cessione;
  }
}