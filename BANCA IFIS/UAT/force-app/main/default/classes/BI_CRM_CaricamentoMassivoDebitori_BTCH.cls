global class BI_CRM_CaricamentoMassivoDebitori_BTCH implements Database.Batchable<Account>, Database.AllowsCallouts, Database.Stateful {

	public List<Account> scope;
	public Integer debitoriProcessati = 0;

	global List<Account> start(Database.BatchableContext bc) {
		this.scope = [SELECT Id, Tag_Caricamento__c FROM Account WHERE Tag_Caricamento__c like 'DEBITORE%' LIMIT 10];
		return this.scope;
	}

	global void execute(Database.BatchableContext bc, List<Account> scope) {
		if (scope.size() > 0) {
			debitoriProcessati = debitoriProcessati + 1;
			System.debug('@@@@ BI - identificato carico massivo debitori');
			//call out jobs
			System.enqueueJob(new AsyncJobs_Q(scope));
		}
	}

	global void finish(Database.BatchableContext bc) {
		// Email list to notify
		try {

			Parametri_Schedulazioni__c schedulazioniParameters = Parametri_Schedulazioni__c.getInstance();
			String destinationMail = schedulazioniParameters.Mail_Gestori_Schedulazioni__c;

			OrgWideEmailAddress owa = [SELECT id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'CRM Multicanalità' limit 1];

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] { destinationMail };
			mail.setOrgWideEmailAddressId(owa.Id);
			mail.setToAddresses(toAddresses);
			mail.setSubject('CRM e Multicanalità - Batch "Carico Massivo Debitori" concluso');
			mail.setBccSender(false);
			mail.setUseSignature(false);

			String body = 'Il Batch "Carico Massivo Debitori" si è concluso. \n';
			body += 'Numero Debitori processati: ' + this.debitoriProcessati + '\n';
			body += 'SFDC Instance: ' + System.URL.getSalesforceBaseUrl().toExternalForm();
			mail.setPlainTextBody(body);

			String htmlBody = '<p>Il Batch "Carico Massivo Debitori" si è concluso.</p>';
			htmlBody += '<p>Numero Debitori processati: ' + this.debitoriProcessati + '</p>';
			htmlBody += '<p>SFDC Instance: ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '</p>';
			mail.setHtmlBody(htmlBody);

			if(!Test.isRunningTest() && this.debitoriProcessati > 0){
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			}
		}

		catch(Exception ex) {
			System.debug('Eccezione in fase di invio mail per la procedura di Carico Massivo Debitori');
		}
	}

	@TestVisible
	public class AsyncJobs_Q implements Queueable, Database.AllowsCallouts {

		List<Account> accs;

		public AsyncJobs_Q(List<Account> accs) {
			this.accs=accs;
		}

		public void execute(QueueableContext context) {
			for(Account acc : accs) {
				System.debug('@@@@ BI - richieste dati per accountId: ' + acc.Id);

				//Richiesta Eventi Negativi
				WGC_Account_Utility_Controller.WrapperResponse resultEventi = WGC_Account_Utility_Controller.callServiceEventiNegativi(acc.Id);
				System.debug('@@@@ BI - risultato Eventi Negativi: ' + resultEventi);

				//Richiesta Bilanci in modalità Future
				richiestaBilanciRibesFuture(acc.Id, 'Civilistico');
				
				if (!acc.Tag_Caricamento__c.equalsIgnoreCase('DEBITORE_NO_CR')) {
					System.debug('@@@@ BI - richiedo prima info CR per accountId: ' + acc.Id);
					richiestaPrimaInfoCR(acc.Id);
				} else {
					System.debug('@@@@ BI - prima info CR NON richiesta per accountId: ' + acc.Id);
				}
				//elimino TAG debitore
				acc.Tag_Caricamento__c = '';   
				update acc;   
			}
		}
	}

	@Future(callout=true)
	public static void richiestaBilanciRibesFuture(Id acc, String tipoBilancio) {
				//Richiesta Bilanci
				WGC_Account_Utility_controller.ResponseBilancio resultBilancio = WGC_Account_Utility_controller.getBilancioRibes(acc, tipoBilancio);
				System.debug('@@@@ BI - risultato richiesta Bilanci: ' + resultBilancio);
	
	}
			
	public static void richiestaPrimaInfoCR(String accountId) {
		Account acc = [SELECT Id, NDGGruppo__c, NaturaGiuridica__c, WGC_DataRichiestaCR__c, WGC_Area__c FROM Account WHERE Id = :accountId];
        List<WGC_Centrale_Rischi__c> cr = new List<WGC_Centrale_Rischi__c>();
        cr = [SELECT Id, Data_ultima_rilevazione__c FROM WGC_Centrale_Rischi__c WHERE Anagrafica__c = :acc.Id ORDER BY Data_ultima_rilevazione__c DESC LIMIT 1];
        Integer ggValidCR = Integer.valueOf(Impostazioni__c.getInstance().WGC_Giorni_Validit_CR__c);
        try {
			if ((cr.size() > 0 && cr[0] != null && cr[0].Data_ultima_rilevazione__c.daysBetween(Date.today()) < ggValidCR) || acc.WGC_Area__c == 'EE')
				return;

			if (acc.NaturaGiuridica__c == 'DI') { // SE DITTA INDIVIDUALE ALLORA PRIMA INFO CR SU TITOLARE EFFETTIVO
				List<AccountContactRelation> acrs = new List<AccountContactRelation>();
				acrs = [SELECT Id, ContactId, WGC_Ruolo__c, Contact.NDGGruppo__c, Contact.WGC_DataRichiestaCR__c FROM AccountContactRelation WHERE AccountId = :acc.Id AND WGC_Ruolo__c != null AND Contact.NDGGruppo__c != null ORDER BY CreatedDate ASC];

				if (acrs.size() > 0) { // ALMENO UNA ASSOCIAZIONE ANAGRAFICA-REFERENTE; REFERENTE CON NDG E RUOLO
					AccountContactRelation acr = acrs[0];
					Contact cnt = new Contact(Id = acr.ContactId);
                            
					if (acr.WGC_Ruolo__c.contains('U')) {

						if (acr.Contact.WGC_DataRichiestaCR__c != null && Date.newinstance(acr.Contact.WGC_DataRichiestaCR__c.year(), acr.Contact.WGC_DataRichiestaCR__c.month(), acr.Contact.WGC_DataRichiestaCR__c.day()).daysBetween(Date.today()) < ggValidCR) { // SE ULTIMA RICHIESTA PER NDG MINORE DI 2 MESI FA, ALLORA SKIPPO
							System.debug('@@@@ BI - ultima richiesta Prima Info CR MINORE di 2 mesi per NDG: ' + acr.Contact.NDGGruppo__c);
							return;
						}

						WizardOpportunityController.callInfoCRAsync(acr.Contact.NDGGruppo__c);

						cnt.WGC_DataRichiestaCR__c = Datetime.now();
						acc.WGC_DataRichiestaCR__c = Datetime.now();

						update cnt;
						
						System.debug('@@@@ BI - richiesta Prima Info CR: ' + acr.Contact.NDGGruppo__c);
					}
				}
			} else {      
				if (acc.WGC_DataRichiestaCR__c != null && Date.newinstance(acc.WGC_DataRichiestaCR__c.year(), acc.WGC_DataRichiestaCR__c.month(), acc.WGC_DataRichiestaCR__c.day()).daysBetween(Date.today()) < ggValidCR) { // SE ULTIMA RICHIESTA PER NDG MINORE DI 2 MESI FA, ALLORA SKIPPO
					System.debug('@@@@ BI - ultima richiesta Prima Info CR MINORE di 2 mesi per NDG: ' + acc.NDGGruppo__c);
					return;
				}
				
				WizardOpportunityController.callInfoCRAsync(acc.NDGGruppo__c);

				acc.WGC_DataRichiestaCR__c = Datetime.now();

				System.debug('@@@@ BI - richiesta Prima Info CR: ' + acc.NDGGruppo__c);
			}  
			update acc;

        } catch (Exception e) {
            System.debug('@@@@ BI - richiesta Prima Info CR: ERROR: ' + e.getStackTraceString() + ' --- ' + e.getMessage());
        }
    }
}