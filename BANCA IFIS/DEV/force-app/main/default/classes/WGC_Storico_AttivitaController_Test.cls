@isTest
public class WGC_Storico_AttivitaController_Test {
	@isTest
    public static void test_storicoAll(){
        
        WGC_AllDataFactory.disattivaTrigger();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(3,true);

        Test.startTest();
        WGC_Storico_AttivitaController.getAllData(listAcc.get(0).Id);
        WGC_Storico_AttivitaController.getUserInfo();
        WGC_Storico_AttivitaController.getselectOptions(listAcc.get(0), 'BillingStreetType__c');
        Test.stopTest();

    }
}