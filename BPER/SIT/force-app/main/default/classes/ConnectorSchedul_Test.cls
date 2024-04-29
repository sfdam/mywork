@isTest
global class ConnectorSchedul_Test {
    
    @isTest 
    public static void testPostCallout(){
        ConnectorScheduleChat csc = new ConnectorScheduleChat();
        ConnectorMessagesEventPublish.createMessagesEvent();
           
        ExternalRoutingChat erc = new ExternalRoutingChat();
           
        GenesysSetting__c gs = new GenesysSetting__c();
        gs.Name = 'chat';
        gs.G_MEDIA_TYPE__c = 'chat';
        gs.G_PRIORITY__c = 5;
        gs.G_QUEUE_ID__c = '123';
        gs.G_SCHEDULE_GROUP_ID__c = '123';
        gs.S_MESSAGES_TIMEOUT__c = '';
        gs.S_OMNI_ID__c = '0N53X000000GrHK';
        insert gs;
            
        Test.startTest();
        ExternalRoutingChat.CalloutOutbound('1234567890abcde');
        Test.stopTest();
        
        List<String> ids = new List<String>{'1234567890abcdefgi'};   
        ExternalRoutingChat.externalRouting(ids);
           
        HTTPResponse res = new HTTPResponse();
                res.setBody('{}');
                res.setStatusCode(200);
           Map<String, Object> params = new Map<String, Object>();
        ExternalRoutingChat.createTaskFromResponse(res, '123abc',params);
    }
}