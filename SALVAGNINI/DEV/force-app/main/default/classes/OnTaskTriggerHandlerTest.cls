@isTest
public class OnTaskTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        Account testAcc = new Account(Name = 'TEST', Primary_Industry__c = 'Agricultural Technologies',BillingCity='Agrigento', BillingCountryCode ='IT',BillingStateCode = 'AG' ,BillingPostalCode = '11500',BillingStreet = 'Test');
        insert testAcc;
        Account testApplicationBranch = new Account(Name = 'TEST2', Primary_Industry__c = 'Agricultural Technologies', Type = 'Branch', Ser_Branch__c = true,BillingCity='Agrigento', BillingCountryCode ='IT',BillingStateCode = 'AG' ,BillingPostalCode = '11500',BillingStreet = 'Test');
        insert testApplicationBranch;
        Opportunity testOpp = new Opportunity(Name = 'TEST', AccountId = testAcc.Id, StageName = 'Qualification', CloseDate = system.today());
        insert testOpp;
        
        SER__c testSer = new SER__c(Name = 'TEST',
                                    Account__c = testAcc.Id,
                                    Application_Branch__c = testApplicationBranch.Id,
                                    Opportunity__c = testOpp.Id);
        insert testSer;
        Task task = new Task (Subject = 'Test',
                              WhatId = testSer.Id,
                              SER_in_charge_to__c = UserInfo.getUserId(),
                              Type = 'Product',
                              ActivityDate = Date.today(),
                              SER_Owner__c = UserInfo.getUserId()
                              );
        insert task;
    }

    @isTest
    static void testUpdate () {
       Task t = [SELECT Id FROM Task WHERE Subject = 'Test'];
       t.Status = 'Completed';
       update t;
    }
}