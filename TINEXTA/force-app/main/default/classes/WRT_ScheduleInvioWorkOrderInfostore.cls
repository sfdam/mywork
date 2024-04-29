global with sharing class WRT_ScheduleInvioWorkOrderInfostore implements Schedulable
{
    global void execute(SchedulableContext SC) {
        map<string, WorkOrder> wokMap = new map<string, WorkOrder>([SELECT Id FROM workorder WHERE Work_Order_per_Batch_verso_Infostore__c = true]);
        List<String> ids = new List<String>();
        ids.addAll(wokMap.keySet());
        
        WRT_QblWorkOrderInfostore q = new WRT_QblWorkOrderInfostore(ids);
        if(!Test.isRunningTest()) System.enqueueJob(q);
    }
}