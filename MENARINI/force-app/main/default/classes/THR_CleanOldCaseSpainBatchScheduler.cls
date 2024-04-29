global class THR_CleanOldCaseSpainBatchScheduler implements Schedulable{

    global void execute(SchedulableContext ctx) {
        System.debug('Running THR_CleanOldCaseSpainBatchScheduler as: ' + UserInfo.getName() +  ', ID: ' + UserInfo.getUserId() + ', Profile ID: ' + UserInfo.getProfileId());
        Database.executeBatch(new THR_CleanOldCaseSpainDailyBatch());
    }
}