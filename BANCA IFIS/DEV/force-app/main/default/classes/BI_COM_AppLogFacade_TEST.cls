@isTest 
private class BI_COM_AppLogFacade_TEST {

	@isTest
	private static void BI_COM_AppLogFacade_TEST_insertAppLog() {

        Test.startTest();

		    String shortDescription = 'This is an happy test!';

			BI_COM_AppLogFacade_CODE.insertAppLog(BI_COM_AppLogFacade_CODE.Threshold.DEBUG, BI_COM_AppLogFacade_TEST.class.getName(), '', shortDescription, '');
            
        Test.stopTest();

	}

}