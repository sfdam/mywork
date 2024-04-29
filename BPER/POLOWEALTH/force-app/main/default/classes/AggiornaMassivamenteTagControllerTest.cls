/**
 * @description       : 
 * @author            : alessandro.dinardo@lutech.it
 * @group             : tengroup
 * @last modified on  : 24-01-2024
 * @last modified by  : alessandro.dinardo@lutech.it
 * description        : class test per AggiornaMassivamenteTagController
**/


@isTest
public  class AggiornaMassivamenteTagControllerTest {
    
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
        AggiornaMassivamenteTagController.executeBatchUpdate('LANTERNINA','test');
        Test.stopTest();
    }
    @isTest
    public static void noTAGselected(){
 
		Test.StartTest(); 
        AggiornaMassivamenteTagController.executeBatchUpdate('','test');
        Test.stopTest();
    }
    @isTest
    public static void getBatchJobStatusTest(){
 
		Test.StartTest(); 
        AggiornaMassivamenteTagController.getBatchJobStatus();
        Test.stopTest();
    }

    @isTest
    public static void getDateBatchCompletedTest(){
 
		Test.StartTest(); 
        AggiornaMassivamenteTagController.getDateBatchCompleted();
        Test.stopTest();
    }

}