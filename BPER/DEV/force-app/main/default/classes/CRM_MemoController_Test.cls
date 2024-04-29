@IsTest
public with sharing class CRM_MemoController_Test {
    @TestSetup
    public static void setup(){
        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        insert filiale;

        Wallet__c microPortafoglioFamily = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Family');
        Wallet__c microPortafoglioPersonal = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Personal');
        Wallet__c portafoglioTecnico = AllDataFactory.getWallet('TechnicalWallet',  filiale.Id, 'Private');
        insert new List<Wallet__c>{microPortafoglioFamily, portafoglioTecnico, microPortafoglioPersonal};

        RoleTypology__c ruolo = new RoleTypology__c();
        ruolo.Name = 'Titolare';
        insert ruolo;

        ServiceModel__c modelloDiServizio = new ServiceModel__c();
        modelloDiServizio.Name = 'Personal';
        insert modelloDiServizio;

        RoleMDS__c ruoloMDS = new RoleMDS__c();
        ruoloMDS.PTF_BranchTypology__c = 'A';
        ruoloMDS.PTF_RoleTypology__c = ruolo.Id;
        ruoloMDS.PTF_ServiceModel__c = modelloDiServizio.Id;
        ruoloMDS.PTF_StartDate__c = Date.today().addDays(-10);
        ruoloMDS.PTF_EndDate__c = Date.today().addDays(10);
        insert ruoloMDS;
        
        Contact contact = AllDataFactory.getContact('01', UserInfo.getUserId(), filiale.Id);
        contact.PTF_TipologiaRuolo__c = ruolo.Id;
        insert contact;

        // Relazione Di Cointestazione
        Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
        personAccount.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        personAccount.PTF_Filiale__c = filiale.Id;
        personAccount.PTF_StatoCRM__c = 'ATT';
        insert personAccount;

        CRM_Memo__c memo = new CRM_Memo__c();
        memo.Cliente__c = personAccount.id;
        memo.Name = 'test';
        memo.CRM_Tipologia__c = 'PUBBLICO';
        memo.CRM_FineValidita__c = Date.today();
        memo.CRM_PopupCassa__c = false;
        insert memo;

        CH_Memo__c chMemo = new CH_Memo__c();
        chMemo.CRM_Account__c = personAccount.id;
        chMemo.Name = 'test';
        chMemo.CRM_Tipologia__c = 'PUBBLICO';
        chMemo.CRM_FineValidita__c = Datetime.now().format('yyyy-MM-dd');
        chMemo.CRM_PopupCassa__c = false;
        insert chMemo;

    }

    @IsTest
    public static void test1(){
        List<Account> accList = [SELECT id FROM Account WHERE RecordType.Developername = 'PersonAccount' LIMIT 1];
        test.startTest();
        User user = CRM_MemoController.getUserInfo();
        CRM_MemoController.getAllData(acclist[0].Id);
        test.stopTest();
        System.assertEquals(true, user !=null);
        System.assertEquals(true,(CRM_MemoController.getAllData(acclist[0].Id)) !=null);
    }
}