@isTest
public without sharing class WsRestUtilsTest {
    public static Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    public static String certificationName = isSandbox ? 'salesforcetestclient2024' : 'salesforceprodclient2024';
    @TestSetup
    static void setup(){
        
        Account account = AllDataFactory.getAccount('01', 'PersonAccount');
        account.FinServ__BankNumber__c = '05387';
        account.CRM_NDG__c = '2816687'; 
        insert account;

        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Test';
        opportunity.CloseDate = Date.today().addDays(10);
        opportunity.StageName = 'Prosect';
        opportunity.AccountId = account.Id;
        insert opportunity;

        Product2 product = new Product2();
        product.Name = 'TestProduct';
        product.ProductCode = 'PV_1000002';
        insert product;

        FinServ__FinancialAccount__c financialAccount = AllDataFactory.getFinancialAccount('BankingAccount', '01', account.Id);
        financialAccount.FinServ__FinancialAccountNumber__c = '000000882095';
        financialAccount.CRM_Ced__c = '0055';
        financialAccount.FinServ__ProductName__c = product.Id;
        financialAccount.CRM_Tipologia_Carta__c = 'CREDITO';
        financialAccount.CRM_CardNumber__c = 'testNumero';
        insert financialAccount;

        CRM_Channel__c servizioDigitale = new CRM_Channel__c();
        servizioDigitale.Financial_Account__c = financialAccount.Id;
        servizioDigitale.CRM_Account__c = account.Id;
        servizioDigitale.CRM_UserId__c = '2115557';
        insert servizioDigitale;

        Endpoint__c endpoint = new Endpoint__c();
        endpoint.Name = 'getDettaglioAnagrafica';
        endpoint.Method__c = 'GET';
        endpoint.Timeout__c = 120000;
        endpoint.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/AnagrafeClientiAPI/v4/anagrafica/dettaglio-anagrafica/abi/{abi}/ndgSettoriale/{ndgSettoriale}';

        Endpoint__c endpoint3 = new Endpoint__c();
        endpoint3.Name = 'getProfiloCarteNDG';
        endpoint3.Method__c = 'GET';
        endpoint3.Timeout__c = 120000;
        endpoint3.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/CarteAPI/v2/carte/profilo-carte-ndg/abi/{abi}/ndg/{ndg}/tipoCliente/{tipoCliente}/tipoCarta/TUTTE';
        endpoint3.EndpointParams__c = '{"abi":"{testata_abi}","termid": "WEB","utente":"{security_utente}","agenzia":"{security_idced}","livello":"05"}';
        

        Endpoint__c endpoint5 = new Endpoint__c();
        endpoint5.Name = 'getInfoCarte';
        endpoint5.Method__c = 'POST';
        endpoint5.Timeout__c = 120000;
        endpoint5.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/ContactCenterCarteAPI/v1/contact-center-carte/getInfoCarte';
        endpoint5.BodyParams__c = '{"abi":"{testata_abi}","numeroCarta":"{numeroCarta}","tipoCarta":"{tipologiaCarta}"}';

        Endpoint__c endpoint6 = new Endpoint__c();
        endpoint6.Name = 'listaRapporti';
        endpoint6.Method__c = 'GET';
        endpoint6.Timeout__c = 120000;
        endpoint6.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/RataInContoServiceAPI/v1/rapporti';
        endpoint6.EndpointParams__c = '{"abiBanca":"{abi}","ndg": "{ndg}","stato":"A"}';

        Endpoint__c endpoint7 = new Endpoint__c();
        endpoint7.Name = 'listaPiani';
        endpoint7.Method__c = 'GET';
        endpoint7.Timeout__c = 120000;
        endpoint7.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/RataInContoServiceAPI/v1/prodotti/{codProdotto}/piani';
        endpoint7.EndpointParams__c = '{"abiBanca":"{abiBanca}","rapportoRataInConto": "{rapportoRataInConto}", "numeroPiano": "{numeroPianoParam}"}';
        insert new List<Endpoint__c>{endpoint, endpoint3, endpoint5, endpoint6, endpoint7};
    }

    @isTest
    static void testCallService() {
        Endpoint__c testApiRequest = new Endpoint__c(
            Name = 'testEndpoint',
            Method__c = 'GET',
            Timeout__c = 120000,
            Endpoint__c = 'https://example.com/api'
        );
        insert testApiRequest;

        Map<String, String> testFirstHeaderObject = new Map<String, String>{'Header1' => 'Value1'};
        Map<String, String> testSecondHeaderObject = new Map<String, String>{'Header2' => 'Value2'};
        Map<String, String> testUrlParams = new Map<String, String>{'param1' => 'value1'};
        Map<String, String> testEndpointParamsMap = new Map<String, String>{'param2' => 'value2'};
        String testBody = '{"key": "value"}';
        String certificateName = 'TestCertificate';
        Boolean disableLog = false;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        WsRestInput.CommonResponse result = WsRestUtils.callService(
            testApiRequest, 
            testFirstHeaderObject, 
            testSecondHeaderObject, 
            testUrlParams, 
            testEndpointParamsMap, 
            testBody, 
            certificateName, 
            disableLog
        );
        

        Test.stopTest();

      
    }

    @isTest
    static void testGetFinalHeader() {
            Endpoint__c testApiRequest = new Endpoint__c(
                Name = 'testEndpoint',
                Method__c = 'GET',
                Timeout__c = 120000,
                Endpoint__c = 'https://example.com/api'
            );
            insert testApiRequest;
    
            Map<String, String> testSecondHeaderObject = new Map<String, String>{'Header2' => 'Value2'};
            Map<String, String> testUrlParams = new Map<String, String>{'param1' => 'value1'};
            Map<String, String> testEndpointParamsMap = new Map<String, String>{'param2' => 'value2'};
            String testHeaderObjectName = 'test';
            string testApiRequestName = 'testEndpoint';
        
            WsRestUtils.getFinalHeader(
                testHeaderObjectName,
                testApiRequestName,
                testSecondHeaderObject,
                testUrlParams,
                testEndpointParamsMap
            );
           
        }
    
    @isTest
    static void testGetFinalHeaderWithUrlParams() {
        String apiRequestName = 'SampleRequest';
        String headerObjectName = 'userProfile';
        Map<String, String> headerObject = new Map<String, String>();
        Map<String, String> urlParams = new Map<String, String>{'{abi}' => '123'};
        Test.startTest();
        Map<String, String> resultHeader = WsRestUtils.getFinalHeader(apiRequestName, headerObjectName, headerObject, urlParams, new Map<String, String>());
        Test.stopTest();
    }

    @isTest
    static void testGetFinalHeaderWithEndpointParams() {
        String apiRequestName = 'SampleRequest';
        String headerObjectName = 'userProfile';
        Map<String, String> headerObject = new Map<String, String>();
        Map<String, String> endpointParamsMap = new Map<String, String>{'abi' => '456'};
        Test.startTest();
        Map<String, String> resultHeader = WsRestUtils.getFinalHeader(apiRequestName, headerObjectName, headerObject, new Map<String, String>(), endpointParamsMap);
        Test.stopTest();

        
    }

    @isTest
    static void testGetFinalHeaderWithoutAbi() {
        String apiRequestName = 'SampleRequest';
        String headerObjectName = 'otherObject';
        Map<String, String> headerObject = new Map<String, String>();
        Map<String, String> urlParams = new Map<String, String>();
        Map<String, String> endpointParamsMap = new Map<String, String>();
        Test.startTest();
        Map<String, String> resultHeader = WsRestUtils.getFinalHeader(apiRequestName, headerObjectName, headerObject, urlParams, endpointParamsMap);
        Test.stopTest();

    }
    @isTest
    static void testConstructor() {
        WsRestUtils utils = new WsRestUtils();
    }

    @isTest
    static void testWriteLog() {
 
        String apiRequestName = 'TestAPI';
        String method = 'GET';
        String input = '{"key":"value"}';
        Integer code = 200;
        String status = 'OK';
        String output = '{"result":"success"}';
        Map<String, String> reqHeader = new Map<String, String>{'Content-Type' => 'application/json'};
        Map<String, String> resHeader = new Map<String, String>{'Content-Type' => 'application/json'};
        String endpoint = 'https://example.com/api?param1=value1&param2=value2';
        String errorMessage = 'No errors';
       
        String apiRequestName1 = 'TestAPI';
        String method1 = 'POST';
        String input1 = '{"key":"value"}';
        String code1 = '500';
        String status1 = 'Internal Server Error';
        String output1 = '{"error":"server error"}';
        Map<String, String> reqHeader1 = new Map<String, String>{'Content-Type' => 'application/json'};
        Map<String, String> resHeader1 = new Map<String, String>{'Content-Type' => 'application/json'};
        String endpoint1 = 'https://example.com/api/error';
        String errorMessage1 = 'Server error occurred';

        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        WsRestUtils.writeLog(apiRequestName, method, input, code, status, output, reqHeader, resHeader, endpoint, errorMessage);
        WsRestUtils.writeLog(apiRequestName1, method1, input1, code1, status1, output1, reqHeader1, resHeader1, endpoint1, errorMessage1);
        Test.stopTest();
      }
}