@isTest
public without sharing class ART_UpdatePaymentStatusOnPayerChild2Test {
    
    @isTest
    static void test_children_update(){
        Test.startTest();
        Account payer = new Account(Name = 'TestPayer', ART_Updated_Payment_Status__c = TRUE, ART_Payment_Status__c = 'Red', THR_CentralDeliveryBlock__c='1', ART_Updated_Central_Delivery_Block__c = TRUE, THR_AccountsKey__c = '1'+String.valueOf(System.currentTimeMillis()));
        insert payer;
        Account child = new Account(Name = 'TestChild', THR_Payer__c = payer.Id, THR_AccountsKey__c = '2'+String.valueOf(System.currentTimeMillis()));
        insert child;
        Database.executeBatch(new ART_UpdatePaymentStatusOnPayerChildren2(), 1);
        Test.stopTest();
    }
}