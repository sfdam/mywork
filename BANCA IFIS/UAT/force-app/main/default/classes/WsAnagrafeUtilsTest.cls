@isTest
private class WsAnagrafeUtilsTest {

  private static String NDG_ACCOUNT = '2768167';
  private static String NDG_CONTACT = '378463';

  @testSetup
  static void dataSetup() {
    WGC_AllDataFactory.createUtenzaDefault();
    User dora = TestUtils.creaUtente('dora');
    TestUtils.impostaCS();
    Account acc = TestUtils.creaAccount('Accaunt', dora, 'MI', '02213390343', 'rsscld50r15h501y', 'Prospect', NDG_ACCOUNT);
    Account acc2 = TestUtils.creaAccount('AccauntDaCensire', dora, 'MI', '02213390344', 'rsscld50r15h502y', 'Prospect', null);
    // Contact con = TestUtils.creaReferente('codiceFiscale', 'Nome', 'Cognome', NDG_CONTACT);
    Contact con = WGC_AllDataFactory.createContact(1,false).get(0);
    con.FirstName='Nome';
    insert con;
    TestUtils.creaEndpointServizi();
  }

  @isTest
  static void testUpdatePG() {
    Account acc = [SELECT NDGGruppo__c, CF__c, PIVA__c FROM Account WHERE Name = 'Accaunt'];
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_GET_DATI_ANAGRAFICI_CEDACRI_DI));

    Test.startTest();
    Account risposta = (Account) WsAnagrafeUtils.mergeWithCedacri(acc);
    Test.stopTest();

    System.assertEquals(NDG_ACCOUNT, risposta.NDGGruppo__c);
    // TODO: check account mapping nel dettaglio
  }

  @isTest
  static void testUpdatePF() {
    Contact con = [SELECT NDGGruppo__c, CF__c FROM Contact WHERE FirstName = 'Nome'];
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_GET_DATI_ANAGRAFICI_CEDACRI_PF));

    Test.startTest();
    Contact risposta = (Contact) WsAnagrafeUtils.mergeWithCedacri(con);
    Test.stopTest();

    System.assertEquals(NDG_CONTACT, risposta.NDGGruppo__c);
    // TODO: check contact mapping nel dettaglio
  }

   @isTest
   static void testGestioneCollNdg() {
    // TODO: da implementare, gestire più risposte mockate
    User dora = [SELECT Id FROM User WHERE Alias = 'dora'];
    Account acc = TestUtils.creaAccount('AccountTest', dora, 'MI', null, 'BRVPMR54R11A290O', 'Prospect', '2548031');
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOADS_GESTIONE_COLL_NDG_PF));

    Test.startTest();
    WsAnagrafeUtils.syncCollegamentiAsync('2548031', acc.Id);
    Test.stopTest();

    AccountContactRelation[] accountContactRelations = [SELECT Id FROM AccountContactRelation WHERE AccountId = :acc.Id];
    //System.assertEquals(2, accountContactRelations.size());
  }

  @isTest
  static void testCensimentoLightPG() {

    Account acc = (Account) WsAnagraficaBean.getEntity([SELECT Id,EmailPEC__c FROM Account WHERE Name = 'Accaunt'].Id);

    //Account acc = [SELECT Id FROM Account WHERE Name = 'Accaunt'];

    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_SET_ANAGRAFICA_LIGHT_PG));

    Test.startTest();
    WsAnagrafeUtils.censimentoLight(acc);
    Test.stopTest();

    // TODO: fare i check
    // verifico che il censimento sia andato a buon fine = niente log
    //Log__c[] logList = [SELECT Id FROM Log__c WHERE Source__c = 'CensimentoLight'];
    //  System.assert(logList.isEmpty());
  }

  @isTest
  static void testCensimentoLightPF() {
    Contact con = [SELECT Id FROM Contact WHERE FirstName = 'Nome'];
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_SET_ANAGRAFICA_LIGHT_PF));

    Test.startTest();
    WsAnagrafeUtils.censimentoLightAsync(con.Id);
    Test.stopTest();

    // TODO: fare i check
    // verifico che il censimento sia andato a buon fine = niente log
    // Log__c[] logList = [SELECT Id FROM Log__c WHERE Source__c = 'CensimentoLight'];
    // System.assert(logList.isEmpty());

  }

  @isTest
  static void testSearchPG() {
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_PG));

    Test.startTest();
    Account[] risposta = WsAnagrafeUtils.searchPG('RACCORFERS BRIVIO PAOLO', 'codFiscale', 'piva', 'LC');
    Test.stopTest();

    System.debug('risposta: ' + JSON.serialize(risposta));
    System.assertEquals(1, risposta.size());
  }

  @isTest
  static void testSearchPF() {
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_PF));

    Test.startTest();
    Contact[] risposta = WsAnagrafeUtils.searchPF('cf', 'lastName', 'firstName');
    Test.stopTest();

    System.assertEquals(2, risposta.size());
  }

  @isTest
  static void testVariazionePF() {
    Contact con = [SELECT Id FROM Contact WHERE FirstName = 'Nome'];
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_SET_ANAGRAFICA_VARIAZIONE_PF));

    Test.startTest();
    WsAnagrafeUtils.variazioneAsync(con.Id);
    Test.stopTest();

    // verifico che il censimento sia andato a buon fine = niente log
    Log__c[] logList = [SELECT Id FROM Log__c WHERE Source__c = 'variazionePF'];
    System.assert(logList.isEmpty());//TODO fix...
  }

  @isTest
  static void testvariazionePG() {
    Account account = [SELECT Name,
      CF__c,
      PIVA__c,
      BillingPostalCode,
      BillingCity,
      BillingState,
      BillingStreetName__c,
      BillingStreetNumber__c,
      BillingStreetType__c,
      ShippingStreetName__c,
      ShippingStreetNumber__c,
      ShippingStreetType__c,
      ShippingPostalCode,
      ShippingCity,
      ShippingState,
      NDGGruppo__c,
      NaturaGiuridica__c,
      DataInserimentoConsensi__c,
      ConsensoAllaProfilazione__c,
      ConsensoAttivitaPromRicercheMercato__c,
      ConsensoAttivitaPromozionaleTerzi__c,
      ConsensoProdottiBancaRicercheMercato__c,
                       ConsensoProdottiSocietaTerze__c,
                       ConsensoSoloModalitaTradizionali__c,
                       WGC_Emissioni_di_Azioni_al_Portatore_PNF__c,
                       WGC_Partecipazione_societa_fiduciarie__c,
                       WGC_Assetti_Attivita_Svolta__c,
                       WGC_Soggetti_Partecipanti__c,
      SAE__c,
      RAE__c,
      Ateco__c,
      REA__c
    FROM Account
    WHERE NDGGruppo__c = :NDG_ACCOUNT];
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_SET_ANAGRAFICA_VARIAZIONE_PG));

    Test.startTest();
    WsAnagrafeUtils.variazione(account.Id);
    Test.stopTest();

    // TODO asserts

  }

  @isTest
  static void testCensimentoFull() {
    Account account = [SELECT Name,
      CF__c,
      PIVA__c,
      Email__c,
      BillingPostalCode,
      BillingCity,
      BillingState,
      BillingStreetName__c,
      BillingStreetNumber__c,
      BillingStreetType__c,
      ShippingStreetName__c,
      ShippingStreetNumber__c,
      ShippingStreetType__c,
      ShippingPostalCode,
      ShippingCity,
      ShippingState,
      NDGGruppo__c,
      NaturaGiuridica__c,
      DataInserimentoConsensi__c,
      ConsensoAllaProfilazione__c,
      ConsensoAttivitaPromRicercheMercato__c,
      ConsensoAttivitaPromozionaleTerzi__c,
      ConsensoProdottiBancaRicercheMercato__c,
      ConsensoProdottiSocietaTerze__c,
      ConsensoSoloModalitaTradizionali__c,
                       WGC_Emissioni_di_Azioni_al_Portatore_PNF__c,
                       WGC_Partecipazione_societa_fiduciarie__c,
                       WGC_Assetti_Attivita_Svolta__c,
                       WGC_Soggetti_Partecipanti__c,
      SAE__c,
      RAE__c,
      Ateco__c,
      REA__c,
      PaeseCasaMadre__c
    FROM Account
    WHERE Name = 'AccauntDaCensire'];

    account.Ateco__c = '01.13.30';
    account.RAE__c = '11';
    account.SAE__c = '33';
    update account;

    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_SET_ANAGRAFICA_CEDACRI_PG));

    Test.startTest();
    String result = WsAnagrafeUtils.censimentoFull(account.Id);
    Test.stopTest();

    // TODO: asserts
    System.assertEquals('1278', result);
  }

  @isTest
  static void testGetNdgCointestazione() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_GESTIONE_COLL_NDG_PF));
    String response = WsAnagrafeUtils.getNdgCointestazione(new String[]{'1553425'});
    Test.stopTest();
    System.assertEquals('1553425', response);
  }

  @isTest
  static void testSetRetiAnagraficheIfisAsync() {
    Test.startTest();
    Boolean exceptionThrown = false;
    User u = TestUtils.creaUtente('TestUser');
    Account a = TestUtils.creaAccount('TestAccount');
    // a.NDGGruppo__c = '1234';
    a.GestoreCliente__c = 'gestore cliente';
    a.GestoreDebitore__c = 'gestore debitore';
    a.Presentatore__c = u.Id;
    update a;

    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_SET_RETI_ANAGRAFICHE));
    try {
      WsAnagrafeUtils.setRetiAnagraficheIfisAsync(a.Id);
    } catch (Exception e) {
      exceptionThrown = true;
    }
    Test.stopTest();

    // Il metodo ritorna void e non esegue dml: se non vengono lanciate eccezioni l'esito del test è positivo
    System.assert(!exceptionThrown);
  }

  @isTest
  static void testAssociaPfPgCollNdg() {
    Test.startTest();
    Boolean exceptionThrown = false;
    Contact c = TestUtils.creaReferente('TestCF', 'TestNome', 'TestCognome', '5678');
    User u = TestUtils.creaUtente('TestUser');
    Account a = TestUtils.creaAccount('TestAccount');
    // a.NDGGruppo__c = '1234';
    a.NaturaGiuridica__c = 'SPA';
    update a;

    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_GESTIONE_COLL_NDG_PF));
    try {
      WsAnagrafeUtils.associaPfPgCollNdg(a.Id, c.Id);
    } catch (Exception e) {
      exceptionThrown = true;
    }
    Test.stopTest();

    // Il metodo ritorna void e non esegue dml: se non vengono lanciate eccezioni l'esito del test è positivo
    // System.assert(!exceptionThrown);
  }

  @isTest
  static void testThrowError() {
    Exception ex = new Ex.WSException();
    Test.startTest();
    try {
      WsAnagrafeUtils.throwError(ex);
    } catch (Ex.AnagrafeDiGruppoException e) {
      System.assert(e.getMessage().contains('Errore richiesta integration layer (cedacri):'));
    }
    Test.stopTest();
  }
}