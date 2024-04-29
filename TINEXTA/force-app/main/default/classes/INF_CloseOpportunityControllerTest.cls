@isTest
public class INF_CloseOpportunityControllerTest {

    @TestSetup
    static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standardusertest@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standardusertest2021@testorg.com', Societa__c = 'Infocert');

        insert u;

        Account acc = new Account(Name = 'TestAccount1');
        insert acc;

        List<Account> accList = new List<Account>{acc};
        List<Opportunity> oppList = TestDataFactory.createOpportunity(accList);
        Codice_Cliente__c cc = new Codice_Cliente__c(Name = '123', Account__c = accList[0].Id);
        insert cc;
        
        for(Opportunity opp : oppList){
            opp.Codice_Cliente__c = cc.Id;
        }
        
        insert oppList;
    }

    @isTest
    static void getDataTestOk1(){
        User u =  [SELECT Id, Name FROM User WHERE LastName = 'Testing'];

        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount1'];

        Test.startTest();
        System.runAs(u){
            INF_CloseOpportunityController.getCodes(acc.Id);
        }
        Test.stopTest();
    }

    // @isTest
    // static void getDataTestOk2(){
    //     User u =  [SELECT Id, Name, Societa__c FROM User WHERE LastName = 'Testing'];
    //     u.Societa__c = 'Luxtrust';
    //     update u;

    //     Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount1'];

    //     Test.startTest();
    //     System.runAs(u){
    //         INF_CloseOpportunityController.getCodes(acc.Id);
    //     }
    //     Test.stopTest();
    // }

    @isTest
    static void getDataTestOk3(){
        User u =  [SELECT Id, Name, Societa__c FROM User WHERE LastName = 'Testing'];
        u.Societa__c = 'Camerfirma';
        update u;
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount1'];

        Test.startTest();
        System.runAs(u){
            INF_CloseOpportunityController.getCodes(acc.Id);
        }
        Test.stopTest();
    }

    @isTest
    static void getDataTestOk4(){
        User u =  [SELECT Id, Name, Societa__c FROM User WHERE LastName = 'Testing'];
        u.Societa__c = 'Sixtema';
        update u;
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount1'];

        Test.startTest();
        System.runAs(u){
            INF_CloseOpportunityController.getCodes(acc.Id);
        }
        Test.stopTest();
    }

    @isTest
    static void getDataTestKo(){
        User u =  [SELECT Id, Name FROM User WHERE LastName = 'Testing'];

        // Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount1'];

        Test.startTest();
        System.runAs(u){
            INF_CloseOpportunityController.getCodes(null);
        }
        Test.stopTest();
    }

    @isTest
    static void getDataTestNew(){

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
            INF_CloseOpportunityController.getCodesNew(opp.Id);
        Test.stopTest();
    }

    // @isTest
    // static void updateRecordKO(){

    //     Test.startTest();
    //         INF_CloseOpportunityController.updateRecord(null, '1234');
    //     Test.stopTest();
    // }
}