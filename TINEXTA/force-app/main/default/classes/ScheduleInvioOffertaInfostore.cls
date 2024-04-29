global without sharing class ScheduleInvioOffertaInfostore implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>([SELECT Id FROM SBQQ__QuoteLine__c WHERE Quote_Line_Per_Batch_Verso_Infostore__c = true AND RecordType.DeveloperName = 'Warrant']);
        Map<String, SObject> qlMap = (Map<String,SObject>)Utilities.keyBy(qlList, 'Id');
        List<String> ids = new List<String>();
        ids.addAll(qlMap.keySet());
        // mergeNumbers M = new mergeNumbers();
        QbleInvioOffertaInfostore q = new QbleInvioOffertaInfostore(ids);
        if(!Test.isRunningTest()) System.enqueueJob(q);
    }

}