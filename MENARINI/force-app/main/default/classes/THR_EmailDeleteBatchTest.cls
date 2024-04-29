@IsTest
public with sharing class THR_EmailDeleteBatchTest {

    private static final String reclamiFarmacovigilanza = Case.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('THR_PVClaims').getRecordTypeId();

    @TestSetup
    public static void setup() {

        Case newCase = new Case(RecordTypeId = reclamiFarmacovigilanza, THR_RequestType__c = 'PV Claims', THR_Type__c = 'Adverse event', THR_Case_Reason__c = '', THR_Client_Request_Date__c = System.today(), Status = 'New');
        insert newCase;

        Case closedCase = new Case(RecordTypeId = reclamiFarmacovigilanza, THR_RequestType__c = 'PV Claims', THR_Type__c = 'Adverse event', THR_Case_Reason__c = '', THR_Client_Request_Date__c = System.today(), Status = 'Closed');
        insert closedCase;

        insert new List<EmailMessage>{new EmailMessage(ParentId = newCase.Id), new EmailMessage(ParentId = closedCase.Id)};
    }

    @IsTest
    public static void emailDeleteBatch_test1() {
        Test.startTest();
        Database.executeBatch(new THR_EmailDeleteBatch(), 200);
        Test.stopTest();

        List<EmailMessage> emailMessages = [SELECT Id, Parent.Status FROM EmailMessage];
        System.assertEquals(1,emailMessages.size());
        System.assertEquals('New',emailMessages[0].Parent.Status);

        List<Task> tasks = [SELECT Id, WhatId FROM Task];
        System.assertEquals(1,tasks.size());
        System.assertEquals(emailMessages[0].ParentId, tasks[0].WhatId);
    }
}