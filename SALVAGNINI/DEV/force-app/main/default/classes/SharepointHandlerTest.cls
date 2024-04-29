@isTest
public class SharepointHandlerTest {
    //NB: ContentDocumentLinkTriggerHandlerTest copre tutta un altra parte della classe (Commento pe ri Posteri)
    static testMethod void testSerUpdate(){
        Account testAcc = new Account(Name = 'TEST', Primary_Industry__c = 'Agricultural Technologies');
        insert testAcc;
        Account testApplicationBranch = new Account(Name = 'TEST', Primary_Industry__c = 'Agricultural Technologies', Type = 'Branch', Ser_Branch__c = true);
        insert testApplicationBranch;
        Opportunity testOpp = new Opportunity(Name = 'TEST', AccountId = testAcc.Id, StageName = 'Qualification', CloseDate = system.today());
        insert testOpp;
        
        SER__c testSer = new SER__c(Name = 'TEST');
        Test.setMock(HttpCalloutMock.class, new sharepointMock());
        
       
        test.startTest();
        insert testSer;
        testSer.Account__c = testAcc.Id;
        testSer.Application_Branch__c = testApplicationBranch.Id;
        testSer.Opportunity__c = testOpp.Id;
        update testSer;
        test.stopTest();
        
    }

    // @isTest 
    // public static void testCReateSPI(){
    // //////////////////////////////////////////////////////////////////////////

    //     Account testAcc = new Account(Name = 'TEST', Primary_Industry__c = 'Agricultural Technologies');
    //         insert testAcc;
    //         Account testApplicationBranch = new Account(Name = 'TEST', Primary_Industry__c = 'Agricultural Technologies', Type = 'Branch', Ser_Branch__c = true);
    //         insert testApplicationBranch;
    //         Opportunity testOpp = new Opportunity(Name = 'TEST', AccountId = testAcc.Id, StageName = 'Qualification', CloseDate = system.today());
    //         insert testOpp;

    //     Product2 p1 = new Product2(
    //         Name = 'Product1',
    //         Special_Base_List_Price__c =2,
    //         Special_List_Price__c =1,
    //         Installation_Price__c=1,
    //         Prog_Training_days__c=1,
    //         Mnt_Training_Days__c =1,
    //         Transport_Price__c=1,
    //         isActive = true
    //     );
    //     insert p1;
        
    //     Pricebook2 PB = new Pricebook2();
    //         PB.name='Test';
    //         PB.Markup__c=0.1;
    //     //PB.isStandard=true;
    //     insert PB; 

    //     Id pricebookIdstd = Test.getStandardPricebookId();
        
    //     Pricebook2 PBS = new Pricebook2(
    //     Id = pricebookIdstd,
    //     IsActive = true
    //     );
    //     update PBS;

    //     system.debug('@@@ IsStandard: '+ PB.IsStandard);

    //     // SBQQ__Quote__c q1 = new SBQQ__Quote__c(
    //     // //SBQQ__Status__c = 'Draft',
    //     // SBQQ__QuoteLanguage__c = 'English',
    //     // SBQQ__Account__c = testAcc.Id,
    //     // Change_for_List_Area_Price__c= 3,
    //     // SBQQ__PriceBook__c=PBS.id
    //     // );
    //     // insert q1;

    //     // List<SBQQ__QuoteLine__c> ListQL = new  List<SBQQ__QuoteLine__c>();
    //     // SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(
    //     //     SBQQ__Quote__c = q1.Id,
    //     //     SBQQ__Product__c = p1.Id
    //     // );
    //     // ListQL.add(ql1);

    //     // SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c(
    //     //     SBQQ__Quote__c = q1.Id,
    //     //     SBQQ__Product__c = p1.Id
    //     // );
    //     // ListQL.add(ql2);
    //     // insert ListQL;

    //     SBQQ__Quote__c q1 = new SBQQ__Quote__c(
    //         //SBQQ__Status__c = 'Draft',
    //         SBQQ__QuoteLanguage__c = 'English',
    //         SBQQ__Account__c = testAcc.Id
    //     );
    //     insert q1;

    //     SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(
    //         SBQQ__Quote__c = q1.Id,
    //         SBQQ__Product__c = p1.Id
    //     );
    //     insert ql1;

    // }

    public class sharepointMock implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token": "testToken"}');
            response.setStatusCode(200);
            return response; 
        }
    }

}