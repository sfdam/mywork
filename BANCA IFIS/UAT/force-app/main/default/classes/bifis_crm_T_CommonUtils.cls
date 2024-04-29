@isTest
class bifis_crm_T_CommonUtils {
	static User userCommerciale;
	static String profileName = 'IFIS - Sviluppo Commerciale Filiali';

	static void bifis_crm_T_CommonUtils_setupUserCommerciale() {
			Id profiloCommerciale = [
			SELECT Id 
			FROM Profile 
			WHERE name = :profileName
			LIMIT 1].Id;
		userCommerciale = new User(Alias = 'User3', 
			Email='UserThree@testorg.com', 
			EmailEncodingKey='UTF-8', 
			Username = 'UserThree@testorg.com', 
			LastName = 'UserThree', 
			ProfileId = profiloCommerciale, 
			Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali', 
			WGC_Canale_di_sviluppo__c = 'Rete Commerciale Ifis Impresa',
			LanguageLocaleKey='en_US', 
			LocaleSidKey='en_US', 
			TimeZoneSidKey='America/Los_Angeles'
		);
	}

	static void bifis_crm_T_CommonUtils_setupDati() {
		bifis_crm_T_CommonUtils_setupUserCommerciale();
		// DATI DI TEST
		User babeto = TestUtils.creaUtente('babeto');
		System.runAs(userCommerciale) {
            Account acc = TestUtils.creaAccount('Account TEST', babeto, 'MI', '02119590046', 'rsscld50r15h501y', 'Prospect', '4321');
    
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Content4TestTitle';
            cv.Description = 'Content4TestDescription';
            cv.PathOnClient='/' + cv.Title + '.jpg'; 
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            cv.VersionData=bodyBlob; 
    
            insert cv;

			system.debug('---> user per setupDati: '+UserInfo.getUserName());
			Opportunity opp = TestUtils.CreaOpportunity(acc);
		}
	}

	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_normalizeAccountValues() {

	Test.startTest();

        Account a = new Account(Name='acme spa', PIVA__c='03421400965'); //real p.iva

		bifis_crm_c_CommonUtils.normalizeAccountValues(a);

	Test.stopTest();

	}

	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_CheckPartitaIvaOKCRM() {
        bifis_crm_T_CommonUtils.bifis_crm_T_CommonUtils_setupUserCommerciale();
		//TestUtils.creaAccount('ACME S.P.A.', 'PD', '02119590046', '02119590046');

		System.runAs(userCommerciale) {
            system.debug('---> user: '+UserInfo.getUserName());
			List<Object> result = bifis_crm_c_CommonUtils.checkPartitaIva('02119590046');
		}
	}

	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_CheckPartitaIvaOKCEDACRI() {
	    bifis_crm_T_CommonUtils.bifis_crm_T_CommonUtils_setupUserCommerciale();
		System.runAs(userCommerciale) {
			// PIVA DI MOCKUP
			List<String> mockups = new List<String>();

			mockups.add(bifis_crm_u_MockResponse4Test.PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_PG_PA);
			mockups.add(bifis_crm_u_MockResponse4Test.PAYLOAD_GET_DATI_ANAGRAFICI_CEDACRI_PG_PA);

			Test.setMock(HttpCalloutMock.class, bifis_crm_u_MockResponse4Test.creaMockRispostaOk(mockups));

			Test.startTest();
			System.runAs(userCommerciale) {
				List<Object> result = bifis_crm_c_CommonUtils.checkPartitaIva('00339370272');
			}
			Test.stopTest();
		}
	}

	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_CheckPartitaIvaOKRIBES() {
        bifis_crm_T_CommonUtils.bifis_crm_T_CommonUtils_setupUserCommerciale();
		System.runAs(userCommerciale) {
			// PIVA DI MOCKUP
			List<String> mockups = new List<String>();

			mockups.add(bifis_crm_u_MockResponse4Test.PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_PG_KO);
			mockups.add(bifis_crm_u_MockResponse4Test.PAYLOAD_RICERCA_ANAGRAFICA_RIBES_PG);

			Test.setMock(HttpCalloutMock.class, bifis_crm_u_MockResponse4Test.creaMockRispostaOk(mockups));

			Test.startTest();
			System.runAs(userCommerciale) {
				List<Object> result = bifis_crm_c_CommonUtils.checkPartitaIva('01732460264');
			}
			Test.stopTest();
		}
	}
	
	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_CheckPartitaIvaKO() {
        bifis_crm_T_CommonUtils.bifis_crm_T_CommonUtils_setupUserCommerciale();
		System.runAs(userCommerciale) {
			List<Object> result = bifis_crm_c_CommonUtils.checkPartitaIva('ABC');
			//System.assertEquals('KO', result[0]);
        }
	}

	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_CheckPartitaIvaKO2() {
		bifis_crm_T_CommonUtils.bifis_crm_T_CommonUtils_setupUserCommerciale();
		System.runAs(userCommerciale) {
			List<String> mockups = new List<String>();

			mockups.add(bifis_crm_u_MockResponse4Test.PAYLOAD_RICERCA_ANAGRAFICA_CEDACRI_PG_KO);

			Test.setMock(HttpCalloutMock.class, bifis_crm_u_MockResponse4Test.creaMockRispostaOk(mockups));

			Test.startTest();
			System.runAs(userCommerciale) {	
				List<Object> result = bifis_crm_c_CommonUtils.checkPartitaIva('11111111111');
				//System.assertEquals('KO', result[0]);
			}
			Test.stopTest();
		}
	}

	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_CheckPartitaIvaKOFormale() {
        bifis_crm_T_CommonUtils.bifis_crm_T_CommonUtils_setupUserCommerciale();
		System.runAs(userCommerciale) {
			List<Object> result = bifis_crm_c_CommonUtils.checkPartitaIva('AAA');
			//System.assertEquals('KO', result[0]);
        }
	}

	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_SentMailToTheSubmitterOK() {
        bifis_crm_T_CommonUtils.bifis_crm_T_CommonUtils_setupUserCommerciale();

		System.runAs(userCommerciale) {
			Test.startTest();

			Integer invocations = Limits.getEmailInvocations();

			OrgWideEmailAddress owa = [SELECT id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'Portale Pratiche SGA' OR DisplayName = 'Portale Pratiche MCC NSA' limit 1];

			WorkflowMutui__c w = new WorkflowMutui__c();
			w.Ragione_Sociale__c='';
			w.PartitaIVA__c='';
			bifis_crm_c_CommonUtils.sentMailToTheSubmitter(
				owa.Id, 
				'gestione.canali.salesforce@bancaifis.it', 
				'GCS', 
				w.Ragione_Sociale__c, 
				w.PartitaIVA__c,
				w.Id,
				'TIPO_WORKFLOW');

			//System.assertNotEquals(invocations,Limits.getEmailInvocations());

			Test.stopTest();
		}
	}

	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_parseReferentiJSON() {

		String inputJSON = '[{"nome":"BABETO","cognome":"PIAZZA","codiceFiscale":"BBTPZZXXXXXXXXXX"},{"nome":"FRANCA","cognome":"VALERI","codiceFiscale":"FRAVALXXXXXXXXXX"}]';
		List<Object> result = bifis_crm_c_CommonUtils.parseReferentiJSON(inputJSON);
		//System.assertEquals(2, result.size());

		inputJSON = '';
		result = bifis_crm_c_CommonUtils.parseReferentiJSON(inputJSON);
		//System.assertEquals(null, result);

		inputJSON = '****';
		result = bifis_crm_c_CommonUtils.parseReferentiJSON(inputJSON);
		//System.assertEquals(null, result);

		inputJSON = '[{"fileHappy":"}]';
		result = bifis_crm_c_CommonUtils.parseReferentiJSON(inputJSON);
		//System.assertEquals(null, result);

	}

	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_parseProdottoJSON() {

		String inputJSON = '{"importoMutuo":"123","durataAmmortamentoMutuo":"","durataPreammortamentoMutuo":"","finalitaMutuo":"","noteMutuo":""}';
		Map<String, Object> result = bifis_crm_c_CommonUtils.parseProdottoJSON(inputJSON);
		//System.assertEquals(2, result.size());

		inputJSON = '';
		result = bifis_crm_c_CommonUtils.parseProdottoJSON(inputJSON);
		//System.assertEquals(null, result);

		inputJSON = '****';
		result = bifis_crm_c_CommonUtils.parseProdottoJSON(inputJSON);
		//System.assertEquals(null, result);

		inputJSON = '[{"fileHappy":"}]';
		result = bifis_crm_c_CommonUtils.parseProdottoJSON(inputJSON);
		//System.assertEquals(null, result);

	}

	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_createTaskForDigitalContact() {

		Lead actualLead = BI_COM_UtilitiesSupportoTest_CODE.getLead_FormWeb();
		Account actualAccount = BI_COM_UtilitiesSupportoTest_CODE.getAccounts().get(0);
		Contact actualContact = BI_COM_UtilitiesSupportoTest_CODE.getContacts().get(0);

		String ID_CAMPAGNA_WEB = Impostazioni__c.getInstance().IdCampagnaWeb__c;

		CampaignMember cmTarget = new CampaignMember(ContactId = actualContact.Id, CampaignId = ID_CAMPAGNA_WEB, Status = 'Target');
		String esito_liv1 = 'Individuata opportunità';
		bifis_crm_c_CommonUtils.createTaskForDigitalContact(cmTarget,actualAccount,actualLead,false, esito_liv1);

	}

	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_parseDocumentJSON() {

		String inputJSON = '[{"fileName":"PIANO DI RIENTRO.pdf","id":"0691l0000004bgjAAA"},{"fileName":"MANDATO SGA.pdf","id":"0691l0000004bgoAAA"}]';
		List<Object> result = bifis_crm_c_CommonUtils.parseDocumentJSON(inputJSON);
		//System.assertEquals(2, result.size());

		inputJSON = '';
		result = bifis_crm_c_CommonUtils.parseDocumentJSON(inputJSON);
		//System.assertEquals(null, result);
		inputJSON = '****';

		result = bifis_crm_c_CommonUtils.parseDocumentJSON(inputJSON);
		//System.assertEquals(null, result);

		inputJSON = '[{"fileHappy":"}]';
		result = bifis_crm_c_CommonUtils.parseDocumentJSON(inputJSON);
		//System.assertEquals(null, result);
	}
	/*
	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_pairFileToOpportunityEmpty() {
		Boolean pairingResult = bifis_crm_c_CommonUtils.pairFileToOpportunity('a021l0000018Ao4AAE','a021l0000018Ao3AAE','','');
		//System.assertEquals(false, pairingResult);
	}

	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_pairFileToOpportunityNoOpp() {
		Boolean pairingResult = bifis_crm_c_CommonUtils.pairFileToOpportunity('a021l0000018Ao4AAE','a021l0000018Ao3AAE','Garanzie','DM10');
		//System.assertEquals(false, pairingResult);
	}

	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_pairFileToOpportunity() {
	
		ContentVersion cv = [SELECT id,ContentDocumentId FROM ContentVersion WHERE Description = 'Content4TestDescription' LIMIT 1];

		String documentId = cv.ContentDocumentId;

		Opportunity opp = [SELECT id from Opportunity LIMIT 1];


		String jsonInput = '[{"fileName":"PIANO DI RIENTRO.pdf","id":"' + documentId + '"}]';

		List<Object> result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);

		for (Object current : result) {

			Map<String, Object> entry = (Map<String, Object>) current;

			String filename =  (String) entry.get('fileName');
			String fileid = (String) entry.get('id');

			Boolean pairingResult = bifis_crm_c_CommonUtils.pairFileToOpportunity(opp.Id,fileid,'Documenti identità','Civilistico');

			//System.assertEquals(true, pairingResult);

		}
	
	}
	*/ //method deprecated no need to test
    
