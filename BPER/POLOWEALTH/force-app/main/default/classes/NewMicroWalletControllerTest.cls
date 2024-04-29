/**
*
* @author  Dam Kebe @Lutech
* @version 1.0
* @since   2020-07-27
*/
@isTest
public class NewMicroWalletControllerTest {
    
    @TestSetup
    public static void setup(){

        
		Funzionalita__c x= new Funzionalita__c();
        x.Disable_Trigger__c=true;
        insert x;

        Profile profile = [SELECT id FROM Profile WHERE Name=: Label.System_Administrator LIMIT 1];
        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        User user2 = AllDataFactory.getUser('02', profile.Id, 'CORPORATE');
        User user3 = AllDataFactory.getUser('03', profile.Id, 'CORPORATE');
        User user4 = AllDataFactory.getUser('04', profile.Id, 'Private');
        User user5 = AllDataFactory.getUser('05', profile.Id, 'Private');
        insert new List<User>{user, user2, user3, user4, user5};
            System.runAs(user){
                Account account = AllDataFactory.getAccount('01', 'Banca');
                account.PTF_IdCED__c='1716';
        Account account2 = AllDataFactory.getAccount('02', 'DirezioneRegionale');
        account2.PTF_IdCED__c='8414';        
        Account account3 = AllDataFactory.getAccount('03', 'Area');
        account3.PTF_IdCED__c='5071';        
        Account account4 = AllDataFactory.getAccount('04', 'FilialeDiRelazione');

        Account account7 = AllDataFactory.getAccount('07', 'FilialeDiRelazione');
        account7.PTF_IdCED__c = '27926';
               
        insert new List<Account>{account, account2, account3, account7};
        Account account5 = AllDataFactory.getAccount('05', 'AltraUnitaOrganizzativa');
        Account5.PTF_IdCEDPadre__c='1716';
        insert account5;
        Account account6 = AllDataFactory.getAccount('06', 'AltraUnitaOrganizzativa');
        account6.PTF_IdCEDPadre__c='8414';
        account6.PTF_Livello__c = '180';
        account6.FinServ__BankNumber__c = '03084';
        account6.PTF_IdCed__c = '27926';
        insert account6;  
		account4.PTF_IdCEDFiliale__c='2499';
        account4.PTF_Banca__c=account.Id;
        account4.PTF_DirezioneRegionale__c=account2.Id;
        account4.PTF_Area__c=account3.Id;
        account4.FinServ__BankNumber__c = '05387';
        account4.PTF_UffPrivate__c = account6.Id;
        insert account4;        

        Struttura_Banca__c sb1 = new Struttura_Banca__c(
            IdCed__c='27926',
            Descrizione__c ='T12347',
            Stato__c='A',
            ABI__c = '03084',
            Livello__c = '200'
        );
        insert sb1;
        
        ConfigUffPrivateDR__c configUffPrivateDR = new ConfigUffPrivateDR__c();
        configUffPrivateDR.Name = 'TEST';
        configUffPrivateDR.PTF_DR__c = account2.Id;
        configUffPrivateDR.PTF_UffPrivate__c = account6.Id;
        configUffPrivateDR.PTF_IdCP__c='CP1';
        Insert configUffPrivateDR;

        Contact contact = AllDataFactory.getContact('01', user.Id, account4.Id);
        contact.PTF_ReferenteElegibile__c=true;        
        Contact contact2 = AllDataFactory.getContact('02', user2.Id, account4.Id);
        contact2.PTF_ReferenteElegibile__c=true;        
        Contact contact3 = AllDataFactory.getContact('03', user3.Id, account4.Id);
        contact3.PTF_ReferenteElegibile__c=true;
        Contact contact5 = AllDataFactory.getContact('04', user3.Id, account3.Id);
        contact5.PTF_ReferenteElegibile__c=true;
        Contact contact6 = AllDataFactory.getContact('05', user3.Id, account5.Id);
        contact6.PTF_ReferenteElegibile__c=true; 
        Contact contact7 = AllDataFactory.getContact('06', user3.Id, account6.Id);
        contact7.PTF_ReferenteElegibile__c=true;        
        insert new List<Contact>{contact, contact2, contact3, contact5, contact6, contact7};

        Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet', 'Filiale di Milano', 'CORPORATE');
        insert microPortafoglio;

        Assignment__c primarioAssignment = AllDataFactory.getAssignment('Primario', microPortafoglio.Id, contact.Id);
        insert primarioAssignment;

        Account banca= AllDataFactory.getAccount('Banca','Banca');
        banca.FinServ__BankNumber__c='05387';
		banca.PTF_IdCED__c='1234';
        insert banca;
        
        Account a = new Account();
        a.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Account', 'AltraUnitaOrganizzativa');
        a.Name = 'UFF. Private test';
        a.PTF_IdCED__c = '998';
        a.PTF_IdCEDPadre__c='10031';
        insert a;
        Account d = new Account();
        d.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Account', 'DirezioneRegionale');
        d.Name = 'UFF. Private test2';
        d.PTF_IdCED__c = '10030';
        d.PTF_IdCEDPadre__c='10031';
        insert d;
        Account e = new Account();
        e.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Account', 'DirezioneRegionale');
        e.Name = 'Executive';
        e.PTF_IdCED__c = '10031';
        insert e;
        Account b = new Account();
        b.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Account', 'DirezioneRegionale');
        b.Name = 'Direzione Reg Test';
        b.PTF_IdCED__c = '991';
        insert b;
        ConfigUffPrivateDR__c c = new ConfigUffPrivateDR__c();
        c.Name = 'TEST';
        c.PTF_DR__c = b.Id;
        c.PTF_UffPrivate__c = a.Id;
        c.PTF_IdCP__c='CP1';
        Insert c;
        
        Account area = AllDataFactory.getAccount('Area','Area');
        area.PTF_DirezioneRegionale__c=b.Id;
        area.PTF_Banca__c=banca.Id;
        area.PTF_IdCED__c='123456';
        insert area;


        Account filiale = AllDataFactory.getAccount('11', 'FilialeDiRelazione');
        filiale.PTF_BranchTypology__c='A';
        filiale.PTF_Area__c= area.Id;
        filiale.PTF_Banca__c=banca.Id;
        filiale.PTF_DirezioneRegionale__c=b.Id;
        filiale.PTF_IdCED__c='1238';
        filiale.PTF_IdCEDFiliale__c='1238';
        filiale.PTF_IdCedUffPrivate__c = '10030';
        Account filiale2 = AllDataFactory.getAccount('12', 'FilialeDiRelazione');
        filiale2.PTF_Division__c='PR';
        filiale2.PTF_MacroDivision__c='WM';
        filiale2.PTF_Area__c= area.Id;
        filiale2.PTF_Banca__c=banca.Id;
        filiale2.PTF_DirezioneRegionale__c=b.Id;
        filiale2.PTF_BranchTypology__c='F';
        filiale2.PTF_IdCED__c='1239';
        filiale2.PTF_IdCEDFiliale__c='1239';
        insert new List<Account>{filiale, filiale2};
        Account uff = AllDataFactory.getAccount('22', 'AltraUnitaOrganizzativa');
        uff.PTF_IdCED__c='937';
        uff.PTF_Banca__c=banca.Id;
        uff.PTF_IdCEDPadre__c='1234';
        insert uff;
        Contact contact4 = AllDataFactory.getContact('14', user3.Id, filiale.Id);
        Contact supervisor = AllDataFactory.getContact('16', user5.Id, d.Id);
        Contact executive = AllDataFactory.getContact('15', user4.Id, e.Id);
        insert new List<Contact>{contact4, supervisor, executive};

        Group groupMMDS = new group();
        groupMMDS.Name = 'RIDCED1238_PR';
        groupMMDS.DeveloperName = 'RIDCED1238_PR';
        insert groupMMDS;

        ServiceModel__c sm1= new ServiceModel__c();
        sm1.Name='Private';
        sm1.PTF_NameAbbreviation__c = 'PR';
        sm1.PTF_TresholdPTF__c=0;
        ServiceModel__c sm2= new ServiceModel__c();
        sm2.Name='CORPORATE';
        sm2.PTF_TresholdPTF__c=99;
        ServiceModel__c sm3= new ServiceModel__c();
        sm3.Name='Consulenti Finanziari';
        sm3.PTF_TresholdPTF__c=99;
        insert new List<ServiceModel__c>{sm1, sm2, sm3};        
            }
        
        
    }

