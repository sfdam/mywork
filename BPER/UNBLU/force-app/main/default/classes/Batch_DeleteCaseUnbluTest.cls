@IsTest
public class Batch_DeleteCaseUnbluTest {

    @TestSetup
    static void makeData(){
        Case c1= new Case();
        c1.Origin='Web';
        c1.Subject='First';
        c1.UnbluChatStatus__c='abandoned';

        Case c2= new Case();
        c2.Origin='Web';
        c2.Subject='Second';
        c2.UnbluChatStatus__c='abandoned';

        Case c3= new Case();
        c3.Origin='Ufficio Reclami';
        c3.Subject='third';
        c3.UnbluChatStatus__c='abandoned';
        insert new List<Case>{c1,c2,c3};
    }

    @IsTest
    static void testExecute() {
        Test.startTest();
        Batch_DeleteCaseUnblu b = new Batch_DeleteCaseUnblu();
        Database.executeBatch(b, 200); 
        Test.stopTest();
    }

    @IsTest
    static void testSchedulable() {
        Test.startTest();
        SchedulableContext sc = null;
        Batch_DeleteCaseUnblu b = new Batch_DeleteCaseUnblu();
        b.execute(sc);
        Test.stopTest();
    }

    @IsTest
    static void testMandaMail() {
        Test.startTest();
        SchedulableContext sc = null;
        Batch_DeleteCaseUnblu b = new Batch_DeleteCaseUnblu();
        String testoMail = 'EXCEPTION';
        b.mandaMail('Errore',testoMail);
        Test.stopTest();
    }
}