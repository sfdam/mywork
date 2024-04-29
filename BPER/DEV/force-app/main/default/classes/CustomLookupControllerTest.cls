/**
*
* @author  Giorgio Bonifazi @Lutech
* @version 1.0
* @since   2021-03-31
*/
@isTest
public class CustomLookupControllerTest {
    
    @TestSetup
    public static void setup(){
        
        Account banca = AllDataFactory.getAccount('10', 'Banca');
        banca.FinServ__BankNumber__c = '05387';
        insert banca;
        Account dir = AllDataFactory.getAccount('09', 'DirezioneRegionale');
        
        dir.parentId = banca.Id;
        insert dir;
        Account area = AllDataFactory.getAccount('08', 'Area');
        
        area.parentId = dir.Id;
        insert area;
        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        
        filiale.parentId = area.Id;
        filiale.PTF_BranchTypology__c = 'A';
        filiale.CRM_Nome__C = '2011 - MILANO - AGENZIA 13';
        insert filiale;
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
		
        test.startTest();
        List<CustomLookupController> response = CustomLookupController.getSearchResult('', '', '', '', '', '', '');
        test.stopTest();
        System.assertEquals(false, response.size()>0);
    }
    
    @isTest
    public static void testMethod2(){

        String strSearch = 'mil';
        String fieldAlternativeInLabel = '';
        String otherFieldToQuery = 'PTF_MDSAbilitati__c';
        String fieldToLike = 'CRM_Nome__c';
        String sObjectName = 'Account';
        String iconName = 'standard:account';
        String condition = '';
		
        test.startTest();
        List<CustomLookupController> response1 = CustomLookupController.getSearchResult(strSearch, fieldAlternativeInLabel, otherFieldToQuery, fieldToLike, sObjectName, iconName, '');
        test.stopTest();
        System.assertEquals(true, response1.size()>0);
    }
    
    @isTest
    public static void testMethod3(){
		
        String strSearch = 'mil';
        String fieldAlternativeInLabel = 'Name';
        String objId = '';
        String sObjectName = 'Account';
        String iconName = 'standard:account';
        String fieldToLike = 'CRM_Nome__c';
        String otherFieldToQuery = 'PTF_MDSAbilitati__c';
        String name = 'Account name';
        String condition = '';
        SObject obj = Schema.getGlobalDescribe().get('Account').newSObject();
		
        CustomLookupController c = new CustomLookupController(objId,  sObjectName, iconName, name,obj);
        Test.startTest();
        List<CustomLookupController> response2 = CustomLookupController.getSearchResult( strSearch, fieldAlternativeInLabel, otherFieldToQuery, fieldToLike,  sObjectName,  iconName,  condition);
  		test.stopTest();
        System.assertEquals(true, response2.size()>0);
    }

}