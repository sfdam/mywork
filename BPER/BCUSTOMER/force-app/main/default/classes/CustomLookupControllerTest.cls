@isTest
public class CustomLookupControllerTest {
   
    @isTest 
    static void test() {
        
        Test.startTest();
        Account banca = AllDataFactory.getAccount('10', 'Banca');
        banca.FinServ__BankNumber__c = '05387';
        insert banca;
        List<String> ListString = New List<String>();
        ListString.add(banca.Id);
		
        CustomLookupController controller = new CustomLookupController(banca.Id, 'object', 'icon', 'FinServ__BankNumber__c', banca);
        CustomLookupController.getSearchResult('05387', 'FinServ__BankNumber__c', '', 'FinServ__BankNumber__c', 'Account', '05387', 'FinServ__BankNumber__c = \'05387\'',ListString);
        Test.stopTest();
	}
}