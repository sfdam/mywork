@IsTest
public class OpportunityDataTableControllerTest {
    @TestSetup
    static void makeData(){
        Account a = new Account();
        a.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        a.FirstName='test';
        a.LastName='test';
        insert a;

        Case c = new Case();
        c.Origin='Web';
        c.AccountId=a.Id;
        insert c;

        Opportunity o = new Opportunity();
        o.AccountId=a.Id;
        o.Name= 'Test';
        o.StageName='Non risponde 1';
        o.CloseDate=Date.today().addDays(3);
        insert o;

    }

    @isTest
    static void testGetAllData(){
        Case c = [SELECT Id, AccountId FROM Case LIMIT 1];
        OpportunityDataTableController.getAllData(c.AccountId, 1);
        OpportunityDataTableController.getAllData(c.Id, 2);
    }
}