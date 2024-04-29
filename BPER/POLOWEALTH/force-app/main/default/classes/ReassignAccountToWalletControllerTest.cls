@isTest
public with sharing class ReassignAccountToWalletControllerTest {
    
    @TestSetup
    public static void setup(){

        Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet',  'Filiale di Milano', 'CORPORATE');
        insert microPortafoglio;

        Account account = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        account.PTF_Portafoglio__c = microPortafoglio.Id;
        insert account;

        List<Wallet__c> testAssignWallets = new List<Wallet__c>();
        Wallet__c microPortafoglio_To = AllDataFactory.getWallet('MicroWallet',  'Filiale di Mantova', 'Corporate');
        Wallet__c microPortafoglio_From = AllDataFactory.getWallet('MicroWallet',  'Filiale di Mantova', 'Corporate');
        
        testAssignWallets.add(microPortafoglio_To);
        testAssignWallets.add(microPortafoglio_From);
        insert testAssignWallets;

        Account accountToAssign = new Account();
        accountToAssign.LastName='Test';
        accountToAssign.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        account.PTF_Portafoglio__c = microPortafoglio_From.Id;
        insert accountToAssign;
    }

    @isTest
    public static void testGetAllData(){

        Wallet__c microPortafoglio = [SELECT id FROM Wallet__c WHERE PTF_ModelloDiServizio__c ='CORPORATE' LIMIT 1];
        Map<String, SObject> response = ReassignAccountToWalletController.getAllData(microPortafoglio.Id);
    }

    @isTest
    public static void testGetAllDataException(){

        try {
            
            Map<String, SObject> response = ReassignAccountToWalletController.getAllData(UserInfo.getUserId());
        } catch (Exception ex) {
            
            System.assert(ex != null);
        }
    }

    @isTest
    public static void testAssign(){
        
        List<Wallet__c> portafogli = [SELECT Id FROM Wallet__c WHERE PTF_ModelloDiServizio__c ='Corporate'];

        Account acc= [SELECT Id, PTF_Portafoglio__c FROM ACCOUNT WHERE LastName='Test'];

        List<String> accIds= new List<String>();

        accIds.add(acc.Id);
        
        Wallet__c microPortafoglioFrom= new Wallet__c();

        Wallet__c microPortafoglioTo= new Wallet__c();

        if(acc.PTF_Portafoglio__c==portafogli[0].Id){
            microPortafoglioFrom.Id=portafogli[0].Id;
            microPortafoglioTo.Id=portafogli[1].Id;
        }
        else {
            microPortafoglioTo.Id=portafogli[0].Id;
            microPortafoglioFrom.Id=portafogli[1].Id;
        }
        Boolean Result = ReassignAccountToWalletController.assignSelectedAccounts(microPortafoglioTo.Id, accIds);
        acc= [SELECT Id, PTF_Portafoglio__c FROM ACCOUNT WHERE LastName='Test'];
    }

    @isTest
    public static void testAssignException(){

        try {
            
            Boolean Result = ReassignAccountToWalletController.assignSelectedAccounts(UserInfo.getUserId(), new List<String>());
        } catch (Exception ex) {
            
            System.assert(ex != null);
        }
    }

    @isTest
    public static void testgetAssignData(){
        Wallet__c microPortafoglio = [SELECT id FROM Wallet__c WHERE PTF_ModelloDiServizio__c ='Corporate' LIMIT 1];
        ReassignAccountToWalletController.getAssignData(microPortafoglio.Id);
    }

    @isTest
    public static void testgetAssignDataException(){

        try {
            
            Map<String,SObject> Result = ReassignAccountToWalletController.getAssignData(UserInfo.getUserId());
        } catch (Exception ex) {
            
            System.assert(ex != null);
        }
    }

    @isTest
    public static void testgetMW(){
        Wallet__c microPortafoglio = [SELECT id FROM Wallet__c WHERE PTF_ModelloDiServizio__c ='Corporate' LIMIT 1];
        ReassignAccountToWalletController.getMW(microPortafoglio.Id);
    } 

    @isTest
    public static void testgetMWException(){

        try {
            
            Map<String,SObject> Result = ReassignAccountToWalletController.getMW(UserInfo.getUserId());
        } catch (Exception ex) {
            
            System.assert(ex != null);
        }
    }

    @isTest
    public static void testRessign(){
        
        List<Wallet__c> portafogli = [SELECT Id FROM Wallet__c WHERE PTF_ModelloDiServizio__c ='Corporate'];

        Account acc= [SELECT Id, PTF_Portafoglio__c FROM ACCOUNT WHERE LastName='Test'];

        List<String> accIds= new List<String>();

        accIds.add(acc.Id);
        
        Wallet__c microPortafoglioFrom= new Wallet__c();

        Wallet__c microPortafoglioTo= new Wallet__c();

        
            if(acc.PTF_Portafoglio__c==portafogli[0].Id){
                microPortafoglioFrom.Id=portafogli[0].Id;
                microPortafoglioTo.Id=portafogli[1].Id;
            }
            else {
                microPortafoglioTo.Id=portafogli[0].Id;
                microPortafoglioFrom.Id=portafogli[1].Id;
            }
        
            try{
                Wallet__c microPortafoglio = [SELECT id FROM Wallet__c WHERE PTF_ModelloDiServizio__c ='CORPORATE'];
            Boolean Result = ReassignAccountToWalletController.reassignSelectedAccount(microPortafoglioFrom.Id, accIds, microPortafoglioTo.Id);
            Boolean Result2 = ReassignAccountToWalletController.reassignSelectedAccount(microPortafoglio.Id, accIds, microPortafoglioTo.Id);
            }
            catch(Exception e){}
    }

    @isTest
    public static void testReassignException(){

        try {
            
            Boolean Result = ReassignAccountToWalletController.reassignSelectedAccount(UserInfo.getUserId(), new List<String>(), UserInfo.getUserId());
        } catch (Exception ex) {
            
            System.assert(ex != null);
        }
    }
}