@isTest
private class miniWalletReferentiTableControllerTEST {

    @isTest
    public static void getReferentiTEST() {

        // BASE DATI
        String miniWalletName = 'nomeDelMiniWallet';

        Account filiale = new Account();
        filiale.Name = 'filialeTest';

        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('AltraUnitaOrganizzativa').getRecordTypeId();
        
        filiale.RecordTypeId = RecordTypeIdAccount;
        filiale.PTF_IdCEDPadre__c = '10';
        filiale.PTF_Livello__c = '210';
        
        insert filiale;

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

        pfiliale.PTF_Portafoglio__c = wallet.id;
        update pfiliale;

        Contact contact = new Contact();
        contact.FirstName = 'Test43039';
        contact.LastName = 'Test43039';
        insert contact;

        Assignment__c referente = new Assignment__c();
        Id RecordTypeIdAssignment = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Primario').getRecordTypeId();
        referente.RecordTypeId = RecordTypeIdAssignment;
        referente.PTF_MicroWallet__c = wallet.id;
        referente.PTF_EndDate__c = null;
        referente.PTF_MiniPortafoglio__c = null;
        insert referente;

        MiniWallet__c mw = new MiniWallet__c();
        mw.Name = 'Test43039';
        mw.PTF_Portafoglio__c = wallet.id;
        mw.Referente__c = contact.Id;
        mw.PTF_SL__c = pfiliale.Id;
        insert mw;

        List<Account> sportelliLeggeri = new List<Account>();
        sportelliLeggeri.add(pfiliale);
        // FINE BASE DATI

        List<Assignment__c> referenti = new List<Assignment__c>();
        referenti.add(referente);

        Test.startTest();
            miniWalletReferentiTableController.getReferenti(mw.id);
        Test.stopTest();

    }

    @isTest
    public static void getReferentiAssegnatiTEST() {

        // BASE DATI
        String miniWalletName = 'nomeDelMiniWallet';
        Account filiale = new Account();
        filiale.Name = 'filialeTest';

        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('AltraUnitaOrganizzativa').getRecordTypeId();
        
        filiale.RecordTypeId = RecordTypeIdAccount;
        filiale.PTF_IdCEDPadre__c = '10';
        filiale.PTF_Livello__c = '210';
        
        insert filiale;

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

        pfiliale.PTF_Portafoglio__c = wallet.id;
        update pfiliale;

        Contact contact = new Contact();
        contact.FirstName = 'Test43039';
        contact.LastName = 'Test43039';
        insert contact;

        Assignment__c referente = new Assignment__c();
        Id RecordTypeIdAssignment = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Primario').getRecordTypeId();
        referente.RecordTypeId = RecordTypeIdAssignment;
        referente.PTF_MicroWallet__c = wallet.id;
        referente.PTF_EndDate__c = null;
        referente.PTF_MiniPortafoglio__c = null;
        insert referente;
        MiniWallet__c mw = new MiniWallet__c();
        mw.Name = 'Test43039';
        mw.PTF_Portafoglio__c = wallet.id;
        mw.Referente__c = contact.Id;
        mw.PTF_SL__c = pfiliale.Id;
        insert mw;
        referente.PTF_MiniPortafoglio__c = mw.id;
        update referente;
        // FINE BASE DATI

        Test.startTest();
            List<Assignment__c> referentiAssegnati = miniWalletReferentiTableController.getReferentiAssegnati(mw.id);
        Test.stopTest();

        System.assertEquals(true, referentiAssegnati.size() > 0, 'errore in recupero referenti assegnati al mini wallet');

    }

    @isTest
    public static void AssegnaReferentiTest() {

        // BASE DATI
        String miniWalletName = 'nomeDelMiniWallet';

        Account filiale = new Account();
        filiale.Name = 'filialeTest';

        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('AltraUnitaOrganizzativa').getRecordTypeId();
        
        filiale.RecordTypeId = RecordTypeIdAccount;
        filiale.PTF_IdCEDPadre__c = '10';
        filiale.PTF_Livello__c = '210';
        
        insert filiale;

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

        pfiliale.PTF_Portafoglio__c = wallet.id;
        update pfiliale;

        MiniWallet__c mw = new MiniWallet__c();
        mw.Name = 'Test43039';
        mw.PTF_Portafoglio__c = wallet.id;
        
        mw.PTF_SL__c = pfiliale.Id;
        insert mw;

        Contact contact = new Contact();
        contact.FirstName = 'Test43039';
        contact.LastName = 'Test43039';
        insert contact;

        Assignment__c referente = new Assignment__c();
        Id RecordTypeIdAssignment = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Primario').getRecordTypeId();
        referente.RecordTypeId = RecordTypeIdAssignment;
        referente.PTF_MicroWallet__c = wallet.id;
        referente.PTF_EndDate__c = null;
        referente.PTF_MiniPortafoglio__c = null;
        insert referente;

        // FINE BASE DATI

        List<Assignment__c> referenti = new List<Assignment__c>();
        referenti.add(referente);

        Test.startTest();
            miniWalletReferentiTableController.AssegnaReferenti(mw.id, referenti, referenti);
        Test.stopTest();

    }

    @isTest
    public static void getReferentePrimarioName(){

        // BASE DATI
        String miniWalletName = 'nomeDelMiniWallet';

        Account filiale = new Account();
        filiale.Name = 'filialeTest';

        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('AltraUnitaOrganizzativa').getRecordTypeId();
        
        filiale.RecordTypeId = RecordTypeIdAccount;
        filiale.PTF_IdCEDPadre__c = '10';
        filiale.PTF_Livello__c = '210';
        
        insert filiale;

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

        pfiliale.PTF_Portafoglio__c = wallet.id;
        update pfiliale;

        Contact contact = new Contact();
        contact.FirstName = 'Test43039';
        contact.LastName = 'Test43039';
        insert contact;

        MiniWallet__c mw = new MiniWallet__c();
        mw.Name = 'Test43039';
        mw.PTF_Portafoglio__c = wallet.id;
        mw.Referente__c = contact.id;
        mw.PTF_SL__c = pfiliale.Id;
        insert mw;

        // FINE BASE DATI

        Test.startTest();
            //String nomeReferentePrimario = miniWalletReferentiTableController.getReferentePrimarioName(mw.id);
        Test.stopTest();

       // System.assertEquals(true, nomeReferentePrimario == 'Test43039 Test43039', 'errore in recupero nome referente primario mini wallet');

    }
}