@isTest 
private class BI_COM_NotificaAccount_TEST {

	@isTest(SeeAllData=true)
	private static void postNotifica() {

		Test.startTest();

			RestRequest request = new RestRequest(); 
			RestResponse response = new RestResponse();

			request.requestUri = URL.getOrgDomainUrl() + '/services/apexrest/notificaAccount';

			RestCommon.TechInfo techInfo = new RestCommon.TechInfo();

			BI_COM_NotificaAccount_REST.AllegaNotificaInputPayload payload = new BI_COM_NotificaAccount_REST.AllegaNotificaInputPayload();
			 
			payload.chiaveDiRicerca = '100666';
			payload.testo = 'Notifica di test';
			payload.tipologiaNotifica = 'CHATTER';

			request.httpMethod = 'POST';
			request.addHeader('Content-Type', 'application/json'); 

			RestContext.request = request;
			RestContext.response = response;

			BI_COM_NotificaAccount_REST.allegaNotifica(techInfo, payload);

		Test.stopTest();   

	}
}