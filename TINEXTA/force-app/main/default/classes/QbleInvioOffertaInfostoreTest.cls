@isTest
public class QbleInvioOffertaInfostoreTest {

    @TestSetup
    static void makeData(){

        Funzionalita__c f = new Funzionalita__c(Disabilita_Integrazione__c = true);
        insert f;

        Account acc = new Account(Name = 'TestAccountBatchQL');
        acc.Censimento_Manuale__c = true;
        insert acc;

        Opportunity opp = new Opportunity(Name = 'TestQuote', AccountId = acc.Id, CloseDate = System.Today().addDays(30), StageName = 'Proposta /Quotazione prezzi');
        insert opp;

        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c = acc.Id, SBQQ__Primary__c = true, SBQQ__Opportunity2__c = opp.Id, Opportunity_Name__c = 'TestQuote', CloseDate__c = System.Today().addDays(30));
        insert quote;

        Product2 p = new Product2(Name = 'TestProductQLBatch');
        insert p;

        EndpointServizi__c es = new EndpointServizi__c(WRT_Create_CPQ_Infostore__c = 'https://salesforce-test.warranthub.it/v1/Wh/Quote', WRN_Key_IntegrazioneInfoStore__c = 'sm3llsl1k3t33nsp1r1t', WRT_Elimina_Pagamenti_CPQ_Infostore__c = 'https://salesforce-test.warranthub.it/v1/Wh/Quote/Pagamenti/');
        insert es;

        Test.startTest();

