@isTest 
private class TransferOrdersViaMail_Batch_Test {
    
    @isTest 
    static void test_AnyDatas() {
        
        cgcloud__Order_Template__c tmpl0 = new cgcloud__Order_Template__c();
        
        insert tmpl0;
        
        Account acc0 = new Account();
        acc0.Name = 'TestAcc0';
        acc0.ART_Transfer_Order_Delivery_Mode__c = 'FTP';
        acc0.Email_2__c = 'testMail0@domain.com';
        acc0.THR_AccountsKey__c = '1'+String.valueOf(System.currentTimeMillis());
        Account acc1 = new Account();
        acc1.Name = 'TestAcc1';
        acc1.ART_Transfer_Order_Delivery_Mode__c = 'Email';
        acc1.Email_2__c = 'testMail0@domain.com';
        acc1.THR_AccountsKey__c = '2'+String.valueOf(System.currentTimeMillis());
        Account acc2 = new Account();
        acc2.Name = 'TestAcc2';
        acc2.ART_Transfer_Order_Delivery_Mode__c = 'Email';
        acc2.Email_2__c = 'testMail02@domain.com';
        acc2.THR_AccountsKey__c = '3'+String.valueOf(System.currentTimeMillis());
        insert new List<Account> { acc0, acc1, acc2 };
        
        Cgcloud__Order__c order0 = new Cgcloud__Order__c();
        //order0.Name = 'Name0Test'; NOW WRATABLE 
        order0.cgcloud__Mobility_Release__c = true;
        order0.cgcloud__Wholesaler__c = acc1.Id;
        order0.cgcloud__Order_Template__c = tmpl0.Id;
        order0.ART_Order_To_Be_Sent__c = true;
		order0.ART_Order_send_block__c = false;
        order0.cgcloud__Phase__c = 'Ready';
        Cgcloud__Order__c order01 = new Cgcloud__Order__c();
        order01.cgcloud__Mobility_Release__c = true;
        order01.cgcloud__Wholesaler__c = acc2.Id;
        order01.cgcloud__Order_Template__c = tmpl0.Id;
        order01.ART_Order_To_Be_Sent__c = true;
		order01.ART_Order_send_block__c = false;
        order01.cgcloud__Phase__c = 'Ready';
        Cgcloud__Order__c order02 = new Cgcloud__Order__c();
        order02.cgcloud__Mobility_Release__c = true;
        order02.cgcloud__Wholesaler__c = acc2.Id;
        order02.cgcloud__Order_Template__c = tmpl0.Id;
        order02.ART_Order_To_Be_Sent__c = true;
		order02.ART_Order_send_block__c = false;
        order02.cgcloud__Phase__c = 'Ready';
        insert new List<Cgcloud__Order__c> { order0, order01, order02 };
        List<Cgcloud__Order__c> quer = [SELECT Id, ART_OrderItemRowsCount__c FROM Cgcloud__Order__c];
        System.debug('Cgcloud__Order__c 1 ' + quer.get(0).ART_OrderItemRowsCount__c + ', 2 ' + quer.get(1).ART_OrderItemRowsCount__c 
                     + ', ' + quer.get(2).ART_OrderItemRowsCount__c);
        TransferOrdersViaMail_Batch batch_to_test_phase = new TransferOrdersViaMail_Batch();
        
        Test.startTest();
        Database.executeBatch( batch_to_test_phase );
        Test.stopTest();
    }
    
    @isTest 
    static void test_zeroDatas() {
		TransferOrdersViaMail_Batch batch_to_test_phase = new TransferOrdersViaMail_Batch();
        
        Test.startTest();
        Database.executeBatch( batch_to_test_phase );
        Test.stopTest();
    } 
}