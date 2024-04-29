trigger TRSVG02_QuoteLine on SBQQ__QuoteLine__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    
    //if(!APSVG02_QuoteLineHandler.recursion){
        APSVG02_QuoteLineHandler.recursion = true;
        APSVG02_QuoteLineHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    //}
    
    
}