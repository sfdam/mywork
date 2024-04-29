@isTest
public class WGC_MainCalloutComponentController_Test {

    @isTest
    public static void test_accountHasHesitatedTaskOrEvent(){
        WGC_AllDataFactory.createUtenzaDefault();
        Account a = WGC_AllDataFactory.createAccount(1,true).get(0);
        Test.startTest();
        WGC_MainCalloutComponentController.accountHasHesitatedTaskOrEvent(a.Id);
        Test.stopTest();
    }

}