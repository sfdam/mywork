trigger QuoteLineTrigger on SBQQ__QuoteLine__c (before insert, before update, after insert, after update, after delete, after undelete) {
    if(!Trigger.isUpdate)
    {
        QuoteLine_TriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }else{
        
        boolean procedi = false;
        for(SBQQ__QuoteLine__c ql:Trigger.new){
            if(!QuoteLine_TriggerHandler.setQLUsed.contains(ql.Id)) {procedi = true; break;}
        }
        
        if(procedi) {QuoteLine_TriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);} 

        if(Trigger.isAfter){
            for(SBQQ__QuoteLine__c ql:Trigger.new){
                QuoteLine_TriggerHandler.setQLUsed.add(ql.Id);
            }
        }        
    }
}