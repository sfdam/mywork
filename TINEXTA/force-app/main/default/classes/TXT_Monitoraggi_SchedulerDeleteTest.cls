@isTest
public without sharing class TXT_Monitoraggi_SchedulerDeleteTest {

    @isTest
    static void test1(){
        Datetime dt = Datetime.now().addSeconds(5);
        String schedulazione = String.valueOf(dt.second()) + ' ' + String.valueOf(dt.minute()) + ' ' + String.valueOf(dt.hour()) + ' ' + String.valueOf(dt.day()) + ' ' + String.valueOf(dt.month()) + ' ? ' + String.valueOf(dt.year());
        // '0 12 11 11 NOV ? 2021'
        System.debug('@@@ s ' + schedulazione);
                    
        System.schedule('Innolva Monitoraggi - GetProdottoDaNota ' + 213 + dt, schedulazione, new TXT_Monitoraggi_Sched(new List<Map<String,String>>(), 213, '123'));

        Test.startTest();
            Database.executeBatch(new TXT_Monitoraggi_SchedulerDelete(''), 10);
        Test.stopTest();
    }

    @isTest
    static void test2(){
        Datetime dt = Datetime.now().addSeconds(5);
        String schedulazione = String.valueOf(dt.second()) + ' ' + String.valueOf(dt.minute()) + ' ' + String.valueOf(dt.hour()) + ' ' + String.valueOf(dt.day()) + ' ' + String.valueOf(dt.month()) + ' ? ' + String.valueOf(dt.year());
        // '0 12 11 11 NOV ? 2021'
        System.debug('@@@ s ' + schedulazione);
                    
        System.schedule('Innolva Monitoraggi - GetProdottoDaNota ' + 213 + dt, schedulazione, new TXT_Monitoraggi_Sched(new List<Map<String,String>>(), 213, '123'));

        Test.startTest();
            Database.executeBatch(new TXT_Monitoraggi_SchedulerDelete('SELECT Id FROM CronTrigger LIMIT 1'), 10);
        Test.stopTest();
    }
}