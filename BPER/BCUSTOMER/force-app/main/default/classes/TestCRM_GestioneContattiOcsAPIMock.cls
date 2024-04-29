@isTest
public class TestCRM_GestioneContattiOcsAPIMock implements HttpCalloutMock {
    
    public Integer statusCode;
    public String  body;
    public static HTTPResponse response = new HTTPResponse();
    
    public TestCRM_GestioneContattiOcsAPIMock(Integer statusCode, String body ) {
        this.statusCode = statusCode;
        this.body       = body;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
    	    
        // Set response values
        response.setHeader('Content-Type', 'application/json');
        response.setBody(body);
        response.setStatusCode( statusCode );
        response.setStatus('status');        
        
        // return response.
        return response;
    }
}