@isTest
public with sharing class onAssenzeTriggerHandlerTest {

    public static final string PROFILE_NAME_LIKE = '%Contact Center';

    public static final Boolean isFirstTime = true;
    
    @TestSetup
    static void makeData(){
        
        List <Endpoint__c> listEndpoint = new List <Endpoint__c>();

        Funzionalita__c funzionalita = new Funzionalita__c();
        funzionalita.isETL__c = false;
        insert funzionalita;
        CRM_Assenze__c testAssenza = new CRM_Assenze__c();
        insert testAssenza;
        Test.startTest();
        testAssenza.CRM_SyncGenesysDelete__c = true; 
        update testAssenza;
        Test.stopTest();

        Endpoint__c endpoint = new Endpoint__c();
        endpoint.Name = 'GenesysToken';
        endpoint.Method__c = 'POST';
        endpoint.Timeout__c = 120000;
        endpoint.Endpoint__c = 'https://login.mypurecloud.de/oauth/token';
        listEndpoint.add(endpoint);

        Endpoint__c endpoint2 = new Endpoint__c();
        endpoint2.Name = 'EstrazioneCodiceTimeoff';
        endpoint2.Method__c = 'GET';
        endpoint2.Timeout__c = 120000;
        endpoint2.Endpoint__c = 'https://api.mypurecloud.de/api/v2/workforcemanagement/businessunits/{businessUnitId}/activitycodes';
        listEndpoint.add(endpoint2);

        Endpoint__c endpoint3 = new Endpoint__c();
        endpoint3.Name = 'Inserimento richiesta timeoff';
        endpoint3.Method__c = 'POST';
        endpoint3.Timeout__c = 120000;
        endpoint3.Endpoint__c = 'https://api.mypurecloud.de/api/v2/workforcemanagement/managementunits/{managementUnitId}/timeoffrequests';
        listEndpoint.add(endpoint3);

        Endpoint__c endpoint4 = new Endpoint__c();
        endpoint4.Name = 'UpdateTimeoff';
        endpoint4.Method__c = 'PATCH';
        endpoint4.Timeout__c = 120000;
        endpoint4.Endpoint__c = 'https://api.mypurecloud.de/api/v2/workforcemanagement/managementunits/{managementUnitId}/users/{userId}/timeoffrequests/{timeOffRequestId}';
        listEndpoint.add(endpoint4);

        insert listEndpoint;

        softphone_it__Connector_Settings__c cs= new softphone_it__Connector_Settings__c();
        cs.Name=UserInfo.getOrganizationId().left(15);
        cs.softphone_it__GC_CLIENT_ID__c='test';
        cs.softphone_it__GC_CLIENT_SECRET__c='test';
        insert cs;

        Profile profile = [SELECT id FROM Profile WHERE Name LIKE :PROFILE_NAME_LIKE LIMIT 1];
        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        user.CRM_GenesysID__c = 'test';
        insert user;

    }

    @isTest
    static void testGenesysQueueDeleteCallout() {
        CRM_Assenze__c testRecord = new CRM_Assenze__c();
        insert testRecord;

        Map<Id, CRM_Assenze__c> testMap = new Map<Id, CRM_Assenze__c>();
        testMap.put(testRecord.Id, testRecord);

        Test.startTest();
        onAssenzeTriggerHandler.genesysQueueDeleteCallout(testMap);
        Test.stopTest();

        
    }


    @IsTest
    static void handleAfterInsert_SuccessfulScenario(){
        List<User> listUser = [SELECT Id, Name, FederationIdentifier, CRM_DataultimasyncGenesys__c, CRM_GenesysID__c, CRM_ManagementID__c, CRM_BusinessUnitID__c 
                                FROM User 
                                WHERE profile.Name LIKE :PROFILE_NAME_LIKE
                                LIMIT 1];
        
            CRM_Assenze__c assenza = new CRM_Assenze__c(
            CRM_User__c = listUser[0].Id,
            CRM_Inizioassenza__c = DateTime.newInstance(Date.today(), Time.newInstance(3, 3, 3, 0)),
            CRM_FineAssenza__c = DateTime.newInstance(Date.today(), Time.newInstance(4, 4, 4, 0))
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        insert assenza;
        Test.stopTest();
    }

    @IsTest
    static void handleAfterInsert_AuthenticationFailure(){
        List<User> listUser = [SELECT Id, Name, FederationIdentifier, CRM_DataultimasyncGenesys__c, CRM_GenesysID__c, CRM_ManagementID__c, CRM_BusinessUnitID__c 
                                FROM User 
                                WHERE profile.Name LIKE :PROFILE_NAME_LIKE
                                LIMIT 1];
        
        CRM_Assenze__c assenza = new CRM_Assenze__c(
            CRM_User__c = listUser[0].Id,
            CRM_Inizioassenza__c = DateTime.newInstance(Date.today(), Time.newInstance(3, 3, 3, 0)),
            CRM_FineAssenza__c = DateTime.newInstance(Date.today(), Time.newInstance(4, 4, 4, 0))
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponse());
        insert assenza;
        Test.stopTest();
    }

    @IsTest
    static void estrazioneVSGenesys_Test() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name LIKE :PROFILE_NAME_LIKE LIMIT 1];
        CRM_Assenze__c testAssenza = new CRM_Assenze__c(
            CRM_User__c = testUser.Id,
            CRM_Inizioassenza__c = DateTime.newInstance(Date.today(), Time.newInstance(3, 3, 3, 0)),
            CRM_FineAssenza__c = DateTime.newInstance(Date.today(), Time.newInstance(4, 4, 4, 0)),
            CRM_Giornataintera__c = 'G'
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        insert testAssenza;
        Test.stopTest();
    }

    @IsTest
    static void testEstrazioneVSGenesys() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        List<String> params = new List<String>{'mockCrmManagementId', 'mockCrmGenesysId', 'mockActivityCodeId', 'mockDate', 'mockDuration'};
        String giornataInter = 'G';

        HttpResponse response = onAssenzeTriggerHandler.estrazioneVSGenesys(params, giornataInter);
        Test.stopTest();  
    }

    @IsTest
    static void testHandleAfterInsert() {
        
        List<User> listUser = [SELECT Id, Name, FederationIdentifier, CRM_DataultimasyncGenesys__c, CRM_GenesysID__c, CRM_ManagementID__c, CRM_BusinessUnitID__c 
        FROM User 
        WHERE profile.Name LIKE :PROFILE_NAME_LIKE
        LIMIT 1];

        CRM_Assenze__c assenza = new CRM_Assenze__c(
        CRM_User__c = listUser[0].Id,
        CRM_Inizioassenza__c = DateTime.newInstance(Date.today(), Time.newInstance(3, 3, 3, 0)),
        CRM_FineAssenza__c = DateTime.newInstance(Date.today(), Time.newInstance(4, 4, 4, 0))
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Set<Id> setIdsCRMAssenze = new Set<Id>{assenza.Id};

        onAssenzeTriggerHandler.handleAfterInsert(setIdsCRMAssenze);
        Test.stopTest();
    }

    @IsTest
    static void testHandleAfterUpdate() {
        
        List<User> listUser = [SELECT Id, Name, FederationIdentifier, CRM_DataultimasyncGenesys__c, CRM_GenesysID__c, CRM_ManagementID__c, CRM_BusinessUnitID__c 
        FROM User 
        WHERE profile.Name LIKE :PROFILE_NAME_LIKE
        LIMIT 1];

        CRM_Assenze__c assenza = new CRM_Assenze__c(
        CRM_User__c = listUser[0].Id,
        CRM_Inizioassenza__c = DateTime.newInstance(Date.today(), Time.newInstance(3, 3, 3, 0)),
        CRM_FineAssenza__c = DateTime.newInstance(Date.today(), Time.newInstance(4, 4, 4, 0))
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Set<Id> setIdsCRMAssenze = new Set<Id>{assenza.Id};

        onAssenzeTriggerHandler.handleAfterUpdate(setIdsCRMAssenze);
        Test.stopTest();
    }

    @IsTest
    static void testupdateTimeoffVS() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        List<String> params = new List<String>{'mockCrmManagementId', 'mockCrmGenesysId', 'mockActivityCodeId'};

        HttpResponse response = onAssenzeTriggerHandler.updateTimeoffVS(params);
        Test.stopTest();  
    }

    

    
    /*public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"example": "response"}');
            return res;
        }
    }*/


    public class MockHttpErrorResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(401); 
            return res;
        }
    }
}