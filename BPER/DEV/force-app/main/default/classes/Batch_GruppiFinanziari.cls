global class Batch_GruppiFinanziari implements Database.Batchable<sObject>,Database.stateful,IRunner {

    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    
    global void initRunner(List<ScheduledJob__c> schedules) {
        sj.addAll(schedules);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, CRM_Account__c, CRM_Account__r.PTF_PortafoglioAssegnato__c, CRM_RelatedAccount__r.PTF_Portafoglio__c FROM CRM_LinkedNDG__c WHERE CRM_Account__r.RecordType.DeveloperName = \'GruppoFinanziario\' AND CRM_LinkCode__c = \'113\' AND( (CRM_Account__r.PTF_PortafoglioAssegnato__c= true AND CRM_RelatedAccount__r.PTF_Portafoglio__c=null) OR (CRM_Account__r.PTF_PortafoglioAssegnato__c= false AND CRM_RelatedAccount__r.PTF_Portafoglio__c!=null)) ';
        
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<CRM_LinkedNDG__c> scope) {
        Map<String, Account> accountToUpdate = new Map<String, Account>();
        for(CRM_LinkedNDG__c link: scope){

           if(!link.CRM_Account__r.PTF_PortafoglioAssegnato__c && String.isNotBlank(link.CRM_RelatedAccount__r.PTF_Portafoglio__c)){
               Account acc= new Account();
               acc.Id=link.CRM_Account__c;
               acc.PTF_PortafoglioAssegnato__c=true;
               accountToUpdate.put(acc.Id, acc);
           }
           else if(link.CRM_Account__r.PTF_PortafoglioAssegnato__c && String.isBlank(link.CRM_RelatedAccount__r.PTF_Portafoglio__c)){
                Account acc= new Account();
                acc.Id=link.CRM_Account__c;
                acc.PTF_PortafoglioAssegnato__c=false;
                accountToUpdate.put(acc.Id, acc);
           }
            

        }
        if(accountToUpdate.size()>0){
            Batch_AccountLink.skipAccountTrigger=true;
            update accountToUpdate.values();
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
        if (sj!=null && sj.size()>0) {
            JobRunner.executeNext(sj);
        }
    }  
   
}