@isTest
public class BI_PSE_ControllerPrincipale_TEST {

	@testSetup
	static void BI_PSE_HomePageDataTable_setupDati() {
		
		Impostazioni__c i = new Impostazioni__c();
        i.Id_Covisian__c = '0054H000006mQupQAE';
		upsert i;
		Parametri_Segnalatori__c pse= new Parametri_Segnalatori__c();
		pse.Destinatari_CC__c = 'test@gmail.com';
		insert pse;
		insert BI_COM_UtilitiesSupportoTest_CODE.getImpostazioniServizi();
		insert BI_COM_UtilitiesSupportoTest_CODE.getCustomSettingEndpointServizi();

		List<WorkflowSegnalatori__c> testWorkflowSegnalatori = new List<WorkflowSegnalatori__c> ();
		
		// DATI DI TEST
		Account a = new Account(Name = 'TestAcc', BI_CodiceAccordo__c = '123');
		insert a;
		Account accountCollegato = new Account(Name = 'TestAcc', WGC_Qualifica_Corporate__c = 'Cliente incerto');
		insert accountCollegato;
		Contact c = new Contact(LastName = 'tastCont', AccountId = a.Id);
		insert c;
		Profile p = [SELECT Id FROM Profile WHERE Name = 'IFIS - Segnalatori'];
		User u = new User(Email = 'TestIFIS@testorg.com',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Los_Angeles', UserName = 'TestIFIS@testorg.com', Alias = '123', ContactId = c.Id);

		insert u;
		testWorkflowSegnalatori.add(new WorkflowSegnalatori__c(PartitaIva__c = '99999999999', Tipo_Segnalatore__c = 'Partner', Ragione_Sociale__c = 'Unit Test', Natura_Giuridica__c = 'DI', Stato__c = 'BOZZA_DATI', Ente_segnalante__c = '123', Ente_segnalante_descrizione__c = 'Desc123', Tipologia_Segnalazione__c = 'MISTO', Tipo_Segnalazione__c = 'FACTORING', PRD_FACTORING_JSON__c = '{"fabbisognoFinanziarioFactoring": "500000", "naturaClientiFactoring": "PUBBLICI", "nazionalitaClientiFactoring": "ITALIANI", "noteFactoring": "mediazione 2%"}', TIMELINE_JSON__c = '[{"descrizione":"Creazione segnalazione da portale","momento":1611315309658,"decoratore":"DEFAULT","utenteOperazione":"Marco Nonni"},{"descrizione":"Invio segnalazione da portale","momento":1611323833165,"decoratore":"SENT", "utenteOperazione":"Marco Nonni"}', PRD_MUTUO_JSON__c = '{"importoMutuo": "400000", "durataAmmortamentoMutuo": "48", "durataPreammortamentoMutuo": "12", "finalitaMutuo": "LIQUIDITA", "noteMutuo": "mediazione 2%"}', REFERENTI_JSON__c = '[{"nome":"carlo","cognome":"berton","ruolo":"CEO","telefono":"23456789","mail":"ca@gmail.com","codiceFiscale":"crlbrt85e09i459k"}]', DOCUMENTI_JSON__c = '[{"fileName":"external_light.pdf","fileType":"GENERICO","id":"06926000000sgiwAAA"}]'));
		testWorkflowSegnalatori.add(new WorkflowSegnalatori__c(PartitaIva__c = '88888888888', Tipo_Segnalatore__c = 'Partner', Ragione_Sociale__c = 'Unit Test Leasing Rental', AccountCollegato__c = accountCollegato.Id, Natura_Giuridica__c = 'DI', Stato__c = 'BOZZA_DATI', Ente_segnalante__c = '123', Ente_segnalante_descrizione__c = 'Desc123', Tipologia_Segnalazione__c = 'LEASINGRENTAL', Tipo_Segnalazione__c = 'LEASING', PRD_LEASING_JSON__c = '{"importoLeasing": "50000", "businessLeasing": "TSP", "noteLeasing": "note leasing"}', PRD_RENTAL_JSON__c = '{"importoRental": "100000", "businessRental": "AGR", "noteRental": "note rental"}', TIMELINE_JSON__c = '[{"descrizione":"Creazione segnalazione da portale","momento":1611315309658,"decoratore":"DEFAULT","utenteOperazione":"Marco Nonni"},{"descrizione":"Invio segnalazione da portale","momento":1611323833165,"decoratore":"SENT", "utenteOperazione":"Marco Nonni"}', REFERENTI_JSON__c = '[{"nome":"carlo","cognome":"berton","ruolo":"CEO","telefono":"23456789","mail":"ca@gmail.com","codiceFiscale":"crlbrt85e09i459k"}]', DOCUMENTI_JSON__c = '[{"fileName":"external_light.pdf","fileType":"GENERICO","id":"06926000000sgiwAAA"}]'));
		insert testWorkflowSegnalatori;
		Opportunity o = new Opportunity(Name = 'NomeOpp', BI_WorkflowSegnalatori__c = testWorkflowSegnalatori[0].Id, CloseDate = Date.today());
		insert o;
	}

	@isTest
	static void testDatiUtenteLoggato() {
		List<User> users = [select id FROM User WHERE LastName = 'Testing'];
		System.runAs(users.get(0)) {
			User recordList = BI_PSE_ControllerPrincipale_CTRL.datiUtenteLoggato();
			System.assertEquals(users[0].Id, recordList.Id);
		}
	}

	@isTest
	static void testEsitoPrevalutazioneSegnalazione() {
		WorkflowSegnalatori__c workflowRecord = [select Id, OwnerId, Name, CreatedDate, ATECO__c, AccountCollegato__c, CapLegale__c, CittaLegale__c, CivicoLegale__c, CognomeReferente__c, DOCUMENTI_JSON__c, DataInvioIfis__c, EmailReferente__c, ErroriTecnici__c, IndirizzoLegale__c, MotivazioneRifiutoPrevalutazione__c, Natura_Giuridica__c, NomeReferente__c, OpportunitaCollegata__c, PRD_FACTORING_JSON__c, PRD_MUTUO_JSON__c, PartitaIVA__c, ProvinciaCCIAA__c, ProvinciaLegale__c, RAE__c, REA__c, REFERENTI_JSON__c, Ragione_Sociale__c, SAE__c, Stato__c, TIMELINE_JSON__c, TelefonoReferente__c, TipoViaLegale__c, Tipologia_Segnalazione__c, Tipo_Segnalazione__c, Tipo_Segnalatore__c, Ente_segnalante__c, CommentoEsito__c, Ente_segnalante_descrizione__c FROM WorkflowSegnalatori__c where PartitaIVA__c = '99999999999'];
		BI_PSE_ControllerPrincipale_CTRL.RisultatoPrevalutazione prevalutazione = BI_PSE_ControllerPrincipale_CTRL.esitoPrevalutazioneSegnalazione(workflowRecord, 'esitoLivello', 'PREVALUTAZIONE_OK', 'Prevalutazione esitata positivamente');
	}

	@isTest
	static void testCompletaPrevalutazioneSegnalazione() {
		WorkflowSegnalatori__c workflowRecord = [select Id, OwnerId, Name, CreatedDate, ATECO__c, AccountCollegato__c, CapLegale__c, CittaLegale__c, CivicoLegale__c, CognomeReferente__c, DOCUMENTI_JSON__c, DataInvioIfis__c, EmailReferente__c, ErroriTecnici__c, IndirizzoLegale__c, MotivazioneRifiutoPrevalutazione__c, Natura_Giuridica__c, NomeReferente__c, OpportunitaCollegata__c, PRD_FACTORING_JSON__c, PRD_MUTUO_JSON__c, PartitaIVA__c, ProvinciaCCIAA__c, ProvinciaLegale__c, RAE__c, REA__c, REFERENTI_JSON__c, Ragione_Sociale__c, SAE__c, Stato__c, TIMELINE_JSON__c, TelefonoReferente__c, TipoViaLegale__c, Tipologia_Segnalazione__c, Tipo_Segnalazione__c, Tipo_Segnalatore__c, Ente_segnalante__c, CommentoEsito__c, Ente_segnalante_descrizione__c FROM WorkflowSegnalatori__c where PartitaIVA__c = '99999999999'];
		Opportunity opp = [select id FROM Opportunity WHERE Name = 'NomeOpp'];
		List<User> users = [select id FROM User WHERE LastName = 'Testing'];
		System.runAs(users.get(0)) {
			BI_PSE_ControllerPrincipale_CTRL.RisultatoPrevalutazione prevalutazione = BI_PSE_ControllerPrincipale_CTRL.completaPrevalutazioneSegnalazione(workflowRecord, opp.Id);
		}
	}

	@isTest
	static void testCompletaPrevalutazioneSegnalazioneLeasing() {
		WorkflowSegnalatori__c workflowRecord = [select Id, OwnerId, Name, CreatedDate, ATECO__c, AccountCollegato__c, AccountCollegato__r.Name, AccountCollegato__r.WGC_Qualifica_Corporate__c, CapLegale__c, CittaLegale__c, CivicoLegale__c, CognomeReferente__c, DOCUMENTI_JSON__c, DataInvioIfis__c, EmailReferente__c, ErroriTecnici__c, IndirizzoLegale__c, MotivazioneRifiutoPrevalutazione__c, Natura_Giuridica__c, NomeReferente__c, OpportunitaCollegata__c, PRD_LEASING_JSON__c, PRD_RENTAL_JSON__c, PartitaIVA__c, ProvinciaCCIAA__c, ProvinciaLegale__c, RAE__c, REA__c, REFERENTI_JSON__c, Ragione_Sociale__c, SAE__c, Stato__c, TIMELINE_JSON__c, TelefonoReferente__c, TipoViaLegale__c, Tipologia_Segnalazione__c, Tipo_Segnalazione__c, Tipo_Segnalatore__c, Ente_segnalante__c, CommentoEsito__c, Ente_segnalante_descrizione__c FROM WorkflowSegnalatori__c where PartitaIVA__c = '88888888888'];
		//List<User> users = [select id FROM User WHERE LastName = 'Testing'];
		//System.runAs(users.get(0)) {
			BI_PSE_ControllerPrincipale_CTRL.RisultatoPrevalutazione prevalutazione = BI_PSE_ControllerPrincipale_CTRL.completaPrevalutazioneSegnalazione(workflowRecord, '');
		//}
	}

	@isTest
	static void testIntegraDatiMancanti() {
		Contact c = [select Id, Ruolo__c,FirstName,LastName,Birthdate,LuogoNascita__c,PaeseNascita__c,Sesso__c,CF__c,SAE__c,TAECode__c,Email,TipoDocumentoId__c,NumeroDoc__c,DataEmissioneDoc__c,DataScadenzaDoc__c,LuogoEmissioneDoc__c FROM Contact WHERE LastName = 'tastCont'];
		String referenti = '[{"nome":"STEFANIA","cognome":"MARCOLONGO","ruolo":"Titolare","telefono":"3234567897","mail":"m@gmsil.com","dataNascita":"1985-03-08","luogoNascita":"sassocorvaro","nazioneNascita":"italia","sesso":"M","codiceFiscale":"nnnmrc85c08i459k","sae":"600","tae":"984","tipoDocumento":"CI","numeroDocumento":"12345","luogoEmissioneDocumento":"rubano","dataEmissioneDocumento":"2020-08-03","dataScadenzaDocumento":"2030-03-08"}]';
		BI_PSE_ControllerPrincipale_CTRL.integraDatiMancanti(c, referenti);
	}

	@isTest
	static void testControlliFinali() {
		WorkflowSegnalatori__c workflowRecord = [select Id, OwnerId, Name, CreatedDate, ATECO__c, AccountCollegato__c, CapLegale__c, CittaLegale__c, CivicoLegale__c, CognomeReferente__c, DOCUMENTI_JSON__c, DataInvioIfis__c, EmailReferente__c, ErroriTecnici__c, IndirizzoLegale__c, MotivazioneRifiutoPrevalutazione__c, Natura_Giuridica__c, NomeReferente__c, OpportunitaCollegata__c, PRD_FACTORING_JSON__c, PRD_MUTUO_JSON__c, PartitaIVA__c, ProvinciaCCIAA__c, ProvinciaLegale__c, RAE__c, REA__c, REFERENTI_JSON__c, Ragione_Sociale__c, SAE__c, Stato__c, TIMELINE_JSON__c, TelefonoReferente__c, TipoViaLegale__c, Tipologia_Segnalazione__c, Ente_segnalante__c, CommentoEsito__c, Ente_segnalante_descrizione__c FROM WorkflowSegnalatori__c where PartitaIVA__c = '99999999999'];
		BI_PSE_ControllerPrincipale_CTRL.controlliFinali(workflowRecord.Id);
		WorkflowSegnalatori__c workflowRecordLeasing = [select Id, OwnerId, Name, CreatedDate, ATECO__c, AccountCollegato__c, CapLegale__c, CittaLegale__c, CivicoLegale__c, CognomeReferente__c, DOCUMENTI_JSON__c, DataInvioIfis__c, EmailReferente__c, ErroriTecnici__c, IndirizzoLegale__c, MotivazioneRifiutoPrevalutazione__c, Natura_Giuridica__c, NomeReferente__c, OpportunitaCollegata__c, PRD_LEASING_JSON__c, PRD_RENTAL_JSON__c, PartitaIVA__c, ProvinciaCCIAA__c, ProvinciaLegale__c, RAE__c, REA__c, REFERENTI_JSON__c, Ragione_Sociale__c, SAE__c, Stato__c, TIMELINE_JSON__c, TelefonoReferente__c, TipoViaLegale__c, Tipologia_Segnalazione__c, Ente_segnalante__c, CommentoEsito__c, Ente_segnalante_descrizione__c FROM WorkflowSegnalatori__c where PartitaIVA__c = '88888888888'];
		BI_PSE_ControllerPrincipale_CTRL.controlliFinali(workflowRecordLeasing.Id);
	}

	@isTest
	static void testRicaricaRecord() {
		WorkflowSegnalatori__c workflowRecord = [select Id, OwnerId, Name, CreatedDate, ATECO__c, AccountCollegato__c, CapLegale__c, CittaLegale__c, CivicoLegale__c, CognomeReferente__c, DOCUMENTI_JSON__c, DataInvioIfis__c, EmailReferente__c, ErroriTecnici__c, IndirizzoLegale__c, MotivazioneRifiutoPrevalutazione__c, Natura_Giuridica__c, NomeReferente__c, OpportunitaCollegata__c, PRD_FACTORING_JSON__c, PRD_MUTUO_JSON__c, PartitaIVA__c, ProvinciaCCIAA__c, ProvinciaLegale__c, RAE__c, REA__c, REFERENTI_JSON__c, Ragione_Sociale__c, SAE__c, Stato__c, TIMELINE_JSON__c, TelefonoReferente__c, TipoViaLegale__c, Tipologia_Segnalazione__c, Ente_segnalante__c, CommentoEsito__c, Ente_segnalante_descrizione__c FROM WorkflowSegnalatori__c where PartitaIVA__c = '99999999999'];
		BI_PSE_ControllerPrincipale_CTRL.ricaricaRecord(workflowRecord.Id);
	}

	@isTest
	static void ricercaEnteSegnalante() {
		List<User> users = [select id FROM User WHERE LastName = 'Testing'];
		System.runAs(users.get(0)) {
			BI_PSE_ControllerPrincipale_CTRL.RisultatoPrevalutazione prevalutazione = BI_PSE_ControllerPrincipale_CTRL.ricercaEnteSegnalante((String)users[0].Id);
		}
	}

	@isTest
	static void testInvioPratica() {
		WorkflowSegnalatori__c workflowRecord = [select Id, OwnerId, Name, CreatedDate, ATECO__c, AccountCollegato__c, CapLegale__c, CittaLegale__c, CivicoLegale__c, CognomeReferente__c, DOCUMENTI_JSON__c, DataInvioIfis__c, EmailReferente__c, ErroriTecnici__c, IndirizzoLegale__c, MotivazioneRifiutoPrevalutazione__c, Natura_Giuridica__c, NomeReferente__c, OpportunitaCollegata__c, PRD_FACTORING_JSON__c, PRD_MUTUO_JSON__c, PartitaIVA__c, ProvinciaCCIAA__c, ProvinciaLegale__c, RAE__c, REA__c, REFERENTI_JSON__c, Ragione_Sociale__c, SAE__c, Stato__c, TIMELINE_JSON__c, TelefonoReferente__c, TipoViaLegale__c, Tipologia_Segnalazione__c, Ente_segnalante__c, CommentoEsito__c, Ente_segnalante_descrizione__c FROM WorkflowSegnalatori__c where PartitaIVA__c = '99999999999'];
		BI_PSE_ControllerPrincipale_CTRL.invioPratica(workflowRecord.Id);
	}
	
	@isTest
	static void testCensimentoAccount() {
		WorkflowSegnalatori__c workflowRecord = [select Id, OwnerId, Name, CreatedDate, ATECO__c, AccountCollegato__c, CapLegale__c, CittaLegale__c, CivicoLegale__c, CognomeReferente__c, DOCUMENTI_JSON__c, DataInvioIfis__c, EmailReferente__c, ErroriTecnici__c, IndirizzoLegale__c, MotivazioneRifiutoPrevalutazione__c, Natura_Giuridica__c, NomeReferente__c, OpportunitaCollegata__c, PRD_FACTORING_JSON__c, PRD_MUTUO_JSON__c, PartitaIVA__c, ProvinciaCCIAA__c, ProvinciaLegale__c, RAE__c, REA__c, REFERENTI_JSON__c, Ragione_Sociale__c, SAE__c, Stato__c, TIMELINE_JSON__c, TelefonoReferente__c, TipoViaLegale__c, Tipologia_Segnalazione__c, Ente_segnalante__c, CommentoEsito__c, Ente_segnalante_descrizione__c FROM WorkflowSegnalatori__c where PartitaIVA__c = '99999999999'];
		BI_PSE_ControllerPrincipale_CTRL.censimentoAccount(workflowRecord);
	}

	@isTest
	static void testRicercaProfiliAbilitati() {
		Boolean abilitazione = BI_PSE_ControllerPrincipale_CTRL.ricercaProfiliAbilitati('');
	}
}