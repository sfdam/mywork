/**
 * Created by ccardinale on 17/05/2017.
 */

@IsTest
private class QbleInvioDocumentiTest {
  @IsTest
  static void testAll(){
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
    QbleInvioDocumenti.QbleInvioDocumentiInput documento = new QbleInvioDocumenti.QbleInvioDocumentiInput(opp.Id, allegato.Id);
    QbleInvioDocumenti invioDocumenti = new QbleInvioDocumenti(documento);
    invioDocumenti.execute(null);
    //TODO assert...
  }
}