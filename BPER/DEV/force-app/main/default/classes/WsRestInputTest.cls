@isTest
public without sharing class WsRestInputTest {

    @isTest
    static void testWsRestInput() {

        String profileId = [SELECT id FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1].id;
        User testUser = AllDataFactory.getUser('1123', profileId, 'Family');
        insert testUser;

        String testPayload;
        WsRestInput testWsRestInput = new WsRestInput(testUser, testPayload);

        String jsonParam = '{"statoAzione" : "StageName" , "nota" : "Description", "banca" : "PTF_ABICED__c", "ndg" : "CRM_FormulaAccountNDG__c", "codiceAzione" : "CodiceAzione__c", "codiceAzioneUtente" : "CodiceAzioneUtente__c", "motivo" : "CRM_Motivo__c", "nomeAzione" : "", "esito" : "CRM_Esito__c", "matricolaAutore" : "MatricolaAutore__c", "matricolaReferente" : "MatricolaReferente__c", "autore" : "Autore__c", "referente" : "CRM_Referente__c", "unitaOrganizzativa" : "UnitaOrganizzativa__c", "mds" : "DescrizioneMds__c"}';

        String jsonString = WsRestInput.toJSONString(jsonParam);
    }

    @isTest
    static void testConstructor() {
        WsRestInput.Security sec = new WsRestInput.Security();
    }

    @isTest
    static void testBindingInfo() {
        WsRestInput.BindingInfo binfo = new WsRestInput.BindingInfo();
    }

    @isTest
    static void testConstructorTestata() {
        WsRestInput.Testata testataInstance = new WsRestInput.Testata(); 
    }

    @isTest
    static void testUserProfile() {
        WsRestInput.UserProfile profile = new WsRestInput.UserProfile(); 
    }

    @isTest
    static void testCommonResponse() {
        String profileId = [SELECT id FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1].id;
        User testUser = AllDataFactory.getUser('1123', profileId, 'Family');
        insert testUser;

        String testPayload;
        WsRestInput testWsRestInput = new WsRestInput(testUser, testPayload);
        WsRestInput.CommonResponse commonResponseInstance = new WsRestInput.CommonResponse();
        commonResponseInstance.headers = testWsRestInput.headers;
        commonResponseInstance.headers.error_header = new WsRestInput.ErrorHeader();
        commonResponseInstance.headers.error_header.archErrorList = new List<WsRestInput.Error>{new WsRestInput.Error()};
        commonResponseInstance.headers.error_header.archErrorList[0].code = '123';
        commonResponseInstance.headers.error_header.archErrorList[0].description = 'Error Description';
    }

    
    @isTest
    static void testIsCorrect_NoErrors() {
        String profileId = [SELECT id FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1].id;

        User testUser = AllDataFactory.getUser('1123', profileId, 'Family');
        insert testUser;

        String testPayload;
        WsRestInput testWsRestInput = new WsRestInput(testUser, testPayload);
        WsRestInput.CommonResponse commonResponseInstance = new WsRestInput.CommonResponse();
        commonResponseInstance.headers = testWsRestInput.headers;
    }

    @isTest
    static void testIsCorrect_WithErrors() {
        String profileId = [SELECT id FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1].id;

        User testUser = AllDataFactory.getUser('1123', profileId, 'Family');
        insert testUser;

        String testPayload;
        WsRestInput testWsRestInput = new WsRestInput(testUser, testPayload);
        WsRestInput.CommonResponse commonResponseInstance = new WsRestInput.CommonResponse();
        commonResponseInstance.headers = testWsRestInput.headers;
        commonResponseInstance.headers.error_header = new WsRestInput.ErrorHeader();
        commonResponseInstance.headers.error_header.archErrorList = new List<WsRestInput.Error>{new WsRestInput.Error()};
        commonResponseInstance.headers.error_header.archErrorList[0].code = '123';
        commonResponseInstance.headers.error_header.archErrorList[0].description = 'Error Description';
    }

    @isTest
    static void testGetErrors_NoErrors() {
        String profileId = [SELECT id FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1].id;

        User testUser = AllDataFactory.getUser('1123', profileId, 'Family');
        insert testUser;

        String testPayload;
        WsRestInput testWsRestInput = new WsRestInput(testUser, testPayload);
        WsRestInput.CommonResponse commonResponseInstance = new WsRestInput.CommonResponse();
        commonResponseInstance.headers = testWsRestInput.headers;
    }

    @isTest
    static void testGetErrors_WithErrors() {
        String profileId = [SELECT id FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1].id;

        User testUser = AllDataFactory.getUser('1123', profileId, 'Family');
        insert testUser;

        String testPayload;
        WsRestInput testWsRestInput = new WsRestInput(testUser, testPayload);
        WsRestInput.CommonResponse commonResponseInstance = new WsRestInput.CommonResponse();
        commonResponseInstance.headers = testWsRestInput.headers;
        commonResponseInstance.headers.error_header = new WsRestInput.ErrorHeader();
        commonResponseInstance.headers.error_header.archErrorList = new List<WsRestInput.Error>{new WsRestInput.Error()};
        commonResponseInstance.headers.error_header.archErrorList[0].code = '123';
        commonResponseInstance.headers.error_header.archErrorList[0].description = 'Error Description';
    }

    @isTest
    static void testGetErrors_ExceptionError() {
        WsRestInput.CommonResponse commonResponseInstance = new WsRestInput.CommonResponse();
        commonResponseInstance.exceptionError = 'Error due to 404';
    }

    @isTest
    static void testParseError() {
        WsRestInput.CommonResponse commonResponseInstance = new WsRestInput.CommonResponse();
        String errorString = 'Descrizione = Error1; Descrizione = Error2;';
        String parsedError = commonResponseInstance.parseError(errorString);
    }
}