/**
 *  Name        :   OnTaskTrigger
 * Description  :   Manage event on sObject Task
 * Create date  :   2020-09-25
 * Author       :   Ezio Dal Bo @TEN
**/
trigger OnEventTrigger on Event (after insert, after update, after delete, before insert) {

    Funzionalita__c f = Funzionalita__c.getInstance(); 
    if (f.Disable_Trigger__c) return;
    if (f.Disable_EventTrigger__c) return;
    if (OnEventTriggerHandler.skipEventTrigger) return;

    if (Trigger.isBefore) {
        OnEventTriggerHandler.updateWhoId(Trigger.new);
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            OnEventTriggerHandler.afterInsert(Trigger.new);
            OnEventTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);
        }
        else if (Trigger.isUpdate) {
            OnEventTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
            OnEventTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);
            OnEventTriggerHandler.checkRicontatto(Trigger.new, Trigger.oldMap);
        }
        else if (Trigger.isDelete) {
            OnEventTriggerHandler.afterDelete(Trigger.old);
        }
    }
}