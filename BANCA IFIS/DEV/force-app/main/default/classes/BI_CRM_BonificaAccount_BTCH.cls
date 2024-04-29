global class BI_CRM_BonificaAccount_BTCH implements Database.Batchable<Account>, Database.AllowsCallouts {

	public List<Account> scope;
	public Map<Id,String> users;
	public List<String> log;
	public String utenza;
	public Integer utenzeBonificate = 0;
	public Integer utenzeFallite = 0;
	Boolean isSandbox;

	public BI_CRM_BonificaAccount_BTCH() {
		this.scope = new List<Account> ();
		this.log = new List<String> ();
		this.users = new Map<Id,String>();
		this.utenza = UtenzaBonifica__c.getInstance().Parametro__c;

		// E' una sandbox o si tratta della produzione ???
		Organization o = [SELECT IsSandbox FROM Organization LIMIT 1];
		if (o != null) {
			this.isSandbox = o.IsSandbox;
		} else {
			this.isSandbox = false; // se la select non da risultati allora prendo i dati del servizio, che in ambienti non prod dovrebbe avere i dati sensibili modificati
		}
	}


	global List<Account> start(Database.BatchableContext bc) {
		
		List<User> userList = new List<user>();
		userList = [SELECT Id, Name FROM User where IsActive = true];
		for (User userIdName : userList) {
			this.users.put(userIdName.Id,userIdName.Name);
		}
		
		if (Test.isRunningTest()){
			this.scope = [SELECT Id, Name, NDGGruppo__c, PIVA__c, Owner.Name, BillingPostalCode, ShippingPostalCode, BillingCity, ShippingCity, BillingState, ShippingState FROM Account WHERE Owner.Name = 'Utenza Default'];
		} else {
			this.scope = [SELECT Id, NDGGruppo__c, PIVA__c, Owner.Name, BillingPostalCode, ShippingPostalCode, BillingCity, ShippingCity, BillingState, ShippingState FROM Account WHERE Owner.Name = :this.utenza and CodiceIstituto3N__c = '881' and (not Name like 'Tribunale%') limit 30000];
		}
		return this.scope;
	}


	global void execute(Database.BatchableContext bc, List<Account> scope) {
		Account[] accs = new Account[] { };

		for (Account accScope : scope) {
			accs.add(accScope);
		}
		
		if (!accs.isEmpty()) {
			Set<String> caps = U.getSet(accs, 'ShippingPostalCode');
			Set<String> comuni = U.getSet(accs, 'ShippingCity');
			Set<String> provincie = U.getSet(accs, 'ShippingState');
			Map<String, Id> cap2owner = UtilAnagrafiche.getOwners(caps, comuni, provincie, false);
			Id utenzaDefault = UtenzeDefault__c.getInstance().IdUtente__c;
			for (Account a : accs) {
				Id ownerId = null;
				// Considero i campi nell'array "fields" nell'ordine in cui sono inseriti: al primo match prendo l'owner
				String[] fields = new String[] { 'BillingPostalCode_BillingCity', 'ShippingPostalCode_ShippingCity', 'BillingPostalCode', 'ShippingPostalCode', 'BillingCity', 'ShippingCity', 'BillingState', 'ShippingState' };
				for (String field : fields) {
					if (String.isBlank(field)) continue;
					String[] fieldList = field.split('_');
					String[] valueList = new String[] { };
					Boolean isOk = true;
					for (String f : fieldList) {
						String fValue = (String) a.get(f);
						if (String.isBlank(fValue)) {
							isOk = false;
						} else {
							valueList.add(fValue);
						}
					}
					String logAccount = '';
					String value = String.join(valueList, '_');
					if (isOk && cap2owner.containsKey(value)) {
						String ownerValue = cap2owner.get(value);
						if (String.isNotBlank(ownerValue)) {
							ownerId = ownerValue;
							break;
						}
					}
				}
				if (String.isNotBlank(ownerId)) {
					a.OwnerId = ownerId;
					String ownerName = users.get(ownerId);
					this.log.add('ID ' + a.Id + ' - ' + 'NDG ' + a.NDGGruppo__c + ' - ' + 'P.IVA ' + a.PIVA__c + ' - ' + 'COMM. ' + ownerName + ' - '  + a.OwnerId + ' \n');
					this.utenzeBonificate++;
				} else {
					a.OwnerId = utenzaDefault; 
					this.log.add('ID ' + a.Id + ' - ' + 'NDG ' + a.NDGGruppo__c + ' - ' + 'P.IVA ' + a.PIVA__c + ' - KO \n');
					this.utenzeFallite++;
				}
			}
			if (!Test.isRunningTest()){
				update accs;
			}
		}
	}

	global void finish(Database.BatchableContext bc) {
		// Email list to notify
		try {

			Parametri_Schedulazioni__c schedulazioniParameters = Parametri_Schedulazioni__c.getInstance();
			String destinationMail = schedulazioniParameters.Mail_Gestori_Schedulazioni__c;
			String sourceMail = schedulazioniParameters.Mail_Mittente__c;

			OrgWideEmailAddress owa = [SELECT id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'CRM Multicanalità' limit 1];

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] { destinationMail };
			mail.setOrgWideEmailAddressId(owa.Id);
			mail.setToAddresses(toAddresses);
			mail.setSubject('CRM e Multicanalità - Batch "CorrezioneOwnerId" concluso');
			mail.setBccSender(false);
			mail.setUseSignature(false);

			// CREAZIONE ALLEGATO
			List<String> inputArray = new List<String> ();
			String attachmentTextToSend = '';

			// SCARICO LISTA DI TEST
			for (String riga : this.log) {
				attachmentTextToSend = attachmentTextToSend + riga;
			}

            if(this.log.size() > 0){
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName('risultatoBatchCorrezioneOwnerId.txt');
                efa.setBody(Blob.valueOf(attachmentTextToSend));
    
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { efa });
            }

			String body = 'Il Batch "CorrezioneOwnerId" si è concluso \n';
			body += 'Numero record processati: ' + this.log.size() + '\n';
			body += 'Utenze bonificate: '+ this.utenzeBonificate + '\n';
			body += 'Utenze fallite: '+ this.utenzeFallite + '\n';
			body += 'SFDC Instance: ' + System.URL.getSalesforceBaseUrl().toExternalForm();
			mail.setPlainTextBody(body);

			String htmlBody = '<p>Il Batch "CorrezioneOwnerId" si è concluso</p>';
			htmlBody += '<p>Numero record processati: ' + this.log.size() + '</p>';
			htmlBody += 'Utenze bonificate: ' + this.utenzeBonificate + '</p>';
			htmlBody += 'Utenze fallite: ' + this.utenzeFallite + '</p>';
			htmlBody += '<p>SFDC Instance: ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '</p>';
			mail.setHtmlBody(htmlBody);

			if(!Test.isRunningTest()){
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			}
		}

		catch(Exception ex) {
			System.debug('Eccezione in fase di invio mail per la procedura di AllineamentoAnagrafiche');
		}
	}
}