	@isTest
	static void bifis_crm_T_CommonUtils_logError() {
        bifis_crm_T_CommonUtils.bifis_crm_T_CommonUtils_setupUserCommerciale();
		System.runAs(userCommerciale) {		
            Date bd = Date.newInstance(1982, 4, 4);
            Contact c = new Contact(CF__c='RBBLCU82D44G565U', FirstName='Lucia', LastName='Ribba', Birthdate=bd, Sesso__c='F', 
                                    LuogoNascita__c='PIANIGA', ProvinciaNascita__c='VE', PaeseNascita__c = 'it', CodCatastaleLocNascita__c='G565');
            upsert c;
            Exception e = new bifis_crm_c_MccNsaException('test exception');
            Account a = new Account(Name='acme spa', PIVA__c='03421400965'); //real p.iva
            upsert a;
            
			WorkflowMutui__c w = new WorkflowMutui__c(PartitaIVA__c='01234567899');
			bifis_crm_c_CommonUtils.logError(a, c, w, e);
			bifis_crm_c_CommonUtils.logError(a.Id, c.Id, w, e.getMessage());
        }
	}

	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_createFromNSAObjAcc() {
		WorkflowMutui__c w = new WorkflowMutui__c();
		  w.Ragione_Sociale__c = 'acme spa';
		  w.PartitaIVA__c = '03421400965';
		  w.ProvinciaSpedizione__c = 'PD';
		  w.CapSpedizione__c = '35100';
		  w.CittaSpedizione__c = 'PADOVA';
		  w.IndirizzoSpedizione__c = 'Gozzi';
		  w.CivicoSpedizione__c = '24';
		  w.TipoViaSpedizione__c = 'VIA';
		  w.ProvinciaLegale__c = 'PD';
		  w.CapLegale__c = '35100';
		  w.CittaLegale__c = 'PADOVA';
		  w.IndirizzoLegale__c = 'Gozzi';
		  w.CivicoLegale__c = '24';
		  w.TipoViaLegale__c = 'VIA';
		  w.Telefono__c = '555-121232';
		  w.Email__c = 'info@example.com';
		  w.EmailPEC__c = 'pec@example.com';
		  w.Fax__c = '555-121232';
		  w.SAE__c = '430';
		  w.RAE__c = '515';
		  w.Ateco__c = '55.10.1';
		bifis_crm_c_CommonUtils.createFromNSAObj(w);
	}

	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_searchByCodFiscBAD() {
		Contact c = bifis_crm_c_CommonUtils.searchByCodFisc('aaabbb99x99x123x');
		//System.assertEquals(null, c);
	}

