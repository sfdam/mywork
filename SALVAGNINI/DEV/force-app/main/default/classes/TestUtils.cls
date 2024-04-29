@IsTest
public  class TestUtils {
    
    public class UserContext{
        public Profile profile;
        public Account account;
        public Contact contact;
        public User user;
    }

    public class TerritoryContext{
        public Country__c country;
        public Account applicationBranch;
        public Territory__c territory;
    }

    public class OpportunityContext{
        public Account account;
        public Opportunity opportunity;
        public Pricebook2 pricebook;
        public PricebookEntry pricebookEntry;
        public OpportunityLineItem oppLineItem;
        public Product2 product;
    }

    public class SERcontext{
        public SER__c ser;
        public Account account;
        public Account applicationBranch;
        public Opportunity opportunity;
        public SER_Routing__c routing;
        public SER_Product__c product;
    }   

    public static Profile createProfile(){
        Profile profile = [Select Id from Profile where name = 'GFL - Sales Partner Community'];
        return profile;
    }

  public static String generateRandomString(Integer len) {
    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'; //0123456789abcdefghijklmnopqrstuvwxyz
    String randStr = '';
    while (randStr.length() < len) {
       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
       randStr += chars.substring(idx, idx+1);
    }
    return randStr; 
  }

    public static Account createAccount(){
        return TestUtils.createAccount(true,null);
    }
    public static Account createAccount(boolean isIta){
        return TestUtils.createAccount(isIta,null);
    }
    public static Account createAccount(boolean isIta, Id territoryId){
        RecordType recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Account'];

        Account account = new Account(
            Name = 'Account' + String.valueOf(Integer.valueOf(Math.random()*10000)),
            BillingCountryCode = isIta ? 'IT' : 'DE',
            BillingStateCode = isIta ? 'AG' : '',
            BillingPostalCode = '11500',
            BillingCity = 'Test',
            BillingStreet = 'Test',
            RecordTypeId = recordType.Id,
            Primary_Industry__c = 'Agricultural Technologies',
            Type = 'Branch',
            Ser_Branch__c = true,
            Territory__c = territoryId
        );
        insert account;
        return account;
    }

    public static Lead createLead(){
        return TestUtils.createLead(true);
    }
    public static Lead createLead(boolean isIta){
        RecordType recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Lead' AND DeveloperName = 'Lead'];
        Lead lead = new Lead(
            LastName = 'Lead',
            CountryCode = isIta ? 'IT' : 'DE',
            StateCode = isIta ? 'AG' : '',
            PostalCode = '11500',
            RecordTypeId = recordType.Id,
            Email = 'test@test.test',
            Phone = '0000000',
            Company = 'Test'
        );
        insert lead;
        return lead;
    }

    public static Contact createContact(Id accountId){
        Contact contact = new Contact(
            AccountId = accountId,
            LastName = 'Test Lastname'
        );
        insert contact;
        return contact;
    }

    public static User createUser(Id contactId, Id profileId){
        User user = new User(
            ContactId = contactId,
            Username = 'testUser@mail.com@salvag.com',
            Email = 'testuser@mail.com',
            Alias = 'testuser',
            TimeZoneSidKey = 'Europe/Rome',
            LocaleSidKey = 'it_IT',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = profileId,
            LanguageLocaleKey = 'en_US',
            LastName = 'Test Lastname'
        );
        insert user;
        return user;
    }
  
    public static Product2 createProduct(){
        RecordType recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Product2' AND DeveloperName = 'System_PA_Budget'];
        Product2 product = new Product2(
            Name = 'Product Test',
            IsActive = true,
            Enable_for_Budget__c = true,
            RecordTypeId = recordType.Id
        );
        insert product;
        return product;
    }

    public static Opportunity createOpportunity(Id accountId){
        Opportunity opportunity = new Opportunity(
            Name = 'Opportunity',
            AccountId = accountId,
            CloseDate = Date.today()+1,
            StageName = 'Qualification'
        );
        insert opportunity;
        return opportunity;
    }

    public static PriceBook2 createPriceBook(){
        PriceBook2 priceBook = new PriceBook2(
            Name = 'Listino Italia'
        );

        insert priceBook;
        return priceBook;
    }

    public static PricebookEntry createPriceBookEntry(Id priceBookId, Id productId){
        PricebookEntry standardPriceBook = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = productId,
            UnitPrice = 100,
            IsActive = true
        );

        insert standardPriceBook;

        PricebookEntry priceBookEntry = new PricebookEntry(
            Pricebook2Id = priceBookId,
            Product2Id = productId,
            UnitPrice = 100,
            IsActive = true
        );

