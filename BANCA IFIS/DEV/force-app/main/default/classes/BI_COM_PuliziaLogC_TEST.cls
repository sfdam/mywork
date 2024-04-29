@isTest 
private class BI_COM_PuliziaLogC_TEST {

	@testSetup 
	static void BI_COM_PuliziaLogC_TEST_setupDati() {

		Log__c newLog = new Log__c();
		
		insert newLog;

		Datetime over180 = Datetime.now().addDays(-181);
		Test.setCreatedDate(newLog.Id, over180);

	}

	@isTest
	private static void testBatch() {

        Test.startTest();

		    BI_COM_PuliziaLogC_BTCH batch = new BI_COM_PuliziaLogC_BTCH();
            DataBase.executeBatch(batch); 
            
        Test.stopTest();

	}

}