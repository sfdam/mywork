/**
 * Created by ccardinale on 17/05/2017.
 */

@IsTest
private class QbleRecuperoDocumentiTest {
  @IsTest
  static void testAll() {
    User dora = TestUtils.creaUtente('dora');
    TestUtils.impostaCS();
    Account a = TestUtils.creaAccount('A',dora);
    // a.NDGGruppo__c = '3333';
    update a;
    Opportunity opp = TestUtils.CreaOpportunity(a);
    opp.Name = 'test';
    opp.IdCartella__c = 'aaa';
    update opp;
    Allegato__c allegato = TestUtils.creaAllegato(opp, 'RSFFirm');
    TestUtils.creaContentDocumentLink(allegato);
    TestUtils.creaEndpointServizi();
    Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_SEARCH_DOCUMENT));
    Test.startTest();
    QbleRecuperoDocumenti recuperoDocumenti = new QbleRecuperoDocumenti(opp.Id);
    recuperoDocumenti.execute(null);
    Test.stopTest();
    //TODO assert...
  }
}