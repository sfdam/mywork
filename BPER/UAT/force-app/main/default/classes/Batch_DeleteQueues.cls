global class Batch_DeleteQueues implements Schedulable, Database.Batchable<sObject>,Database.stateful{
    
    public Integer numWeeks = 2;
    global Batch_DeleteQueues(Integer numWeeks){
        this.numWeeks = numWeeks;
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, Queues__c FROM WorkOrder WHERE Status != \'Pending\' AND EndDate = LAST_N_WEEKS:' + numWeeks);
    }

    global void execute(Database.BatchableContext BC, List<WorkOrder> scope) {

        Set<String> queuesList = new Set<String>();
        for(WorkOrder wo : scope){
            queuesList.add('%' + wo.Queues__c + '%');
        }
        Savepoint sp = Database.setSavepoint();
        try {
            List<Group> queuesToDelete = [SELECT id FROM Group WHERE DeveloperName LIKE: queuesList AND Type = 'Queue'];
            if(!queuesToDelete.isEmpty()) delete queuesToDelete;
        } catch (Exception ex) {
            Database.rollback(sp);
            System.debug('DK Exception: ' + ex  + '; Stacktrace: ' + ex.getStackTraceString());
        }
    }

    global void finish(Database.BatchableContext BC) {}

    global void execute(SchedulableContext SC) {
        
        Id batchJobId = Database.executeBatch(new Batch_DeleteQueues(numWeeks), 50);
    }
}