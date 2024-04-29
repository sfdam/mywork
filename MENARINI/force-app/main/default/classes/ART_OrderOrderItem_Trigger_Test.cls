@isTest
public with sharing class ART_OrderOrderItem_Trigger_Test {
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
        product2 p=new product2();
        p.name='testProd';
        p.Description='testDesc';
        p.productCode='TestCode';
        p.THR_MaterialKey__c='TestMatCode';
        insert p;
        Pricebookentry PriceProd =[select id from PricebookEntry where product2Id=:p.Id and Pricebook2Id=:Test.getStandardPricebookId()]; 
        /*Pricebookentry PriceProd=new Pricebookentry();
        PriceProd.Pricebook2Id=Test.getStandardPricebookId();
        PriceProd.product2Id=p.id;
        PriceProd.UnitPrice=10;
        PriceProd.isActive=true;
        insert PriceProd;*/
        OrderItem oi=new orderItem (
            OrderId=ord.id,
            Quantity=10,
            UnitPrice=12,
            product2Id=p.id,
            PricebookEntryId=PriceProd.id,
            THR_OrderItemKey__c='OIKey'
        );
        insert oi;
       
        delete oi;
        delete ord;
        
        Test.stopTest();
    }
}