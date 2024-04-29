@isTest
public inherited sharing class RestInserimentoCondizioniPagamentiTest {

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
    }

    @isTest
    static void testInserimentoCondizioniPagamentiOK(){

        SBQQ__QuoteLine__c quoteline = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        Finanziamenti__c finanziamento = [SELECT Id FROM Finanziamenti__c LIMIT 1];

        List<Condizioni__c> condizioni = new List<Condizioni__c>();
        condizioni.add(new Condizioni__c(Quote_Line__c = quoteline.Id, Finanziamento__c = finanziamento.Id, Pag_WarrantCPQ__c = '1', FF_WarrantCPQ__c = false, Progressivo__c = false));
        condizioni.add(new Condizioni__c(Quote_Line__c = quoteline.Id, Finanziamento__c = finanziamento.Id, Pag_WarrantCPQ__c = '2', FF_WarrantCPQ__c = false, Progressivo__c = true, Percentuale_WarrantCPQ__c = 10));
        
        List<Pagamenti__c> pagamenti = new List<Pagamenti__c>();
        pagamenti.add(new Pagamenti__c(Quote_Line__c = quoteline.Id, Pag_WarrantCPQ__c = '1'));
        pagamenti.add(new Pagamenti__c(Pag_WarrantCPQ__c = '1'));
        pagamenti.add(new Pagamenti__c(Quote_Line__c = quoteline.Id, Pag_WarrantCPQ__c = '2'));

        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();

        Map<String,Object> body = new Map<String,Object>{
            'Condizioni' => condizioni,
            'Pagamenti' => Pagamenti
        };
        
        req.requestURI = '/v1.0/InserimentoCondizioniPagamenti';
        req.httpMethod = 'POST';
        // req.requestBody = Blob.valueOf(bodySr);
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        RestInserimentoCondizioniPagamenti.doPost();
        Test.stopTest();
    }

    @isTest
    static void testInserimentoCondizioniPagamentiKO(){
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();

        Map<String,Object> body = new Map<String,Object>{
            'Condizioni' => null,
            'Pagamenti' => null
        };
        
        req.requestURI = '/v1.0/InserimentoCondizioniPagamenti';
        req.httpMethod = 'POST';
        // req.requestBody = Blob.valueOf(bodySr);
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        RestInserimentoCondizioniPagamenti.doPost();
        Test.stopTest();
    }

    @isTest
    static void testInserimentoCondizioniPagamentiKO2(){

        Finanziamenti__c finanziamento = [SELECT Id FROM Finanziamenti__c LIMIT 1];

        List<Condizioni__c> condizioni = new List<Condizioni__c>();
        condizioni.add(new Condizioni__c(Finanziamento__c = finanziamento.Id, Pag_WarrantCPQ__c = '1'));

        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        
        Map<String,Object> body = new Map<String,Object>{
            'Condizioni' => condizioni,
            'Pagamenti' => null
        };

        req.requestURI = '/v1.0/InserimentoCondizioniPagamenti';
        req.httpMethod = 'POST';
        // req.requestBody = Blob.valueOf(bodySr);
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        RestInserimentoCondizioniPagamenti.doPost();
        Test.stopTest();
    }

    @isTest
    static void testInserimentoCondizioniPagamentiKO3(){
        SBQQ__QuoteLine__c quoteline = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        
        List<Condizioni__c> condizioni = new List<Condizioni__c>();
        condizioni.add(new Condizioni__c(Quote_Line__c = quoteline.Id, Pag_WarrantCPQ__c = '1'));

        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();

        Map<String,Object> body = new Map<String,Object>{
            'Condizioni' => condizioni,
            'Pagamenti' => null
        };
        
        req.requestURI = '/v1.0/InserimentoCondizioniPagamenti';
        req.httpMethod = 'POST';
        // req.requestBody = Blob.valueOf(bodySr);
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        RestInserimentoCondizioniPagamenti.doPost();
        Test.stopTest();
    }
}