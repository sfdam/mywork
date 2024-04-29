/**
 * Created by ssalaris on 12/08/2021.
 */

global class THR_UpdCaseOwnershipDaysScheduler implements Schedulable{
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new THR_UpdCaseOwnershipDaysBatch(), 200);
    }
}