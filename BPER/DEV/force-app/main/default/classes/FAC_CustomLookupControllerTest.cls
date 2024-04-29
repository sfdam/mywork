@isTest
public class FAC_CustomLookupControllerTest {

    @TestSetup
    public static void setup(){
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            testAccts.add(new Account(Name = 'TestAcct'+i, Phone='123456789'));
        }
        insert testAccts;    
    }

    @isTest
    public static void testMethod1(){

        String strSearch = '';
        String fieldAlternativeInLabel = '';
        String otherFieldToQuery = '';
        String fieldToLike = '';
        String sObjectName = '';
        String iconName = '';
        String condition = '';

        FAC_CustomLookupController.getSearchResult(strSearch, fieldAlternativeInLabel, otherFieldToQuery, fieldToLike, sObjectName, iconName, condition);
    }
    
    @isTest
    public static void testMethod2(){

        String strSearch = 'Test';
        String fieldAlternativeInLabel = '';
        String otherFieldToQuery = 'Phone, BillingCity';
        String fieldToLike = 'Name, BillingCountry';
        String sObjectName = 'Account';
        String iconName = 'standard:account';
        String condition = 'Phone=\'123456789\'';

        FAC_CustomLookupController.getSearchResult(strSearch, fieldAlternativeInLabel, otherFieldToQuery, fieldToLike, sObjectName, iconName, condition);
    }
    
    @isTest
    public static void testMethod3(){

        String objId = '';
        String sObjectName = 'Opportunity';
        String iconName = 'standard:opportunity';
        String name = 'Nome Opportunità';
        SObject obj = Schema.getGlobalDescribe().get('Opportunity').newSObject();
		
        FAC_CustomLookupController c = new FAC_CustomLookupController(objId,  sObjectName, iconName, name, obj);
        
    }

}