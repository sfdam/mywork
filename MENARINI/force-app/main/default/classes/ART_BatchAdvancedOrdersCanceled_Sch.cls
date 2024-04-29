public class ART_BatchAdvancedOrdersCanceled_Sch implements Schedulable {

    public void execute(System.SchedulableContext sc) {
        System.debug('ART_BatchAdvancedOrdersCanceled_Sch - execute');
        Database.executeBatch(new ART_BatchAdvancedOrdersCanceled());
    }

}