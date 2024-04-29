@isTest
public class Batch_SganciaRuoliUtenteTest {
    @testSetup static void setup() {
        List<Struttura_Banca__c> sbs = new List<Struttura_Banca__c>();
        Struttura_Banca__c sb1 = new Struttura_Banca__c(
            IdCed__c='12345',
            Stato__c='A'
        );
        Struttura_Banca__c sb2 = new Struttura_Banca__c(
            IdCed__c='12346',
            Stato__c='D'
        );
        sbs.add(sb1);
        sbs.add(sb2);
        
        insert sbs;
    }
    
    @isTest
    static void unitTest() {
        Test.startTest();
        Batch_SganciaRuoliUtente sgr = new Batch_SganciaRuoliUtente();
        sgr.initRunner(new List<ScheduledJob__c>());
        Database.executeBatch(sgr,200);
        Test.stopTest();
    }
}