@isTest
public class CreazioneOffertaInfostoreControllerTest {

    @TestSetup
    static void makeData(){
        // Test.setMock(HttpCalloutMock.Class, new HTTPMockFactory(200, 'ok', '{}', new Map<String,String>()));

        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        insert x;

        Account acc = new Account(Name = 'TestAccountCreazioneOfferta');
        insert acc;

        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c = acc.Id, SBQQ__Primary__c = true);
        insert quote;

        EndpointServizi__c endp = new EndpointServizi__c();
        endp.WRN_Key_IntegrazioneInfoStore__c = 'test';
        endp.WRN_URL_SharePoint_Auth__c = 'https://sp-integration.test.it/token';
        endp.WRT_SharePoint_Create_Folder_Opportunity__c = 'https://sp-integration.test.it/api/SharePoint/CreateOpportunityFolders';
        endp.WRT_SharePoint_Folders_Opportunity__c = 'test';
        endp.WRT_Create_CPQ_Infostore__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/Quote';
        insert endp;

        x.Disabilita_tutti_i_trigger__c=true;
        update x;
    }

    @isTest
    static void creazioneOffertaTest(){

        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c];

        Test.setMock(HttpCalloutMock.Class, new HTTPMockFactory(200, 'ok', '{}', new Map<String,String>()));
        Test.startTest();
            CreazioneOffertaInfostoreController.CreazioneOffertaInfostore(quote.Id);
            CreazioneOffertaInfostoreController.CreazioneOffertaInfostore(null);
        Test.stopTest();
    }
}