@isTest 
private class INF_SendMail_Test {
	@isTest static void testSend(){
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        insert x;
        
    	List<Account> accList= TestDataFactory.createAccounts(1);
        accList[0].Responsabile_Infocert__c = UserInfo.getUserId();
        accList[0].WRT_Codice_IBAN__c = 'IT60X0542811101000000123457';
        insert accList;
        Slave_Data__c slave = new Slave_Data__c(Account__c = accList[0].Id,
                                               Codice_Cliente_X3__c = 'Test',
                                               Id_Esterno__c = 'Test');
        insert slave;
        List<Opportunity> oppList = TestDataFactory.createOpportunity(accList);
        List<OpportunityLineItem> oppItemList = new List<OpportunityLineItem>();
        insert oppList;
        List<OpportunityLineItemSchedule> oppschedList = new List<OpportunityLineItemSchedule>();
    	Map<Id,OpportunityLineItemSchedule> oppschedMap = new Map<Id,OpportunityLineItemSchedule>();
        
        
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
            for(integer i =0; i<1;i++){
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
           for (OpportunityLineItem item: oppItemList){
             	for(integer i =0; i<3;i++){
                	OpportunityLineItemSchedule sch = new OpportunityLineItemSchedule(OpportunityLineItemId = item.Id,
                                                                                      Type = 'Revenue',
                                                                                     Revenue =3750,
                                                                                     Description = 'test',
                                                                                     ScheduleDate = Date.today(), 
                                                                                      Fatturabile__c = true
                                                                                     );
                    oppschedList.add(sch);               
            	}                   
        	}
        insert oppschedList;
    	for(OpportunityLineItemSchedule sch : oppschedList){
        	oppschedMap.put(sch.Id,sch);
    	}
    	INF_SendMail.sendOppScheduleMail(oppschedMap);
	}
}