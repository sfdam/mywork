@IsTest
public with sharing class THR_InvoiceItemsDeleteBatchSchedulerTest {

    @IsTest
    public static void invoiceItemsDeleteBatchScheduler_test1() {
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute() + 1);
        String ss = String.valueOf(Datetime.now().second());
        String cronExp = ss + ' ' + min + ' ' + hour + ' * * ?';
        String jobId;

        Test.startTest();
        jobId = System.schedule('invoiceItemsDeleteBatchScheduler', cronExp, new THR_InvoiceItemsDeleteBatchScheduler());
        Test.stopTest();

        System.assertEquals(jobId, [SELECT Id FROM CronTrigger WHERE Id = :jobId].Id);
    }
}