@isTest
public with sharing class Batch_AllineaMonteOreGenesysTest {

    public static final string PROFILE_NAME_LIKE = '%Contact Center';

    @TestSetup
    static void makeData(){
        
        List <Endpoint__c> listEndpoint = new List <Endpoint__c>();

        Funzionalita__c funzionalita = new Funzionalita__c();
        funzionalita.isETL__c = false;
        insert funzionalita;

        Endpoint__c endpoint = new Endpoint__c();
        endpoint.Name = 'GenesysToken';
        endpoint.Method__c = 'POST';
        endpoint.Timeout__c = 120000;
        endpoint.Endpoint__c = 'https://login.mypurecloud.de/oauth/token';
        listEndpoint.add(endpoint);

        Endpoint__c endpoint2 = new Endpoint__c();
        endpoint2.Name = 'EstrazioneUtenteGenesys';
        endpoint2.Method__c = 'POST';
        endpoint2.Timeout__c = 120000;
        endpoint2.Endpoint__c = 'https://api.mypurecloud.de/api/v2/users/search';
        listEndpoint.add(endpoint2);

        Endpoint__c endpoint3 = new Endpoint__c();
        endpoint3.Name = 'UpdateMonteOreGenesys';
        endpoint3.Method__c = 'PATCH';
        endpoint3.Timeout__c = 120000;
        endpoint3.Endpoint__c = 'https://api.mypurecloud.de/api/v2/users/{userId}';
        listEndpoint.add(endpoint3);

        Endpoint__c endpoint4 = new Endpoint__c();
        endpoint4.Name = 'ManagementBusinessUnitGenesys';
        endpoint4.Method__c = 'GET';
        endpoint4.Timeout__c = 120000;
        endpoint4.Endpoint__c = 'https://api.mypurecloud.de/api/v2/workforcemanagement/agents/{agentId}/managementunit';
        listEndpoint.add(endpoint4);

        insert listEndpoint;

        softphone_it__Connector_Settings__c cs= new softphone_it__Connector_Settings__c();
        cs.Name=UserInfo.getOrganizationId().left(15);
        cs.softphone_it__GC_CLIENT_ID__c='test';
        cs.softphone_it__GC_CLIENT_SECRET__c='test';
        insert cs;

        Profile profile = [SELECT id FROM Profile WHERE Name LIKE :PROFILE_NAME_LIKE LIMIT 1];
        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        insert user;
    }

    @IsTest
    static void testExecute(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Batch_AllineaMonteOreGenesys b = new Batch_AllineaMonteOreGenesys();
        Database.executeBatch(b);
        Test.stopTest();
        
    }
}