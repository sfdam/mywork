@isTest 
private class BI_PNS_HomePageDataTable_TEST {

	@testSetup static void BI_PNS_HomePageDataTable_setupDati() {

		List<WorkflowMutui__c> testWorkflowMccNsa = new List<WorkflowMutui__c> ();

		// DATI DI TEST

		testWorkflowMccNsa.add(new WorkflowMutui__c(PartitaIva__c = '99999999999', Ragione_Sociale__c = 'Unit Test', Stato__c = 'BOZZA_DATI'));

		insert testWorkflowMccNsa;

	}

	@isTest
	static void BI_PNS_HomePageDataTableFetchWorkflowsMccForHomePage() {

		List < WorkflowMutui__c > recordList = BI_PNS_HomePageDataTable_CTRL.fetchWorkflowsMCCForHomePage('99999999999','');

		System.assertEquals(0, recordList.size());


	}

	@isTest
	static void BI_PNS_HomePageDataTableDeleteWorkflowMutuiForHomePage() {

	WorkflowMutui__c workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowMutui__c WHERE PartitaIva__c='99999999999' LIMIT 1];

	Boolean result = BI_PNS_HomePageDataTable_CTRL.deleteWorkflowMutuiForHomePage(workflowAttuale.Id);
	
	System.assertEquals(true, result);

	}

}