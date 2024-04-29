@isTest
public class WGC_HomePage_MieiSuccessi_FD_Test {

    @TestSetup
    static void makeData(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createImpostazioni();

        UserRole ur =[SELECT DeveloperName,Id FROM UserRole WHERE DeveloperName = 'ResponsabileFiloDiretto'];
        Profile p = [SELECT Id FROM Profile WHERE Name='IFIS - Filo Diretto']; 
        User u = new User(Alias = 'IFIS_FD', Email='TestIFIS@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS@testorg.com', WGC_Team_Filo_Diretto__c = 'New Team');
        u.UserRole=ur;
        Insert u;

        List<Task> tList = WGC_AllDataFactory.createTask(4);

        tList[0].Subject = 'Contatto Telefonico';
        tList[1].Subject = 'Contatto Telefonico';
        tList[2].Subject = 'Ricontatto Telefonico';

        // tList[3].

        List<WGC_Andamentale__c> andamentaleList = WGC_AllDataFactory.createAndamentale(4,u);

        System.runAs(u){ 
            Insert tList;
            Insert andamentaleList;
        }
    }

    @isTest
    public static void getData_Test(){

        User u = [SELECT Id, Name, WGC_Team_Filo_Diretto__c FROM User WHERE Alias = 'IFIS_FD'];

        Test.startTest();

        System.runAs(u){
            WGC_HomePage_MieiSuccessi_FD_Controller.getData(true);
            WGC_HomePage_MieiSuccessi_FD_Controller.getData(false);

            WGC_HomePage_MieiSuccessi_FD_Controller.getDataFiltered(String.valueOf(u.Id), '', false);
            WGC_HomePage_MieiSuccessi_FD_Controller.getDataFiltered('', 'New Team', false);
            WGC_HomePage_MieiSuccessi_FD_Controller.getDataFiltered('', '', true);

            //Dummy Test
            WGC_HomePage_MieiSuccessi_FD_Controller.GraphData g = new WGC_HomePage_MieiSuccessi_FD_Controller.GraphData();
        }
        
        Test.stopTest();
    }

}