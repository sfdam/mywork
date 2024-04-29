@isTest
public with sharing class Batch_AlignNdgHierarchyTest {
    @TestSetup
    static void makeData(){
        
        ServiceModel__c personal = new ServiceModel__c(Name = 'Personal',
        PTF_Division__c = 'PE',
        PTF_MacroDivision__c = 'WM');

        ServiceModel__c family = new ServiceModel__c(Name = 'Family',
        PTF_Division__c = 'PE',
        PTF_MacroDivision__c = 'EB');
        insert new List<ServiceModel__c>{personal, family};
        Account banca = AllDataFactory.getAccount('10', 'Banca');
        banca.FinServ__BankNumber__c = '05387';
        insert banca;
        Account dir = AllDataFactory.getAccount('09', 'DirezioneRegionale');
        dir.FinServ__BankNumber__c = '05387';
        dir.parentId = banca.Id;
        dir.PTF_Banca__c = banca.Id;
        insert dir;
        Account area = AllDataFactory.getAccount('08', 'Area');
        area.FinServ__BankNumber__c = '05387';
        area.parentId = dir.Id;
        area.PTF_Banca__c = banca.Id;
        area.PTF_DirezioneRegionale__c = dir.Id;
        insert area;

        Account area2 = AllDataFactory.getAccount('22', 'Area');
        area2.FinServ__BankNumber__c = '05387';
        area2.parentId = dir.Id;
        area2.PTF_Banca__c = banca.Id;
        area2.PTF_DirezioneRegionale__c = dir.Id;
        insert area2;

        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        filiale.FinServ__BankNumber__c = '05387';
        filiale.parentId = area.Id;
        filiale.PTF_BranchTypology__c = 'A';
        filiale.PTF_Banca__c = banca.Id;
        filiale.PTF_DirezioneRegionale__c = dir.Id;
        filiale.PTF_Area__c = area.Id;

        Account filiale2 = AllDataFactory.getAccount('30', 'FilialeDiRelazione');
        filiale2.FinServ__BankNumber__c = '05387';
        filiale2.parentId = area2.Id;
        filiale2.PTF_BranchTypology__c = 'A';
        filiale2.PTF_Banca__c = banca.Id;
        filiale2.PTF_DirezioneRegionale__c = dir.Id;
        filiale2.PTF_Area__c = area2.Id;
        insert new List<Account>{filiale, filiale2};

        Wallet__c microPortafoglioFamily = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Family');
        Wallet__c microPortafoglioFamily2 = AllDataFactory.getWallet('MicroWallet',  filiale2.Id, 'Family');
        Wallet__c microPortafoglioPersonal = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Personal');
        Wallet__c microPortafoglioPersonal2 = AllDataFactory.getWallet('MicroWallet',  filiale2.Id, 'Personal');
        Wallet__c microPortafoglioAssente = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Assente');
        Wallet__c microPortafoglioCF = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Consulenti Finanziari');
        insert new List<Wallet__c>{microPortafoglioFamily, microPortafoglioPersonal, microPortafoglioFamily2, microPortafoglioPersonal2, microPortafoglioAssente,microPortafoglioCF};

        // Relazione Di Cointestazione
        Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
        personAccount.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        personAccount.PTF_Filiale__c = filiale.Id;

        insert personAccount;
    }

    @isTest
    public static void executeBatchException(){
        
        Account account = [SELECT id, PTF_Portafoglio__c, PTF_Portafoglio__r.PTF_Filiale__c FROM Account WHERE LastName = 'LastName01' LIMIT 1];
        Wallet__c microPortafoglioFamily2 = [SELECT id, PTF_Filiale__c FROM Wallet__c  WHERE PTF_ModelloDiServizio__c = 'Family' AND PTF_Filiale__c !=: account.PTF_Portafoglio__r.PTF_Filiale__c LIMIT 1];
        account.PTF_Portafoglio__c = microPortafoglioFamily2.Id;
        account.PTF_Filiale__c = microPortafoglioFamily2.PTF_Filiale__c;
        Batch_AlignNdgHierarchy.skipAccountTrigger = true;
        update account;
        Batch_AlignNdgHierarchy.skipAccountTrigger = false;
		Test.StartTest(); 
        Batch_AlignNdgHierarchy batch = new Batch_AlignNdgHierarchy();
        batch.walletsIdSet = new Set<String>{microPortafoglioFamily2.Id};
        Database.executeBatch(batch,200);
        Test.stopTest();
    }
}