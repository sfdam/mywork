@isTest
private without sharing class QbleArricchimentoErrorTest {

    @TestSetup
    static void makeData(){
        Account acc = new Account(
            Name = 'TESTERRORE',
            CCIAA_CMK__c = 'MI',
            CCIAA_REA__c = '123',
            Errore_Monitoraggio__c = true,
            Data_Ultimo_Arricchimento__c = System.Today()
        );
        insert acc;
    }

    @isTest
    static void testQbleNoIds() {
        Test.setMock(HttpCalloutMock.class, new TXT_CalloutHandlerTestMock(3));
        Test.startTest();
            System.enqueueJob(new QbleArricchimentoError());
        Test.stopTest();
    }

    @isTest
    static void testQbleWithIds() {
        Test.setMock(HttpCalloutMock.class, new TXT_CalloutHandlerTestMock(3));
        List<Account> accs = new List<Account>([SELECT Id FROM Account]);
        List<Id> accIds = new List<Id>{accs[0].Id};
        Test.startTest();
            System.enqueueJob(new QbleArricchimentoError(accIds));
        Test.stopTest();
    }

    @isTest
    static void testQble_NoAccounts() {
        delete [SELECT Id FROM Account];
        Test.setMock(HttpCalloutMock.class, new TXT_CalloutHandlerTestMock(3));
        Test.startTest();
            System.enqueueJob(new QbleArricchimentoError());
        Test.stopTest();
    }

    @isTest
    static void testScheduler() {
        QbleArricchimentoErrorScheduler job = new QbleArricchimentoErrorScheduler();
        String sch = '0 0 23 * * ?';
        System.Schedule('Schedule Errori monitoraggio', sch, job);
    }
}