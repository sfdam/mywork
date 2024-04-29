@IsTest
public with sharing class CrmLogGarantePrivacyControllerTest {
    @TestSetup
    static void setup(){
        Product2 product = new Product2(
            Name = 'Test'
        );
        insert product;
        User user = AllDataFactory.getUser('01', UserInfo.getProfileId(), 'CORPORATE');
        user.FederationIdentifier = '0987';
        insert new List<User>{user};

        Account a= new Account();
        FinServ__FinancialAccount__c prod= new FinServ__FinancialAccount__c();
        prod.FinServ__ProductName__c = product.Id;
        a.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        a.FirstName='test';
        a.LastName='test';
        a.FinServ__BankNumber__c = '0987';
        a.CRM_NDG__c = '09875';
        insert a;

        prod.FinServ__PrimaryOwner__c=a.Id;
        insert prod;
        LDAP__c ldap = new LDAP__c();
        ldap.Codice_Controllo_Accessi__c ='01015008870000000000';
        ldap.Matricola__c ='U0987';
        insert ldap;
    }

    @isTest
    static void testLoadUpdate(){
        Test.startTest();
        List<FinServ__FinancialAccount__c> finAcc = [SELECT Id FROM FinServ__FinancialAccount__c LIMIT 1];
        User u = [SELECT Id FROM User WHERE FederationIdentifier ='0987' AND IsActive = true LIMIT 1];
        Map<String, SObject> x;
        System.runAs(u) {
             x = CrmLogGarantePrivacyController.saveLog('Financial Account', finAcc[0].Id, 'TEST');
        }
        
        Test.stopTest();
        System.assertEquals(false, x.size()>0);
    }
}