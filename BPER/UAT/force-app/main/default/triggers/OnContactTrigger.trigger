trigger OnContactTrigger on Contact (after insert, after update, before delete,before insert,before update) {

    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_ContactTrigger__c) return;

    if(trigger.isInsert){
        if(trigger.isBefore){
            System.debug('SV Wallet INSERT trigger.isBefore');
            OnContactTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        
        if(trigger.isAfter){
            System.debug('SV Wallet INSERT trigger.isAfter');
            OnContactTriggerHandler.handleAfterInsert(Trigger.new);
        }        
    }

    if(trigger.isUpdate){
        if(trigger.isBefore){
            OnContactTriggerHandler.handleBeforeUpdate(trigger.new, trigger.oldMap);
        }
        if(trigger.isAfter){
            System.debug('SV Wallet INSERT trigger.isAfter');
            OnContactTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }        
    }

    if(trigger.isDelete){

        if(trigger.isBefore){
            System.debug('SV Wallet UPDATE trigger.isBefore');
            OnContactTriggerHandler.handleBeforeDelete(Trigger.old);
        }
    }
}