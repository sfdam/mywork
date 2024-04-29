@isTest
private without sharing class CMK_SharepointIntegrationCtrlTest {
    
    @TestSetup
    static void makeData(){

        Funzionalita__c x = new Funzionalita__c();
        x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_tutti_i_trigger__c = true;
        x.Disabilita_Integrazione__c = true;
        insert x;

        EndpointServizi__c es = new EndpointServizi__c();
        es.CMK_Url_Sharepoint_CreateFolder__c = 'https://sharepointcreatefolder.it';
        es.CMK_Url_Sharepoint_Token__c = 'https://sharepointtoken.it';
        es.CMK_client_id_Sharepoint__c = '123';
        es.CMK_client_secret_Sharepoint__c = '321';
        insert es;

        List<Account> accs = TestDataFactory.createAccounts(1);
        accs[0].Data_Ultimo_Arricchimento__c = System.Today();
        insert accs;

        List<Opportunity> opps = TestDataFactory.createOpportunity(accs);
        opps[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Co_Mark').getRecordTypeId();
        opps[0].StageName = 'Negoziazione/Revisione';
        opps[0].TXT_ForecastCategory__c = 'Upside';

        insert opps;

        x.Disabilita_tutti_i_trigger__c = false;
        update x;
    }

    @isTest
    static void testSuccess() {

        Opportunity opp = [SELECT Id, StageName, TXT_ForecastCategory__c FROM Opportunity LIMIT 1];
        Test.setMock(HttpCalloutMock.Class, new HttpMockSharepoint(200, 'OK', '{}', new Map<String,String>()));

        Test.startTest();

            opp.StageName = 'Chiuse/Conseguite';
            opp.TXT_ForecastCategory__c = 'Closed Won';
            update opp;

        Test.stopTest();
    }

    @isTest
    static void testError() {

        Test.setMock(HttpCalloutMock.Class, new HttpMockSharepoint(405, 'ERROR', '{}', new Map<String,String>()));
        Opportunity opp = [SELECT Id, StageName, TXT_ForecastCategory__c FROM Opportunity LIMIT 1];

        Test.startTest();

            opp.StageName = 'Chiuse/Conseguite';
            opp.TXT_ForecastCategory__c = 'Closed Won';
            update opp;

        Test.stopTest();
    }

    public class HTTPMockSharepoint implements HttpCalloutMock{
        protected Integer code;
        protected String status;
        protected String body;
        protected Map<String, String> responseHeaders;
        public HTTPMockSharepoint(Integer code, String status, String body, Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.body = body;
            this.responseHeaders = responseHeaders;
        }
        public HTTPMockSharepoint(){
            this.code = 200;
            this.status = 'OK';
            this.body = '{}';
            this.responseHeaders = new Map<String,String>();
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            if(req.getEndpoint()== EndpointServizi__c.getInstance().CMK_Url_Sharepoint_Token__c){
                res.setHeader('Content-type', 'application/json');
                if(this.status == 'OK') {
                    res.setBody('{"success":true,"message":"Created","access_token": "eyj" }');
                } else {
                    res.setBody('{"success":false,"errors":"Created"}');
                }
                res.setStatusCode(this.code);
                res.setStatus(this.status);
            } else if(req.getEndpoint()== EndpointServizi__c.getInstance().CMK_Url_Sharepoint_CreateFolder__c)  {
                res.setHeader('Content-type', 'application/json');
                if(this.status == 'OK') {
                    res.setBody('{"id":"12312312312", "webUrl": "https://sharepointtest.it"}');
                    res.setStatusCode(201);
                } else {
                    res.setBody('{"success":"false", "error": "123"}');
                    res.setStatusCode(405);
                }
                res.setStatus(this.status);
            } else {
                    for (String key : this.responseHeaders.keySet()) {
                        res.setHeader(key, this.responseHeaders.get(key));
                    }
                    res.setBody(this.body);
                    res.setStatusCode(this.code);
                    res.setStatus(this.status);
                    
            }
            return res;
        }
    }
}