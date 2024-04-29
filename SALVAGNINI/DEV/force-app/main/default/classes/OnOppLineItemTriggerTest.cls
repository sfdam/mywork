@isTest
public class OnOppLineItemTriggerTest {
    @TestSetup
    static void makeData(){
        TestUtils.OpportunityContext context = TestUtils.createOpportunityContext();
    }

    @isTest
    static void testInsert () {
       
    }
    @isTest
    static void testDelete() {
        OpportunityLineItem item = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        delete item;
    }
}