@isTest
public with sharing class ContrattoEcobonusCtrl_Test {

    @TestSetup
    static void makeData(){
        Account acc = new Account(Name = 'TestContrattoEcobonus');
        acc.Censimento_Manuale__c=true;
        insert acc;
        Contact cnt = new Contact(FirstName = 'Test', LastName = 'Ecobonus1', AccountId = acc.Id);
        insert cnt;

        Opportunity opp = new Opportunity(Name = 'PREFATTIBILITATEST', AccountId = acc.Id, ContactId = cnt.Id, StageName = 'Closed/Won', CloseDate = System.Today(), Amount=1000);
        insert opp;
        Product2 pro = new product2 (name = 'FAE - GREEN110',
                                     IsActive =true);
        
        insert pro ;
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pro.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        OpportunityLineItem item = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                       Description = 'Test',
                                                                       Quantity= 1,
                                                                       TotalPrice = 34555,
                                                                       PricebookEntryId = standardPrice.Id,
                                                          				Prezzo_con_IVA__c=40000
                                                                      );
        Insert item;
        
    }
    
    @isTest
    public static void costruttoreTest(){

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        PageReference pageRef = Page.ContrattoEcobonus;
        pageRef.getParameters().put('id', opp.Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
            ContrattoEcobonusCtrl c = new ContrattoEcobonusCtrl();
        Test.stopTest();
    }

    @isTest
    public static void getContrattoTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact cnt = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
            ContrattoEcobonusCtrl.getContratto(cnt.Id, opp.Id);
            try{

            } catch (AuraHandledException e){
                ContrattoEcobonusCtrl.getContratto(cnt.Id, null);
            }
        Test.stopTest();
    }

    @isTest
    public static void getContrattoBlobTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact cnt = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
            ContrattoEcobonusCtrl.getContrattoBlob(cnt.Id, opp.Id);
            try{

            } catch (AuraHandledException e){
                ContrattoEcobonusCtrl.getContrattoBlob(cnt.Id, null);
            }
        Test.stopTest();
    }

}