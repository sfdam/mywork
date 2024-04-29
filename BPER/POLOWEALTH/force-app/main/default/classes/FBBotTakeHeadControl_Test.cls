@isTest
private class FBBotTakeHeadControl_Test {
    
    @testSetup static void setup() {
        insert new SocialCustomerServiceSettings__c(FBPageAccessToken__c = 'access_token', FBTakeHeadControlURL__c = 'www.example.com');
        
        Contact c = new Contact(LastName = 'Test');
        
        insert c;
        
        SocialPersona persona = new SocialPersona(Name = 'Test', Provider = 'Facebook', ParentId = c.Id, ExternalId = '0001');
        
        insert persona;
        
        List<Case> cases = new List<Case>();
        
        for (Integer i = 0; i < 10; i++){
            cases.add(new Case(SocialPersona__c = persona.Id, Origin = 'Facebook'));
        }
        
        insert cases;        
    }
    
    @isTest static void takeHeadControl() {
        Test.setMock(HttpCalloutMock.class, new FBMockGenerator());
        
        Map<Id, Case> cases = new Map<Id, Case>([SELECT Id FROM Case]);
        List<Id> ids = new List<Id>();
        
        ids.addAll(cases.KeySet());
        
        FBBotTakeHeadControl.takeHeadControl(ids);
    }
    
    class FBMockGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": "true" }');
            res.setStatusCode(200);
            return res;
        }
    }
    
}