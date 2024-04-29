global with sharing class ExternalRoutingControllerTransfer {
   
    @InvocableMethod (label='externalRoutingTransfer')
    global static void externalRouting(List<String> ids){
        List<String> app = ids[0].split(',');
        
        String prechatId = '';
         String id = '';
   	    
        try{
            softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('INFO', 'externalRoutingTransfer', 'START', ids.toString(), '', '');
            id = app.get(0).substring(0, 15);
            if ( app.size() == 2 ){
               prechatId = app.get(1);    
            }
            //LiveChatTranscript lct = [select Id,CreatedDate,softphoneerc__IWS_PreChat_Id__c,softphoneerc__IWS_Customer_Name__c,status from LiveChatTranscript WHERE id = :id order by CreatedDate desc limit 1];
            //External_Routing_Bean__c t = [select id,Interaction_Id__c,Agent_Id__c from External_Routing_Bean__c WHERE PreChat_Id__c = :lct.softphoneerc__IWS_PreChat_Id__c order by CreatedDate desc limit 1];
            
            External_Routing_Bean__c t = [select id,Interaction_Id__c,Agent_Id__c from External_Routing_Bean__c WHERE PreChat_Id__c = :id order by CreatedDate desc limit 1];
            
            if ( t.Interaction_Id__c == null || t.Agent_Id__c == null ){
                String log = 'cannot transfer missing parameters, agentId : ' + t.Agent_Id__c + ', interactionId : ' +  t.Interaction_Id__c;
                softphone_it.ConnectorOutboundSoftphoneLogs.insertLog('externalRoutingTransfer',log,'ERROR');
                return;
            }
            CalloutOutbound(t.Interaction_Id__c,t.Agent_Id__c);
        }catch(Exception e){
            softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('ERROR', 'externalRoutingTransfer', 'ERROR', 'exception in externalRoutingTransfer, id=' + id + ',prechatId=' + prechatId + ', ids.get0' + ids.get(0), e.getMessage(), ''); 
        }
      }

    @future (callout=true)
    public Static void CalloutOutbound(String id, String agentId){
        softphone_it__Connector_Settings__c COS = softphone_it__Connector_Settings__c.getOrgDefaults();
        List<GenesysSetting__c> queues = [select id, G_QUEUE_ID__c from GenesysSetting__c where G_MEDIA_TYPE__c='Chat' limit 1];
        if ( queues.size() == 0 ){
            softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('ERROR', 'externalRoutingTransfer', 'ERROR', 'Interaction Id: '+id+', Agent Id: '+agentId, 'cannot find chat queue in GenesysSetting__c', '');
            return;
        }
        String queueId = (String)queues[0].get('G_QUEUE_ID__c');
         if ( queueId == null){
            softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('ERROR', 'externalRoutingTransfer', 'ERROR', String.valueOf(queues), 'cannot find chat queue in GenesysSetting__c', '');
            return;
        }     
        Map<String, Object> params = new Map<String, Object>();
        params.put('queueId', queueId);
        params.put('conversationId', id);
        params.put('participantId', agentId);
        String body = JSON.Serialize(params);
        HttpResponse response = new HttpResponse();
        String headers = '';
     	 if(!Test.isRunningTest()){
             try{
                 String path = 'conversations/chats/'+ id + '/participants/' + agentId + '/replace';
                 //String path = 'integrations/actions/custom_-_245667f0-e171-47c1-9e06-c112410535c1/execute';
                 
                 response = softphone_it.ConnectorCalloutGc.CalloutGC(body, path , 'POST');
        		 
                 List<String> hk = response.getHeaderKeys();
                 
                 for ( String k : hk ){
                     String h = response.getHeader(k);
                     headers += k + ':' + h + ';';
                 }
                 softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequestHeader('INFO', 'externalRoutingTransfer', 'POST', path, JSON.serialize(params), response.getBody(), headers); 
             }catch( Exception e){
                softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequestHeader('ERROR', 'externalRoutingTransfer', 'ERROR', 'error in calloutbound', JSON.serialize(params), response.getBody(), headers);            
             }	
        }
    }
}