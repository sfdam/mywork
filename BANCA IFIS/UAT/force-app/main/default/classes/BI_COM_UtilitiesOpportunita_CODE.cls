/**
* Progetto:         Revisione componenti core per CRM 2.0.
* Sviluppatore      Marco Bonin <marco.bonin@bancaifis.it>
* Descrizione:      Classe di utility per operazioni inerenti alle opportunità
*
*/

public class BI_COM_UtilitiesOpportunita_CODE  {

	/**
	 * crea opportunità e preimposta alcuni campi, si basa su custom setting per gestire operatività
	 * prodotto mutui mcc nsa ovvero pre-imposta alcune configurazioni opportunità-linea
	 */
	public static Opportunity preparaOpportunitaLIGHT(Account actualAccount) {
		
		RecordType oppRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'IFISOpportunitaFactoring' LIMIT 1];

		String cmDevName = 'Partner_Broker_NSA';
		WGC_Originator__mdt originatorMD = [
			SELECT Originator__c, Originator_dettaglio__c
			FROM WGC_Originator__mdt
			WHERE DeveloperName = :cmDevName
		];

		Opportunity actualOpportunity = new Opportunity();
		
		actualOpportunity.CloseDate = Date.today().addMonths(1);
		actualOpportunity.RecordTypeId = oppRecType.Id;
		actualOpportunity.AccountId = actualAccount.id;

		actualOpportunity.StageName = 'In Istruttoria';
		actualOpportunity.Tipologia_Opportunit__c = 'CONC'; //Nuova Concessione
		
		actualOpportunity.Originator__c = originatorMD.Originator__c;
		actualOpportunity.Originator_di_dettaglio__c = originatorMD.Originator_dettaglio__c;

		actualOpportunity.OwnerId = actualAccount.WGC_Specialista_Factoring__c;

		return actualOpportunity;
	}

}