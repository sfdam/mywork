//@TestClass: ART_EffectiveAccManSyncBatchSched_Test
global with sharing class ART_EffectiveAccManagerSyncBatchSched implements Schedulable{
    global void execute(System.SchedulableContext sc) {
        Database.executeBatch(new cgcloud.EffectiveAccountManagerSyncBatch(), 1);
    }
}