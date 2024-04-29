/**
 * Created by ccardinale on 17/05/2017.
 */

@IsTest
private class ExtPdfFatcaTest {
  @IsTest
  static void testAll(){
    User dora = TestUtils.creaUtente('dora');
    TestUtils.impostaCS();
    Account a = TestUtils.creaAccount('A',dora);
    Opportunity opp = TestUtils.CreaOpportunity(a);
    opp.Name = 'test';
    update opp;
    Contact ref = TestUtils.creaReferente(a);
    NDGLinea__c ndglinea = TestUtils.CreaNGDLinea(ref, opp);
    ndglinea.ReferenteFatca__c = true;
    update ndglinea;
    ExtPdfFatca fatca = new ExtPdfFatca(new ApexPages.StandardController(opp));
    System.assertEquals(1, fatca.linee.size());
  }
}