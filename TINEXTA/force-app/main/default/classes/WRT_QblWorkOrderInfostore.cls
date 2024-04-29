global with sharing class WRT_QblWorkOrderInfostore implements Queueable, Database.AllowsCallouts 
{
    global List<String> workorderids{get;set;}

    global WRT_QblWorkOrderInfostore(List<String> workorderids) 
    {
        this.workorderids = workorderids;
    }
    global void execute(QueueableContext context)
    {
        if(this.workorderids.isEmpty()) return;

        Id wokid = (Id)this.workorderids.remove(0);

        try{
            Log__c log = WRT_IntegrazioneController.workOrderIntegration_HDR(new list<id>{wokid});

            /*if(msg != 'OK' || Test.isRunningTest()){
                sendErrorEmail(quoteId, ql.SBQQ__Quote__r.Name, msg);
            }*/
            if(log != null)
            {
                //System.debug('*************if(logList != null)****************'+logList != null);

                insert log;
            }

            if(!this.workorderids.isEmpty() 
               && !Test.isRunningTest()) System.enqueueJob(new WRT_QblWorkOrderInfostore(this.workorderids));
            
        } catch (Exception e){
            System.debug('@@@ exception ' + e.getMessage() + ' ' + e.getStackTraceString());
            if(!this.workorderids.isEmpty() && !Test.isRunningTest()) System.enqueueJob(new WRT_QblWorkOrderInfostore(this.workorderids));          
        }
    }
}