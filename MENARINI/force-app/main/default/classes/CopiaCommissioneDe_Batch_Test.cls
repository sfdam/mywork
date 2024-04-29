@isTest
private class CopiaCommissioneDe_Batch_Test {
    
    @TestSetup
    static void load() {
        Profile admin 	  = TestDataFactory.findProfileByName('System Administrator');
        UserRole userRole = TestDataFactory.findUserRoleByDeveloperName('THR_Italy');
		User u = TestDataFactory.createUser(userRole.Id, 'alias010', 'email12@domain.com', 'lastNameAdm4Test1', admin.Id);
        insert u;
        
        Account acc0 = TestDataFactory.createEasyAccount('Acc per test');
        acc0.THR_MAIL__c = 'maildiTest@domail.com';
        
        cgcloud__Order_Template__c tmpl0 = TestDataFactory.createOrderTemplate('Ordine Diretto Pharma'); 
        System.runAs(u) {
            insert acc0;
            insert tmpl0;
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
            System.debug('--- ' + pickListVal.getLabel() + ' ' + pickListVal.getValue());
            piklistDELAY_Order.add(pickListVal.getValue());
        }
        System.debug('Size piklistDELAY_Order ' + piklistDELAY_Order.size());
        cgcloud__Order__c order0 = TestDataFactory.createMobilityReleaseOrder(tmpl0.Id); 
        order0.cgcloud__Order_Account__c = acc0.Id;
        order0.cgcloud__Phase__c = 'Ready';
        order0.Invio_Copia_Commissione__c = null;
		order0.cgcloud__Order_Date__c     = Date.today().addDays(8);
        order0.ART_Payment_Code__c = 'TEST_ART';
        order0.ART_Order_To_Be_Sent__c = true;
		order0.ART_Order_send_block__c = false;
        order0.cgcloud__Order_Id__c = 'OEt1000000058';
        order0.cgcloud__Responsible__c = u.Id;
        cgcloud__Order__c order1 = TestDataFactory.createMobilityReleaseOrder(tmpl0.Id); 
        order1.cgcloud__Order_Account__c = acc0.Id;
        order1.cgcloud__Phase__c = 'Ready';
        order1.Invio_Copia_Commissione__c = null;
		order1.cgcloud__Order_Date__c     = Date.today().addDays(8);
        order1.ART_Payment_Code__c = 'TEST_ART';
        order1.ART_Order_To_Be_Sent__c = true;
		order1.ART_Order_send_block__c = false;
        order1.cgcloud__Responsible__c = u.Id;
        cgcloud__Order__c order2 = TestDataFactory.createMobilityReleaseOrder(tmpl0.Id);
        order2.ART_Delay_days__c = piklistDELAY_Order.get(0);
        order2.cgcloud__Order_Date__c = Date.today();
        order2.cgcloud__Phase__c = 'Initial';
        order2.cgcloud__Responsible__c = u.Id;
        order2.cgcloud__Delivery_Note__c = '' + Date.today().addDays(9);
        order2.cgcloud__Order_Account__c = acc0.Id;
       	order2.cgcloud__Delivery_Date__c  = Date.today();
        order2.ART_Payment_Code__c = 'TEST_ART';
        order2.cgcloud__Mobility_Release__c = false;
        System.runAs(u) {
	        insert new List<cgcloud__Order__c> { order0, order1, order2 };
        }
    }

    @isTest
    static void test() {
        
        Test.startTest();
        CopiaCommissioneDe_Batch bath_test = new CopiaCommissioneDe_Batch();
        bath_test.TestMode = true;
        
        String jobId = System.schedule('Test_CopiaCommissioneDe_Batch',
                                       CopiaCommissioneDe_Batch.CRON_EXP, 
                                       bath_test);
        
        CronTrigger ct = [  SELECT id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CopiaCommissioneDe_Batch.CRON_EXP, ct.CronExpression);        
        
        try {
            Id idBatch = Database.executeBatch(bath_test);
        } catch (Exception e) {}
        
        Test.stopTest();
    }
}