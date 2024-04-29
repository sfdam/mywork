@isTest
public class MockChiamataGalileoMemo implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        string memoId;
        string codiceEntita;
        String responseBody = JSON.serialize(new Map<String, Object>{

            'memoId' =>  '123456',
            'codiceEntita' => 'testmemo'
        });
        res.setBody (responseBody);
        res.setStatusCode(200);
        return res;
    }
}