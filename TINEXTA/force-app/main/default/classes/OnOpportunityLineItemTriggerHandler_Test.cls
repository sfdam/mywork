@isTest
public class OnOpportunityLineItemTriggerHandler_Test {
    
    @isTest 
    static void testMakeOpportunityLineItem(){
        Funzionalita__c x = new Funzionalita__c();
        x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_tutti_i_trigger__c = true;
        x.Disabilita_Integrazione__c = true;
        x.Bypass_Validation_Rules__c=true;
        insert x;
        
        
        //Id WRT_Profile = [SELECT Id FROM Profile WHERE Name = 'Warrant Hub - System Administrator'].Id;
        //User WRT_User = TestDataFactory.create_User(WRT_Profile);
        //WRT_User.Societa__c = 'Warrant';
        //insert WRT_User;
        User WRT_User = [SELECT Id FROM  User WHERE IsActive = true AND Profile.Name = 'Warrant Hub - System Administrator' LIMIT 1];
        
        
        Test.startTest();
        System.runAs(WRT_User) {
            
            Account[] acc = TestDataFactory.createAccounts(1);
            insert acc;
            
            Opportunity[] oppList = TestDataFactory.createOpportunity(acc);
            //oppList[0].WH_Business_Area__c = 'FA TEST';
            oppList[0].Anno_di_competenza__c = '2020';
            insert oppList;
            
            List<OpportunityLineItem> oppItemList = new List<OpportunityLineItem>();
            
            Product2 prod = new Product2(Name = 'Laptop X200', 
                                         Family = 'Hardware',
                                         CanUseRevenueSchedule=true,
                                         Societ__c= 'WarrantHub');
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
                for(integer i =0; i<3;i++){
                    OpportunityLineItem item = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                       Description = 'Test',
                                                                       Quantity= 5,
                                                                       TotalPrice = 34555,
                                                                       PricebookEntryId = standardPrice.Id
                                                                      );
                    oppItemList.add(item);
                }
            }
            insert oppItemList;
            
            x.Disabilita_tutti_i_trigger__c = false;
            update x;            
            
            List<OpportunityLineItem> oppLineItemUpdateList = [SELECT id, Description FROM OpportunityLineItem LIMIT 1];
            oppLineItemUpdateList[0].Description = 'TEST';
            update oppLineItemUpdateList[0];
        }
        Test.stopTest(); 
    }
    
    
  @isTest 
    static void testNumberOpportunityLineItem(){
        Funzionalita__c x = new Funzionalita__c();
        x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_tutti_i_trigger__c = true;
        x.Disabilita_Integrazione__c = true;
        x.Bypass_Validation_Rules__c=true;
        insert x;
        
       //Id WRT_Profile = [SELECT Id FROM Profile WHERE Name = 'Warrant Hub - System Administrator'].Id;
       // User WRT_User = TestDataFactory.create_User(WRT_Profile);
       // WRT_User.Societa__c = 'Warrant';
        //insert WRT_User;
       
         User WRT_User = [SELECT Id FROM  User WHERE IsActive = true AND Profile.Name = 'Warrant Hub - System Administrator' LIMIT 1];
        Test.startTest();
        System.runAs(WRT_User) {
        Account[] acc = TestDataFactory.createAccounts(1);
        insert acc;
            
        
        
        Opportunity[] oppList = TestDataFactory.createOpportunityWarrant(acc);
        //oppList[0].WH_Business_Area__c = 'FA TEST';
        oppList[0].Anno_di_competenza__c = '2020';
        insert oppList;


        List<OpportunityLineItem> oppItemList = new List<OpportunityLineItem>();
            
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware',
                                     CanUseRevenueSchedule=true,
                                     Societ__c= 'WarrantHub');
        insert prod;
            
        Id pricebookId = Test.getStandardPricebookId();
            
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
        											        Pricebook2Id = pricebookId, 
            												Product2Id = prod.Id,
            												UnitPrice = 10000,
            												IsActive = true);
           insert standardPrice;
           Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
            insert customPB;
            
         // 2. Insert a price book entry with a custom price.
         PricebookEntry customPrice = new PricebookEntry(
         											     	Pricebook2Id = customPB.Id, 
             												Product2Id = prod.Id,
             												UnitPrice = 12000, 
             												IsActive = true);
            insert customPrice;
        
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
        
        OpportunityLineItem item = new OpportunityLineItem(OpportunityId = oppList[0].Id,
                                                           Description = 'Test',
                                                           Quantity= 5,
                                                           TotalPrice = 34555,
                                                           PricebookEntryId = standardPrice.Id
                                                                      );
            insert item;
        
        
    }
                
        Test.stopTest(); 
    }
    
}