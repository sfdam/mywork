trigger OnBudgetTrigger on Budget__c (before insert,after insert) {

    if(trigger.isInsert){
        if(trigger.isBefore){
            OnBudgetTriggerHandler.fillYearOnInsert(trigger.new);
        }else if(trigger.isAfter){
            OnBudgetTriggerHandler.insertBudgetLines(trigger.new);
        }
    }
}