	@isTest
	static void bifis_crm_T_CommonUtils_searchByCodFiscGOOD() {
        bifis_crm_T_CommonUtils.bifis_crm_T_CommonUtils_setupUserCommerciale();
		System.runAs(userCommerciale) {		
            Date bd = Date.newInstance(1982, 4, 4);
            Contact c = new Contact(CF__c='RBBLCU82D44G565U', FirstName='Lucia', LastName='Ribba', Birthdate=bd, Sesso__c='F', 
                                    LuogoNascita__c='PIANIGA', ProvinciaNascita__c='VE', PaeseNascita__c = 'it', CodCatastaleLocNascita__c='G565');
            upsert c;
    
            Contact found = bifis_crm_c_CommonUtils.searchByCodFisc('RBBLCU82D44G565U');
            //System.assertNotEquals(null, found);
        }
	}

	@isTest
	static void bifis_crm_T_CommonUtils_getDomandeQQ_SB() {
		bifis_crm_c_CommonUtils.getDomandeQQ('Small Business');
	}

	@isTest
	static void bifis_crm_T_CommonUtils_getDomandeQQ_NOT_SB() {
		bifis_crm_c_CommonUtils.getDomandeQQ('Corporate');
	}	

	@isTest
	static void bifis_crm_T_CommonUtils_createFromNSAObj() {
		bifis_crm_T_CommonUtils.bifis_crm_T_CommonUtils_setupUserCommerciale();
		System.runAs(userCommerciale) {
            Test.startTest();
            String inputJSON = '[{"nome":"BABETO","cognome":"PIAZZA","codiceFiscale":"PZZBTT65E05G224T","ruolo":"Titolare effettivo ed esecutore","tipologiaTE":"Proprietà diretta"},{"nome":"FRANCA","cognome":"VALERI","codiceFiscale":"VLRFNC65E45G224U","ruolo":"Titolare effettivo","tipologiaTE":"Proprietà diretta"}]';
            List<Object> referenti = bifis_crm_c_CommonUtils.parseReferentiJSON(inputJSON);
            Comune__c com = new Comune__c(Name='PADOVA', Provincia__c='PD', CodiceCatastale__c='G224');
            upsert com;
            Account a = new Account(Name='acme spa', PIVA__c='03474030289'); //real p.iva
            upsert a;
            Account b = new Account(Name='emca srl', PIVA__c='01426240485'); //real p.iva
            upsert b;
            //inserisco nuovo contatto c correlato ad account b così il test del metodo entra nel ramo di nuova relazione da creare con account a
            Contact c = new Contact(CF__c='PZZBTT65E05G224T', FirstName='BABETO', LastName='PIAZZA', AccountId=b.Id); //valid c.f.
            upsert c;
            
            bifis_crm_c_CommonUtils.createFromNSAObj(referenti, a.Id);
            Test.stopTest();
        }
	}

	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_UpdateRole() {
		String accountId = '';
		String contactId = '';
		List<String> rolesList = new List<String>();
		bifis_crm_c_CommonUtils.runUpdateRole(accountId, contactId, rolesList);
	}

/* TODO capire come mockare le call out per questi 2 metodi
	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_runQQ_BAD() {
		WsAnagrafe.ModificaDatiAggiuntiviQQInput input = new WsAnagrafe.ModificaDatiAggiuntiviQQInput();
		input.ndg = Long.valueOf('2557');
		String payload = JSON.serialize(input);
		bifis_crm_c_CommonUtils.runQQ(payload);
	}


	@isTest(SeeAllData=true)
	static void bifis_crm_T_CommonUtils_searchByPIVA_GOOD() {
		Account a = new Account(Name='acme spa', PIVA__c='01234567899');
		insert a;		
		Account found = bifis_crm_c_CommonUtils.searchByPIVA('01234567899');
		System.assertNotEquals(null, found);
	}
*/

}