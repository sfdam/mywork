@isTest 
private class bifis_crm_T_MccNsaHomePageDataTableCtrl {

	@testSetup static void bifis_crm_T_MccNsaHomePageDataTableCtrl_setupDati() {

		List<WorkflowMutui__c> testWorkflowMccNsa = new List<WorkflowMutui__c> ();

		// DATI DI TEST

		// PER bifis_crm_T_MccNsaHomePageDataTableCtrl_fetchWorkflowsMccForHomePage
		testWorkflowMccNsa.add(new WorkflowMutui__c(PartitaIva__c = '99999999999', Ragione_Sociale__c = 'Unit Test', Stato__c = 'BOZZA_DATI'));

		insert testWorkflowMccNsa;

	}

	@isTest
	static void bifis_crm_T_MccNsaHomePageDataTableCtrlFetchWorkflowsMccForHomePage() {

		List < WorkflowMutui__c > recordList = bifis_crm_c_MccNsaHomePageDataTableCtrl.fetchWorkflowsMCCForHomePage('99999999999');

		System.assertEquals(0, recordList.size());


	}

	@isTest
	static void bifis_crm_T_MccNsaHomePageDataTableCtrlDeleteWorkflowMutuiForHomePage() {

	WorkflowMutui__c workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowMutui__c WHERE PartitaIva__c='99999999999' LIMIT 1];

	Boolean result = bifis_crm_c_MccNsaHomePageDataTableCtrl.deleteWorkflowMutuiForHomePage(workflowAttuale.Id);
	
	System.assertEquals(true, result);

	}

}