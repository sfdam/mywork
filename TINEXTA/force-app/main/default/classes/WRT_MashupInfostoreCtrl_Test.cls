@isTest
public without sharing class WRT_MashupInfostoreCtrl_Test {
    

    @isTest
    static void mashupTest(){

        EndpointServizi__c es = new EndpointServizi__c();
        es.WRT_IFrame_Infostore__c = 'https://salesforce-test.warranthub.it/v1/Wh/Quote/Pricing/View/';
        es.WRN_Key_IntegrazioneInfoStore__c = 'test';
        es.WRN_Url_IntegrazioneInfoStore__c = 'https://salesforce-test.test.it/api/v1/Wh/Opportunity';
        es.WRT_SharePoint_Folders_Account__c = 'test';
        es.WRT_SharePoint_Create_Folder_Account__c = 'https://sp-integration.test.it/api/SharePoint/CreateCustomerFolders';
        es.WRN_URL_SharePoint_Auth__c = 'https://sp-integration.test.it/token';
        es.WRT_SharePoint_Create_Folder_Opportunity__c = 'https://sp-integration.test.it/api/SharePoint/CreateOpportunityFolders';
        es.WRT_SharePoint_Folders_Opportunity__c = 'test';
        es.WRT_Create_CPQ_Infostore__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/Quote';
        insert es;

        List<Account> accList = TestDataFactory.createAccounts(1);
        for(Account a : accList){
            a.Societa_di_riferimento__c = 'Warrant';
            //a.WRT_Documento_SharePoint__c = 'https://test';
        }
        insert accList;

        // Opportunity opp = new Opportunity(Name = 'TestQuote', AccountId = acc.Id, CloseDate = System.Today().addDays(30), StageName = 'Proposta /Quotazione prezzi');
        // insert opp;

        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c = accList[0].Id, SBQQ__Primary__c = true/*, SBQQ__Opportunity2__c = opp.Id*/);
        insert quote;

        Product2 p = new Product2(Name = 'TestIntegrazioneISCPQ');
        insert p;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory(200, 'OK', '{}', new Map<String,String>()));

        SBQQ__QuoteLine__c quoteline = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = p.Id, Divisione_WarrantCPQ__c = 'FA AUTOMATICA', Tipo_Mandato__c = '1 anno + 2 anni');
        insert quoteline;

        PageReference pageRef = Page.WRT_MashupInfostore;
        pageRef.getParameters().put('id',quoteline.id);
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.Class, new HTTPMockFactory());

        Test.startTest();
            new WRT_MashupInfostoreCtrl();
        Test.stopTest();
    }
}