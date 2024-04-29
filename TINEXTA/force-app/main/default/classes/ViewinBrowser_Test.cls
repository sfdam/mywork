@isTest
public with sharing class ViewinBrowser_Test {
    @TestSetup
    static void makeData(){
        Account acc = new Account(Name = 'TestContrattoEcobonus');
        acc.Censimento_Manuale__c=true;
        insert acc;
        Contact cnt = new Contact(FirstName = 'Test', LastName = 'Ecobonus1', AccountId = acc.Id);
        insert cnt;

        Opportunity opp = new Opportunity(Name = 'PRIVATOTEST', 
                                          AccountId = acc.Id, 
                                          ContactId = cnt.Id, 
                                          StageName = 'Closed/Won', 
                                          CloseDate = System.Today(), 
                                          Amount=1000, 
                                          WRT_TagDinamica__c = 'Ecobonus Privato - con acquisto'
                                           );
        insert opp;
        
        WRT_Transazione__c trans = new WRT_Transazione__c (Opportunit__c=opp.Id,
                                                           Cognome_del_Cliente__c = 'TEST 1',
                                                           Nome_del_Cliente__c = 'Test'
        );
        insert trans;
    }
    
    @isTest
    public static void costruttoreTest(){

        WRT_Transazione__c opp = [SELECT Id FROM WRT_Transazione__c WHERE Cognome_del_Cliente__c = 'TEST 1'  LIMIT 1];
        

        PageReference pageRef = Page.ViewinBrowser;
        pageRef.getParameters().put('id', opp.Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
            ViewinBrowser c = new ViewinBrowser();
        Test.stopTest();
    }

    

}