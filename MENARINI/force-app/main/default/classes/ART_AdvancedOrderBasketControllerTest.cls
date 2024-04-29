@isTest
public class ART_AdvancedOrderBasketControllerTest {

    @TestSetup
    static void makeData(){

        cgcloud__Order_Template__c orderTemplate = new cgcloud__Order_Template__c
		(
        	Name='Ordine Diretto OTC'
        );
        Insert orderTemplate;

        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
        
        Product2 pdL = new Product2();
        pdL.IsActive = true;
        pdL.Name ='ProdTestName0001';
        pdL.ProductCode ='CodProd0001';
        pdL.THR_MaterialKey__c='MK_PT0001';
        insert pdL;
        
        Pricebook2 currPricebook = new Pricebook2();
        currPricebook.Name = 'currPricebookTestName';
        currPricebook.THR_PriceBookKey__c = 'PBKEY001';
        insert currPricebook;
        
        Bundle__c bundle = new Bundle__c();
        bundle.Name = 'Bundle 1';
        bundle.From__c = 1;
        bundle.To__c = 99999;
        bundle.Priority__c = '1';
        bundle.Order_Template__c = orderTemplate.Id;
        bundle.Is_Active__c = true;
        bundle.Campo_raggruppamento__c = 'ART_Rural__c';
        bundle.Cliente__c = 'NON Rural';
        bundle.StartDate__c = Date.today().addDays(-10);
        bundle.EndDate__c = Date.today().addDays(10);
        insert bundle;

        Bundle_Item__c bundleItem = new Bundle_Item__c();
        bundleItem.Bundle__c = bundle.Id;
        bundleItem.Product__c = pdL.Id;
        bundleItem.Discount__c = 50;
        insert bundleItem;
        
        
        Account account = new Account(
            Name = 'testPayer',
            THR_AccountsKey__c = String.valueOf(System.currentTimeMillis()),
            BillingStreet = 'testPayer',
            BillingCountry = 'Italy',
            BillingState = 'Napoli'
        );
        Insert account;
        cgcloud__Order__c order = new cgcloud__Order__c(
            cgcloud__Order_Template__c = orderTemplate.Id,
            cgcloud__Order_Account__c = account.Id
        );
        Insert order;
        
        cgcloud__Order_Item__c orderItem = new cgcloud__Order_Item__c
        (
            cgcloud__Order__c = order.Id
        );
        Insert orderItem;
        cgcloud__Order_Item__c orderItem1 = new cgcloud__Order_Item__c
        (
            cgcloud__Order__c = order.Id,
            cgcloud__Quantity__c = 100//, 
            //cgcloud__Product__c=orderItem.Id
        );
        Insert orderItem1;
    }

    @isTest
    static void test() {
        
        Test.startTest();
        
        cgcloud__Order_Template__c orderTemplate = [SELECT ID FROM cgcloud__Order_Template__c LIMIT 1];
        Product2 product = [SELECT ID FROM Product2 LIMIT 1];
        
        
        Account account = new Account(
            Name = 'test',
            THR_AccountsKey__c = String.valueOf(System.currentTimeMillis()),
            BillingStreet = 'test',
            BillingCountry = 'Italy',
            BillingState = 'Napoli'
        );
        Insert account;

        Account payer = new Account(
            Name = 'testPayer',
            THR_AccountsKey__c = String.valueOf(System.currentTimeMillis()),
            BillingStreet = 'testPayer',
            BillingCountry = 'Italy',
            BillingState = 'Napoli'
        );
        Insert payer;
            
        cgcloud__Order__c order = new cgcloud__Order__c(
            cgcloud__Order_Template__c = orderTemplate.Id,
            cgcloud__Order_Account__c = account.Id
        );
        Insert order;
        
        cgcloud__Order_Item__c orderItem = new cgcloud__Order_Item__c
        (
            cgcloud__Order__c = order.Id
        );
        Insert orderItem;
        Assortment ass = new Assortment
        (
			Name = 'test'
        );
        Insert ass;
        
        StoreAssortment sass = new StoreAssortment
        (
            AssortmentId = ass.Id,
			AccountId = account.Id,
            StartDate = System.today()
        );
        Insert sass;
        
        cgcloud__Product_Assortment_Order_Template__c paot = new cgcloud__Product_Assortment_Order_Template__c
        (
			cgcloud__Order_Template__c = orderTemplate.Id,
            cgcloud__Product_Assortment__c = ass.Id
        );
        Insert paot;
        
        cgcloud__Order_Item_Template__c orderItemTemplate = new cgcloud__Order_Item_Template__c
        (
            Name = 'Codifi Standard'
        );
        Insert orderItemTemplate;

        cgcloud__Account_Relationship__c accountRelationShip = new cgcloud__Account_Relationship__c
        (
            cgcloud__Related_Account__c = payer.Id,
            cgcloud__Account__c = account.Id,
            cgcloud__Relationship_Type__c = 'Payer'
        );
         
        List<Map<String, Object>> recordList = new List<Map<String, Object>>();
        Map<String, Object> objMap = new Map<String, Object>();
        objMap.put('cgcloud__Price__c', 1);
        objMap.put('cgcloud__Quantity__c', 1);
		objMap.put('cgcloud__Discount__c', 1);
        objMap.put('cgcloud__ProductCode','codetest');
        objMap.put('scontoLegge', true);
        //objMap.put('Id', orderItem.Id);
        recordList.add(objMap);
        
        ART_AdvancedOrderBasketController.fetchCloudOrderItems(order.Id);
        ART_AdvancedOrderBasketController.deleteCloudOrderItem(orderItem.Id, new List<cgcloud__Order_Item__c>());
        ART_AdvancedOrderBasketController.getProduct(account.Id, orderTemplate.Id);
        ART_AdvancedOrderBasketController.saveProduct(order.Id, recordList);

        // DK START DE-033A Bis
        Map<String, Object> orderItemQuantityMap = new Map<String, Object>();
        orderItemQuantityMap.put(product.Id, 30);
        Map<String, Object> filetrMap = new Map<String, Object>();
        filetrMap.put('ART_Rural__c', 'NON Rural');
        Map<String, Object> getBundleDiscountsResponse = ART_AdvancedOrderBasketController.getBundleDiscounts(JSOn.serialize(orderItemQuantityMap), orderTemplate.Id, JSOn.serialize(filetrMap));
        // DK END DE-033A Bis


        // List<cgcloud__Order__c> order = [SELECT ID FROM cgcloud__Order__c LIMIT 1];
        String orderId = order.Id;
        Object getOrderItemsToCloneResponse = ART_AdvancedOrderBasketController.getOrderItemsToClone(orderId, account.Id);
        List<cgcloud__Order_Item__c> orderItems =  Database.query(SV_Utilities.selectAllField('cgcloud__Order_Item__c') + ' WHERE cgcloud__Order__c =: orderId');
        Object cloneOrderResponse = ART_AdvancedOrderBasketController.cloneOrder(account.Id, orderId, orderItems);
        Test.stopTest();
	}
    
    @isTest static void test_orderItemDelete(){
        cgcloud__Order_Item__c item=[SELECT Id FROM cgcloud__Order_Item__c LIMIT 1];
        cgcloud__Order_Item__c item1=[SELECT Id FROM cgcloud__Order_Item__c WHERE cgcloud__Quantity__c=100];
        String focusId= item.Id;
        Test.startTest();
        Boolean isDelete=ART_AdvancedOrderBasketController.orderItemDelete(new List<String>{focusId}, new List<cgcloud__Order_Item__c>{item1});
        Test.stopTest();
    }
}