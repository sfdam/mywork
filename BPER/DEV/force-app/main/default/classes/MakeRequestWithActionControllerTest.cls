@isTest
public with sharing class MakeRequestWithActionControllerTest {

    @isTest
    static void testInitInfo() {
        FinServ__FinancialAccount__c finAcc = new FinServ__FinancialAccount__c(Name = 'Test Account');
        List<FinServ__FinancialAccount__c> result = MakeRequestWithActionController.initInfo(finAcc.Id);    
           
    }
}