/**
 * Created by ccardinale on 17/05/2017.
 */

@IsTest
private class CtrlCensimentoTest {
  @TestSetup
  static void dataSetup() {
    Funzionalita__c f = Funzionalita__c.getInstance();
    f.DisabilitaNamingAutomaticaOpportunita__c = true;
    f.DisabilitaValidationSuCambioNDG__c = true;
    f.ControlloCodiceFiscale__c = false;
    upsert f;

    EndpointServizi__c s = new EndpointServizi__c(Name = 'settings', LAGKey__c = 'x', URLGetListaAziendeRibes__c = 'https://a.com');
    insert s;

    User dora = TestUtils.creaUtente('dora');
    TestUtils.impostaCS();
    TestUtils.creaEndpointServizi();
    Account a = TestUtils.creaAccount('A',dora);
    a.NaturaGiuridica__c = 'DI';
    update a;
    Opportunity opp = TestUtils.CreaOpportunity(a, 'test');
    update opp;
  }

  @IsTest
  static void testGetAziendeDaCensire(){
    Account a = [SELECT Id, OwnerId FROM Account WHERE Name = 'A'];
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test'];
    System.assertEquals(1, CtrlCensimento.getAziendeDaCensire(opp.Id).size());
    //aggiungo un attore
    Contact cont = TestUtils.creaReferente(a, 'AAAA');
    NDGLinea__c ndglinea = TestUtils.CreaNGDLinea(Cont, Opp);
    System.assertEquals(2, CtrlCensimento.getAziendeDaCensire(opp.Id).size());
  }

