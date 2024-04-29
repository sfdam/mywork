global class CC_retryAssenzeFailed implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Esegui la query per ottenere gli ID desiderati dalla CRM_Assenze__c
        Set<Id> assenzeIds = new Set<Id>();
        for (CRM_Assenze__c assenza : [SELECT Id
                                        FROM CRM_Assenze__c
                                        WHERE CRM_User__r.CRM_BusinessUnitID__c != null
                                        AND CRM_SyncGenesys__c = false]) {
            assenzeIds.add(assenza.Id);
        }
        
        // Chiamare il metodo runBatch dalla classe Batch_onAssenzeTriggerHandler
        Batch_onAssenzeTriggerHandler.runBatch(assenzeIds);
    }
}