/**
* Progetto:         Revisione componenti core per CRM 2.0.
* Sviluppatore      Marco Bonin <marco.bonin@bancaifis.it>
* Descrizione:      Classe di utility per l'inserimento di un log applicativo.
*
*/

public class BI_COM_AppLogFacade_CODE  {

	public enum Threshold {FATAL, ERROR, WARNING, DEBUG, INFO}

	public static String SMSG_REST_CALL = 'CHIAMATA AL SERVIZIO REST';

	public static void insertAppLog(Threshold threshold, String originator, String keyValue, String shortDescription, String stackTrace){
	
		try{

			AppLog__c appLogCandidate = new AppLog__c();

			appLogCandidate.Threshold__c = threshold.name();
			appLogCandidate.Originator__c = originator;
			appLogCandidate.KeyValue__c = keyValue;
			appLogCandidate.ShortDescription__c = shortDescription;
			appLogCandidate.StackTrace__c = stackTrace;

			insert appLogCandidate;

		}
		catch(Exception ex){
		
			System.debug('Errore inserimento in AppLog. Originator: ' + originator + ' Short Description: ' + shortDescription);

		}
	
	}

}