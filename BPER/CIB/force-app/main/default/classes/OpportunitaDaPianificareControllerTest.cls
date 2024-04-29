@IsTest
public class OpportunitaDaPianificareControllerTest {

    @TestSetup
    public static void setup(){
        Opportunity opp = new Opportunity(
        	Name = 'Test',
        	CloseDate = Date.today(),
        	StageName = 'Qualification'
        );
        insert opp;
        Profile profile = [SELECT id FROM Profile WHERE Name =: Label.System_Administrator LIMIT 1];
        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        insert user;
    }
    
    @IsTest
    public static void test1(){
        Test.startTest();
        User user = [SELECT Id FROM User WHERE LastName='Test01'];
        System.debug('TEST UserId --> ' + user);
        System.runAs(user){
        	OpportunitaDaPianificareController.getOpps();
        	OpportunitaDaPianificareController.getUsers(new List<String>());
        	Id comitatoId = OpportunitaDaPianificareController.assignOpps([SELECT Id from Opportunity], System.today(), System.today());
        	OpportunitaDaPianificareController.createEvents(new List<Id>(), System.today(), System.today(), comitatoId);
        }
        Test.stopTest();
    }
}