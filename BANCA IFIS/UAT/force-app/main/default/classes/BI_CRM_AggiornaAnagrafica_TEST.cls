@isTest 
private class BI_CRM_AggiornaAnagrafica_TEST {

	@TestSetup
	private static void setupData() {
		WGC_AllDataFactory.disattivaTrigger();
		EndpointServizi__c eps = new EndpointServizi__c();         
		eps.Name = 'settings';
		eps.LAGKey__c = 'B3DAF392-AF8C-4687-8387-48261E9A63FD';        
		eps.URLGetListaAziendeRibes__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/getlistaaziendecompositeservice/getlistaaziende';
		eps.URLGetInformazioniPGRibes__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/getprodottopgcompositeservice/getprodottopg';
		insert eps;
        List<Account> listAcc = WGC_AllDataFactory.createAccount(1,true);
		
	}

	@isTest
	private static void testValorizzaAccount() {
		Test.startTest();
		Account acc = [SELECT Id FROM Account LIMIT 1];
			
		BI_CRM_AggiornaAnagrafica_CTRL.valorizzaAccount(acc.Id);
		BI_CRM_AggiornaAnagrafica_CTRL.aggiornaAccount(acc);
		Test.stopTest();
	}
}