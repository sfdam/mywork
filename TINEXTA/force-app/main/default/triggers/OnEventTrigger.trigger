trigger OnEventTrigger on Event (before insert, after insert, before update, after update, before delete) {
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disabilita_tutti_i_trigger__c)return;

    if(Trigger.isInsert){
        if(Trigger.isBefore){
            OnActivityTriggerHandler.setEventLocation(Trigger.new);
             OnActivityTriggerHandler.alignLookups(Trigger.new);
            OnActivityTriggerHandler.InsertDataVisita(Trigger.new);
            OnActivityTriggerHandler.setEventSubject(Trigger.new);
        }
        if(Trigger.isAfter){
            OnActivityTriggerHandler.alignOutcome(true,Trigger.newMap, Trigger.oldMap);
            OnActivityTriggerHandler.UpdateLeadReferenza(Trigger.new);
            OnActivityTriggerHandler.UpdateAccountReferenza(trigger.new);
            
        }
    }
    if(Trigger.isUpdate){
         if(Trigger.isBefore){
           OnActivityTriggerHandler.alignLookups(Trigger.new);
             OnActivityTriggerHandler.InsertDataVisita(Trigger.new);
        }
        if(Trigger.isAfter){
         OnActivityTriggerHandler.alignOutcome(false, Trigger.newMap, Trigger.oldMap);
        }
    }
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            OnActivityTriggerHandler.validateDelete(Trigger.old);
        }
    }
    // if(Trigger.isUpdate){
    //     if(Trigger.isBefore){
    //         OnActivityTriggerHandler.validateDelete(Trigger.new);
    //     }
    // }
}