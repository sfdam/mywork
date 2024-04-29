@IsTest
public with sharing class CommunityUsersBatchSchedulableTest {
    @IsTest
    public static void emailDeleteBatchSchedulable_test1() {
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute() + 1);
        String ss = String.valueOf(Datetime.now().second());
        String cronExp = ss + ' ' + min + ' ' + hour + ' * * ?';
        String jobId;

        Test.startTest();
        jobId = System.schedule('communityUsersBatchSchedulable', cronExp, new CommunityUsersBatchSchedulable());
        Test.stopTest();

        System.assertEquals(jobId, [SELECT Id FROM CronTrigger WHERE Id = :jobId].Id);
    }
}