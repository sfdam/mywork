@isTest
public class BI_COM_Leads_TEST  {

	@isTest
	public static void postLead() {

		Test.startTest();

			RestRequest request = new RestRequest(); 
			RestResponse response = new RestResponse();

			request.requestUri = URL.getOrgDomainUrl() + '/services/apexrest/leads';

			RestCommon.TechInfo techInfo = new RestCommon.TechInfo();

			BI_COM_Leads_REST.AcquisisciLeadInputPayload payload = new BI_COM_Leads_REST.AcquisisciLeadInputPayload();
			 
			payload.nome = 'Marco';
			payload.cognome = 'Bonin';
			payload.ragioneSociale = 'BMT Snc';
			payload.partitaIva = '1122334455';
			payload.messaggio = 'Prova da classe di test'; 
			payload.ifisFormId = '23';
			payload.ifisFormIdUnivoco = '326afa41046232e2c1b9efbdc63559';
			payload.tipologiaClienti = '2';

			request.httpMethod = 'POST';
			request.addHeader('Content-Type', 'application/json'); 

			RestContext.request = request;
			RestContext.response = response;

			BI_COM_Leads_REST.acquisisciLead(techInfo, payload);

		Test.stopTest();   

	}

}