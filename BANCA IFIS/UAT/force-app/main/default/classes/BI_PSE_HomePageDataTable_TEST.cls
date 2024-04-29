@isTest 
private class BI_PSE_HomePageDataTable_TEST {


	@testSetup static void BI_PSE_HomePageDataTable_setupDati() {

		List<WorkflowSegnalatori__c> testWorkflowSegnalatori = new List<WorkflowSegnalatori__c> ();

		// DATI DI TEST
		Account a = new Account(Name='TestAcc', BI_CodiceAccordo__c = '123');
		insert a;
		Contact c = new Contact(LastName='tastCont', AccountId = a.Id);
		insert c;
        Profile p = [SELECT Id FROM Profile WHERE Name='IFIS - Segnalatori']; 
        User u = new User(Email='TestIFIS@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS@testorg.com', Alias = '123', ContactId = c.Id);
        
        insert u;
		testWorkflowSegnalatori.add(new WorkflowSegnalatori__c(PartitaIva__c = '99999999999', Ragione_Sociale__c = 'Unit Test', Stato__c = 'BOZZA_DATI', Ente_segnalante__c = '123'));
		insert testWorkflowSegnalatori;

	}

	@isTest
	static void BI_PSE_HomePageDataTableFetchWorkflowsSegnalatoriHomePage() {
		List<User> users = [select id FROM User WHERE LastName = 'Testing'];
		System.runAs(users.get(0)){
			List < WorkflowSegnalatori__c > recordList = BI_PSE_HomePageDataTable_CTRL.fetchWorkflowsSegnalazioniForHomePage('99999999999');
			System.assertEquals(1, recordList.size());
		}
	}

	@isTest
	static void BI_PSE_HomePageDataTableDeleteWorkflowSegnalatoriForHomePage() {

	WorkflowSegnalatori__c workflowAttuale = [SELECT Id, Name, Stato__c FROM WorkflowSegnalatori__c WHERE PartitaIva__c='99999999999' LIMIT 1];

	Boolean result = BI_PSE_HomePageDataTable_CTRL.deleteWorkflowSegnalazioniForHomePage(workflowAttuale.Id);
	
	System.assertEquals(true, result);

	}

}