/**
 * Created by ccardinale on 17/05/2017.
 */

@IsTest
private class ExtViewCheckListTest {

  @testSetup
  static void dataSetup() {
    Test.startTest();
    WGC_AllDataFactory.createLagKey();
    Funzionalita__c f = Funzionalita__c.getInstance();
    f.DisabilitaNamingAutomaticaOpportunita__c = true;
    f.DisabilitaControlloCambioFaseOpp__c = true;
    upsert f;

    User dora = TestUtils.creaUtente('dora');
    System.debug('@user id'+dora);
    TestUtils.impostaCS();
    Account a = TestUtils.creaAccount('A',dora);
    //Account b = TestUtils.creaAccount('B',dora,'VI','12345678900','rsscld50r15h501y');
    // a.NDGGruppo__c = '3333';
    a.WGC_Specialista_Factoring__c = UserInfo.getUserId(); 
    a.Filiale__c = '5';
    a.CF__c = 'rsscld50r15h501y';
    update a;
    System.debug('@@@ query ' + Limits.getQueries());
    Opportunity opp = TestUtils.CreaOpportunity(a, 'test');
    System.debug('@@@ query ' + Limits.getQueries());
    Opportunity oppB = TestUtils.creaOpportunity(a,'testb');
    oppB.InnescataNV__c = false;
    update opp;
    opp.IdCartella__c = 'a/333.33';
    update opp;
    Contact c = TestUtils.creaReferente(a);
    c.NDGGruppo__c = '1111';
    update c;
    NDGLinea__c ndgLinea = TestUtils.CreaNGDLinea(c, opp);
    ndgLinea.Tipo__c = 'Esecutore adeguata verifica';
    update ndgLinea;
    Prodotto__c prodotto = TestUtils.creaProdotto('AAAA','000001','Factoring');
    Linea__c[] linee = TestUtils.creaLinee(opp, 1);
    TestUtils.creaEndpointServizi();
    Test.stopTest();
  }

  @IsTest
  static void testInstance() {
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test'];
    new ExtViewCheckList(new ApexPages.StandardController(opp));
    //TODO assert...
  }

  @IsTest
  static void testGetStatoChecklist(){
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test'];
    Test.startTest();
    System.assertEquals(false, ExtViewCheckList.getStatoChecklist(opp.Id).fatcaOk);
    Test.stopTest();
  }

  /*@IsTest
  static void testRefreshStatoCartella(){
    Test.startTest();
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test'];
    String idProdotto = [SELECt Id, IdProdotto__c FROM Linea__c WHERE Opportunity__c = :opp.Id][0].IdProdotto__c;
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_NV_INQUIRY_STATO_CARTELLA_PLACEHOLDER.replace('{{idProdotto}}',idProdotto)));
    ExtViewCheckList.refreshStatoCartella(opp.Id);
    // System.assertEquals(true, ExtViewCheckList.refreshStatoCartella(opp.Id));
    Test.stopTest();
  }*/

  /*@IsTest
  static void testEsistePef(){
    Test.startTest();
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test'];
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_CHECK_STATO_PEF));
    System.assertEquals(false, ExtViewCheckList.esistePef(opp.Id));
    Test.stopTest();
  }*/

  @IsTest
  static void testInviaNuovaVendita(){
    Test.startTest();
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test'];
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_NV_AGGIORNAMENTO_INNESCA_VENDITA));
    ExtViewCheckList.inviaNuovaVendita(opp.Id);
    //System.assertEquals(null, );
    Test.stopTest();
  }

  @IsTest
  static void testGeneraDocumentazione(){
    Test.startTest();
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test'];
    System.assertNotEquals(null, ExtViewCheckList.generaDocumentazione(opp.Id, 'Privacy'));
    Test.stopTest();
  }

  @IsTest
  static void testEsisteTitolareEffettivo() {
    Test.startTest();

    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test'];

    Boolean response = ExtViewCheckList.esisteTitolareEffettivo(opp.Id);
    Test.stopTest();

    System.assert(!response);
  }

  @IsTest
  static void testRichiediInfoCR() {
    Test.startTest();
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test'];

    
    Boolean response = ExtViewCheckList.richiediInfoCR(opp.Id);
    Test.stopTest();

    System.assert(response);
  }

  @isTest
  static void testCambiaInnescoOpportunita() {
    Test.startTest();
    Opportunity opp = [SELECT Id, InnescataNV__c FROM Opportunity WHERE Name = 'testb'];
    System.assert(!opp.InnescataNV__c);
      
    ExtViewCheckList.cambiaInnescoOpportunita(true, opp.Id);
    Test.stopTest();

    //opp = [SELECT Id, InnescataNV__c FROM Opportunity WHERE Name = 'test'];
    //System.assert(opp.InnescataNV__c);
  }

  @isTest
  static void testFetchInnescoOpportunita() {
    Opportunity opp = [SELECT Id, InnescataNV__c FROM Opportunity WHERE Name = 'testb'];
	/*
    opp.InnescataNV__c = true;
    update opp;
	*/
      
    Test.startTest();
    Boolean result1 = ExtViewCheckList.fetchInnescoOpportunita(opp.Id);
    //System.assert(result1);
    Test.stopTest();
	
    /*
    opp.InnescataNV__c = false;
    update opp;
    Boolean result2 = ExtViewCheckList.fetchInnescoOpportunita(opp.Id);
    System.assert(!result2);
    */
  }
    
  @isTest
  static void testFetchInnescoOpportunita2(){
      Test.startTest();
        Opportunity opp = [SELECT Id, InnescataNV__c FROM Opportunity WHERE Name = 'test'];
        Boolean result2 = ExtViewCheckList.fetchInnescoOpportunita(opp.Id);
    	//System.assert(!result2);
      Test.stopTest();
    }

  @isTest static void testGetUpdatedFatturatoAndDipendenti(){
    Opportunity opp = [SELECT Account.Id, Account.Name FROM Opportunity WHERE Name = 'test'];
    Account a = [SELECT Name, CF__c, Fatturato__c, NumberOfEmployees FROM Account WHERE Id = :opp.Account.Id];

    Test.startTest();
    System.assertEquals(true, ExtViewCheckList.getUpdatedFatturatoAndDipendenti(opp.Id));
    a.RicaviNetti__c = 10.0;
    a.NumberOfEmployees = 10;
    //update a;
    //Opportunity oppo = [SELECT Account.Id FROM Opportunity WHERE Name = 'test'];
    //System.assertEquals(false, ExtViewCheckList.getUpdatedFatturatoAndDipendenti(opp.Id));
    Test.stopTest();
  }
}