    @isTest
    public static void testGetAllData(){

        NewMicroWalletController.WrapperObj response = NewMicroWalletController.getAllData();
    }

    @isTest
    public static void testGetAllModelli(){

        List<String> response = NewMicroWalletController.getAllModelli();
    }

    @isTest
    public static void testGetGestoriPrincipaliPrivate(){

        Account filiale = [SELECT Id FROM Account WHERE Name = 'Account04' LIMIT 1];
        Map<String, SObject> response = NewMicroWalletController.getGestoriPrincipaliPrivate(filiale.Id, 'Private', '10030','', false, false,'10030', null);
    }
    

    @isTest
    public static void testGetGestoriPrincipali(){

        Account filiale = [SELECT Id FROM Account WHERE Name = 'Account04' LIMIT 1];
        Map<String, SObject> response = NewMicroWalletController.getGestoriPrincipali(filiale.Id, 'CORPORATE', false, false);
    }
    
    @isTest
    public static void testGetGestoriPrincipali2(){

        Account filiale = [SELECT Id FROM Account WHERE Name = 'Account04' LIMIT 1];
        Map<String, SObject> response = NewMicroWalletController.getGestoriPrincipali(filiale.Id, 'Consulenti Finanziari', false, false);
    }

    @isTest
    public static void testGetGestoriPrincipali3(){

        Account filiale = [SELECT Id FROM Account WHERE Name = 'Account04' LIMIT 1];
        Map<String, SObject> response = NewMicroWalletController.getGestoriPrincipali(filiale.Id, 'Private', false, false);
    }

