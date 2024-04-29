public without sharing class UtilsUnblu {

    /* public class GenericError{
        public String statusCode            {get; set;}
        public String statusDescription     {get; set;}
        public String errorMessage          {get; set;}
    }

    public class ConversationLinkResponse{
        public List<LinkType> links = new List<LinkType>();
    }

    public class LinkType{
        public String type                  {get; set;}
        public String url                   {get; set;}
    }
    
    public static void loginWithSecureToken(){

        if(isAuthenticated()){

            //do nothing, client already authenticated

        }else{

            String endpoint = Unblu_Settings__c.getInstance('ENDPOINT_LOGIN').Value__c;
            endpoint += '?x-unblu-apikey=' + Unblu_Settings__c.getInstance('XUNBLUAPIKEY').Value__c;

            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setTimeout(120000);

            String requestBody = '{';
            requestBody += '"$_type":"SecureTokenRequest",';
            requestBody += '"token":"' + Unblu_Settings__c.getInstance('JWT_TOKEN').Value__c + '",';
            requestBody += '"type":"JWT"';
            requestBody += '}';
            req.setBody(JSON.serialize(requestBody));

            req.setHeader('allow-impersonated-access', 'true');
            req.setHeader('required-entry-path', 'PUBLIC');
            req.setHeader('required-role', 'ANONYMOUS_USER');

            Http h = new Http();
            HttpResponse res = h.send(req);
            
            if(res.getStatusCode() != 204){
                GenericError err = (GenericError)JSON.deserialize(res.getBody(), GenericError.class);
                System.debug('error --> '+err);
            }

        }

    }

    public static Boolean isAuthenticated(){

        Boolean result = false;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(Unblu_Settings__c.getInstance('ENDPOINT_ISAUTHENTICATED').Value__c);
        req.setMethod('GET');
        req.setTimeout(120000);

        req.setHeader('allow-impersonated-access', 'true');
        req.setHeader('required-entry-path', 'PUBLIC');
        req.setHeader('required-role', 'ANONYMOUS_USER');

        Http h = new Http();
        HttpResponse res = h.send(req);
        
        if(res.getStatusCode() != 200){
            
            GenericError err = (GenericError)JSON.deserialize(res.getBody(), GenericError.class);
            System.debug('error --> '+err);

        }else{

            result = true;

        }


        return result;

    }

    public static String getConversationLink(String conversationId){

        String resultUrl = '';

        UtilsUnblu.loginWithSecureToken();

        HttpRequest req = new HttpRequest();
        String endpoint = Unblu_Settings__c.getInstance('ENDPOINT_GETCONVERASTIONLINK') + '?';
        endpoint += 'id=' + conversationId;

        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setTimeout(120000);

        req.setHeader('required-entry-path', 'INTERNAL');
        req.setHeader('required-role', 'REGISTERED_USER');

        Http h = new Http();
        HttpResponse res = h.send(req);

        if(res.getStatusCode() == 200){

            ConversationLinkResponse response = (ConversationLinkResponse)JSON.deserialize(res.getBody(),ConversationLinkResponse.class);
            if(response != null && response.links != null && !response.links.isEmpty()){
                for(LinkType lt : response.links){
                    if('OPEN_IN_AGENT_SINGLE_VIEW'.equalsIgnoreCase(lt.type)){
                        resultUrl = lt.url;
                        break;
                    }
                }
            }

        }else{

            GenericError err = (GenericError)JSON.deserialize(res.getBody(), GenericError.class);
            System.debug('error --> '+err);

        }

        return resultUrl;

    } */

}