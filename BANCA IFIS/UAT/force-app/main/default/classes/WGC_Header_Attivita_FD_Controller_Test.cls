@isTest
public class WGC_Header_Attivita_FD_Controller_Test {

    @TestSetup
    public static void makeData(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createImpostazioni();

        UserRole ur =[SELECT DeveloperName,Id FROM UserRole WHERE DeveloperName = 'ResponsabileFiloDiretto'];
        Profile p = [SELECT Id FROM Profile WHERE Name='IFIS - Filo Diretto']; 
        User u = new User(Alias = 'IFIS_FD', Email='TestIFIS@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS@testorg.com', WGC_Team_Filo_Diretto__c = 'Ifis Bulls');
        u.UserRole=ur;
        Insert u;

        List<Task> tList = WGC_AllDataFactory.createTask(3);

        RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Previsione_Avvio_Rapporto' AND SobjectType = 'Task'];

        tList[2].RecordTypeId = rt.Id;

        System.runAs(u){ Insert tList; }
    }

    @isTest
    public static void getTodayActivityUser_FD_Test(){    

        Test.startTest();
            User u = [SELECT Id, Name, WGC_Team_Filo_Diretto__c FROM User WHERE WGC_Team_Filo_Diretto__c != null LIMIT 1];
            System.debug('@@@ utente ' + u);

            WGC_Header_Attivita_FD_Controller.getTodayActivityUser_FD(true);
            WGC_Header_Attivita_FD_Controller.getTodayActivityUser_FD(false);

            WGC_Header_Attivita_FD_Controller.getTodayActivityUser_FD_Filtered(String.valueOf(u.Id),'', false);
            WGC_Header_Attivita_FD_Controller.getTodayActivityUser_FD_Filtered('', 'Ifis Bulls', false);
            WGC_Header_Attivita_FD_Controller.getTodayActivityUser_FD_Filtered('','', true);
        Test.stopTest();
    }

    @isTest
    public static void getPastActivityUser_FD_Test(){    

        Test.startTest();
            User u = [SELECT Id, Name, WGC_Team_Filo_Diretto__c FROM User WHERE WGC_Team_Filo_Diretto__c != null LIMIT 1];

            WGC_Header_Attivita_FD_Controller.getPastActivityUser_FD(true);
            WGC_Header_Attivita_FD_Controller.getPastActivityUser_FD(false);

            WGC_Header_Attivita_FD_Controller.getPastActivityUser_FD_Filtered(String.valueOf(u.Id),'', false);
            WGC_Header_Attivita_FD_Controller.getPastActivityUser_FD_Filtered('', 'Ifis Bulls', false);
            WGC_Header_Attivita_FD_Controller.getPastActivityUser_FD_Filtered('','', true);
        Test.stopTest();
    }

    @isTest
    public static void getTaskPrevisioneAvvioRapporto_Test(){
        Test.startTest();
            User u = [SELECT Id, Name, WGC_Team_Filo_Diretto__c FROM User WHERE WGC_Team_Filo_Diretto__c != null LIMIT 1];

            WGC_Header_Attivita_FD_Controller.getTaskPrevisioneAvvioRapporto(true);
            WGC_Header_Attivita_FD_Controller.getTaskPrevisioneAvvioRapporto(false);

            WGC_Header_Attivita_FD_Controller.getTaskPrevisioneAvvioRapporto_Filtered(String.valueOf(u.Id),'', false);
            WGC_Header_Attivita_FD_Controller.getTaskPrevisioneAvvioRapporto_Filtered('', 'Ifis Bulls', false);
            WGC_Header_Attivita_FD_Controller.getTaskPrevisioneAvvioRapporto_Filtered('','', true);
        Test.stopTest();
    }
}