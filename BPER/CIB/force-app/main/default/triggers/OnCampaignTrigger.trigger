trigger OnCampaignTrigger on Campaign (after update) {

    Funzionalita__c f = Funzionalita__c.getInstance();
    
    if(Trigger.isUpdate && Trigger.isAfter){
       if(!f.isETL__c){    
            OnCampaignTriggerHandler.genesysQueueCallout(Trigger.new,  Trigger.newMap,  Trigger.oldMap);
       }
    }
}