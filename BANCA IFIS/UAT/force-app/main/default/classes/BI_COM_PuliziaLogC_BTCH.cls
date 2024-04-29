global class BI_COM_PuliziaLogC_BTCH implements Database.Batchable<Log__c>, Database.Stateful {

    Integer numberOfQueryRecords;
	Integer numberOfProcessedRecords;
	String processingResult;
	List<Log__c> scope;

	global BI_COM_PuliziaLogC_BTCH() {

        this.numberOfQueryRecords = 0;
		this.numberOfProcessedRecords = 0;
		this.processingResult = '--';
	}

	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set as a QueryLocator object that will be batched for execution
	 */
	global List<Log__c> start(Database.BatchableContext context) {

		List<Log__c> actualLogs = new List<Log__c> ();

		actualLogs = [SELECT id, Name FROM Log__c WHERE CreatedDate<LAST_N_DAYS : 180 order by CreatedDate ASC LIMIT 49000];

        this.numberOfQueryRecords = actualLogs.size();
        
		return actualLogs;

	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */
	global void execute(Database.BatchableContext context, List<Log__c> scope) {

		try {

			Database.delete(scope);

			this.numberOfProcessedRecords += scope.size();

			this.processingResult = 'OK'; 

		}
		catch(Exception exc) {

			System.debug('Eccezione in fase di Pulizia della Log__c');

			this.processingResult = 'KO';

		}

	}

	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */
	global void finish(Database.BatchableContext bc) {

		try {

			Parametri_Schedulazioni__c schedulazioniParameters = Parametri_Schedulazioni__c.getInstance();
			String destinationMail = schedulazioniParameters.Mail_Gestori_Schedulazioni__c;
			String sourceMail = schedulazioniParameters.Mail_Mittente__c;

			OrgWideEmailAddress owa = [SELECT id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'CRM Multicanalità' limit 1];

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

			String[] toAddresses = new String[] { destinationMail };

			mail.setOrgWideEmailAddressId(owa.Id);

			mail.setToAddresses(toAddresses);

			mail.setSubject('CRM e Multicanalità - Batch "PuliziaLogC" concluso con esito: ' + this.processingResult);

			mail.setBccSender(false);

			mail.setUseSignature(false);

			String body = 'Il Batch "PuliziaLogC" concluso con esito: ' + this.processingResult + '\n';
			body += 'Numero record candidati: ' + this.numberOfQueryRecords + '\n';
			body += 'Numero record processati: ' + this.numberOfProcessedRecords + '\n';            
			body += 'SFDC Instance: ' + System.URL.getSalesforceBaseUrl().toExternalForm();
			mail.setPlainTextBody(body);

			String htmlBody = '<p>Il Batch "PuliziaLogC" concluso con esito: ' + this.processingResult + '</p>';
			htmlBody += '<p>Numero record candidati: ' + this.numberOfQueryRecords + '</p>';
			htmlBody += '<p>Numero record processati: ' + this.numberOfProcessedRecords + '</p>';            
			htmlBody += '<p>SFDC Instance: ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '</p>';
			mail.setHtmlBody(htmlBody);

			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

		}

		catch(Exception ex) {

			System.debug('Eccezione in fase di invio mail per la procedura di Pulizia Log');

		}

	}
}