@isTest 
private class BI_PSG_AcquireAccount_TEST {

	@testSetup 
	static void BI_PSG_AcquireAccount_TEST_setupDati() {

		WorkflowSGA__c newWorkflow = new WorkflowSGA__c();

		newWorkflow.Stato__c = 'PRE_VALUTAZIONE_CLIENTE';
		
		insert newWorkflow;

	}

	@isTest
	private static void testBatch() {

        Test.startTest();

            BI_PSG_AcquireAccount_BTCH batch = new BI_PSG_AcquireAccount_BTCH();
            DataBase.executeBatch(batch); 
            
        Test.stopTest();

	}
}