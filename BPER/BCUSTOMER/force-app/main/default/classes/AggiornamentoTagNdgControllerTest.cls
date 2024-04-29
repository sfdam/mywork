/**
 * @description       : 
 * @author            : alessandro.dinardo@lutech.it
 * @group             : tengroup
 * @last modified on  : 22-01-2024
 * @last modified by  : alessandro.dinardo@lutech.it
 * desciption         : AggiornamentoTagNdg
**/
@isTest
public class AggiornamentoTagNdgControllerTest {

    @TestSetup
    static void makeData(){
        
        Account acct2 = new Account (Name = 'ACE Chemicals', ModelloDiServizio__c = 'Family', CRM_NDG__c = '112358');
        insert acct2;
    }

    @isTest
    static void testGetNdgFromAccount(){

        List<Account> account = [select id from Account LIMIT 1];

        Test.startTest();
        AggiornamentoTagNdgController.getNdgFromAccount(account[0].id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetNdgFromAccountException(){

        List<Account> account = [select id from Account LIMIT 1];

        Test.startTest();
        AggiornamentoTagNdgController.getNdgFromAccount('test');
        Test.stopTest();
    }

    @isTest
    static void testUpdateNdgValue(){

        List<Account> account = [select id from Account LIMIT 1];

        Test.startTest();
        AggiornamentoTagNdgController.updateNdgValue(account[0].id,'test');
        Test.stopTest();
    }
}