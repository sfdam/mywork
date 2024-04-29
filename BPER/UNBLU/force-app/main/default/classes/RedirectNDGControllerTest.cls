@isTest
public with sharing class RedirectNDGControllerTest {

    @isTest static void urlRedirectionTest() {
        Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
        personAccount.CRM_NDG__c='1234';
        personAccount.FinServ__BankNumber__c='05387';
        insert personAccount;

        RedirectNDGController redRect = new RedirectNDGController();
        redRect.abi='05387';
        redRect.ndg='1234';
        redRect.urlRedirection();
        
        RedirectNDGController controller = new RedirectNDGController();       
        controller.urlRedirection(); 
    }
   
}