/**
 * Name			:	onUserTrigger
 * Author		:	Ezio Dal Bo @TEN
 * Create Date	:	2020-09-21
 * --------------------------------
 * Modify Date	:	2020-11-12
 * Author		:	Ezio Dal Bo @TEN
 * Modify		:	added logic to set flag on user and add permission sets  
 **/
trigger OnUserTrigger on User (after update,after insert,before insert,before update) {
    
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_UserTrigger__c) return;

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            OnUserTriggerHandler.beforeInsert(trigger.new);
        }
        else if (Trigger.isUpdate) {
            OnUserTriggerHandler.beforeUpdate(trigger.new,Trigger.oldMap);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            OnUserTriggerHandler.afterInsert(trigger.new);
        }
        else if (Trigger.isUpdate) {
            OnUserTriggerHandler.afterUpdate(trigger.new,Trigger.oldMap);
        }
    }
}