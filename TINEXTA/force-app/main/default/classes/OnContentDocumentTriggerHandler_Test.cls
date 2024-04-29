@isTest
public class OnContentDocumentTriggerHandler_Test {
    
    @isTest 
    static void testMakeCallContentDocument(){
        
        Funzionalita__c x = new Funzionalita__c();
        x.Bypass_Validation_Rules__c=true;
        insert x;

        EndpointServizi__c endp = new EndpointServizi__c();
        endp.WRN_Key_IntegrazioneInfoStore__c = 'test';
        endp.WRN_Url_IntegrazioneInfoStore__c = 'https://salesforce-test.test.it/api/v1/Wh/Opportunity';
        endp.WRT_SharePoint_Folders_Account__c = 'test';
        endp.WRT_SharePoint_Create_Folder_Account__c = 'https://sp-integration.test.it/api/SharePoint/CreateCustomerFolders';
        endp.WRN_URL_SharePoint_Auth__c = 'https://sp-integration.test.it/token';
        endp.WRT_SharePoint_Create_Folder_Opportunity__c = 'https://sp-integration.test.it/api/SharePoint/CreateOpportunityFolders';
        endp.WRT_SharePoint_Folders_Opportunity__c = 'test';
        insert endp;

        Map<String,String> header = new Map<String,String>();
         header.put('Content-type', 'application/json');
          HttpMockFactory mock = new HttpMockFactory(200, 'OK', '{"success":true,"message":"Created","data":{"Opportunity":{"Numero_offerta_Infostore__c":10}}}', header);
        Test.setMock(HttpCalloutMock.class, mock);
                
        Id WRT_Profile = [SELECT Id FROM Profile WHERE Name = 'Warrant Hub - System Administrator'].Id;
        User WRT_User = TestDataFactory.create_User(WRT_Profile);
        WRT_User.Societa__c = 'Warrant';
        insert WRT_User;
                
        Test.startTest();
        System.runAs(WRT_User) {
            
            Account[] acc = TestDataFactory.createAccounts(1);
            insert acc;
            
            Opportunity[] opp = TestDataFactory.createOpportunity(acc);
            //opp[0].WH_Business_Area__c = 'FA TEST';
            insert opp;   
            
            ContentVersion contentVersionInsert = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'test.snote',
                VersionData = Blob.valueOf('Test Content Data'),
                IsMajorVersion = true
            );
            insert contentVersionInsert;
            
            ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
             ContentDocumentLink contentlink=new ContentDocumentLink();
             contentlink.LinkedEntityId=opp[0].id;  
             contentlink.ShareType= 'V';               
             contentlink.ContentDocumentId=documents[0].Id;
             contentlink.Visibility = 'AllUsers'; 
             insert contentlink;
        }
        Test.stopTest(); 
        
    }

}