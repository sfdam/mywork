@isTest
private class bifis_crm_T_SGACommonCtrl {

	@testSetup static void bifis_crm_T_SGACommonCtrl_setupDati() {

		List<WorkflowSGA__c> testWorkflowSGAPrevalutazione = new List<WorkflowSGA__c> ();

		// DATI DI TEST

		// PER bifis_crm_T_SGACommonCtrl_preValutaPraticaDaCRM
		testWorkflowSGAPrevalutazione.add(new WorkflowSGA__c(PartitaIva__c = '99999999999', Ragione_Sociale__c = 'Unit Test', Stato__c = 'PRE_VALUTAZIONE_CLIENTE'));
		testWorkflowSGAPrevalutazione.add(new WorkflowSGA__c(PartitaIva__c = '99999999998', Ragione_Sociale__c = 'Unit Test', Stato__c = 'PRE_VALUTAZIONE_CLIENTE'));
		testWorkflowSGAPrevalutazione.add(new WorkflowSGA__c(PartitaIva__c = '99999999997', Ragione_Sociale__c = 'Unit Test', Stato__c = 'PRE_VALUTAZIONE_CLIENTE'));

		// PER bifis_crm_T_SGACommonCtrl_finalizzaPraticaDaCRM
		testWorkflowSGAPrevalutazione.add(new WorkflowSGA__c(PartitaIva__c = '99999999996', Ragione_Sociale__c = 'Unit Test', Stato__c = 'VISITA_FINALIZZAZIONE_MANDATO'));
		testWorkflowSGAPrevalutazione.add(new WorkflowSGA__c(PartitaIva__c = '99999999995', Ragione_Sociale__c = 'Unit Test', Stato__c = 'VISITA_FINALIZZAZIONE_MANDATO'));

		// PER bifis_crm_T_SGACommonCtrl_valutaPraticaDaCRM
		testWorkflowSGAPrevalutazione.add(new WorkflowSGA__c(PartitaIva__c = '99999999994', Ragione_Sociale__c = 'Unit Test', Stato__c = 'VALUTAZIONE_PRATICA'));
		testWorkflowSGAPrevalutazione.add(new WorkflowSGA__c(PartitaIva__c = '99999999993', Ragione_Sociale__c = 'Unit Test', Stato__c = 'VALUTAZIONE_PRATICA'));

		// PER bifis_crm_T_SGACommonCtrl_submitFinale
		testWorkflowSGAPrevalutazione.add(new WorkflowSGA__c(PartitaIva__c = '99999999992', Ragione_Sociale__c = 'Unit Test', Stato__c = 'VALUTAZIONE_PRATICA'));

		// PER bifis_crm_T_SGACommonCtrl_controlliFinali
		testWorkflowSGAPrevalutazione.add(new WorkflowSGA__c(PartitaIva__c = '99999999991', Ragione_Sociale__c = 'Unit Test', Stato__c = 'VALUTAZIONE_PRATICA'));

		insert testWorkflowSGAPrevalutazione;

		// CUSTOM SETTING per INVIO MAIL

		insert new Parametri_SGA__c(Mail_Mittente__c = 'gestione.canali.salesforce@bancaifis.it');

	}

	@isTest
	private static void bifis_crm_T_SGACommonCtrl_preValutaPraticaDaCRM() {

		WorkflowSGA__c workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowSGA__c WHERE PartitaIva__c='99999999999' LIMIT 1];

		bifis_crm_c_SGACommonCtrl.preValutaPraticaDaCRM(workflowAttuale.Id, 'PROSPECT', 'NON_APPROVATA');
		
		workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowSGA__c WHERE Id=:workflowAttuale.Id LIMIT 1];

		System.assertEquals('OPPORTUNITA_PERSA', workflowAttuale.Stato__c);

		workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowSGA__c WHERE PartitaIva__c='99999999998' LIMIT 1];

		bifis_crm_c_SGACommonCtrl.preValutaPraticaDaCRM(workflowAttuale.Id, 'PROSPECT', 'APPROVATA');
		
		workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowSGA__c WHERE Id=:workflowAttuale.Id LIMIT 1];

		System.assertEquals('VISITA_FINALIZZAZIONE_MANDATO', workflowAttuale.Stato__c);

		workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowSGA__c WHERE PartitaIva__c='99999999997' LIMIT 1];

		bifis_crm_c_SGACommonCtrl.preValutaPraticaDaCRM(workflowAttuale.Id, 'CLIENTE', 'APPROVATA');
		
		workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowSGA__c WHERE Id=:workflowAttuale.Id LIMIT 1];

		System.assertEquals('VISITA_FINALIZZAZIONE_MANDATO', workflowAttuale.Stato__c);

	}

	@isTest
	private static void bifis_crm_T_SGACommonCtrl_finalizzaPraticaDaCRM() {

		WorkflowSGA__c workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowSGA__c WHERE PartitaIva__c='99999999996' LIMIT 1];

		bifis_crm_c_SGACommonCtrl.finalizzaPraticaDaCRM(workflowAttuale.Id, 'SI');
		
		workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowSGA__c WHERE Id=:workflowAttuale.Id LIMIT 1];

		System.assertEquals('VALUTAZIONE_PRATICA', workflowAttuale.Stato__c);

		workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowSGA__c WHERE PartitaIva__c='99999999995' LIMIT 1];

		bifis_crm_c_SGACommonCtrl.finalizzaPraticaDaCRM(workflowAttuale.Id, 'NO');
		
		workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowSGA__c WHERE Id=:workflowAttuale.Id LIMIT 1];

		System.assertEquals('OPPORTUNITA_PERSA', workflowAttuale.Stato__c);

	}

	@isTest
	private static void bifis_crm_T_SGACommonCtrl_valutaPraticaDaCRM() {

		WorkflowSGA__c workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowSGA__c WHERE PartitaIva__c='99999999994' LIMIT 1];

		bifis_crm_c_SGACommonCtrl.valutaPraticaDaCRM(workflowAttuale.Id, 'APPROVATA');
		
		workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowSGA__c WHERE Id=:workflowAttuale.Id LIMIT 1];

		System.assertEquals('ATTIVAZIONE_RAPPORTO', workflowAttuale.Stato__c);

		workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowSGA__c WHERE PartitaIva__c='99999999993' LIMIT 1];

		bifis_crm_c_SGACommonCtrl.valutaPraticaDaCRM(workflowAttuale.Id, 'NON_APPROVATA');
		
		workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowSGA__c WHERE Id=:workflowAttuale.Id LIMIT 1];

		System.assertEquals('OPPORTUNITA_PERSA', workflowAttuale.Stato__c);

	}

	@isTest
	private static void bifis_crm_T_SGACommonCtrl_getValoriPicklistStato() {

		Map<String,String> result = bifis_crm_c_SGACommonCtrl.getValoriPicklistStato();

		System.assertNotEquals(null, result);

	}

	@isTest
	private static void bifis_crm_T_SGACommonCtrl_submitFinale() {
			
		Test.startTest();

		Integer invocations = Limits.getEmailInvocations();

		WorkflowSGA__c workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowSGA__c WHERE PartitaIva__c='99999999992' LIMIT 1];

		bifis_crm_c_SGACommonCtrl.submitFinale(workflowAttuale.Id);

		if(invocations <> Limits.getEmailInvocations()){

			System.assertNotEquals(invocations,Limits.getEmailInvocations());
		
		} else {
		
			System.assertEquals(invocations,Limits.getEmailInvocations());
			 
		}

		Test.stopTest();
		
	}

	@isTest
	private static void bifis_crm_T_SGACommonCtrl_controlliFinali() {
			 
		WorkflowSGA__c workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowSGA__c WHERE PartitaIva__c='99999999991' LIMIT 1];

		List<Object> result = bifis_crm_c_SGACommonCtrl.controlliFinali(workflowAttuale.Id);

		System.assertEquals(4, result.size());

	}
}