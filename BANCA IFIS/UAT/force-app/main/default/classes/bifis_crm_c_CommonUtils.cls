public with sharing class bifis_crm_c_CommonUtils {
    
	public static String LOG_PREFIX = 'bifis_crm_log ';

    public static String OK = 'OK';
    public static String KO = 'KO';
    
    public static String BACKEND_SALESFORCE = 'SFDC';
    public static String BACKEND_CEDACRI = 'ANDG';
    public static String BACKEND_CERVED = 'CERVED';
    
    public static String MSG_ERR01 = 'Ragione Sociale già presente a sistema e non utilizzabile (CRM).';
    public static String MSG_ERR02 = 'Ragione Sociale già presente a sistema e non utilizzabile (CEDACRI).';
    public static String MSG_ERR03 = 'Nessuna corrispondenza trovata per il valore di ricerca inserito.';
    public static String MSG_ERR04 = 'La ricerca ha ritornato piu di una anagrafica.';

    public static String SGA_ERROR_HEADER = 'ERRORE - PORTALE SGA: ';

	public static final String CI3N_FACTORING = '881';
	public static final String CI3N_POLONIA = '889';
	public static final String ASSICURATIVO = 'ASSICURATIVO';
	public static final String STANDARD = 'STANDARD';
	public static final String MISTO = 'MISTO';
    
	//A.M. DIGITAL LEASING -> Modifica Firma del metodo per passare l'esito livello 1
	//public static Task createTaskForDigitalContact(CampaignMember cm, Account account, Lead lead, Boolean fromLead){
	public static Task createTaskForDigitalContact(CampaignMember cm, Account account, Lead lead, Boolean fromLead, String esito1){
	
		User user =[select id FROM user WHERE Username like 'nextSelfService@bancaifis.it%' LIMIT 1];

		if(user != null){
			String orignator; 
			String originatorDettaglio; 

			//A.M. DIGITAL LEASING Gestione dell'Originato Specifico
			if (lead.IFISForm__c == '24'){
				orignator = 'Web';
				originatorDettaglio = 'Digital Leasing';
			} else {
				orignator = account.WGC_Originator__c;
				originatorDettaglio = account.WGC_Originator_dettaglio__c;
			}
				
			Task t = new Task(
								WhoId = cm.ContactId,
								WhatId = account.Id,
								Canale__c = 'Campagna Filo Diretto',
								OwnerId = user.Id,
								Status = 'Chiuso',
								Subject = 'Contatto da canale digitale',
								ActivityDate = Date.today(),
								Campagna__c = cm.CampaignId,
								RecordTypeId = U.getRecordTypes('Task').get('ContattoTelefonicoDiretto').Id,
								Data_Inizio__c = System.now(),
								Data_Fine__c = System.now(),
								MembroCampagna__c = cm.Id,
										  
								// ORIGINATORS CALCOLATI IN BASE CHE IL LEAD SIA CAMPAGNA O FORM
								//A.M. DIGITAL LEASING -> Gestione Originator differenziato
								//Originator__c = account.WGC_Originator__c,
								//Originator_di_dettaglio__c = account.WGC_Originator_dettaglio__c,
								Originator__c = orignator,
								Originator_di_dettaglio__c = originatorDettaglio,

								WGC_IsCreatedFromLead__c = fromLead

			);


			// EVENTUALE "TRAVASO" DI DATI NEL TASK, DATI PROVENIENTI DAL LEAD ORIGINARIO
			//A.M. DIGITAL LEASING -> Gestione dell'esito recuperato dall'input
			//t.EsitoLivello1__c = 'Individuata Opportunità';
			t.EsitoLivello1__c = esito1;
			t.CommentiEsito__c = 'Il task è stato esitato automaticamente come evidenza di una richiesta proveniente da canale digitale.';

			System.debug('@@@A.M. newTask-lead: ' + lead);
			
			t.Description = lead.Messaggio__c;
			t.IFISForm__c = lead.IFISForm__c;
			t.IFISIdUnicoForm__c = lead.IFISIdUnicoForm__c;
			t.BI_IFISFormPriority__c = '1';

			System.debug('@@@A.M. newTask-t: ' + t);

			return t;
	
		}

		return null;

	}

	public static Account normalizeAccountValues(Account actualAccount){
	
		actualAccount.SAE__c = actualAccount.SAE__c == null ? '' : actualAccount.SAE__c;
		actualAccount.NaturaGiuridica__c = actualAccount.NaturaGiuridica__c == null ? '' : actualAccount.NaturaGiuridica__c;
		actualAccount.RAE__c = actualAccount.RAE__c == null ? '' : actualAccount.RAE__c;
		actualAccount.Ateco__c = actualAccount.Ateco__c == null ? '' : actualAccount.Ateco__c;
		
		actualAccount.BillingPostalCode = actualAccount.BillingPostalCode == null ? '' : actualAccount.BillingPostalCode;
		actualAccount.BillingCity = actualAccount.BillingCity == null ? '' : actualAccount.BillingCity;
		actualAccount.BillingStreetNumber__c = actualAccount.BillingStreetNumber__c == null ? '' : actualAccount.BillingStreetNumber__c;
		actualAccount.BillingStreetName__c = actualAccount.BillingStreetName__c == null ? '' : actualAccount.BillingStreetName__c;
		actualAccount.BillingStreetType__c = actualAccount.BillingStreetType__c == null ? '' : actualAccount.BillingStreetType__c;
		actualAccount.BillingState = actualAccount.BillingState == null ? '' : actualAccount.BillingState;

		actualAccount.ShippingPostalCode = actualAccount.ShippingPostalCode == null ? '' : actualAccount.ShippingPostalCode;
		actualAccount.ShippingCity = actualAccount.ShippingCity == null ? '' : actualAccount.ShippingCity;
		actualAccount.ShippingStreetNumber__c = actualAccount.ShippingStreetNumber__c == null ? '' : actualAccount.ShippingStreetNumber__c;
		actualAccount.ShippingStreetName__c = actualAccount.ShippingStreetName__c == null ? '' : actualAccount.ShippingStreetName__c;
		actualAccount.ShippingStreetType__c = actualAccount.ShippingStreetType__c == null ? '' : actualAccount.ShippingStreetType__c;
		actualAccount.ShippingState = actualAccount.ShippingState == null ? '' : actualAccount.ShippingState;
						
		/*
		actualAccount.EmailPEC__c = actualAccount.EmailPEC__c == null ? '' : actualAccount.EmailPEC__c;
		actualAccount.Email__c = actualAccount.Email__c == null ? '' : actualAccount.Email__c;
		*/
		actualAccount.PIVA__c = actualAccount.PIVA__c == null ? actualAccount.CF__c : actualAccount.PIVA__c;

		return actualAccount;

	}

	/*Deprecated -- no more used in CRM20
	public static boolean pairFileToOpportunity(Id opportunityId, Id documentId, String documentFamily, String documentType){

		// CONTROLLI FORMALI
		if(String.isEmpty(opportunityId) || String.isEmpty(documentId) || String.isEmpty(documentFamily) || String.isEmpty(documentType)){
			System.debug('pairFileToOpportunity - Dati mancanti');
			return false;		
		}

		// CONTROLLO CORRETTEZZA DELL'ID DELL'OPPORTUNITA'
		List<Opportunity> opps = [SELECT ID FROM Opportunity WHERE Id =:opportunityId LIMIT 1];
		
		if(opps.size() == 0){
			System.debug('pairFileToOpportunity - Opportunità non trovata - Id: '+opportunityId);
			return false;
		}

		Opportunity actualOpportunity = opps[0];
		// ACQUISIZIONE DEL CONTENT
		ContentVersion contentVersion = new ContentVersion();

		try {
			contentVersion = [
				SELECT Id, ContentDocumentId, IsLatest, VersionNumber, Title, Description, FileType, FileExtension, ExternalDocumentInfo1, ExternalDocumentInfo2, ExternalDataSourceId 
				FROM ContentVersion 
				WHERE ContentDocumentId = :documentId 
				LIMIT 1
			];
			contentVersion.Title = contentVersion.Title + '.' + contentVersion.FileExtension;
			update contentVersion;
		} catch (QueryException e) {

			System.debug( e.getMessage() );

			return false;

		}

		// CREAZIONE DELL'ALLEGATO

		Allegato__c newAllegato = new Allegato__c();
		newAllegato.Opportunita__c = opportunityId;
		newAllegato.Tipo__c = documentType;
		newAllegato.FamigliaDocumento__c = documentFamily;
		newAllegato.LatestContentVersionId__c = contentVersion.Id;

		insert newAllegato;

		// CREAZIONE DEL DOCUMENT LINK

		ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId = contentVersion.ContentDocumentId,LinkedEntityId = newAllegato.Id ,ShareType = 'I');

		insert cdl;

		return true;

	} */ //END of deprecate method pairFileToOpportunity

	public static List<Object> parseDocumentJSON(String serializedJSON){

		if(String.isEmpty(serializedJSON))
			return null;

		if(!serializedJSON.startsWith('[') && !serializedJSON.endsWith(']'))
			return null;

		// MODIFICA DEL JSON PER LIMITE DI APEX CHE NON PARSA JSON ARRAY VALIDI MA SENZA ATTRIBUTO INIZIALE

		String jsonInput = '{"files" : ' + serializedJSON + '}'; 

		try{

			Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
			List<Object> myMapObjects = (List<Object>) meta.get('files');
	
			return myMapObjects;

		}
		catch(Exception ex){

			System.debug('Error parsing Document JSON' + ex);

			return null;
		
		}

	}

	public static List<Object> parseReferentiJSON(String serializedJSON){

		if(String.isEmpty(serializedJSON))
			return null;

		if(!serializedJSON.startsWith('[') && !serializedJSON.endsWith(']'))
			return null;

		// MODIFICA DEL JSON PER LIMITE DI APEX CHE NON PARSA JSON ARRAY VALIDI MA SENZA ATTRIBUTO INIZIALE

		String jsonInput = '{"referenti" : ' + serializedJSON + '}'; 

		try{

			Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
			List<Object> myMapObjects = (List<Object>) meta.get('referenti');
	
			return myMapObjects;

		}
		catch(Exception ex){

			System.debug('Error parsing Referenti JSON' + ex);

			return null;
		
		}

	}

	public static Map<String, Object> parseProdottoJSON(String serializedJSON){

		if(String.isEmpty(serializedJSON))
			return null;

		if(!serializedJSON.startsWith('{') && !serializedJSON.endsWith('}'))
			return null;

		// MODIFICA DEL JSON PER LIMITE DI APEX CHE NON PARSA JSON ARRAY VALIDI MA SENZA ATTRIBUTO INIZIALE

		String jsonInput = '{"prodotto" : ' + serializedJSON + '}'; 

		try{

			Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
			Map<String, Object> myMapObjects = (Map<String, Object>) meta.get('prodotto');

			return myMapObjects;

		}
		catch(Exception ex){

			System.debug('Error parsing Prodotto JSON' + ex);

			return null;
		
		}

	}

    public static void sentMailToTheSubmitter(Id fromAddressOwaId, String toAddress, String owner, String ragioneSociale, String partitaIva, String workflowId, String workflowType){
        
        try{

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            String[] toAddresses = new String[] {toAddress}; 
                
            mail.setOrgWideEmailAddressId(fromAddressOwaId);
            
            mail.setToAddresses(toAddresses);

            mail.setSubject('Pratica ' + workflowType + ' Inviata a Banca Ifis da parte di ' + owner + '. ID: ' + workflowId);
            
            mail.setBccSender(false);
            
            mail.setUseSignature(false);

            String body = 'La pratica con ID ' + workflowId + ' è stata inviata a Banca Ifis ed inizierà la lavorazione.' + '\n';
			body += 'Ragione sociale: ' + ragioneSociale + '\n';
			body += 'Partita IVA: ' + partitaIva + '\n';
			body += '\n\n';
			body += 'SFDC Instance: ' + System.URL.getSalesforceBaseUrl().toExternalForm();
            mail.setPlainTextBody(body);

            String htmlBody = 'La pratica con ID <b>' + workflowId + '</b> è stata inviata a Banca Ifis ed inizierà la sua lavorazione.<p>';
			htmlBody += '<p>Ragione sociale: ' + ragioneSociale + '</p>';
			htmlBody += '<p>Partita IVA: ' + partitaIva + '</p>';
			htmlBody += '<p>SFDC Instance: ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '</p>';
			mail.setHtmlBody(htmlBody);

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });        
            
        }
        
        catch(Exception ex){
            
            System.debug(SGA_ERROR_HEADER + ex);
            
        }        
        
    }    
    
    @AuraEnabled 
    public static List<Object> checkPartitaIva(String partitaIva){
        
        List<Object> myResult = new List<Object>();
        try {
            // IMPOSTAZIONE DELL' OGGETTO BASE DI RICERCA          
            CtrlWizardAccount.InputObj ricercaIO = new CtrlWizardAccount.InputObj(partitaIva, null, null, 'piva', false);

            // CONTROLLO SE LA PARTITA IVA E' GIA' PRESENTE IN SF. IN CASO POSITIVO RESTITUISCO IL RISULTATO 
            Account[] accsSalesforceAttivi = new Account[]{};
			accsSalesforceAttivi = CtrlWizardAccount.searchAnagrafica(ricercaIO,BACKEND_SALESFORCE);

            if(accsSalesforceAttivi.size() > 0) {
                Account actualAccount = accsSalesforceAttivi[0];
                
				actualAccount = normalizeAccountValues(actualAccount);

                myResult.add(OK);
                myResult.add(actualAccount.Name);            
                myResult.add(actualAccount);
                myResult.add(BACKEND_SALESFORCE);
                System.debug('Anagrafica trovata in BACKEND_SALESFORCE');

                return myResult;
            }
              
            // CONTROLLO SE LA PARTITA IVA E' GIA' PRESENTE IN CEDACRI. IN CASO POSITIVO RESTITUISCO IL RISULTATO             
            Account[] accsCedacriAttivi = new Account[]{};
			accsCedacriAttivi = CtrlWizardAccount.searchAnagrafica(ricercaIO,BACKEND_CEDACRI);

            if(accsCedacriAttivi.size() > 0) {
                Account actualAccount = accsCedacriAttivi[0];
                
                // INTEGRAZIONE DATI PERCHE' LA PRIMA RICERCA CEDACRI E' PARZIALE
                WsAnagrafeUtils.mergeWithCedacri(actualAccount);
                
				actualAccount = normalizeAccountValues(actualAccount);

                myResult.add(OK);
                myResult.add(actualAccount.Name);            
                myResult.add(actualAccount);
                myResult.add(BACKEND_CEDACRI);
                System.debug('Anagrafica trovata in BACKEND_CEDACRI');

                return myResult;
            }
         
            // CONTROLLO SE LA PARTITA ESISTE IN RIBES. SE SI E RISULTA ATTIVA, HO LA CONDIZIONE NECESSARIA PER PROCEDERE             
            Account[] accsRibesAttivi = new Account[]{};
			accsRibesAttivi = CtrlWizardAccount.searchAnagrafica(ricercaIO,BACKEND_CERVED);

            if(accsRibesAttivi.size() > 0) {
                Account actualAccount = accsRibesAttivi[0];

				actualAccount = normalizeAccountValues(actualAccount);
				                
                myResult.add(OK);
                myResult.add(actualAccount.Name);            
                myResult.add(actualAccount);
                myResult.add(BACKEND_CERVED);
                System.debug('Anagrafica trovata in BACKEND_CERVED');

                return myResult;                
            }
            
            myResult.add(KO);
            myResult.add(MSG_ERR03);
            myResult.add(null);

            return myResult;
            
        }
        catch(Exception anagEx){
            Log__c logEx = new Log__c();
			logEx.Source__c = 'bifis_crm_c_CommonUtils';
			logEx.ErorrMessage__c = LOG_PREFIX + anagEx;
			insert logEx;

            myResult.add(KO);
            myResult.add(MSG_ERR03);
            myResult.add(null);
            
            return myResult;
            
        }
    }     

	/**
	 * create a new Account reading input from specified WorkflowMutui NSA object
	 */
	public static Account createFromNSAObj(WorkflowMutui__c w) {
		return new Account(
		  Name = w.Ragione_Sociale__c,
		  OwnerId = UtenzeDefault__c.getInstance().IdUtente__c,
		  PIVA__c = w.PartitaIVA__c,
		  CF__c = w.PartitaIVA__c,
		  ShippingState = String.isNotBlank(w.ProvinciaSpedizione__c) ? w.ProvinciaSpedizione__c.toUpperCase() : '',
		  ShippingState__c = String.isNotBlank(w.ProvinciaSpedizione__c) ? w.ProvinciaSpedizione__c.toUpperCase() : '',
		  ShippingPostalCode = String.isNotBlank(w.CapSpedizione__c) ? w.CapSpedizione__c : '',
		  ShippingPostalCode__c = String.isNotBlank(w.CapSpedizione__c) ? w.CapSpedizione__c : '',
		  ShippingCity = String.isNotBlank(w.CittaSpedizione__c) ? w.CittaSpedizione__c.toUpperCase() : '',
		  ShippingCity__c = String.isNotBlank(w.CittaSpedizione__c) ? w.CittaSpedizione__c.toUpperCase() : '',
		  ShippingStreetName__c = String.isNotBlank(w.IndirizzoSpedizione__c) ? w.IndirizzoSpedizione__c.toUpperCase() : '',
		  ShippingStreetNumber__c = String.isNotBlank(w.CivicoSpedizione__c) ? w.CivicoSpedizione__c.toUpperCase() : '',
		  ShippingStreetType__c = String.isNotBlank(w.TipoViaSpedizione__c) ? w.TipoViaSpedizione__c.toUpperCase() : '',
		  BillingState = String.isNotBlank(w.ProvinciaLegale__c) ? w.ProvinciaLegale__c.toUpperCase() : '',
		  BillingState__c = String.isNotBlank(w.ProvinciaLegale__c) ? w.ProvinciaLegale__c.toUpperCase() : '',
		  BillingPostalCode = String.isNotBlank(w.CapLegale__c) ? w.CapLegale__c : '',
		  BillingPostalCode__c = String.isNotBlank(w.CapLegale__c) ? w.CapLegale__c : '',
		  BillingCity = String.isNotBlank(w.CittaLegale__c) ? w.CittaLegale__c.toUpperCase() : '',
		  BillingCity__c = String.isNotBlank(w.CittaLegale__c) ? w.CittaLegale__c.toUpperCase() : '',
		  BillingStreetName__c = String.isNotBlank(w.IndirizzoLegale__c) ? w.IndirizzoLegale__c.toUpperCase() : '',
		  BillingStreetNumber__c = String.isNotBlank(w.CivicoLegale__c) ? w.CivicoLegale__c.toUpperCase() : '',
		  BillingStreetType__c = String.isNotBlank(w.TipoViaLegale__c) ? w.TipoViaLegale__c.toUpperCase() : '', 
		  phone = w.Telefono__c,
		  email__c = w.Email__c,
		  StatoCensimento__c = null,
		  EmailPEC__c = w.EmailPEC__c,
		  Fax = w.Fax__c,
		  SAE__c = w.SAE__c,
		  RAE__c = w.RAE__c,
		  Ateco__c = w.Ateco__c,
		  NaturaGiuridica__c = w.Natura_Giuridica__c,
		  NumberOfEmployees = Integer.valueOf(w.NumeroAddetti__c),
		  WGC_Numero_dipendenti__c = w.NumeroAddetti__c, 
		  PaeseCasaMadre__c = 'ITALIA', //adione-crm20 campi obbligatori per MAV
		  PaeseSvolgimentoAttivitaPrevalente__c = 'ITALIA'
		);		
	}

	/**
	 * create and insert a new Contact reading input from specified list 
	 * if a Contact is already present in CRM, it won't be created
	 * CRM20: dobbiamo fare censimento light della PF, serve dunque dettaglio residenza
	 * non essendo disponibile in community NSA, impostiamo quelli di nascita + dei default
	 * poi l'operatore di backoffice corregge quando fa censimento full
	 */
	public static void createFromNSAObj(List<Object> pfs, Id accId) {
		UtilCodiceFiscale u = new UtilCodiceFiscale();
		String nome, cognome, cf, ruolo, tipologiaTE;
		Contact c;
		
		for(Object pf : pfs) {
			Map<String, Object> m = (Map<String, Object>) pf;
			nome = ((String) m.get('nome')).toUpperCase();
			cognome = ((String) m.get('cognome')).toUpperCase();
			cf = ((String) m.get('codiceFiscale')).toUpperCase();
			ruolo = ((String) m.get('ruolo')).toUpperCase();
			tipologiaTE = (String) m.get('tipologiaTE');

			c = searchByCodFisc(cf);
			if (c == null) { //new contact to be created
				UtilCodiceFiscale.ContactInfo ci = u.reverseCodiceFiscale(
					cf,
					nome,
					cognome
				);

				Comune__c comuneNascita = [SELECT Name, Provincia__c, Cap__c FROM Comune__c WHERE CodiceCatastale__c = :ci.codiceCatastale LIMIT 1];

				c = new Contact(
					FirstName = nome,
					LastName = cognome,
					CF__c = cf,
					Birthdate = ci.birthDate,
					Sesso__c = ci.sesso,
					LuogoNascita__c = comuneNascita.Name,
					ProvinciaNascita__c = comuneNascita.Provincia__c,
					PaeseNascita__c = 'IT',
					MailingState = comuneNascita.Provincia__c,
					MailingState__c = comuneNascita.Provincia__c,
					MailingPostalCode = comuneNascita.Cap__c,
					MailingPostalCode__c = comuneNascita.Cap__c,
					MailingCity = comuneNascita.Name,
					MailingCity__c = comuneNascita.Name,
					MailingStreetName__c = 'CORREGGERE', //adione-CRM20 
					MailingStreetNumber__c = '1', //adione-CRM20 
					StatoCensimento__c = null,
					SAE__C = '600',
					TAECode__c = '984',
					CodCatastaleLocNascita__c = ci.codiceCatastale,
					AccountId = accId
				);

				try {
					//create contact
					insert c;
					//create relation with Account and specify role
					AccountContactRelation rel = [
						SELECT Id, WGC_Ruolo__c, WGC_Tipologia_Titolare_Effettivo__c, WGC_Ruolo_Pratica__c
						FROM AccountContactRelation 
						WHERE AccountId = :accId and ContactId = :c.Id
						LIMIT 1];
					/* --FIXME non pre-associamo per poter laciare fare l'operazione a FE
					rel.WGC_Ruolo__c = ruolo.containsIgnoreCase('Esecutore') ? 'Z1' : 'J';
					rel.WGC_Ruolo_Pratica__c = rel.WGC_Ruolo__c;
					rel.WGC_Tipologia_Titolare_Effettivo__c = tipologiaTE;
					
					//questo finchè non avremo i dati da NSA per fare censimento FULL
					//allora potremo creare le reti da batch
					rel.WGC_Selezionato__c = true; //adione-CRM20 seleziona i referenti per il MAV
					rel.WGC_IsSelected__c = true;
					*/

					update rel;
				} catch (Exception e) {
					logError(null, c, null, e);
					throw e;  //block execution! not valid c.f. not acceptable
				}

			} else { //contact esistente -> crea eventuale nuova relazione contact-account se mancante
				List<AccountContactRelation> correlato = [
					SELECT Id 
					FROM AccountContactRelation 
					WHERE AccountId = :accId and ContactId = :c.Id];
				if (correlato == null || correlato.size() == 0) {
					AccountContactRelation rel = new AccountContactRelation();
					rel.AccountId = accId;
					rel.ContactId = c.Id;
					rel.IsActive = true;
					rel.ContattoPrimario__c = false;
					/*
					rel.WGC_Ruolo__c = ruolo.containsIgnoreCase('Esecutore') ? 'Z1' : 'J';
					rel.WGC_Ruolo_Pratica__c = rel.WGC_Ruolo__c;
					rel.WGC_Tipologia_Titolare_Effettivo__c = tipologiaTE;
					rel.WGC_Selezionato__c = true; //adione-CRM20 seleziona i referenti per il MAV
					rel.WGC_IsSelected__c = true;
					*/
					insert rel;
				}
			}
		}
	}

	/**
	 * search an Account/company in CRM and in Ribes, optionally merging results
	 * search is made against P.IVA field only
	 */
	public static Account searchByPIVA(String piva) {
		Account[] accsSuCrm = [
		  SELECT		Id,
						OwnerId, 
						RecordType.DeveloperName, 
						NDGGruppo__c, 
						NDG__c, 
						StatoCensimento__c, 
						Name, 
						NaturaGiuridica__c,
						SAE__c,
						RAE__c,
						Ateco__c,
						TAECode__c,
						DataIscrizioneCCIAA__c,
						REA__c,
						BillingStreetName__c,
						BillingStreetType__c,
						BillingStreetNumber__c,
						BillingPostalCode,
						BillingCountry,
						BillingState,
						BillingCity, 
						ShippingCity,
						ShippingStreetName__c,
						ShippingStreetType__c,
						ShippingStreetNumber__c,
						ShippingPostalCode,
						ShippingCountry,
						ShippingState,
						CF__c,
						PIVA__c,
						Email__c,
						telefonoprefisso__c,
						telefononumero__c,
						fax,
						consensoallaprofilazione__c,
						consensoattivitapromozionaleterzi__c,
						consensoattivitapromricerchemercato__c,
						consensoprodottibancaricerchemercato__c, 
						consensoprodottisocietaterze__c,
						consensosolomodalitatradizionali__c,
						datainserimentoconsensi__c,
						PartecipazioneSocietaFiduciarie2__c,
						WGC_Numero_dipendenti__c,
						NumberOfEmployees
		  FROM Account
		  WHERE (PIVA__c = :piva OR CF__c = :piva)
		  AND CodiceIstituto3N__c = :CI3N_FACTORING
		];
		if(accsSuCrm.size() > 1)
			throw new Ex.BtcConvertLeadException('Esiste più di un Account con la stessa Partita iva in CRM');

		//look up existing company in Ribes
		//we expect at most 1 Account since we search by P.IVA 
		Account[] accsCervedAttivi = new Account[] {};
		for(Account a : CtrlWizardAccount.searchAnagraficaRibes(null, piva, null)) {
			if(a.StatoAnagrafica__c == 'ATTIVA')
				accsCervedAttivi.add(a);
		}
		
		//company found in Ribes only
		if(accsSuCrm.isEmpty()) {
		  if(accsCervedAttivi.size() == 1)
			return accsCervedAttivi[0];
		  else 
			return null;
		}

		//existing Account present in CRM
		if(accsSuCrm.size() == 1) {
			if(accsCervedAttivi.size() != 1 || accsSuCrm[0].RecordType.DeveloperName != 'Prospect')
				return accsSuCrm[0];
			else {
				//merge details between existing Account and retrieved data from Ribes
				Account cervedAcc = accsCervedAttivi[0];
				Account res = accsSuCrm[0];
				res.Name = cervedAcc.Name;
				res.PIVA__c = cervedAcc.PIVA__c;
				res.CF__c = cervedAcc.CF__c;
				if(res.BillingCity != cervedAcc.BillingCity) {
					res.BillingPostalCode = null;
				}
				res.BillingStreet = cervedAcc.BillingStreet;
				res.BillingCity = cervedAcc.BillingCity;
				res.BillingState = cervedAcc.BillingState;
				return res;
			  }
		}

		//couldn't find company
		return null;
	}

	/**
	 * search a Contact in CRM *only* - by cod. fisc. *only*
	 */
	public static Contact searchByCodFisc(String codFisc) {
		//List<Contact> contacts = CtrlWizardAccount.searchContattiSFDC(codFisc, null, null);
		List<Contact> contacts = [SELECT
							Id,
							AccountID,
							Account.Name,
							CodiceIstituto3N__c,
							NDGGruppo__c,
							PEP__c,
							PEPTipoCarica__c,
							StatoFastFinance__c,
                            MailingCity,
                            MailingCountry,
                            MailingPostalCode,
                            MailingState,
                            MailingCity__c,
                            MailingCountry__c,
                            MailingPostalCode__c,
                            MailingState__c,
							MailingStreetName__c,
							MailingStreetNumber__c,
							MailingStreetType__c,
             				LuogoNascita__c,
							ProvinciaNascita__c,
             				CF__c, 
             				Sesso__c,
             				FirstName,
             				LastName,
							SAE__c,
							TAECode__c,
							Birthdate

						   FROM Contact
						   WHERE CF__c = :codFisc];

		if (contacts.size() > 0) {
			return contacts[0]; //cod fisc is unique key, so we expect only 1 result
		} else {
			return null; //contact not present in CRM
		}
	}

	/**
	 * ritorna JSON serializzato con domande in base al tipo questionario
	 */
	public static String getDomandeQQ(String tipQuest) {
		if (tipQuest == 'Small Business') {
			return '[{"value":"B","dominio":[{"value":"A","label":"Forte crescita (>10%)"},{"value":"B","label":"Lieve crescita (2%-10%)"},{"value":"C","label":"Stazionario (+/- 2%)"},{"value":"D","label":"Diminuzione (<2%)"},{"value":"E","label":"Inf non disponib./valutab."}],"domanda":"Qual e\' l andamento del mercato?","codiceModulo":2801,"codiceDatoDomanda":66000},{"value":"B","dominio":[{"value":"A","label":"Meno del 30%"},{"value":"B","label":"Tra il 30% e il 60%"},{"value":"C","label":"Oltre 60% con sostiuz. fornito"},{"value":"D","label":"Oltre 60% con difficolta\' sost"},{"value":"E","label":"Inf non disponib./non valutab."}],"domanda":"Quanto pesano i primi 10 fornitori?","codiceModulo":2801,"codiceDatoDomanda":66001},{"value":"B","dominio":[{"value":"A","label":"Regolare"},{"value":"B","label":"Occasionalmente anomalo"},{"value":"C","label":"Irregolare"},{"value":"D","label":"Non rilevabile (nuovo rapporto"},{"value":"E","label":"Inf non disponib./non valutab."}],"domanda":"Qual e\' la qualita\' del pagamento ai fornitori negli ultimi dodici mesi?","codiceModulo":2801,"codiceDatoDomanda":66002},{"value":"B","dominio":[{"value":"A","label":"Contanti"},{"value":"B","label":"Rimesse dirette"},{"value":"C","label":"Accettazioni"},{"value":"D","label":"Assegni"},{"value":"E","label":"Ri. Ba."},{"value":"F","label":"Tratte"},{"value":"G","label":"MAV/RAV/RID"},{"value":"H","label":"Inf non disponib./non valutab."}],"domanda":"Modalita\' di pagamento prevalente?","codiceModulo":2801,"codiceDatoDomanda":66003},{"value":"D","dominio":[{"value":"A","label":"Meno del 30%"},{"value":"B","label":"Tra il 30% e il 60%"},{"value":"C","label":"> 60% con sostiuz. clienti"},{"value":"D","label":"> 60% con difficolta\' sost"},{"value":"E","label":"Inf non disponib./non valutab."}],"domanda":"Quanto pesano come fatturato i primi 10 clienti?","codiceModulo":2801,"codiceDatoDomanda":66004},{"value":"B","dominio":[{"value":"A","label":"Regolare"},{"value":"B","label":"Occasionalmente anomalo"},{"value":"C","label":"Irregolare"},{"value":"D","label":"Non rilevab. (nuovo rapporto)"},{"value":"E","label":"Inf non disponib./non valutab."}],"domanda":"Qual e\' la qualita\' degli incassi dai clienti?","codiceModulo":2801,"codiceDatoDomanda":66005},{"value":"C","dominio":[{"value":"A","label":"Contanti"},{"value":"B","label":"Rimesse dirette"},{"value":"C","label":"Accettazioni"},{"value":"D","label":"Assegni"},{"value":"E","label":"Ri. Ba."},{"value":"F","label":"Tratte"},{"value":"G","label":"MAV/RAV/RID"},{"value":"H","label":"Inf non disponib./non valutab."}],"domanda":"Modalita\' di incasso prevalente?","codiceModulo":2801,"codiceDatoDomanda":66006},{"value":"C","dominio":[{"value":"A","label":"Non sono presenti"},{"value":"B","label":"Presenti <30% fatturato"},{"value":"C","label":"Presenti >30% fatturato"},{"value":"D","label":"Inf non disponib./non valutab."}],"domanda":"Le commesse del settore pubblico sono?","codiceModulo":2801,"codiceDatoDomanda":66007},{"value":"B","dominio":[{"value":"A","label":"< 1 A: prima altro core bsn"},{"value":"B","label":"1< A <3: prima altro core bsn"},{"value":"C","label":"> 3 A: prima altro core bsn"},{"value":"D","label":"Sempre attuale core bsn"},{"value":"E","label":"Start up (< 1 A)"},{"value":"F","label":"Inf non disponib./non valutab."}],"domanda":"Da quanto tempo il gruppo/azienda opera nel core business attuale?","codiceModulo":2802,"codiceDatoDomanda":66008},{"value":"B","dominio":[{"value":"A","label":"SI"},{"value":"B","label":"No"},{"value":"C","label":"Inf non disponib./non valutab."}],"domanda":"L\'azienda e\' puntuale nella presentazione della documentazione contabile?","codiceModulo":2803,"codiceDatoDomanda":66013},{"value":"A","dominio":[{"value":"A","label":"Si, PSP disponibile. Si inv"},{"value":"B","label":"Si, PSP disponibile. No inv"},{"value":"C","label":"Si, PSP non disponib. Si inv"},{"value":"D","label":"Si, PSP non disponib. No inv"},{"value":"E","label":"No PSP"},{"value":"F","label":"Inf non disponib./non valutab."}],"domanda":"Piano Sviluppo Plurienn. PSP. Per i prox 12 mesi previsti programmi di investimento di rilievo?","codiceModulo":2803,"codiceDatoDomanda":66015},{"value":"A","dominio":[{"value":"A","label":"Magg. az. di una sola famiglia"},{"value":"B","label":"Patti sind. blindano maggior."},{"value":"C","label":"Fraz.azionario:difficile acq."},{"value":"D","label":"Fraz.azionario:possibile acq."},{"value":"E","label":"Inf non disponib./non valutab."}],"domanda":"Costituzione della base proprietaria?","codiceModulo":2804,"codiceDatoDomanda":66016},{"value":"B","dominio":[{"value":"A","label":"Si:problema non significativo"},{"value":"B","label":"No"},{"value":"C","label":"Si, con grado profess.le basso"},{"value":"D","label":"Si, con grado profess.le medio"},{"value":"E","label":"Si, con grado profess.le alto"}],"domanda":"In azienda sono presenti successori?","codiceModulo":2804,"codiceDatoDomanda":66019},{"value":"B","dominio":[{"value":"A","label":"No"},{"value":"B","label":"Si, valore <10% patr. Netto"},{"value":"C","label":"Si, valore >=10% patr. Netto"},{"value":"D","label":"Inf non disponib./non valutab."}],"domanda":"Esistono rischi legati a cause legali pendenti e/o contenziosi fiscali e previdenziali?","codiceModulo":2805,"codiceDatoDomanda":66020},{"value":"B","dominio":[{"value":"A","label":"Si, entita\' ridotta"},{"value":"B","label":"Si, entita\' media, coperti"},{"value":"C","label":"Si, entita\' media, non coperti"},{"value":"D","label":"Si, entita\' elevata, coperti"},{"value":"E","label":"Si, entita\' elev. non coperti"},{"value":"F","label":"Inf non disponib./non valutab."}],"domanda":"L\'impresa ha rischi operativi ambientali, tecnologici, di immagine e ha prodotti pericolosi?","codiceModulo":2805,"codiceDatoDomanda":66021},{"value":"B","dominio":[{"value":"A","label":"Bilancio cert. senza eccezioni"},{"value":"B","label":"Bilancio cert. con eccezioni"},{"value":"C","label":"Bilancio non certificato"},{"value":"D","label":"Inf non disponib./non valutab."}],"domanda":"Eventuale certificazione del bilancio da parte di societa\' di revisione?","codiceModulo":2805,"codiceDatoDomanda":66022},{"value":"A","dominio":[{"value":"A","label":"Si, tutte per settore appart."},{"value":"B","label":"In corso una o piu\' richieste"},{"value":"C","label":"No"},{"value":"D","label":"Inf non disponib./non valutab."}],"domanda":"Ottenimento di certificazioni di qualita\'?","codiceModulo":2805,"codiceDatoDomanda":66023},{"value":"D","dominio":[{"value":"A","label":"no."},{"value":"B","label":"Si, con una stelletta"},{"value":"C","label":"Si, da 1 stel. + a 2 stel. 2 +"},{"value":"D","label":"Si, con tre stellette"}],"domanda":"La societa\' ha ottenuto il Rating di Legalita\' AGCM ?","codiceModulo":2806,"codiceDatoDomanda":66024}]';
		} else {
			return '[{"value":"B","dominio":[{"value":"A","label":"Forte crescita (>10%)"},{"value":"B","label":"Lieve crescita (2%-10%)"},{"value":"C","label":"Stazionario (+/- 2%)"},{"value":"D","label":"Diminuzione (<2%)"},{"value":"E","label":"Inf non disponib./valutab."}],"domanda":"Qual e\' l andamento del mercato?","codiceModulo":2901,"codiceDatoDomanda":66000},{"value":"B","dominio":[{"value":"A","label":"Meno del 30%"},{"value":"B","label":"Tra il 30% e il 60%"},{"value":"C","label":"Oltre 60% con sostiuz. fornito"},{"value":"D","label":"Oltre 60% con difficolta\' sost"},{"value":"E","label":"Inf non disponib./non valutab."}],"domanda":"Quanto pesano i primi 10 fornitori?","codiceModulo":2901,"codiceDatoDomanda":66001},{"value":"B","dominio":[{"value":"A","label":"Regolare"},{"value":"B","label":"Occasionalmente anomalo"},{"value":"C","label":"Irregolare"},{"value":"D","label":"Non rilevabile (nuovo rapporto"},{"value":"E","label":"Inf non disponib./non valutab."}],"domanda":"Qual e\' la qualita\' del pagamento ai fornitori negli ultimi dodici mesi?","codiceModulo":2901,"codiceDatoDomanda":66002},{"value":"D","dominio":[{"value":"A","label":"Meno del 30%"},{"value":"B","label":"Tra il 30% e il 60%"},{"value":"C","label":"> 60% con sostiuz. clienti"},{"value":"D","label":"> 60% con difficolta\' sost"},{"value":"E","label":"Inf non disponib./non valutab."}],"domanda":"Quanto pesano come fatturato i primi 10 clienti?","codiceModulo":2901,"codiceDatoDomanda":66004},{"value":"B","dominio":[{"value":"A","label":"Regolare"},{"value":"B","label":"Occasionalmente anomalo"},{"value":"C","label":"Irregolare"},{"value":"D","label":"Non rilevab. (nuovo rapporto)"},{"value":"E","label":"Inf non disponib./non valutab."}],"domanda":"Qual e\' la qualita\' degli incassi dai clienti?","codiceModulo":2901,"codiceDatoDomanda":66005},{"value":"C","dominio":[{"value":"A","label":"Contanti"},{"value":"B","label":"Rimesse dirette"},{"value":"C","label":"Accettazioni"},{"value":"D","label":"Assegni"},{"value":"E","label":"Ri. Ba."},{"value":"F","label":"Tratte"},{"value":"G","label":"MAV/RAV/RID"},{"value":"H","label":"Inf non disponib./non valutab."}],"domanda":"Modalita\' di incasso prevalente?","codiceModulo":2901,"codiceDatoDomanda":66006},{"value":"C","dominio":[{"value":"A","label":"Non sono presenti"},{"value":"B","label":"Presenti <30% fatturato"},{"value":"C","label":"Presenti >30% fatturato"},{"value":"D","label":"Inf non disponib./non valutab."}],"domanda":"Le commesse del settore pubblico sono?","codiceModulo":2901,"codiceDatoDomanda":66007},{"value":"B","dominio":[{"value":"A","label":"< 1 A: prima altro core bsn"},{"value":"B","label":"1< A <3: prima altro core bsn"},{"value":"C","label":"> 3 A: prima altro core bsn"},{"value":"D","label":"Sempre attuale core bsn"},{"value":"E","label":"Start up (< 1 A)"},{"value":"F","label":"Inf non disponib./non valutab."}],"domanda":"Da quanto tempo il gruppo/azienda opera nel core business attuale?","codiceModulo":2902,"codiceDatoDomanda":66008},{"value":"","dominio":[{"value":"A","label":"Si, investimenti adeguati"},{"value":"B","label":"Si, investimenti non adeguati"},{"value":"C","label":"No, non investe in R&S"},{"value":"D","label":"Inf non disponib./non valutab."}],"domanda":"L\'azienda investe in ricerca e sviluppo?","codiceModulo":2902,"codiceDatoDomanda":66009},{"value":"","dominio":[{"value":"A","label":"Non previsti"},{"value":"B","label":"Previsti, ma non rilevanti"},{"value":"C","label":"Previsti, rilevanti"},{"value":"D","label":"Inf non disponib./non valutab."}],"domanda":"Fattori esterni che possono modificare il business?","codiceModulo":2902,"codiceDatoDomanda":66010},{"value":"","dominio":[{"value":"A","label":"Bassa, 1 sett. imp. non fles."},{"value":"B","label":"Bassa, 1 sett. impian. fles."},{"value":"C","label":"Media, + settori"},{"value":"D","label":"Elevata, + settori"},{"value":"E","label":"Inf non disponib./non valutab."}],"domanda":"La diversificazione dei prodotti/servizi risulta?","codiceModulo":2902,"codiceDatoDomanda":66011},{"value":"","dominio":[{"value":"A","label":"Ridotta, opera in un Paese"},{"value":"B","label":"Media,+Paesi, +rilev>50% fatt"},{"value":"C","label":"Elev, +Paesi, +rilev<50% fatt"},{"value":"D","label":"Inf non disponib./non valutab."}],"domanda":"Diversificazione geografica dei mercati di riferimento?","codiceModulo":2902,"codiceDatoDomanda":66012},{"value":"B","dominio":[{"value":"A","label":"SI"},{"value":"B","label":"No"},{"value":"C","label":"Inf non disponib./non valutab."}],"domanda":"L\'azienda e\' puntuale nella presentazione della documentazione contabile?","codiceModulo":2903,"codiceDatoDomanda":66013},{"value":"","dominio":[{"value":"A","label":"Si, PI disponibile. Si inv"},{"value":"B","label":"Si, PI disponibile. No inv"},{"value":"C","label":"Si, PI non disponibile. Si inv"},{"value":"D","label":"Si, PI non disponibile. No inv"},{"value":"E","label":"No PI"},{"value":"F","label":"Inf non disponib./non valutab."}],"domanda":"Esiste un piano industriale? Per i prossimi 12 mesi, previsti programmi di investimento di rilievo?","codiceModulo":2903,"codiceDatoDomanda":66014},{"value":"A","dominio":[{"value":"A","label":"Magg. az. di una sola famiglia"},{"value":"B","label":"Patti sind. blindano maggior."},{"value":"C","label":"Fraz.azionario:difficile acq."},{"value":"D","label":"Fraz.azionario:possibile acq."},{"value":"E","label":"Inf non disponib./non valutab."}],"domanda":"Costituzione della base proprietaria?","codiceModulo":2904,"codiceDatoDomanda":66016},{"value":"","dominio":[{"value":"A","label":"< 3 anni"},{"value":"B","label":"Tra 3 e 10 anni"},{"value":"C","label":"> 10 anni"},{"value":"D","label":"Inf non disponib./non valutab."}],"domanda":"Esperienza nel settore del management?","codiceModulo":2904,"codiceDatoDomanda":66017},{"value":"","dominio":[{"value":"A","label":"Si, piano di stock option"},{"value":"B","label":"Si, per risultati di gestione"},{"value":"C","label":"Non esistono ufficialmente"},{"value":"D","label":"Intenzione di introdurli"},{"value":"E","label":"Inf non disponib./non valutab."}],"domanda":"Esistono degli incentivi previsti per i risultati conseguiti dal management?","codiceModulo":2904,"codiceDatoDomanda":66018},{"value":"B","dominio":[{"value":"A","label":"No"},{"value":"B","label":"Si, valore <10% patr. Netto"},{"value":"C","label":"Si, valore >=10% patr. Netto"},{"value":"D","label":"Inf non disponib./non valutab."}],"domanda":"Esistono rischi legati a cause legali pendenti e/o contenziosi fiscali e previdenziali?","codiceModulo":2905,"codiceDatoDomanda":66020},{"value":"B","dominio":[{"value":"A","label":"Si, entita\' ridotta"},{"value":"B","label":"Si, entita\' media, coperti"},{"value":"C","label":"Si, entita\' media, non coperti"},{"value":"D","label":"Si, entita\' elevata, coperti"},{"value":"E","label":"Si, entita\' elev. non coperti"},{"value":"F","label":"Inf non disponib./non valutab."}],"domanda":"L\'impresa ha rischi operativi ambientali, tecnologici, di immagine e ha prodotti pericolosi?","codiceModulo":2905,"codiceDatoDomanda":66021},{"value":"A","dominio":[{"value":"A","label":"Si, tutte per settore appart."},{"value":"B","label":"In corso una o piu\' richieste"},{"value":"C","label":"No"},{"value":"D","label":"Inf non disponib./non valutab."}],"domanda":"Ottenimento di certificazioni di qualita\'?","codiceModulo":2905,"codiceDatoDomanda":66023},{"value":"D","dominio":[{"value":"A","label":"no."},{"value":"B","label":"Si, con una stelletta"},{"value":"C","label":"Si, da 1 stel. + a 2 stel. 2 +"},{"value":"D","label":"Si, con tre stellette"}],"domanda":"La societa\' ha ottenuto il Rating di Legalita\' AGCM ?","codiceModulo":2906,"codiceDatoDomanda":66024}]';
		}
	}

	@Future(callout=true)
	public static void runQQ(String payload) {
		WsAnagrafe.ModificaDatiAggiuntiviQQInput input = 
			(WsAnagrafe.ModificaDatiAggiuntiviQQInput) JSON.deserialize(payload, WsAnagrafe.ModificaDatiAggiuntiviQQInput.class);

		WsAnagrafe.modificaDatiAggiuntiviQQ(input);
	}

	@Future(callout=true)
	public static void runUpdateRole(String accountId, String contactId, List<String> rolesList) {
		WGC_EditRolesModalController.updateRole(accountId, contactId, rolesList);
	}

	@Future(callout=true)
	public static void uploadDocFuture(String recordId, String docToInsert, String optyId, String docName) {
		bifis_crm_c_CommonUtils.uploadDoc(recordId, docToInsert, optyId, docName);
	}

	public static void uploadDoc(String recordId, String docToInsert, String optyId, String docName) {
		System.debug('---> Batch NSA - upload su cedacri documento: '+docName+' per object: '+recordId);
		try {
			WGC_FileUploaderController.WrapperResponse wr = WGC_FileUploaderController.uploadDocMultipart(recordId, docToInsert, optyId, false, 'NSA');
			if (!wr.success) {
				bifis_crm_c_CommonUtils.logError(null, null, null, docName+'--'+wr.message);
			} 
		} catch (Exception e) {
			//log error
			Id objectId = (Id)recordId;
			String objectName = objectId.getSObjectType().getDescribe().getName();
			String a,c='';
			if (objectName == 'Account') {
				a = objectId;
			} else {
				c = objectId;
			}
				
			bifis_crm_c_CommonUtils.logError(a, c, null, '---> Batch NSA - upload su cedacri documento: '+docName+' per object: '+recordId+'--json-cedacri--'+docToInsert);
			bifis_crm_c_CommonUtils.logError(null, null, null, e);
		}
	}

	/**
	 * Creates a Log__c entry from objects: Account, Contact, WorkflowMutui, Exception
	 */
	public static void logError(Account a, Contact c, WorkflowMutui__c w, Exception e) {
		Log__c l = new Log__c();
		l.CodiceFunzione__c = 'bifis_crm_b_MccNsaGenerateOppException';
		l.Source__c = 'bifis_crm_b_MccNsaGenerateOpp';
		l.ErorrMessage__c = e.getMessage() + ' - ' + e.getStackTraceString();

		if (a != null)
			l.Account__c = a.Id;

		if (c != null)
			l.Contact__c = c.Id;

		if (w != null && !String.isBlank(w.PartitaIVA__c)) {
			l.CodiceCliente__c = w.PartitaIVA__c;
			if (e != null)
				w.ErrorMessage__c = (e.getMessage() + '\n\n' + e.getStackTraceString()).abbreviate(131072);
		} else if (a != null && !String.isBlank(a.PIVA__c)) {
			l.CodiceCliente__c = a.PIVA__c;
		} else if (c != null && !String.isBlank(c.CF__c)) {
			l.CodiceCliente__c = c.CF__c;
		}

		insert l;
	}

	/**
	 * Creates a Log__c entry from Account Id, Contact Id, WorkflowMutui object, String error message
	 */
	public static void logError(Id a, Id c, WorkflowMutui__c w, String e) {
		Log__c l = new Log__c();
		l.CodiceFunzione__c = 'bifis_crm_b_MccNsaGenerateOppException';
		l.Source__c = 'bifis_crm_b_MccNsaGenerateOpp';
		l.ErorrMessage__c = e;

		if (a != null)
			l.Account__c = a;

		if (c != null)
			l.Contact__c = c;

		if (w != null && !String.isBlank(w.PartitaIVA__c)) {
			l.CodiceCliente__c = w.PartitaIVA__c;
			if (e != null)
				w.ErrorMessage__c = e.abbreviate(131072);
		} 

		insert l;
	}

	/********************************************************************************************
	 * classi locali 
	 *******************************************************************************************/
	//Questionario Qualitativo
	public Class Domanda {
		public Integer codiceDatoDomanda;
		public String value;
		public String domanda;
		public Integer codiceModulo;
		public DominioRisposta[] dominio;
	}

	//Questionario Qualitativo
	@TestVisible
	public Class DominioRisposta {
		public String value;
		public String label;
	}
}