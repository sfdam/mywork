@isTest
public class WGC_HomePage_Sistema_IncController_Test {
    @isTest
    public static void Test_getSistemaIncentivante(){
        // il test funziona anche senza aggiungere liste di Account, Event, Opportunity ecc.
        Test.startTest();
        WGC_HomePage_Sistema_IncController.getSistemaIncentivante();
        WGC_HomePage_Sistema_IncController.getselectOptions(new Account(Name='Test'),'Name');
        Test.stopTest();
    }
}