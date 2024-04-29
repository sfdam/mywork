global class THR_LockCaseSpainDailyBatchScheduler implements Schedulable{
    global void execute(SchedulableContext ctx) {
        System.debug('Running THR_LockCaseSpainDailyBatchScheduler as: ' + UserInfo.getName() +  ', ID: ' + UserInfo.getUserId() + ', Profile ID: ' + UserInfo.getProfileId());
        Database.executeBatch(new THR_LockCaseSpainDailyBatch());
    }
}