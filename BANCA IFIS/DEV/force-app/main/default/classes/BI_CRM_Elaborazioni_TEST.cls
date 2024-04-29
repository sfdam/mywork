@isTest
public class BI_CRM_Elaborazioni_TEST  {

	@testSetup
	static void setupDati() {	
		List<Account> a = WGC_AllDataFactory.createAccount(1, true);
		Elaborazioni__c elab = new Elaborazioni__c(Name=a.get(0).Id, Stato__c='Da elaborare', Processo__c = 'Completa anagrafica');
		insert elab;
	}

	@isTest 
	static void testSuddivisioneTerritoriale() {

		Test.startTest();

		BI_CRM_Elaborazioni_BTCH s = new BI_CRM_Elaborazioni_BTCH();
		Database.executeBatch(s,1);

		Test.stopTest();
	}
}