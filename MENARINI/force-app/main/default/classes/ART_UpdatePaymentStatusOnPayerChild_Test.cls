@isTest
public without sharing class ART_UpdatePaymentStatusOnPayerChild_Test {
    
    @isTest
    static void test_children_update(){
        Test.startTest();
        Account payer = new Account(Name = 'TestPayer', ART_Updated_Payment_Status__c = TRUE, ART_Payment_Status__c = 'Red');
        insert payer;
        Account child = new Account(Name = 'TestChild', THR_Payer__c = payer.Id);
        insert child;
        Database.executeBatch(new ART_UpdatePaymentStatusOnPayerChildren(), 1);
        Test.stopTest();
    }
}