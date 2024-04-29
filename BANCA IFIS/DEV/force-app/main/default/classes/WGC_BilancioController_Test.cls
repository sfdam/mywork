@isTest
public with sharing class WGC_BilancioController_Test {

    @isTest
    public static void Test_Metodi(){

        //Account a = WGC_AllDataFactory.createAccount(1,true).get(0);  SV: Ho Sicuramente sbagliato qualcosa per questo tes
        TestUtils.impostaCS();
        Account a = TestUtils.creaAccount('Test');
        Test.startTest();
        WGC_BilancioController.callBilancioSpecial(a.id,'Definitivo');
        WGC_BilancioController.getAllDatiBilancio(a.id,'Definitivo');
        Test.stopTest();
    }

}