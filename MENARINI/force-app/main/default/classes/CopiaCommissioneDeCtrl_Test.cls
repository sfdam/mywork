@isTest
private class CopiaCommissioneDeCtrl_Test {
    
    @TestSetup
    static void load() {
        Profile admin 	  = TestDataFactory.findProfileByName('System Administrator');
        UserRole userRole = TestDataFactory.findUserRoleByDeveloperName('THR_Italy');
		User u = TestDataFactory.createUser(userRole.Id, 'alias018', 'emailprod@domain.com', 'lastNameAdm41Testprod', admin.Id);
        insert u;
        
        cgcloud__Order_Template__c tmpl0 = TestDataFactory.createOrderTemplate('Ordine Diretto Pharma');
        cgcloud__Order_Template__c tmpl1 = TestDataFactory.createOrderTemplate('Ordine Diretto OTC');
        cgcloud__Order_Template__c tmpl2 = TestDataFactory.createOrderTemplate('Transfer Order');
        Account acc0 = TestDataFactory.createEasyAccount('TestNameAcc0');
        acc0.THR_CustomerIdentificationCode__c = '00';
        acc0.ShippingStreet = 'vai ews';
        acc0.ShippingPostalCode = '20129';
        acc0.ShippingCity = 'Cinisello';
        acc0.ShippingState = 'Milano';
        acc0.ShippingCountry = 'Italy';
        acc0.THR_VATNumber__c = '98';
        acc0.THR_CUU__c = '98';
        acc0.ART_Rural__c = false;
        System.runAs(u) {
            insert new List<cgcloud__Order_Template__c> {tmpl0, tmpl1, tmpl2};
            insert acc0;    
        } 
        String objectName = 'cgcloud__Order__c';
        String fieldName  = 'ART_Delay_days__c';        
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<String> piklistDELAY_Order = new List<String>();
        for( Schema.PicklistEntry pickListVal : ple) {
            piklistDELAY_Order.add(pickListVal.getValue());
        }
        System.debug('Size piklistDELAY_Order ' + piklistDELAY_Order.size());
        
        cgcloud__Order__c order = TestDataFactory.createMobilityReleaseOrder(tmpl0.Id);
        order.ART_Delay_days__c = piklistDELAY_Order.get(0);
        order.cgcloud__Order_Date__c = Date.today();
        order.cgcloud__Phase__c = 'Initial';
        order.cgcloud__Responsible__c = u.Id;
        order.cgcloud__Delivery_Note__c = '' + Date.today().addDays(9);
        order.cgcloud__Order_Account__c = acc0.Id;
        order.cgcloud__Delivery_Date__c  = Date.today();
        order.ART_Payment_Code__c = 'TEST_ART';
        order.cgcloud__Payer__c = acc0.Id;
        cgcloud__Order__c order01 = TestDataFactory.createMobilityReleaseOrder(tmpl1.Id);
        order01.ART_Delay_days__c = piklistDELAY_Order.get(1);
        order01.cgcloud__Order_Date__c = Date.today();
        order01.cgcloud__Phase__c = 'Initial';
        order01.cgcloud__Responsible__c = u.Id;
        order01.cgcloud__Delivery_Note__c = '' + Date.today().addDays(9);
        order01.cgcloud__Order_Account__c = acc0.Id;
        order01.cgcloud__Delivery_Date__c  = Date.today();
        order01.ART_Payment_Code__c = 'TEST_ART1';
        order01.cgcloud__Payer__c = acc0.Id;
        cgcloud__Order__c order02 = TestDataFactory.createMobilityReleaseOrder(tmpl0.Id);
        order02.ART_Delay_days__c = piklistDELAY_Order.get(0);
        order02.cgcloud__Order_Date__c = Date.today();
        order02.cgcloud__Phase__c = 'Initial';
        order02.cgcloud__Responsible__c = u.Id;
        order02.cgcloud__Delivery_Note__c = '' + Date.today().addDays(9);
        order02.cgcloud__Order_Account__c = acc0.Id;
        order02.cgcloud__Delivery_Date__c  = Date.today();
        order02.ART_Payment_Code__c = 'TEST_ART';
        order02.cgcloud__Payer__c = acc0.Id;
        
        System.runAs(u) {
            insert new List<cgcloud__Order__c> {order, order01, order02};
            List<Product2> products = THR_TestDataFactory.ProductCreation();
            products.get(0).THR_IndustryStandard__c  = '999';
            products.get(0).THR_DiscountSegment__c   = 'E';
            products.get(0).THR_TaxClassification__c = 43.8;
            products.get(0).THR_ZLAW__c 		     =  19.2;
            products.get(1).THR_IndustryStandard__c  = '999';
            products.get(1).THR_DiscountSegment__c   = 'C';
            products.get(1).THR_TaxClassification__c = 43.8;
            Product2 pdL = new Product2(IsActive = true,
                Name ='ProdTestName0003',
                ProductCode ='CodProd0003',
                THR_MaterialKey__c='MK_PT0003',
                THR_IndustryStandard__c  = '999',
                THR_DiscountSegment__c   = 'H');
            upsert new List<Product2>{products.get(0), products.get(1), pdL};
            
            Id pricebookId = Test.getStandardPricebookId();
	        Pricebookentry PriceProd =[select id from PricebookEntry where product2Id=:pdL.Id and Pricebook2Id=:pricebookId]; 
            
			cgcloud__Order_Item__c item = TestDataFactory.createOrderItem(order.Id, products.get(0).Id);
            item.cgcloud__Pricing_Info_1__c = 2.22;
            item.cgcloud__Price__c = 11234588.222;
            item.cgcloud__Quantity__c = 5521.2;
            item.cgcloud__Discount__c = 1;
            item.cgcloud__Value__c = 1.2;
            cgcloud__Order_Item__c item01 = TestDataFactory.createOrderItem(order01.Id, products.get(0).Id);
            item01.cgcloud__Pricing_Info_1__c = 2.87;
            item01.cgcloud__Price__c = 11234588.22;
            item01.cgcloud__Quantity__c = 5521.209;
            item01.cgcloud__Discount__c = 901;
            item01.cgcloud__Value__c = 1.9;
            cgcloud__Order_Item__c item02 = TestDataFactory.createOrderItem(order01.Id, products.get(1).Id);
            item02.cgcloud__Pricing_Info_1__c = 2.87;
            item02.cgcloud__Price__c = 11234588.22;
            item02.cgcloud__Quantity__c = 5521.209;
            item02.cgcloud__Discount__c = 901;
            item02.cgcloud__Value__c = 1.9;
            cgcloud__Order_Item__c item03 = TestDataFactory.createOrderItem(order01.Id, pdL.Id);
            item03.cgcloud__Pricing_Info_1__c = 2.87;
            item03.cgcloud__Price__c = 11234588.22;
            item03.cgcloud__Quantity__c = 5521.209;
            item03.cgcloud__Discount__c = 901;
            item03.cgcloud__Value__c = 1.9;
            cgcloud__Order_Item__c item05 = TestDataFactory.createOrderItem(order.Id, products.get(1).Id);
            item05.cgcloud__Pricing_Info_1__c = 2.22;
            item05.cgcloud__Price__c = 11234588.222;
            item05.cgcloud__Quantity__c = 5521.2;
            item05.cgcloud__Discount__c = 1;
            item05.cgcloud__Value__c = 1.2;
            insert new List<cgcloud__Order_Item__c> {item, item01, item02, item03, item05};
        }
    }
    
    @isTest 
    static void test() {
        Cgcloud__Order__c order = [SELECT Id FROM Cgcloud__Order__c LIMIT 1];
        Test.startTest();
        PageReference pgRef = Page.CopiaCommissioneDe;
        Test.setCurrentPage(pgRef); 
		ApexPages.StandardController sc           = new ApexPages.standardController(order); 
        
        CopiaCommissioneDeCtrl copiacommDe = new CopiaCommissioneDeCtrl(sc);
        Test.stopTest();
    }
    
    @isTest
    static void test_OrdineDirettoOTCTMPL() {
        Cgcloud__Order__c order = [SELECT Id FROM Cgcloud__Order__c WHERE cgcloud__Order_Template__r.Name = 'Ordine Diretto OTC' LIMIT 1];
        Test.startTest();
        PageReference pgRef = Page.CopiaCommissioneDe;
        Test.setCurrentPage(pgRef); 
		ApexPages.StandardController sc           = new ApexPages.standardController(order); 
        
        CopiaCommissioneDeCtrl copiacommDe = new CopiaCommissioneDeCtrl(sc);
        Test.stopTest();
    }
}