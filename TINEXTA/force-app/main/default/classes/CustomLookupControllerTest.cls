@isTest
public class CustomLookupControllerTest {

    @TestSetup
    static void makeData(){
        Account acc = new Account(Name = 'TestAccount');
        Insert acc;

        Opportunity opp = new Opportunity(Name = 'TestOpportunity', StageName = 'Won', AccountId = acc.Id, CloseDate = System.Today());
        Insert opp;
    }

    @isTest
    public static void test_method1(){
        Test.startTest();
            CustomLookupController constructor = new CustomLookupController();
            //With results
            List<CustomLookupController> results = CustomLookupController.getSearchResult('Test', 'Opportunity', 'standard:opportunity', '');
            //With no results
            List<CustomLookupController> noresults = CustomLookupController.getSearchResult('', 'Opportunity', 'standard:opportunity', '');
        Test.stopTest();
    }
}