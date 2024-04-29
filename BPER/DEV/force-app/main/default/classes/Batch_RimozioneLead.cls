global class Batch_RimozioneLead implements Database.Batchable<sObject>, Database.stateful {

    /**
     * Batch
	***/
    global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT Id FROM Lead WHERE CreatedDate < LAST_N_DAYS:14';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        delete scope;
    }

    global void finish(Database.BatchableContext BC) {

    }
}