/****
 * Name         :   onAssenzeTrigger
 * Created Date :   2023-13-06
 * Author       :   Lorenzo Vento @TEN
 ****/

 trigger onAssenzeTrigger on CRM_Assenze__c (after insert, after update) {
    Funzionalita__c f = Funzionalita__c.getInstance();

    if (Trigger.isAfter && Trigger.isInsert) {
        if (!f.isETL__c && onAssenzeTriggerHandler.isFirstTime) {   
            onAssenzeTriggerHandler.genesysQueueCallout(Trigger.newMap);
            Set<Id> newAssenzeIds = new Set<Id>();
            for (CRM_Assenze__c newAssenza : Trigger.new) {
                newAssenzeIds.add(newAssenza.Id);
            }
            Batch_onAssenzeTriggerHandler.runBatch(newAssenzeIds);
        }
    }
}