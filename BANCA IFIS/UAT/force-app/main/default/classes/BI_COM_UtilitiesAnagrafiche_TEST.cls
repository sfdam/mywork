/**
* Progetto:         Revisione componenti core per CRM 2.0.
* Sviluppatore      Marco Bonin <marco.bonin@bancaifis.it>
* Descrizione:      Classe di test per BI_COM_UtilitiesAnagrafiche_CODE
*
*/

@isTest 
private class BI_COM_UtilitiesAnagrafiche_TEST {

  @testSetup
  public static void BI_COM_UtilitiesAnagrafiche_TEST_setupDati() {

	insert BI_COM_UtilitiesSupportoTest_CODE.getImpostazioniServizi();
    insert BI_COM_UtilitiesSupportoTest_CODE.getCustomSettingEndpointServizi();
	insert BI_COM_UtilitiesSupportoTest_CODE.getComuni();
	insert BI_COM_UtilitiesSupportoTest_CODE.getAccounts();
	insert BI_COM_UtilitiesSupportoTest_CODE.getLeads();

  }

	@isTest
	private static void BI_COM_UtilitiesAnagrafiche_TEST_getComuni() {
			
		Test.startTest();

		List<Comune__c> comuni = BI_COM_UtilitiesAnagrafiche_CODE.getComuni(false,'30175');

		System.assertEquals(1, comuni.size());
			 
		Test.stopTest();

	}

	@isTest
	private static void BI_COM_UtilitiesAnagrafiche_TEST_getNDGByPivaOverCRM() {
			
		Test.startTest();

		String ndg = BI_COM_UtilitiesAnagrafiche_CODE.getNDGByPivaOverCRM('07864443511','881');

		System.assertNotEquals(null, ndg);
			 
		Test.stopTest();

	}

	@isTest
	private static void BI_COM_UtilitiesAnagrafiche_TEST_getNDGByPivaOverCedacri() {
			
		Test.startTest();

		List<String> mockups = new List<String>();

		mockups.add(BI_COM_UtilitiesSupportoTest_CODE.MOCK_PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_PG);

		Test.setMock(HttpCalloutMock.class, BI_COM_MockResponseSupportoTest_CODE.creaMockRispostaOk(mockups));

		String ndg = BI_COM_UtilitiesAnagrafiche_CODE.getNDGByPivaOverCedacri('01732460264','881');

		System.assertNotEquals(null, ndg);
			 
		Test.stopTest();

	}

	@isTest
	private static void BI_COM_UtilitiesAnagrafiche_TEST_truncateNumeroCivicoForCedacri() {
			
		Test.startTest();

		Account actualAccount = [SELECT Id,Name,BillingStreetName__c FROM Account LIMIT 1];

		actualAccount.BillingStreetNumber__c = '1234567890';

		actualAccount = BI_COM_UtilitiesAnagrafiche_CODE.truncateNumeroCivicoForCedacri(actualAccount);

		System.assertEquals(6, actualAccount.BillingStreetNumber__c.length());
			 
		Test.stopTest();

	}

	@isTest
	private static void BI_COM_UtilitiesAnagrafiche_TEST_searchAccountOverAllSystems() {
			
		Test.startTest();

		List<String> mockups = new List<String>();

		mockups.add(BI_COM_UtilitiesSupportoTest_CODE.MOCK_PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_PG_KO);
		mockups.add(BI_COM_UtilitiesSupportoTest_CODE.MOCK_PAYLOAD_RIBES_GETLISTAAZIENDE); 

		Test.setMock(HttpCalloutMock.class, BI_COM_MockResponseSupportoTest_CODE.creaMockRispostaOk(mockups));
		
		Account actualAccount = BI_COM_UtilitiesAnagrafiche_CODE.searchAccountOverAllSystems('04361070289','');

		System.assertEquals(null, actualAccount);
			 
		Test.stopTest();

	}
	    
	@isTest
	private static void BI_COM_UtilitiesAnagrafiche_TEST_createNewContactFromLead() {
			
		Test.startTest();

		Account actualAccount = [SELECT Name, PIVA__c FROM Account LIMIT 1];
		Lead actualLead = [
		SELECT Name, PIVA__c, FirstName, LastName, Phone, MobilePhone, Email, State, PostalCode, Street, City, WGC_Tipo_Via__c, WGC_Codice_Fiscale__c, WGC_Sesso__c 
		FROM Lead 
		LIMIT 1];
		
		Contact actualContact = BI_COM_UtilitiesAnagrafiche_CODE.createNewContactFromLead(actualLead, actualAccount);

		System.assertNotEquals(null, actualContact);
			 
		Test.stopTest();

	}

	    
	@isTest
	private static void BI_COM_UtilitiesAnagrafiche_TEST_creaTaskSuAccount() {
			
		Test.startTest();

		Account actualAccount = [SELECT Id, Name, PIVA__c FROM Account LIMIT 1];
		WorkflowSegnalatori__c workflow = new WorkflowSegnalatori__c(AccountCollegato__c = actualAccount.Id, Ente_segnalante_descrizione__c = actualAccount.Name, PartitaIva__c = '99999999999', Ragione_Sociale__c = 'Unit Test', Stato__c = 'BOZZA_DATI', Ente_segnalante__c = '123', Tipologia_Segnalazione__c = 'MISTO', PRD_FACTORING_JSON__c = '{"fabbisognoFinanziarioFactoring": "500000", "naturaClientiFactoring": "PUBBLICI", "nazionalitaClientiFactoring": "ITALIANI", "noteFactoring": "mediazione 2%"}', TIMELINE_JSON__c = '[{"descrizione":"Creazione segnalazione da portale","momento":1611315309658,"decoratore":"DEFAULT","utenteOperazione":"Marco Nonni"},{"descrizione":"Invio segnalazione da portale","momento":1611323833165,"decoratore":"SENT", "utenteOperazione":"Marco Nonni"}', PRD_MUTUO_JSON__c = '{"importoMutuo": "400000", "durataAmmortamentoMutuo": "48", "durataPreammortamentoMutuo": "12", "finalitaMutuo": "LIQUIDITA", "noteMutuo": "mediazione 2%"}', REFERENTI_JSON__c = '[{"nome":"carlo","cognome":"berton","ruolo":"undefined","telefono":"23456789","mail":"ca@gmail.com"}]', DOCUMENTI_JSON__c = '[{"fileName":"external_light.pdf","fileType":"GENERICO","id":"06926000000sgiwAAA"}]');

		Task actualTask = BI_COM_UtilitiesAnagrafiche_CODE.creaTaskSuAccount(workflow, UserInfo.getUserId(),'Chiuso','Segnalazione esterna','Aperta opportunità', 'ContattoTelefonicoDiretto');

		System.assertNotEquals(null, actualTask);
			 
		Test.stopTest();

	}

	@isTest
	private static void BI_COM_UtilitiesAnagrafiche_TEST_calcolaSpecialistiAccount() {
			
		Test.startTest();

		Account actualAccount = [SELECT Id, Name, PIVA__c FROM Account LIMIT 1];

		BI_COM_UtilitiesAnagrafiche_CODE.Specialisti specialisti = BI_COM_UtilitiesAnagrafiche_CODE.calcolaSpecialistiAccount(actualAccount.id);

		System.assertNotEquals(null, specialisti);
			 
		Test.stopTest();

	}

}