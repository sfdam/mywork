/**
 * @description       : 
 * @author            : alessandro.dinardo@lutech.it
 * @group             : tengroup
 * @last modified on  : 24-01-2024
 * @last modified by  : alessandro.dinardo@lutech.it
 * description        :  classe mock per "AggiornaMassivamenteTagQueueable" 
**/
 
@isTest
public class MockHttpAggiornaMassivamenteTagQueueable implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        System.debug('req: ' + req);
        if(req.getEndpoint() ==   'callout:CallMeBack/services/data/v55.0/wave/replicatedDatasets/'){
            System.debug('AD MockHttpAggiornaMassivamenteTagQueueable replicatedDatasets');
            res.setBody('{"replicatedDatasets" : [{"sourceObjectName" : "Account","id":"1","replicationDataflowId":"2"}]}');

        }if(req.getEndpoint() ==  'callout:CallMeBack/services/data/v55.0/wave/replicatedDatasets/1'){
            System.debug('AD MockHttpAggiornaMassivamenteTagQueueable replicatedDatasets with id');
            res.setBody('{"replicatedDatasets" : [{"sourceObjectName" : "Account","id":"1","replicationDataflowId":"2"}]}');

        }if(req.getEndpoint() ==  'callout:CallMeBack/services/data/v55.0/wave/dataflowjobs'){
            System.debug('AD MockHttpAggiornaMassivamenteTagQueueable dataflowjobs');
            res.setBody('{"replicatedDatasets" : [{"sourceObjectName" : "Account","id":"1","replicationDataflowId":"2"}]}');

        }
        


        return res;

    }
}