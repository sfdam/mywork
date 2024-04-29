@isTest
public with sharing class WGC_Bussiness_DetailController_Test {
    @isTest
    public static void Test_Metodi1(){

        // WGC_AllDataFactory.disattivaTrigger();
        // WGC_AllDataFactory.createOpportunity(5,true);
        // WGC_AllDataFactory.createAccount(5,true);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='IFIS - Direzione Commerciale']; 
        User u = new User(Alias = 'TestIFIS', Email='TestIFIS@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS@testorg.com');
        insert u;
        Test.startTest();
        System.runAs(u) {
        // runna il codice come utente u
            
            WGC_Bussiness_DetailController.getAllData();
           
        }
         Test.stopTest();

        
        
    }
    @isTest
    public static void Test_Metodi2(){
            Test.startTest();
            WGC_Bussiness_DetailController.getAllData();
            Test.stopTest();
    }

}