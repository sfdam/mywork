@isTest 
private class bifis_crm_T_SGAHomePageDataTableCtrl {

	@testSetup static void bifis_crm_T_SGAHomePageDataTableCtrl_setupDati() {

		List<WorkflowSGA__c> testWorkflowSGAPrevalutazione = new List<WorkflowSGA__c> ();

		// DATI DI TEST

		// PER bifis_crm_T_SGAHomePageDataTableCtr_fetchWorkflowsSGAForHomePage
		testWorkflowSGAPrevalutazione.add(new WorkflowSGA__c(PartitaIva__c = '99999999999', Ragione_Sociale__c = 'Unit Test', Stato__c = 'PRE_VALUTAZIONE_CLIENTE'));

		insert testWorkflowSGAPrevalutazione;

	}

	@isTest
	static void bifis_crm_T_SGAHomePageDataTableCtrlFetchWorkflowsSGAForHomePage() {

		List < WorkflowSGA__c > recordList = bifis_crm_c_SGAHomePageDataTableCtrl.fetchWorkflowsSGAForHomePage('99999999999');

		System.assertEquals(0, recordList.size());


	}

	@isTest
	static void bifis_crm_T_SGAHomePageDataTableCtrlDeleteWorkflowSGAForHomePage() {

	WorkflowSGA__c workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowSGA__c WHERE PartitaIva__c='99999999999' LIMIT 1];

	Boolean result = bifis_crm_c_SGAHomePageDataTableCtrl.deleteWorkflowSGAForHomePage(workflowAttuale.Id);
	
	System.assertEquals(true, result);

	}

}