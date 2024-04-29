@isTest
public class CustomLookupControllerTest {
   
    @isTest 
    static void test() {
        
        Test.startTest();
        Account acc = new Account
        (
			Name = 'test', THR_AccountsKey__c = String.valueOf(System.currentTimeMillis())
        );
        insert acc;
        List<String> ListString = New List<String>();
        ListString.add(acc.Id);
		
        CustomLookupController controller = new CustomLookupController(Acc.Id, 'object', 'icon', 'name', Acc);
        CustomLookupController.getSearchResult('test', 'Name', '', 'Name', 'Account', 'test', 'Name = \'Test\'',ListString);
        Test.stopTest();
	}
}