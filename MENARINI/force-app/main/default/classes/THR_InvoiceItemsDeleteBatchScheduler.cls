global class THR_InvoiceItemsDeleteBatchScheduler implements Schedulable{

    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new THR_InvoiceItemsDeleteBatch(), 200);
    }
}