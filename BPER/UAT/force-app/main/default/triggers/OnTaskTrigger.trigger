/**
 *  Name        :   OnTaskTrigger
 * Description  :   Manage event on sObject Task
 * Create date  :   2020-09-25
 * Author       :   Ezio Dal Bo @TEN
**/
trigger OnTaskTrigger on Task (after insert, after update, after delete) {

    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_TaskTrigger__c) return;

    if (Trigger.isBefore) {
        // Actually nothing to do
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            OnTaskTriggerHandler.afterInsert(Trigger.new);
            OnTaskTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);

        }
        else if (Trigger.isUpdate) {
            OnTaskTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
            OnTaskTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);
        }
        else if (Trigger.isDelete) {
            OnTaskTriggerHandler.afterDelete(Trigger.old);
        }
    }
}