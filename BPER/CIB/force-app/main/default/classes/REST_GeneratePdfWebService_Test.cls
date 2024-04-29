@isTest
public without sharing class REST_GeneratePdfWebService_Test {
    @TestSetup
    static void makeData(){
        Endpoint__c generateDocument = (Endpoint__c)JSON.deserialize('{"attributes":{"type":"Endpoint__c","url":""},"IsDeleted":false,"Name":"generateDocument","EndpointParams__c":null,"Endpoint__c":"https://apigw.bper.it/gateway/DocumentsGenerationEngineAPI/v1/documentsgenerationengine/generateDocument","Method__c":"POST","Timeout__c":120000,"BodyParams__c":null,"InList__c":false}', Endpoint__c.class);
        insert generateDocument;
    }

    @isTest
    static void getAccountTest(){


        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/v1/GeneratePDF/';
        request.headers.put('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"key": "value"}');
        RestContext.request = request;
        RestContext.response = response;
        request.params.put('abi', '05387');
        request.params.put('ndg', '21159252');

        Account testAccount = new Account();
        testAccount.Name = 'RTUXASU IETUPIEB';
        testAccount.CRM_PEF_PDFBase64Split1__c ='111';
        testAccount.CRM_PEF_PDFBase64Split2__c='222';
        testAccount.CRM_PEF_PDFBase64Split3__c='333'; 
        testAccount.CRM_PEF_PDFBase64Split4__c='444'; 
        testAccount.NDW_ExternalId__c = '05387_21159252';
        insert testAccount;
        System.debug('testAccount' + testAccount);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PrintPDFExecuteCallMock());
        REST_GeneratePdfWebService.getAccount();
        Test.stopTest();
    }
}