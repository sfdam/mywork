@isTest
public without sharing class TXT_Monitoraggi_ScheduledTest {

    @TestSetup
    static void makeData(){

        EndpointServizi__c endpoints = new EndpointServizi__c(TXT_BusinessInformation__c = 'https://example.test');
        insert endpoints;
        UtenzeDefault__c credentials = new UtenzeDefault__c(TXT_Innolva_EndPoint_User__c='test',TXT_Innolva_EndPoint_Password__c='test');
        insert credentials;

        Funzionalita__c x = new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c=true;
        x.Disabilita_tutti_i_process_builder__c=true;
        insert x;

        List<Account> accs = TestDataFactory.createAccounts(2);
        accs[0].CCIAA_REA__c = '1690901';
        accs[0].CCIAA_CMK__c = 'MI';
        accs[0].Censimento_Manuale__c = false;
        accs[0].Data_Ultimo_Arricchimento__c = System.Today();
        accs[1].Censimento_Manuale__c = false;
        accs[1].Data_Ultimo_Arricchimento__c = System.Today();
        insert accs;
    }

    @isTest
    static void executeScheduleTest(){
        Test.setMock(HttpCalloutMock.class, new TXT_Monitoraggi_ScheduledMock(1));
        Datetime dt = Datetime.now().addSeconds(5);
        String schedulazione = String.valueOf(dt.second()) + ' ' + String.valueOf(dt.minute()) + ' ' + String.valueOf(dt.hour()) + ' ' + String.valueOf(dt.day()) + ' ' + String.valueOf(dt.month()) + ' ? ' + String.valueOf(dt.year());
        // '0 12 11 11 NOV ? 2021'
        System.debug('@@@ s ' + schedulazione);
                    
        System.schedule('Innolva Monitoraggi - GetProdottoDaNota ' + 213 + dt, schedulazione, new TXT_Monitoraggi_Sched(new List<Map<String,String>>(), 213, '123'));

        Test.startTest();
            TXT_Monitoraggi_Scheduled txt = new TXT_Monitoraggi_Scheduled();
            txt.execute(null);
        Test.stopTest();
    }

    @isTest
    static void executeScheduleTestKO(){
        Test.setMock(HttpCalloutMock.class, new TXT_Monitoraggi_ScheduledMock(2));
        Test.startTest();
            TXT_Monitoraggi_Scheduled txt = new TXT_Monitoraggi_Scheduled();
            txt.execute(null);
        Test.stopTest();
    }

    @isTest
    static void executeQueueableKO(){
        Test.setMock(HttpCalloutMock.class, new TXT_Monitoraggi_ScheduledMock(1));
        Datetime dt = Datetime.now().addSeconds(5);
        String schedulazione = String.valueOf(dt.second()) + ' ' + String.valueOf(dt.minute()) + ' ' + String.valueOf(dt.hour()) + ' ' + String.valueOf(dt.day()) + ' ' + String.valueOf(dt.month()) + ' ? ' + String.valueOf(dt.year());
        // '0 12 11 11 NOV ? 2021'
        System.debug('@@@ s ' + schedulazione);
                    
        System.schedule('Innolva Monitoraggi - GetProdottoDaNota ' + 213 + dt, schedulazione, new TXT_Monitoraggi_Sched(new List<Map<String,String>>(), 213, '123'));

        Test.startTest();
            TXT_Monitoraggi txt = new TXT_Monitoraggi(new List<Map<String,String>>(), 0, '123');
            txt.execute(null);
        Test.stopTest();
    }

}