@isTest 
public with sharing class ServiceAppointmentControllerTest {
    
    @TestSetup
    public static void setup(){
          
        Account account = AllDataFactory.getPersonAccount('01');
        insert account;

        ServiceAppointment servApp = new ServiceAppointment();
        servApp.Subject='Appuntamento call 1';
        servApp.SchedStartTime=Datetime.now();
        servApp.status='Programmato';
        servApp.ParentRecordId=account.id;
        insert servApp;
        
    }

    @IsTest
        static void getAllDataTest(){
            Test.startTest();
            Account ndg= [SELECT Id FROM Account WHERE Name='Person01' LIMIT 1];
            ServiceAppointmentController.getAllData(ndg.id);
            Test.stopTest();
            
        }

}