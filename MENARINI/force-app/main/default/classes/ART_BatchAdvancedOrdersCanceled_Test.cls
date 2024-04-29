@IsTest
public class ART_BatchAdvancedOrdersCanceled_Test {

    public static Date day_1 = Date.today().addDays(-30);

    @TestSetup
    static void makeData() {
        cgcloud__Order_Template__c orderTemplate = new cgcloud__Order_Template__c();
        insert orderTemplate;

        cgcloud__Order__c order = new cgcloud__Order__c(
            cgcloud__Order_Template__c = orderTemplate.Id,
            cgcloud__Phase__c = 'Initial',
            cgcloud__Delivery_Date__c = day_1
        );
        insert order;
        System.debug('makeData - order: ' + order);
    }

    @IsTest
    static void methodName() {
        Test.startTest();
        ART_BatchAdvancedOrdersCanceled batchable = new ART_BatchAdvancedOrdersCanceled();
        // System.schedule('ART_BatchAdvancedOrdersCanceled_Test', '0 0 12 * * ?', batchable);
        Database.executeBatch(new ART_BatchAdvancedOrdersCanceled());
        Test.stopTest();
        
        cgcloud__Order__c order = [SELECT Id, cgcloud__Delivery_Date__c, cgcloud__Phase__c FROM cgcloud__Order__c];
        System.assertEquals(day_1, order.cgcloud__Delivery_Date__c);
        System.assertEquals('Canceled', order.cgcloud__Phase__c);
    }

}