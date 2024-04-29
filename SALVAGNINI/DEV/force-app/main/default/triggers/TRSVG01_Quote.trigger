trigger TRSVG01_Quote on SBQQ__Quote__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    
    if(!APSVG01_QuoteHandler.recursion){
        APSVG01_QuoteHandler.recursion = true;
        APSVG01_QuoteHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}