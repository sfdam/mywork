@isTest
private class Batch_UpdateGerarchiaTables_Test {
    @isTest
    static void StrutturaBanca() {
        Struttura_Banca__c sb = new Struttura_Banca__c(Da_Elaborare__c=true);
        insert sb;
        Test.startTest();
        Batch_UpdateGerarchiaTables upd = new Batch_UpdateGerarchiaTables();
        upd.initRunner(new List<ScheduledJob__c>());
        Database.executeBatch(upd,200);
        Test.stopTest();
    }
}