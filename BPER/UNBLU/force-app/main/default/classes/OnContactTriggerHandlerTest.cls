@istest
public with sharing class OnContactTriggerHandlerTest {
    
    @istest
    static void test(){
        
        String profiloName = Label.System_Administrator;
        Profile profile = [SELECT id FROM Profile WHERE Name =:profiloName  LIMIT 1];
        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        User user2 = AllDataFactory.getUser('02', profile.Id, 'CORPORATE');
        User user3 = AllDataFactory.getUser('03', profile.Id, 'CORPORATE');
        User user4 = AllDataFactory.getUser('04', profile.Id, 'CORPORATE');
        User user5 = AllDataFactory.getUser('05', profile.Id, 'CORPORATE');
        User user6 = AllDataFactory.getUser('06', profile.Id, 'CORPORATE');
        User user7 = AllDataFactory.getUser('07', profile.Id, 'CORPORATE');
        User user8 = AllDataFactory.getUser('08', profile.Id, 'CORPORATE');
        User user9 = AllDataFactory.getUser('09', profile.Id, 'CORPORATE');
        User user10 = AllDataFactory.getUser('10', profile.Id, 'CORPORATE');
        User user11 = AllDataFactory.getUser('11', profile.Id, 'CORPORATE');
        User user12 = AllDataFactory.getUser('12', profile.Id, 'CORPORATE');
        User user13 = AllDataFactory.getUser('13', profile.Id, 'CORPORATE');
        User user14 = AllDataFactory.getUser('14', profile.Id, 'CORPORATE');
        User user15 = AllDataFactory.getUser('15', profile.Id, 'CORPORATE');
        User user16 = AllDataFactory.getUser('16', profile.Id, 'CORPORATE');
        User user17 = AllDataFactory.getUser('17', profile.Id, 'CORPORATE');
        User user18 = AllDataFactory.getUser('18', profile.Id, 'CORPORATE');
        User user19 = AllDataFactory.getUser('19', profile.Id, 'CORPORATE');
        User user20 = AllDataFactory.getUser('20', profile.Id, 'CORPORATE');
        User user21 = AllDataFactory.getUser('21', profile.Id, 'CORPORATE');
        User user22 = AllDataFactory.getUser('22', profile.Id, 'CORPORATE');
        User user23 = AllDataFactory.getUser('23', profile.Id, 'CORPORATE');
        
        
        insert new List<User>{user, user2, user3, user4,user5,user6,user7,user8,user9,user10,user11,user12,user13,user14,user15,user16,user17,user19,user20,user21,user22,user23};
        System.runAs(user){
            Account banca = AllDataFactory.getAccount('01', 'Banca');
            Account direzioneRegionale = AllDataFactory.getAccount('02', 'DirezioneRegionale');
            Account area = AllDataFactory.getAccount('03', 'Area');
            Account filiale = AllDataFactory.getAccount('04', 'FilialeDiRelazione');
            filiale.PTF_BranchTypology__c = 'A';
            Account filiale2 = AllDataFactory.getAccount('04a', 'FilialeDiRelazione');
            filiale2.PTF_BranchTypology__c = 'A';
            Account filiale3 = AllDataFactory.getAccount('04b', 'FilialeDiRelazione');
            filiale3.PTF_BranchTypology__c = 'A';
            filiale3.FinServ__BankNumber__c='01015';
            Account filiale4 = AllDataFactory.getAccount('04c', 'FilialeDiRelazione');
            filiale4.PTF_BranchTypology__c = 'A';
            filiale4.FinServ__BankNumber__c='05387';
            Account filiale5 = AllDataFactory.getAccount('Uff. sviluppo', 'FilialeDiRelazione');
            filiale5.CRM_Nome__c = 'uff. sviluppo';
            insert new List<Account>{banca, direzioneRegionale, area, filiale,filiale2,filiale3,filiale4,filiale5};

            RoleTypology__c ruolo = new RoleTypology__c();
            ruolo.Name = 'CORPORATE';
            insert ruolo;

            RoleTypology__c ruolo2 = new RoleTypology__c();
            ruolo2.Name = 'CORPORATE';
            insert ruolo2;
                    
            RoleTypology__c ruolo3 = new RoleTypology__c();
            ruolo3.Name = 'Consulenti test';
            ruolo3.PTF_Code__c = '990';
            insert ruolo3;
                    
            RoleTypology__c ruolo4 = new RoleTypology__c();
            ruolo4.Name = 'test4';
            ruolo4.PTF_Code__c = '040';
            insert ruolo4;
                    
            RoleTypology__c ruolo5 = new RoleTypology__c();
            ruolo5.Name = 'Coordinatore test';
            ruolo5.PTF_Code__c = '001';
            insert ruolo5;
            
            RoleTypology__c ruolo6 = new RoleTypology__c();
            ruolo6.Name = 'CORPORATE';
            ruolo6.PTF_Code__c = '101';
            insert ruolo6;
            
            RoleTypology__c ruolo7 = new RoleTypology__c();
            ruolo7.Name = 'CORPORATE';
            ruolo7.PTF_Code__c = '042';
            insert ruolo7;

            RoleTypology__c ruolo8 = new RoleTypology__c();
            ruolo8.Name = 'CORPORATE';
            ruolo8.PTF_Code__c = 'F_143';
            insert ruolo8;

            RoleTypology__c ruolo9 = new RoleTypology__c();
            ruolo9.Name = 'CORPORATE';
            ruolo9.PTF_Code__c = 'F_903';
            insert ruolo9;

            RoleTypology__c ruolo10 = new RoleTypology__c();
            ruolo10.Name = 'CORPORATE';
            ruolo10.PTF_Code__c = 'F_902';
            insert ruolo10;

            RoleTypology__c ruolo11 = new RoleTypology__c();
            ruolo11.Name = 'CORPORATE';
            ruolo11.PTF_Code__c = '037';
            insert ruolo11;

            ServiceModel__c modelloDiServizio = new ServiceModel__c();
            modelloDiServizio.Name = 'CORPORATE';
            insert modelloDiServizio;

            ServiceModel__c modelloDiServizio3 = new ServiceModel__c();
            modelloDiServizio3.Name = 'CORPORATE';
            modelloDiServizio3.PTF_Division__c = 'PR';
            modelloDiServizio3.PTF_MacroDivision__c = 'WM';
            insert modelloDiServizio3;
            
            ServiceModel__c modelloDiServizio2 = new ServiceModel__c();
            modelloDiServizio.Name = 'CORPORATE';
            modelloDiServizio2.PTF_Division__c = 'CF';
            modelloDiServizio2.PTF_MacroDivision__c = 'WM';
            insert modelloDiServizio2;

            ServiceModel__c modelloDiServizio4 = new ServiceModel__c();
            modelloDiServizio4.Name = 'CORPORATE';
            modelloDiServizio4.PTF_Division__c = 'ET';
            modelloDiServizio4.PTF_MacroDivision__c = 'IC';
            insert modelloDiServizio4;

            ServiceModel__c modelloDiServizio5 = new ServiceModel__c();
            modelloDiServizio5.Name = 'CORPORATE';
            modelloDiServizio5.PTF_Division__c = 'KI';
            modelloDiServizio5.PTF_MacroDivision__c = 'IC';
            insert modelloDiServizio5;



            List<LDAP__c> ldaps = new List<LDAP__c>();
            
            for (Integer i=40; i<60;i++) {
                LDAP__c ldap = new LDAP__c();
                ldap.Matricola__c = 'U123'+i;
                ldap.Ruolo_LDAP__c = '990';
                ldap.Ruolo_LDAP_Calcolato__c = '990';
                ldaps.add(ldap);
            }
            insert ldaps;

            LDAP__c ldap1 = new LDAP__c();
            ldap1.Matricola__c = 'U11111';
            ldap1.Ruolo_LDAP__c = 'F_143';
            ldap1.Ruolo_LDAP_Calcolato__c = 'F_143';
            ldap1.IDCed__c='6116';
            insert ldap1;

            LDAP__c ldap2 = new LDAP__c();
            ldap2.Matricola__c = 'U22222';
            ldap2.Ruolo_LDAP__c = 'F_903';
            ldap2.Ruolo_LDAP_Calcolato__c = 'F_903';
            ldap2.IDCed__c='6859';
            insert ldap2;

            LDAP__c ldap3 = new LDAP__c();
            ldap3.Matricola__c = 'U33333';
            ldap3.Ruolo_LDAP__c = 'F_902';
            ldap3.Ruolo_LDAP_Calcolato__c = 'F_902';
            ldap3.IDCed__c='21707';
            insert ldap3;

            LDAP__c ldap4 = new LDAP__c();
            ldap4.Matricola__c = 'U44444';
            ldap4.Ruolo_LDAP__c = '037';
            ldap4.Ruolo_LDAP_Calcolato__c = '037';
            ldap4.IDCed__c='21707';
            insert ldap4;

            LDAP__c ldap5 = new LDAP__c();
            ldap5.Matricola__c = 'U55555';
            ldap5.Ruolo_LDAP__c = '037';
            ldap5.Ruolo_LDAP_Calcolato__c = '037';
            ldap5.IDCed__c='21707';
            insert ldap5;

            RoleMDS__c ruoloMDS = new RoleMDS__c();
            ruoloMDS.PTF_BranchTypology__c = 'A';
            ruoloMDS.PTF_RoleTypology__c = ruolo.Id;
            ruoloMDS.PTF_ServiceModel__c = modelloDiServizio.Id;
            ruoloMDS.PTF_StartDate__c = Date.today().addDays(-10);
            ruoloMDS.PTF_EndDate__c = Date.today().addDays(10);
            insert ruoloMDS;

            RoleMDS__c ruoloMDS1 = new RoleMDS__c();
            ruoloMDS1.PTF_BranchTypology__c = 'A';
            ruoloMDS1.PTF_RoleTypology__c = ruolo8.Id;
            ruoloMDS1.PTF_ServiceModel__c = modelloDiServizio3.Id;
            ruoloMDS1.PTF_StartDate__c = Date.today().addDays(-10);
            ruoloMDS1.PTF_EndDate__c = Date.today().addDays(10);
            insert ruoloMDS1;

            RoleMDS__c ruoloMDS2 = new RoleMDS__c();
            ruoloMDS2.PTF_BranchTypology__c = 'A';
            ruoloMDS2.PTF_RoleTypology__c = ruolo3.Id;
            ruoloMDS2.PTF_ServiceModel__c = modelloDiServizio2.Id;
            ruoloMDS2.PTF_StartDate__c = Date.today().addDays(-10);
            ruoloMDS2.PTF_EndDate__c = Date.today().addDays(10);
            insert ruoloMDS2;

            RoleMDS__c ruoloMDS3 = new RoleMDS__c();
            ruoloMDS3.PTF_BranchTypology__c = 'A';
            ruoloMDS3.PTF_RoleTypology__c = ruolo9.Id;
            ruoloMDS3.PTF_ServiceModel__c = modelloDiServizio4.Id;
            ruoloMDS3.PTF_StartDate__c = Date.today().addDays(-10);
            ruoloMDS3.PTF_EndDate__c = Date.today().addDays(10);
            insert ruoloMDS3;

            RoleMDS__c ruoloMDS4 = new RoleMDS__c();
            ruoloMDS4.PTF_BranchTypology__c = 'A';
            ruoloMDS4.PTF_RoleTypology__c = ruolo10.Id;
            ruoloMDS4.PTF_ServiceModel__c = modelloDiServizio5.Id;
            ruoloMDS4.PTF_StartDate__c = Date.today().addDays(-10);
            ruoloMDS4.PTF_EndDate__c = Date.today().addDays(10);
            insert ruoloMDS4;

            Contact contact = AllDataFactory.getContact('01', user.Id, filiale.Id);
            contact.PTF_TipologiaRuolo__c = ruolo.Id;
            Contact contact2 = AllDataFactory.getContact('02', user2.Id, filiale.Id);
            contact2.PTF_TipologiaRuolo__c = ruolo.Id;
            Contact contact3 = AllDataFactory.getContact('03', user3.Id, filiale.Id);
            contact3.PTF_TipologiaRuolo__c = ruolo.Id;
            Contact contact4 = AllDataFactory.getContact('04', user4.Id, filiale.Id);
            contact4.PTF_TipologiaRuolo__c = ruolo.Id;
            Contact contact5 = AllDataFactory.getContact('05', user5.Id, filiale.Id);
            contact5.PTF_TipologiaRuolo__c = ruolo.Id;
            contact5.PTF_Ruolo__c = '069';
            contact5.PTF_CentroPrivate__c = 'CP1';
            //'NEC_A.5','NEC_CF','NEC_F.1','NEC_F.2','NEC_D.4','NEC_D.5','NEC_D.6','NEC_D.7','NEC_D.9','NEC_F.9','NEC_F.10','NEC_T.4','NEC_T.7','NEC_T.8','NEC_T.10'        
            
            List<Contact> contacts = new List<Contact>();
            //05387
            Contact contact10 = AllDataFactory.getContact('10', user10.Id, filiale4.Id);
            contact10.PTF_TipologiaRuolo__c = ruolo3.Id;
            contact10.PTF_RegistrationNumber__c ='12344';
            contact10.PTF_ProfiloLDAP__c ='NEC_D.4';
            contacts.add(contact10);
            Contact contact11 = AllDataFactory.getContact('11', user11.Id, filiale4.Id);
            contact11.PTF_TipologiaRuolo__c = ruolo3.Id;
            contact11.PTF_RegistrationNumber__c ='12345';
            contact11.PTF_ProfiloLDAP__c ='NEC_D.5';
            contacts.add(contact11);
            Contact contact12 = AllDataFactory.getContact('12', user12.Id, filiale4.Id);
            contact12.PTF_TipologiaRuolo__c = ruolo3.Id;
            contact12.PTF_RegistrationNumber__c ='12346';
            contact12.PTF_ProfiloLDAP__c ='NEC_D.6';
            contacts.add(contact12);
            Contact contact13 = AllDataFactory.getContact('13', user13.Id, filiale4.Id);
            contact13.PTF_TipologiaRuolo__c = ruolo3.Id;
            contact13.PTF_RegistrationNumber__c ='12347';
            contact13.PTF_ProfiloLDAP__c ='NEC_D.7';
            contacts.add(contact13);
            Contact contact14 = AllDataFactory.getContact('14', user14.Id, filiale4.Id);
            contact14.PTF_TipologiaRuolo__c = ruolo3.Id;
            contact14.PTF_RegistrationNumber__c ='12348';
            contact14.PTF_ProfiloLDAP__c ='NEC_D.9';
            contacts.add(contact14);
            Contact contact15 = AllDataFactory.getContact('15', user15.Id, filiale4.Id);
            contact15.PTF_TipologiaRuolo__c = ruolo3.Id;
            contact15.PTF_RegistrationNumber__c ='12349';
            contact15.PTF_ProfiloLDAP__c ='NEC_D.9';
            contacts.add(contact15);
            Contact contact16 = AllDataFactory.getContact('16', user16.Id, filiale2.Id);
            contact16.PTF_TipologiaRuolo__c = ruolo5.Id;
            contact16.PTF_RegistrationNumber__c ='12350';
            contact16.PTF_ProfiloLDAP__c ='NEC_F.9';
            contacts.add(contact16);
            Contact contact17 = AllDataFactory.getContact('17', user17.Id, filiale5.Id);
            contact17.PTF_TipologiaRuolo__c = ruolo6.Id;
            contact17.PTF_RegistrationNumber__c ='12351';
            contact17.PTF_ProfiloLDAP__c ='NEC_T.4';
            contacts.add(contact17);
            Contact contact18 = AllDataFactory.getContact('18', user18.Id, filiale5.Id);
            contact18.PTF_TipologiaRuolo__c = ruolo7.Id;
            contact18.PTF_RegistrationNumber__c ='12352';
            contact18.PTF_ProfiloLDAP__c ='NEC_T.10';
            contacts.add(contact18);
    
            Contact contact19 = AllDataFactory.getContact('19', user19.Id, filiale4.Id);
            contact19.PTF_TipologiaRuolo__c = ruolo8.Id;
            contact19.PTF_RegistrationNumber__c ='11111';
            contact19.PTF_ProfiloLDAP__c ='NEC_D.4';
            contacts.add(contact19);

            Contact contact20 = AllDataFactory.getContact('20', user20.Id, filiale4.Id);
            contact20.PTF_TipologiaRuolo__c = ruolo9.Id;
            contact20.PTF_RegistrationNumber__c ='22222';
            contact20.PTF_ProfiloLDAP__c ='NEC_D.5';
            contacts.add(contact20);

            Contact contactNec_D6 = AllDataFactory.getContact('21', user21.Id, filiale4.Id);
            contactNec_D6.PTF_TipologiaRuolo__c = ruolo10.Id;
            contactNec_D6.PTF_RegistrationNumber__c ='33333';
            contactNec_D6.PTF_ProfiloLDAP__c ='NEC_D.6';
            contacts.add(contactNec_D6);

            Contact contactNec_F2 = AllDataFactory.getContact('22', user22.Id, filiale4.Id);
            contactNec_F2.PTF_TipologiaRuolo__c = ruolo11.Id;
            contactNec_F2.PTF_RegistrationNumber__c ='44444';
            contactNec_F2.PTF_ProfiloLDAP__c ='NEC_F.2';
            contacts.add(contactNec_F2);

            Contact contactNonElegibile = AllDataFactory.getContact('23', user23.Id, filiale4.Id);
            contactNonElegibile.PTF_TipologiaRuolo__c = ruolo11.Id;
            contactNonElegibile.PTF_RegistrationNumber__c ='55555';
            contactNonElegibile.PTF_ProfiloLDAP__c ='NEC_XXX';
            contacts.add(contactNonElegibile);
                    
            
            contacts.add(contact);
            contacts.add(contact2);
            contacts.add(contact3);
            contacts.add(contact4);
            contacts.add(contact5);
            //insert new List<Contact>{contact, contact2, contact3,contact4,contact5,contact6,contact7,contact8,contact9,contact10,contact11,contact12,contact13,contact14};
            insert contacts;
            
            Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet', filiale.Id, 'CORPORATE');
            Wallet__c microPortafoglio2 = AllDataFactory.getWallet('MicroWallet', filiale.Id, 'CORPORATE');
            Wallet__c microPortafoglio3 = AllDataFactory.getWallet('MicroWallet', filiale4.Id, 'CORPORATE');
            microPortafoglio3.PTF_DeletionDate__c=null;
            microPortafoglio3.PTF_Pool__c = true;
            microPortafoglio2.PTF_Pool__c = true;
            insert new List<Wallet__c>{microPortafoglio,microPortafoglio2,microPortafoglio3};
            
            Assignment__c backupAssignment = AllDataFactory.getAssignment('Backup', microPortafoglio.Id, contact.Id);
            Assignment__c primarioAssignment = AllDataFactory.getAssignment('Primario', microPortafoglio.Id, contact2.Id);
            Assignment__c primarioAssignment1 = AllDataFactory.getAssignment('Primario', microPortafoglio3.Id, contact20.Id);
            Assignment__c primarioAssignment2 = AllDataFactory.getAssignment('Primario', microPortafoglio3.Id, contact11.Id);
            primarioAssignment1.PTF_EndDate__c=null;
            primarioAssignment2.PTF_EndDate__c=null;
            //Assignment__c primarioAssignment2 = AllDataFactory.getAssignment('Primario', microPortafoglio.Id, contact5.Id);
            Test.startTest();
            insert new List<Assignment__c>{backupAssignment, primarioAssignment,primarioAssignment1,primarioAssignment2};
            
                
            delete contact;
            contact3.PTF_TipologiaRuolo__c = ruolo2.Id;
            contact2.AccountId = filiale2.Id;
            contact4.PTF_Ruolo__c = '069'; 
            contact5.PTF_CentroPrivate__c = 'CP5';
            FollowUp.invokeBatchAssignment = true;
            //update new List<Contact>{contact3,contact2,contact4,contact5};
            //01015
            

            contact10.AccountId = filiale3.Id;
            contact10.PTF_ProfiloLDAP__c = 'NEC_A.5';
            contact11.AccountId = filiale3.Id;
            contact11.PTF_ProfiloLDAP__c = 'NEC_D.4';
            contact11.PTF_TipologiaRuolo__c = ruolo10.id;
            contact12.AccountId = filiale3.Id;
            contact12.PTF_ProfiloLDAP__c = 'NEC_D.5';
            contact13.AccountId = filiale4.Id;
            contact13.PTF_ProfiloLDAP__c = 'NEC_D.9';
            contact14.AccountId = filiale2.Id;        
            contact14.PTF_ProfiloLDAP__c = 'NEC_CF';

            contact15.AccountId = filiale2.Id;
            contact15.PTF_ProfiloLDAP__c = null;
            contact15.PTF_TipologiaRuolo__c=ruolo4.Id;
            update contact15;

            contact20.PTF_ProfiloLDAP__c=null;
            contact20.AccountId = filiale2.Id;
            contact20.PTF_TipologiaRuolo__c=ruolo8.id;
            update contact20;
            contact20.PTF_ProfiloLDAP__c='NEC_CF';
            contact20.AccountId = filiale3.Id;
            contact20.PTF_TipologiaRuolo__c=ruolo5.id;
            update contact20;

            contact15.PTF_ProfiloLDAP__c = 'NEC_F.10';
            update new List<Contact>{contact3,contact2,contact4,contact5,contact10,contact11,contact12,contact13,contact14,contact15};
            delete new List<Contact>{contact3,contact2,contact4,contact5,contact10,contact11};

            Test.stopTest();
        }
    }
    @isTest
    static void testNEC_T7(){
        String profiloName = Label.System_Administrator;
        Profile profile = [SELECT id FROM Profile WHERE Name =:profiloName  LIMIT 1];

        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        Account executive = AllDataFactory.getAccount('05', 'FilialeDiRelazione');
        executive.PTF_IdCEDPadre__c='3008';
        insert executive;

        RoleTypology__c ruolo1 = new RoleTypology__c();
        ruolo1.Name = 'Titolare';
        ruolo1.PTF_Code__c='100';
        insert ruolo1;
        ServiceModel__c modelloDiServizio = new ServiceModel__c();
        modelloDiServizio.Name = 'CORPORATE';
        insert modelloDiServizio;

        RoleMDS__c ruoloMDS1 = new RoleMDS__c();
        ruoloMDS1.PTF_BranchTypology__c = 'A';
        ruoloMDS1.PTF_RoleTypology__c = ruolo1.Id;
        ruoloMDS1.PTF_ServiceModel__c = modelloDiServizio.Id;
        ruoloMDS1.PTF_StartDate__c = Date.today().addDays(-10);
        ruoloMDS1.PTF_EndDate__c = Date.today().addDays(10);
        insert ruoloMDS1;

        LDAP__c ldap = new LDAP__c();
        ldap.Matricola__c = 'U55555';
        ldap.Ruolo_LDAP__c = '100';
        ldap.Ruolo_LDAP_Calcolato__c = '100';
        ldap.IDCed__c='21718';
        insert ldap; 

        Contact contact = AllDataFactory.getContact('04', user.Id, executive.Id);
        contact.PTF_RegistrationNumber__c='55555';
        contact.PTF_TipologiaRuolo__c = ruolo1.Id;
        contact.PTF_Ruolo__c='100';
        contact.PTF_ProfiloLDAP__c = 'NEC_T.7';
        contact.PTF_ReferenteElegibile__c=true;
        contact.AccountId=executive.id;
        insert new List<Contact>{contact};

        ldap.IDCed__c='21719';
        update ldap;
        update contact;
        ldap.IDCed__c='21720';
        update ldap;
        update contact;
        ldap.IDCed__c='21716';
        update ldap;
        update contact;
        ldap.IDCed__c='21715';
        update ldap;
        update contact;
        ldap.IDCed__c='21713';
        update ldap;
        update contact;

    }
    @isTest
    static void testNEC_D6(){

        String profiloName = Label.System_Administrator;
        Profile profile = [SELECT id FROM Profile WHERE Name =:profiloName  LIMIT 1];

        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        Account acc = AllDataFactory.getAccount('05', 'FilialeDiRelazione');
        acc.FinServ__BankNumber__c='05387';
        insert acc;

        RoleTypology__c ruolo1 = new RoleTypology__c();
        ruolo1.Name = 'Titolare';
        ruolo1.PTF_Code__c='031';
        insert ruolo1;

        ServiceModel__c modelloDiServizio = new ServiceModel__c();
        modelloDiServizio.Name = 'CORPORATE';
        modelloDiServizio.PTF_Division__c = 'KI';
        modelloDiServizio.PTF_MacroDivision__c = 'IC';
        insert modelloDiServizio;

        RoleMDS__c ruoloMDS1 = new RoleMDS__c();
        ruoloMDS1.PTF_BranchTypology__c = 'A';
        ruoloMDS1.PTF_RoleTypology__c = ruolo1.Id;
        ruoloMDS1.PTF_ServiceModel__c = modelloDiServizio.Id;
        ruoloMDS1.PTF_StartDate__c = Date.today().addDays(-10);
        ruoloMDS1.PTF_EndDate__c = Date.today().addDays(10);
        insert ruoloMDS1;

        LDAP__c ldap = new LDAP__c();
        ldap.Matricola__c = 'U55555';
        ldap.Ruolo_LDAP__c = '031';
        ldap.Ruolo_LDAP_Calcolato__c = '031';
        ldap.IDCed__c='21718';
        insert ldap; 

        Contact contact = AllDataFactory.getContact('04', user.Id, acc.Id);
        contact.PTF_RegistrationNumber__c='55555';
        contact.PTF_TipologiaRuolo__c = ruolo1.Id;
        contact.PTF_Ruolo__c='031';
        contact.PTF_ProfiloLDAP__c = 'NEC_D.6';
        contact.PTF_ReferenteElegibile__c=true;
        contact.AccountId=acc.id;
        insert new List<Contact>{contact};
    }
    
@isTest
    static void testNEC_D7(){

        String profiloName = Label.System_Administrator;
        Profile profile = [SELECT id FROM Profile WHERE Name =:profiloName  LIMIT 1];

        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        Account acc = AllDataFactory.getAccount('05', 'FilialeDiRelazione');
        acc.FinServ__BankNumber__c='05387';
        insert acc;

        RoleTypology__c ruolo1 = new RoleTypology__c();
        ruolo1.Name = 'Titolare';
        ruolo1.PTF_Code__c='301';
        insert ruolo1;

        ServiceModel__c modelloDiServizio = new ServiceModel__c();
        modelloDiServizio.Name = 'CORPORATE';
        modelloDiServizio.PTF_Division__c = 'KI';
        modelloDiServizio.PTF_MacroDivision__c = 'IC';
        insert modelloDiServizio;

        RoleMDS__c ruoloMDS1 = new RoleMDS__c();
        ruoloMDS1.PTF_BranchTypology__c = 'A';
        ruoloMDS1.PTF_RoleTypology__c = ruolo1.Id;
        ruoloMDS1.PTF_ServiceModel__c = modelloDiServizio.Id;
        ruoloMDS1.PTF_StartDate__c = Date.today().addDays(-10);
        ruoloMDS1.PTF_EndDate__c = Date.today().addDays(10);
        insert ruoloMDS1;

        LDAP__c ldap = new LDAP__c();
        ldap.Matricola__c = 'U55555';
        ldap.Ruolo_LDAP__c = '300';
        ldap.Ruolo_LDAP_Calcolato__c = '301';
        ldap.IDCed__c='7114';
        insert ldap; 

        Contact contact = AllDataFactory.getContact('04', user.Id, acc.Id);
        contact.PTF_RegistrationNumber__c='55555';
        contact.PTF_TipologiaRuolo__c = ruolo1.Id;
        contact.PTF_Ruolo__c='300';
        contact.PTF_ProfiloLDAP__c = 'NEC_D.7';
        contact.PTF_ReferenteElegibile__c=true;
        contact.AccountId=acc.id;
        insert new List<Contact>{contact};
        
        ldap.IDCed__c='21719';
        update ldap;
        update contact;
        ldap.IDCed__c='21720';
        update ldap;
        update contact;
        ldap.IDCed__c='21716';
        update ldap;
        update contact;
        ldap.IDCed__c='21715';
        update ldap;
        update contact;
        ldap.IDCed__c='21713';
        update ldap;
        update contact;
    }

    @isTest
    static void testNEC_D9(){

        String profiloName = Label.System_Administrator;
        Profile profile = [SELECT id FROM Profile WHERE Name =:profiloName  LIMIT 1];

        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        Account acc = AllDataFactory.getAccount('05', 'FilialeDiRelazione');
        acc.FinServ__BankNumber__c='01015';
        insert acc;

        RoleTypology__c ruolo1 = new RoleTypology__c();
        ruolo1.Name = 'Titolare';
        ruolo1.PTF_Code__c='100';
        insert ruolo1;

        ServiceModel__c modelloDiServizio = new ServiceModel__c();
        modelloDiServizio.Name = 'Enti E Tesorerie';
        modelloDiServizio.PTF_Division__c = 'ET';
        modelloDiServizio.PTF_MacroDivision__c = 'IC';
        insert modelloDiServizio;

        RoleMDS__c ruoloMDS1 = new RoleMDS__c();
        ruoloMDS1.PTF_BranchTypology__c = 'A';
        ruoloMDS1.PTF_RoleTypology__c = ruolo1.Id;
        ruoloMDS1.PTF_ServiceModel__c = modelloDiServizio.Id;
        ruoloMDS1.PTF_StartDate__c = Date.today().addDays(-10);
        ruoloMDS1.PTF_EndDate__c = Date.today().addDays(10);
        insert ruoloMDS1;

        LDAP__c ldap = new LDAP__c();
        ldap.Matricola__c = 'U55555';
        ldap.Ruolo_LDAP__c = '100';
        ldap.Ruolo_LDAP_Calcolato__c = 'F_909';
        ldap.IDCed__c='5692';
        insert ldap; 

        Contact contact = AllDataFactory.getContact('04', user.Id, acc.Id);
        contact.PTF_RegistrationNumber__c='55555';
        contact.PTF_TipologiaRuolo__c = ruolo1.Id;
        contact.PTF_Ruolo__c='100';
        contact.PTF_ProfiloLDAP__c = 'NEC_D.9';
        contact.PTF_ReferenteElegibile__c=true;
        contact.AccountId=acc.id;
        insert new List<Contact>{contact};
        
        ldap.IDCed__c='21719';
        update ldap;
        update contact;
        ldap.IDCed__c='21720';
        update ldap;
        update contact;
        ldap.IDCed__c='21716';
        update ldap;
        update contact;
        ldap.IDCed__c='21715';
        update ldap;
        update contact;
        ldap.IDCed__c='21713';
        update ldap;
        update contact;
    }
    @isTest
    static void testNEC_D10(){

        String profiloName = Label.System_Administrator;
        Profile profile = [SELECT id FROM Profile WHERE Name =:profiloName  LIMIT 1];

        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        Account acc = AllDataFactory.getAccount('05', 'FilialeDiRelazione');
        acc.FinServ__BankNumber__c='05387';
        insert acc;

        RoleTypology__c ruolo1 = new RoleTypology__c();
        ruolo1.Name = 'Titolare';
        ruolo1.PTF_Code__c='100';
        insert ruolo1;

        ServiceModel__c modelloDiServizio = new ServiceModel__c();
        modelloDiServizio.Name = 'CORPORATE';
        modelloDiServizio.PTF_Division__c = 'KI';
        modelloDiServizio.PTF_MacroDivision__c = 'IC';
        insert modelloDiServizio;

        RoleMDS__c ruoloMDS1 = new RoleMDS__c();
        ruoloMDS1.PTF_BranchTypology__c = 'A';
        ruoloMDS1.PTF_RoleTypology__c = ruolo1.Id;
        ruoloMDS1.PTF_ServiceModel__c = modelloDiServizio.Id;
        ruoloMDS1.PTF_StartDate__c = Date.today().addDays(-10);
        ruoloMDS1.PTF_EndDate__c = Date.today().addDays(10);
        insert ruoloMDS1;

        LDAP__c ldap = new LDAP__c();
        ldap.Matricola__c = 'U55555';
        ldap.Ruolo_LDAP__c = '100';
        ldap.Ruolo_LDAP_Calcolato__c = 'F_144';
        ldap.IDCed__c='21713';
        insert ldap; 

        Contact contact = AllDataFactory.getContact('04', user.Id, acc.Id);
        contact.PTF_RegistrationNumber__c='55555';
        contact.PTF_TipologiaRuolo__c = ruolo1.Id;
        contact.PTF_Ruolo__c='100';
        contact.PTF_ProfiloLDAP__c = 'NEC_D.10';
        contact.PTF_ReferenteElegibile__c=true;
        contact.AccountId=acc.id;
        insert new List<Contact>{contact};
        
        ldap.IDCed__c='21719';
        update ldap;
        update contact;
        ldap.IDCed__c='21720';
        update ldap;
        update contact;
        ldap.IDCed__c='21716';
        update ldap;
        update contact;
        ldap.IDCed__c='21715';
        update ldap;
        update contact;
        ldap.IDCed__c='21713';
        update ldap;
        update contact;
    }
}