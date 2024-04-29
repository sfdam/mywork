@isTest
public class OnAccountTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        TestUtils.TerritoryContext terrContext = TestUtils.createTerritoryContext(false);
        TestUtils.TerritoryContext terrContextIta = TestUtils.createTerritoryContext(true);
    }
    @isTest
    static void testManageTerrioryOnInsert () {
       Account a =  TestUtils.createAccount(true);
       Account b = TestUtils.createAccount(false);
    }
    @isTest
    static void testManageTerritoryOnUpdate () {
      Account a = [SELECT Id FROM Account WHERE BillingCountryCode = 'IT' LIMIT 1];
      a.BillingStateCode = 'VI';
      update a;
      
    }

  


}