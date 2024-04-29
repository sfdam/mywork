@isTest
private class UnbluApex_Test { 
    
    static testMethod void UnbluControllerTest() {
        Object o;
        UnbluController ubc = new UnbluController(o);
    
        UnbluController.unbluUserSearch('');
        UnbluController.unbluPersonSearch('');
        UnbluController.createUser('test', 'test test');
        UnbluController.unbluInviteAgentToConversation('unbluConvId', 'unbluPersonId');
        UnbluController.unbluAddParticipant('unbluConvId', 'unbluPersonId');
        UnbluController.unbluSetAssigneePerson('unbluConvId', 'unbluPersonId');
		UnbluController.unbluEndConversation('unbluConvId');
        UnbluController.unbluRequeueConversation('unbluConvId');
        
        Case c = new Case();
        insert c;
        UnbluController.updateUnbluChatAccepted(c.Id);
        UnbluController.updateUnbluChatEnded(c.Id);
        
       /* HTTPResponse res = new HTTPResponse();
        res.setBody('{"items":[{"id": "123"}]');
        res.setStatusCode(200);
        UnbluController.getUnbluPersonIdFromResponse(res);*/
   	}
    
    static testMethod void UnbluRestClientTest() {        
        softphone_it__Connector_Settings__c cs = softphone_it__Connector_Settings__c.getOrgDefaults();
        cs.UnbluApiUsername__c = 'testUser';
        cs.UnbluApiPassword__c = 'testPassword';
        cs.UnbluApiUrl__c = 'TestURL';
        upsert cs;
        
        Test.setMock(HttpCalloutMock.class, new UnbluRestMock_Test('{"access_token": "8aec49f7"}')); 
        HttpResponse response = UnbluRestClient.executeRequest('', '', '');
    }
    
    public static void createRestContext(String headers, String body){
        //System.debug(EncodingUtil.convertToHex(Crypto.generateMac('hmacSHA1',Blob.valueOf('body'),Blob.valueOf('settings'))));
        softphone_it__Connector_Settings__c cs = softphone_it__Connector_Settings__c.getOrgDefaults();
        cs.UnbluWebhookSecret__c = 'a1b2c3';
        upsert cs;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/unblu-webhooks/created';
        req.httpMethod = 'POST';        
        req.headers.put('X-Unblu-Signature', headers);
       	req.requestBody = Blob.valueof(body);
        
        RestContext.request = req;
		RestContext.response= res;
    }
    
    static testMethod void UnbluRestWebhookFailTest() {
        createRestContext('', 'abc123');
                
        UnbluRestWebhookCreated.doPost(); 
       	UnbluRestWebhookEnded.doPost();
    }
    
     static testMethod void UnbluRestWebhookCatchTest() {
        createRestContext('0e37055fc3170bca9e90b2669a0cab5b139cdceb', 'a1b2c3');
             
        UnbluRestWebhookCreated.doPost(); 
       	UnbluRestWebhookEnded.doPost();
    }
    
    static testMethod void UnbluRestWebhookSuccessCreatedTest() {
        String body = '{"$_type":"ConversationCreatedEvent", "conversation": {"$_type":"ConversationData","id":"k55bD_nySoWrMGQhZKvGMQ","visitorData":"test"}}';
        createRestContext('aba6ebdebd2b505ec694128e73e5ef1484fd9e44', body);
        
        UnbluRestWebhookCreated.doPost();
       	UnbluRestWebhookEnded.doPost();
        UnbluRestWebhookEnded.CalloutOutbound('test', 'test');
        UnbluRestWebhookCreated.manageDoPost('test');
    }
    
    static testMethod void UnbluRestWebhookSuccessEndedTest() {
        String body = '{"$_type":"ConversationEndedEvent", "conversation": {"$_type":"ConversationData","id":"k55bD_nySoWrMGQhZKvGMQ"}}';
        createRestContext('1be5f31a2f2f2293a23d3a09b0ec5b7ccb825623', body);
        
        UnbluRestWebhookCreated.doPost();
       	UnbluRestWebhookEnded.doPost();
    }
}