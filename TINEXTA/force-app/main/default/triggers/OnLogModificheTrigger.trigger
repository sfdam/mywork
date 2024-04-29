trigger OnLogModificheTrigger on Approvazioni__c (after insert, after update) {
    
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disabilita_tutti_i_trigger__c)return;
    
    if(trigger.isAfter && trigger.isInsert){
        OnLogModificheTriggerHandler.mandaInApprovazioneWarrant(trigger.newMap);
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        OnLogModificheTriggerHandler.mandaInApprovazioneWarrant(trigger.newMap);
        //OnLogModificheTriggerHandler.ApprovazioneForo2Legal(trigger.oldmap, trigger.newmap);
    }

}