@isTest
public class ClonaQuote_Test {
    @testSetup
    static void CloneTest() {
        UserRole r= new UserRole(DeveloperName = 'Territory_Manager_IT', Name = 'Territory Manager IT');
        insert r;


        User user = new User(
            Username = 'testUser@mail.com@salvag.com',
            Email = 'testuser@mail.com',
            Alias = 'testuser',
            TimeZoneSidKey = 'Europe/Rome',
            LocaleSidKey = 'it_IT',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = [SELECT Id from Profile LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            LastName = 'Test Lastname',
            UserRoleId = r.Id
        );
        insert user;
        

    }
    @isTest
    static void testClona(){
        test.startTest();
        
        Account a = new Account();
        a.name='test';
        a.BillingCountry='Italy';
        insert a;

        Product2 product  = TestUtils.createProduct();
        
        Pricebook2 PB = new Pricebook2();
        PB.name='Test';
        insert PB; 

        SBQQ__LookupData__c LD = new SBQQ__LookupData__c();
        LD.Price_Book__c=PB.Id;
        LD.SVG_Country__c='Italy';
        LD.Active__c=true;
        LD.Default__c=true;
        LD.Lookup_Data_Type__c='Price Book Assignment';
        insert LD; 
        //system.runAs(user){
            SBQQ__quote__c q = new SBQQ__quote__c();
            q.SBQQ__Account__c=[SELECT Id FROM Account LIMIT 1].Id;
            q.SBQQ__QuoteLanguage__c='Italian';
            insert q;

            SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
            qli.SBQQ__Product__c=[SELECT Id FROM Product2 LIMIT 1].Id;
            qli.SBQQ__Quote__c=q.id;
            insert qli;

            ClonaQuote.ottieniDati(q.Id);
            customLookUpController.fetchLookUpValues('C','Pricebook2','Italy',true);
            ClonaQuote.clonaQuoteAmend(q.Id,PB.Id,null );
            ClonaQuote.clonaQuoteWithRelated(q.Id,a.Id,Null);
        //}
        test.stopTest();
    }
}