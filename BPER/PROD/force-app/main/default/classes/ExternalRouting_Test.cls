@isTest
global class ExternalRouting_Test {
    
    @isTest static void testExternalRouting(){
        ConnectorMessagesEventPublish.createMessagesEvent();
            
        ExternalRoutingChat erc = new ExternalRoutingChat();
            
        GenesysSetting__c gs = new GenesysSetting__c();
        gs.Name = 'chat';
        gs.G_MEDIA_TYPE__c = 'chat';
        gs.G_PRIORITY__c = 5;
        gs.G_QUEUE_ID__c = '123';
        gs.G_SCHEDULE_GROUP_ID__c = '123';
        gs.G_SKILL__c = 'skill';
        gs.S_CHAT_BUTTON_ID__c = '5733X000000HVuZQAW';
        insert gs;
        
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatDeploymentId = '5723X000000HVA8QAO';
        lct.LiveChatButtonId = '5733X000000HVuZQAW';
        lct.LiveChatVisitorId = '5713X0000061zAmQAI';
        insert lct;
        
        ConversationContextEntry cce = new ConversationContextEntry();
        cce.CustomDetailContextKey = 'Nome e cognome';
        cce.CustomDetailContextValue = 'Test Test';
        cce.ParentId = lct.Id;
        insert cce;
        
        List<String> ids = new List<String>{lct.Id}; 
            
        Test.startTest();
        ExternalRoutingChat.externalRouting(ids);
        Test.stopTest();
                
        ExternalRoutingChat.CalloutOutboundRemote(lct.Id);
                
        Object o;    
        HTTPResponse res = new HTTPResponse();
                res.setBody('{}');
                res.setStatusCode(200);
        Map<String, Object> params = new Map<String, Object>();
        ExternalRoutingChat.createTaskFromResponse(res, '123abc', params);
    }
    @isTest static void testExternalRoutingWA(){
        GenesysSetting__c gs = new GenesysSetting__c();
        gs.Name = 'Whatsapp';
        gs.G_MEDIA_TYPE__c = 'whatsapp';
        gs.G_PRIORITY__c = 5;
        gs.G_QUEUE_ID__c = '123';
        gs.G_SCHEDULE_GROUP_ID__c = '123';
        insert gs;
        
        MessagingChannel mc = [SELECT Id from MessagingChannel WHERE DeveloperName LIKE 'Whatsapp_IT_whatsapp%' LIMIT 1];
        
        MessagingEndUser mu = new MessagingEndUser();
        mu.Name = 'test';
        mu.MessagingPlatformKey = 'WhatsApp:+123';
        mu.MessagingChannelId = mc.Id;
        mu.MessageType = 'WhatsApp';
        insert mu;
        
        MessagingSession ms = new MessagingSession ();
        ms.MessagingChannelId = mc.Id;
        ms.MessagingEndUserId = mu.Id;
        ms.Status = 'Waiting';
        insert ms ;
        
        List<String> ids = new List<String>{ms.Id};
            
        Object o;
        
        Test.startTest();
        ExternalRoutingWhatsapp er = new ExternalRoutingWhatsapp(o);
        ExternalRoutingWhatsapp.pushToGcWithTId(ids);
        ExternalRoutingWhatsapp.CalloutOutbound(ms.Id);
        Test.stopTest();
    }
}