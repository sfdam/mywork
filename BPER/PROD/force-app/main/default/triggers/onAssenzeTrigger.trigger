/****
 * Name         :   onAssenzeTrigger
 * Created Date :   2023-13-06
 * Author       :   Lorenzo Vento @TEN
 ****/

 trigger onAssenzeTrigger on CRM_Assenze__c (after insert, before update, after update) {
    Funzionalita__c f = Funzionalita__c.getInstance();
    List<CRM_Assenze__c> recordsToUpdate = new List<CRM_Assenze__c>();
    
    if(Trigger.isBefore && Trigger.isUpdate) {
    
        for (CRM_Assenze__c oldRecord : Trigger.old) {
        
            CRM_Assenze__c newRecord = Trigger.newMap.get(oldRecord.Id);
            
            if (oldRecord.CRM_IsDeleted__c == true && newRecord.CRM_IsDeleted__c == false) {
                newRecord.CRM_SyncGenesys__c = false;
                newRecord.CRM_SyncGenesysDelete__c = false;         
            }
        }

    }

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        if (onAssenzeTriggerHandler.isFirstTime) {   
            onAssenzeTriggerHandler.genesysQueueCallout(Trigger.newMap);
            Set<Id> newAssenzeIds = new Set<Id>();
            for (CRM_Assenze__c newAssenza : Trigger.new) {
                newAssenzeIds.add(newAssenza.Id);
            }
            Batch_onAssenzeTriggerHandler.runBatch(newAssenzeIds);
        }
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        if (onAssenzeTriggerHandler.isFirstTime) {   
            onAssenzeTriggerHandler.genesysQueueDeleteCallout(Trigger.newMap);
            Set<Id> newAssenzeIds = new Set<Id>();
            for (CRM_Assenze__c newAssenza : Trigger.new) {
                newAssenzeIds.add(newAssenza.Id);
            }
            Batch_onAssenzeDeleteTriggerHandler.runBatch(newAssenzeIds);
        }
    }
}