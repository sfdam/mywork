global with sharing class ExternalRoutingChat {
    public ExternalRoutingChat() {}  

    @InvocableMethod (label='er_chat')
    global static void externalRouting(List<String> id){
        softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('INFO', 'er_chat', 'START_FLOW', id.toString(), '', '');
        for ( String chatId : id ){
            try{ 
                softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('INFO', 'er_chat', 'START', chatId, '', '');
                CalloutOutbound(chatId);
            }catch(Exception e){
                System.debug('ERRORE: ' + e.getMessage());
                softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('ERROR', 'er_chat', 'ERROR', chatId, e.getMessage(), '');
            }
        }     
    }
    
    public Static void innerCalloutOutbound(String liveChatId,String label){
        String customerName, motivoChat, codiceFiscale;
        LiveChatTranscript lct = [select id, LiveChatDeploymentId, LiveChatButtonId, SkillId from LiveChatTranscript where id=:liveChatId limit 1];
        GenesysSetting__c settings = [select id, G_QUEUE_ID__c, G_MEDIA_TYPE__c, G_PRIORITY__c, G_SKILL__c, S_CHAT_BUTTON_ID__c from GenesysSetting__c where S_CHAT_BUTTON_ID__c=:lct.LiveChatButtonId limit 1];
            
            String queueId = settings.G_QUEUE_ID__c;
            //String priority = settings.G_PRIORITY__c;
            Decimal priority = settings.G_PRIORITY__c;
            String skill = settings.G_SKILL__c;
             if ( queueId == null || priority == null || skill == null){
                softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('ERROR', label, 'ERROR', String.valueOf(settings), 'cannot find chat queue, priority or skill in GenesysSetting__c', '');
                return;
            }     
            String mediaType = 'chat';
           // softphone_it.ConnectorOutboundSoftphoneLogs.insertLogExtended('er_chat','getConversationContextEntry START','chatId : ' + chatId,'INFO');
            
            List<ConversationContextEntry> cce = [select id,CreatedDate,CustomDetailContextKey, CustomDetailContextValue,ParentId from ConversationContextEntry Where ParentId =:liveChatId order by CreatedDate desc limit 100];
           // softphone_it.ConnectorOutboundSoftphoneLogs.insertLogExtended('er_chat','getConversationContextEntry END','chatId : ' + chatId,'INFO');
            
            for(ConversationContextEntry c : cce){
                if(c.CustomDetailContextKey == 'Nome e cognome/Ragione sociale' || c.CustomDetailContextKey == 'Nome e cognome' || c.CustomDetailContextKey == 'Ragione sociale'){
                    customerName = c.CustomDetailContextValue;
                } else if (c.CustomDetailContextKey == 'Motivo della chat' || c.CustomDetailContextKey == 'Subject'){
                    motivoChat = c.CustomDetailContextValue;
                } else if (c.CustomDetailContextKey == 'Codice fiscale/Partita iva' || c.CustomDetailContextKey == 'Codice fiscale' || c.CustomDetailContextKey == 'Partita iva'){
                    codiceFiscale = c.CustomDetailContextValue;
                } 
            }
        
        Map<String, Object> params = new Map<String, Object>();
        params.put('queueId', queueId);
        params.put('skillIds', new List<String>{skill});
        params.put('provider', 'Salesforce');
        if ( customerName == null || customerName == ''){
              customerName = 'Cliente Autenticato';
         }
        params.put('customerName', customerName);
        //params.put('priority', Integer.valueOf(priority));
        params.put('priority', priority);
        Map<String, String> attributes = new Map<String, String>{'livechat_id'=> liveChatId, 'motivo_chat'=> motivoChat, 'codice_fiscale'=> codiceFiscale, 'media_type'=> mediaType};
        params.put('attributes', attributes);
        String body = JSON.Serialize(params);
        
        if(!Test.isRunningTest()){
            System.debug('callout Genesys START');

            HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC(body,  'conversations/chats', 'POST'); 
            System.debug('callout Genesys END');
            try{
                createTaskFromResponse(response, liveChatId,params);
            }catch(Exception e){
                softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('ERROR', label, 'POST', 'conversations/chats', JSON.serialize(params), response.getBody());
            }
        }
    }

    
   @future (callout=true)
    public Static void CalloutOutbound(String liveChatId){
        innerCalloutOutbound(liveChatId,'er_chat');
    }
    
    @RemoteAction
    public Static void CalloutOutboundRemote(String liveChatId){
        innerCalloutOutbound(liveChatId,'er_chat_resubmit');
    }
    
    public static void createTaskFromResponse(HTTPResponse response, String liveChatId,Map<String, Object> params){
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());              
            External_Routing_Bean__c app = new External_Routing_Bean__c();
            app.Name = 'ExternalFlowRouting';
            app.Interaction_Id__c = (String)results.get('id');
            app.PreChat_Id__c = liveChatId;
            insert app;       
        } 
        softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('INFO', 'er_chat', 'POST', 'conversations/chats', JSON.serialize(params), response.getBody());
    }
}