  @isTest
  static void testPrecheckCedacri() {
    Account a = [SELECT Id, OwnerId FROM Account WHERE Name = 'A'];
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test'];
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_PF));

    Test.startTest();
    CtrlCensimento.precheckCedacri(a.Id, opp.Id);
    Test.stopTest();

    // TODO: inserire assert
  }

  @IsTest
  static void testRichiediRibes(){
    Account a = [SELECT Id, OwnerId FROM Account WHERE Name = 'A'];
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test'];
    //aggiungo un attore
    Contact cont = TestUtils.creaReferente(a, 'AAAA');
    NDGLinea__c ndglinea = TestUtils.CreaNGDLinea(Cont, Opp);
    ndglinea.Account__c = a.Id;
    update ndglinea;

    Test.startTest();
    //Caso 1- no convalida
    CtrlCensimento.richiediRibes([SELECT Id, Account__c FROM NDGLinea__c WHERE Id = :ndglinea.Id].Account__c, opp.Id);
    Test.stopTest();

    System.assertEquals(null, [SELECT DataConvalida__c FROM NDGLinea__c WHERE Id = :ndglinea.Id].DataConvalida__c);

    //Caso 3 - convalida ok
    /*Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_GETLISTAAZIENDE));
    a.REA__c = 'AAA';
    a.ProvinciaCCIAA__c = 'AAA';
    update a;
    CtrlCensimento.richiediRibes([SELECT Id, Account__r.Id, Account__r.StatoCensimento__c, Account__r.DettaglioCensimento__c, Account__r.REA__c, Account__r.ProvinciaCCIAA__c, Account__r.CF__c, Account__r.BillingState, Account__r.Fatturato__c, Account__r.DataFatturato__c, Account__r.BU__c FROM NDGLinea__c WHERE Id = :ndglinea.Id], opp.Id);
    System.assertEquals('1001', [SELECT BU__c FROM Account WHERE Id = :a.Id].BU__c);*/
    //TODO fix
  }

  @isTest
  static void testRichiediRibes2() {
    Account a = [SELECT Id, OwnerId FROM Account WHERE Name = 'A'];
    a.StatoCensimento__c = CtrlCensimento.INFOPROVIDER_TODO;
    a.CF__c = 'AAA';
    update a;

    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test'];
    //aggiungo un attore
    Contact cont = TestUtils.creaReferente(a, 'AAAA');
    NDGLinea__c ndglinea = TestUtils.CreaNGDLinea(Cont, Opp);
    ndglinea.Account__c = a.Id;
    update ndglinea;

    //Caso 2- convalida con error
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_GETLISTAAZIENDE));
    Test.startTest();
    CtrlCensimento.richiediRibes([SELECT Id, Account__c FROM NDGLinea__c WHERE Id = :ndglinea.Id].Account__c, opp.Id);
    Test.stopTest();

    System.assertEquals(CtrlCensimento.INFOPROVIDER_KO, [SELECT StatoCensimento__c FROM Account WHERE Id = :a.Id].StatoCensimento__c);
  }

  @IsTest
  static void testRichiediCensimento(){
      Test.startTest();
    Account a = [SELECT Id, OwnerId FROM Account WHERE Name = 'A'];
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test'];
    //aggiungo un attore
    Contact cont = TestUtils.creaReferente(a, 'AAAA');
    NDGLinea__c ndglinea = TestUtils.CreaNGDLinea(Cont, Opp);
    ndglinea.Account__c = a.Id;
    update ndglinea;

    a.StatoCensimento__c = CtrlCensimento.CENSIMENTO_FULL_OK;
    a.CF__c = 'AAA';
    a.Ateco__c = 'AA';
    a.BillingCity = 'AA';
    a.BillingPostalCode = '0999';
    a.BillingStreetName__c = 'AA';
    a.BillingStreetNumber__c = 'AA';
    a.BillingStreetType__c = 'via';
    a.BillingState = 'AA';
    a.RAE__c = '222';
    a.NaturaGiuridica__c = 'AA';
    a.SAE__c = '22';
    update a;
    CtrlCensimento.richiediCensimento(a.Id, opp.Id);
      Test.stopTest();
    //TODO SISTEMARE STO TEST
  }

  //TODO testare più approfonditamente
  @IsTest
  static void testForzaControaggiornamentoKNET(){
      Test.startTest();
    Account a = [SELECT Id, OwnerId FROM Account WHERE Name = 'A'];
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test'];
    //aggiungo un attore
    Contact cont = TestUtils.creaReferente(a, 'AAAA');
    NDGLinea__c ndglinea = TestUtils.CreaNGDLinea(Cont, Opp);
    ndglinea.Account__c = a.Id;
    update ndglinea;
    a.StatoCensimento__c = CtrlCensimento.CENSIMENTO_FULL_OK;
    a.NDGGruppo__c = '123456';
    update a;
    CtrlCensimento.forzaControaggiornamentoKNET(a.Id, opp.Id);
      Test.stopTest();
    //TODO assert...
  }

  @isTest
  static void testUpdateEntities() {
    String CF_CONTATTO = 'AAAA';
    Account a = [SELECT Id, OwnerId, NumberOfEmployees FROM Account WHERE Name = 'A'];
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test'];
    opp.DataConvalida__c = Datetime.now();
    update opp;
    // Aggiungo un attore
    Contact cont = TestUtils.creaReferente(a, CF_CONTATTO);
    NDGLinea__c attore = TestUtils.creaNGDLinea(cont, opp);
    attore.DataConvalida__c = Datetime.now();
    update attore;

    Test.startTest();
    CtrlCensimento.updateEntities(new List<Account>{a},new List<Contact>{cont}, opp.Id);
    Test.stopTest();

    opp = [SELECT Id, DataConvalida__c FROM Opportunity WHERE Name = 'Test'];
    cont = [SELECT Id, NaturaGiuridica__c FROM Contact WHERE CF__c = :CF_CONTATTO];
    attore = [SELECT Id, DataConvalida__c FROM NDGLinea__c WHERE Id = :attore.Id];

    System.assertEquals('PF', cont.NaturaGiuridica__c);
    System.assertEquals(null, attore.DataConvalida__c);
    System.assertEquals(null, opp.DataConvalida__c);
  }

  @isTest
  static void testAssociaPfPglLVuota() {
    String CF_CONTATTO = 'AAAA';
    Account a = [SELECT Id, OwnerId FROM Account WHERE Name = 'A'];
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test'];
    Contact cont = TestUtils.creaReferente(a, CF_CONTATTO);

    NDGLinea__c attore = TestUtils.creaNGDLinea(cont, opp);
    attore.Tipo__c = 'Titolare effettivo adeguata verifica';

    Test.startTest();
    System.assertEquals(CtrlCensimento.associaPfPg(cont.Id, opp.Id).success,true);
    Test.stopTest();
  }

    @isTest
  static void testAssociaPfPg() {
    String CF_CONTATTO = 'AAAA';
    Account a = [SELECT Id, OwnerId FROM Account WHERE Name = 'A'];
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test'];
    Contact cont = TestUtils.creaReferente(a, CF_CONTATTO);

    NDGLinea__c attore = TestUtils.creaNGDLineaTitolare(cont, opp, false);

    Test.startTest();
    System.assertEquals(CtrlCensimento.associaPfPg(cont.Id, opp.Id).success,true);
    Test.stopTest();
  }

  @isTest
  static void testFetchAteco() {
    Test.startTest();
    Ateco__c[] result = CtrlCensimento.fetchAteco();
    Test.stopTest();
    System.debug('testFetchAteco: ' + JSON.serialize(result));
  }

  @isTest
  static void testFetchAnagrafeConsulenti() {
    Test.startTest();
    AnagrafeConsulenti__c[] result = CtrlCensimento.fetchAnagrafeConsulenti();
    Test.stopTest();
    System.debug('testFetchAnagrafeConsulenti: ' + JSON.serialize(result));
  }

  @isTest
  static void testFetchRelazioneNgSae() {
    Test.startTest();
    NaturaGiuridicaSAE__mdt[] result = CtrlCensimento.fetchRelazioneNgSae();
    Test.stopTest();
    System.debug('testFetchRelazioneNgSae: ' + JSON.serialize(result));
  }
}