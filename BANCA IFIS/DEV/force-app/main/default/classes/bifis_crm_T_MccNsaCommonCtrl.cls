@isTest 
private class bifis_crm_T_MccNsaCommonCtrl {

	@testSetup static void bifis_crm_T_MccNsaCommonCtrl_setupDati() {

		List<WorkflowMutui__c> testWorkflowMutui = new List<WorkflowMutui__c> ();

		// DATI DI TEST

		// PER bifis_crm_T_MccNsaCommonCtrl_attribuzioneQQ
		testWorkflowMutui.add(new WorkflowMutui__c(PartitaIva__c = '99999999995', Fatturato__c = 100000, Tipologia_Mutuo__c = 'ASSICURATIVO', Ragione_Sociale__c = 'Unit Test', Stato__c = 'BOZZA_DATI', REFERENTI_JSON__c ='[{"nome":"LUCIA","cognome":"RIBBA","codiceFiscale":"RBBLCU82D44G565U","ruolo":"Titolare effettivo ed esecutore","tipologiaTE":"Proprietà diretta"}]'));

		// PER bifis_crm_T_SGACommonCtrl_submitFinale
		testWorkflowMutui.add(new WorkflowMutui__c(PartitaIva__c = '99999999994', Tipologia_Mutuo__c = 'ASSICURATIVO', Ragione_Sociale__c = 'Unit Test', Stato__c = 'INVIATA', REFERENTI_JSON__c ='[{"nome":"LUCIA","cognome":"RIBBA","codiceFiscale":"RBBLCU82D44G565U","ruolo":"Titolare effettivo ed esecutore","tipologiaTE":"Proprietà diretta"}]'));
		testWorkflowMutui.add(new WorkflowMutui__c(PartitaIva__c = '99999999993', Tipologia_Mutuo__c = 'STANDARD', Ragione_Sociale__c = 'Unit Test', Stato__c = 'INVIATA', REFERENTI_JSON__c ='[{"nome":"LUCIA","cognome":"RIBBA","codiceFiscale":"RBBLCU82D44G565U","ruolo":"Titolare effettivo ed esecutore","tipologiaTE":"Proprietà diretta"}]'));

		// PER bifis_crm_T_MccNsaCommonCtrl_controlliFinali
		testWorkflowMutui.add(new WorkflowMutui__c(PartitaIva__c = '99999999992', Tipologia_Mutuo__c = 'ASSICURATIVO', Ragione_Sociale__c = 'Unit Test', Stato__c = 'BOZZA_DATI', REFERENTI_JSON__c ='[{"nome":"LUCIA","cognome":"RIBBA","codiceFiscale":"RBBLCU82D44G565U","ruolo":"Titolare effettivo ed esecutore","tipologiaTE":"Proprietà diretta"}]'));
		testWorkflowMutui.add(new WorkflowMutui__c(PartitaIva__c = '99999999991', Tipologia_Mutuo__c = 'STANDARD', Ragione_Sociale__c = 'Unit Test', Stato__c = 'BOZZA_DATI', REFERENTI_JSON__c ='[{"nome":"LUCIA","cognome":"RIBBA","codiceFiscale":"RBBLCU82D44G565U","ruolo":"Titolare effettivo ed esecutore","tipologiaTE":"Proprietà diretta"}]'));

		insert testWorkflowMutui;

		// CUSTOM SETTING per INVIO MAIL

		insert new Parametri_MccNsa__c(Mail_Mittente__c = 'gestione.canali.salesforce@bancaifis.it');

	}

