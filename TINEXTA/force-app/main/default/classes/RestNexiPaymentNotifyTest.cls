@isTest
public with sharing class RestNexiPaymentNotifyTest {
    @TestSetup
    static void makeData(){
        Account acc = new Account(Name = 'TestRestNexiNotify', Data_Ultimo_Arricchimento__c = System.Today());
        insert acc;

        Opportunity opp = new Opportunity(Name = 'TestOppRestNexiNotify', StageName = 'Potenziali', WRT_Id_pagamento_Nexi__c = '123', AccountId = acc.Id, CloseDate = System.Today());
        insert opp;
    }

    @isTest
    static void doPostNotificaTestOk(){
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1.0/NexiPaymentNotify';  
        req.addParameter('paymentid', '123');
        req.addParameter('result', 'CAPTURED');
        req.addParameter('customfield', 'test_test@test.invalid');
        req.addHeader('Content-Type', 'application/x-www-form-urlencoded');
    	req.httpMethod = 'POST';  
        RestContext.request = req;
    	RestContext.response = res;
        
        Test.startTest();
        RestNexiPaymentNotify.doPost();
        Test.stopTest();
    }

    @isTest
    static void doPostNotificaTestKo(){
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1.0/NexiPaymentNotify';  
        req.addParameter('paymentid', '123');
        req.addParameter('result', 'CAPTURED');
        req.addHeader('Content-Type', 'application/x-www-form-urlencoded');
    	req.httpMethod = 'POST';  
        RestContext.request = req;
    	RestContext.response = res;
        
        Test.startTest();
        RestNexiPaymentNotify.doPost();
        Test.stopTest();
    }
}