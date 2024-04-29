@isTest
public class ExecuteAsUnecapiTest {
    
    @isTest
    public static void executeDMLTest() {

        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        Account banca = AllDataFactory.getAccount('01', 'Banca');
        banca.FinServ__BankNumber__c = '05387';

        req.requestURI = 'callout:CallMeBackUnecapi/services/apexrest/executeasunecapi';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSON.serialize(
            new Map<String,Object>{
                'recordList' => new List<Account>{banca},
                'operation' => 'insert'
            }
        ));

        RestContext.request = req;
        RestContext.response = res;
        ExecuteAsUnecapi.executeDML();
        Test.stopTest();
    }

    @isTest
    public static void executeDMLTest2() {

        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        Account banca = AllDataFactory.getAccount('01', 'Banca');
        banca.FinServ__BankNumber__c = '05387';
        insert banca;

        req.requestURI = 'callout:CallMeBackUnecapi/services/apexrest/executeasunecapi';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSON.serialize(
            new Map<String,Object>{
                'recordList' => new List<Account>{banca},
                'operation' => 'update'
            }
        ));

        RestContext.request = req;
        RestContext.response = res;
        ExecuteAsUnecapi.executeDML();
        Test.stopTest();
    }

    @isTest
    public static void executeDMLTest3() {
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        Account banca = AllDataFactory.getAccount('01', 'Banca');
        banca.FinServ__BankNumber__c = '05387';
        insert banca;

        req.requestURI = 'callout:CallMeBackUnecapi/services/apexrest/executeasunecapi';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSON.serialize(
            new Map<String,Object>{
                'recordList' => new List<Account>{banca},
                'operation' => 'upsert'
            }
        ));

        RestContext.request = req;
        RestContext.response = res;
        ExecuteAsUnecapi.executeDML();
        Test.stopTest();
    }

    @isTest
    public static void executeDMLTest4() {

        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        Account banca = AllDataFactory.getAccount('01', 'Banca');
        banca.FinServ__BankNumber__c = '05387';
        insert banca;

        req.requestURI = 'callout:CallMeBackUnecapi/services/apexrest/executeasunecapi';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSON.serialize(
            new Map<String,Object>{
                'recordList' => new List<Account>{banca},
                'operation' => 'delete'
            }
        ));

        RestContext.request = req;
        RestContext.response = res;
        ExecuteAsUnecapi.executeDML();
        Test.stopTest();
    }
}