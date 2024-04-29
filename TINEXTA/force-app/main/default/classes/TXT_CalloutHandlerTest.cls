@isTest
public with sharing class TXT_CalloutHandlerTest {

    @TestSetup
    static void makeData(){
        EndpointServizi__c endpoints = new EndpointServizi__c();
        endpoints.TXT_BusinessInformation__c = 'http://collaudo-ws.ribes.it/wsrbs/services/BInformationV4.BInformationV4HttpSoap11Endpoint/';
        endpoints.TXT_EventiNegativi__c = 'http://collaudo-ws.ribes.it/wsrbs/services/EventiNegativi.EventiNegativiHttpSoapEndpoint/';
        endpoints.TXT_ServiziCamerali__c = 'https://collaudo-ws.ribes.it/wsrbs/services/ServiziCameraliV1?wsdl';
        insert endpoints;

        UtenzeDefault__c credentials = new UtenzeDefault__c();
        credentials.TXT_Innolva_EndPoint_User__c = 'TINEXTA-WS';
        credentials.TXT_Innolva_EndPoint_Password__c = 'pwdcollaudo';
        credentials.Id_User_Segreteria_Commerciale__c = '132452215';
        insert credentials;
    }

    @isTest static void testGetListaAziende() {

        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new TXT_CalloutHandlerTestMock(1));
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        List<Account> accts = TXT_CalloutHandler.executeCall(1,'Merloni Holding','IT');
        
        System.debug('Account: ' + accts);
        TXT_CalloutHandler c = new TXT_CalloutHandler();
        Test.stopTest();
    }

    @isTest static void testGetListaAziende2() {

        // EndpointServizi__c endpoints = new EndpointServizi__c();
        // endpoints.TXT_BusinessInformation__c = 'http://collaudo-ws.ribes.it/wsrbs/services/BInformationV4.BInformationV4HttpSoap11Endpoint/';
        // endpoints.TXT_EventiNegativi__c = 'http://collaudo-ws.ribes.it/wsrbs/services/EventiNegativi.EventiNegativiHttpSoapEndpoint/';
        // insert endpoints;

        // UtenzeDefault__c credentials = new UtenzeDefault__c();
        // credentials.TXT_Innolva_EndPoint_User__c = 'TINEXTA-WS';
        // credentials.TXT_Innolva_EndPoint_Password__c = 'pwdcollaudo';
        // insert credentials;

        Test.startTest();
        List<Account> accts = new List<Account>();

        Test.setMock(HttpCalloutMock.class, new TXT_CalloutHandlerTestMock(4));
        accts = TXT_CalloutHandler.executeCall(1,'Merloni Holding','IT');

        System.debug('Account: ' + accts);

        Test.stopTest();
    }

    @isTest static void testGetListaAziende2_WithLogs() {

        // EndpointServizi__c endpoints = new EndpointServizi__c();
        // endpoints.TXT_BusinessInformation__c = 'http://collaudo-ws.ribes.it/wsrbs/services/BInformationV4.BInformationV4HttpSoap11Endpoint/';
        // endpoints.TXT_EventiNegativi__c = 'http://collaudo-ws.ribes.it/wsrbs/services/EventiNegativi.EventiNegativiHttpSoapEndpoint/';
        // insert endpoints;

        // UtenzeDefault__c credentials = new UtenzeDefault__c();
        // credentials.TXT_Innolva_EndPoint_User__c = 'TINEXTA-WS';
        // credentials.TXT_Innolva_EndPoint_Password__c = 'pwdcollaudo';
        // insert credentials;

        List<Account> accs = new List<Account>();
        Account acct = new Account();
        acct.name = 'Test';
        acct.CCIAA_CMK__c = '12345';
        acct.CCIAA_REA__c = 'TE';
        accs.add(acct);

        Log__c l = new Log__c(
            Ricerca_JSON__c = JSON.serialize(accs),
            Duplicate_Ricerca__c = 'Merloni HoldingIT'
        );
        insert l;

        Test.startTest();
        List<Account> accts = new List<Account>();

        Test.setMock(HttpCalloutMock.class, new TXT_CalloutHandlerTestMock(4));
        accts = TXT_CalloutHandler.executeCall(1,'Merloni Holding','IT');

        System.debug('Account: ' + accts);

        Test.stopTest();
    }

    @isTest static void testGetListaAziendeEstero() {
        // EndpointServizi__c endpoints = new EndpointServizi__c();
        // endpoints.TXT_BusinessInformation__c = 'http://collaudo-ws.ribes.it/wsrbs/services/BInformationV4.BInformationV4HttpSoap11Endpoint/';
        // endpoints.TXT_EventiNegativi__c = 'http://collaudo-ws.ribes.it/wsrbs/services/EventiNegativi.EventiNegativiHttpSoapEndpoint/';
        // insert endpoints;

        // UtenzeDefault__c credentials = new UtenzeDefault__c();
        // credentials.TXT_Innolva_EndPoint_User__c = 'TINEXTA-WS';
        // credentials.TXT_Innolva_EndPoint_Password__c = 'pwdcollaudo';
        // insert credentials;


        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new TXT_CalloutHandlerTestMock(2));
        List<Account> accts = TXT_CalloutHandler.executeCall(1,'Amazon','FR');
        
        System.debug('Account: ' + accts);
        Test.stopTest();
    }

    @isTest static void testGetProdottoPG() {
        // EndpointServizi__c endpoints = new EndpointServizi__c();
        // endpoints.TXT_BusinessInformation__c = 'http://collaudo-ws.ribes.it/wsrbs/services/BInformationV4.BInformationV4HttpSoap11Endpoint/';
        // endpoints.TXT_EventiNegativi__c = 'http://collaudo-ws.ribes.it/wsrbs/services/EventiNegativi.EventiNegativiHttpSoapEndpoint/';
        // insert endpoints;

        // UtenzeDefault__c credentials = new UtenzeDefault__c();
        // credentials.TXT_Innolva_EndPoint_User__c = 'TINEXTA-WS';
        // credentials.TXT_Innolva_EndPoint_Password__c = 'pwdcollaudo';
        // insert credentials;

        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new TXT_CalloutHandlerTestMock(3));
        Account acct = new Account();
        acct.name = 'Test';
        acct.CCIAA_CMK__c = '12345';
        acct.CCIAA_REA__c = 'TE';
        acct = TXT_CalloutHandler.getProdottoPG(acct);
        
        System.debug('Account: ' + acct);

        Test.stopTest();
    }

    @isTest static void testGetProdottoPG_WithLogs() {
        // EndpointServizi__c endpoints = new EndpointServizi__c();
        // endpoints.TXT_BusinessInformation__c = 'http://collaudo-ws.ribes.it/wsrbs/services/BInformationV4.BInformationV4HttpSoap11Endpoint/';
        // endpoints.TXT_EventiNegativi__c = 'http://collaudo-ws.ribes.it/wsrbs/services/EventiNegativi.EventiNegativiHttpSoapEndpoint/';
        // insert endpoints;

        // UtenzeDefault__c credentials = new UtenzeDefault__c();
        // credentials.TXT_Innolva_EndPoint_User__c = 'TINEXTA-WS';
        // credentials.TXT_Innolva_EndPoint_Password__c = 'pwdcollaudo';
        // insert credentials;

        Account acct = new Account();
        acct.name = 'Test';
        acct.CCIAA_CMK__c = '12345';
        acct.CCIAA_REA__c = 'TE';

        Log__c l = new Log__c(
            Account_JSON__c = JSON.serialize(acct),
            DuplicateCCIAAREA__c = acct.CCIAA_CMK__c+acct.CCIAA_REA__c
        );
        insert l;

        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new TXT_CalloutHandlerTestMock(3));
        acct = TXT_CalloutHandler.getProdottoPG(acct);
        
        System.debug('Account: ' + acct);

        Test.stopTest();
    }
    
