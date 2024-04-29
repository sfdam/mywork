trigger TrackingSegnalazioneTrigger on Tracking_segnalazione__c (before update) {
    if(Trigger.isUpdate && Trigger.isBefore) {
        SegnalazioneTriggerHandler.sla(Trigger.new);
    }
}