	@isTest
	private static void bifis_crm_T_MccNsaCommonCtrl_submitFinaleSTANDARD() {
			
		Test.startTest();

		Integer invocations = Limits.getEmailInvocations();

		WorkflowMutui__c workflowAttuale = [SELECT Id, Name, Stato__c, Tipologia_Mutuo__c, PartitaIVA__c FROM WorkflowMutui__c WHERE PartitaIva__c='99999999993' LIMIT 1];

		bifis_crm_c_MccNsaCommonCtrl.submitFinale(workflowAttuale.Id);

		if(invocations <> Limits.getEmailInvocations()){

			System.assertNotEquals(invocations,Limits.getEmailInvocations());
		
		} else {
		
			System.assertEquals(invocations,Limits.getEmailInvocations());
			 
		}

		Test.stopTest();
		
	}
    /*
	@isTest
	private static void bifis_crm_T_MccNsaCommonCtrl_submitFinaleSTANDARD_badNumCivico() {
			
		Test.startTest();

        Integer invocations = Limits.getEmailInvocations();
		WorkflowMutui__c workflowAttuale = [SELECT Id, Name, Stato__c, Tipologia_Mutuo__c, PartitaIVA__c FROM WorkflowMutui__c WHERE PartitaIva__c='99999999993' LIMIT 1];
            
		bifis_crm_c_MccNsaCommonCtrl.submitFinale(workflowAttuale.Id);
		if(invocations <> Limits.getEmailInvocations()){
			System.assertNotEquals(invocations,Limits.getEmailInvocations());
		} else {
			System.assertEquals(invocations,Limits.getEmailInvocations());
		}

		Test.stopTest();
	}    
*/
	@isTest
	private static void bifis_crm_T_MccNsaCommonCtrl_submitFinaleASSICURATIVO() {
			
		Test.startTest();

		Integer invocations = Limits.getEmailInvocations();

		WorkflowMutui__c workflowAttuale = [SELECT Id, Name, Stato__c, Tipologia_Mutuo__c, PartitaIVA__c FROM WorkflowMutui__c WHERE PartitaIva__c='99999999994' LIMIT 1];
																													 
		bifis_crm_c_MccNsaCommonCtrl.submitFinale(workflowAttuale.Id);

		if(invocations <> Limits.getEmailInvocations()){

			System.assertNotEquals(invocations,Limits.getEmailInvocations());
		
		} else {
		
			System.assertEquals(invocations,Limits.getEmailInvocations());
			 
		}

		Test.stopTest();
		
	}

	@isTest
	private static void bifis_crm_T_MccNsaCommonCtrl_controlliFinaliSTANDARD() {
			 
		WorkflowMutui__c workflowAttuale = [SELECT Id, Name, Stato__c, Tipologia_Mutuo__c, PartitaIVA__c FROM WorkflowMutui__c WHERE PartitaIva__c='99999999991' LIMIT 1];

		List<Object> result = bifis_crm_c_MccNsaCommonCtrl.controlliFinali(workflowAttuale.Id);

		System.assertEquals(10, result.size());

	}

	@isTest
	private static void bifis_crm_T_MccNsaCommonCtrl_controlliFinaliASSICURATIVO() {
			 
		WorkflowMutui__c workflowAttuale = [SELECT Id, Name, Stato__c, Tipologia_Mutuo__c, PartitaIVA__c FROM WorkflowMutui__c WHERE PartitaIva__c='99999999992' LIMIT 1];

		List<Object> result = bifis_crm_c_MccNsaCommonCtrl.controlliFinali(workflowAttuale.Id);

		System.assertEquals(10, result.size());

	}

	@isTest
	private static void bifis_crm_T_MccNsaCommonCtrl_attribuzioneQQ() {
			 
		WorkflowMutui__c workflowAttuale = [SELECT Id, Name, Stato__c, Tipologia_Mutuo__c, PartitaIVA__c FROM WorkflowMutui__c WHERE PartitaIva__c='99999999995' LIMIT 1];

		String result = bifis_crm_c_MccNsaCommonCtrl.attribuzioneQQ(workflowAttuale.Id);

		System.assertEquals('Small Business', result);

	}

	@isTest
	private static void bifis_crm_T_MccNsaCommonCtrl_classificazioneQQ() {
		Integer fatt = Integer.valueOf('552500');
        String res = bifis_crm_c_MccNsaCommonCtrl.classificazioneQQ(fatt);
        System.assertEquals('Small Business', res);
    }

}