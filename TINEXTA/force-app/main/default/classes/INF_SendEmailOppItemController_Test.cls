@isTest
private class INF_SendEmailOppItemController_Test {
	@isTest static void testGetData(){
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        insert x;
        List<Account> accList= TestDataFactory.createAccounts(1);
        insert accList;
        List<Opportunity> oppList = TestDataFactory.createOpportunity(accList);
        List<OpportunityLineItem> oppItemList = new List<OpportunityLineItem>();
        insert oppList;
        List<OpportunityLineItemSchedule> oppschedList = new List<OpportunityLineItemSchedule>();
        
        
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
                                                                //    Unique_Product_Id__c = 'testtesttest123123'
                                                                  );
                oppItemList.add(item);
            // }
         }
           insert oppItemList;
           for (OpportunityLineItem item: oppItemList){
             	// for(integer i =0; i<3;i++){
                	OpportunityLineItemSchedule sch = new OpportunityLineItemSchedule(OpportunityLineItemId = item.Id,
                                                                                      Type = 'Revenue',
                                                                                     Revenue =3750,
                                                                                     Description = 'test',
                                                                                     ScheduleDate = Date.today(), 
                                                                                      Fatturabile__c = true
                                                                                     );
                    oppschedList.add(sch);               
            	// }                   
        	}
        insert oppschedList;
        boolean saved = INF_SendEmailOppItemComponentController.SaveItems(JSON.serialize(oppschedList), false);
        
        INF_SendEmailOppItemComponentController.WrapperResponse wrap = new INF_SendEmailOppItemComponentController.WrapperResponse();
        wrap = INF_SendEmailOppItemComponentController.getData(oppList[0].Id);
    }
    

    
}