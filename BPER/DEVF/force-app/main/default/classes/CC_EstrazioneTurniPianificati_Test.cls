@IsTest
private class CC_EstrazioneTurniPianificati_Test {

    @IsTest
    static void testBatchExecution() {
        // Create test users with required fields
        User testUser = new User(
            FirstName = 'Test1',
            LastName = 'User',
            ProfileId = UserInfo.getProfileId(),
            CRM_GenesysID__c = 'TestGenesysID',
            CRM_ManagementID__c = 'TestManagementID',
            Username = 'testuser6@zucchettitest.com',
            Email = 'testuser@example.com',
            Alias = 'testuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        Endpoint__c apiRequest = new Endpoint__c(
            Name = 'GenesysToken',
            Method__c = 'POST',
            Endpoint__c = 'https://login.mypurecloud.de/oauth/token'
        );
        insert apiRequest;
        Endpoint__c apiRequest2 = new Endpoint__c(
            Name = 'EstrazioneTurniPianificati',
            Method__c = 'GET',
            Endpoint__c = 'https://example.com/api/estraturni'
        );
        insert apiRequest2;
        
        
        // Set the mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();

        // Call the authVsGenesys method
        HttpResponse response = CC_EstrazioneTurniPianificati.authVsGenesys();
        // Call the estrazioneVSGenesys method
        List<String> params = new List<String>{
            testUser.CRM_ManagementID__c + '_' + testUser.CRM_GenesysID__c
        };
        String params2 = testUser.CRM_ManagementID__c;
        HttpResponse response2 = CC_EstrazioneTurniPianificati.estrazioneVSGenesys(params,params2);

        //Test.startTest();
        // Start the batch execution
        CC_EstrazioneTurniPianificati batch = new CC_EstrazioneTurniPianificati();
        Database.executeBatch(batch);
        /*CC_EstrazioneTurniPianificati est = new CC_EstrazioneTurniPianificati();
        est.testExecution();*/
        Test.stopTest();

        // Perform assertions to validate the batch execution
        // Retrieve the created records and verify their correctness
        List<CRM_TurniPianificati__c> turniPianificatiList = [SELECT Id, CRM_User__c, CRM_Data__c, CRM_IDProfiloGiornaliero__c, NDW_ExternalId__c FROM CRM_TurniPianificati__c];
        System.assertEquals(0, turniPianificatiList.size());
        // Add more assertions as needed
    }

    @IsTest
    static void testExecute() {
        // Create test users with required fields and CRM_GenesysID__c value
        User user1 = new User(CRM_GenesysID__c = 'GenesysID1',CRM_ManagementID__c = 'TestManagementID');
        User user2 = new User(CRM_GenesysID__c = 'GenesysID2',CRM_ManagementID__c = 'TestManagementID');
        List<User> scope = new List<User>{ user1, user2 };
        Endpoint__c apiRequest = new Endpoint__c(
            Name = 'GenesysToken',
            Method__c = 'POST',
            Endpoint__c = 'https://login.mypurecloud.de/oauth/token'
        );
        insert apiRequest;
        Endpoint__c apiRequest2 = new Endpoint__c(
            Name = 'EstrazioneTurniPianificati',
            Method__c = 'GET',
            Endpoint__c = 'https://example.com/api/estraturni'
        );
        insert apiRequest2;
        
        // Set the mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();

        // Call the authVsGenesys method
        HttpResponse response = CC_EstrazioneTurniPianificati.authVsGenesys();
        // Call the estrazioneVSGenesys method
        List<String> params = new List<String>{
            user1.CRM_ManagementID__c + '_' + user1.CRM_GenesysID__c
        };
        String params2 = user1.CRM_ManagementID__c;
        HttpResponse response2 = CC_EstrazioneTurniPianificati.estrazioneVSGenesys(params,params2);

        // Call the execute method
        CC_EstrazioneTurniPianificati batch = new CC_EstrazioneTurniPianificati();
        //Test.startTest();
        batch.execute(null, scope);
        /*CC_EstrazioneTurniPianificati est = new CC_EstrazioneTurniPianificati();
        est.testExecution();*/
        Test.stopTest();

        // Add assertions for the expected behavior
        // Verify the generated records, method calls, etc.
    }

