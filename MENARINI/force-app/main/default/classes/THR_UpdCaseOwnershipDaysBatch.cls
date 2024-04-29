/**
 * Created by ssalaris on 10/08/2021.
 */

public with sharing class THR_UpdCaseOwnershipDaysBatch implements Database.Batchable<SObject>{

    private String query = 'SELECT Id, Is_Current_Partial__c, Case_Ownership__c, Case_Ownership__r.Case__c, Case_Ownership__r.Is_Current_Owner__c, Case_Ownership__r.Case__r.Status, Case_Ownership__r.Case__r.THR_Country__c, Days__c, Close_Date__c from Case_Ownership_Partial__c WHERE Close_Date__c = null and Is_Current_Partial__c = true and Case_Ownership__r.Is_Current_Owner__c = true and Case_Ownership__r.Case__r.Status != \'Closed\'';

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Case_Ownership_Partial__c> scope){
            for( Case_Ownership_Partial__c partial : scope) {
                if(THR_DateUtils.checkBusinessDay(System.today(), partial.Case_Ownership__r.Case__r.THR_Country__c)) {
                    partial.Days__c = partial.Days__c != null ? (partial.Days__c + 1) : 1;
                }
            }
            update scope;
    }

    public void finish(Database.BatchableContext BC){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        System.debug('JobInfo: ' + job);
    }
}