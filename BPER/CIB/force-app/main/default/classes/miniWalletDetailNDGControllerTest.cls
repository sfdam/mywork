@isTest
public with sharing class miniWalletDetailNDGControllerTest {
    @isTest
    static void testNDGMiniWallet(){
		Test.startTest();
        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        insert new List<Account>{filiale};
        Wallet__c microPortafoglioFamily = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Family');
      
        insert new List<Wallet__c>{microPortafoglioFamily};
        // Relazione Di Cointestazione
        Account personAccount = AllDataFactory.getAccount('02', 'PersonAccount');
        personAccount.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        personAccount.PTF_StatoCRM__c = 'ATT';
        personAccount.ModelloDiServizio__c = 'Private';
        insert personAccount;
       
    
        MiniWallet__c miniWallet = new MiniWallet__c();
        miniWallet.PTF_Portafoglio__c=microPortafoglioFamily.id;        
        insert miniWallet;

        personAccount.PTF_MiniPortafoglio__c = miniWallet.id;
        update personAccount;
        
        List<Account> listMW = miniWalletDetailNDGController.getAllData(personAccount.id);

        Test.stopTest();
    }
}