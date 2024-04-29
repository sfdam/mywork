@isTest
public with sharing class ContentDocumentLinkTriggerHandlerTest {

   @IsTest
   public static void test_Prepare_file (){

        // Country__c country = TestUtils.createCountry();
        // TerritoryContext terrCont = TestUtils.createTerritoryContext(false);

        // id territoryId = [select id from territory__c limit 1].id;
   
        Account accA =TestUtils.createAccount(false);
        
        Opportunity opp =TestUtils.createOpportunity(AccA.id);
        // Opportunity opp = new Opportunity(Name='test opp',StageName='stage', AccountId = accA.Id ,Probability = 95, CloseDate=system.today());
        // insert opp;
        
        Quote Q = New Quote(Name='Test Quote', OpportunityId=opp.Id);
        insert Q;
        system.debug(' @@@ id della quote: '+ Q.id);

        SBQQ__Quote__c sq = new SBQQ__Quote__c();
        sq.SBQQ__Type__c = 'Quote';
		sq.SBQQ__Opportunity2__c= opp.id;
        sq.SBQQ__Account__c = accA.id;
		sq.SBQQ__QuoteLanguage__c = 'Italian';
        sq.Country_dependency__c ='Algeria';
		insert sq;

        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=sq.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InvoicesMockCheck());
        insert contentlink;
        Test.stopTest();
   }


  
   public class InvoicesMockCheck implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{ "customer_id": "02000027171", "items": [ { "row_id": 1, "item_id": "12345", "requested_quantity": 24, "available_quantity": 20, "result_code": "IPT_IAL_OK_001", "messages": [ "Product found" ] }, { "row_id": 2, "item_id": "0002511", "requested_quantity": 1, "available_quantity": 1960, "result_code": "IPT_IAL_OK_001", "messages": [ "Product found" ] } ] }');
        response.setStatusCode(200);
        return response; 
    }
}


}