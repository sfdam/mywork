@isTest
public class RestAggiornamentoRigheTest {

    @TestSetup
    static void makeData(){

        Funzionalita__c x = new Funzionalita__c();
        x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_tutti_i_trigger__c = false;
        insert x;

        Schema.DescribeSObjectResult d = Schema.SObjectType.Account; 
        Id rtAccount = d.getRecordTypeInfosByName().get('Warrant').getRecordTypeId();
        Account acc = new Account(Name = 'TestInserimentoOfferta', RecordTypeId = rtAccount, Censimento_Manuale__c  = true);
        insert acc;

        Product2 p = new Product2(Name = 'TestProdAgg', Cluster_Tagetik__c = 'FINANZA DI IMPRESA');
        insert p;

        SBQQ__Quote__c q = new SBQQ__Quote__c(SBQQ__Account__c = acc.Id, SBQQ__Primary__c = true);
        insert q;
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = p.Id, Tipo_Mandato__c = 'Singolo', Divisione_WarrantCPQ__c = '1104244169');
        insert ql;
        Finanziamenti__c fin = new Finanziamenti__c(Quote_Line__c = ql.Id);
        insert fin;
        Condizioni__c c = new Condizioni__c(Quote_Line__c = ql.Id);
        insert c;
    }

    @isTest
    static void aggiornamentoRigheOk(){
        List<SObject> records = new List<SObject>();

        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'TestProdAgg'];

        SBQQ__QuoteLine__c ql = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Product__c =: p.Id];
        records.add(ql);
        Finanziamenti__c f = [SELECT Id FROM Finanziamenti__c WHERE Quote_Line__c =: ql.Id];
        records.add(f);
        Condizioni__c c = [SELECT Id FROM Condizioni__c WHERE Quote_Line__c =: ql.Id];

        Test.startTest();
        Condizione_Opzionale__c co = new Condizione_Opzionale__c(CondizionePadre_WarrantCPQ__c = c.Id, Percentuale_WarrantCPQ__c = 10);
        insert co;
        Pagamenti__c pag = new Pagamenti__c(Condizione_WarrantCPQ__c = c.Id, Quote_Line__c = ql.Id);
        insert pag;

        records.add(c);
        records.add(co);
        records.add(pag);
        // Condizione_Opzionale__c co = [SELECT Id FROM Condizione_Opzionale__c WHERE CondizionePadre_WarrantCPQ__r.Quote_Line__c =: ql.Id];
        // records.add(co);
        // Pagamenti__c pag = [SELECT Id FROM Pagamenti__c WHERE Condizione_WarrantCPQ__r.Quote_Line__c =: ql.Id];
        // records.add(pag);

        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        
        req.requestURI = '/v1.0/AggiornamentoRigheOfferta';
        req.httpMethod = 'POST';
        // req.requestBody = Blob.valueOf(bodySr);
        RestContext.request = req;
        RestContext.response = res;

        // Test.startTest();
        RestAggiornamentoRighe.doPost(records);
        Test.stopTest();
    }

    @isTest
    static void aggiornamentoRigheKo(){
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        
        req.requestURI = '/v1.0/AggiornamentoRigheOfferta';
        req.httpMethod = 'POST';
        // req.requestBody = Blob.valueOf('null');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            RestAggiornamentoRighe.doPost(new List<SObject>());
        Test.stopTest();
    }
}