    @isTest
    public static void testGetGestoriBackupPrivate(){

        Account filiale = [SELECT Id FROM Account WHERE Name = 'Account04' LIMIT 1];
        Map<String, SObject> response = NewMicroWalletController.gestoriBackupPrivate(filiale.Id, 'Private','10030','','10030', null);
    }
    
    @isTest
    public static void testGetGestoriBackup(){

        Account filiale = [SELECT Id FROM Account WHERE Name = 'Account04' LIMIT 1];
        Map<String, SObject> response = NewMicroWalletController.getGestoriBackup(filiale.Id, 'CORPORATE', false, false);
    }
    @isTest
    public static void testGetGestoriBackup2(){

        Account filiale = [SELECT Id FROM Account WHERE Name = 'Account04' LIMIT 1];
        Map<String, SObject> response = NewMicroWalletController.getGestoriBackup(filiale.Id, 'Consulenti Finanziari', false, false);
    }

    @isTest
    public static void testGetGestoriBackup3(){

        Account filiale = [SELECT Id FROM Account WHERE Name = 'Account04' LIMIT 1];
        Map<String, SObject> response = NewMicroWalletController.getGestoriBackup(filiale.Id, 'Private', false, false);
    }

    @isTest
    public static void testSaveSingleMicroWallet(){

        
		Test.startTest();
        Account banca = [SELECT Id FROM Account WHERE Name = 'Account01' LIMIT 1];
        Account dirReg = [SELECT Id FROM Account WHERE Name = 'Account02' LIMIT 1];
        Account area = [SELECT Id FROM Account WHERE Name = 'Account03' LIMIT 1];
        Account filiale = [SELECT Id FROM Account WHERE Name = 'Account04' LIMIT 1];
        List<Contact> contactList = [SELECT id FROM Contact WHERE Account.Name = 'Account04'];
       
        Boolean response = NewMicroWalletController.saveMicroWallet(filiale.Id, banca.Id, dirReg.Id, area.id, filiale.Id, 'Consulenti Finanziari', 1, new list<String>{contactList[0].id}, new list<String>{contactList[1].id}, '', false, false,'', '');
        Test.stopTest();
    }

