@isTest
public with sharing class WGC_TrgAccount_Test {

    @isTest
    public static void Test_manageAccountUsers1(){
         //Test.stopTest();
         
        WGC_AllDataFactory.createUtenzaDefault();

        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Amministratore del sistema' LIMIT 1].Id;
        Id notAdminProfileId = [SELECT Id FROM Profile WHERE Name != 'System Administrator' AND Name != 'Amministratore del sistema' AND Name = 'IFIS - Sviluppo Commerciale Filiali' LIMIT 1].Id;

        User manager = new User(Alias = 'User6', Email='UserSix@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserSix@testorg.com', LastName = 'UserSix', ProfileId = notAdminProfileId, LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', Qualifica_Utente__c = 'Finanza Strutturata');

        insert manager;

        List<User> users = new List<User>();// WGC_AllDataFactory.createUser(6,true);
        User systemAdmin = new User(Alias = 'User1', Email='UserOne@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserOne@testorg.com', LastName = 'UserOne', ProfileId = adminProfileId, Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles',ManagerId=manager.Id);
        User filoDiretto = new User(Alias = 'User2', Email='UserTwo@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserTwo@testorg.com', LastName = 'UserTwo', ProfileId = notAdminProfileId, Qualifica_Utente__c = 'Filo Diretto', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles',ManagerId=manager.Id);
        User sviluppoCommerciale = new User(Alias = 'User3', Email='UserThree@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserThree@testorg.com', LastName = 'UserThree', ProfileId = notAdminProfileId, Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles',ManagerId=manager.Id);
        User creditiErariali = new User(Alias = 'User4', Email='UserFour@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserFour@testorg.com', LastName = 'UserFour', ProfileId = notAdminProfileId, Qualifica_Utente__c = 'Crediti Erariali', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles',ManagerId=manager.Id);
        User elseUser = new User(Alias = 'User5', Email='UserFive@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserFive@testorg.com', LastName = 'UserFive', ProfileId = notAdminProfileId, LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', Qualifica_Utente__c = 'Finanza Strutturata',ManagerId=manager.Id);

        users.add(systemAdmin);
        users.add(filoDiretto);
        users.add(sviluppoCommerciale);
        users.add(creditiErariali);
        users.add(elseUser);

        insert users;

        Comune__c com = new Comune__c(Cap__c='10000',Name='CITY',Provincia__c = 'MI');
        insert com;

        List<AssegnazioneAnagrafica__c> aa = new List<AssegnazioneAnagrafica__c>();
        aa.add(new AssegnazioneAnagrafica__c(CAP__c = '10000', Comune__c = com.Id, Utente__c = filoDiretto.Id));
        aa.add(new AssegnazioneAnagrafica__c(CAP__c = '10000', Comune__c = com.Id, Utente__c = sviluppoCommerciale.Id));
        aa.add(new AssegnazioneAnagrafica__c(CAP__c = '10000', Comune__c = com.Id, Utente__c = creditiErariali.Id));
        aa.add(new AssegnazioneAnagrafica__c(CAP__c = '10000', Comune__c = com.Id, Utente__c = elseUser.Id));

        insert aa;
		
        Test.startTest();
        System.runAs(systemAdmin) {
            insert new Account(Name = 'Account1', BillingPostalCode = '10000', BillingCity = 'CITY',Filiale__c='004', BillingState = 'MI');
        }
        System.runAs(filoDiretto) {
            insert new Account(Name = 'Account2', BillingPostalCode = '10000', BillingCity = 'CITY', BillingState = 'MI');
        }
        System.runAs(sviluppoCommerciale) {
            insert new Account(Name = 'Account3', BillingPostalCode = '10000', BillingCity = 'CITY', BillingState = 'MI');
        }
        System.runAs(creditiErariali) {
            insert new Account(Name = 'Account4', BillingPostalCode = '10000', BillingCity = 'CITY', BillingState = 'MI');
        }

        /*
        System.runAs(elseUser) {
            insert new Account(Name = 'Account5', BillingPostalCode = '10000', BillingCity = 'CITY', WGC_Richiesta_Approvata__c = false);
        }
		*/
        Test.stopTest();
    }

    @isTest
    public static void test2(){
        WGC_AllDataFactory.createUtenzaDefault();
        Id notAdminProfileId = [SELECT Id FROM Profile WHERE Name != 'System Administrator' AND Name != 'Amministratore del sistema' AND Name = 'IFIS - Sviluppo Commerciale Filiali' LIMIT 1].Id;

        User manager = new User(Alias = 'User6', Email='UserSix@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserSix@testorg.com', LastName = 'UserSix', ProfileId = notAdminProfileId, LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', Qualifica_Utente__c = 'Finanza Strutturata');
        insert manager;

        User leasingUser = new User(Alias = 'User6', Email='UserThree@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserSeven@testorg.com', LastName = 'UserThree', ProfileId = notAdminProfileId, Qualifica_Utente__c = 'Leasing EF', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles',ManagerId=manager.Id);
        insert leasingUser;

        Comune__c com = new Comune__c(Cap__c='10000',Name='CITY',Provincia__c = 'MI');
        insert com;

        List<AssegnazioneAnagrafica__c> aa = new List<AssegnazioneAnagrafica__c>();
        aa.add(new AssegnazioneAnagrafica__c(CAP__c = '10000', Comune__c = com.Id, Utente__c = leasingUser.Id));
        insert aa;

        Test.startTest();
        System.runAs(leasingUser) {
            insert new Account(Name = 'Account4', BillingPostalCode = '10000', BillingCity = 'CITY', BillingState = 'MI');
        }
        Test.stopTest();
    }

    @isTest
    public static void test3(){
        WGC_AllDataFactory.createUtenzaDefault();
        Id notAdminProfileId = [SELECT Id FROM Profile WHERE Name != 'System Administrator' AND Name != 'Amministratore del sistema' AND Name = 'IFIS - Sviluppo Commerciale Filiali' LIMIT 1].Id;
        User manager = new User(Alias = 'User6', Email='UserSix@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserSix@testorg.com', LastName = 'UserSix', ProfileId = notAdminProfileId, LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', Qualifica_Utente__c = 'Finanza Strutturata');
        insert manager;

        User leasingUser = new User(Alias = 'User6', Email='UserThree@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserSeven@testorg.com', LastName = 'UserThree', ProfileId = notAdminProfileId, Qualifica_Utente__c = 'Leasing TR', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles',ManagerId=manager.Id);
        insert leasingUser;

        Comune__c com = new Comune__c(Cap__c='10000',Name='CITY',Provincia__c = 'MI');
        insert com;

        List<AssegnazioneAnagrafica__c> aa = new List<AssegnazioneAnagrafica__c>();
        aa.add(new AssegnazioneAnagrafica__c(CAP__c = '10000', Comune__c = com.Id, Utente__c = leasingUser.Id));
        insert aa;

        Test.startTest();
        System.runAs(leasingUser) {
            insert new Account(Name = 'Account4', BillingPostalCode = '10000', BillingCity = 'CITY', BillingState = 'MI');
        }
        Test.stopTest();
    }

    @isTest
    public static void test4(){
        WGC_AllDataFactory.createUtenzaDefault();
        Id notAdminProfileId = [SELECT Id FROM Profile WHERE Name != 'System Administrator' AND Name != 'Amministratore del sistema' AND Name = 'IFIS - Sviluppo Commerciale Filiali' LIMIT 1].Id;

        User manager = new User(Alias = 'User6', Email='UserSix@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserSix@testorg.com', LastName = 'UserSix', ProfileId = notAdminProfileId, LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', Qualifica_Utente__c = 'Finanza Strutturata');
        insert manager;

        User leasingUser = new User(Alias = 'User6', Email='UserThree@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserSeven@testorg.com', LastName = 'UserThree', ProfileId = notAdminProfileId, Qualifica_Utente__c = 'IFIS_International', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles',ManagerId=manager.Id);
        insert leasingUser;

        Comune__c com = new Comune__c(Cap__c='10000',Name='CITY',Provincia__c = 'MI');
        insert com;

        List<AssegnazioneAnagrafica__c> aa = new List<AssegnazioneAnagrafica__c>();
        aa.add(new AssegnazioneAnagrafica__c(CAP__c = '10000', Comune__c = com.Id, Utente__c = leasingUser.Id));
        insert aa;

        Test.startTest();
        System.runAs(leasingUser) {
            insert new Account(Name = 'Account4', BillingPostalCode = '10000', BillingCity = 'CITY', BillingState = 'MI');
        }
        Test.stopTest();
    }

    @isTest
    public static void test5(){
        WGC_AllDataFactory.createUtenzaDefault();
        Id notAdminProfileId = [SELECT Id FROM Profile WHERE Name != 'System Administrator' AND Name != 'Amministratore del sistema' AND Name = 'IFIS - Sviluppo Commerciale Filiali' LIMIT 1].Id;

        User manager = new User(Alias = 'User6', Email='UserSix@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserSix@testorg.com', LastName = 'UserSix', ProfileId = notAdminProfileId, LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', Qualifica_Utente__c = 'Finanza Strutturata');
        insert manager;

        User leasingUser = new User(Alias = 'User6', Email='UserThree@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserSeven@testorg.com', LastName = 'UserThree', ProfileId = notAdminProfileId, Qualifica_Utente__c = 'Finanza Strutturata', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles',ManagerId=manager.Id);
        insert leasingUser;

        Comune__c com = new Comune__c(Cap__c='10000',Name='CITY',Provincia__c = 'MI');
        insert com;

        List<AssegnazioneAnagrafica__c> aa = new List<AssegnazioneAnagrafica__c>();
        aa.add(new AssegnazioneAnagrafica__c(CAP__c = '10000', Comune__c = com.Id, Utente__c = leasingUser.Id));
        insert aa;

        Test.startTest();
        System.runAs(leasingUser) {
            insert new Account(Name = 'Account4', BillingPostalCode = '10000', BillingCity = 'CITY', BillingState = 'MI');
        }
        Test.stopTest();
    }

    @isTest
    public static void test6(){
        WGC_AllDataFactory.createUtenzaDefault();
        Id notAdminProfileId = [SELECT Id FROM Profile WHERE Name != 'System Administrator' AND Name != 'Amministratore del sistema' AND Name = 'IFIS - Sviluppo Commerciale Filiali' LIMIT 1].Id;

        User manager = new User(Alias = 'User6', Email='UserSix@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserSix@testorg.com', LastName = 'UserSix', ProfileId = notAdminProfileId, LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', Qualifica_Utente__c = 'Finanza Strutturata');
        insert manager;

        User leasingUser = new User(Alias = 'User6', Email='UserThree@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserSeven@testorg.com', LastName = 'UserThree', ProfileId = notAdminProfileId, Qualifica_Utente__c = 'Finanza Strutturata', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles',ManagerId=manager.Id);
        insert leasingUser;

        Comune__c com = new Comune__c(Cap__c='10000',Name='CITY',Provincia__c = 'MI');
        insert com;


        Account aa = new Account(Name = 'Account4', BillingPostalCode = '10000', BillingCity = 'CITY', BillingState = 'MI');
        insert aa;

        Test.startTest();
        WGC_TrgAccount.unlockBlockedAccount(new List<String>{aa.Id});
        Test.stopTest();
    }

    @isTest
    public static void test7(){
        WGC_AllDataFactory.createUtenzaDefault();
        Id AdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Amministratore del sistema' LIMIT 1].Id;
        User manager = new User(Alias = 'User6', Email='UserSix@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserSix@testorg.com', LastName = 'UserSix', ProfileId = AdminProfileId, LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', Qualifica_Utente__c = 'Finanza Strutturata');
        insert manager;

        User leasingUser = new User(Alias = 'User6', Email='UserThree@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserSeven@testorg.com', LastName = 'UserThree', ProfileId = AdminProfileId, Qualifica_Utente__c = 'Finanza Strutturata', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles',ManagerId=manager.Id);
        insert leasingUser;

        Comune__c com = new Comune__c(Cap__c='10000',Name='CITY',Provincia__c = 'MI');
        insert com;

        List<AssegnazioneAnagrafica__c> aa = new List<AssegnazioneAnagrafica__c>();
        aa.add(new AssegnazioneAnagrafica__c(CAP__c = '10000', Comune__c = com.Id, Utente__c = leasingUser.Id));
        insert aa;

        Test.startTest();
        System.runAs(leasingUser) {
            insert new Account(Name = 'Account4', BillingPostalCode = '10000', BillingCity = 'CITY', BillingState = 'MI');
        }
        Test.stopTest();
    }
}