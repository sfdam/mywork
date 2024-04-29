@isTest
public with sharing class CheckupListViewControllerTest {
    
    @TestSetup
    public static void setup(){

        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        insert filiale;

        Wallet__c microPortafoglioFamily = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Family');
        Wallet__c microPortafoglioPersonal = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Personal');
        insert new List<Wallet__c>{microPortafoglioFamily, microPortafoglioPersonal};

        // Relazione Di Cointestazione
        Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
        personAccount.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        personAccount.PTF_Filiale__c = filiale.Id;
        insert personAccount;

        CRM_CustomerInterview__c checkup1 = new CRM_CustomerInterview__c(CRM_Customer__c = personAccount.id);
        insert checkup1;
        CRM_Note__c note1 = new CRM_Note__c(CRM_BankCreditNotes__c = 'testProva',CRM_Tagliando__c=checkup1.id);
        insert  note1;
    }

    @isTest
    public static void test1(){

        String chekup = [SELECT ID FROM CRM_CustomerInterview__c limit 1].Id;
        CheckupListViewController.getRecordNotes(chekup, 1);
    }


}