        insert priceBookEntry;
        return priceBookEntry;
    }

    public static OpportunityLineItem createOppLineItem(Id oppId, Id productId, Id pricebookEntryId){
        OpportunityLineItem item = new OpportunityLineItem(
            OpportunityId = oppId,
            Product2Id = productId,
            PriceBookEntryId = pricebookEntryId
        );
        insert item;
        return item;
    } 

    public static Territory__c createTerritory(Id areaId,Id managerId){
        Territory__c territory = new Territory__c(
            Name = 'Agrigento',
            Area__c = areaId,
            State_Province_abbreviation__c = 'AG',
            Territory_Manager__c = managerId,
            From_Zip__c = '11000',
            To_Zip__c = '11999',
            Language__c  = 'Italian'
        );

        insert territory;
        return territory;
    }

    public static SER__c createSer(Id opportunityId,Id accountId, Id appBranchId){
        SER__c ser = new SER__c(
            Name = 'Test',
            Account__c = accountId,
            Application_Branch__c = appBranchId,
            Opportunity__c = opportunityId,
            Request_due_date__c = Date.today()+1,
            Detailed_request_description__c = 'test',
            Owner__c = UserInfo.getUserId()
            );
        insert ser;
        return ser;
    }

    public static SER_Product__c createSerProduct(Id modelId, Id techId, Id serId){
        SER_Product__c serProd = new SER_Product__c(
                SER__c = serId,
                Product__c = modelId,
                Technology__c = techId
        );
        insert serProd;
        return serProd;
    }

    public static SER_Routing__c createSerRouting(Id productId, Id appBranchId){
        SER_Routing__c routing = new SER_Routing__c(
            Product__c = productId,
            SER_Type__c = 'Application Study: FMS and Simulation = FALSE',
            Application_Branch__c = appBranchId
        );
        insert routing;
        return routing;
    }

    public static Product2 createSerModel(Id familyId){
        RecordType recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Product2' AND DeveloperName = 'Model'];
        Product2 model = new Product2(Name = 'TestModel',
                            Family = 'Autonomous connection',
                            RecordTypeId = recordType.Id,
                            IsActive = true,
                            ProductFamily__c = familyId
        );
        insert model;
        return model;
    }

    public static Product2 createSerTechnology(){
        RecordType recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Product2' AND DeveloperName = 'ProductFamily'];
        Product2 technology = new Product2(Name = 'Autonomous connection',
                            Family = 'Autonomous connection',
                            RecordTypeId = recordType.Id,
                            IsActive = true
        );
        insert technology;
        return technology;
    }

    public static Country__c createCountry(){
        Account appBranch = TestUtils.createAccount();
        return TestUtils.createCountry(appBranch.Id);
    }
    public static Country__c createCountry(Id appBranchId){
        return TestUtils.createCountry(appBranchId,UserInfo.getUserId());
    }
    public static Country__c createCountry(Id appBranchId,Id managerId){
        return TestUtils.createCountry(true,appBranchId,managerId);
    }
    public static Country__c createCountry(boolean isIta, Id appBranchId,Id managerId){
        Country__c country = new Country__c(
            Application_Branch__c = appBranchId,
            Country_Code__c = isIta ? 'IT' : 'DE',
            Area_Manager__c = managerId,
            Determined_by__c = isIta ? 'State or Province' : 'Zip codes'
        );
        insert country;
        return country;
    }

    public static TerritoryContext createTerritoryContext(Boolean isIta){
        return TestUtils.createTerritoryContext(isIta, UserInfo.getUserId()); 
    }
    public static TerritoryContext createTerritoryContext(Boolean isIta, Id managerId){
        TerritoryContext context = new TerritoryContext();
        context.applicationBranch = TestUtils.createAccount(isIta);
        context.country = TestUtils.createCountry(isIta, context.applicationBranch.Id ,managerId);
        context.territory = TestUtils.createTerritory(context.country.Id,managerId);
        return context;
    }

    public static UserContext createUserContext(){
        UserContext context = new UserContext();
        context.profile = TestUtils.createProfile();
        context.account = TestUtils.createAccount(true);
        context.contact = TestUtils.createContact(context.account.Id);
        context.user = TestUtils.createUser(context.contact.Id, context.profile.Id);
        return context;
    }

    public static OpportunityContext createOpportunityContext(){
        OpportunityContext context = new OpportunityContext();
        context.account = TestUtils.createAccount();
        context.opportunity = TestUtils.createOpportunity(context.account.Id);
        context.product = TestUtils.createProduct();
        context.pricebook = TestUtils.createPriceBook();
        context.pricebookEntry = TestUtils.createPriceBookEntry(context.pricebook.Id, context.product.Id);
        context.oppLineItem = TestUtils.createOppLineItem(context.opportunity.Id,context.product.Id,context.pricebookEntry.Id);
        return context;
    }

    public static SerContext createSerContext(){
        SerContext context = new SerContext();
        context.applicationBranch = Testutils.createAccount();
        context.opportunity = TestUtils.createOpportunity(context.applicationBranch.Id);
        Country__c country = TestUtils.createCountry(context.applicationBranch.Id);
        Territory__c territory = TestUtils.createTerritory(country.Id,UserInfo.getUserId());
        context.account = TestUtils.createAccount(true,territory.Id);
        context.ser = TestUtils.createSer(context.opportunity.Id,context.account.Id, context.applicationBranch.Id);
        Product2 tech = TestUtils.createSerTechnology();
        Product2 model = TestUtils.createSerModel(tech.Id);
        context.product = TestUtils.createSerProduct(model.Id,tech.Id,context.ser.Id);
        context.routing = TestUtils.createSerRouting(model.Id,context.applicationBranch.Id);
        return context;
    }

}