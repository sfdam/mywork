@isTest
public inherited sharing class PardotIntegrationCtrlTest {
    
    @TestSetup
    static void makeData(){
        EndpointServizi__c es = new EndpointServizi__c();
        es.WRT_Create_Prospect_Pardot_Ecobonus__c = 'https://pi.pardot.com/api/prospect/version/4/do/create?format=json';
        es.WRT_Delete_Prospect_Pardot_Ecobonus__c = 'https://pi.pardot.com/api/prospect/version/4/do/delete?format=json';
        es.WRT_Token_SF_Pardot__c = 'https://login.salesforce.com/services/oauth2/token';
        insert es;

        UtenzeDefault__c ud = new UtenzeDefault__c();
        ud.WRT_Client_Id_Pardot__c = 'clientId';
        ud.WRT_Client_Secret_Pardot__c = 'clientSecret';
        ud.WRT_Pardot_Business_Unit_ID__c = 'PardotBusinessUnit';
        ud.WRT_Username_Pardot__c = 'ten@tinexta';
        ud.WRT_Password_Pardot__c = 'password';
        insert ud;
    }

    @isTest
    static void createContactPardotTest(){
        InvocableCreazioneProspectPardot.ActionRequest parametro = new InvocableCreazioneProspectPardot.ActionRequest();
        parametro.Nome = 'test_nome';
        parametro.Cognome = 'test_cognome';
        parametro.Email = 'Email@test.invalid';

        Test.setMock(HttpCalloutMock.Class, new HTTPMockFactory());

        List<InvocableCreazioneProspectPardot.ActionRequest> parametri = new List<InvocableCreazioneProspectPardot.ActionRequest>{parametro};

        Test.startTest();
        InvocableCreazioneProspectPardot.handlePardotCallout(parametri);
        Test.stopTest();
    }

    @isTest
    static void createContactPardotTestKO(){
        InvocableCreazioneProspectPardot.ActionRequest parametro = new InvocableCreazioneProspectPardot.ActionRequest();
        parametro.Nome = 'test_nome';
        parametro.Cognome = 'test_cognome';
        parametro.Email = 'Email@test.invalid';

        Test.setMock(HttpCalloutMock.Class, new HTTPMockFactory(400, 'KO', '{"error":"error"}', new Map<String,String>()));

        List<InvocableCreazioneProspectPardot.ActionRequest> parametri = new List<InvocableCreazioneProspectPardot.ActionRequest>{parametro};

        Test.startTest();
        InvocableCreazioneProspectPardot.handlePardotCallout(parametri);
        Test.stopTest();
    }

    @isTest
    static void deleteContactPardotTest(){
        InvocableDeleteProspectPardot.ActionRequest parametro = new InvocableDeleteProspectPardot.ActionRequest();
        parametro.Email = 'Email@test.invalid';
        parametro.Key = '123';
        
        Test.setMock(HttpCalloutMock.Class, new HTTPMockFactory());

        List<InvocableDeleteProspectPardot.ActionRequest> parametri = new List<InvocableDeleteProspectPardot.ActionRequest>{parametro};

        Test.startTest();
        InvocableDeleteProspectPardot.deleteProspectPardot(parametri);
        Test.stopTest();
    }

    @isTest
    static void deleteContactPardotTest2(){
        Map<String,String> parametri = new Map<String,String>();
        parametri.put('id', '123');
        
        Test.setMock(HttpCalloutMock.Class, new HTTPMockFactory());

        Test.startTest();
        PardotIntegrationCtrl.deleteContactFlow(parametri);
        Test.stopTest();
    }
}