@isTest
private class TestCRM_GestioneContattiOcsAPI {
    
    static final Id profileSysAdmId = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1].Id;
	static final String recordTypeTopDownMono = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Monostep').getRecordTypeId();
    static final String endpoint_Str = 'https://apigw-test.bper.it:443/gateway/GestioneContattiOcsAPI/v1/gestionecontattiocs/inserisci-contatto';
    static User titolare = AllDataFactory.getUser('14', profileSysAdmId, 'CORPORATE');
    
    @testSetup
    static void setup() {
        Account account = AllDataFactory.getPersonAccount('01');
        account.LastName = 'LastName01';
        account.FirstName = 'FirstName01';
        account.FinServ__BankNumber__c = 'finserv';
        account.CRM_NDG__c  = 'testCRMNDG';
        account.CRM_FilialiRapportoToShow__c = 'CRM_FilialiRapportoToShow**TEST';
        /*account.PTF_IdCedFilialeOnNDG__c = '8888'; FORMULA : IF(
											CRM_NDG__c <> null, IF(PTF_Filiale__c <> null,
														PTF_Filiale__r.PTF_IdCED__c,CRM_FilialiRapportoToShow__c),null)*/
        account.CRM_TaxId__c = 'taxIdm1234556778990000999';
        account.PersonBirthdate = Date.today().addDays(-30);
        account.PersonEmail = 'test01@test.com';
        account.CRM_ResidentialAddress__pc = '1 , 2 , 3'; // 'VIA ,  DELLA ,   MAIELLA';//'2222 , 333 , 444';
        account.Phone = '+392134585212';
        account.PersonMobilePhone = '2134585217';//+392134585217';
        account.CRM_SmartWebMobilePhone__c = '2134585217';
        account.CRM_Phone1__c              = '2134585217';
        account.CRM_Phone2__c              = '2134585217';
        insert account;
        
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
        
        
        titolare.FederationIdentifier = '14';
        titolare.Profilo__c = 'NEC_F.1';
        System.runAs(titolare){
        insert testUser;
        update titolare;//insert new List<User>{ testUser, titolare }; 
        }
        Campaign camp                = AllDataFactory.getCampaign('01', titolare.Id, recordTypeTopDownMono); 
        camp.CRM_NomeAttributo1__c   = null;
        camp.CRM_NomeAttributo2__c   = null;
        insert camp;
        
		insert new Endpoint__c(Name                = 'GestioneContattiOCSApi'
                               , Endpoint__c       = endpoint_Str
                       		   , BodyParams__c     = ''
                               , EndpointParams__c = ''
                               , Method__c         = 'POST'
                               , Timeout__c        = 120000
                              ); 
        insert new CRM_CodiciCatastali__c(Name            = '2'
                                          , CRM_Codice__c = '122'
                                         );
    }
    
    @isTest
    static void test_StatusCode200() {
        
        Id accountId =  [SELECT Id, CRM_NDG__c FROM Account  
                         WHERE CRM_NDG__c  = 'testCRMNDG'].Id;
        Id campingId =  [SELECT Id, Name       FROM Campaign WHERE Name = 'Campaign01'].Id;
        
        CRM_GestioneContattiOcsAPI.FlowInputs v = new CRM_GestioneContattiOcsAPI.FlowInputs();
        v.accountId         = (String) accountId;
        v.codiceSegnalatore = 'test';
        v.campingID         = (String) campingId;
        v.note              = 'Note';
        
        User titolare = [SELECT Id FROm User WHERE FederationIdentifier = '13' LIMIT 1];
        System.runAs(titolare){

            Test.startTest();
            
            Test.setMock( HttpCalloutMock.class, new TestCRM_GestioneContattiOcsAPIMock(200, '{"codice": "204", "messaggio": "Successo"}') );
            
            CRM_GestioneContattiOcsAPI.makeRequest(new List<CRM_GestioneContattiOcsAPI.FlowInputs> {v
                });
            
            Test.stopTest();
        }
    } 
    
    @isTest
    static void test_StatusCode201() {
        
        Id accountId =  [SELECT Id, CRM_NDG__c FROM Account  
                         WHERE CRM_NDG__c  = 'testCRMNDG'].Id;
        Id campingId =  [SELECT Id, Name       FROM Campaign WHERE Name = 'Campaign01'].Id;
        
        CRM_GestioneContattiOcsAPI.FlowInputs v = new CRM_GestioneContattiOcsAPI.FlowInputs();
        v.accountId         = (String) accountId;
        v.codiceSegnalatore = 'test';
        v.campingID         = (String) campingId;
        v.note              = 'Note';
        
        User titolare = [SELECT Id FROm User WHERE FederationIdentifier = '13' LIMIT 1];
        System.runAs(titolare){

            Test.startTest();
            
            Test.setMock( HttpCalloutMock.class, new TestCRM_GestioneContattiOcsAPIMock(201, '{"codice": "204", "messaggio": "Successo"}') );
            
            CRM_GestioneContattiOcsAPI.makeRequest(new List<CRM_GestioneContattiOcsAPI.FlowInputs> {v
                });
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void test_StatusCode201ANDNullBody() {
        
        Id accountId =  [SELECT Id, CRM_NDG__c FROM Account  
                         WHERE CRM_NDG__c  = 'testCRMNDG'].Id;
        Id campingId =  [SELECT Id, Name       FROM Campaign WHERE Name = 'Campaign01'].Id;
        
        CRM_GestioneContattiOcsAPI.FlowInputs v = new CRM_GestioneContattiOcsAPI.FlowInputs();
        v.accountId         = (String) accountId;
        v.codiceSegnalatore = 'test';
        v.campingID         = (String) campingId;
        v.note              = 'Note';
        User titolare = [SELECT Id FROm User WHERE FederationIdentifier = '13' LIMIT 1];
        System.runAs(titolare){

            Test.startTest();
            
            Test.setMock( HttpCalloutMock.class, new TestCRM_GestioneContattiOcsAPIMock(201, '') );
            
            CRM_GestioneContattiOcsAPI.makeRequest(new List<CRM_GestioneContattiOcsAPI.FlowInputs> {v
                });
            
            Test.stopTest();
        }
    } 
}