        SBQQ__QuoteLine__c quoteline = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = p.Id, Divisione_WarrantCPQ__c = 'FA AUTOMATICA');
        insert quoteline;

        // Finanziamenti__c fin = new Finanziamenti__c(Quote_Line__c = quoteline.Id);
        // insert fin;

        Test.stopTest();

        // Finanziamenti__c fin = new Finanziamenti__c(Quote_Line__c = quoteline.Id);
        // insert fin;
    }

    @isTest
    public static void testBatchOk(){
        SBQQ__QuoteLine__c quoteline = [SELECT Id, SBQQ__Quote__r.SBQQ__Opportunity2__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Product__r.Name = 'TestProductQLBatch'];
        System.debug('@@@ quoteline.SBQQ__Quote__r.SBQQ__Opportunity2__c ' + quoteline.SBQQ__Quote__r.SBQQ__Opportunity2__c);
        // Condizioni__c conPadre = [SELECT Id FROM Condizioni__c WHERE Quote_Line__c =: quoteline.Id];

        // Finanziamenti__c fin = [SELECT Id FROM Finanziamenti__c WHERE Quote_Line__c =: quoteline.Id];
        Finanziamenti__c fin = new Finanziamenti__c(Quote_Line__c = quoteline.Id, Formula_Semaforo_Trigger__c = true);
        insert fin;

        Condizioni__c conPadre = new Condizioni__c(Quote_Line__c = quoteline.Id, Finanziamento__c = fin.Id, Formula_Semaforo_Trigger__c = true);
        insert conPadre;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory(200, 'OK', '{}', new Map<String,String>()));

        Test.startTest();
            Condizione_Opzionale__c conOpz = new Condizione_Opzionale__c(CondizionePadre_WarrantCPQ__c = conPadre.Id, Formula_Semaforo_Trigger__c = true, Percentuale_WarrantCPQ__c = 10);
            insert conOpz;

            Pagamenti__c pag = new Pagamenti__c(Quote_Line__c = quoteline.Id, Condizione_WarrantCPQ__c = conPadre.Id, Formula_Semaforo_Trigger__c = true);
            insert pag;    

            QbleInvioOffertaInfostore job = new QbleInvioOffertaInfostore(new List<String>{String.valueOf(quoteline.Id)});
            System.enqueueJob(job);
        Test.stopTest();
    }

    @isTest
    public static void testBatchKO(){
        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory(200, 'KO', '{}', new Map<String,String>()));

        Test.startTest();
            QbleInvioOffertaInfostore job = new QbleInvioOffertaInfostore(new List<String>{});
            System.enqueueJob(job);
        Test.stopTest();
    }

    @isTest
    public static void testBatchKO2(){
        SBQQ__QuoteLine__c quoteline = [SELECT Id, SBQQ__Quote__r.SBQQ__Opportunity2__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Product__r.Name = 'TestProductQLBatch'];
        System.debug('@@@ quoteline.SBQQ__Quote__r.SBQQ__Opportunity2__c ' + quoteline.SBQQ__Quote__r.SBQQ__Opportunity2__c);
        // Condizioni__c conPadre = [SELECT Id FROM Condizioni__c WHERE Quote_Line__c =: quoteline.Id];

        // Finanziamenti__c fin = [SELECT Id FROM Finanziamenti__c WHERE Quote_Line__c =: quoteline.Id];
        Finanziamenti__c fin = new Finanziamenti__c(Quote_Line__c = quoteline.Id, Formula_Semaforo_Trigger__c = true);
        insert fin;

        Condizioni__c conPadre = new Condizioni__c(Quote_Line__c = quoteline.Id, Finanziamento__c = fin.Id, Formula_Semaforo_Trigger__c = true);
        insert conPadre;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory(200, 'KO', '{ "message": "authentication failure" }', new Map<String,String>()));

        Test.startTest();
            Condizione_Opzionale__c conOpz = new Condizione_Opzionale__c(CondizionePadre_WarrantCPQ__c = conPadre.Id, Formula_Semaforo_Trigger__c = true, Percentuale_WarrantCPQ__c = 10);
            insert conOpz;

            Pagamenti__c pag = new Pagamenti__c(Quote_Line__c = quoteline.Id, Condizione_WarrantCPQ__c = conPadre.Id, Formula_Semaforo_Trigger__c = true);
            insert pag;    

            QbleInvioOffertaInfostore job = new QbleInvioOffertaInfostore(new List<String>{String.valueOf(quoteline.Id)});
            System.enqueueJob(job);
        Test.stopTest();
    }

    @isTest
    public static void testSchedulazione(){
        Test.startTest();
            ScheduleInvioOffertaInfostore job = new ScheduleInvioOffertaInfostore();
            String sch = '0 0 23 * * ?'; 
            System.Schedule('Schedule Invio Offerta Infostore Test', sch, job);
        Test.stopTest();
    }

    @isTest
    public static void testDelete(){
        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory(200, 'OK', '{}', new Map<String,String>()));

        SBQQ__QuoteLine__c quoteline = [SELECT Id, SBQQ__Quote__r.SBQQ__Opportunity2__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Product__r.Name = 'TestProductQLBatch'];
        System.debug('@@@ quoteline.SBQQ__Quote__r.SBQQ__Opportunity2__c ' + quoteline.SBQQ__Quote__r.SBQQ__Opportunity2__c);
        // Condizioni__c conPadre = [SELECT Id FROM Condizioni__c WHERE Quote_Line__c =: quoteline.Id];

        // Finanziamenti__c fin = [SELECT Id FROM Finanziamenti__c WHERE Quote_Line__c =: quoteline.Id];
        Finanziamenti__c fin = new Finanziamenti__c(Quote_Line__c = quoteline.Id, Formula_Semaforo_Trigger__c = true);
        insert fin;

        Condizioni__c conPadre = new Condizioni__c(Quote_Line__c = quoteline.Id, Finanziamento__c = fin.Id, Formula_Semaforo_Trigger__c = true);
        insert conPadre;

        Test.startTest();

        Condizione_Opzionale__c conOpz = new Condizione_Opzionale__c(CondizionePadre_WarrantCPQ__c = conPadre.Id, Formula_Semaforo_Trigger__c = true, Percentuale_WarrantCPQ__c = 10);
        insert conOpz;

        Pagamenti__c pag = new Pagamenti__c(Quote_Line__c = quoteline.Id, Condizione_WarrantCPQ__c = conPadre.Id, Formula_Semaforo_Trigger__c = true);
        insert pag;

        // List<Pagamenti__c> p = new List<Pagamenti__c>([SELECT Id FROM Pagamenti__c LIMIT 1]);
        // System.debug('@@@ p ' + JSON.serialize(p));
        delete pag;
        delete conOpz;
        delete conPadre;
        delete fin;
        // delete [SELECT Id FROM Pagamenti__c LIMIT 1];
        // delete [SELECT Id FROM Condizione_Opzionale__c LIMIT 1];
        // delete [SELECT Id FROM Condizioni__c LIMIT 1];
        // delete [SELECT Id FROM Finanziamenti__c LIMIT 1];
        Test.stopTest();
    }
    
    @isTest
    public static void testSchedulazioneProv1(){
        Test.startTest();
            ScheduleInvioISProvvisoria1 job = new ScheduleInvioISProvvisoria1();
            String sch = '0 0 23 * * ?'; 
            System.Schedule('Schedule Invio Offerta Infostore Test 1', sch, job);
        Test.stopTest();
    }   
}