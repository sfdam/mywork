@isTest
public with sharing class CheckupListViewControllerv2Test {
    
    @TestSetup
    public static void setup(){

        // Relazione Di Cointestazione
        Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
        insert personAccount;

        CRM_CustomerInterview__c checkup1 = new CRM_CustomerInterview__c();
        checkup1.CRM_Customer__c = personAccount.id;
        checkup1.CRM_IsCompilazione__c = true;
        checkup1.CRM_DataUltimaCompilazione__c = date.today();
        insert checkup1;
        
        CRM_Note__c note1 = new CRM_Note__c(CRM_BankCreditNotes__c = 'testProva',CRM_Tagliando__c=checkup1.id);
        insert  note1;
    }

    @isTest
    public static void test1(){
	  Test.startTest();
        String accId = [SELECT Id FROM Account LIMIT 1].Id;
        List<CRM_CustomerInterview__c> response= CheckupListViewControllerv2.getRecordNotes(accId, 1,null);
      Test.stopTest();
       System.assertEquals(true, response.size()>0);
    }


}