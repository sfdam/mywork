@isTest
public with sharing class Batch_RimozioneLead_Test {

    @TestSetup
    static void setup(){
        Lead newLead = new Lead(
            FirstName = 'test',
            LastName = 'test',
            Company = 'test test'           
        );
        insert newLead;
        Test.setCreatedDate(newLead.Id, System.now().addDays(-15));
    }
    
    @isTest
    static void Test1() {
        Test.startTest();
        Batch_RimozioneLead rl = new Batch_RimozioneLead();
        Database.executeBatch(rl);
        Test.stopTest();
    }
}