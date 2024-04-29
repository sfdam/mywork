@IsTest
public with sharing class CaseDataTableControllerTest {
    @TestSetup
    static void setup(){
        Product2 product = new Product2(
            Name = 'Test'
        );
        insert product;
        
        Account a= new Account();
        a.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        a.FirstName='test';
        a.LastName='test';
        insert a;

        FinServ__FinancialAccount__c prod= new FinServ__FinancialAccount__c();
        prod.FinServ__PrimaryOwner__c=a.Id;
        prod.FinServ__ProductName__c = product.Id;
        prod.CRM_ValidityEndDate__c = Date.newInstance(2025, 12, 29);
        insert prod;

        Case c = new Case();
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
        Case c = [SELECT Id,AccountId FROM Case LIMIT 1];
        CRM_Channel__c ch = [SELECT Id FROM CRM_Channel__c LIMIT 1];
        FinServ__FinancialAccount__c prod = [SELECT Id FROM FinServ__FinancialAccount__c LIMIT 1];

        Test.startTest();
        List<Case> case1= CaseDataTableController.getAllData(a.Id,1);
        List<Case> case2= CaseDataTableController.getAllData(prod.Id,3);
        List<Case> case3= CaseDataTableController.getAllData(prod.Id,4);
        List<Case> case4= CaseDataTableController.getAllData(ch.Id,2);
        System.debug('case1'+ case1);
        System.debug('case2'+ case2);
        System.debug('case3'+ case3);
        System.debug('case4'+ case4);
        Test.stopTest();
        System.assertEquals(True, case1.size()>0);
        System.assertEquals(True, case2.size()>0);
        System.assertEquals(True, case3.size()>0);
        System.assertEquals(True, case3.size()>0);

    }

    @isTest
    static void testGetInfo(){
        Account a = [SELECT Id FROM Account LIMIT 1];
        Case c = [SELECT Id FROM Case LIMIT 1];
        CRM_Channel__c ch = [SELECT Id FROM CRM_Channel__c LIMIT 1];
        FinServ__FinancialAccount__c prod = [SELECT Id FROM FinServ__FinancialAccount__c LIMIT 1];

        Test.startTest();
        SObject record1 = CaseDataTableController.getInfo('FinServ__FinancialAccount__c', prod.id);
        SObject record2 = CaseDataTableController.getInfo('CRM_Channel__c', ch.id);
        System.debug('record1'+ record1);
        System.debug('record2'+ record2);
        Test.stopTest();
        System.assertEquals(prod.id, record1.Id);
        System.assertEquals(ch.id, record2.Id);

    }

    @isTest
    static void testGetRecordTypeId(){
        Account a = [SELECT Id FROM Account LIMIT 1];
        Case c = [SELECT Id FROM Case LIMIT 1];
        CRM_Channel__c ch = [SELECT Id FROM CRM_Channel__c LIMIT 1];
        FinServ__FinancialAccount__c prod = [SELECT Id FROM FinServ__FinancialAccount__c LIMIT 1];
        String response = CaseDataTableController.getRecordTypeId('Case', 'Standard_Case');
        System.debug('response'+response);
    }
}