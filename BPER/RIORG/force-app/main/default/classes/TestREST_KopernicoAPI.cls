@isTest 
private class TestREST_KopernicoAPI {
    
    static final Id profileSysAdmId = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1].Id;
    static final String endpoint_Str = 'https://apigw-test.bper.it:443/gateway/KopernicoAPI/v1/kopernico/recupera-agenzie/?';
    
    @testSetup
    static void setup() {
    	
        User testUser = AllDataFactory.getUser('1123', profileSysAdmId, 'Family');
        testUser.abi__c = '***TST@@@';
        testUser.applicazione__c = 'testApp';
        testUser.ndgsettoriale__c = '000';
        testUser.banca__c = 'test banca';
        testUser.terminale__c = 'terminal di tst';
        testUser.idced__c     = 'idc di test';
        testUser.ip__c = 'ipt';
        testUser.cab__c = 'cab di tst';
        testUser.branchcode__c = '8888888dseeer';
        testUser.userid__c     = '5555rr';
        testUser.sessionId__c  = 'sessione di test';
        testUser.operationId__c = 'operation di test';
        testUser.sysCaller__c   = 'sysCal di test';
        testUser.fnCaller__c    = 'fn-sysCal di test';
        testUser.serviceName__c = 'servicename di test';
        testUser.fnName__c      = 'fn-name di test';
        testUser.Token__c       = 'TOKEN_USATO_SOLO_PER_IL_TEST++++';
        testUser.idApplicazione__c = 'idApp_USATO_SOLO_PER_IL_TEST++++';
        testUser.esb_idCed__c     = 'esb di test';
        testUser.esb_operatore__c = 'esb operatore';
        testUser.esb_IP__c        = 'esb ip di test';
        testUser.serviceImplClass__c = 'service di tst';
        testUser.serviceClient__c    = 'ServiceCl test';
        testUser.TermId__c           = 'term id test';
        testUser.customerId__c       = 'customer id per il test';
        testUser.ServiceVersion__c   = 'ServiceVesion in fase di test';
        //testUser.Matricola6CifreFormula__c = 'matr_di_test';
        testUser.FederationIdentifier = '13'; 
        insert testUser;
        
		insert new Endpoint__c(Name                = 'KopernicoAPI'
                               , Endpoint__c       = endpoint_Str
                       		   , BodyParams__c     = ''
                               , EndpointParams__c = '{"numeroPagina":"1","numeroMaxElementiPerPagina":"0","agenziaAttiva":"true"}'
                               , Method__c         = 'GET'
                               , Timeout__c        = 120000
                              ); 
    }
    
    @isTest 
    static void test() {
        
        REST_KopernicoAPI.FlowInputs v = new REST_KopernicoAPI.FlowInputs();
        v.codiceSegnalatore = 'Codice usato per il test';
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestREST_KopernicoAPIMock());
        System.debug('SET Mock OK***');
        
        
        REST_KopernicoAPI.makeRequest(new List<REST_KopernicoAPI.FlowInputs>{ v });
        Test.stopTest();
    }

}