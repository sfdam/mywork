@isTest 
private class QbleCalcoloPreventivoTest {

	@isTest
	private static void testCalcoloPreventivo() {
		Funzionalita__c f = Funzionalita__c.getInstance();
		f.DisabilitaControlloCambioFaseOpp__c = true;
		f.DisabilitaNamingAutomaticaOpportunita__c = true;
		f.WGC_disabilita_per_batch__c = true; //adione-crm20
		upsert f;
		insert new Prodotto__c(CodiceUnivoco__c = 'ATDTiAnticipo');
		User userTest = TestUtils.creaUtente('userTest');
		Account a = TestUtils.creaAccount('AccountTest', userTest);
		Cessione__c cCon = TestUtils.creaCessioneCompleta(a);

		QueueItemPreventivo__c prev = new QueueItemPreventivo__c(
			Cessione__c = cCon.Id/*,
			Solved__c = false, 
			Errori__c = 'blah blah', 
			Status__c = 'Failed', 
			TentativiEseguiti__c = 1*/);
		insert prev;
		QueueItemPreventivo__c[] preventivi = new QueueItemPreventivo__c[]{};
		preventivi.add(prev);
		QbleCalcoloPreventivo q = new QbleCalcoloPreventivo(preventivi);

        Test.startTest();        
        System.enqueueJob(q);
        Test.stopTest();
	}
}