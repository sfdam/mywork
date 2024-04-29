@RestResource(urlMapping = '/unblu-webhooks/created')
global without sharing class UnbluRestWebhookCreated {

    @HttpPost
    global static Case doPost() {
        Case result = null;
        String unbluChatId = null;
        String msg = '';
        String customerName='Cliente Autenticato';
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.statusCode = 200;
        String webhookBody = RestContext.request.requestBody.toString();
        String webhookSignature = RestContext.request.headers.get('X-Unblu-Signature');
        List<softphone_it__Softphone_Gc_Sync_Log__c> logs = new List<softphone_it__Softphone_Gc_Sync_Log__c>();
        
        try {
           
            
           if(!UnbluRestWebhookUtils.checkSignature(webhookSignature,webhookBody)){
                String error = 'UNAUTHORIZED: "X-Unblu-Signature" is not equal to the shared signature.';
                RestContext.response.responseBody = Blob.valueOf(error);
                UnbluController.insertDebugLog(unbluChatId, 'ERROR', 'unblu_webhook_created', 'END_WEBHOOK', '', webhookBody, error );
                return result;
            }
            Map <String, Object > requestBody = (Map < String, Object >) JSON.deserializeUntyped(webhookBody);
            String type = (String)requestBody.get('$_type');
            if ( type == null || type != 'ConversationQueuedEvent'){
                String error = 'BADREQUEST: "Wrong message type';
                RestContext.response.responseBody = Blob.valueOf(error);
                UnbluController.insertDebugLog(unbluChatId, 'ERROR', 'unblu_webhook_created', 'END_WEBHOOK', '', webhookBody, error );
                return result;
            }
           
           
            
            Map < String, Object > conversation = (Map < String, Object >) requestBody.get('conversation');
            if (conversation == null) {
                String error = 'BADREQUEST: "Cannot retrieve conversation from webhook';
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
                    String name = (String)visitorDataMap.get('CRM_WebChannelName__c');
                    if ( name != null){
                        name = name.trim();
                        if ( name != '' ){
                            customerName = (String)visitorDataMap.get('CRM_WebChannelName__c');
                        }
                        
                    }
                    
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
     
            String openId = null;
            Decimal priority = 0;
            
            GenesysSetting__c settings = null;
            try{
                settings = getGenesysSettingsUnblu();
            }catch(Exception e1){
                msg += 'cannot find settings for motivo della chat : [' + motivoDellaChat + '];Error : ' + String.valueOf(e1);
            }
            
            if ( settings == null || settings.G_QUEUE_ID__c == null ){     
                openId = 'a71c33c6-634a-4ed2-a348-c362dbaba633';  
                msg += 'cannot find unbluchat queue in GenesysSetting__c, defaulting to : ' + openId + ';';
                
            }else{
                openId = settings.G_QUEUE_ID__c;
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
            CalloutOutboundOpen(openId,customerName,result.Id,motivoDellaChat,unbluChatId,priority);
                
        } catch (Exception e) {
           
            RestContext.response.responseBody = Blob.valueOf('Exception: BAD_REQUEST '+ String.valueOf(e)); 
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
    public Static void CalloutOutboundOpen(String openId,String customerName,String caseId,String motivoChat,String unbluChatId,Decimal priority){
        DateTime dt = DateTime.now();
        String dtDate = dt.formatGmt('yyyy-MM-dd');
        String dtTime = dt.formatGmt('HH:mm:ss.SSS');
        String dtIso = dtDate + 'T' + dtTime + 'Z';

        Map<String, Object> toMap = new Map<String, Object> {'id' => openId};
        Map<String, Object> fromMap = new Map<String, Object> {
            'id' => unbluChatId,
            'idType' => 'Opaque',
            'nickname' => customerName
        };

        Map<String, Object> customAttributes = new Map<String, Object> {
            'case_id' => caseId,
            'customer_name' => customerName,
            'motivo_chat' => motivoChat,
            'media_type' => 'unblu_chat',
            'unblu_chat_id' => unbluChatId
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

    public static GenesysSetting__c getGenesysSettingsUnblu(){
        return  [select id, G_QUEUE_ID__c, G_MEDIA_TYPE__c, G_PRIORITY__c, G_MotivoDiContatto__c from GenesysSetting__c where G_MEDIA_TYPE__c='unblu' limit 1];
    }
   
}