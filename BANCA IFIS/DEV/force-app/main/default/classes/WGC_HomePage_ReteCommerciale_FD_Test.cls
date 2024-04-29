@isTest
public class WGC_HomePage_ReteCommerciale_FD_Test {

    @TestSetup
    public static void makeData(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createImpostazioni();

        UserRole ur =[SELECT DeveloperName,Id FROM UserRole WHERE DeveloperName = 'ResponsabileFiloDiretto'];
        Profile p = [SELECT Id FROM Profile WHERE Name='IFIS - Filo Diretto']; 
        Profile p2 = [SELECT Id FROM Profile WHERE Name='IFIS - Sviluppo Commerciale Filiali'];

        User u = new User(Alias = 'IFIS_FD', Email='TestIFISFD@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingFD', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFISFD@testorg.com', WGC_Team_Filo_Diretto__c = 'New Team');
        u.UserRole=ur;
        Insert u;

        User uComm = new User(Alias = 'IFIS_CM', Email='TestIFIS@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p2.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS@testorg.com', Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali');
        uComm.UserRole=ur;
        Insert uComm;

        List<WGC_Dettaglio_Visite__c> dtList = WGC_AllDataFactory.createDettaglioVisite(4,u,uComm);

        Insert dtList;

    }

    @isTest
    public static void getBestAndBadFiliale_Test(){

        Test.startTest();

        WGC_HomePage_ReteCommerciale_FD.getBestAndBadFiliale();

        WGC_HomePage_ReteCommerciale_FD.Filiale f = new WGC_HomePage_ReteCommerciale_FD.Filiale('Test',1,true);
        WGC_HomePage_ReteCommerciale_FD.Filiale f1 = new WGC_HomePage_ReteCommerciale_FD.Filiale('Test1',2,true);
        f.compareTo(f);
        f1.compareTo(f);
        f.compareTo(f1);

        Test.stopTest();
    }
    
}