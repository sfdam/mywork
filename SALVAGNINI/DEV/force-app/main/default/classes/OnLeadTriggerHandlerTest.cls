@isTest
public class OnLeadTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        TestUtils.TerritoryContext terrContext = TestUtils.createTerritoryContext(false);
        TestUtils.TerritoryContext terrContextIta = TestUtils.createTerritoryContext(true);
        Lead a =  TestUtils.createLead(true);

    }
    @isTest
    static void testManageTerrioryOnInsert () {
       Lead b = TestUtils.createLead(false);
       RecordType recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Lead' AND DeveloperName = 'Lead'];
        Lead leadC = new Lead(
            LastName = 'Lead'+ Math.rint(Math.random() * 1000),
            Country = 'Italy' ,
            State = 'Milano',
            PostalCode = '11500',
            RecordTypeId = recordType.Id,
            Email = 'testTEST@test.test',
            Phone = '0000000',
            Company = 'Test'
        );
        insert leadC;
    }
    @isTest
    static void testManageTerritoryOnUpdate () {
      Lead a = [SELECT Id FROM Lead WHERE CountryCode = 'IT' LIMIT 1];
      a.StateCode = 'VI';
      update a;
      
    }

  


}