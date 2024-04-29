@isTest
public class REST_RequestPdfWebService_Test {

    @isTest
    static void getAccountTest(){

        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/v1/RequestPDF/';
        request.headers.put('Content-Type', 'application/json');
        request.params.put('abi', '05387');
        request.params.put('ndg', '123456');
        RestContext.request = request;
        RestContext.response = response;

        Account testAccount = new Account();
        testAccount.Name = 'CRESCENZO COPPOLA';
        testAccount.CRM_PEF_PDFBase64Split1__c ='';
        testAccount.CRM_PEF_PDFBase64Split2__c ='';
        testAccount.CRM_PEF_PDFBase64Split3__c =''; 
        testAccount.CRM_PEF_PDFBase64Split4__c =''; 
        testAccount.NDW_ExternalId__c = '05387_123456';
        testAccount.CRM_TimestampPEFPDF__c = Datetime.now();
        insert testAccount;
        
        Map<String, String> mapResponse = new Map<String, String>();
        mapResponse = REST_RequestPdfWebService.get();

        String pdf = mapResponse.get('pdf');
        Test.stopTest();
    }
}