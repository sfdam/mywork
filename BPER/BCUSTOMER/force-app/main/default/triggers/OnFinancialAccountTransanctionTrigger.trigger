/****
 * Name			:	OnFinancialAccountTransanctionTrigger
 * Create date	:	2020-09-25
 * Author		:	Ezio Dal Bo @TEN
 ****/
trigger OnFinancialAccountTransanctionTrigger on FinServ__FinancialAccountTransaction__c (after insert,after update, after delete) {

    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_FinancialAccountTrigger__c) return;
    
    if (Trigger.isBefore) {
        // nothing to do
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            OnFinAccountTransanctionTriggerHandler.afterInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            OnFinAccountTransanctionTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
        else if (Trigger.isDelete) {
            OnFinAccountTransanctionTriggerHandler.afterDelete(Trigger.old);
        }
    }
}