    @isTest
    public static void testSaveSingleMicroWalletPrivate(){

        
		Test.startTest();
        Account banca = [SELECT Id FROM Account WHERE Name = 'Account01' LIMIT 1];
        Account dirReg = [SELECT Id FROM Account WHERE Name = 'Account02' LIMIT 1];
        Account area = [SELECT Id FROM Account WHERE Name = 'Account03' LIMIT 1];
        Account filiale = [SELECT Id FROM Account WHERE Name = 'Account04' LIMIT 1];
        List<Contact> contactList = [SELECT id FROM Contact WHERE Account.Name = 'Account04'];
       
        Boolean response = NewMicroWalletController.saveMicroWallet(filiale.Id, banca.Id, dirReg.Id, area.id, filiale.Id, 'Private', 1, new list<String>{contactList[0].id}, new list<String>{contactList[1].id}, '', false, false,'','');
        Test.stopTest();
    }

    @isTest
    public static void testSaveSingleMicroWalletPrivateNEC(){

        
		Test.startTest();
        Account banca = [SELECT Id FROM Account WHERE Name = 'Account01' LIMIT 1];
        Account dirReg = [SELECT Id FROM Account WHERE Name = 'Account02' LIMIT 1];
        Account area = [SELECT Id FROM Account WHERE Name = 'Account03' LIMIT 1];
        Account filiale = [SELECT Id FROM Account WHERE Name = 'Account04' LIMIT 1];
        List<Contact> contactList = [SELECT id FROM Contact WHERE Account.Name = 'Account04'];
       
        Boolean response = NewMicroWalletController.saveMicroWallet(filiale.Id, banca.Id, dirReg.Id, area.id, filiale.Id, 'Private', 1, new list<String>{contactList[0].id}, new list<String>{contactList[1].id}, '', false, true,'','');
        Test.stopTest();
    }
    @isTest
    public static void testSaveMultipleMicroWallet(){

       
		Test.startTest();
        Account banca = [SELECT Id FROM Account WHERE Name = 'Account01' LIMIT 1];
        Account dirReg = [SELECT Id FROM Account WHERE Name = 'Account02' LIMIT 1];
        Account area = [SELECT Id FROM Account WHERE Name = 'Account03' LIMIT 1];
        Account filiale = [SELECT Id FROM Account WHERE Name = 'Account04' LIMIT 1];
        List<Contact> contactList = [SELECT id FROM Contact WHERE Account.Name = 'Account04'];
        
        Boolean response = NewMicroWalletController.saveMicroWallet(filiale.Id, banca.Id, dirReg.Id, area.id, filiale.Id, 'Consulenti Finanziari', 2, new list<String>{contactList[0].id}, new list<String>{contactList[1].id}, '',false, false,'','');
        Test.stopTest();
    }

