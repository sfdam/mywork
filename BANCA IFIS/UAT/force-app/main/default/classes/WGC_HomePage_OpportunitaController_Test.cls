@isTest
public class WGC_HomePage_OpportunitaController_Test {
    @isTest
	public static void Test_getUserInfo(){
        // il test funziona anche senza aggiungere liste di Account, Event, Opportunity ecc.
        WGC_New_Business__c nb = new WGC_New_Business__c();
        insert nb;
        Test.startTest();
        WGC_HomePage_OpportunitaController.getUserInfo();
        Test.stopTest();
    }

    @isTest
	public static void Test_getUserInfo2(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IFIS - Direzione Commerciale']; 
        User u = new User(Alias = 'TestIFIS', Email='TestIFIS@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS@testorg.com');
        insert u;
        Test.startTest();
        System.runAs(u) {
        // runna il codice come utente u
            
        WGC_HomePage_OpportunitaController.getUserInfo();

        }
         Test.stopTest();
    }
}