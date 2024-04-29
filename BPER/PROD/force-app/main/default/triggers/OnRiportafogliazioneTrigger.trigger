trigger OnRiportafogliazioneTrigger on Riportafogliazione__c (before insert, before update) {
    if(Trigger.isInsert && Trigger.isBefore){
        OnRiportafogliazioneTriggerHandler.populateLookup(Trigger.new, Trigger.oldMap, 'Insert');
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        OnRiportafogliazioneTriggerHandler.populateLookup(Trigger.new, Trigger.oldMap, 'Update');
    }
}