    @isTest
    public static void testSaveMultipleMicroWalletPrivate(){

       
		Test.startTest();
        Account banca = [SELECT Id FROM Account WHERE Name = 'Account01' LIMIT 1];
        Account dirReg = [SELECT Id FROM Account WHERE Name = 'Account02' LIMIT 1];
        Account area = [SELECT Id FROM Account WHERE Name = 'Account03' LIMIT 1];
        Account filiale = [SELECT Id FROM Account WHERE Name = 'Account04' LIMIT 1];
        List<Contact> contactList = [SELECT id FROM Contact WHERE Account.Name = 'Account04'];
        
        Boolean response = NewMicroWalletController.saveMicroWallet(filiale.Id, banca.Id, dirReg.Id, area.id, filiale.Id, 'Private', 2, new list<String>{contactList[0].id}, new list<String>{contactList[1].id}, '', false, false,'','');
        Test.stopTest();
    }
    @isTest
    public static void testSaveMultipleMicroWalletPrivateNEC(){

       
		Test.startTest();
        Account banca = [SELECT Id FROM Account WHERE Name = 'Account01' LIMIT 1];
        Account dirReg = [SELECT Id FROM Account WHERE Name = 'Account02' LIMIT 1];
        Account area = [SELECT Id FROM Account WHERE Name = 'Account03' LIMIT 1];
        Account filiale = [SELECT Id FROM Account WHERE Name = 'Account04' LIMIT 1];
        List<Contact> contactList = [SELECT id FROM Contact WHERE Account.Name = 'Account04'];
        
        Boolean response = NewMicroWalletController.saveMicroWallet(filiale.Id, banca.Id, dirReg.Id, area.id, filiale.Id, 'Private', 2, new list<String>{contactList[0].id}, new list<String>{contactList[1].id}, '', false, true,'','');
        Test.stopTest();
    }
    @isTest
    static void TestShare() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser){
            UserRole role1= new UserRole();
            role1.DeveloperName='RIDCED1234';
            role1.Name=role1.DeveloperName;
            UserRole role2= new UserRole();
            role2.DeveloperName='RIDCED12345';
            role2.Name=role2.DeveloperName;
            UserRole role3= new UserRole();
            role3.DeveloperName='RIDCED123456';
            role3.Name=role3.DeveloperName;
            UserRole role4= new UserRole();
            role4.DeveloperName='RIDCED991';
            role4.Name=role4.DeveloperName;
            UserRole role5= new UserRole();
            role5.DeveloperName='RIDCED1238';
            role5.Name=role5.DeveloperName;
            UserRole role6= new UserRole();
            role6.DeveloperName='RIDCED1239';
            role6.Name=role6.DeveloperName;
            UserRole role7= new UserRole();
            role7.DeveloperName='RIDCED937';
            role7.Name=role7.DeveloperName;
            insert new List<UserRole>{role1, role2, role3, role4, role5, role6, role7};
            Group g = new Group();
            g.developerName='CP1_998';
            g.Name=g.DeveloperName;
            g.Type='Regular';
            insert g;
            Map<String, String> fiVirGroup = NewMicroWalletController.filialeVirtualeGroupMap;

        }
       
        List<Contact> contactList = [SELECT id FROM Contact WHERE Account.PTF_IDCed__c = '1238'];
        Account filiale = [SELECT Id, PTF_Banca__c, PTF_DirezioneRegionale__c, PTF_Area__c FROM Account WHERE PTF_IDCed__c = '1238' LIMIT 1];
        Test.startTest();
        Boolean response = NewMicroWalletController.saveMicroWallet(filiale.Id, filiale.PTF_Banca__c, filiale.PTF_DirezioneRegionale__c, filiale.PTF_Area__c, filiale.Id, 'Private', 1, new list<String>{contactList[0].id}, new List<String>(), '',false, false,'','');
        Test.stopTest();
    }

    @isTest
    public static void getUffPrivateTest(){
        Account filiale = [SELECT id FROM Account WHERE PTF_IdCED__c='1238' LIMIT 1];
        NewMicroWalletController.Wrapper response = NewMicroWalletController.getUffPrivate(filiale.Id);
    }

    @isTest
    public static void getUffPrivateTest2(){
        Account filiale = [SELECT id FROM Account WHERE PTF_IdCED__c='27926' LIMIT 1];
        NewMicroWalletController.Wrapper response = NewMicroWalletController.getUffPrivate(filiale.Id);
    }

    @isTest
    public static void findRoleGroupFilialeMDSTest(){
        Map<String,Group> response = NewMicroWalletController.findRoleGroupFilialeMDS(new Set<String>{'RIDCED1238'});
    }

    @isTest
    public static void checkPortafoglioExistsTest(){
		Test.startTest();
        Account filiale = [SELECT Id FROM Account WHERE Name = 'Account04' LIMIT 1];
        List<Contact> contactList = [SELECT id FROM Contact WHERE Account.Name = 'Account04']; 
        Boolean response = NewMicroWalletController.checkPortafoglioExists(filiale.Id, 'Consulenti Finanziari');
        Test.stopTest();
    }
}