trigger FakePriceBookTrigger on FakePricebookEntry__c (after insert, after update) {
    
    Map<String, Pricebook2> key2PricebookID = new Map<String, Pricebook2>();
    Set<String> pricebookKeySet = new Set<String>();
    List<PricebookEntry> pricebookEntryToUpdate = new List<PricebookEntry>();
    List<Pricebook2> pricebookToInsert = new List<Pricebook2>();
    Set<String> newPricebookEntryKey = new Set<String>();
    // Set<String> priceBookEntryFakeId = new Set<String>();
    ////////////////////////Gestione Feature Pricing DE - 039//////////////////////
    //R.M DE-039 10/11/2023 START
    if(UtilityFunctions.isTriggerDeactive( trigger.isDelete ? trigger.old.getSObjectType().getDescribe().getName() : trigger.new.getSObjectType().getDescribe().getName())){
         return;        
    }
    //R.M DE-039 10/11/2023 END
    //
    for(FakePricebookEntry__c fakeEntry : Trigger.New ){
        pricebookKeySet.add(fakeEntry.THR_PriceBookKey__c);
        // priceBookEntryFakeId.add(fakeEntry.THR_PriceBookEntryKey__c);
    }
        
    for(Pricebook2 pbook : [SELECT Id, THR_PriceBookKey__c FROM Pricebook2 WHERE THR_PriceBookKey__c IN : pricebookKeySet]){
        key2PricebookID.put(pbook.THR_PriceBookKey__c, pbook);
    }
    
    for(FakePricebookEntry__c fakeEntry : Trigger.New ){      
        if(!key2PricebookID.containsKey(fakeEntry.THR_PriceBookKey__c)){
            newPricebookEntryKey.add(fakeEntry.THR_PriceBookKey__c);
        }     
    }
    
    for(String pbkey : newPricebookEntryKey){
        pricebookToInsert.add(new Pricebook2(
                Name = pbkey,
                THR_PriceBookKey__c = pbkey               
        ));  
    }
    
    upsert pricebookToInsert THR_PriceBookKey__c;
    
    for(Pricebook2 pbook : [SELECT Id, THR_PriceBookKey__c FROM Pricebook2 WHERE THR_PriceBookKey__c IN : pricebookKeySet]){
        key2PricebookID.put(pbook.THR_PriceBookKey__c, pbook);
    }
    
    for(FakePricebookEntry__c fakeEntry : Trigger.New ){
        //pricebookEntryToUpdate.add(generatePriceBookEntryFromFake(fakeEntry, key2PricebookID.get(fakeEntry.THR_PriceBookKey__c).Id ));
        // DE - 039
        generatePriceBookEntryFromFake(fakeEntry, key2PricebookID.get(fakeEntry.THR_PriceBookKey__c).Id, pricebookEntryToUpdate);
    }
    
    if(!pricebookEntryToUpdate.isEmpty()){ // DE - 039
        upsert pricebookEntryToUpdate THR_PriceBookEntryKey__c;
    }

    private static void generatePriceBookEntryFromFake(FakePricebookEntry__c fakeEntry, Id pricebookId, List<PricebookEntry> pricebookEntryToUpdate){
        
		PricebookEntry anEntry = new PricebookEntry();
        anEntry.IsActive = fakeEntry.IsActive__c;

        // DE-121
        if(Trigger.isUpdate) {
            Decimal oldPrice = Trigger.oldMap.get(fakeEntry.Id).UnitPrice__c;
            if(oldPrice != fakeEntry.UnitPrice__c){
                anEntry.IsActive = true;
            }
        }

        anEntry.THR_Z1PC__c = fakeEntry.THR_Z1PC__c;
        anEntry.THR_AccountsrKey__c = fakeEntry.THR_AccountsrKey__c;
        anEntry.THR_Country__c = fakeEntry.THR_Country__c;
        anEntry.THR_Currency__c = fakeEntry.THR_Currency__c;
        anEntry.THR_Division__c = fakeEntry.THR_Division__c;
        anEntry.THR_EndingDate__c = fakeEntry.THR_EndingDate__c;
        anEntry.UnitPrice = fakeEntry.UnitPrice__c;
        anEntry.THR_MaterialKey__c = fakeEntry.THR_MaterialKey__c;
        anEntry.Pricebook2Id = pricebookId;
        //DE - 039
        //anEntry.THR_PriceBookEntryKey__c = fakeEntry.THR_PriceBookEntryKey__c;
        String EntryKey = fakeEntry.THR_PriceBookEntryKey__c.contains('_') ? fakeEntry.THR_PriceBookEntryKey__c.split('_')[0] : fakeEntry.THR_PriceBookEntryKey__c;
        anEntry.THR_PriceBookEntryKey__c= EntryKey;

        anEntry.THR_PriceBookKey__c = pricebookId;
        anEntry.THR_PricingUnit__c = fakeEntry.THR_PricingUnit__c;
        anEntry.Product2Id = fakeEntry.Product2__c;
        anEntry.THR_SalesOrganization__c = fakeEntry.THR_SalesOrganization__c;
        anEntry.THR_StartingDate__c = fakeEntry.THR_StartingDate__c;
        anEntry.THR_UnitOfMeasure__c = fakeEntry.THR_UnitOfMeasure__c;
        anEntry.UseStandardPrice = fakeEntry.UseStandardPrice__c;
		anEntry.THR_ZPPU__c = fakeEntry.THR_ZPPU__c;

        // DE - 039
        if((System.Today() >= fakeEntry.THR_StartingDate__c && fakeEntry.THR_PriceBookEntryKey__c.contains('_')) || !fakeEntry.THR_PriceBookEntryKey__c.contains('_')){
            pricebookEntryToUpdate.add(anEntry);
        }
        //return anEntry;
    }
    
}