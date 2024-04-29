@isTest
public class WGC_FilterUtility_FD_Test {

    @TestSetup
    static void makeData(){
        UserRole ur =[SELECT DeveloperName,Id FROM UserRole WHERE DeveloperName = 'ResponsabileFiloDiretto'];
        Profile p = [SELECT Id FROM Profile WHERE Name='IFIS - Filo Diretto']; 
        User u1 = new User(Alias = 'TestIFIS', Email='TestIFIS@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS@testorg.com', WGC_Team_Filo_Diretto__c = 'New Team');
        u1.UserRole=ur;
        insert u1;

        User u2 = new User(Alias = 'TestIFI2', Email='TestIFIS2@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS2@testorg.com', WGC_Team_Filo_Diretto__c = 'Ifis Bulls');
        u2.UserRole=ur;
        insert u2;
    }

    @isTest
    public static void test_method1(){
        Test.startTest();
        
        User u = WGC_FilterUtility_FD_Controller.getUserInfo();
        WGC_FilterUtility_FD_Controller.WrapperResponse response = WGC_FilterUtility_FD_Controller.getFilterValues();

        //Dummy Test
        WGC_FilterUtility_FD_Controller.Filter f = new WGC_FilterUtility_FD_Controller.Filter();
        WGC_FilterUtility_FD_Controller.FilterGroup fg = new WGC_FilterUtility_FD_Controller.FilterGroup();

        Test.stopTest();
    }
}