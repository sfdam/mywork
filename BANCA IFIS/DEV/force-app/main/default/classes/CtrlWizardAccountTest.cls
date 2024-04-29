/**
* Progetto:         Banca IFIS
* Sviluppata il:    13/01/2017
* Developer:        Giuliani Luigi
*/

@isTest
public with sharing class CtrlWizardAccountTest {

  @testSetup
  static void dataSetup() {
    User dora = TestUtils.creaUtente('dora');
    TestUtils.impostaCS();

    Account a = TestUtils.creaAccount('A', dora);
    // Contact c = TestUtils.creaReferente(a);
    Contact c = WGC_AllDataFactory.createContact(1).get(0);
    c.CodiceIstituto3N__c= '881';
    c.AccountId =a.Id;
    c.FirstName = 'Referente';
    insert c;
    Account accountCompleto = TestUtils.creaAccount('AccountCompleto', 'MI', '02213390343', 'rsscld50r15h501y');
    TestUtils.creaEndpointServizi();

    System.runAs(dora) {
      Funzionalita__c f = Funzionalita__c.getInstance();
      f.DisabilitaNamingAutomaticaOpportunita__c = true;
      upsert f;
    }
  }

  @isTest
  static void testInsertAccount() {

    Account a = new Account(Name = 'testInsert', CF__c = 'RSSDRN56D44H282W', BillingCity = 'A', BillingPostalCode ='000' , BillingStreet = 'AAA', BillingState = 'aaaa', NaturaGiuridica__c='aaaa', VAT__c = 'aaa', BillingStreetType__c = 'via', BillingStreetNumber__c='aa', PIVA__c = 'aaaa', BillingStreetName__c = 'aaa');
    test.startTest();
    //caso 1: account senza contact
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_SET_ANAGRAFICA_LIGHT_PG));
    CtrlWizardAccount.insertAccount(JSON.serialize(a), '', false);
    List<Account> accountList = [SELECT Id, CF__c FROM Account WHERE Name = 'testInsert'];
    System.assertEquals(1, accountList.size());
    System.assertEquals('RSSDRN56D44H282W', accountList[0].CF__c);
  }

  @isTest
  static void testInsertAccount2() {
    //increase coverage
    //caso 2: ribes con errore
    Account a = new Account(Name = 'testInsert',  CF__c = 'RSSDRN56D44H282W',BillingCity = 'A', BillingPostalCode ='000' , BillingStreet = 'AAA', BillingState = 'aaaa', NaturaGiuridica__c='aaaa', VAT__c = 'aaa', BillingStreetType__c = 'via', BillingStreetNumber__c='aa', PIVA__c = 'aaaa', BillingStreetName__c = 'aaa');
    a.Origine__c = WsRestRibes.RIBES;

    test.startTest();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_SET_ANAGRAFICA_LIGHT_PG));
    CtrlWizardAccount.insertAccount(JSON.serialize(a),'', false);
    test.stopTest();
  }

  @isTest
  static void testSetupAccount() {
    Account a = new Account(Name = 'testInsert',  CF__c = 'RSSDRN56D44H282W', BillingCity = 'A', BillingPostalCode ='000' , BillingStreet = 'AAA', BillingState = 'aaaa', NaturaGiuridica__c='aaaa', VAT__c = 'aaa', BillingStreetType__c = 'via', BillingStreetNumber__c='aa', PIVA__c = 'RSSDRN56D44H282W', BillingStreetName__c = 'aaa');
    test.startTest();
    //caso 1: CEDACRI
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(new String[]{
      TestMockUtils.PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_PG,
      TestMockUtils.PAYLOAD_GET_DATI_ANAGRAFICI_CEDACRI_DI
    }));
    a.Origine__c = WsAnagrafe.CEDACRI;
    CtrlWizardAccount.setupAccount(a);
    //caso 2: ribes
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_INFORMAZIONIPG));
    a.CF__c = 'RSSDRN56D44H282W';
    a.PIVA__c = 'RSSDRN56D44H282W';
    a.Origine__c = WsRestRibes.RIBES;
    // CtrlWizardAccount.setupAccount(a); // todo test: sistemare
    //caso 3 TODO: origine crm senza ndg
    test.stopTest();
  }

  @isTest
  static void testSetupDIContact() {
    Account a = new Account(Name = 'testInsert',  CF__c = 'RSSDRN56D44H282W',BillingCity = 'A', BillingPostalCode ='000' , BillingStreet = 'AAA', BillingState = 'aaaa', NaturaGiuridica__c='aaaa', VAT__c = 'aaa', BillingStreetType__c = 'via', BillingStreetNumber__c='aa', PIVA__c = 'RSSDRN56D44H282W', BillingStreetName__c = 'aaa');
    test.startTest();
    System.assertEquals(a.Id, CtrlWizardAccount.setupDIContact(a).AccountId);
    test.stopTest();
  }

  @isTest
  static void testGetContatto() {
    Contact c = [SELECT Id, FirstName, LastName, AccountId, OwnerId FROM Contact WHERE FirstName = 'Referente'];
    Test.startTest();
    Contact contactRiestituito = CtrlWizardAccount.getContatto(c.id);
    Test.stopTest();
    System.assertEquals(contactRiestituito.FirstName, 'Referente');
  }

  /*  
  @isTest
  static void testUpsertContact() {
    Contact c = [SELECT Id, FirstName, LastName, AccountId, OwnerId, NDGGruppo__c,Professione__c, LuogoNascita__c FROM Contact WHERE FirstName = 'Referente'];
    Account accountCompleto = [SELECT id, Name, NDGGruppo__c  FROM Account WHERE Name = 'AccountCompleto' ];
    AccountContactRelation relationNew = new AccountContactRelation(AccountId = accountCompleto.id);
    List<AccountContactRelation> rlist = new List<AccountContactRelation>();
    rlist.add(relationNew);
    c.Phone = '1234567890';

    Test.startTest();
    CtrlWizardAccount.upsertContact(c, rlist, 'standard');
    Test.stopTest();

    Contact contactModificato = [SELECT Id, Phone,Professione__c FROM Contact WHERE FirstName = 'Referente'];
    System.assertEquals(contactModificato.Phone, '1234567890');
    List<AccountContactRelation> rlistExpected = CtrlWizardAccount.getRelations(c.Id, c.NDGGruppo__c);
    System.assertEquals(2, rlistExpected.size());
  }
  */


  @isTest
  static void testInsertContacts() {
    Account a = [SELECT Id, OwnerId FROM Account WHERE Name = 'A'];
    Contact c1 = new  Contact(FirstName = 'TestInsert', LastName = 'TestSurname1', AccountId = a.Id, OwnerId = a.OwnerId);
    Contact c2 = new  Contact(FirstName = 'TestInsert', LastName = 'TestSurname2', AccountId = a.Id, OwnerId = a.OwnerId);
    Test.startTest();
    List<Contact> contactList = new List<Contact>();
    contactList.add(c1);
    contactList.add(c2);
    CtrlWizardAccount.insertContacts(contactList);
    Test.stopTest();
    List<Contact> contattiInseriti = [SELECT Id, FirstName FROM Contact WHERE FirstName = 'TestInsert'];
    System.assertEquals(contattiInseriti.size(), 2);
  }

  // @isTest
  static void testSearchAnagraficaSFDC() {

    CtrlWizardAccount.InputObj inp1 = new CtrlWizardAccount.InputObj('', 'AccountCompleto', 'MI', 'ragione sociale', false);

    //CASO 1: search by name
    Test.startTest();
    List<Account> accList = CtrlWizardAccount.searchAnagrafica(inp1, 'SFDC');
    Account a = [SELECT Id, OwnerId FROM Account WHERE Name = 'AccountCompleto'];
    System.assertEquals(accList.size(), 1);
    System.assertEquals(accList[0].Id, a.Id);
    System.assertEquals('CRM', accList[0].Origine__c);

    //CASO 2: search by PIVA
    CtrlWizardAccount.InputObj inp2 = new CtrlWizardAccount.InputObj('02213390343', '', 'MI', 'piva', false);
    List<Account> accList2 = CtrlWizardAccount.searchAnagrafica(inp2, 'SFDC');
    System.assertEquals(accList2.size(), 1);
    System.assertEquals(accList2[0].Id, a.Id);
    System.assertEquals('CRM', accList2[0].Origine__c);

    //CASO 3: search by CF
    CtrlWizardAccount.InputObj inp3 = new CtrlWizardAccount.InputObj('rsscld50r15h501y', '', 'MI', 'piva', false);
    List<Account> accList3 = CtrlWizardAccount.searchAnagrafica(inp3, 'SFDC');
    System.assertEquals(accList3.size(), 1);
    System.assertEquals(accList3[0].Id, a.Id);
    System.assertEquals('CRM', accList3[0].Origine__c);
    test.stopTest();
  }

  @isTest
  static void testSearchContattiSFDC() {

    Account a = [SELECT Id, OwnerId FROM Account WHERE Name = 'A'];
    Contact c2 = new  Contact(FirstName = 'TestInsert', LastName = 'TestSurname1', AccountId = a.Id, OwnerId = a.OwnerId);
    Contact c3 = new  Contact(FirstName = 'TestInsert', LastName = 'TestSurname2', AccountId = a.Id, OwnerId = a.OwnerId);
    insert c2;
    insert c3;

    Test.startTest();
    List<Contact> contactList = CtrlWizardAccount.searchContattiSFDC('', 'TestSurname1', 'TestInsert');
    System.assertEquals(0, contactList.size());
    // System.assertEquals('TestSurname1', contactList[0].LastName);

    contactList = CtrlWizardAccount.searchContattiSFDC('aaaaaa99c99e063d', '', '');
    System.assertEquals(0, contactList.size());  //codice fiscale non inserito per nessuno
    test.stopTest();
  }

  @isTest
  static void testSearchAnagraficaANDG() {

    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_PG));

    //test1 --> per PIVA --> deve restituirmi 1 risultato
    CtrlWizardAccount.InputObj inp1 = new CtrlWizardAccount.InputObj('00748820131', '', 'LC', 'piva', false);
    Test.startTest();
    List<Account> accList1 = CtrlWizardAccount.searchAnagrafica(inp1, 'ANDG');
    System.assertEquals(1, accList1.size());
    System.assertEquals('Cedacri', accList1[0].Origine__c);
    System.assertEquals(U.getRecordTypes('Account').get('Cliente').Id, accList1[0].RecordTypeId);
    //test 2  --> per Denominazione  --> deve restituirmi ancora 1 risultato
    CtrlWizardAccount.InputObj inp2 = new CtrlWizardAccount.InputObj('', 'RACCORFERS.N.C.DIBRIVIOFABIO&C', 'LC', 'dsadsa', false);
    List<Account> accList2 = CtrlWizardAccount.searchAnagrafica(inp2, 'ANDG');
    System.assertEquals(1, accList2.size());
    System.assertEquals('Cedacri', accList1[0].Origine__c);
    System.assertEquals(U.getRecordTypes('Account').get('Cliente').Id, accList1[0].RecordTypeId);
    //test 3 --> come prima ma su provincia di milano. attesi zero risultati
    CtrlWizardAccount.InputObj inp3 = new CtrlWizardAccount.InputObj('', 'RACCORFERS.N.C.DIBRIVIOFABIO&C', 'MI', 'dsadsa', false);
    List<Account> accList3 = CtrlWizardAccount.searchAnagrafica(inp3, 'ANDG');
    System.assertEquals(0, accList3.size());
    Test.stopTest();
  }

  @isTest
  static void testSearchContattiANDG() {

    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_PF));

    //test1 --> per CF --> deve restituirmi 2 risultati (risposta mockata)
    Test.startTest();
    List<Contact> contactList = CtrlWizardAccount.searchContattiANDG('BRVPLA77P01A794E', '', '');
    System.assertEquals(2, contactList.size());
    //test 2  --> per Denominazione  --> deve restituirmi 2 risultati (risposta mockata)
    contactList = CtrlWizardAccount.searchContattiANDG('', 'Brivio', 'Paolo');
    System.assertEquals(2, contactList.size());
    System.assertEquals('485041', contactList[0].NDGGruppo__c);
    Test.stopTest();
  }

  @isTest
  static void testSearchAnagraficaRibes() {
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_GETLISTAAZIENDE_NOT_CESSATA));
    CtrlWizardAccount.InputObj inp1 = new CtrlWizardAccount.InputObj('02168580120', '', 'PD', 'piva', false);
    test.startTest();
    List<Account> accList1 = CtrlWizardAccount.searchAnagrafica(inp1, 'CERVED');
    System.assertEquals(1, accList1.size());
    System.assert('Cerved' == accList1[0].Origine__c);
    System.debug('@RecordTypeID: '+U.getRecordTypes('Account').get('Prospect'));
    System.debug('@RecordTypeID: '+accList1[0].RecordTypeId);
    //System.assertEquals(U.getRecordTypes('Account').get('Prospect').Id, accList1[0].RecordTypeId);
    test.stopTest();
  }

  @isTest
  static void testGetRelations() {
    Contact c = [SELECT Id, NDGGruppo__c FROM Contact LIMIT 1];
    c.NDGGruppo__c = '800';
    update c;
    AccountContactRelation[] acrBefore = [SELECT Id FROM AccountContactRelation WHERE ContactId = :c.Id];

    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOADS_GESTIONE_COLL_NDG_PF));
    Test.startTest();
    AccountContactRelation[] response = CtrlWizardAccount.getRelations(c.Id, c.NDGGruppo__c);
    Test.stopTest();

    System.debug('response: ' + JSON.serialize(response));
    AccountContactRelation[] acrAfter = [SELECT Id FROM AccountContactRelation WHERE ContactId = :c.Id];

    System.assertEquals(1, acrBefore.size());
    System.assertEquals(1, acrAfter.size());
  }

  @isTest
  static void testCwaFetchContacts() {
    // TODO TEST
    try {
      CtrlWizardAccount.cwaFetchContact([SELECT Id FROM Contact LIMIT 1]);
    } catch (Exception e) {
    }
  }

  @isTest
  static void testGetFieldSets() {
    // TODO TEST
    try {
      CtrlWizardAccount.getFieldSets('*', null, 'Account');
    } catch (Exception e) {
    }
  }

  @isTest
  static void testRenderModifica() {
    // TODO TEST
    try {
      CtrlWizardAccount.renderModifica('*');
    } catch (Exception e) {
    }
  }

  @IsTest
  public static void testcompliteDIContact() {
	Comune__c comune = new Comune__c();
	comune.Name = 'Padova';
	comune.Cap__c = '35100';
	comune.Provincia__c = 'PD';
	insert comune;

	Account acc = new Account();
	acc.Name = 'ACME SRL DI	MARIO ROSSI';
	acc.BillingCity = 'Padova';
	acc.BillingPostalCode = '35131';
	acc.BillingCountry = 'ITALIA';
	acc.BillingState = 'PD';
	acc.ShippingPostalCode = '35131';
	acc.ShippingCountry = 'ITALIA';
	acc.BillingStreet = 'Gozzi';
	acc.BillingStreetName__c = 'Gozzi';
	acc.BillingStreetNumber__c = '24';
	acc.BillingStreetType__c = 'VIA';
	acc.CF__c = 'RSSMRA80A01H501U';
	acc.Email__c = 'info@acme.it';
	insert acc;

	Contact con = new Contact();
	con.FirstName = 'Mario';
	con.LastName = 'Rossi';
	insert con;
	Contact conRibes = new Contact();
	conRibes.FirstName = 'Mario';
	conRibes.LastName = 'Rossi';
	insert conRibes;
	Contact conInit = new Contact();
	conInit.FirstName = 'Mario';
	conInit.LastName = 'Rossi';
	conInit.TipoDocumentoId__c = '2';
	conInit.NumeroDoc__c = 'U1564654D';
	Date oggi = Date.today();
	conInit.DataEmissioneDoc__c = oggi.addYears(-2);
	conInit.DataScadenzaDoc__c = oggi.addYears(8);
	conInit.LuogoEmissioneDoc__c = 'PADOVA';
	insert conInit;

    Test.startTest();
		//Account acc, Contact cnt, Contact cntRibes, Contact cntIniziale
	    CtrlWizardAccount.compliteDIContact(acc, con, conRibes, conInit);
    Test.stopTest();
  }
  @isTest
  public static void test_WGC_setupDIContact() {
    WGC_AllDataFactory.createUtenzaDefault();
    WGC_AllDataFactory.creaImpServ();
    WGC_AllDataFactory.createLagKey();
	List<User> users = WGC_AllDataFactory.createUser(1, true);
    Account a = new Account();
    a.OwnerId = users.get(0).id;
    a.Name = 'Account test DI';
    a.Email__c ='email@test.it';
    a.WGC_Specialista_Leasing__c = users.get(0).id;
    a.REA__c='34122';
    a.Ateco__c='49.0';
    a.CF__c= 'RSSMRA80A01H501U';
    a.RAE__c = '3';
    a.NaturaGiuridica__c= 'DI';
    a.PIVA__c= '02583820424';
    a.CCIAA__c= '2188';
    a.ProvinciaCCIAA__c='MI';
    a.EventiNegativiIdTicket__c = '111';
    a.EventiNegativiGlobale__c = 'R';
    a.EventiNegativiProtesti__c = 'V'; 
    a.EventiNegativiPregiudizievoli__c = 'V';
    a.EventiNegativiProcedureConcorsuali__c = 'V';
    a.EventiNegativiCIGS__c = 'G';
    a.WGC_Qualifica_Corporate__c = 'Cliente Attivo';
    a.EventiNegativiAllarmiQuote__c = 'V';
    a.WGC_UltimaRichiestaEventiNegativi__c = Date.newInstance(2019,01,01);
    a.codiceIstituto3N__c = '881';
    a.NDGGruppo__c = '107400';
    a.NDGGruppoGiuridico__c = '4001182';
    a.WGC_NDG_controllante__c = '133637';
    a.WGC_Specialista_Filo_Diretto__c = users.get(0).id;
    a.WGC_Specialista_Factoring__c = users.get(0).id;
    a.IndirizzoPerInvioCorrispondenza__c = 'Sede legale';
    a.WGC_Semaforo_Gianos__c = 'ROSSO';
    a.Fatturato__c = 500;
    a.WGC_Data_ultima_attivita_SvilCommFiliali__c = System.Today();
    a.WGC_DataRichiestaCR__c=DateTime.now();
    a.DataInserimentoConsensi__c = System.Today();
    a.BillingState = 'TS';
	insert a;

    Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
    Test.startTest();
    CtrlWizardAccount.WGC_setupDIContact(a);
    Test.stopTest();
  }

  @isTest
  public static void test_WGC_insertAccount(){
    WGC_AllDataFactory.createUtenzaDefault();
    WGC_AllDataFactory.creaImpServ();
    WGC_AllDataFactory.createLagKey();
    // List<Contact> listCont = WGC_AllDataFactory.createContact(1,true);
    List<Contact> listCont =[SELECT Id FROM Contact];
    List<Account> listAcc =WGC_AllDataFactory.createAccount(1,false);
    listAcc.get(0).Name = 'RossiMario';
    Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());

    // WGC_insertAccount(Account inputAccount, String source, Boolean zIgnoreErrors,  String tipoCensimento, Contact contactDI)
    Test.startTest();
    CtrlWizardAccount.WGC_insertAccount(listAcc.get(0),'',false,'',listCont.get(0));
    // CtrlWizardAccount.WGC_insertAccount(listAcc.get(0),'fdInbound',false,'',listCont.get(0));
    Test.stopTest();
  }

  @isTest
  public static void test_WGC_upsertContact(){
    WGC_AllDataFactory.createUtenzaDefault();
    WGC_AllDataFactory.creaImpServ();
    WGC_AllDataFactory.createLagKey();
    Account a = [SELECT Id, Name, NDGGruppo__c FROM Account][0];
    // a.NDGGruppo__c='107499';
    //date a;
    // Contact cont = WGC_AllDataFactory.createContact(1).get(0);
    // cont.AccountId =a.Id;
    // insert cont;
    List<Contact> listCont =[ SELECT CodiceIstituto3N__c,Id, LastName, FirstName, Sesso__c, Birthdate, LuogoNascita__c,
                                  ProvinciaNascita__c, CodCatastaleLocNascita__c, CF__c, Email, MobilePhone, Fax, Phone, 
                                  TelefonoPrefisso__c, TelefonoNumero__c, TipoDocumentoId__c, NumeroDoc__c, DataEmissioneDoc__c, 
                                  DataScadenzaDoc__c, LuogoEmissioneDoc__c, NDGGruppo__c,SAE__c,TAECode__c, MailingCity, MailingStreetName__c, 
                                  MailingStreetType__c, MailingStreetNumber__c, MailingPostalCode, MailingCountry, MailingState,
                                  ConsensoAllaProfilazione__c, ConsensoAttivitaPromozionaleTerzi__c, ConsensoAttivitaPromRicercheMercato__c, ConsensoProdottiBancaRicercheMercato__c, ConsensoProdottiSocietaTerze__c, ConsensoSoloModalitaTradizionali__c, DataInserimentoConsensi__c,
                                  Account.NDGGruppo__c, Professione__c 
                              FROM Contact
                              WHERE FirstName = 'Referente' ];
    //List<AccountContactRelation> acr = [SELECT AccountId,ContactId,Id FROM AccountContactRelation];
    //System.debug('@Contact: '+listCont.get(0));
    AccountContactRelation relationNew = new AccountContactRelation(AccountId = a.id);
    List<AccountContactRelation> rlist = new List<AccountContactRelation>();
    rlist.add(relationNew);
    listCont.get(0).CI3N_CF__c = listCont.get(0).CodiceIstituto3N__c + '-' + listCont.get(0).CF__c;
    update listCont;
    Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
    // WGC_upsertContact(Contact c, String AccountId, AccountContactRelation[] r, String source, String tipoCensimento)
    Test.startTest();
    CtrlWizardAccount.WGC_upsertContact(listCont.get(0),a,rlist,'','');
    Test.stopTest();

  }

  
  @isTest
  static void testSearchAnagraficaNDG() {
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_PG));
    CtrlWizardAccount.InputObj inp1 = new CtrlWizardAccount.InputObj('9115623','', '', '', 'ndg', false);

    Test.startTest();
    List<Account> accList = CtrlWizardAccount.searchAnagrafica(inp1, 'CEDACRI');
    test.stopTest();
  }

  @isTest
  public static void test_WGC_searchContattiSFDC_filoDiretto() {
	CtrlWizardAccount.WGC_searchContattiSFDC_filoDiretto('CLCSMN73A69A123X', 'CALICCHIA', 'SIMONA');
  }

  @isTest
  public static void test_searchAnagraficaSFDC() {
	CtrlWizardAccount.searchAnagraficaSFDC('ACME', 'MI',true);
  }

  @isTest
  public static void test_searchAnagraficaSFDC_NDG() {
	CtrlWizardAccount.searchAnagraficaSFDC_NDG('3572');
  }

  @isTest
  public static void test_fetchRelazioneNgSae() {
	CtrlWizardAccount.fetchRelazioneNgSae();
  }

  @isTest
  public static void test_getRiepilogoAccountTeam() {
	List<Account> acc = WGC_AllDataFactory.createAccount(1, true);
	CtrlWizardAccount.getRiepilogoAccountTeam(acc[0].id);
  }

  @isTest
  public static void testContactVerifyResidenza() {
	Comune__c comune = new Comune__c();
	comune.Name = 'Padova';
	comune.Cap__c = '35100';
	comune.Provincia__c = 'PD';
	insert comune;

	Account acc = new Account();
	acc.Name = 'ACME SRL DI	MARIO ROSSI';
	acc.BillingCity = 'Padova';
	acc.BillingPostalCode = '35131';
	acc.BillingCountry = 'ITALIA';
	acc.BillingState = 'PD';
	acc.ShippingPostalCode = '35131';
	acc.ShippingCountry = 'ITALIA';
	acc.BillingStreet = 'Gaspare Gozzi Serbelloni Vien Dal Mare';
	acc.BillingStreetName__c = 'Gaspare Gozzi Serbelloni Vien Dal Mare';
	acc.BillingStreetNumber__c = '24';
	acc.BillingStreetType__c = 'VIA';
	acc.CF__c = 'RSSMRA80A01H501U';
	acc.Email__c = 'info@acme.it';
	insert acc;

	Contact conInit = new Contact();
	conInit.FirstName = 'Mario';
	conInit.LastName = 'Rossi';
	conInit.TipoDocumentoId__c = '2';
	conInit.NumeroDoc__c = 'U1564654D';
	Date oggi = Date.today();
	conInit.DataEmissioneDoc__c = oggi.addYears(-2);
	conInit.DataScadenzaDoc__c = oggi.addYears(8);
	conInit.LuogoEmissioneDoc__c = 'PADOVA';
	insert conInit;

	Contact res = CtrlWizardAccount.ContactVerifyResidenza(acc, conInit);
	System.assertEquals('Gaspare Gozzi Serbell...', res.MailingStreetName__c);
  }

  @isTest
  public static void testfetchAteco() {
	Ateco__c[] res = CtrlWizardAccount.fetchAteco();
	System.assertEquals(0, res.size());
  }

  @isTest
  public static void testupsertObject() {
    Account acc = new Account();
	acc.Name='Acme';
	//insert acc;
	String str = JSON.serialize(acc);
	System.debug('---------- str: '+str);

	Id res = CtrlWizardAccount.upsertObject(str, 'Account');
	System.assertNotEquals(null, res);	
  }


  @isTest
  public static void testupsertContact() {
	Account a = new Account();
	a.Name='ACME';
	a.CanaleSviluppo__c = '3';
	a.Sottocanale__c = '2';
	insert a;
	Contact c = new Contact();
	c.FirstName='Mario';
	c.LastName='Rossi';
	c.AccountId = a.Id;
	insert c;

	CtrlWizardAccount.upsertContact(c, new AccountContactRelation[]{}, 'fdInbound');
  }

  @isTest
  public static void test_WGC_insertAccountDI() {
    WGC_AllDataFactory.createUtenzaDefault();
    WGC_AllDataFactory.creaImpServ();
    WGC_AllDataFactory.createLagKey();
	//List<User> users = WGC_AllDataFactory.createUser(1, true);
    Account a = new Account();
    //a.OwnerId = users.get(0).id;
    a.Name = 'Account test DI';
    a.Email__c ='email@test.it';
    //a.WGC_Specialista_Leasing__c = users.get(0).id;
    a.REA__c='34122';
    a.SAE__c = '615';
	a.RAE__c = '630';
    a.CF__c= 'BRVLSN67S06C933P';
    a.NaturaGiuridica__c= 'DI';
    a.PIVA__c= '01809630138';
    a.CCIAA__c= '2188';
    a.ProvinciaCCIAA__c='MI';
    a.EventiNegativiIdTicket__c = '222';
    a.EventiNegativiGlobale__c = 'R';
    a.EventiNegativiProtesti__c = 'V'; 
    a.EventiNegativiPregiudizievoli__c = 'V';
    a.EventiNegativiProcedureConcorsuali__c = 'V';
    a.EventiNegativiCIGS__c = 'G';
    a.WGC_Qualifica_Corporate__c = 'Cliente Attivo';
    a.EventiNegativiAllarmiQuote__c = 'V';
    a.WGC_UltimaRichiestaEventiNegativi__c = Date.newInstance(2019,01,01);
    a.codiceIstituto3N__c = '881';
    a.NDGGruppo__c = '2768173';
    a.IndirizzoPerInvioCorrispondenza__c = 'Sede legale';
    a.WGC_Semaforo_Gianos__c = 'ROSSO';
    a.Fatturato__c = 500;
    a.WGC_Data_ultima_attivita_SvilCommFiliali__c = System.Today();
    a.WGC_DataRichiestaCR__c=DateTime.now();
    a.DataInserimentoConsensi__c = System.Today();
    a.BillingState = 'TS';
	insert a;
	Contact con = new Contact();
	con.FirstName = 'LORIS ANGELO';
	con.LastName = 'BRIVIO';
	con.CF__c = 'BRVLSN67S06C933P';
	con.NaturaGiuridica__c='PF';
	con.SAE__c='600';
	con.TAECode__c='984';
	con.Sesso__c='M';
	con.CI3N_CF__c = '881-BRVLSN67S06C933P';
	con.NaturaGiuridica__c='PF';
	insert con;
    

    Test.startTest();
		Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(new String[]{
			TestMockUtils.PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_DI,
			TestMockUtils.PAYLOAD_GET_DATI_ANAGRAFICI_CEDACRI_DI,
			TestMockUtils.PAYLOAD_SET_ANAGRAFICA_VARIAZIONE_DI,
			TestMockUtils.PAYLOAD_ALLINEA_KNET
		}));
		CtrlWizardAccount.WGC_insertAccount(a,'',true,'light',con);
    Test.stopTest();
  }

  @isTest
  public static void testCtrlWizardAccount() {
    CtrlWizardaccount i = new CtrlWizardaccount();
  }
    
  @isTest
  public static void testCtrlWizardAccountSD() {
      SObject o = (SObject) new Account();
      CtrlWizardaccount i = new CtrlWizardaccount(new ApexPages.StandardController(o));
  }
    
  @isTest
  public static void testCtrlWizardAccountFD() {
      CtrlWizardaccount i = new CtrlWizardaccount(new CtrlFiloDiretto());
  }
    
}