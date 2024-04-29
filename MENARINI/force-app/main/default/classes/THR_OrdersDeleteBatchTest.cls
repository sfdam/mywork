/**
 * Created by User on 31/08/2022.
 */

@IsTest
public with sharing class THR_OrdersDeleteBatchTest {

    @TestSetup
    public static void setup() {

        String country = 'IT';

        Account acc = THR_TestDataFactory.createAccount('AccTest', country, '1111EF');
        insert acc;

        Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
        );
        update standardPricebook;

        List<Order> orderList = new List<Order>();
        orderList.add(THR_TestDataFactory.createOrder(acc, '1111A', 'H', country));
        orderList.add(THR_TestDataFactory.createOrder(acc, '1111B', 'F', country));
        orderList.add(THR_TestDataFactory.createOrder(acc, '1111C', 'X', country));
        orderList.add(THR_TestDataFactory.createOrder(acc, '1111D', 'F', country));
        orderList.add(THR_TestDataFactory.createOrder(acc, '1111E', 'F', 'ES'));
        orderList.add(THR_TestDataFactory.createOrder(acc, '1111F', 'E', country));
        insert orderList;

    }

    @IsTest
    public static void ordersDeleteBatchTest_13MonthsAgo() {
        Test.setCreatedDate([SELECT Id, CreatedDate, THR_OrderKey__c FROM Order WHERE THR_OrderKey__c = '1111A'].Id, Datetime.now().addMonths(-13));
        Test.setCreatedDate([SELECT Id, CreatedDate, THR_OrderKey__c FROM Order WHERE THR_OrderKey__c = '1111B'].Id, Datetime.now().addMonths(-13));
        Test.setCreatedDate([SELECT Id, CreatedDate, THR_OrderKey__c FROM Order WHERE THR_OrderKey__c = '1111C'].Id, Datetime.now().addMonths(-13));

        Test.startTest();
        Database.executeBatch(new THR_OrdersDeleteBatch(), 200);
        Test.stopTest();

        System.assert([SELECT Id FROM Order].size() == 3);
    }

    @IsTest
    public static void ordersDeleteBatchTest_1MonthAgo() {
        Test.setCreatedDate([SELECT Id, CreatedDate, THR_OrderKey__c FROM Order WHERE THR_OrderKey__c = '1111A'].Id, Datetime.now().addMonths(-1));
        Test.setCreatedDate([SELECT Id, CreatedDate, THR_OrderKey__c FROM Order WHERE THR_OrderKey__c = '1111B'].Id, Datetime.now().addMonths(-1));
        Test.setCreatedDate([SELECT Id, CreatedDate, THR_OrderKey__c FROM Order WHERE THR_OrderKey__c = '1111C'].Id, Datetime.now().addMonths(-1));

        Test.startTest();
        Database.executeBatch(new THR_OrdersDeleteBatch(), 200);
        Test.stopTest();

        System.assert([SELECT Id FROM Order].size() == 6);
    }
}