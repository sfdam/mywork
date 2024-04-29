@IsTest
public class THR_CleanOldCaseSpainBatchSchedulerTest {

    @IsTest
    public static void deleteOldContactsSpainBatchSchedulerTest_test() {

        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute() + 1);
        String ss = String.valueOf(Datetime.now().second());
        String cronExp = ss + ' ' + min + ' ' + hour + ' * * ?';
        String jobId;

        Test.startTest();
        jobId = System.schedule('CleanCasesDeleteOldContacts', cronExp, new THR_CleanOldCaseSpainBatchScheduler());
        Test.stopTest();

        System.assertEquals(jobId, [SELECT Id FROM CronTrigger WHERE Id = :jobId].Id);
    }

}