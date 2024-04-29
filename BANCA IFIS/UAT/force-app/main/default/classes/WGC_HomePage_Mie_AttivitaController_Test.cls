@isTest
public class WGC_HomePage_Mie_AttivitaController_Test {
    @isTest
    public static void Test_getActivityUser(){
        // il test funziona anche senza aggiungere liste di Event e Task.
   		WGC_HomePage_Mie_AttivitaController.getActivityUser();
    }
    @isTest
    public static void Test_getActivityUserError(){
        // SV: Riuscire a trovare il modo di mandare in errore la classe WGC_HomePage_Mie_AttivitaController
        WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createAccount(1,true);
        Test.startTest();
        WGC_HomePage_Mie_AttivitaController.getActivityUser();
        Test.stopTest();
        //WGC_HomePage_Mie_AttivitaController.getActivityUser();
        
    }
	
    @isTest
    public static void Test_getActivityUser2(){
        WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createAccount(10,true);
        Profile p = [SELECT Id FROM Profile WHERE Name='IFIS - Direzione Commerciale']; 
        User u = new User(Alias = 'TestIFIS', Email='TestIFIS@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS@testorg.com');
        insert u;
        Test.startTest();
        System.runAs(u) {
        // runna il codice come utente u
            
            WGC_HomePage_Mie_AttivitaController.getActivityUser();

        }
         Test.stopTest();
       
    }
	
    
}