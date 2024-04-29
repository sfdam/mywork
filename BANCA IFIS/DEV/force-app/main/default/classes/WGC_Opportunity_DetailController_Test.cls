@isTest
public class WGC_Opportunity_DetailController_Test {
    @isTest
    public static void Test_WGC_Opportunity_DetailController1(){
        WGC_AllDataFactory.disattivaTrigger();
        //List<Account> listAcc = WGC_AllDataFactory.createAccount(10,true);
        List<Opportunity> listAcc = WGC_AllDataFactory.createOpportunity(10,true);
        /*Test.startTest();
        WGC_Opportunity_DetailController.getAllData();
        Test.stopTest();*/

        Profile p = [SELECT Id FROM Profile WHERE Name='IFIS - Direzione Commerciale'];
        Profile pFD = [SELECT Id FROM Profile WHERE Name='IFIS - Filo Diretto'];

        User u = new User(Alias = 'TestIFIS', Email='TestIFIS@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS@testorg.com');
        insert u;

        User uFD = new User(Alias = 'TestIFI2', Email='TestIFIS22@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing22', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = pFD.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS22@testorg.com');
        insert uFD;

        Test.startTest();
        System.runAs(u) {
        // runna il codice come utente u        
        WGC_Opportunity_DetailController.getAllData();
        }

        System.runAs(uFD){
            WGC_Opportunity_DetailController.getAllData();
        }
        Test.stopTest();
    }

    @isTest
    public static void Test_WGC_Opportunity_DetailController2(){
        WGC_AllDataFactory.disattivaTrigger();
        //List<Account> listAcc = WGC_AllDataFactory.createAccount(10,true);
        List<Opportunity> listAcc = WGC_AllDataFactory.createOpportunity(10,true);
        Test.startTest();
        WGC_Opportunity_DetailController.getAllData();
        Test.stopTest();
    }
}