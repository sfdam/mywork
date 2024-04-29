@IsTest
public with sharing class Batch_AssignNewPermissionSetTest {
    @TestSetup
    static void setup(){
        /*List<sObject> ls1 = Test.loadData(Struttura_Banca__c.sObjectType, 'StrutturaBancaTest');
        List<sObject> ls2 = Test.loadData(LDAP__c.sObjectType, 'LDAPTest');
        List<sObject> ls3 = Test.loadData(RoleTypology__c.sObjectType, 'RoleTypologyTest');*/

    
        ServiceModel__c model= new ServiceModel__c();
        model.PTF_Division__c='PR';
        model.PTF_MacroDivision__c='WM';
        model.Name='Private';
        insert model;
        
        Account banca= AllDataFactory.getAccount('Banca','Banca');
        banca.FinServ__BankNumber__c='1234';
		banca.PTF_IdCED__c='1234';
        insert banca;
        
        Account acc = new Account();
        acc.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Account', 'AltraUnitaOrganizzativa');
        acc.Name = 'UFF. Private test';
        acc.PTF_IdCED__c = '998';
        insert acc;

        LDAP__c ldapTest = new LDAP__c();
        ldapTest.Nome__c = 'Test';
        ldapTest.Cognome__c = 'Test';
        ldapTest.Matricola__c= 'UTest';
        ldapTest.Email__c = 'test@test.it';
        ldapTest.IDCed__c = '998';
        ldapTest.Attivo__c = true;
        ldapTest.Da_Elaborare__c = true;
        ldapTest.Ruolo_LDAP__c='100';
        ldapTest.Team__c='';
        ldapTest.Vicario__c='VIC_A';

        insert ldapTest;

        LDAP__c ldapTest3 = new LDAP__c();
        ldapTest3.Nome__c = 'Test3';
        ldapTest3.Cognome__c = 'Test3';
        ldapTest3.Matricola__c= 'UTest3';
        ldapTest3.Email__c = 'test@test.it3';
        ldapTest3.IDCed__c = '123';
        ldapTest3.Attivo__c = true;
        ldapTest3.Da_Elaborare__c = true;
        ldapTest3.Ruolo_LDAP__c='100';
        ldapTest3.Team__c='';
        ldapTest3.Vicario__c='VIC_A';

        insert ldapTest3;

        LDAP__c ldapTest1 = new LDAP__c();
        ldapTest1.Nome__c = 'Test';
        ldapTest1.Cognome__c = 'Test';
        ldapTest1.Matricola__c= 'UTest1';
        ldapTest1.Email__c = 'test@test.it';
        ldapTest1.IDCed__c = '8717';
        ldapTest1.IdCedFittizia__c = '8718';
        ldapTest1.Ruolo_LDAP__c = '100';
        ldapTest1.Profilo_LDAP__c = 'NEC_D.7';
        ldapTest1.Attivo__c = true;
        ldapTest1.Da_Elaborare__c = true;
        ldapTest1.Team__c='';
        ldapTest.Vicario__c='VIC_A';

        insert ldapTest1;

        LDAP__c ldapTest4 = new LDAP__c();
        ldapTest4.Nome__c = 'Test4';
        ldapTest4.Cognome__c = 'Test4';
        ldapTest4.Matricola__c= 'UTest4';
        ldapTest4.Email__c = 'test@test.it';
        ldapTest4.IDCed__c = '8717';
        ldapTest4.IdCedFittizia__c = '8718';
        ldapTest4.Ruolo_LDAP__c = '069';
        ldapTest4.Profilo_LDAP__c = 'NEC_D.7';
        ldapTest4.Attivo__c = true;
        ldapTest4.Da_Elaborare__c = true;
        ldapTest4.Team__c='team';
        ldapTest4.Vicario__c='VIC_A';

        insert ldapTest4;

        Account a = new Account();
        a.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Account', 'AltraUnitaOrganizzativa');
        a.Name = 'UFF. Private test';
        a.PTF_IdCED__c = '123';
        insert a;

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



        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        filiale.PTF_BranchTypology__c='A';
        filiale.PTF_Area__c= area.Id;
        filiale.PTF_Banca__c=banca.Id;
        filiale.PTF_DirezioneRegionale__c=b.Id;
        filiale.PTF_IdCED__c='1238';
        filiale.PTF_IdCEDFiliale__c='1200';
        Account filiale2 = AllDataFactory.getAccount('02', 'FilialeDiRelazione');
        filiale2.PTF_Division__c='PR';
        filiale2.PTF_MacroDivision__c='WM';
        filiale2.PTF_Area__c= area.Id;
        filiale2.PTF_Banca__c=banca.Id;
        filiale2.PTF_DirezioneRegionale__c=b.Id;
        filiale2.PTF_BranchTypology__c='F';
        filiale2.PTF_IdCED__c='1239';
        filiale2.PTF_IdCEDFiliale__c='2499';
        insert new List<Account>{filiale, filiale2};
        Account uff = AllDataFactory.getAccount('02', 'AltraUnitaOrganizzativa');
        uff.PTF_IdCED__c='256';
        uff.PTF_Banca__c=banca.Id;
        uff.PTF_IdCEDPadre__c='1234';
        insert uff;
        Wallet__c wal = new Wallet__c();
        wal.PTF_ModelloDiServizio__c='Private';
        wal.PTF_Filiale__c=filiale.Id;
        wal.PTF_Banca__c=banca.Id;
        wal.PTF_Capofila__c=filiale.Id;
        wal.PTF_Area__c=area.Id;
        wal.PTF_DirezioneRegionale__c=b.Id;
        insert wal;
        Wallet__c wal1 = new Wallet__c();
        wal1.PTF_ModelloDiServizio__c='Private';
        wal1.PTF_Filiale__c=filiale2.Id;
        wal1.PTF_Banca__c=banca.Id;
        wal1.PTF_Capofila__c=filiale2.Id;
        wal1.PTF_Area__c=area.Id;
        wal1.PTF_DirezioneRegionale__c=b.Id;
        insert wal1;
        LDAP__c ldp = new LDAP__c();
        ldp.Ruolo_LDAP__c='100';
        ldp.Team__c=null;
        ldp.Matricola__c='U5852';
        insert ldp;
        Group gr = new Group();
        gr.DeveloperName='CP1_123';
        gr.Name='test';
        insert gr;
        Group gr1 = new Group();
        gr1.DeveloperName='team_8717';
        gr1.Name='test1';
        insert gr1;

        ConfigUffPrivateDR__c cf = new ConfigUffPrivateDR__c();
        cf.Name='CF_TEST';
        cf.PTF_IdCP__c='CP1_123';
        insert cf;
    }
    @isTest
    static void Test1() {
        Map<String,SObject> mUser = SV_Utilities.keyBy([
            SELECT	Id,
            		FederationIdentifier
            FROM User
        ], '{FederationIdentifier}',true);
        List<LDAP__c> ldapList = [SELECT Matricola__c, IDCed__c, Profilo_LDAP__c, Ruolo_LDAP__c FROM LDAP__c LIMIT 200];
        List<UserRole> roleexisting= [SELECT DeveloperName FROM UserRole];
        Set<String> existingRolesDevName= new Set<String>();
        for(UserRole r:roleexisting){
            existingRolesDevName.add(r.DeveloperName);
        }
        List<UserRole> roles = new List<UserRole>();
        for(LDAP__c l:ldapList){
            if(!existingRolesDevName.contains('RIDCED'+l.IDCed__c)){
                UserRole r = new UserRole();
                r.DeveloperName='RIDCED'+l.IDCed__c;
                r.Name= r.DeveloperName;
                roles.add(r);
                existingRolesDevName.add(r.DeveloperName);
            }
        }
        insert roles;
        Profile profile = [SELECT id FROM Profile WHERE Name =: Label.System_Administrator LIMIT 1];
        List<User> userList= new List<User>();
        Integer counter=0;
        for(LDAP__c l:ldapList){
            if (!mUser.containsKey(l.Matricola__c.replace('U',''))) {
            	counter=counter+1;
            	User u = AllDataFactory.getUser(String.valueOf(counter), profile.Id, 'CORPORATE');
            	u.FederationIdentifier=l.Matricola__c.replace('U','');
                u.Profilo__c = l.Profilo_LDAP__c;
            	userList.add(u);
            }
        }
        insert userList;
        
        LDAP__c ldapTest = new LDAP__c();
        ldapTest.Nome__c = 'Test';
        ldapTest.Cognome__c = 'Test';
        ldapTest.Matricola__c= 'UTest';
        ldapTest.Email__c = 'test@test.it';
        ldapTest.IDCed__c = '8717';
        ldapTest.IdCedFittizia__c = '8718';
        ldapTest.Ruolo_LDAP__c = '100';
        ldapTest.Profilo_LDAP__c = 'NEC_D.7';
        ldapTest.Attivo__c = true;
        ldapTest.Da_Elaborare__c = true;
        ldapTest.Vicario__c='VIC_A';


        Test.startTest();
        Batch_AssignNewPermissionSet sgr = new Batch_AssignNewPermissionSet();
        sgr.initRunner(new List<ScheduledJob__c>());
        Database.executeBatch(sgr);
        Test.stopTest();
    }
}