    @IsTest
    static void testExecuteWithMultipleKeys() {
        // Create test users with different CRM_ManagementID__c values
        User user1 = new User(CRM_ManagementID__c = 'ManagementID1',CRM_GenesysID__c = 'TestGenesysID');
        User user2 = new User(CRM_ManagementID__c = 'ManagementID2',CRM_GenesysID__c = 'TestGenesysID');
        List<User> scope = new List<User>{ user1, user2 };
        Endpoint__c apiRequest = new Endpoint__c(
            Name = 'GenesysToken',
            Method__c = 'POST',
            Endpoint__c = 'https://login.mypurecloud.de/oauth/token'
        );
        insert apiRequest;
        Endpoint__c apiRequest2 = new Endpoint__c(
            Name = 'EstrazioneTurniPianificati',
            Method__c = 'GET',
            Endpoint__c = 'https://example.com/api/estraturni'
        );
        insert apiRequest2;
        
        // Set the mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();

        // Call the authVsGenesys method
        HttpResponse response = CC_EstrazioneTurniPianificati.authVsGenesys();
        // Call the estrazioneVSGenesys method
        List<String> params = new List<String>{
            user1.CRM_ManagementID__c + '_' + user1.CRM_GenesysID__c
        };
        String params2 = user1.CRM_ManagementID__c;
        HttpResponse response2 = CC_EstrazioneTurniPianificati.estrazioneVSGenesys(params,params2);

        // Call the execute method
        CC_EstrazioneTurniPianificati batch = new CC_EstrazioneTurniPianificati();
        //Test.startTest();
        batch.execute(null, scope);
        /*CC_EstrazioneTurniPianificati est = new CC_EstrazioneTurniPianificati();
        est.testExecution();*/
        Test.stopTest();

        // Add assertions for the expected behavior
        // Verify the generated records, method calls, etc.
    }

    @IsTest
    static void testExecuteWithSingleKey() {
        // Create test users with the same CRM_ManagementID__c value
        User user1 = new User(CRM_ManagementID__c = 'ManagementID',CRM_GenesysID__c = 'TestGenesysID');
        User user2 = new User(CRM_ManagementID__c = 'ManagementID',CRM_GenesysID__c = 'TestGenesysID');
        List<User> scope = new List<User>{ user1, user2 };
        Endpoint__c apiRequest = new Endpoint__c(
            Name = 'GenesysToken',
            Method__c = 'POST',
            Endpoint__c = 'https://login.mypurecloud.de/oauth/token'
        );
        insert apiRequest;
        Endpoint__c apiRequest2 = new Endpoint__c(
            Name = 'EstrazioneTurniPianificati',
            Method__c = 'GET',
            Endpoint__c = 'https://example.com/api/estraturni'
        );
        insert apiRequest2;
        
        // Set the mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();

        // Call the authVsGenesys method
        HttpResponse response = CC_EstrazioneTurniPianificati.authVsGenesys();
        // Call the estrazioneVSGenesys method
        List<String> params = new List<String>{
            user1.CRM_ManagementID__c + '_' + user1.CRM_GenesysID__c
        };
        String params2 = user1.CRM_ManagementID__c;
        HttpResponse response2 = CC_EstrazioneTurniPianificati.estrazioneVSGenesys(params,params2);

        // Call the execute method
        CC_EstrazioneTurniPianificati batch = new CC_EstrazioneTurniPianificati();
        //Test.startTest();
        batch.execute(null, scope);
        /*CC_EstrazioneTurniPianificati est = new CC_EstrazioneTurniPianificati();
        est.testExecution();*/
        Test.stopTest();

        // Add assertions for the expected behavior
        // Verify the generated records, method calls, etc.
    }

