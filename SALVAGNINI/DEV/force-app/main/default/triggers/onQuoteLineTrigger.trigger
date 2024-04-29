trigger onQuoteLineTrigger on SBQQ__QuoteLine__c (after insert, before delete) {
    //darò per scontato che si possono modificare solo le righe di una Quote alla volta tramite QLE
    if(!(System.isFuture() || System.isQueueable())){
        if(trigger.isInsert && !QuoteLineTriggerHandler.hasAlreadyRan){
            QuoteLineTriggerHandler.hasAlreadyRan = true;
            string QuoteId = trigger.new[0].SBQQ__Quote__c;
            //QuoteLineTriggerHandler.handleAlternatives(QuoteId, null);
        }
        else if(trigger.isDelete && !QuoteLineTriggerHandler.hasAlreadyRan){
            QuoteLineTriggerHandler.hasAlreadyRan = true;
            string QuoteId = trigger.old[0].SBQQ__Quote__c;
            //QuoteLineTriggerHandler.handleAlternatives(QuoteId, JSON.SERIALIZE(trigger.oldMap));
        }
    }
}