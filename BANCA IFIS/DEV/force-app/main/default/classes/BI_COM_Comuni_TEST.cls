@isTest 
private class BI_COM_Comuni_TEST {

	@testSetup
	private static void BI_COM_ConversioneLead_TEST_setupDati() {

		insert BI_COM_UtilitiesSupportoTest_CODE.getComuni();

	}

	@isTest
	public static void getComuni() {

		Test.startTest();

			RestRequest request = new RestRequest(); 
			RestResponse response = new RestResponse();

			request.requestUri = URL.getOrgDomainUrl() + '/services/apexrest/comuni';
			System.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX '+ request.requestURI); 

			request.params.put('includiStorici', 'false');
			request.params.put('cap', '30175');

			request.httpMethod = 'GET';
			request.addHeader('Content-Type', 'application/json'); 

			RestContext.request = request;
			RestContext.response = response;

			BI_COM_Comuni_REST.getComuni();

		Test.stopTest();   

	}
}