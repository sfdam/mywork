@IsTest
public with sharing class CaseDataTableControllerTest {
    @TestSetup
    static void setup(){
        Product2 product = new Product2(
            Name = 'Test'
        );
        insert product;
        Case c = new Case();
        Account a= new Account();
        FinServ__FinancialAccount__c prod= new FinServ__FinancialAccount__c();
        a.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        a.FirstName='test';
        a.LastName='test';
        insert a;

        prod.FinServ__PrimaryOwner__c=a.Id;
        prod.FinServ__ProductName__c = product.Id;
        prod.CRM_ValidityEndDate__c = Date.newInstance(2025, 12, 29);
        insert prod;

        c.AccountId=a.Id;
        c.Origin='Web';
        c.FinServ__FinancialAccount__c=prod.Id;

        insert c;

        CRM_Channel__c ch  =new CRM_Channel__c();
        ch.CRM_Account__c=a.Id;
        insert ch;
    }
    @isTest
    static void testGetAllData(){
        Account a = [SELECT Id FROM Account LIMIT 1];
        Case c = [SELECT Id FROM Case LIMIT 1];
        CRM_Channel__c ch = [SELECT Id FROM CRM_Channel__c LIMIT 1];
        FinServ__FinancialAccount__c prod = [SELECT Id FROM FinServ__FinancialAccount__c LIMIT 1];
        CaseDataTableController.getAllData(a.Id,1);
        CaseDataTableController.getAllData(prod.Id,3);
        CaseDataTableController.getAllData(prod.Id,4);
        CaseDataTableController.getAllData(ch.Id,2);
    }

    @isTest
    static void testGetInfo(){
        Account a = [SELECT Id FROM Account LIMIT 1];
        Case c = [SELECT Id FROM Case LIMIT 1];
        CRM_Channel__c ch = [SELECT Id FROM CRM_Channel__c LIMIT 1];
        FinServ__FinancialAccount__c prod = [SELECT Id FROM FinServ__FinancialAccount__c LIMIT 1];
        SObject record = CaseDataTableController.getInfo('FinServ__FinancialAccount__c', prod.id);
        record = CaseDataTableController.getInfo('CRM_Channel__c', ch.id);
    }

    @isTest
    static void testGetRecordTypeId(){
        Account a = [SELECT Id FROM Account LIMIT 1];
        Case c = [SELECT Id FROM Case LIMIT 1];
        CRM_Channel__c ch = [SELECT Id FROM CRM_Channel__c LIMIT 1];
        FinServ__FinancialAccount__c prod = [SELECT Id FROM FinServ__FinancialAccount__c LIMIT 1];
        String response = CaseDataTableController.getRecordTypeId('Case', 'Standard_Case');
    }
}