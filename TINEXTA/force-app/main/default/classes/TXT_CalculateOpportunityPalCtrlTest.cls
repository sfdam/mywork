@isTest
public without sharing class TXT_CalculateOpportunityPalCtrlTest {

    @TestSetup
    static void makeData(){
        Funzionalita__c f = new Funzionalita__c(
            Disabilita_tutti_i_trigger__c = true,
            Bypass_Validation_Rules__c = true
        );

        insert f;

       List<Account> accList = TestDataFactory.createAccounts(1);   
        accList[0].Codice_fiscale__c = '29384729837';
       	accList[0].Partita_iva__c = '29384729837';
        accList[0].Stato__c = 'Prospect';
        insert accList;
        List<Opportunity> oppList = TestDataFactory.createOpportunity(accList);
        for(Opportunity opp : oppList){
            opp.StageName = 'Prospecting';
        }
        insert oppList;
        List<OpportunityLineItem> oppItemList = new List<OpportunityLineItem>();
        
        f.Disabilita_tutti_i_trigger__c=false;
        update f;

        Product2 prod = new Product2(Name = 'Laptop X200', 
            						 Family = 'Hardware',
                                     CanUseRevenueSchedule=true);
        insert prod;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;

        for (Opportunity opp: oppList){
            // for(integer i =0; i<3;i++){
            	OpportunityLineItem item = new OpportunityLineItem(OpportunityId = opp.Id,
                                                               		Description = 'Test',
                                                              		Quantity= 5,
                                                                   TotalPrice = 34555,
                                                                   PricebookEntryId = standardPrice.Id
                                                                  );
                oppItemList.add(item);
            // }
        }

        insert oppItemList;
    }

    @isTest
    static void testCalculateOk(){

        Test.startTest();
            TXT_CalculateOpportunityPalCtrl.calculate([SELECT Id FROM Account LIMIT 1].Id);
        Test.stopTest();
    }

}