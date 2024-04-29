@isTest
public class WGC_HomePage_New_BusinessController_Test {
	@isTest
    public static void Test_getUserInfo(){
        // il test funziona anche senza aggiungere liste di Account, Event, Opportunity ecc.
        Test.startTest();
        WGC_HomePage_New_BusinessController.getUserInfo();
        Test.stopTest();
    }
    
    @isTest
    public static void Test_getUserInfoError(){
        // SV: Riuscire a trovare il modo di mandare in errore la classe WGC_HomePage_New_BusinessController
        Test.startTest();
        Test.stopTest();
    }
}