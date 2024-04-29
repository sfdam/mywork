/**
 * @author            : alessandro.dinardo@lutech.it
 * @group             : tengroup
 * @last modified on  : 14-03-2024
 * description        :  mock per REST_GetAccount
**/

@isTest
public class MockHttpRestGetAccount implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        System.debug('req: ' + req);
        if(req.getEndpoint().contains('getAccount')){

            res.setBody('{message:ndg}');
        }   
        return res;
    }
}