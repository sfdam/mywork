/**
 * Created by ssalaris on 12/08/2021.
 */

@IsTest
public with sharing class THR_UpdCaseOwnershipDaysSchedulerTest {

    @IsTest
    public static void updCaseOwnershipDaysScheduler_test1() {
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute() + 1);
        String ss = String.valueOf(Datetime.now().second());
        String cronExp = ss + ' ' + min + ' ' + hour + ' * * ?';
        String jobId;

        Test.startTest();
        jobId = System.schedule('updCaseOwnershipDaysScheduler', cronExp, new THR_UpdCaseOwnershipDaysScheduler());
        Test.stopTest();

        System.assertEquals(jobId, [SELECT Id FROM CronTrigger WHERE Id = :jobId].Id);
    }
}