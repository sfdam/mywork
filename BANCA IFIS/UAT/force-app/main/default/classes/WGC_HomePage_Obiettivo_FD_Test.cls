@isTest
public class WGC_HomePage_Obiettivo_FD_Test {

    @TestSetup
    public static void makeData(){
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

        Account acc = [SELECT Id, Name FROM Account LIMIT 1];

        WGC_New_Business__c nb = new WGC_New_Business__c(Anagrafica__c = acc.Id, Data_New_Business__c = System.Today(), NDG_Settorista__c = u2.NDGGruppo__c);
        Insert nb;

        WGC_New_Business__c nb2 = new WGC_New_Business__c(Anagrafica__c = acc.Id, Data_New_Business__c = System.Today(), NDG_Filo_Diretto__c = u.NDGGruppo__c);
        Insert nb2;

        WGC_Budget__c budget = new WGC_Budget__c(Anno__c = String.valueOf(System.Today().Year()), Mese__c = String.valueOf(System.Today().Month()), OwnerId = u.Id);
        WGC_Budget__c budget2 = new WGC_Budget__c(Anno__c = String.valueOf(System.Today().Year()), Mese__c = String.valueOf(System.Today().Month()), OwnerId = u2.Id);

        System.runAs(u){
            Insert budget;
        }

        System.runAs(u2){
            Insert budget2;
        }
    }

    @isTest
    public static void getAllData_Test(){
        Test.startTest();
        User u = [SELECT Id, Name FROM User WHERE Alias = 'IFIS_FD'];

        System.runAs(u){
            WGC_HomePage_Obiettivo_FD_Controller.getAllData();
            WGC_HomePage_Obiettivo_FD_Controller.getAllData();
            WGC_HomePage_Obiettivo_FD_Controller.getUsersFD();
        }
        //Dummy test
        //WGC_HomePage_Obiettivo_FD_Controller.Results r = new WGC_HomePage_Obiettivo_FD_Controller.Results(0,0,0,0, new List<WGC_HomePage_Obiettivo_FD_Controller.GraphData>());
        //Integer i = WGC_HomePage_Obiettivo_FD_Controller.getWorkingDaysRemaining();
        //WGC_HomePage_Obiettivo_FD_COntroller.GraphData g = new WGC_HomePage_Obiettivo_FD_COntroller.GraphData();
        //WGC_HomePage_Obiettivo_FD_COntroller.GraphData g2 = new WGC_HomePage_Obiettivo_FD_COntroller.GraphData(1, 'Gennaio');
        //Integer i = WGC_HomePage_Obiettivo_FD_Controller.getWorkingDaysPassed();

        Test.stopTest();
    }
}