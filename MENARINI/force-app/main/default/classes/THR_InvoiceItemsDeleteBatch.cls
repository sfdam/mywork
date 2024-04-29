public with sharing class THR_InvoiceItemsDeleteBatch implements Database.Batchable<SObject>{

    private static final String QUERY =
                    'SELECT Id, CreatedDate, THR_Country__c, Name, THR_InvoiceBalance__c ' +
                    'FROM THR_Invoice__c ' +
                    'WHERE THR_Country__c = \'IT\' ' +
                            'AND CreatedDate < LAST_N_MONTHS:5 ' +
                            'AND (THR_InvoiceBalance__c = 0 OR THR_InvoiceBalance__c = NULL)' +
                            'AND Id NOT IN (SELECT THR_Invoice__c FROM THR_Related_Object__c WHERE THR_Invoice__c <> NULL)';

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(QUERY);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope){

        delete scope;
        //Database.emptyRecycleBin(scope);
    }

    public void finish(Database.BatchableContext BC){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        System.debug('JobInfo: ' + job);
    }
}