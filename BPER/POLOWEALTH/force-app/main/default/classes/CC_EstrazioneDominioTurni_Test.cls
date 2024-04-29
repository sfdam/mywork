@IsTest
private class CC_EstrazioneDominioTurni_Test {

    static void makeData() {
        Endpoint__c endpoint = new Endpoint__c();
        endpoint.Name = 'GenesysToken';
        endpoint.Method__c = 'POST';
        endpoint.Timeout__c = 120000;
        endpoint.Endpoint__c = 'https://login.mypurecloud.de/oauth/token';
        insert endpoint;
    }

    @IsTest
    static void testBatchExecution() {
        User testUser = new User(
            FirstName = 'Test1',
            LastName = 'User',
            ProfileId = UserInfo.getProfileId(),
            CRM_GenesysID__c = 'TestGenesysID',
            CRM_BusinessUnitID__c = 'TestBusinessUnitID',
            Username = 'testDominio2@example.com',
            Email = 'testuser@example.com',
            Alias = 'testuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        Test.startTest();
        CC_EstrazioneDominioTurni batch = new CC_EstrazioneDominioTurni();
        Database.executeBatch(batch);
        Test.stopTest();
    }

    @IsTest
    static void testExecute() {
        User user1 = new User(CRM_GenesysID__c = 'GenesysID1', CRM_BusinessUnitID__c = 'BusinessUnitID1');
        User user2 = new User(CRM_GenesysID__c = 'GenesysID2', CRM_BusinessUnitID__c = 'BusinessUnitID2');
        List<User> scope = new List<User>{ user1, user2 };

        CC_EstrazioneDominioTurni batch = new CC_EstrazioneDominioTurni();
        Test.startTest();
        batch.execute(null, scope);
        Test.stopTest();

    }

    @IsTest
    static void testExecuteWithMultipleKeys() {
        User user1 = new User(CRM_BusinessUnitID__c = 'BusinessUnitID1');
        User user2 = new User(CRM_BusinessUnitID__c = 'BusinessUnitID2');
        List<User> scope = new List<User>{ user1, user2 };

        CC_EstrazioneDominioTurni batch = new CC_EstrazioneDominioTurni();
        Test.startTest();
        batch.execute(null, scope);
        Test.stopTest();

    }

    @IsTest
    static void testExecuteWithSingleKey() {
        User user1 = new User(CRM_BusinessUnitID__c = 'BusinessUnitID');
        User user2 = new User(CRM_BusinessUnitID__c = 'BusinessUnitID');
        List<User> scope = new List<User>{ user1, user2 };

        CC_EstrazioneDominioTurni batch = new CC_EstrazioneDominioTurni();
        Test.startTest();
        batch.execute(null, scope);
        Test.stopTest();

    }

    @IsTest
    static void testAuthVsGenesys() {
        Endpoint__c apiRequest = new Endpoint__c(
            Name = 'GenesysToken',
            Method__c = 'POST',
            Endpoint__c = 'https://login.mypurecloud.de/oauth/token'
        );
        insert apiRequest;

        User testUser = new User(
            FirstName = 'Test1',
            LastName = 'User',
            ProfileId = UserInfo.getProfileId(),
            CRM_GenesysID__c = 'TestGenesysID',
            CRM_BusinessUnitID__c = 'TestBusinessUnitID',
            Username = 'testDominio2@example.com',
            Email = 'testuser@example.com',
            Alias = 'testuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();

        HttpResponse response = CC_EstrazioneDominioTurni.authVsGenesys();

        System.assertEquals(200, response.getStatusCode());

        Test.stopTest();
    }

    @IsTest
    static void testEstrazioneVSGenesys() {
        Endpoint__c apiRequest = new Endpoint__c();
        apiRequest.Name = 'EstrazioneCodiceTimeoff';
        apiRequest.Endpoint__c = 'https://example.com/api/{businessUnitId}/timeoff';
        apiRequest.Method__c = 'GET';
        insert apiRequest;
        
        User testUser = new User(
            FirstName = 'Test1',
            LastName = 'User',
            ProfileId = UserInfo.getProfileId(),
            CRM_GenesysID__c = 'TestGenesysID',
            CRM_BusinessUnitID__c = 'TestBusinessUnitID',
            Username = 'testDominio2@example.com',
            Email = 'testuser@example.com',
            Alias = 'testuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        List<String> params = new List<String>{
            testUser.CRM_BusinessUnitID__c + '_' + testUser.CRM_GenesysID__c
        };

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
        Test.startTest();

        HttpResponse response = CC_EstrazioneDominioTurni.estrazioneVSGenesys(params);
    
        System.assertEquals(200, response.getStatusCode());

        Test.stopTest();
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');
    
            Map<String, Object> jsonResponse = new Map<String, Object>();
            List<Object> entities = new List<Object>{
                new Map<String, Object>{
                    'name' => 'Activity1',
                    'id' => '001'
                },
                new Map<String, Object>{
                    'name' => 'Activity2',
                    'id' => '002'
                }
            };
            jsonResponse.put('entities', entities);
    
            String responseBody = JSON.serialize(jsonResponse);
            response.setBody(responseBody);
    
            return response;
        }
    }

    @IsTest
    static void testProcessResponse() {
        Map<String, Object> jsonResponse = new Map<String, Object>();
        List<Object> entities = new List<Object>{
            new Map<String, Object>{
                'name' => 'Activity1',
                'id' => '001'
            },
            new Map<String, Object>{
                'name' => 'Activity2',
                'id' => '002'
            }
        };
        jsonResponse.put('entities', entities);

        Test.startTest();

        CC_EstrazioneDominioTurni.processResponse(jsonResponse);

        Test.stopTest();
    }
}