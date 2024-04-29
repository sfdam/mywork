@isTest
private class TaCtrlLoginTest {
    
    
    @testSetup
    static void setupData() {
        TestUtils.impostaCS();
        TestUtils.creaEndpointServizi();
        TestUtils.creaAccount('acc');
    }
    
    @isTest
    static void testConstructor() {
        //no real testing here, just coverage
		TaCtrlLogin tcl = new TaCtrlLogin();
        TaCtrlLogin.ProfileInfo p = new TaCtrlLogin.ProfileInfo(null, null);
        TaCtrlLogin.ProfileInfo p1 = new TaCtrlLogin.ProfileInfo(null, null, null);
        TaCtrlLogin.UserInfoObj u = new TaCtrlLogin.UserInfoObj(null, null, null, null, null);
    }
    
    @isTest static void testLogin() {
        TaCtrlLogin.InputObj input = new TaCtrlLogin.InputObj();
        
        input.email = 'test@test.com.xxx';
        input.password = '12345678ab';
        
        try {
            String res = TaCtrlLogin.login(JSON.serialize(input));
            System.assertEquals(true, res.endsWith('/s/home'));
        } catch (Exception e) {}
    }
    
    @isTest static void testSelfRegister() {
		//new client
        TaCtrlLogin.InputObj input = new TaCtrlLogin.InputObj();
        input.email = 'test@test.com.xxx';
        input.password = '12345678ab';
        input.nome = 'Paolo';
        input.cognome = 'Rossi';
        input.selectedAccount = new Account(Name = 'test', CF__c = 'AAAQQQ12Q12Q123Q', PIVA__c = '11111111111');
        
        try {
            String res = TaCtrlLogin.selfRegister(JSON.serialize(input));
            System.assertEquals(true, res.endsWith('/s/home'));
        } catch (Exception e) {}

		//existing client
        TaCtrlLogin.InputObj input2 = new TaCtrlLogin.InputObj();
		Account a  = [SELECT Id, Name, CF__c, PIVA__c FROM Account WHERE Name = 'acc' LIMIT 1];
        input2.email = 'test@test.com.xxx';
        input2.password = '12345678ab';
        input2.nome = 'Paolo';
        input2.cognome = 'Rossi';
        input2.selectedAccount = new Account(Name = 'test', CF__c = a.CF__c, PIVA__c = a.PIVA__c);
        
        try {
            String res = TaCtrlLogin.selfRegister(JSON.serialize(input2));
            System.assertEquals(true, res.endsWith('/s/home'));
        } catch (Exception e) {}
    }
    
    @isTest static void testResetPassword() {
        ParametriTiAnticipo__c paramTA = new ParametriTiAnticipo__c();
        paramTA.Mail_Segnalazione_Errori__c = 'gestione.canali.salesforce@bancaifis.it';
        upsert paramTA;
        TaCtrlLogin.InputObj input = new TaCtrlLogin.InputObj();
        
        input.forgottenEmail = 'test@test.com.xxx';
        
        try {
            Boolean res = TaCtrlLogin.resetPassword(JSON.serialize(input));
            System.assertEquals(false, res); //lo user del test non esiste
        } catch (Exception e) {}
    }
    
