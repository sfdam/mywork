trigger OnDelegaTrigger on Delega__c (before insert, before update) {

    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;

    if(trigger.isInsert){
        if(trigger.isBefore){
            OnDelegaTriggerHandler.handleBeforeInsert(trigger.new);
        }
    }

    if(trigger.isUpdate){
        if(trigger.isBefore){
            OnDelegaTriggerHandler.handleBeforeUpdate(trigger.new, Trigger.oldMap);
        }
    }
}