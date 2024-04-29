@isTest
public class RestInserimentoOffertaInfostoreTest {

    @TestSetup
    static void makeData(){
        Schema.DescribeSObjectResult d = Schema.SObjectType.Account; 
        Id rtAccount = d.getRecordTypeInfosByName().get('Warrant').getRecordTypeId();
        Account acc = new Account(Name = 'TestInserimentoOfferta', RecordTypeId = rtAccount, Data_Ultimo_Arricchimento__c = System.Today());
        insert acc;

        Funzionalita__c x = new Funzionalita__c();
        x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_tutti_i_trigger__c = true;
        x.Disabilita_Integrazione__c = true;
        insert x;

        Product2 p = new Product2(Name = 'TestProd');
        insert p;

    }

    @isTest
    static void inserimentoOffertaOK(){
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'test_inserimentoofferta'];

        String bodySr = sr.Body.toString();
        String prodId = [SELECT Id FROM Product2 WHERE Name = 'TestProd'].Id;
        String accId = [SELECT Id FROM Account WHERE Name = 'TestInserimentoOfferta'].Id;

        // Pricebook2 stdPb = [select Id from Pricebook2 where isStandard=true limit 1];
        Pricebook2 warrantPb = new Pricebook2(Name = 'Prodotti Warrant', IsActive = true);
        insert warrantPb;

        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prodId, UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        PricebookEntry pe = new PricebookEntry(pricebook2id = warrantPb.id, product2id = prodId,unitprice=1.0, isActive=true);
        insert pe;

        bodySr = bodySr.replace('#SBQQ__Account__c#', '"SBQQ__Account__c": "' + accId + '", ');
        bodySr = bodySr.replace('#SBQQ__PricebookId__c#', '"SBQQ__PricebookId__c": "' + warrantPb.Id + '", ');
        // bodySr = bodySr.replace('#PricebookEntryId#', '"PricebookEntryId": "' + accId + '", ');
        bodySr = bodySr.replace('#SBQQ__Product__c#', '"SBQQ__Product__c": "' + prodId + '", ');


        // bodySr = bodySr.replaceFirst('},', '},"SBQQ__Product__c":"'+ prodId +'",');

        System.debug('@@@ bodySr ' + bodySr);

        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        
        req.requestURI = '/v1.0/InserimentoOfferta';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(bodySr);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            // SBQQ.TriggerControl.disable();
            RestInserimentoOffertaInfostore.doPost();
            // SBQQ.TriggerControl.enable();
        Test.stopTest();
    }

    @isTest
    static void inserimentoOffertaKO(){
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        
        req.requestURI = '/v1.0/InserimentoOfferta';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('null');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();        
            RestInserimentoOffertaInfostore.doPost();
        Test.stopTest();
    }
}