@isTest static void testGetProdottoPG_ArricchimentoAction() {

        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new TXT_CalloutHandlerTestMock(3));
        Account acct = new Account();
        acct.name = 'Test';
        acct.CCIAA_CMK__c = '12345';
        acct.CCIAA_REA__c = 'TE';
        acct.Errore_Monitoraggio__c = true;
        acct.Data_Ultimo_Arricchimento__c = System.Today();
        insert acct;
        Map<String,Object> resp = TXT_CalloutHandler.arricchimentoActionBatch();
        
        System.debug('Account: ' + resp);

        Test.stopTest();
    }

    @isTest static void testGetProdottoPG_ArricchimentoAction_Error() {

        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new TXT_CalloutHandlerTestMock(3));
        Account acct = new Account();
        acct.name = 'error';
        acct.CCIAA_CMK__c = '12345';
        acct.CCIAA_REA__c = 'TE';
        acct.Errore_Monitoraggio__c = true;
        acct.Data_Ultimo_Arricchimento__c = System.Today();
        insert acct;
        Map<String,Object> resp = TXT_CalloutHandler.arricchimentoActionBatch();
        
        System.debug('Account: ' + resp);

        Test.stopTest();
    }

    @isTest
    static void testCacheHit() {

        Account acct = new Account(CCIAA_CMK__c = 'MI', CCIAA_REA__c = '123');
        Cache.Org.put(acct.CCIAA_CMK__c+acct.CCIAA_REA__c, acct.CCIAA_CMK__c+acct.CCIAA_REA__c, 600);
        Test.startTest();
            TXT_CalloutHandler.handleSessionCacheArricchimento(acct);
        Test.stopTest();
    }

    @isTest
    static void testCacheMiss() {
        Account acct = new Account(CCIAA_CMK__c = 'MI', CCIAA_REA__c = '123');
        Test.startTest();
            TXT_CalloutHandler.handleSessionCacheArricchimento(acct);
        Test.stopTest();
    }

    @isTest
    static void testVisura()
    {
        Account acct = new Account();
        acct.name = 'Test';
        acct.CCIAA_CMK__c = '12345';
        acct.CCIAA_REA__c = 'TE';
        acct.Errore_Monitoraggio__c = true;
        acct.Data_Ultimo_Arricchimento__c = System.Today();
        insert acct;
        
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new TXT_CalloutHandlerTestMock(6));
        
        string resp = TXT_CalloutHandler.getVisuraCamerale(acct.id);

        account acc = TXT_CalloutHandler.getAccount(acct.id);
        
        System.debug('Account: ' + resp);

        Test.stopTest();
    }
}