@isTest
public without sharing class ART_EffectiveAccManSyncBatchSched_Test {
    static testMethod void myTestMethod() {        
        Test.startTest();
        ART_EffectiveAccManagerSyncBatchSched myClass = new ART_EffectiveAccManagerSyncBatchSched();   
        String chron = '0 0 * 1/1 * ? *';        
        System.schedule('Test Sched', chron, myClass);
        Test.stopTest();
   }
}