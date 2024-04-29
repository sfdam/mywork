@RestResource(urlMapping = '/unblu-webhooks/ended')
global without sharing class UnbluRestWebhookEnded {

    @HttpPost
    global static void doPost() {
        String unbluChatId = null;
        String msg = '';
        List<softphone_it__Softphone_Gc_Sync_Log__c> logs = new List<softphone_it__Softphone_Gc_Sync_Log__c>();
        
        RestContext.response.addHeader('Content-Type', 'application/json');
        String webhookBody = RestContext.request.requestBody.toString();
        String webhookSignature = RestContext.request.headers.get('X-Unblu-Signature');

        
        try {
            
            if(!UnbluRestWebhookUtils.checkSignature(webhookSignature,webhookBody)){
                RestContext.response.statusCode = 401;
                String error = 'UNAUTHORIZED: "X-Unblu-Signature" is not equal to the shared signature.';
                RestContext.response.responseBody = Blob.valueOf(error);
                UnbluController.insertDebugLog(unbluChatId, 'ERROR', 'unblu_webhook_ended', 'END_WEBHOOK', '', webhookBody, error );
                return;
            }
            UnbluController.createDebugLog(unbluChatId,'INFO','unblu_webhook_ended','START_WEBHOOK','',webhookBody,'');
            RestContext.response.statusCode = 200;
            Map < String, Object > requestBody = (Map < String, Object >) JSON.deserializeUntyped(webhookBody);
            String type = (String)requestBody.get('$_type');

            if ( type == null || type != 'ConversationEndedEvent'){
                    msg = 'BADREQUEST: "Wrong message type';
                    RestContext.response.statusCode = 400;
                    RestContext.response.responseBody = Blob.valueOf(msg);
                    softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('ERROR', 'unblu_webhook_ended', 'END_WEBHOOK', '', webhookBody, msg );
                    return;
            }

            Map < String, Object > conversation = (Map < String, Object >) requestBody.get('conversation');
            if (conversation == null) {
                String error = 'BADREQUEST: "Cannot retrieve conversation from webhook';
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf(error);
                UnbluController.insertDebugLog(unbluChatId, 'ERROR', 'unblu_webhook_ended', 'END_WEBHOOK', '', webhookBody, error );
                return;
            }
            unbluChatId = (String)conversation.get('id');
            logs.add(UnbluController.createDebugLog(unbluChatId,'INFO','unblu_webhook_ended','START_WEBHOOK','',webhookBody,''));
            Case c = retrieveCaseByUnbluChatId(unbluChatId);
            /*
            if ( c != null && c.softphone_it__IWS_Interaction_ID__c != null && c.UnbluChatStatus__c == 'unmanaged' ){
                String interactionId = c.softphone_it__IWS_Interaction_ID__c;
                try{
                    c.UnbluChatStatus__c = 'abandoned';
                    update c;
                }catch(Exception e1){
                    UnbluController.insertDebugLog(unbluChatId, 'ERROR', 'unblu_webhook_ended', 'END_WEBHOOK', msg, webhookBody, 'Error updating case to abandoned : ' +String.valueOf(e1) );
                }
                CalloutOutboundOpen(unbluChatId,interactionId);
            }
            */
            
            if ( c != null && c.IWS_Message_ID__c != null && c.UnbluChatStatus__c == 'unmanaged' ){
                String interactionId = CalloutOutboundMessageId(unbluChatId,c.IWS_Message_ID__c);
                
                CalloutOutboundOpen(unbluChatId,interactionId);
                try{
                    c.UnbluChatStatus__c = 'abandoned';
                    c.softphone_it__IWS_Interaction_ID__c = interactionId;
                    update c;
                }catch(Exception e1){
                    UnbluController.insertDebugLog(unbluChatId, 'ERROR', 'unblu_webhook_ended', 'END_WEBHOOK', msg, webhookBody, 'Error updating case to abandoned : ' +String.valueOf(e1) );
                }
            }
            
        } catch (Exception e) {
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('Exception: BAD_REQUEST'); 
            UnbluController.insertDebugLog(unbluChatId, 'ERROR', 'unblu_webhook_ended', 'END_WEBHOOK', msg, webhookBody, 'Exception: BAD_REQUEST' +String.valueOf(e) );
            return;             
        }  

        try{
            insert logs;
        }catch(Exception e){
            System.debug('Error inserting logs ' + e);
        }
        return;
    }

    public static String CalloutOutboundMessageId(String unbluChatId,String messageId){
        HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC('',  'conversations/messages/' + messageId + '/details', 'GET'); 
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());              
        UnbluController.insertDebugLog(unbluChatId, 'INFO', 'er_unblu_chat', 'POST', 'conversations/messages/' + messageId + '/details', 'messageId='+messageId, response.getBody());
         
        String interactionId = (String)results.get('conversationId');
        return interactionId;
    }
    private static Case retrieveCaseByUnbluChatId(String unbluId){
        try{
            return [select id,IWS_Message_ID__c,CC_Id_Conversationd_Unblu__c,softphone_it__IWS_Interaction_ID__c,UnbluChatStatus__c from case where CC_Id_Conversationd_Unblu__c=:unbluId];
        }catch(Exception e){
            System.debug('Error in retrieveCaseByUnbluChatId '+ e);
        }
        return null;
        
    }
    @future (callout=true)
    public Static void CalloutOutbound(String unbluChatId,String genesysId){
        Map<String, Object> params = new Map<String, Object>();
        params.put('state', 'disconnected');
        String body = JSON.Serialize(params);
		
        if(!Test.isRunningTest()){
        	HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC(body,  'conversations/chats/' + genesysId, 'PATCH'); 
            UnbluController.insertDebugLog(unbluChatId, 'INFO', 'unblu_webhook_ended', 'PATCH', 'conversations/chats/' + genesysId, JSON.serialize(params), response.getBody());
        }
    }  


    @future (callout=true)
    public Static void CalloutOutboundOpen(String unbluChatId,String genesysId){
        Map<String, Object> params = new Map<String, Object>();
        params.put('state', 'disconnected');
        String body = JSON.Serialize(params);
		
        if(!Test.isRunningTest()){
        	HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC(body,  'conversations/messages/' + genesysId, 'PATCH'); 
            UnbluController.insertDebugLog(unbluChatId, 'INFO', 'unblu_webhook_ended', 'PATCH', 'conversations/messages/' + genesysId, JSON.serialize(params), response.getBody());
        }
    }  



}