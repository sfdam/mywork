/**
 * Created by User on 31/08/2022.
 */

@IsTest
public with sharing class THR_OrdersDeleteBatchSchedulerTest {

    @IsTest
    public static void ordersDeleteBatchScheduler_test() {
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute() + 1);
        String ss = String.valueOf(Datetime.now().second());
        String cronExp = ss + ' ' + min + ' ' + hour + ' * * ?';
        String jobId;

        Test.startTest();
        jobId = System.schedule('ordersDeleteBatchScheduler', cronExp, new THR_OrdersDeleteBatchScheduler());
        Test.stopTest();

        System.assertEquals(jobId, [SELECT Id FROM CronTrigger WHERE Id = :jobId].Id);
    }
}