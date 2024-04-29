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
        try{
            Campaign cm = [SELECT Id, CRM_QueueName__c, CRM_QueueId__c FROM Campaign WHERE Id=: campaignId];
            String token = authVsGenesys();
            String endpoint = 'https://api.mypurecloud.de/api/v2/routing/queues/?name='+cm.CRM_QueueName__c;
            System.debug('@@@@@endpoint '+endpoint);
            System.debug('@@@@@autToken '+token);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer '+ token);
            request.setHeader('Content-Type', 'application/json');
    
            System.debug('@@@@@updateQueueOnGenesys request '+request);
            System.debug('@@@@@updateQueueOnGenesys Authorization '+request.getHeader('Authorization'));
    
            HttpResponse response = !Test.isRunningTest() ? http.send(request) : null;
            Map<String,Object> deserializedResponse= (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('@@@@@updateQueueOnGenesys deserializedResponse '+deserializedResponse);
            /*Map<String,Object> entities =  (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(deserializedResponse.get('entities')));
            System.debug('@@@@@updateQueueOnGenesys entities '+entities);
            //Object entity =entities[0];
            //System.debug('@@@@@updateQueueOnGenesys entity '+entity);
            String queueId = (String) JSON.deserialize(JSON.serialize(entities), String.class);
            //String queueId =(String) JSON.deserializeUntyped(entity).get('id');
            System.debug('@@@@@updateQueueOnGenesys queueId '+queueId);*/
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


        }catch(Exception e){
            System.debug('@@@@@error  genesysQueueCallout: '+e.getStackTraceString());
        }
    }

    public static String authVsGenesys(){
        String token;
        Endpoint__c apiRequest = Endpoint__c.getInstance('GenesysToken');
        String orgId=UserInfo.getOrganizationId().left(15);
        softphone_it__Connector_Settings__c  cs= softphone_it__Connector_Settings__c.getInstance(orgId);
        String aut = EncodingUtil.base64Encode(Blob.valueof(cs.softphone_it__GC_CLIENT_ID__c+':'+cs.softphone_it__GC_CLIENT_SECRET__c));
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiRequest.Endpoint__c);
        request.setMethod(apiRequest.Method__c);
        request.setHeader('Authorization', 'Basic '+aut);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody('grant_type=client_credentials');

        HttpResponse response = http.send(request);
        if(!Test.isRunningTest()){
            System.debug('@@@@@tokenResponse'+response.getBody());
            Map<String,Object> deserializedResponse= (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            token=(String) deserializedResponse.get('access_token');
            //Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Bper');
            //orgPart.put('genesysToken', token, 86400);

        }

        return token;
    }
}