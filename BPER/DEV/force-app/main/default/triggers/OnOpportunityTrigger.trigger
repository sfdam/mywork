trigger OnOpportunityTrigger on Opportunity (after insert, after update, after delete) {
    
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_OpportunityTrigger__c) return;

    if(Trigger.isInsert){
        
        if(Trigger.isAfter){
            //OnOpportunityTriggerHandler.publishEvent(Trigger.new,  Trigger.oldMap);
            // INTEGRAZIONE ()
            OnOpportunityTriggerHandler.makeCallOpportunity(Trigger.oldMap, Trigger.newMap);
            OnOpportunityTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);
        }
        
        if(Trigger.isBefore){
            if(f.isMC__c || f.isUnecapi__c){
                OnOpportunityTriggerHandler.updateOpp(Trigger.new);
            }
        }
    }

    if(Trigger.isUpdate){
        if(Trigger.isAfter){
            // OnOpportunityTriggerHandler.publishEvent(Trigger.new,  Trigger.oldMap);
            OnOpportunityTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);
        }
    }
    /*
    if(trigger.isDelete){
        if(trigger.isAfter){
            OnOpportunityTriggerHandler.publishEvent(Trigger.old,  Trigger.oldMap);
        }
    }*/
}