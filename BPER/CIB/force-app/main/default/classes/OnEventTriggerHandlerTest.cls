@IsTest
public class OnEventTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        Case c1= new Case();
        c1.Origin='Web';
        c1.Subject='First';

        Case c2= new Case();
        c2.Origin='Web';
        c2.Subject='Second';

        Case c3= new Case();
        c3.Origin='Ufficio Reclami';
        c3.Subject='third';
        

        insert new List<Case>{c1,c2,c3};
    }

    @isTest
    static void testBehaviour(){
        Account a = new Account ();
        a.Name='TestName';
        insert a;

        Event e = new Event();
        e.whatId= [SELECT Id FROM Case WHERE Subject='First'][0].Id;
        e.DurationInMinutes=20;
        e.ActivityDateTime= Datetime.now();
        e.CRM_EventStatus__c='Non risponde 1';
        e.Subject='Incontro Preliminare';

        Event e1 = new Event();
        e1.whatId= e.whatId=[SELECT Id FROM Case WHERE Subject='Second'][0].Id;
        e1.DurationInMinutes=20;
        e1.ActivityDateTime= Datetime.now();
        e1.CRM_EventStatus__c='Non risponde 1';
        e1.Subject='Incontro Preliminare';

        Test.startTest();
        insert e;
        insert e1;
        e.whatId=[SELECT Id FROM Case WHERE Subject='Second'][0].Id;
        update e;
        e1.whatId=[SELECT Id FROM Case WHERE Subject='third'][0].Id;
        update e1;
        e1.whatId=[SELECT Id FROM Case WHERE Subject='First'][0].Id;
        update e1;

        delete e;
        Test.stopTest();
    }
}