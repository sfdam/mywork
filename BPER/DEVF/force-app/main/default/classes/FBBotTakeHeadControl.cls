public class FBBotTakeHeadControl {
    
    private static String TAKE_THREAD_CONTROL_URL = SocialCustomerServiceSettings__c.getOrgDefaults().FBTakeHeadControlURL__c;
    private static String PAGE_ACCESS_TOKEN = SocialCustomerServiceSettings__c.getOrgDefaults().FBPageAccessToken__c;
    
    @InvocableMethod(label='Dotti Take Head Control' description='The primary receiver takes the control of the conversation')
    public static void takeHeadControl(List<ID> ids) {
        System.debug('Inside takeHeadControl');
        
        List<Case> cases = [SELECT Id, SocialPersona__r.ExternalId
                               FROM Case
                               WHERE Id = :ids];
        
        for (Case c : cases){
            if (c.SocialPersona__r.externalId != null)
                takeMessagingControl(c.SocialPersona__r.externalId);
        }
    }
    
    @future(callout = true)
    public static void takeMessagingControl(String recipientId) {
        System.debug('Taking head control for recipientId ' + recipientId);
        TakeHeadControlRequestDto dto = new TakeHeadControlRequestDto(recipientId);
        String body = dto.toJson();
        
        System.debug('body ' + body);
        
        Http h = new Http();
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setEndpoint(TAKE_THREAD_CONTROL_URL.replace('{0}', PAGE_ACCESS_TOKEN));
        req.setMethod('POST');
        
        req.setBody(body);
        
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        
        System.debug('take head control res ' + res.getBody());
    }
}