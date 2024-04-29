@isTest
public with sharing class syncUserGenesysControllerTest {

public static final string PROFILE_NAME_LIKE = '%Contact Center';

@TestSetup
static void makeData(){

    Profile profile = [SELECT id FROM Profile WHERE Name LIKE :PROFILE_NAME_LIKE LIMIT 1];
    User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
    insert user;

    List <Endpoint__c> listEndpoint = new List <Endpoint__c>();

    Endpoint__c endpoint = new Endpoint__c();
    endpoint.Name = 'GenesysToken';
    endpoint.Method__c = 'POST';
    endpoint.Timeout__c = 120000;
    endpoint.Endpoint__c = 'https://login.mypurecloud.de/oauth/token';
    listEndpoint.add(endpoint);

    Endpoint__c endpoint2 = new Endpoint__c();
    endpoint2.Name = 'ManagementBusinessUnitGenesys';
    endpoint2.Method__c = 'GET';
    endpoint2.Timeout__c = 120000;
    endpoint2.Endpoint__c = 'https://api.mypurecloud.de/api/v2/workforcemanagement/agents/{agentId}/managementunit';
    listEndpoint.add(endpoint2);

    insert listEndpoint;

    softphone_it__Connector_Settings__c cs= new softphone_it__Connector_Settings__c();
    cs.Name=UserInfo.getOrganizationId().left(15);
    cs.softphone_it__GC_CLIENT_ID__c='test';
    cs.softphone_it__GC_CLIENT_SECRET__c='test';
    insert cs;
}

    @IsTest
    static void getGestoriListTest(){

        Test.startTest();
        syncUserGenesysController.getGestoriList(PROFILE_NAME_LIKE);
        Test.stopTest();
        
    }

    @IsTest
    static void syncNewUtentiTest(){

        List<User> listUser = [SELECT Id, Name, FederationIdentifier, CRM_DataultimasyncGenesys__c, CRM_GenesysID__c, CRM_ManagementID__c, CRM_BusinessUnitID__c 
                                FROM User 
                                WHERE profile.Name LIKE :PROFILE_NAME_LIKE
                                LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        String result = syncUserGenesysController.syncNewUtenti(listUser[0].Id);
        Test.stopTest();
        
    }

    @IsTest
    static void writeLogTest(){

        insert syncUserGenesysController.writeLog(
            'TestWriteLog',
            'GET',
            null,
            200,
            'OK',
            '',
            new Map<String, String>{'headerKey' => 'headerValue'},
            new Map<String, String>{'headerKey' => 'headerValue'},
            'endpoint',
            ''
            // responseObj.isCorrect() ? null : responseObj.getErrors()
        );
    }

}