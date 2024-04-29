@isTest
public class ART_OrderController_test {
    @isTest 
    static void test() {
        
        Test.startTest();
        Account acc = new Account
        (
			Name = 'test',
            THR_AccountsKey__c = String.valueOf(System.currentTimeMillis()),
            Billingstate='Milano',
            BillingCountry='Italy',
            Billingstreet='VIa',
            BillingPostalcode='222',
            BillingCity='milano'
        );
        Insert Acc;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
        Order ord = new Order(
            AccountId=Acc.id,
            THR_OrderType__c = 'Standard Order',	
            THR_SalesOrganization__c='DST1',	
            THR_OrderKey__c=String.valueOf(System.currentTimeMillis()),	
            THR_Division__c='OT',	
            THR_PurchaseOrderType__c='OCR (Direct)',	
            Status='Draft',	
            Pricebook2Id=Test.getStandardPricebookId(),
            EffectiveDate=date.today()
        );
        insert ord; 
        ART_OrderController.getOrders(Acc.id);
        Test.stopTest();
    }
}