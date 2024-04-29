@isTest 
private class TransferOrderForWholesalerCtrl_Test {
    
    @TestSetup
    static void load(){
        cgcloud__Order_Template__c tmpl0 = new cgcloud__Order_Template__c();
	
        insert tmpl0;
        
        Account acc0 = new Account();
        acc0.Name = 'TestAcc0';
        acc0.ART_Transfer_Order_Delivery_Mode__c = 'FTP';
        acc0.THR_Mail__c = 'testMail0@domain.com';
        acc0.BillingCity = 'Cinisello';
        //acc0.BillingState = 'VIA XYZ';
        acc0.BillingStreet = 'TEST0';
        acc0.THR_VATNumber__c = '0000';
        acc0.THR_CustomerIdentificationCode__c = '0000';
        acc0.THR_AccountsKey__c = '1'+String.valueOf(System.currentTimeMillis());
        Account acc1 = new Account();
        acc1.Name = 'TestAcc1';
        acc1.ART_Transfer_Order_Delivery_Mode__c = 'Email';
        acc1.THR_MAIL__c = 'testMail0@domain.com';
        acc1.BillingCity = 'Cinisello';
        //acc1.BillingState = 'VIA XYZ';
        acc1.BillingStreet = 'TEST0';
        acc1.THR_VATNumber__c = '0001';
        acc1.THR_CustomerIdentificationCode__c = '001';
        acc1.THR_AccountsKey__c = '2'+String.valueOf(System.currentTimeMillis());
        insert new List<Account> { acc0, acc1 };
 		
        THR_TestDataFactory.ProductCreation();
        Product2 p0 = [SELECT Id FROM Product2 LIMIT 1];

        Cgcloud__Order__c order0 = new Cgcloud__Order__c();
        //order0.Name = 'Name0Test'; NOW WRATABLE 
        order0.cgcloud__Wholesaler__c = acc1.Id;
        order0.cgcloud__Order_Template__c = tmpl0.Id;
        order0.cgcloud__Delivery_Date__c  = Date.today();
        
        order0.ART_Order_To_Be_Sent__c = true;
		order0.ART_Order_send_block__c = false;
        order0.cgcloud__Phase__c = 'Ready';
        Cgcloud__Order__c order01 = new Cgcloud__Order__c();
        order01.cgcloud__Wholesaler__c = acc1.Id;
        order01.cgcloud__Order_Template__c = tmpl0.Id;
        order01.cgcloud__Delivery_Date__c  = Date.today();
        order01.ART_Order_To_Be_Sent__c = true;
		order01.ART_Order_send_block__c = false;
        order01.cgcloud__Phase__c = 'Ready';
        Cgcloud__Order__c order02 = new Cgcloud__Order__c();
        order02.cgcloud__Wholesaler__c = acc1.Id;
        order02.cgcloud__Order_Template__c = tmpl0.Id;
        order02.cgcloud__Delivery_Date__c  = Date.today();
        order02.ART_Order_To_Be_Sent__c = true;
		order02.ART_Order_send_block__c = false;
        order02.cgcloud__Phase__c = 'Ready';
        insert new List<Cgcloud__Order__c> { order0, order01, order02 };
            
        Cgcloud__Order_Item__c item0 = new cgcloud__Order_Item__c();
        item0.cgcloud__Order__c = order0.Id;
        item0.cgcloud__Product__c = p0.Id;
        Cgcloud__Order_Item__c item01 = new cgcloud__Order_Item__c();
        item01.cgcloud__Order__c = order0.Id;
        item01.cgcloud__Product__c = p0.Id;
        Cgcloud__Order_Item__c item02 = new cgcloud__Order_Item__c();
        item02.cgcloud__Order__c = order01.Id;
        item02.cgcloud__Product__c = p0.Id;
        Cgcloud__Order_Item__c item03 = new cgcloud__Order_Item__c();
        item03.cgcloud__Order__c = order02.Id;
        item03.cgcloud__Product__c = p0.Id;
        Cgcloud__Order_Item__c item04 = new cgcloud__Order_Item__c();
        item04.cgcloud__Order__c = order02.Id;
        item04.cgcloud__Product__c = p0.Id;
        insert new List<cgcloud__Order_Item__c> { item0, item01, item02, item03, item04 };        
        
    }

    @isTest 
    static void test() {
        Account acc0 = [SELECT Id, Name FROM Account WHERE Name = 'TestAcc1'];
        System.debug('TEST Account : ' + acc0);
        Test.startTest();
        PageReference pgRef = Page.TransferOrderForWholesaler;
        Test.setCurrentPage(pgRef); 
        pgRef.getParameters().put('wholesalerId', acc0.Id); 
        
		ApexPages.StandardController sc           = new ApexPages.standardController(acc0); 
        TransferOrderForWholesalerCtrl controller = new TransferOrderForWholesalerCtrl(sc);
        //String fulldate = controller.fulldate;
        Test.stopTest();
    }
}