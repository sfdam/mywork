global without sharing class ScheduleInvioISProvvisoria1 implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>([SELECT Id FROM SBQQ__QuoteLine__c WHERE Quoteline_per_Batch_verso_Infostore_TEST__c = true AND RecordType.DeveloperName = 'Warrant' AND Quote_Line_per_Batch_verso_Infostore__c = false  LIMIT 150]);
        Map<String, SObject> qlMap = (Map<String,SObject>)Utilities.keyBy(qlList, 'Id');
        List<String> ids = new List<String>();
        ids.addAll(qlMap.keySet());
        // mergeNumbers M = new mergeNumbers();
        QbleInvioOffertaInfostore q = new QbleInvioOffertaInfostore(ids);
        if(!Test.isRunningTest()) System.enqueueJob(q);
    }

}