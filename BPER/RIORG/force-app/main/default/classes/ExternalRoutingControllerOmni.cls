global with sharing class ExternalRoutingControllerOmni {
    public ExternalRoutingControllerOmni() {}  

    @InvocableMethod (label='externalRoutingOmni')
    global static void externalRouting(List<String> id){
        String chatId = id.get(0);
         System.debug('externalRoutingOmni, chatId : ' + chatId);
        try{ 
            System.debug('externalRoutingOmni, chatId : ' + chatId);
            softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('INFO', 'externalRoutingOmni', 'START', id.toString(), '', '');
            LiveChatTranscript lct = [select id,softphoneerc__IWS_Customer_Name__c from LiveChatTranscript where id=:chatId limit 1];
            CalloutOutbound(chatId, lct.softphoneerc__IWS_Customer_Name__c);
            //CalloutOutbound(chatId, 'test');
        }catch(Exception e){
            System.debug('ERRORE: ' + e.getMessage());
            softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('ERROR', 'externalRoutingOmni', 'ERROR', id.toString(), e.getMessage(), '');
        }

    }
    
   @future (callout=true)
    public Static void CalloutOutbound(String liveChatId, String customerName){
        softphone_it__Connector_Settings__c COS = softphone_it__Connector_Settings__c.getOrgDefaults();
        //String queueId = COS.softphone_it__GC_QUEUE_ID__c;
        String queueId = '828a9208-c9c1-43e6-9102-7a937f0625ac';
        
        Map<String, Object> params = new Map<String, Object>();
        params.put('queueId', queueId);
        params.put('provider', 'Salesforce');
        params.put('customerName', customerName);
        Map<String, String> attributes = new Map<String, String>{'livechat_id'=> liveChatId};
        params.put('attributes', attributes);
        String body = JSON.Serialize(params);
        
        if(!Test.isRunningTest()){
            HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC(body,  'conversations/chats', 'POST'); 
            softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('INFO', 'externalRoutingOmni', 'POST', 'conversations/chats', JSON.serialize(params), response.getBody());
            createTaskFromResponse(response, liveChatId);
        }
    }
    
    public static void createTaskFromResponse(HTTPResponse response, String liveChatId){
        /*
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());              
            Task app = new Task();
            app.Subject = 'TaskFlowRouting';
            app.softphone_it__IWS_Interaction_ID__c = (String)results.get('id');
            app.softphoneerc__IWS_PreChat_Id__c = liveChatId;            	
            insert app;       
        } 
*/
        softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('INFO', 'externalRoutingOmni', 'POST', 'createTaskFromResponse', 'Live chat Id: ' + liveChatId, '');
    }
}