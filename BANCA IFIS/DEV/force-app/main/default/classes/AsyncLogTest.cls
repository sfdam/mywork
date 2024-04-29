@isTest 
private class AsyncLogTest {

	@isTest
	private static void testAfterInsert() {
    

		Test.startTest();
		EventBus.publish(new AsyncLog__e(Source__c='TiAnticipo', ErrorMessage__c='TEST123'));

		Test.getEventBus().deliver();
		List<Log__c> l = [SELECT Id, Source__c, ErorrMessage__c FROM Log__c WHERE Source__c = 'TiAnticipo'];
		System.assertEquals(1, l.size());
		System.assertEquals('TEST123', l.get(0).ErorrMessage__c);
		Test.stopTest();		
	}
}