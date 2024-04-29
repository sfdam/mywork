global with sharing class UnbluRestClient {
    private static softphone_it__Connector_Settings__c COS = softphone_it__Connector_Settings__c.getOrgDefaults();
    
    global Static HttpResponse executeRequest( String restMethod,String url, String body ){

        String username = COS.UnbluApiUsername__c;
        String password  = COS.UnbluApiPassword__c; 
        String apiurl = COS.UnbluApiUrl__c;
        HttpResponse response = new HttpResponse();
        response.setStatusCode(0);
        if ( username == null || password == null || url == null ){
            softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequestHeader('ERROR', 'unblu_request', 'END_REQUEST', '', '', '','BAD CONFIG : Missing Unblu API url, username or password from Custom settings.');
            throw new CalloutException('BAD CONFIG : Missing Unblu API url, username or password from Custom settings.');
        }
       
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();            
            request.setEndpoint(apiurl + url);
            request.setMethod(restMethod);
            request.setHeader('Content-Type', 'application/json');
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader);
            response = http.send(request);
                if ( body != null && body != '' ){
                    request.setBody(body);
                }            
                response = http.send(request);
                return response;
            }catch(System.CalloutException e){
                System.debug('Error-' + e.getMessage());
            }
        
        return response;
    }
    
}