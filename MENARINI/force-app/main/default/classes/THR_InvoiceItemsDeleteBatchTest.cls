@IsTest
public with sharing class THR_InvoiceItemsDeleteBatchTest {

    @TestSetup
    public static void setup() {
        Datetime sixMonthsAgo = Datetime.now().addMonths(-6);

        Account acc = THR_TestDataFactory.createAccount('Test Account', 'IT', '1111EF');
        insert acc;
        Contact con = THR_TestDataFactory.CreateSingleCompleteContact(acc.Id);

        THR_Invoice__c inv1 = new THR_Invoice__c(THR_InvoiceKey__c = '12345678', THR_InvoiceBalance__c = 0, THR_Country__c = 'IT');
        insert inv1;
        Test.setCreatedDate(inv1.Id, sixMonthsAgo);

        THR_InvoiceItem__c invIt = new THR_InvoiceItem__c(THR_InvoiceNumber__c = inv1.Id, THR_Quantity__c = 2.0);
        insert invIt;
        Test.setCreatedDate(invIt.Id, sixMonthsAgo);

        THR_InvoiceItem__c invIt2 = new THR_InvoiceItem__c(THR_InvoiceNumber__c = inv1.Id, THR_Quantity__c = 2.0);
        insert invIt2;
        Test.setCreatedDate(invIt2.Id, sixMonthsAgo);

        THR_Invoice__c inv2 = new THR_Invoice__c(THR_InvoiceKey__c = '123456789', THR_InvoiceBalance__c = 0, THR_Country__c = 'IT');
        insert inv2;
        Test.setCreatedDate(inv2.Id, sixMonthsAgo);

        THR_InvoiceItem__c invIt3 = new THR_InvoiceItem__c(THR_InvoiceNumber__c = inv2.Id, THR_Quantity__c = 2.0);
        insert invIt3;
        Test.setCreatedDate(invIt3.Id, sixMonthsAgo);

        THR_InvoiceItem__c invIt4 = new THR_InvoiceItem__c(THR_InvoiceNumber__c = inv2.Id, THR_Quantity__c = 2.0);
        insert invIt4;
        Test.setCreatedDate(invIt4.Id, sixMonthsAgo);

        Account deposit = THR_TestDataFactory.depositAccountCreation();
        insert deposit;

        Case cs = THR_TestDataFactory.createCase('THR_ReturnRequest', acc.Id, con.Id, 'All', 'IT', deposit.Id);
        insert cs;

        List<Product2> products = THR_TestDataFactory.ProductCreation();
        THR_Related_Object__c caseItem = THR_TestDataFactory.caseItemCreation(products[0].Id,'Product', cs.Id);
        caseItem.THR_Invoice__c = inv1.Id;
        update caseItem;

    }

    @IsTest
    public static void invoiceItemsDeleteBatchTest() {
        Test.startTest();
        Database.executeBatch(new THR_InvoiceItemsDeleteBatch(), 200);
        Test.stopTest();

        System.assertEquals(1,[SELECT Id FROM THR_Invoice__c].size());
        System.assertEquals(2,[SELECT Id FROM THR_InvoiceItem__c].size());

    }
}