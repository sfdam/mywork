/**
    * @author TEN Tecnologie & Networking Marcello Spadaccini
    * @date Agosto 2022
    * @description
            
        Recuperare i LiveChatTranscript creati dalla chat abbandonate dal cliente. 
        Cancellare i casi collegati.
    * @idSchedulatore - Admin
    * @schedulazione - ??
    * @testClass - Batch_DeleteCases_test
    **/

global class Batch_DeleteCases implements Schedulable, Database.Batchable<sObject>,Database.stateful{

    global Database.QueryLocator start(Database.BatchableContext BC) {
        //return Database.getQueryLocator('Select id, CaseId from LiveChatTranscript where  Status =\'Missed\' and Case.Owner.Name =\'Automated Process\'');
        User automatedUser = [SELECT Id FROM User WHERE Name = 'Automated Process' LIMIT 1];
        return Database.getQueryLocator('Select id, CaseId from LiveChatTranscript where  Status =\'Missed\' and Case.OwnerId = \'' + automatedUser.Id + '\'');
    }

    global void execute(Database.BatchableContext BC, List<LiveChatTranscript> scope) {

        Set<String> casesList = new Set<String>();
        for(LiveChatTranscript s : scope){
            casesList.add(s.CaseId);
        }

        Savepoint sp = Database.setSavepoint();
        try {
            List<Case> casesToDelete = [SELECT id FROM Case WHERE Id IN: casesList];
            if(!casesToDelete.isEmpty()) {
                delete casesToDelete;
            }
        } catch (Exception ex) {
            Database.rollback(sp);
            System.debug('DK Exception: ' + ex  + '; Stacktrace: ' + ex.getStackTraceString());
        }
    }

    global void finish(Database.BatchableContext BC) {}

    global void execute(SchedulableContext SC) {
        
        Id batchJobId = Database.executeBatch(new Batch_DeleteCases());
    }
}