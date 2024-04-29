trigger SegnalazioneTrigger on Segnalazione__c (before insert, before update) {

    if(Trigger.isBefore && Trigger.isInsert) {
    	SegnalazioneTriggerHandler.handleDateSlaSegnalazioni(Trigger.new);    
    }
    
    if(Trigger.isUpdate && Trigger.isBefore) {
        SegnalazioneTriggerHandler.handleDateSlaSegnalazioni(Trigger.new);
    }
    
}