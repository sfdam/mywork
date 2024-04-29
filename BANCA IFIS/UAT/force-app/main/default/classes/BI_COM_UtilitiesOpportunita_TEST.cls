@isTest 
private class BI_COM_UtilitiesOpportunita_TEST {

  @testSetup
  public static void BI_COM_UtilitiesAnagrafiche_TEST_setupDati() {

	insert BI_COM_UtilitiesSupportoTest_CODE.getImpostazioniServizi();
    insert BI_COM_UtilitiesSupportoTest_CODE.getCustomSettingEndpointServizi();
	insert BI_COM_UtilitiesSupportoTest_CODE.getAccounts();

  }

	@isTest
	private static void BI_COM_UtilitiesOpportunita_TEST_preparaOpportunitaLIGHT() {
			
		Test.startTest();

		Account actualAccount = [SELECT Id, Name, PIVA__c, WGC_Specialista_Factoring__c FROM Account LIMIT 1];

		Opportunity actualOpportunity = BI_COM_UtilitiesOpportunita_CODE.preparaOpportunitaLIGHT(actualAccount);

		System.assertNotEquals(null, actualOpportunity);
			 
		Test.stopTest();

	}

}