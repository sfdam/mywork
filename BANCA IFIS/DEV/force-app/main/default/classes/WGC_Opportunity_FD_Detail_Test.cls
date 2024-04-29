@isTest
public class WGC_Opportunity_FD_Detail_Test {

    @TestSetup
    static void makeData(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createImpostazioni();

        UserRole ur =[SELECT DeveloperName,Id FROM UserRole WHERE DeveloperName = 'ResponsabileFiloDiretto'];
        UserRole urComm =[SELECT DeveloperName,Id FROM UserRole WHERE DeveloperName = 'AltaDirezione'];

        Profile p = [SELECT Id FROM Profile WHERE Name='IFIS - Filo Diretto'];
        Profile PComm = [SELECT Id FROM Profile WHERE Name = 'IFIS - Sviluppo Commerciale Filiali'];

        User u = new User(Alias = 'IFIS_FD', Email='TestIFIS_FD@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingFD', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS_FD@testorg.com', NDGGruppo__c = '1234567899', WGC_Team_Filo_Diretto__c = 'New Team', Qualifica_Utente__c = 'Filo Diretto');
        u.UserRole=ur;
        Insert u;

        User u2 = new User(Alias = 'IFIS_CM', Email='TestIFIS@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pComm.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS@testorg.com', NDGGruppo__c = '1234567119', Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali');
        u2.UserRole=urComm;
        Insert u2;

        // List<Account> accList = WGC_AllDataFactory.createAccount(1);
        // Insert accList;

        List<Task> tList = WGC_AllDataFactory.createTask(1);
        Insert tList;

        List<WGC_Dettaglio_Visite__c> dtList = WGC_AllDataFactory.createDettaglioVisite(3, u, u2);
        Insert dtList;
    }

    @isTest
    public static void getAllData_Test(){
        Test.startTest();
        User u = [SELECT Id, Name FROM User WHERE Alias = 'IFIS_FD'];

        System.runAs(u){
            WGC_Opportunity_FD_DetailController.getAllData();

            //Dummy Test
            WGC_Opportunity_FD_DetailController.getUserInfo();
            WGC_Opportunity_FD_DetailController.getselectOptions_User();
            WGC_Opportunity_FD_DetailController.Filter f = new WGC_Opportunity_FD_DetailController.Filter();
            WGC_Opportunity_FD_DetailController.Filter f2 = new WGC_Opportunity_FD_DetailController.Filter('test','test');
            WGC_Opportunity_FD_DetailController.FilterGroup fg = new WGC_Opportunity_FD_DetailController.FilterGroup();
            WGC_Opportunity_FD_DetailController.FilterGroup fg2 = new WGC_Opportunity_FD_DetailController.FilterGroup('test', new List<WGC_Opportunity_FD_DetailController.Filter>());
        }
        
        Test.stopTest();
    }
}