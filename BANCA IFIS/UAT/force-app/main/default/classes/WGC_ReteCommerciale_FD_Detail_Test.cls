@isTest
public class WGC_ReteCommerciale_FD_Detail_Test {

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
    public static void getFiliali_Test(){
        Test.startTest();

        WGC_ReteCommerciale_FD_DetailController.getFiliali();

        Test.stopTest();
    }

    @isTest
    public static void getDatiTabella_Test(){
        Test.startTest();

        WGC_ReteCommerciale_FD_DetailController.getDatiTabella('Roma');
        List<WGC_ReteCommerciale_FD_DetailController.TableWrapper> twList = WGC_ReteCommerciale_FD_DetailController.getDatiTabellaTutteLeFiliali();

        //Dummy Test
        WGC_ReteCommerciale_FD_DetailController.TableWrapper tw = new WGC_ReteCommerciale_FD_DetailController.TableWrapper();
        WGC_ReteCommerciale_FD_DetailController.TableWrapper tw2 = new WGC_ReteCommerciale_FD_DetailController.TableWrapper('prova','test',1,1,1,1,1,1,1,1,1);

        Test.stopTest();
    }
}