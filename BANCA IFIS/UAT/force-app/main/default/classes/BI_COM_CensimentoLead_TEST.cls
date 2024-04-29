/**
  * Progetto:         Revisione componenti core per CRM 2.0.
  * Sviluppatore      Marco Bonin <marco.bonin@bancaifis.it>
  * Descrizione:      Classe di test per BI_COM_CensimentoLead_CODE
  *
*/

@isTest
private class BI_COM_CensimentoLead_TEST {

	@testSetup
	public static void BI_COM_CensimentoLead_TEST_setupDati() {

		Campaign campagna = TestUtils.creaCampagna();
		TestUtils.CreaImpostazioni(campagna);
		User dora = TestUtils.creaUtente('dora');
		dora.LoginSiebel__c = 'ls';
		update dora;
		TestUtils.impostaCS();

		insert BI_COM_UtilitiesSupportoTest_CODE.getCustomSettingEndpointServizi();

	}

	@isTest
	public static void testCensimentoLeadPG() {

		WGC_AllDataFactory.createUtenzaDefault();
		WGC_AllDataFactory.createLagKey();
		WGC_AllDataFactory.creaImpServ();

		insert BI_COM_UtilitiesSupportoTest_CODE.getLeadPG_DaCensire();

		TestUtils.creaAccount('nomeAccount', 'MI', '02168580120', null);

		Set<Id> leads = U.getIdSet([SELECT Id FROM Lead], 'Id');

		Test.startTest();

		BI_COM_CensimentoLead_BTCH bcl = new BI_COM_CensimentoLead_BTCH(leads);

		Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());

		DataBase.executeBatch(bcl); 

		Test.stopTest();

	}

	@isTest
	public static void testCensimentoLeadDI() {

		WGC_AllDataFactory.createUtenzaDefault();
		WGC_AllDataFactory.createLagKey();
		WGC_AllDataFactory.creaImpServ();

		insert BI_COM_UtilitiesSupportoTest_CODE.getLeadDI_DaCensire();

		TestUtils.creaAccount('nomeAccount', 'MI', '02168580120', null);

		Set<Id> leads = U.getIdSet([SELECT Id FROM Lead], 'Id');

		Test.startTest();

		BI_COM_CensimentoLead_BTCH bcl = new BI_COM_CensimentoLead_BTCH(leads);

		Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());

		DataBase.executeBatch(bcl); 

		Test.stopTest();

	}
}