/****
 * Name         :   Batch_onAssenzeTriggerHandler
 * Created Date :   2023-19-07
 * Author       :   Esposito Francesco Ivan
 ****/
public with sharing class Batch_onAssenzeTriggerHandler implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    private Set<Id> setIdsCRMAssenze;

    public Batch_onAssenzeTriggerHandler(Set<Id> setIdsCRMAssenze) {
        this.setIdsCRMAssenze = setIdsCRMAssenze;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, Name, CRM_SyncGenesys__c, STG_X_Update_TS__c, CRM_IdGenesys__c, CRM_Matricola__c, NDW_ExternalId__c, CRM_Inizioassenza__c, CRM_FineAssenza__c, CRM_User__c, CRM_User__r.CRM_BusinessUnitID__c, CRM_User__r.CRM_ManagementID__c, CRM_User__r.CRM_GenesysID__c FROM CRM_Assenze__c WHERE Id IN :setIdsCRMAssenze AND CRM_SyncGenesys__c = false';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<CRM_Assenze__c> scope) {
        try {
            Set<Id> scopeIds = new Set<Id>();

            for (CRM_Assenze__c assenza : scope) {
                scopeIds.add(assenza.Id);
            }

            onAssenzeTriggerHandler.handleAfterInsert(scopeIds);
            
            /*for (CRM_Assenze__c assenza : scope) {
                assenza.CRM_SyncGenesys__c = true;
            }*/
            //update scope;
        } catch (Exception e) {
        }
    }

    public void finish(Database.BatchableContext context) {
    }

    public static void runBatch(Set<Id> newAssenzeIds) {
        Batch_onAssenzeTriggerHandler batchJob = new Batch_onAssenzeTriggerHandler(newAssenzeIds);
        Database.executeBatch(batchJob, 20); 
    }
}