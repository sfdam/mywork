@isTest
public class WGC_HomePage_Mie_Attivita_FD_Test {

    @TestSetup
    public static void makeData(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createImpostazioni();

        UserRole ur =[SELECT DeveloperName,Id FROM UserRole WHERE DeveloperName = 'ResponsabileFiloDiretto'];
        Profile p = [SELECT Id FROM Profile WHERE Name='IFIS - Filo Diretto']; 
        User u = new User(Alias = 'IFIS_FD', Email='TestIFIS@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS@testorg.com', WGC_Team_Filo_Diretto__c = 'New Team', Qualifica_Utente__c = 'Filo Diretto');
        u.UserRole=ur;
        Insert u;

        List<WGC_Andamentale__c> andList = WGC_AllDataFactory.createAndamentale(3, u);

        System.runAs(u){ Insert andList; }
    }

    
    @isTest
    public static void getDatiGraficoAziende_Test(){    

        Test.startTest();
            User u = [SELECT Id, Name FROM User WHERE Alias = 'IFIS_FD' LIMIT 1];
            WGC_HomePage_Mie_Attivita_FD_Controller.getDatiGraficoAziende(true);
            WGC_HomePage_Mie_Attivita_FD_Controller.getDatiGraficoAziende(false);

            WGC_HomePage_Mie_Attivita_FD_Controller.getDatiGraficoAziende_Filtered(String.valueOf(u.Id), '', false);
            WGC_HomePage_Mie_Attivita_FD_Controller.getDatiGraficoAziende_Filtered('', 'New Team', false);
            WGC_HomePage_Mie_Attivita_FD_Controller.getDatiGraficoAziende_Filtered('', '', true);
        Test.stopTest();
    }

    @isTest
    public static void getDatiGraficoCommerciali_Test(){    

        Test.startTest();
                User u = [SELECT Id, Name FROM User WHERE Alias = 'IFIS_FD' LIMIT 1];
            WGC_HomePage_Mie_Attivita_FD_Controller.getDatiGraficoCommerciali(true);
            WGC_HomePage_Mie_Attivita_FD_Controller.getDatiGraficoCommerciali(false);

            WGC_HomePage_Mie_Attivita_FD_Controller.getDatiGraficoCommerciali_Filtered(String.valueOf(u.Id), '', false);
            WGC_HomePage_Mie_Attivita_FD_Controller.getDatiGraficoCommerciali_Filtered('', 'New Team', false);
            WGC_HomePage_Mie_Attivita_FD_Controller.getDatiGraficoCommerciali_Filtered('', '', true);
        Test.stopTest();
    }
}