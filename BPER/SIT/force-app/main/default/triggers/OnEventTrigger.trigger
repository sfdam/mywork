/**
 *  Name        :   OnTaskTrigger
 * Description  :   Manage event on sObject Task
 * Create date  :   2020-09-25
 * Author       :   Ezio Dal Bo @TEN
**/
trigger OnEventTrigger on Event (after insert, after update, after delete) {

    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_EventTrigger__c) return;

    if (Trigger.isBefore) {
        // Actually nothing to do
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            OnEventTriggerHandler.afterInsert(Trigger.new);
            OnEventTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);
        }
        else if (Trigger.isUpdate) {
            OnEventTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
            OnEventTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);
        }
        else if (Trigger.isDelete) {
            OnEventTriggerHandler.afterDelete(Trigger.old);
        }
    }
}