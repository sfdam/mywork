@isTest
private class MiniWalletNdgTableControllerTest {

    @TestSetup
    static void makeData(){

        Account pfiliale = new Account();
        pfiliale.FirstName = 'filialeTest';
        pfiliale.LastName = 'filialeTest';
        pfiliale.PTF_IdCED__c = '10';
        pfiliale.PTF_Livello__c = '210';
        insert pfiliale;

        Wallet__c wallet = new Wallet__c();
        Id RecordTypeIdWallet = Schema.SObjectType.Wallet__c.getRecordTypeInfosByDeveloperName().get('MicroWallet').getRecordTypeId();
        wallet.RecordTypeId = RecordTypeIdWallet;
        wallet.PTF_Filiale__c = pfiliale.Id;
        wallet.PTF_ModelloDiServizio__c = 'Personal';
        insert wallet;

        MiniWallet__c miniWallet = new MiniWallet__c();
        miniWallet.PTF_Portafoglio__c = wallet.id;
        insert miniWallet;

        Account testAcc = new Account();
        testAcc.Name = 'account di test';
        testAcc.CRM_Nome__c = 'nome di test';
        testAcc.PTF_Capogruppo__c = true;
        testAcc.PTF_NaturaGiuridica__c = 'natura giuridica test';
        testAcc.PTF_Patrimonio__c = 1000;
        testAcc.PTF_Utilizzato__c = 500;
        testAcc.PTF_Portafoglio__c = wallet.id;
        insert testAcc;
        
        Account testAcc1 = new Account();
        testAcc1.Name = 'account di test';
        testAcc1.CRM_Nome__c = 'nome di test';
        testAcc1.PTF_Capogruppo__c = true;
        testAcc1.PTF_NaturaGiuridica__c = 'natura giuridica test';
        testAcc1.PTF_Patrimonio__c = 1000;
        testAcc1.PTF_Utilizzato__c = 500;
        testAcc1.PTF_Portafoglio__c = wallet.id;
        testAcc1.PTF_MiniPortafoglio__c = miniWallet.id;
        insert testAcc1;
        
    }

    @isTest
    private static void getNdgTest(){

        System.debug('AdF start getNdgTest');

        MiniWallet__c miniWallet = [SELECT Id FROM MiniWallet__c LIMIT 1];

        Test.startTest();
            List<Account> accList = MiniWalletNdgTableController.getNdg(miniWallet.id);
        Test.stopTest();

        System.assertEquals(true, accList.size() > 0, 'errore nel recupero della lista di NDG');

        System.debug('AdF end getNdgTest');

    }

    @isTest
    private static void updateNdgTest(){

        System.debug('AdF start updateNdgTest');

        MiniWallet__c miniWallet = [SELECT Id FROM MiniWallet__c LIMIT 1];
        List<Account> accList = [SELECT id FROM Account WHERE Name = 'account di test'];
        List<String> strId = new List<String>();
        for(Account i: accList)
            strId.add(i.id);

        Test.startTest();
            Boolean hasNoError = MiniWalletNdgTableController.updateNdg(miniWallet.id, strId);
        Test.stopTest();

        System.assertEquals(true, hasNoError, 'errore in update dei NDG');

        System.debug('AdF end updateNdgTest');

    }

    @isTest
    private static void removeNdgTest(){

        System.debug('AdF start removeNdgTest');

        MiniWallet__c miniWallet = [SELECT Id FROM MiniWallet__c LIMIT 1];
        List<Account> accList = [SELECT id FROM Account WHERE Name = 'account di test'];
        List<String> strId;
        Test.startTest();
             accList = MiniWalletNdgTableController.getNDGToRemove(miniWallet.id);
        Test.stopTest();
        System.debug('AdF end removeNdgTest');
        System.assertEquals(true, accList.size()>0);

    }

    @isTest
    private static void removeNdgTest2(){

        System.debug('AdF start removeNdgTest2');

        MiniWallet__c miniWallet = [SELECT Id FROM MiniWallet__c LIMIT 1];
        List<Account> accList = [SELECT PTF_MiniPortafoglio__c FROM Account WHERE Name = 'account di test'];
        List<String> strId = new List<String>();
        for(Account i: accList)
            strId.add(i.id);
        Test.startTest();
        Boolean hasNoError = MiniWalletNdgTableController.removeNDG(strId);
        Test.stopTest();
        System.debug('AdF end removeNdgTest2');
        System.assertEquals(true, hasNoError);

    }

}