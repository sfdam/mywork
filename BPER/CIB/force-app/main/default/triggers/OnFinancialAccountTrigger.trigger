/**
 * Name         :   OnFinancialAccountTrigger
 * Create date  :   2020-09-25
 * Author       :   Ezio Dal Bo
**/
trigger OnFinancialAccountTrigger on FinServ__FinancialAccount__c (before insert, before update, after insert, after update, after delete) {

    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_FinancialAccountTrigger__c) return;
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            OnFinancialAccountTriggerHandler.beforeInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            OnFinancialAccountTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isDelete) {
            OnFinancialAccountTriggerHandler.afterDelete(Trigger.old);
            //OnFinancialAccountTriggerHandler.publishEvent(Trigger.old,  Trigger.oldMap);
        }
        else  if (Trigger.isInsert) {
            OnFinancialAccountTriggerHandler.afterInsert(Trigger.new);
            //OnFinancialAccountTriggerHandler.publishEvent(Trigger.new,  Trigger.oldMap);
        }
        else if (Trigger.isUpdate) {
            OnFinancialAccountTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
            //OnFinancialAccountTriggerHandler.publishEvent(Trigger.new,  Trigger.oldMap);
        }
    }
}