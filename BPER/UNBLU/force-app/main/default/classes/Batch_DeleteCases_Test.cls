@isTest
public class Batch_DeleteCases_Test {

    @testSetup static void setup() {
        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }catch(Exception e){}

        User automatedUser = [SELECT Id FROM User WHERE Name = 'Automated Process' LIMIT 1];
        Case c = new Case(ownerId = automatedUser.id);
        insert c;
        LiveChatTranscript lc = new LiveChatTranscript(
            LiveChatVisitorId = lcv.Id,
            ownerId = automatedUser.id,
            Status = 'Missed',
            CaseId = c.Id
        );
        insert lc;

    }
    @isTest
    static void unitTest() {

        User automatedUser = [SELECT Id FROM User WHERE Name = 'Automated Process' LIMIT 1];

        List<LiveChatTranscript> testChat = [SELECT id, CaseId, Status, Case.OwnerId FROM LiveChatTranscript where Case.OwnerId =: automatedUser.Id];
        system.debug(testChat[0]);

        Test.startTest();
        Batch_DeleteCases bdc = new Batch_DeleteCases();
        Database.executeBatch(bdc);
        Test.stopTest();
    }
}