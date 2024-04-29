@isTest
public with sharing class LightningOutControllerTest {
    @TestSetup
    static void createDataLOC()
    {
        String profiloName = Label.System_Administrator;
        Profile profile = [SELECT id FROM Profile WHERE Name =:profiloName  LIMIT 1];
        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        insert new List<User>{user};
        System.runAs(user){

            Account filiale = AllDataFactory.getAccount('04', 'FilialeDiRelazione');
            filiale.PTF_BranchTypology__c = 'A';
            insert filiale;

            Contact contact = AllDataFactory.getContact('01', user.Id, filiale.Id);
            insert contact;

            Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
            personAccount.PTF_Filiale__c = filiale.Id;
            personAccount.PTF_StatoCRM__c = 'ATT';
            personAccount.FinServ__BankNumber__c='05387';
            insert personAccount;

        }
    }
    @isTest
    static void testVerifyNDG(){
        Account acc =[SELECT CRM_NDG__c FROM Account limit 1];
        test.startTest();
        Map<String,Object> response = LightningOutController.verifyNDG(acc.CRM_NDG__c,'05387');
        test.stopTest();
        System.assertEquals(false, response.get('hasCampaigns'));
    }
    @isTest
    static void testGetAllData(){
        Account acc =[SELECT CRM_NDG__c FROM Account limit 1];
        test.startTest();
        String response = LightningOutController.getAllData(acc.CRM_NDG__c,'05387');
        test.stopTest();
        System.assertEquals(true, response !=null);
    }
}