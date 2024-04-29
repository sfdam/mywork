@isTest 
private class BatchClassTest {
    @TestSetup
    static void setup(){
        List<sObject> ls1 = Test.loadData(Struttura_Banca__c.sObjectType, 'StrutturaBancaTest');
        List<sObject> ls2 = Test.loadData(LDAP__c.sObjectType, 'LDAPTest');
        List<sObject> ls3 = Test.loadData(RoleTypology__c.sObjectType, 'RoleTypologyTest');

    
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
    static void Test4() {
        Test.startTest();
        Batch_CreaGerarchiaAccount sgr = new Batch_CreaGerarchiaAccount();
        sgr.initRunner(new List<ScheduledJob__c>());
        Database.executeBatch(sgr);
        Test.stopTest();
    }
    
    @isTest
    static void Test5() {
        Test.startTest();
        Batch_AccountLink.skipAccountTrigger=true;
        Account banca= AllDataFactory.getAccount('Banca','Banca');
        banca.FinServ__BankNumber__c='1234';
        Account banca2= AllDataFactory.getAccount('Banca2','Banca');
        banca2.FinServ__BankNumber__c='12345';

        insert new List<Account>{banca, banca2};

        Account dr= AllDataFactory.getAccount('DR','DirezioneRegionale');
        dr.ParentId=banca.Id;

        insert dr;

        Account area = AllDataFactory.getAccount('Area','Area');
        area.ParentId=dr.Id;
        insert area;


        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        filiale.PTF_BranchTypology__c='A';
        filiale.ParentId=area.Id;
        insert filiale;
        Account ufficio = AllDataFactory.getAccount('01', 'AltraUnitaOrganizzativa');
        ufficio.ParentId=banca.Id;
        insert ufficio;
        Batch_AccountLink sgr = new Batch_AccountLink();
        sgr.initRunner(new List<ScheduledJob__c>());
        Database.executeBatch(sgr);
        Test.stopTest();
    }
    
    @isTest
    static void Test6() {
        Map<String,SObject> mUser = SV_Utilities.keyBy([
            SELECT	Id,
            		FederationIdentifier
            FROM User
        ], '{FederationIdentifier}',true);
        List<LDAP__c> ldapList = [SELECT Matricola__c, IDCed__c, Ruolo_LDAP__c FROM LDAP__c LIMIT 200];
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
        ldapTest.Ruolo_LDAP__c = '100';
        ldapTest.Profilo_LDAP__c = 'NEC_D.7';
        ldapTest.Attivo__c = true;
        ldapTest.Da_Elaborare__c = true;
        ldapTest.Vicario__c='VIC_A';


        Test.startTest();
        Batch_AssegnaRuoli sgr = new Batch_AssegnaRuoli();
        sgr.initRunner(new List<ScheduledJob__c>());
        //sgr.sObjectToManage = new List<String>{'User'};
        sgr.ldapTest = ldapTest;
        Database.executeBatch(sgr);
        Test.stopTest();
    }
    

    @isTest
    static void Test6b() {
        Map<String,SObject> mUser = SV_Utilities.keyBy([
            SELECT	Id,
            		FederationIdentifier
            FROM User
        ], '{FederationIdentifier}',true);
        List<LDAP__c> ldapList = [SELECT Matricola__c, IDCed__c, Ruolo_LDAP__c FROM LDAP__c LIMIT 200];
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
            	userList.add(u);
            }
        }
        insert userList;
        
