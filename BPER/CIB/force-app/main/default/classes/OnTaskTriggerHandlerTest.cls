@IsTest
public class OnTaskTriggerHandlerTest {
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
        Task t = new Task();
        t.whatId= [SELECT Id FROM Case WHERE Subject='First'][0].Id;
        t.Subject='Test';
        t.Status= 'Not Started';
        t.Priority='Normal';

        Task t1 = new Task();
        t1.whatId= [SELECT Id FROM Case WHERE Subject='Second'][0].Id;
        t1.Subject='Test';
        t1.Status= 'Not Started';
        t1.Priority='Normal';

        Test.startTest();
        insert t;
        insert t1;
        t.whatId=[SELECT Id FROM Case WHERE Subject='Second'][0].Id;
        update t;
        t1.whatId=[SELECT Id FROM Case WHERE Subject='third'][0].Id;
        update t1;
        t1.whatId=[SELECT Id FROM Case WHERE Subject='First'][0].Id;
        update t1;
        delete t;
        Test.stopTest();
    }
}