/**
 * @description       : 
 * @author            : alessandro.dinardo@lutech.it
 * @group             : tengroup
 * @last modified on  : 26-01-2024
 * @last modified by  : alessandro.dinardo@lutech.it
 * description        : class test per Batch_AggiornaMassivamenteTag
**/

@isTest
public  class Batch_AggiornaMassivamenteTagTest {
     

    @TestSetup
    static void makeData(){
        
        Account acct2 = new Account (Name = 'ACE Chemicals', ModelloDiServizio__c = 'Family', CRM_NDG__c = '112358',PTF_RiportafogliazioneTAG__c = 'LANTERNINA' );
        insert acct2;
    }

    @isTest
    public static void executeBatchException(){
 
		Test.StartTest(); 
        Batch_AggiornaMassivamenteTag batch = new Batch_AggiornaMassivamenteTag('LANTERNINA','test');
        batch.sendEmailError = true;
        Database.executeBatch(batch,200);
        Test.stopTest();
    }
}