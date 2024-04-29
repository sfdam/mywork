@IsTest
public with sharing class FrodeTableControllerTest {
    
    @TestSetup
    static void setup(){
        Account a = new Account();
        a.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        a.FirstName='test';
        a.LastName='test';
        insert a;

        Product2 product = new Product2();
        product.CRM_MacroGroupCode__c = 'MG_129';
        product.Name = 'test';
        insert product;
        Product2 product2 = new Product2();
        product2.Name = 'test2';
        insert product2;
        FinServ__FinancialAccount__c prod= new FinServ__FinancialAccount__c();
        prod.RecordTypeId=Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('CreditCard').getRecordTypeId();
        prod.Name='test';
        prod.FinServ__Status__c='Active';
        prod.FinServ__PrimaryOwner__c=a.Id;
        prod.FinServ__ProductName__c = product2.id;
        insert prod;
        FinServ__FinancialAccount__c prod2= new FinServ__FinancialAccount__c();
        prod2.Name='test';
        prod2.FinServ__Status__c='Active';
        prod2.FinServ__PrimaryOwner__c=a.Id;
        prod2.FinServ__ProductName__c = product.id;
        insert prod2;
        Case c = new Case();
        c.Origin='Web';
        c.AccountId= a.Id;
        insert c;

        FinServ__FinancialAccountRole__c role = new FinServ__FinancialAccountRole__c();
        role.FinServ__FinancialAccount__c= prod.Id;
        role.FinServ__RelatedAccount__c=a.Id;
        role.FinServ__Role__c='Primary Owner';
        insert role;

        Case c1 = new Case();
        c1.AccountId= a.Id;
        c1.Origin='Phone';
        insert c1;
    }
    
    @isTest
    static void testGetAllData1(){
        
        Case c = [SELECT Id FROM Case WHERE Account.FirstName='Test' LIMIT 1];
        
        
        try{
            FrodeTableController.getAllData(c.Id,1);
           
        }
        catch(AuraHandledException e){

        }
    }
    @isTest
    static void testGetAllData2(){
        
        
        Case c1 = [SELECT Id FROM Case WHERE Origin='Phone' LIMIT 1];
        
        try{
            
            FrodeTableController.getAllData(c1.Id,2);
        }
        catch(AuraHandledException e){

        }
    }
}