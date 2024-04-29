@isTest
public class OnBudgetTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        Product2 product  = TestUtils.createProduct();
        Country__c country = TestUtils.createCountry();
    }
    @isTest
    static void testInsert () {
        Country__c country = [SELECT Id FROM Country__c LIMIT 1];
        Budget__c budget = new Budget__c(Country__c = country.Id,
                                         Status__c = 'Draft');
        insert budget;
    }
}