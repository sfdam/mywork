@RestResource(urlMapping = '/unblu-webhooks/created')
global without sharing class UnbluRestWebhookCreated {

    @HttpPost
    global static Case doPost() {
        Case result = null;
        String unbluChatId = null;
        String msg = '';
        String customerName='';
        RestContext.response.addHeader('Content-Type', 'application/json');
        String webhookBody = RestContext.request.requestBody.toString();
        String webhookSignature = RestContext.request.headers.get('X-Unblu-Signature');
        List<softphone_it__Softphone_Gc_Sync_Log__c> logs = new List<softphone_it__Softphone_Gc_Sync_Log__c>();
        
        try {
            
           if(!UnbluRestWebhookUtils.checkSignature(webhookSignature,webhookBody)){
                RestContext.response.statusCode = 401;
                String error = 'UNAUTHORIZED: "X-Unblu-Signature" is not equal to the shared signature.';
                RestContext.response.responseBody = Blob.valueOf(error);
                UnbluController.insertDebugLog(unbluChatId, 'ERROR', 'unblu_webhook_created', 'END_WEBHOOK', '', webhookBody, error );
                return result;
            }
            RestContext.response.statusCode = 200;
            Map <String, Object > requestBody = (Map < String, Object >) JSON.deserializeUntyped(webhookBody);
            String type = (String)requestBody.get('$_type');
            if ( type == null || type != 'ConversationCreatedEvent'){
                String error = 'BADREQUEST: "Wrong message type';
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf(error);
                UnbluController.insertDebugLog(unbluChatId, 'ERROR', 'unblu_webhook_created', 'END_WEBHOOK', '', webhookBody, error );
                return result;
            }
           
           
            
            Map < String, Object > conversation = (Map < String, Object >) requestBody.get('conversation');
            if (conversation == null) {
                String error = 'BADREQUEST: "Cannot retrieve conversation from webhook';
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf(error);
                UnbluController.insertDebugLog(unbluChatId, 'ERROR', 'unblu_webhook_created', 'END_WEBHOOK', '', webhookBody, error );
                return result;
            }
            
            unbluChatId = (String)conversation.get('id');
            logs.add(UnbluController.createDebugLog(unbluChatId,'INFO','unblu_webhook_created','START_WEBHOOK','',webhookBody,''));
            
            String visitorData = (String)conversation.get('visitorData');
            Map < String, Object > visitorDataMap = null;
            String motivoDellaChat = null;
            if (visitorData == null || visitorData == '') {
                //RestContext.response.statusCode = 400;
                msg += 'Cannot retrieve visitorData from webhook;';
                visitorDataMap = new Map < String, Object >();
                motivoDellaChat = 'Altri prodotti e servizi';
            }else{
                try{
                    visitorDataMap = (Map < String, Object >) JSON.deserializeUntyped(visitorData);  
                    customerName = (String)visitorDataMap.get('CRM_WebChannelName__c');
                }catch ( Exception e1){
                    msg+= 'Cannot parse visitorData from webhook;';
                    motivoDellaChat = 'Altri prodotti e servizi';
           
                }
                if ( visitorDataMap != null ){
                    motivoDellaChat = (String)visitorDataMap.get('CRM_MotivoDellaChat__c');  
                    if(motivoDellaChat == null || motivoDellaChat == ''){
                        msg += 'Cannot retrieve CRM_MotivoDellaChat__c from webhook;';
                        motivoDellaChat = 'Altri prodotti e servizi';
                    }
                }
                
            }
     
            String queueId = null;
            Decimal priority = 0;
            GenesysSetting__c settings = null;
            try{
                settings = getGenesysSettings(motivoDellaChat);
            }catch(Exception e1){
                msg += 'cannot find settings for motivo della chat : [' + motivoDellaChat + '];Error : ' + String.valueOf(e1);
            }
            
            if ( settings == null || settings.G_QUEUE_ID__c == null ){     
                queueId = '1ff16aa1-a933-4439-947b-d0791ddaa244';  
                msg += 'cannot find unbluchat queue in GenesysSetting__c, defaulting to : ' + queueId + ';';
                
            }else{
               queueId = settings.G_QUEUE_ID__c;
               if ( settings.G_PRIORITY__c != null ){
                   priority = settings.G_PRIORITY__c;
               }
        
            }
            
            conversation.put('visitorData', visitorDataMap);
            requestBody.put('conversation', conversation);
            
            result = CreateCase.createCaseFromUnbluChat(requestBody);
            if (result == null){    
          //      RestContext.response.statusCode = 500;                
                msg += 'Error creating case for unblu webhook;';
                return result; 
            }
            //CalloutOutbound(queueId,customerName,result.Id,motivoDellaChat,unbluChatId,priority);
            String openId = 'a71c33c6-634a-4ed2-a348-c362dbaba633';
            CalloutOutboundOpen(openId,customerName,result.Id,motivoDellaChat,unbluChatId,priority);
                
        } catch (Exception e) {
           
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('Exception: BAD_REQUEST'); 
            UnbluController.insertDebugLog(unbluChatId, 'ERROR', 'unblu_webhook_created', 'END_WEBHOOK', msg, webhookBody, 'Exception: BAD_REQUEST' +String.valueOf(e) );
            return result;
                    
        }  
        logs.add(UnbluController.createDebugLog(unbluChatId,'INFO', 'unblu_webhook_created', 'END_WEBHOOK', '', msg, 'result : ' + String.valueOf(result)));
           
       
        try{
            insert logs;
        }catch(Exception e){
            System.debug('Error inserting logs ' + e);
        }
        return result;
    }

    public static void manageDoPost(String bodyString){

    }

    @future (callout=true)
    public Static void CalloutOutbound(String queueId,String customerName,String caseId,String motivoChat,String unbluChatId,Decimal priority){
        Map<String, Object> params = new Map<String, Object>();
        params.put('queueId', queueId);
        params.put('provider', 'Unblu');
        if ( customerName == null || customerName == ''){
              customerName = 'Cliente Autenticato';
         }
        params.put('customerName', customerName);
        params.put('priority', priority);
        //params.put('priority', Integer.valueOf(priority));
        Map<String, String> attributes = new Map<String, String>{
            'case_id'=> caseId, 
            'motivo_chat'=> motivoChat,  
            'media_type'=> 'unblu_chat', 
            'unblu_chat_id'=>unbluChatId
        };
        params.put('attributes', attributes);
        String body = JSON.Serialize(params);
        
        if(!Test.isRunningTest()){
            System.debug('callout Genesys START');

            HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC(body,  'conversations/chats', 'POST'); 
            try{
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());              
                Case c = new Case(CC_Id_Conversationd_Unblu__c = unbluChatId,softphone_it__IWS_Interaction_ID__c=(String)results.get('id'));
                upsert c CC_Id_Conversationd_Unblu__c;
            }catch(Exception e){
                System.debug('Failed to update case' + e);
            }
            UnbluController.insertDebugLog(unbluChatId, 'INFO', 'er_unblu_chat', 'POST', 'conversations/chats', JSON.serialize(params), response.getBody());
         
        }

    }

    @future (callout=true)
    public Static void CalloutOutboundOpen(String openId,String customerName,String caseId,String motivoChat,String unbluChatId,Decimal priority){
        DateTime dt = DateTime.now();
        String dtDate = dt.formatGmt('yyyy-MM-dd');
        String dtTime = dt.formatGmt('HH:mm:ss.SSS');
        String dtIso = dtDate + 'T' + dtTime + 'Z';

        Map<String, Object> toMap = new Map<String, Object> {'id' => openId};
        Map<String, Object> fromMap = new Map<String, Object> {
            'id' => unbluChatId,
            'idType' => 'Opaque',
            'nickname' => 'External Routing'
        };

        Map<String, Object> customAttributes = new Map<String, Object> {
            'case_id' => caseId,
            'customer_name' => customerName,
            'motivo_chat' => motivoChat,
            'media_type' => 'unblu_chat',
            'unblu_chat_id' => unbluChatId,
            'esigenza'=> 'TEST_CHAT'
        };

        Map<String, Object> metadata = new Map<String, Object> {
            'customAttributes' => customAttributes
        };
        Map<String, Object> channel = new Map<String, Object> {
            'platform' => 'Open',
            'messageId' => unbluChatId,
            'time' => dtIso,
            'to' => toMap,
            'from' => fromMap,
            'metadata' => metadata
        };
        Map<String, Object> params = new Map<String, Object> {
            'channel' => channel,
            'type' => 'Text',
            'text' => 'Salesforce External Routing',
            'direction' => 'Inbound'
        };
            
       
        String body = JSON.Serialize(params);
        
        if(!Test.isRunningTest()){
            System.debug('callout Genesys START');

            HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC(body,  'conversations/messages/inbound/open', 'POST'); 
            try{
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());              
                Case c = new Case(CC_Id_Conversationd_Unblu__c = unbluChatId,IWS_Message_ID__c=(String)results.get('id'));
                upsert c CC_Id_Conversationd_Unblu__c;
            }catch(Exception e){
                System.debug('Failed to update case' + e);
                UnbluController.insertDebugLog(unbluChatId, 'WARNING', 'unblu_webhook_created', 'END_WEBHOOK', 'error updating case interactionid', '', String.valueOf(e) );
           
            }
            UnbluController.insertDebugLog(unbluChatId, 'INFO', 'er_unblu_chat', 'POST', 'conversations/messages/inbound/open', JSON.serialize(params), response.getBody());
         
        }

    }

    

    public static GenesysSetting__c getGenesysSettings(String motivoDellaChat){
        return  [select id, G_QUEUE_ID__c, G_MEDIA_TYPE__c, G_PRIORITY__c, G_MotivoDiContatto__c from GenesysSetting__c where G_MEDIA_TYPE__c='unbluchat' AND G_MotivoDiContatto__c=:motivoDellaChat limit 1];
    }
   
}