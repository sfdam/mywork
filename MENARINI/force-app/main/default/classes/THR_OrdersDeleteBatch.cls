/**
 * Created by User on 31/08/2022.
 */

public with sharing class THR_OrdersDeleteBatch implements Database.Batchable<SObject> {

    private static final String QUERY =
            'SELECT Id, Status, CreatedDate, THR_Country__c ' +
                    'FROM Order ' +
                    'WHERE THR_Country__c = \'IT\' ' +
                    'AND CreatedDate < LAST_N_MONTHS:12 ' +
                    'AND (Status = \'F\' OR Status = \'H\' OR Status = \'X\')';

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(QUERY);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope){
        delete scope;
    }

    public void finish(Database.BatchableContext BC){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        System.debug('JobInfo: ' + job);
    }
}