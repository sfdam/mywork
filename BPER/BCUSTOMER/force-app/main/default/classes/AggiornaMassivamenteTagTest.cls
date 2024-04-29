/**
 * @description       : 
 * @author            : alessandro.dinardo@lutech.it
 * @group             : tengroup
 * @last modified on  : 24-01-2024
 * @last modified by  : alessandro.dinardo@lutech.it
 * description        : class test per AggiornaMassivamenteTag
**/


@isTest
public  class AggiornaMassivamenteTagTest {
    
    @TestSetup
    static void makeData(){
        
        Id profId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Amministratore del sistema'][0].Id;

        Account acct2 = new Account (Name = 'ACE Chemicals', ModelloDiServizio__c = 'Family', CRM_NDG__c = '112358',PTF_RiportafogliazioneTAG__c = 'LANTERNINA' );
        insert acct2;

        User u = new User(Alias = 'standt', Email= 'test22@gmail.it', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profId, 
        TimeZoneSidKey='America/Los_Angeles', UserName='test22@gmail.it');

        insert u;
    }

    @isTest
    public static void executeBatchUpdateTest(){
 
		Test.StartTest(); 
        AggiornaMassivamenteTag.executeBatchUpdate('LANTERNINA','test');
        Test.stopTest();
    }
    @isTest
    public static void noTAGselected(){
 
		Test.StartTest(); 
        AggiornaMassivamenteTag.executeBatchUpdate('','test');
        Test.stopTest();
    }
    @isTest
    public static void getBatchJobStatusTest(){
 
		Test.StartTest(); 
        AggiornaMassivamenteTag.getBatchJobStatus();
        Test.stopTest();
    }

    @isTest
    public static void getJobQueryResultTest(){
 

        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpAggiornaMassivamenteTagQueueable());
        AggiornaMassivamenteTag.getJobQueryResult();
        Test.stopTest();
    }

    @isTest
    public static void getIntegrationUserTest(){
 
        Test.StartTest();
        AggiornaMassivamenteTag.getIntegrationUser();
        Test.stopTest();
    }

    
    
    /*
    @isTest
    public static void executeBatchUpdate(){

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');
		Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        AggiornaMassivamenteTag.executeBatchUpdate('LANTERNINA','test');
        Test.stopTest();
    }
    
    */
}