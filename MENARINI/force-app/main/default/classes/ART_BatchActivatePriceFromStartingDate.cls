/*
 * @author        : Matteo.Loprevite @ten | Roberto.Murgia @ten
 * @name		  : ART_BatchActivatePriceFromStartingDate 
 * @createDate    : 2023-03-10
 * @description   : Batch che crea una riga di PriceBookEntry nel caso in cui il FakePriceBookEntry__c abbia una THR_StartingDate__c risalente a oggi. 
 *                  Creando così la riga di PriceBookEntry.
 * 
 * 					
 * @ClassTest     : TODO
 */
global with sharing  class ART_BatchActivatePriceFromStartingDate implements Database.Batchable<SObject>,Schedulable {

    global List<sObject> start(Database.BatchableContext BC) {
        
        return   [SELECT IsActive__c,THR_Z1PC__c,THR_AccountsrKey__c,THR_Country__c,THR_Currency__c,THR_PriceBookKey__c,
                        THR_Division__c,THR_EndingDate__c,UnitPrice__c,THR_MaterialKey__c,THR_PriceBookEntryKey__c,
                        THR_PricingUnit__c,Product2__c,THR_SalesOrganization__c,THR_StartingDate__c,THR_UnitOfMeasure__c
                        ,UseStandardPrice__c,THR_ZPPU__c
                  FROM FakePricebookEntry__c 
                  WHERE THR_StartingDate__c = TODAY];
       
    }
    global void execute(SchedulableContext SC) {
        ART_BatchActivatePriceFromStartingDate batchFakePricebook = new ART_BatchActivatePriceFromStartingDate();
        Database.executeBatch(batchFakePricebook);
    }
    global void execute(Database.BatchableContext BC, List<FakePricebookEntry__c> scope) {
        
        Set<String> pricebookKeySet = new Set<String>();
        Map<String, Pricebook2> key2PricebookID = new Map<String, Pricebook2>();

        for(FakePricebookEntry__c fakeEntry : scope ){
            pricebookKeySet.add(fakeEntry.THR_PriceBookKey__c);
        }

        for(Pricebook2 pbook : [SELECT Id, THR_PriceBookKey__c 
                                FROM Pricebook2 
                                WHERE THR_PriceBookKey__c IN : pricebookKeySet]){
            key2PricebookID.put(pbook.THR_PriceBookKey__c, pbook);
        }

        List<PricebookEntry> listEntry = new  List<PricebookEntry>();
        
        for (FakePricebookEntry__c fakePricebookEntry : scope) {
            if(key2PricebookID.containsKey(fakePricebookEntry.THR_PriceBookKey__c)){
                generatePriceBookEntryFromFake (fakePricebookEntry, key2PricebookID.get(fakePricebookEntry.THR_PriceBookKey__c).Id,listEntry);
            }
        }

        if(!listEntry.isEmpty()){
            upsert listEntry THR_PriceBookEntryKey__c;
        }


    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Price Updated');

    }

    /**
     * @description                   Metodo che crea un istanza di PriceBookEntry sulla base del FakePricebookEntry__C
     * @param  fakeEntry              Riga di FakePricebookEntry__c obbligatoria per la costruzione del PricebookEntry
     * @param  pricebookId            Id del Pricebook obbligatorio per la costruzione del PricebookEntry
     * @param  pricebookEntryToUpdate Lista che aggiunge il PricebookEntry prima di effettuare l'upsert
     */ 
    private static void generatePriceBookEntryFromFake(FakePricebookEntry__c fakeEntry, Id pricebookId, List<PricebookEntry> pricebookEntryToUpdate){
        
		pricebookEntryToUpdate.add(new PricebookEntry(
            IsActive = fakeEntry.IsActive__c,
            THR_Z1PC__c= fakeEntry.THR_Z1PC__c,
            THR_AccountsrKey__c= fakeEntry.THR_AccountsrKey__c,
            THR_Country__c= fakeEntry.THR_Country__c,
            THR_Currency__c= fakeEntry.THR_Currency__c,
            THR_Division__c= fakeEntry.THR_Division__c,
            THR_EndingDate__c= fakeEntry.THR_EndingDate__c,
            UnitPrice= fakeEntry.UnitPrice__c,
            THR_MaterialKey__c= fakeEntry.THR_MaterialKey__c,
            Pricebook2Id= pricebookId,
            THR_PriceBookEntryKey__c = fakeEntry.THR_PriceBookEntryKey__c.contains('_') ? fakeEntry.THR_PriceBookEntryKey__c.split('_')[0] : fakeEntry.THR_PriceBookEntryKey__c,
            THR_PriceBookKey__c= pricebookId,
            THR_PricingUnit__c= fakeEntry.THR_PricingUnit__c,
            Product2Id= fakeEntry.Product2__c,
            THR_SalesOrganization__c= fakeEntry.THR_SalesOrganization__c,
            THR_StartingDate__c= fakeEntry.THR_StartingDate__c,
            THR_UnitOfMeasure__c= fakeEntry.THR_UnitOfMeasure__c,
            UseStandardPrice= fakeEntry.UseStandardPrice__c,
            THR_ZPPU__c  = fakeEntry.THR_ZPPU__c
        ));    
    }
}