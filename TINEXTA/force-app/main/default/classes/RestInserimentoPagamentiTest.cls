@isTest
public inherited sharing class RestInserimentoPagamentiTest {

    @TestSetup
    static void makeData(){
        Funzionalita__c x = new Funzionalita__c();
        x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_tutti_i_trigger__c = false;
        insert x;

        Schema.DescribeSObjectResult d = Schema.SObjectType.Account; 
        Id rtAccount = d.getRecordTypeInfosByName().get('Warrant').getRecordTypeId();
        Account acc = new Account(Name = 'TestInserimentoOfferta', RecordTypeId = rtAccount);
        insert acc;

        Product2 p = new Product2(Name = 'TestProdAgg');
        insert p;

        SBQQ__Quote__c q = new SBQQ__Quote__c(SBQQ__Account__c = acc.Id, SBQQ__Primary__c = true);
        insert q;
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = p.Id, Tipo_Mandato__c = 'Singolo', Divisione_WarrantCPQ__c = '1104244169');
        insert ql;
        Finanziamenti__c fin = new Finanziamenti__c(Quote_Line__c = ql.Id);
        insert fin;
        Condizioni__c con = new Condizioni__c(Quote_Line__c = ql.Id, Finanziamento__c = fin.Id);
        insert con;
    }

    @isTest
    static void inserimentoPagamentiOK(){

        SBQQ__QuoteLine__c quoteline = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        Condizioni__c condizione = [SELECT Id FROM Condizioni__c LIMIT 1];

        List<Pagamenti__c> pagamenti = new List<Pagamenti__c>{
            new Pagamenti__c(Condizione_WarrantCPQ__c = condizione.Id, Quote_Line__c = quoteline.Id)
        };

        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        
        req.requestURI = '/v1.0/InserimentoPagamenti';
        req.httpMethod = 'POST';
        // req.requestBody = Blob.valueOf(bodySr);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        RestInserimentoPagamenti.doPost(pagamenti);
        Test.stopTest();
    }

    @isTest
    static void inserimentoPagamentiKO1(){

        SBQQ__QuoteLine__c quoteline = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        Condizioni__c condizione = [SELECT Id FROM Condizioni__c LIMIT 1];

        List<Pagamenti__c> pagamenti = new List<Pagamenti__c>{
            new Pagamenti__c(Quote_Line__c = quoteline.Id)
        };

        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        
        req.requestURI = '/v1.0/InserimentoPagamenti';
        req.httpMethod = 'POST';
        // req.requestBody = Blob.valueOf(bodySr);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        RestInserimentoPagamenti.doPost(pagamenti);
        Test.stopTest();
    }

    @isTest
    static void inserimentoPagamentiKO2(){
        SBQQ__QuoteLine__c quoteline = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        Condizioni__c condizione = [SELECT Id FROM Condizioni__c LIMIT 1];

        List<Pagamenti__c> pagamenti = new List<Pagamenti__c>{
            new Pagamenti__c(Condizione_WarrantCPQ__c = condizione.Id)
        };

        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        
        req.requestURI = '/v1.0/InserimentoPagamenti';
        req.httpMethod = 'POST';
        // req.requestBody = Blob.valueOf(bodySr);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        RestInserimentoPagamenti.doPost(pagamenti);
        Test.stopTest();
    }

    @isTest
    static void inserimentoPagamentiKO3(){
        // SBQQ__QuoteLine__c quoteline = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        // Condizioni__c condizione = [SELECT Id FROM Condizioni__c LIMIT 1];

        // List<Pagamenti__c> pagamenti = new List<Pagamenti__c>{
        //     new Pagamenti__c(Condizione_WarrrantCPQ__c = condizione.Id)
        // };

        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        
        req.requestURI = '/v1.0/InserimentoPagamenti';
        req.httpMethod = 'POST';
        // req.requestBody = Blob.valueOf(bodySr);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        RestInserimentoPagamenti.doPost(null);
        Test.stopTest();
    }
}