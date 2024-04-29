public with sharing class Batch_onAssenzeDeleteTriggerHandler implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    private Set<Id> setIdsCRMAssenze;

    public Batch_onAssenzeDeleteTriggerHandler(Set<Id> setIdsCRMAssenze) {
        this.setIdsCRMAssenze = setIdsCRMAssenze;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, Name, CRM_SyncGenesys__c, STG_X_Update_TS__c, CRM_Matricola__c, CRM_IdGenesys__c, NDW_ExternalId__c, CRM_Inizioassenza__c, CRM_FineAssenza__c, CRM_User__c, CRM_User__r.CRM_BusinessUnitID__c, CRM_User__r.CRM_ManagementID__c, CRM_User__r.CRM_GenesysID__c FROM CRM_Assenze__c WHERE Id IN :setIdsCRMAssenze AND  CRM_IsDeleted__c = true';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<CRM_Assenze__c> scope) {
        try {
            Set<Id> scopeIds = new Set<Id>();
            for (CRM_Assenze__c assenza : scope) {
                scopeIds.add(assenza.Id);
            }
            onAssenzeTriggerHandler.handleAfterUpdate(scopeIds);
        } catch (Exception e) {
        }
    }

    public void finish(Database.BatchableContext context) {
    }

    public static void runBatch(Set<Id> newAssenzeIds) {
        Batch_onAssenzeDeleteTriggerHandler batchJob = new Batch_onAssenzeDeleteTriggerHandler(newAssenzeIds);
        Database.executeBatch(batchJob, 20); 
    }
}