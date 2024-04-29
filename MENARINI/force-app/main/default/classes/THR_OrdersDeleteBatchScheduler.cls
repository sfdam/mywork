/**
 * Created by User on 31/08/2022.
 */

global class THR_OrdersDeleteBatchScheduler implements Schedulable{
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new THR_OrdersDeleteBatch(), 200);
    }
}