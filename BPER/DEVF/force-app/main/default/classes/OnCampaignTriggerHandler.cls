public with sharing class OnCampaignTriggerHandler {

    public static void genesysQueueCallout(List<Campaign> newCampaignList,  Map<Id,Campaign> newMap,  Map<Id,Campaign> oldMap){
        if(newCampaignList.size() == 1){
            Campaign newCampaign = newCampaignList[0];
            Campaign oldCampaign = oldMap.get(newCampaign.Id);
            if(!String.isBlank(newCampaign.CRM_QueueName__c) && newCampaign.CRM_QueueName__c != oldCampaign.CRM_QueueName__c){
                updateQueueOnGenesys(newCampaign.Id);         
            }
        }
    }

    @future(callout=true)
    public static void updateQueueOnGenesys(Id campaignId){
        String url = '';
        try{
            Campaign cm = [SELECT Id, CRM_QueueName__c, CRM_QueueId__c,softphone_it__Genesys_Cloud_Sync__c FROM Campaign WHERE Id=: campaignId];
            url = 'routing/queues/?name='+cm.CRM_QueueName__c;
            if ( !Test.isRunningTest() && cm.softphone_it__Genesys_Cloud_Sync__c){
                HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC('', url , 'DELETE'); 
                String correlation = response.getHeader('ININ-Correlation-Id');
                OnCampaignMemberTriggerHandler.insertDebugLog(campaignId, 'INFO', 'er_trigger_cmp', 'GET', url, '', response.getBody(),correlation);
                updateQueueIdFromResponse(response.getBody(),cm);
            }
            
        }catch(Exception e){
            System.debug('@@@@@error  genesysQueueCallout: '+e.getStackTraceString());
            OnCampaignMemberTriggerHandler.insertDebugLog(campaignId, 'ERROR', 'er_trigger_cmp', 'GET', url, '', e.getMessage(),'');
        }
    }

    public static void updateQueueIdFromResponse(String response,Campaign cm){
        Map<String,Object> deserializedResponse= (Map<String,Object>) JSON.deserializeUntyped(response);
        System.debug('@@@@@updateQueueOnGenesys deserializedResponse '+deserializedResponse);
        List<Object> entities = (List<Object>) deserializedResponse.get('entities');
        System.debug('@@@@@updateQueueOnGenesys entities '+entities);
        Object entityObj =entities[0];
        Map<String,Object> entityMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entityObj));
        System.debug('@@@@@updateQueueOnGenesys entityMap '+entityMap);
        //String queueId = (String) JSON.deserialize(JSON.serialize(entity), String.class);
        String queueId = (String) entityMap.get('id');
        System.debug('@@@@@updateQueueOnGenesys queueId '+queueId);
        cm.CRM_QueueId__c = queueId;
        update cm;
        
        
    }

}