@isTest
public class BtcCheckStatoQQTest {
 @testSetup static void setup(){

    Funzionalita__c f = Funzionalita__c.getInstance();
    f.DisabilitaControlloCambioFaseOpp__c = true;
    upsert f;
    WGC_AllDataFactory.createUtenzaDefault();
    Account a = TestUtils.creaAccount('AccountTest');

    QuestionarioQualitativo__c q = new QuestionarioQualitativo__c(Account__c = a.Id, DataCompilazione__c = Date.newInstance(2017,2,3), Stato__c = 'Confermato');
    insert q;
    }

    @isTest static void testBatch(){

      List<QuestionarioQualitativo__c> qList = [SELECT FineValidita__c, Stato__c FROM QuestionarioQualitativo__c WHERE Stato__c = 'Confermato'];
      System.assertEquals(qList.size(),1);
      Test.startTest();
      BtcCheckStatoQQ btc = new BtcCheckStatoQQ();
      Database.executeBatch(btc);
      Test.stoptest();

      List<QuestionarioQualitativo__c> qListUpd = [SELECT FineValidita__c, Stato__c FROM QuestionarioQualitativo__c WHERE Stato__c = 'Confermato'];
      System.assertEquals(qListUpd.size(),0);

    }
}