        LDAP__c ldapTest = new LDAP__c();
        ldapTest.Nome__c = 'Test';
        ldapTest.Cognome__c = 'Test';
        ldapTest.Matricola__c= 'UTest';
        ldapTest.Email__c = 'test@test.it';
        // DK - MODIFICA KCI 13/12 - 5806 => 21709
        // ldapTest.IDCed__c = '5806';
        ldapTest.IDCed__c = '21709';
        ldapTest.Ruolo_LDAP__c = '100';
        ldapTest.Profilo_LDAP__c = 'NEC_D.7';
        ldapTest.Attivo__c = true;
        ldapTest.Da_Elaborare__c = true;
        Test.startTest();
        Batch_AssegnaRuoli sgr = new Batch_AssegnaRuoli();
        sgr.initRunner(new List<ScheduledJob__c>());
        //sgr.sObjectToManage = new List<String>{'User'};
        sgr.ldapTest = ldapTest;
        Database.executeBatch(sgr);
        Test.stopTest();
    }

    @isTest
    static void Test7() {
        Account filiale = AllDataFactory.getAccount('04', 'FilialeDiRelazione');
        Account filiale2 = AllDataFactory.getAccount('05', 'FilialeDiRelazione');
        insert new List<Account>{filiale,filiale2};
        RoleTypology__c ruolo = new RoleTypology__c();
        ruolo.Name = 'TestRuolo';
        RoleTypology__c ruolo2 = new RoleTypology__c();
        ruolo2.Name = 'TestRuolo2';
        insert new List<RoleTypology__c>{ruolo,ruolo2};
        Contact contact = AllDataFactory.getContact('01', null, filiale.Id);
        contact.PTF_TipologiaRuolo__c = ruolo.Id;
        contact.PTF_RegistrationNumber__c = 'UTest';
        insert contact;
        LDAP__c ldapTest = new LDAP__c();
        ldapTest.Nome__c = 'Test';
        ldapTest.Cognome__c = 'Test';
        ldapTest.Matricola__c= 'UTest';
        ldapTest.Email__c = 'test@test.it';
        // DK - MODIFICA KCI 13/12 - 5806 => 21709
        // ldapTest.IDCed__c = '5806';
        ldapTest.IDCed__c = '21709';
        ldapTest.Ruolo_LDAP__c = '990';
        ldapTest.Profilo_LDAP__c = '';
        ldapTest.Attivo__c = true;
        ldapTest.Da_Elaborare__c = true;
        Funzionalita__c fun = Funzionalita__c.getInstance(userinfo.getUserId());
        fun.Disable_ContactTrigger__c = true;
        upsert fun;
        Wallet__c wallet = AllDataFactory.getWallet('MicroWallet', filiale.Id, 'CORPORATE');
        insert wallet;
        Assignment__c assignment = AllDataFactory.getAssignment('Primario', wallet.Id, null);
        insert assignment;
        Test.startTest();
        Batch_GeneraContatti.manageAssignment(new List<Assignment__c>{assignment},'onInsert');
        assignment.PTF_EndDate__c = date.today();
        Batch_GeneraContatti.manageAssignment(new List<Assignment__c>{assignment},'onUpdate');
        //Batch_GeneraContatti.ExtraThread et = new Batch_GeneraContatti.ExtraThread(new List<Assignment__c>(),'onInsert');
        //et.execute();
        //Batch_GeneraContatti.ExtraThread et2 = new Batch_GeneraContatti.ExtraThread(new List<Assignment__c>(),'onUpdate');
        //et2.execute();
        Batch_GeneraContatti sgr = new Batch_GeneraContatti();
        sgr.initRunner(new List<ScheduledJob__c>());
        sgr.ldapTest = ldapTest;
        //sgr.sObjectToManage = new List<String>{'Contact'};
        Database.executeBatch(sgr);
        Map<String,String> mTest = new Map<String,String>();
        Map<String,Contact> mContact = Batch_GeneraContatti.findContact(new Set<String>{'UTest'});
        contact = mContact.get('UTest');
        Contact c = contact.clone(true,true,true);
        c.PTF_IsVice__c ='VIC_T';
        c.PTF_ProfiloLDAP__c ='NEC_F.5';
        c.PTF_OFS__c = true;
        c.PTF_Ruolo__c = '050';
        c.PTF_CentroPrivate__c ='CP1';
        c.PTF_TipologiaRuolo__c = ruolo2.Id;
        c.AccountId= filiale2.Id;
        Batch_GeneraContatti.storicoContatti(mTest, c, contact,new Map<Id,String>(),filiale2);
        Test.stopTest();
    }
    @isTest
    static void Test8() {
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
        role7.DeveloperName='RIDCED256';
        role7.Name=role7.DeveloperName;
        insert new List<UserRole>{role1, role2, role3, role4, role5, role6, role7};
        Group g = new Group();
        g.developerName='CP1_998';
        g.Name=g.DeveloperName;
        g.Type='Regular';
        insert g;
        Test.startTest();
        Batch_CreaVisibilita sgr = new Batch_CreaVisibilita();
        sgr.initRunner(new List<ScheduledJob__c>());
        Database.executeBatch(sgr);
        Test.stopTest();
    }

    @isTest
    static void Test6c() {

        Map<String,SObject> mUser = SV_Utilities.keyBy([
            SELECT	Id,
            		FederationIdentifier
            FROM User
        ], '{FederationIdentifier}',true);

        List<LDAP__c> ldapList = [SELECT Matricola__c, IDCed__c, Ruolo_LDAP__c,Team__c FROM LDAP__c  LIMIT 200];
        LDAP__c ldp = [SELECT Matricola__c, IDCed__c, Ruolo_LDAP__c,Team__c FROM LDAP__c where Ruolo_LDAP__c ='100' and Team__c=null LIMIT 1];
        LDAP__c ldp1 = [SELECT Matricola__c, IDCed__c, Ruolo_LDAP__c,Team__c FROM LDAP__c where Matricola__c= 'UTest1' LIMIT 1];
        ldapList.add(ldp);
        ldapList.add(ldp1);

        User u1 =[SELECT	Id,FederationIdentifier FROM User WHERE FederationIdentifier!=NULL limit 1];
        Group gr = [SELECT id FROM GROUP WHERE Name='test'];
        GroupMember grMember = new GroupMember();
        grMember.GroupId=gr.id;
        grMember.UserOrGroupId=u1.id;
        insert grMember;

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
            	userList.add(u);
            }
        }
        insert userList;
        
        LDAP__c ldapTest = new LDAP__c();
        ldapTest.Nome__c = 'Test';
        ldapTest.Cognome__c = 'Test';
        ldapTest.Matricola__c= 'UTest';
        ldapTest.Email__c = 'test@test.it';
        // DK - MODIFICA KCI 13/12 - 5806 => 21709
        // ldapTest.IDCed__c = '5806';
        ldapTest.IDCed__c = '21709';
        ldapTest.Ruolo_LDAP__c = '069';
        ldapTest.Profilo_LDAP__c = 'NEC_D.7';
        ldapTest.Attivo__c = true;
        ldapTest.Da_Elaborare__c = true;
        ldapTest.Team__c='team';
        ldapTest.Vicario__c='VIC_A';


        Test.startTest();
        Batch_AssegnaRuoli sgr = new Batch_AssegnaRuoli();
        sgr.initRunner(new List<ScheduledJob__c>());
        //sgr.sObjectToManage = new List<String>{'User'};
        sgr.ldapTest = ldapTest;
        Database.executeBatch(sgr);
        Test.stopTest();
    }


    @isTest
    static void Test9() {



        Map<String,SObject> mUser = SV_Utilities.keyBy([SELECT	Id,FederationIdentifier FROM User], '{FederationIdentifier}',true);

        List<LDAP__c> ldapList = [SELECT Matricola__c, IDCed__c, Ruolo_LDAP__c,Team__c FROM LDAP__c  LIMIT 200];
        LDAP__c ldp = [SELECT Matricola__c, IDCed__c, Ruolo_LDAP__c,Team__c FROM LDAP__c where Ruolo_LDAP__c ='100' and Team__c='' LIMIT 1];
        LDAP__c ldp1 = [SELECT Matricola__c, IDCed__c, Ruolo_LDAP__c,Team__c FROM LDAP__c where Matricola__c= 'UTest1' LIMIT 1];
        ldapList.add(ldp);
        ldapList.add(ldp1);

        User u1 =[SELECT	Id,FederationIdentifier FROM User WHERE FederationIdentifier!=NULL limit 1];
        Group gr = [SELECT id FROM GROUP WHERE Name='test'];
        GroupMember grMember = new GroupMember();
        grMember.GroupId=gr.id;
        grMember.UserOrGroupId=u1.id;
        insert grMember;

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
            	userList.add(u);
            }
        }
        insert userList;
        
        LDAP__c ldapTest = new LDAP__c();
        ldapTest.Nome__c = 'Test';
        ldapTest.Cognome__c = 'Test';
        ldapTest.Matricola__c= 'UTest';
        ldapTest.Email__c = 'test@test.it';
        ldapTest.IDCed__c = '123';
        ldapTest.Ruolo_LDAP__c = '100';
        ldapTest.Profilo_LDAP__c = 'NEC_D.7';
        ldapTest.Attivo__c = true;
        ldapTest.Da_Elaborare__c = true;
        ldapTest.Team__c=null;


        Test.startTest();
        Batch_AssegnaRuoli sgr = new Batch_AssegnaRuoli();
        sgr.initRunner(new List<ScheduledJob__c>());
        //sgr.sObjectToManage = new List<String>{'User'};
        sgr.ldapTest = ldapTest;
        Database.executeBatch(sgr);
        Test.stopTest();
    }

    @isTest
    static void Test10() {



        Map<String,SObject> mUser = SV_Utilities.keyBy([SELECT	Id,FederationIdentifier FROM User], '{FederationIdentifier}',true);

        List<LDAP__c> ldapList = [SELECT Matricola__c, IDCed__c, Ruolo_LDAP__c,Team__c FROM LDAP__c  LIMIT 200];
        LDAP__c ldp = [SELECT Matricola__c, IDCed__c, Ruolo_LDAP__c,Team__c FROM LDAP__c where Ruolo_LDAP__c ='100' and Team__c='' LIMIT 1];
        LDAP__c ldp1 = [SELECT Matricola__c, IDCed__c, Ruolo_LDAP__c,Team__c FROM LDAP__c where Matricola__c= 'UTest1' LIMIT 1];
        ldapList.add(ldp);
        ldapList.add(ldp1);

        User u1 =[SELECT	Id,FederationIdentifier FROM User WHERE FederationIdentifier!=NULL limit 1];
        Group gr = [SELECT id FROM GROUP WHERE Name='test'];
        GroupMember grMember = new GroupMember();
        grMember.GroupId=gr.id;
        grMember.UserOrGroupId=u1.id;
        insert grMember;

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
            	userList.add(u);
            }
        }
        insert userList;
        
        LDAP__c ldapTest = new LDAP__c();
        ldapTest.Nome__c = 'Test';
        ldapTest.Cognome__c = 'Test';
        ldapTest.Matricola__c= 'UTest';
        ldapTest.Email__c = 'test@test.it';
        ldapTest.IDCed__c = '123';
        ldapTest.Ruolo_LDAP__c = '069';
        ldapTest.Profilo_LDAP__c = 'NEC_D.7';
        ldapTest.Attivo__c = true;
        ldapTest.Da_Elaborare__c = true;
        ldapTest.Team__c='teamtest10';


        Test.startTest();
        Batch_AssegnaRuoli sgr = new Batch_AssegnaRuoli();
        sgr.initRunner(new List<ScheduledJob__c>());
        //sgr.sObjectToManage = new List<String>{'User'};
        sgr.ldapTest = ldapTest;
        Database.executeBatch(sgr);
        Test.stopTest();
    }

    @isTest
    static void Test11() {
        Test.startTest();
        Batch_Deprovisioning sgr = new Batch_Deprovisioning();
        sgr.initRunner(new List<ScheduledJob__c>());
        Database.executeBatch(sgr);
        Test.stopTest();
    }

    @isTest
    static void Test12() {
        Test.startTest();
        Database.executeBatch(new Batch_CalcoloReferenti(),1000);

        Test.stopTest();
    }

    /*@isTest
    static void Test12() {
        List<User> userList = [SELECT ID, Da_Disattivare_Batch__c FROM USER LIMIT 2];
        userList.get(0).Da_Disattivare_Batch__c = true;
        //update userList;

        Case c = new Case(Status = 'New', OwnerId = userList.get(1).Id);
        insert c;
        c.OwnerId = userList.get(0).Id;
        update c;
        Test.startTest();
        Batch_Disattivazione_User sgr = new Batch_Disattivazione_User();
        sgr.initRunner(new List<ScheduledJob__c>());
        Database.executeBatch(sgr);
        Test.stopTest();
    }

    @isTest
    static void Test13() {
        List<User> userList = new List<User>();
        Profile p = [select Id from Profile where name='Standard User'];

        User u = new User(Alias = 'bperUsr1',
        Email='bperTestUser1.test@salesforceBper1.com',
        EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        LastName='Foo',
        UserName='bperTestUser1.test@salesforceBper1.com',
        Da_Disattivare_Batch__c = true);
        userList.add(u);

        User u2 = new User(Alias = 'bperUsr2',
        Email='bperTestUser2.test@salesforceBper2.com',
        EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        LastName='Foo',
        UserName='bperTestUser2.test@salesforceBper2.com',
        Da_Disattivare_Batch__c = true);
        userList.add(u2);

        insert userList;
        
        Case c = new Case(Status = 'New', OwnerId = userList.get(1).Id);
        insert c;
        c.OwnerId = userList.get(0).Id;
        update c;

        ScheduledJob__c sJob = new ScheduledJob__c(Name='Batch_Disattivazione_User',Batch_Size__c=200);
        Test.startTest();
        Batch_Disattivazione_User sgr = new Batch_Disattivazione_User();
        List<ScheduledJob__c> sList = new List<ScheduledJob__c>{sJob,sJob};
        sgr.initRunner(sList);
        Database.executeBatch(sgr);
        Test.stopTest();
    }*/

   
}