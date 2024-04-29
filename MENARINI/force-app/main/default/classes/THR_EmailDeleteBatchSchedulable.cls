global class THR_EmailDeleteBatchSchedulable implements Schedulable{
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new THR_EmailDeleteBatch(), 200);
    }
}