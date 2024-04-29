@isTest
public class BtcAggiornaOppTest {

  @testSetup
  static void setupData() {
    Funzionalita__c f = Funzionalita__c.getInstance();
    f.DisabilitaNamingAutomaticaOpportunita__c = true;
    f.DisabilitaControlloCambioFaseOpp__c = true;
	f.WGC_disabilita_per_batch__c = true; //msommacal-crm20
    upsert f;

    User u = TestUtils.creaUtente('utente');
    TestUtils.impostaCS();
    Account a = TestUtils.creaAccount('account', u);
    //a.NDGGruppo__c = '3333';
    a.Filiale__c = '5';
    update a;
    Opportunity o = TestUtils.creaOpportunity(a, 'opp');
    o.StageName = 'Valutazione Pratica';
    o.IdCartella__c = 'a/333.33';
    o.DataInquiryStatoCartella__c = null;
    update o;
    Contact c = TestUtils.creaReferente(a);
    //c.NDGGruppo__c = '1111';
    update c;
    NDGLinea__c ndgLinea = TestUtils.creaNGDLinea(c, o);
    ndgLinea.Tipo__c = 'Esecutore adeguata verifica';
    update ndgLinea;
    Prodotto__c prodotto = TestUtils.creaProdotto('AAAA','000001','Factoring');
    Linea__c[] linee = TestUtils.creaLinee(o, 1);
    TestUtils.creaEndpointServizi();
  }

  @isTest
  static void testBatch() {

    Opportunity opp = [SELECT Id FROM Opportunity];
    String idProdotto = [SELECt Id, IdProdotto__c FROM Linea__c WHERE Opportunity__c = :opp.Id][0].IdProdotto__c;
	
	Test.startTest();
	Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_NV_INQUIRY_STATO_CARTELLA_PLACEHOLDER.replace('{{idProdotto}}',idProdotto)));
	Database.executeBatch(new BtcAggiornaOpp(false));
	Test.stopTest();
    // TODO: assert significativi
  }

}