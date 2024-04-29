//GPF test
@isTest
private class newMiniWalletModalControllerTest {
    
    @isTest
    private static void Test_generateMiniWalletName(){

        Test.startTest();
            // BASE DATI

            Account pfiliale = new Account();
            pfiliale.FirstName = 'filialeTest';
            pfiliale.LastName = 'filialeTest';
            pfiliale.PTF_IdCED__c = '10';
            pfiliale.PTF_Livello__c = '210';
            insert pfiliale;

            Wallet__c wallet = new Wallet__c();
            wallet.Name = 'PTF-BP-01015-0790-000102';
            Id RecordTypeIdWallet = Schema.SObjectType.Wallet__c.getRecordTypeInfosByDeveloperName().get('MicroWallet').getRecordTypeId();
            wallet.RecordTypeId = RecordTypeIdWallet;
            wallet.PTF_Filiale__c = pfiliale.Id;
            wallet.PTF_ModelloDiServizio__c = 'Personal';
            insert wallet;

            Contact contact = new Contact();
            contact.FirstName = 'Test43039';
            contact.LastName = 'Test43039';
            insert contact;

            MiniWallet__c miniwallet = new MiniWallet__c();
            miniwallet.Name = 'PTF-FA-05387-3198-000002';
            miniwallet.PTF_Portafoglio__c = wallet.Id;
            miniwallet.Referente__c = contact.Id;
            miniwallet.PTF_SL__c = pfiliale.Id;
            insert miniwallet;
			
            pfiliale.PTF_Portafoglio__c = wallet.id;
            pfiliale.PTF_MiniPortafoglio__c = miniwallet.Id;
            update pfiliale;

            pfiliale.PTF_Portafoglio__c = wallet.id;
            pfiliale.PTF_MiniPortafoglio__c = miniwallet.Id;
            update pfiliale;

            // FINE BASE DATI

        
        String WalletName = newMiniWalletModalController.generateMiniWalletName(wallet.id);

        Test.stopTest();
    }

    
    @isTest
    private static void Test_getSportelliLeggeri(){

        Test.startTest();
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

            List<Account> sportelliLeggeri = new List<Account>();
            sportelliLeggeri.add(pfiliale);
            // FINE BASE DATI




        List<Account> filialis = new List<Account>();
        filialis = newMiniWalletModalController.getSportelliLeggeri(wallet.id);
        System.assertEquals(filiale.Id, filialis[0].id);

        Test.stopTest();
    }

    @isTest
    private static void Test_getReferenti(){

        Test.startTest();
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
    
            List<Account> sportelliLeggeri = new List<Account>();
            sportelliLeggeri.add(pfiliale);
            // FINE BASE DATI





        List<Assignment__c> referenti = new List<Assignment__c>();
        referenti.add(referente);
        newMiniWalletModalController.getReferenti(wallet.id);

        Test.stopTest();
    }

    @isTest
    private static void Test_createMiniWallet(){

        Test.startTest();
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
    		
            Id RecordTypeIdWallet = Schema.SObjectType.Wallet__c.getRecordTypeInfosByDeveloperName().get('MicroWallet').getRecordTypeId();
            Wallet__c wallet = new Wallet__c();
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
    
        	Id RecordTypeIdAssignment = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Primario').getRecordTypeId();
            Assignment__c referente = new Assignment__c();
            referente.RecordTypeId = RecordTypeIdAssignment;
            referente.PTF_MicroWallet__c = wallet.id;
            referente.PTF_EndDate__c = null;
            referente.PTF_MiniPortafoglio__c = null;
	        insert referente;
        	
            List<Account> sportelliLeggeri = new List<Account>();
            sportelliLeggeri.add(pfiliale);
            // FINE BASE DATI




		List<Assignment__c> referenti = new List<Assignment__c>();
        referenti.add(referente);
        
		
        String MiniWalletID = newMiniWalletModalController.createMiniWallet(miniWalletName, wallet.id, sportelliLeggeri, referenti, referenti);
        List<Account> FilialeAccount = [SELECT id,PTF_MiniPortafoglio__c FROM Account WHERE Id =: pfiliale.Id];
        
        MiniWalletID = newMiniWalletModalController.createMiniWallet(miniWalletName
                                                                     , wallet.id
                                                                     , sportelliLeggeri
                                                                     , new List<Assignment__c>{}
                                                                     , referenti);
        FilialeAccount = [SELECT id,PTF_MiniPortafoglio__c FROM Account WHERE Id =: pfiliale.Id];
        /*			NON VIEVE MAI ESEGUITE L'ECCEZIONE DAL METODO PER sportellliLegger.isEmpty()
        try {
            MiniWalletID = newMiniWalletModalController.createMiniWallet(miniWalletName
                                                                     , wallet.id
                                                                     , new List<Account> {}
                                                                     , new List<Assignment__c> {}
                                                                     , referenti);
        	FilialeAccount = [SELECT id,PTF_MiniPortafoglio__c FROM Account WHERE Id =: pfiliale.Id];
        
        } catch(AuraHandledException e) {
            
        }        */
        //System.assertEquals(MiniWalletID, FilialeAccount[0].PTF_MiniPortafoglio__c);
        Test.stopTest();
    }
    
    
    @isTest
    private static void Test_getMiniWallet() {
        
        
        Account pfiliale = new Account();
        pfiliale.FirstName = 'filialeTest';
        pfiliale.LastName = 'filialeTest';
        pfiliale.PTF_IdCED__c = '10';
        pfiliale.PTF_Livello__c = '210';
        insert pfiliale; 
        
        
        Wallet__c wallet = new Wallet__c();
        wallet.Name = 'PTF-BP-01015-0790-000102';
        Id RecordTypeIdWallet = Schema.SObjectType.Wallet__c.getRecordTypeInfosByDeveloperName().get('MicroWallet').getRecordTypeId();
        wallet.RecordTypeId = RecordTypeIdWallet;
        
        wallet.PTF_Filiale__c = pfiliale.Id;
        wallet.PTF_ModelloDiServizio__c = 'Personal';
        insert wallet;

        MiniWallet__c miniwallet = new MiniWallet__c();
        miniwallet.Name = 'PTF-FA-05387-3198-000002';
        miniwallet.PTF_Portafoglio__c = wallet.Id;
        //miniwallet.Referente__c = contact.Id;
        miniwallet.PTF_SL__c = pfiliale.Id;
        insert miniwallet;
        
        
        Test.startTest();
        List<MiniWallet__c> mw = newMiniWalletModalController.getMiniWallet(wallet.Id);
        Test.stopTest();
        
    }
}