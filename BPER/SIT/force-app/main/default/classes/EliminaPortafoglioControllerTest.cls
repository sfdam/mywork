@IsTest
public class EliminaPortafoglioControllerTest {
    @TestSetup
    static void makeData(){
        Account filiale = AllDataFactory.getAccount('04', 'FilialeDiRelazione');
        filiale.PTF_BranchTypology__c = 'A';
        insert filiale;
        Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet', filiale.Id, 'Private');
        Wallet__c microPortafoglio2 = AllDataFactory.getWallet('MicroWallet', filiale.Id, 'CORPORATE');
        insert new List<Wallet__c>{microPortafoglio,microPortafoglio2};
        Account personAccount = AllDataFactory.getAccount('05', 'PersonAccount');
        personAccount.PTF_Filiale__c = filiale.Id;
        personAccount.PTF_Portafoglio__c = microPortafoglio.Id;
        personAccount.PTF_StatoCRM__c='ATT';
        insert personAccount;

    }
    @isTest
    static void testCheckMW(){
        Wallet__c wal=[SELECT Id FROM Wallet__c WHERE PTF_ModelloDiServizio__c='Private' LIMIT 1];
        try{
            EliminaPortafoglioController.checkMW(wal.Id);
        }
        catch(Exception e){
            
        }
        
    }
    @isTest
    static void testEliminaMW(){
        Wallet__c wal=[SELECT Id FROM Wallet__c WHERE PTF_ModelloDiServizio__c='CORPORATE' LIMIT 1];
        try{
            EliminaPortafoglioController.eliminaMW(wal.Id);
        }
        catch(Exception e){
            
        }
        
    }
}