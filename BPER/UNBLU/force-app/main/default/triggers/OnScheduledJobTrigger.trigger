/***
 * Name         :   OnScheduledJobTrigger
 * Author       :   Ezio Dal Bo @TEN
 * Create Date  :   2020-10-13
 ***/
trigger OnScheduledJobTrigger on ScheduledJob__c (before insert,after insert,before update,after update) {
    
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_ScheduledJobTrigger__c) return;
    
    if(trigger.isInsert && Trigger.isBefore){
        OnScheduledJobTriggerHandler.BeforeInsert(Trigger.new);
    }
    if(trigger.isInsert && Trigger.isAfter){
        OnScheduledJobTriggerHandler.AfterInsert(Trigger.new);
    }
    if(trigger.isUpdate && Trigger.isBefore){
        OnScheduledJobTriggerHandler.BeforeUpdate(Trigger.new);
    }
    if(trigger.isUpdate && Trigger.isAfter){
        OnScheduledJobTriggerHandler.AfterUpdate(Trigger.new);
    }
}