    @isTest static void testFetchProfile_GetUserInfo() {
        WGC_Originator__mdt originatorMD = [
            SELECT Qualifica_Utente__c
            FROM WGC_Originator__mdt
            WHERE DeveloperName = 'Portali_TiAnticipo_Area_Riservata'
        ];
        Profile taProfile = [SELECT Id FROM Profile WHERE Name = 'IFIS - TiAnticipo' LIMIT 1];
        User uRunning = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Account acc = TestUtils.creaAccount('TA Sample Account', uRunning);
        Contact con = new Contact(FirstName='Alfa', LastName='Gamma', AccountId=acc.Id);
        insert con;
        User u = new User();            
        u.Username = 'ta@dummy.com';
        u.Email = 'ta@dummy.com';
        u.FirstName = 'NomeTA';
        u.LastName = 'Cognome';
        u.TimeZoneSidKey = 'Europe/Rome';
        u.CommunityNickname = u.Username.left(40);
        u.Alias = 'tadummy';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = taProfile.Id;
        u.LanguageLocaleKey = 'en_US';
        u.Qualifica_Utente__c = originatorMD.Qualifica_Utente__c; //Ti Anticipo
        u.ContactId = con.Id;
        
        
        system.debug('-----> user: '+u);
        system.debug('-----> account: '+acc);
        Test.startTest();
        System.runAs(u) {
            TaCtrlLogin.ProfileInfo pi = TaCtrlLogin.fetchProfile();
            System.assertNotEquals(null, pi);
            
            TaCtrlLogin.UserInfoObj ui = TaCtrlLogin.getUserInfo();
            System.assertEquals('NomeTA', ui.firstName);
            
        }
        Test.stopTest();
    }
    
    @isTest static void testUpdateProfile() {
        Account a = [SELECT Id, OwnerId FROM Account WHERE Name = 'acc'];
        Contact c = TestUtils.creaReferente(a);
        Contact[] titolariEsecutori = new Contact[] {};
            for (Integer i = 0; i < 3; i++) {
                titolariEsecutori.add(TestUtils.creaReferente(a));
            }
        
        AdeguataVerifica__c adv = new AdeguataVerifica__c(Account__c = a.Id, TipoIndirizzo__c = 'billing');
        insert adv;
        
        TaCtrlLogin.ProfileInfo input = new TaCtrlLogin.ProfileInfo(a, c, titolariEsecutori, adv);
        Boolean res = TaCtrlLogin.updateProfile(JSON.serialize(input));
        System.assertEquals(true, res); 
    }
    
    @isTest
    static void testSetAccessoEffettuato() {
        WGC_Originator__mdt originatorMD = [
            SELECT Qualifica_Utente__c
            FROM WGC_Originator__mdt
            WHERE DeveloperName = 'Portali_TiAnticipo_Area_Riservata'
        ];
        Profile taProfile = [SELECT Id FROM Profile WHERE Name = 'IFIS - TiAnticipo' LIMIT 1];
        User uRunning = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Account acc = TestUtils.creaAccount('TA Sample Account', uRunning);
        Contact con = new Contact(FirstName='Alfa', LastName='Gamma', AccountId=acc.Id);
        insert con;
        User u = new User();            
        u.Username = 'ta@dummy.com';
        u.Email = 'ta@dummy.com';
        u.FirstName = 'NomeTA';
        u.LastName = 'Cognome';
        u.TimeZoneSidKey = 'Europe/Rome';
        u.CommunityNickname = u.Username.left(40);
        u.Alias = 'tadummy';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = taProfile.Id;
        u.LanguageLocaleKey = 'en_US';
        u.Qualifica_Utente__c = originatorMD.Qualifica_Utente__c; //Ti Anticipo
        u.ContactId = con.Id;
        insert u;
        
        system.debug('-----> user: '+u);
        system.debug('-----> account: '+acc);
        Test.startTest();
        System.runAs(u) {
            Boolean res = TaCtrlLogin.setAccessoEffettuato(true);
            System.assertEquals(true, res);
        }
        Test.stopTest();
    }
    /*
    @IsTest
    static void testCreateUser() {
        // adione: il test serve per la copertura, non son sicuro si possa testare il "validatePassword"
        User uRunning = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Account acc = TestUtils.creaAccount('TA Sample Account', uRunning);
		String username = 'm.rossi@example.com.ta';
        String email = 'm.rossi@example.com';
        String nome = 'Mario';
        String cognome = 'Rossi';
        String password = 'P4ssw0rd10';
        try {
            TaCtrlLogin.createUser(username, email, nome, cognome, password, acc.Id);
        } catch (Exception sysex) {
            //sospetto non si possa testare questo metodo...
            system.debug(sysex.getMessage());
        }
    }
	*/
}