    @IsTest
    static void testAuthVsGenesys() {
        // Create an Endpoint__c record for GenesysToken
        Endpoint__c apiRequest = new Endpoint__c(
            Name = 'GenesysToken',
            Method__c = 'POST',
            Endpoint__c = 'https://login.mypurecloud.de/oauth/token'
        );
        insert apiRequest;
        Endpoint__c apiRequest2 = new Endpoint__c(
            Name = 'EstrazioneTurniPianificati',
            Method__c = 'GET',
            Endpoint__c = 'https://example.com/api/estraturni'
        );
        insert apiRequest2;

        // Create a test user
        User testUser = new User(
            FirstName = 'Test1',
            LastName = 'User',
            ProfileId = UserInfo.getProfileId(),
            CRM_GenesysID__c = 'TestGenesysID',
            CRM_ManagementID__c = 'TestManagementID',
            Username = 'testuser7@zucchettitest.com',
            Email = 'testuser@example.com',
            Alias = 'testuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Set the mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();

        // Call the authVsGenesys method
        HttpResponse response = CC_EstrazioneTurniPianificati.authVsGenesys();
        // Call the estrazioneVSGenesys method
        List<String> params = new List<String>{
            testUser.CRM_ManagementID__c + '_' + testUser.CRM_GenesysID__c
        };
        String params2 = testUser.CRM_ManagementID__c;
        HttpResponse response2 = CC_EstrazioneTurniPianificati.estrazioneVSGenesys(params,params2);

        System.assertEquals(200, response.getStatusCode());
        CC_EstrazioneTurniPianificati est = new CC_EstrazioneTurniPianificati();
        est.testExecution();
        
        Test.stopTest();
    }

    @IsTest
    static void testEstrazioneVSGenesys() {
        // Create an Endpoint__c record for EstrazioneTurniPianificati
        Endpoint__c apiRequest = new Endpoint__c(
            Name = 'EstrazioneTurniPianificati',
            Method__c = 'GET',
            Endpoint__c = 'https://example.com/api/estraturni'
        );
        insert apiRequest;
        Endpoint__c apiRequest2 = new Endpoint__c(
            Name = 'GenesysToken',
            Method__c = 'POST',
            Endpoint__c = 'https://login.mypurecloud.de/oauth/token'
        );
        insert apiRequest2;

        // Create a test user
        User testUser = new User(
            FirstName = 'Test1',
            LastName = 'User',
            ProfileId = UserInfo.getProfileId(),
            CRM_GenesysID__c = 'TestGenesysID',
            CRM_ManagementID__c = 'TestManagementID',
            Username = 'testuser8@zucchettitest.com',
            Email = 'testuser@example.com',
            Alias = 'testuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Set the mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();

        // Call the estrazioneVSGenesys method
        List<String> params = new List<String>{
            testUser.CRM_ManagementID__c + '_' + testUser.CRM_GenesysID__c
        };
        String params2 = testUser.CRM_ManagementID__c;
        HttpResponse response = CC_EstrazioneTurniPianificati.estrazioneVSGenesys(params,params2);

        System.assertEquals(200, response.getStatusCode());
        CC_EstrazioneTurniPianificati est = new CC_EstrazioneTurniPianificati();
        est.testExecution();

        Test.stopTest();
    }

    @IsTest
    static void testWriteLog() {
        Endpoint__c apiRequest = new Endpoint__c(
            Name = 'GenesysToken',
            Method__c = 'POST',
            Endpoint__c = 'https://login.mypurecloud.de/oauth/token'
        );
        insert apiRequest;
        Endpoint__c apiRequest2 = new Endpoint__c(
            Name = 'EstrazioneTurniPianificati',
            Method__c = 'GET',
            Endpoint__c = 'https://example.com/api/estraturni'
        );
        insert apiRequest2;
        // Call the writeLog method with sample data
        SV_Log__c log = CC_EstrazioneTurniPianificati.writeLog(
            'TestApiRequestName',
            'TestMethod',
            'TestInput',
            200,
            'TestStatus',
            'TestOutput',
            new Map<String, String>{'TestReqHeaderKey' => 'TestReqHeaderValue'},
            new Map<String, String>{'TestResHeaderKey' => 'TestResHeaderValue'},
            'TestEndpoint',
            'TestErrorMessage'
        );

        // Perform assertions on the created log record
        //System.assertNotEquals(null, log.Id);
        // Add more assertions as needed
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private String jsonResponseString;

        public MockHttpResponseGenerator() {
            this.jsonResponseString = '{"status":"Success","operationId":"12345","result":{"agentSchedules":[{"user":{"id":"User1"},"startDate":"2023-07-11","shifts":[{"activities":[{"activityCodeId":"Code1"}]}]}]}}';
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');
            response.setBody(jsonResponseString);
            return response;
        }
    }

    static void testBatchExecutionWithMockResponse() {
        // Create test users with required fields
        User testUser = new User(
            FirstName = 'Test1',
            LastName = 'User',
            ProfileId = UserInfo.getProfileId(),
            CRM_GenesysID__c = 'User1',
            CRM_ManagementID__c = 'Management1',
            Username = 'testuser9@zucchettitest.com',
            Email = 'testuser@example.com',
            Alias = 'testuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        Endpoint__c apiRequest = new Endpoint__c(
            Name = 'GenesysToken',
            Method__c = 'POST',
            Endpoint__c = 'https://login.mypurecloud.de/oauth/token'
        );
    
        // Create a CRM_DominioTurni__c record for the activity code
        CRM_DominioTurni__c dominioTurno = new CRM_DominioTurni__c(
            Name = 'Code1',
            CRM_ActivityCodeID__c = 'Code1'
        );
        insert dominioTurno;
    
        // Set up the mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
        Test.startTest();
    
        // Start the batch execution
        CC_EstrazioneTurniPianificati batch = new CC_EstrazioneTurniPianificati();
        Database.executeBatch(batch);
    
        Test.stopTest();
    
        // Retrieve the created records and verify their correctness
        List<CRM_TurniPianificati__c> turniPianificatiList = [
            SELECT Id, CRM_User__c, CRM_Data__c, CRM_IDProfiloGiornaliero__c, NDW_ExternalId__c
            FROM CRM_TurniPianificati__c
        ];
        System.assertEquals(1, turniPianificatiList.size());
        CRM_TurniPianificati__c turnoPianificato = turniPianificatiList[0];
        System.assertEquals(testUser.Id, turnoPianificato.CRM_User__c);
        System.assertEquals(Date.newInstance(2023, 7, 11), turnoPianificato.CRM_Data__c);
        System.assertEquals(dominioTurno.Name, turnoPianificato.CRM_IDProfiloGiornaliero__c);
        System.assertEquals('User1_2023-07-11', turnoPianificato.NDW_ExternalId__c);
    }
}