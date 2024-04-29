@isTest
public class SV_CustomLookUp_Controller_Test {
    
    @testSetup 
    static void setup() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            testAccts.add(new Account(Name = 'TestAcct'+i));
        }
        insert testAccts;        
    }
    
    @isTest
    public static void Test_fetchLookUpValues_Find(){

        Test.startTest();
        // (String searchKeyWord, String ObjectName, String fields, Boolean soqlSearch, String whereCondition)
        SV_CustomLookUp_Controller.fetchLookUpValues('Test', 'Account','Name', false, '');
        Test.stopTest();
    }
    
    @isTest
    public static void Test_fetchLookUpValues_Soql(){

        Test.startTest();
        // (String searchKeyWord, String ObjectName, String fields, Boolean soqlSearch, String whereCondition)
        SV_CustomLookUp_Controller.fetchLookUpValues('Test', 'Account','Name', true, '###Name###');
        Test.stopTest();
    }

}