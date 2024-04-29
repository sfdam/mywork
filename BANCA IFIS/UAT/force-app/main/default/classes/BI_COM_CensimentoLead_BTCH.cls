global class BI_COM_CensimentoLead_BTCH implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

	Set<Id> leadIds;

	global BI_COM_CensimentoLead_BTCH() { }
	global BI_COM_CensimentoLead_BTCH(Set<Id> leadIds) {
		this.leadIds = leadIds;
	}

	public Id actualLeadId;
	Lead actualLead = new Lead();

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(QueryBuilder.newInstance('Lead', new String[] {
			                            'Id',
			                            'IFISIdUnicoForm__c',
			                            'FirstName',
			                            'LastName',
			                            'RagioneSociale__c',
										'Name',
			                            'Phone',
                                        'MobilePhone',
			                            'Email',
			                            'PIVA__c',
			                            'TipoAccount__c',
			                            'State',
			                            'PostalCode',
			                            'Street',
			                            'City',
			                            'Tag__c',
			                            'CodiceOwner__c',
			                            'IFISForm__c',
			                            'Messaggio__c',
			                            'PrivacyMarketing__c', 
			                            'WGC_TAG_Controllante__c',
			                            'WGC_Canale_Di_Sviluppo__c',
			                            'WGC_Originator__c',
			                            'WGC_Originator_Dettaglio__c',
			                            'WGC_Tipo_Via__c',
			                            'WGC_Codice_Fiscale__c',
			                            'WGC_Sesso__c',
			                            'WGC_Specialista_Factoring__c',
			                            'WGC_Specialista_Filo_Diretto__c',
			                            'BI_StackTrace__c',
										'BI_Tipologia_Inserimento__c', 'BI_Tipo_Persona__c',
										'BI_NaturaGiuridica__c',
										'BI_TipoViaResidenzaLegale__c','BI_ViaResidenzaLegale__c','BI_CivicoResidenzaLegale__c','BI_CAPResidenzaLegale__c','BI_ComuneResidenzaLegale__c','BI_ProvinciaResidenzaLegale__c'
		                                })
		    .beginFilter()
		    .add('Status', QBOp.QEQUAL, 'Da censire')
		    .add('Id', QBOp.QIN, leadIds)
		    .endFilter()
		    .getQuery()
		);
	}

	global void execute(Database.BatchableContext BC, List<SObject> scope) {

		actualLead = (Lead) scope[0];

		  // VERIFICO CHE TIPO DI "PERSONA" SI ANDRA' A CENSIRE
		 
		if(actualLead.BI_Tipo_Persona__c == 'PG'){
		 
			// PROCEDO CON IL "CENSIMENTO LIGHT PER LA PG
		 
			Account newAccount = new Account();
		 
			// ARRICCHISCO L'ACCOUNT

			newAccount.Name = actualLead.RagioneSociale__c;
			newAccount.RagioneSociale__c = actualLead.RagioneSociale__c;
			newAccount.NaturaGiuridica__c = actualLead.BI_NaturaGiuridica__c;
			newAccount.BillingStreetType__c = actualLead.BI_TipoViaResidenzaLegale__c;
			newAccount.BillingStreetName__c = actualLead.BI_ViaResidenzaLegale__c;
			newAccount.BillingStreetNumber__c = (actualLead.BI_CivicoResidenzaLegale__c != null) ? actualLead.BI_CivicoResidenzaLegale__c.abbreviate(6) : null; //cedacri max len
			newAccount.BillingPostalCode = actualLead.BI_CAPResidenzaLegale__c;
			newAccount.BillingPostalCode__c = actualLead.BI_CAPResidenzaLegale__c;
			newAccount.BillingCity = actualLead.BI_ComuneResidenzaLegale__c;
			newAccount.BillingCity__c = actualLead.BI_ComuneResidenzaLegale__c;
			newAccount.BillingState = actualLead.BI_ProvinciaResidenzaLegale__c;
			newAccount.BillingState__c = actualLead.BI_ProvinciaResidenzaLegale__c;
			newAccount.BillingCountry = 'ITALIA';
			newAccount.BillingCountry__c = 'ITALIA';
			newAccount.CodiceIstituto3N__c = '881';
	 
			newAccount.TAG_Controllante__c = 'NB Inbound';
			newAccount.PIVA__c = actualLead.PIVA__c;
			newAccount.CF__c = actualLead.PIVA__c;
		 
			Id accountId;
			
			try{

				accountId = CtrlWizardAccount.WGC_insertAccount(newAccount, '', false, 'light', null);
		 
			}
			catch(Exception ex){
			
				String shortDescription = 'Non è stato possibile censire il lead per una anomalia di inserimento';

				BI_COM_AppLogFacade_CODE.insertAppLog(BI_COM_AppLogFacade_CODE.Threshold.ERROR, BI_COM_ConversioneLead_BTCH.class.getName(), '', shortDescription, '');

				actualLead.Status = 'Non qualificato';
				
				actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

				return;
			}

			// CENSIMENTO DELLA PG COMPLETATO, E' POSSIBILE PASSARE OLTRE
		 
		}

		if(actualLead.BI_Tipo_Persona__c == 'DI'){

			// PROCEDO CON IL "CENSIMENTO LIGHT PER LA DI
		 
			Account newAccount = new Account();
		 
			// ARRICCHISCO L'ACCOUNT

			newAccount.Name = actualLead.RagioneSociale__c;
			newAccount.RagioneSociale__c = actualLead.RagioneSociale__c;
			newAccount.NaturaGiuridica__c = actualLead.BI_NaturaGiuridica__c;
			newAccount.BillingStreetType__c = actualLead.BI_TipoViaResidenzaLegale__c;
			newAccount.BillingStreetName__c = actualLead.BI_ViaResidenzaLegale__c;
			newAccount.BillingStreetNumber__c = (actualLead.BI_CivicoResidenzaLegale__c != null) ? actualLead.BI_CivicoResidenzaLegale__c.abbreviate(6) : null; //cedacri max len;
			newAccount.BillingPostalCode = actualLead.BI_CAPResidenzaLegale__c;
			newAccount.BillingPostalCode__c = actualLead.BI_CAPResidenzaLegale__c;
			newAccount.BillingCity = actualLead.BI_ComuneResidenzaLegale__c;
			newAccount.BillingCity__c = actualLead.BI_ComuneResidenzaLegale__c;
			newAccount.BillingState = actualLead.BI_ProvinciaResidenzaLegale__c;
			newAccount.BillingState__c = actualLead.BI_ProvinciaResidenzaLegale__c;
			newAccount.BillingCountry = 'ITALIA';
			newAccount.BillingCountry__c = 'ITALIA';
			newAccount.CodiceIstituto3N__c = '881';
	
			newAccount.TAG_Controllante__c = 'NB Inbound';
			newAccount.PIVA__c = actualLead.PIVA__c;
			newAccount.CF__c = actualLead.WGC_Codice_Fiscale__c;
		 
			// CONDIZIONE NECESSARIA PER IL CENSIMENTO DI UNA DITTA INDIVIDUALE E' CHE CI SIA ANCHE UNA PERSONA FISICA

			Contact newContact = BI_COM_UtilitiesAnagrafiche_CODE.createNewContactFromLead(actualLead, newAccount);

			String shortDescription = 'E\' stato creato il contatto di referenza relativo al lead';

			actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

			Id accountId;
			
			try{

				accountId = CtrlWizardAccount.WGC_insertAccount(newAccount, '', false, 'light', newContact);
		 
			}
			catch(Exception ex){
			
				shortDescription = 'Non è stato possibile censire il lead per una anomalia di inserimento (' + ex.getMessage() + ')';

    			BI_COM_AppLogFacade_CODE.insertAppLog(BI_COM_AppLogFacade_CODE.Threshold.ERROR, BI_COM_ConversioneLead_BTCH.class.getName(), '', shortDescription, '');

				actualLead.Status = 'Non qualificato';
				
				actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

				actualLead.ConversionMessage__c = shortDescription;

				return;
			}
			
			// CENSIMENTO DELLA DI COMPLETATO, E' POSSIBILE PASSARE OLTRE
		 
		}

		actualLeadId = actualLead.Id;

		String shortDescription = 'Il lead è stato correttamente censito con NDG ed è pronto per essere qualificato';

		actualLead.BI_StackTrace__c = !String.isEmpty(actualLead.BI_StackTrace__c) ? actualLead.BI_StackTrace__c + '\n' + DateTime.now() + ' - ' + shortDescription : DateTime.now() + ' - ' + shortDescription;

		actualLead.Status = 'Da qualificare';

	}

	global void finish(Database.BatchableContext BC) {
	
		// DOPO IL CENSIMENTO LIGHT IL LEAD VIENE PORTATO NELLO STATO DA QUALIFICARE.
		// IN QUESTO MODO IL GIRO DI QUALIFICA TROVERA' UN NDG E PROCEDERA' ALLE NORMALI OPERAZIONI
		// DI QUALIFICA

		// IN CASO DI ERRORE VERRA' INVECE AGGIORNATO LO STACK TRACE

		update actualLead;

	}

}