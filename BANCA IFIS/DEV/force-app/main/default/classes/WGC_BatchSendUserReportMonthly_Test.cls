@isTest
public class WGC_BatchSendUserReportMonthly_Test {
    @isTest
    static void unitTest() 
    {

        //inserisci user
        User user = [SELECT Id,Qualifica_Utente__c FROM User WHERE Id =: UserInfo.getUserId()];
        //Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        //User user = new User(LastName = 'LIVESTON',
        //                  FirstName='JASON',
        //                  Alias = 'jliv',
        //                  Email = 'jason.liveston@asdf.com',
        //                  Username = 'jason.liveston@asdf.com',
        //                  ProfileId = profileId.id,
        //                  TimeZoneSidKey = 'GMT'
        //);

        //system.debug(user);

        //inserisci custom setting
        Impostazioni__c setting = new Impostazioni__c();
        setting.Name = 'Id_Referente_Promemoria__c';
        setting.Id_Referente_Promemoria__c = user.id;
        insert setting;

        //trova record type
        Id taskRcId = [select Id from RecordType where SobjectType = 'Task' and DeveloperName = 'ContattoTelefonicoDiretto'].Id;
        Id eventRcId = [select Id from RecordType where SobjectType = 'Event' and DeveloperName = 'VisitaCommerciale'].Id;

        //inserisci task e eventi
        System.runAs(user)
        {
        Task task = new Task(RecordTypeId = taskRcId,  ActivityDate = Date.today().addDays(-31));
        Event event = new Event(DurationInMinutes = 60, RecordTypeId = eventRcId,  ActivityDateTime = Date.today().addDays(-31));
        insert task;
        insert event;
        }

        Test.startTest();
        WGC_Scheduler_BatchSendUserReportMonthly sched = new WGC_Scheduler_BatchSendUserReportMonthly ();   
         String chron = '0 0 3 * * ?';        
         System.schedule('Test Sched', chron, sched);
        Test.stopTest();
    }
}