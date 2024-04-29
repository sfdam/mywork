@isTest
public with sharing class BloccoIterControllerTest {
    @TestSetup
    public static void setup(){
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
        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        filiale.FinServ__BankNumber__c = '05387';
        filiale.parentId = area.Id;
        filiale.PTF_BranchTypology__c = 'A';
        filiale.PTF_Banca__c = banca.Id;
        filiale.PTF_DirezioneRegionale__c = dir.Id;
        filiale.PTF_Area__c = area.Id;
        filiale.PTF_IdCed__c = '1234';

        Account filiale2 = AllDataFactory.getAccount('30', 'FilialeDiRelazione');
        filiale2.FinServ__BankNumber__c = '05387';
        filiale2.parentId = area.Id;
        filiale2.PTF_BranchTypology__c = 'A';
        filiale2.PTF_Banca__c = banca.Id;
        filiale2.PTF_DirezioneRegionale__c = dir.Id;
        filiale2.PTF_Area__c = area.Id;
        insert new List<Account>{filiale, filiale2};

        Wallet__c microPortafoglioFamily = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Family');
        Wallet__c microPortafoglioFamily2 = AllDataFactory.getWallet('MicroWallet',  filiale2.Id, 'Family');
        Wallet__c microPortafoglioPersonal = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Personal');
        Wallet__c microPortafoglioPersonal2 = AllDataFactory.getWallet('MicroWallet',  filiale2.Id, 'Personal');
        insert new List<Wallet__c>{microPortafoglioFamily, microPortafoglioPersonal, microPortafoglioFamily2, microPortafoglioPersonal2};

        // Relazione Di Cointestazione
        Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
        personAccount.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        personAccount.PTF_Filiale__c = filiale.Id;

        Account personAccount2 = AllDataFactory.getAccount('02', 'PersonAccount');
        personAccount2.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        personAccount2.PTF_Filiale__c = filiale.Id;

        Account personAccount3 = AllDataFactory.getAccount('03', 'PersonAccount');
        personAccount3.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        personAccount3.PTF_Filiale__c = filiale.Id;

        Account cointestazione = AllDataFactory.getAccount('04', 'Cointestazione');
        cointestazione.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        cointestazione.PTF_Filiale__c = filiale.Id;
        cointestazione.PTF_NaturaGiuridica__c='CO';

        // Gruppo
        Account gruppo = AllDataFactory.getAccount('05', 'GruppoFinanziario');
        gruppo.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        gruppo.PTF_Filiale__c = filiale.Id;
        gruppo.PTF_NaturaGiuridica__c = 'GF';

        Account business = AllDataFactory.getAccount('06', 'IndustriesBusiness');
        business.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        business.PTF_Filiale__c = filiale.Id;
        business.CRM_NDG__c = 'Account06';

        Account business2 = AllDataFactory.getAccount('07', 'IndustriesBusiness');
        business2.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        business2.PTF_Filiale__c = filiale.Id;
        business.CRM_NDG__c = 'Account07';

        Account business3 = AllDataFactory.getAccount('08', 'IndustriesBusiness');
        business3.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        business3.PTF_Filiale__c = filiale.Id;
        business3.CRM_NDG__c = 'Account08';

        insert new List<Account>{personAccount, personAccount2, personAccount3, cointestazione, gruppo, business, business2,business3};
    }

    @isTest
    public static void testGetStrutturaBancad() {

        Map<String,sObject> response = BloccoIterController.getStrutturaBanca();
    }

    @isTest
    public static void testGetAccountId() {

        string accountId = BloccoIterController.getAccountId('1234');
    }

    @isTest
    public static void testBlockIterUO() {

        Test.startTest();
        string accountId = BloccoIterController.getAccountId('1234');
        Account filiale = [SELECT id, PTF_Capofila__c FROM Account WHERE Id =: accountId];
        BloccoIterController.blockIterUO(filiale, 'Filiale di relazione', '');
        Test.stopTest();
    }
    @isTest
    public static void testUpdateNDGs() {

        Test.startTest();
        BloccoIterController.UpdateNDGs(new List<String>{''}, '');
        Test.stopTest();
    }
}