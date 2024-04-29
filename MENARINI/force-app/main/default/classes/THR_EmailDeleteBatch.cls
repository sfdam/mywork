public with sharing class THR_EmailDeleteBatch implements Database.Batchable<SObject>{

    private String query = 'SELECT Id, ActivityId FROM EmailMessage WHERE ParentId != NULL AND Parent.RecordType.DeveloperName = \'THR_PVClaims\' AND Parent.ClosedDate != NULL' + (Test.isRunningTest() ? '' : ' AND Parent.ClosedDate < LAST_N_DAYS:60');

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope){
        List<String> taskIds = new List<String>();

        for(SObject emailMessage : scope) {
            taskIds.add((String) emailMessage.get('ActivityId'));
        }

        List<Task> tasks = [SELECT Id FROM Task WHERE Id IN :taskIds];

        delete scope;
        delete tasks;
    }

    public void finish(Database.BatchableContext BC){

    }
}