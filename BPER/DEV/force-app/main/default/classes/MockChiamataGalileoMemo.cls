@isTest
public class MockChiamataGalileoMemo implements HttpCalloutMock {

    public Boolean isOk = true;
    public MockChiamataGalileoMemo(){}
    public MockChiamataGalileoMemo(Boolean isOk){
        this.isOk = isOk; 
    }
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        string memoId;
        string codiceEntita;
        String responseBody = JSON.serialize(new Map<String, Object>{

            'idMemo' =>  '123456',
            'codiceEntita' => 'testmemo'
        });
        if(isOk)res.setBody(responseBody);
        res.setStatusCode(isOk ? 200 : 400);
        return res;
    }
}