@IsTest
public with sharing class QuoteSuggestionsControllerTest {

    @TestSetup
    public static void setup() {
        update new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);

        Product2 product = new Product2(Name = 'Product Test 1', ProductCode = '123456789', THR_MaterialKey__c = '123456789', IsActive = true);
        insert product;

        //Il pricebookEntry è creato in automatico dal flow 'Product - After Insert'
        PricebookEntry pricebookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];

        Opportunity opportunity = new Opportunity(Name = 'Opportunity Test 1', StageName =  'Prospecting', CloseDate = Date.today().addDays(1), Pricebook2Id = Test.getStandardPricebookId());
        insert opportunity;

        Quote quote = new Quote(Name = 'Quote Test 1', OpportunityId = opportunity.Id, ShippingStreet = 'ShippingStreet', ShippingCity = 'Roma', ShippingPostalCode = '00133', ShippingCountry = 'Italy');
        insert quote;

        QuoteLineItem quoteLineItem = new QuoteLineItem(QuoteId = quote.Id, Product2Id = product.Id, PricebookEntryId = pricebookEntry.Id, Quantity = 4, UnitPrice = 10);
        insert quoteLineItem;
    }

    @IsTest
    public static void getQuoteLineItemsTest() {
        List<QuoteLineItem> quoteLineItems;

        Test.startTest();
        quoteLineItems = QuoteSuggestionsController.getQuoteLineItems([SELECT Id FROM Quote LIMIT 1].Id);
        Test.stopTest();

        System.assertEquals(1, quoteLineItems.size());
    }

    @IsTest
    public static void getCsvQuoteLineItemsTest() {
        String csv;

        Test.startTest();
        csv = QuoteSuggestionsController.getCsvQuoteLineItems([SELECT Id FROM Quote LIMIT 1].Id);
        Test.stopTest();

        System.assertEquals(true, String.isNotBlank(csv));
    }
}