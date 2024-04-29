@isTest
public class REST_CRMAnalyticsAPIrequestTest {

    @isTest
    static void test(){

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');
		Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        REST_CRMAnalyticsAPIrequest.executeConnectorSync();
        Test.stopTest();
    }

}