@isTest
public without sharing class ART_AccountManagerOrgUnitBasedSched_Test {
    static testMethod void myTestMethod() {        
        Test.startTest();
        ART_AccountManagerOrgUnitBasedScheduler myClass = new ART_AccountManagerOrgUnitBasedScheduler ();   
        String chron = '0 0 * 1/1 * ? *';        
        system.schedule('Test Sched', chron, myClass);
        Test.stopTest();
   }
}