@isTest
global class UnbluRestMock_Test implements HttpCalloutMock {
    private String body;
    
    public UnbluRestMock_Test(String body){
        this.body = body;
    }
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(this.body);
        response.setStatusCode(200);
        return response; 
    }
}