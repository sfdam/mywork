@IsTest
public class THR_LockCaseSpainDailyBatchSchedulerTest {

    @IsTest
    public static void lockCaseSpainDailyBatchScheduler_test() {
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute() + 1);
        String ss = String.valueOf(Datetime.now().second());
        String cronExp = ss + ' ' + min + ' ' + hour + ' * * ?';
        String jobId;

        Test.startTest();
        jobId = System.schedule('LockOldSpanishCasesAndContacts', cronExp, new THR_LockCaseSpainDailyBatchScheduler());
        Test.stopTest();

        System.assertEquals(jobId, [SELECT Id FROM CronTrigger WHERE Id = :jobId].Id);
    }
}