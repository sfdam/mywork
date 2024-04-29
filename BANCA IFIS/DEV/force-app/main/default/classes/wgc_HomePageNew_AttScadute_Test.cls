@isTest
private class wgc_HomePageNew_AttScadute_Test {

    @isTest
    static void testGetData() {
        RecordType contattoRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'ContattoTelefonicoDiretto' LIMIT 1];
        Task contattoTask = new Task(
            RecordTypeId = contattoRecordType.Id,
            Subject = 'Test Contatto Task',
            ActivityDate = Date.today().addDays(-1)
        );
        insert contattoTask;

        RecordType visitaRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'VisitaCommerciale' LIMIT 1];
        Datetime myDate = Datetime.newInstance(2008, 12, 1, 12, 30, 2);
        Event visitaEvent = new Event(
            RecordTypeId = visitaRecordType.Id,
            Subject = 'Test Visita Event',
            ActivityDate = Date.today().addDays(-1),
            ActivityDateTime = myDate,
            DurationInMinutes = 60
        );
        insert visitaEvent;

        RecordType promemoriaRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Promemoria' LIMIT 1];
        Task promemoriaTask = new Task(
            RecordTypeId = promemoriaRecordType.Id,
            Subject = 'Test Promemoria Task',
            ActivityDate = Date.today().addDays(-1),
            Status = 'In progress'
        );
        insert promemoriaTask;
        wgc_HomePageNew_AttScadute_Controller.WrapperData result = wgc_HomePageNew_AttScadute_Controller.getData();
    }
}