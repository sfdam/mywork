@IsTest
public with sharing class AggiungiMassivamenteNdgPFControllerTest {
    @TestSetup
    static void setup(){
        Funzionalita__c x = new Funzionalita__c();
        x.Disable_Trigger__c =true;
        insert x;

        ServiceModel__c personal = new ServiceModel__c(Name = 'Personal',
        PTF_Division__c = 'PE',
        PTF_MacroDivision__c = 'WM');

        ServiceModel__c family = new ServiceModel__c(Name = 'Family',
        PTF_Division__c = 'PE',
        PTF_MacroDivision__c = 'EB');
        insert new List<ServiceModel__c>{personal, family};
        Account banca = AllDataFactory.getAccount('10', 'Banca');
        banca.FinServ__BankNumber__c = '05387';
        insert banca;
        Account dir = AllDataFactory.getAccount('09', 'DirezioneRegionale');
        dir.FinServ__BankNumber__c = '05387';
        dir.parentId = banca.Id;
        dir.PTF_Banca__c = banca.Id;
        insert dir;
        Account area = AllDataFactory.getAccount('08', 'Area');
        area.FinServ__BankNumber__c = '05387';
        area.parentId = dir.Id;
        area.PTF_Banca__c = banca.Id;
        area.PTF_DirezioneRegionale__c = dir.Id;
        insert area;
        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        filiale.FinServ__BankNumber__c = '05387';
        filiale.parentId = area.Id;
        filiale.PTF_BranchTypology__c = 'A';
        filiale.PTF_Banca__c = banca.Id;
        filiale.PTF_DirezioneRegionale__c = dir.Id;
        filiale.PTF_Area__c = area.Id;
        insert filiale;

        Wallet__c microPortafoglioPersonal = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Personal');
        microPortafoglioPersonal.PTF_Filiale__c = filiale.Id;
        microPortafoglioPersonal.PTF_Area__c = area.Id;
        microPortafoglioPersonal.PTF_DirezioneRegionale__c = dir.id;
        microPortafoglioPersonal.PTF_Banca__c = banca.Id;
        insert microPortafoglioPersonal;
        Wallet__c microPortafoglioPersonal2 = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Personal');
        microPortafoglioPersonal2.PTF_Filiale__c = filiale.Id;
        microPortafoglioPersonal2.PTF_Area__c = area.Id;
        microPortafoglioPersonal2.PTF_DirezioneRegionale__c = dir.id;
        microPortafoglioPersonal2.PTF_Banca__c = banca.Id;
        insert microPortafoglioPersonal2;

        // Relazione Di Cointestazione
        Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
        personAccount.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        personAccount.PTF_Filiale__c = filiale.Id;

        Account personAccount2 = AllDataFactory.getAccount('02', 'PersonAccount');
        personAccount2.PTF_Portafoglio__c = microPortafoglioPersonal2.Id;
        personAccount2.PTF_Filiale__c = filiale.Id;

        Account personAccount3 = AllDataFactory.getAccount('03', 'PersonAccount');
        personAccount3.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        personAccount3.PTF_Filiale__c = filiale.Id;

        Account cointestazione = AllDataFactory.getAccount('04', 'Cointestazione');
        cointestazione.PTF_Portafoglio__c = microPortafoglioPersonal2.Id;
        cointestazione.PTF_Filiale__c = filiale.Id;
        cointestazione.PTF_NaturaGiuridica__c='CO';

        // Gruppo
        Account gruppo = AllDataFactory.getAccount('05', 'GruppoFinanziario');
        gruppo.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        gruppo.PTF_Filiale__c = filiale.Id;
        gruppo.PTF_NaturaGiuridica__c = 'GF';

        Account business = AllDataFactory.getAccount('06', 'IndustriesBusiness');
        business.PTF_Portafoglio__c = microPortafoglioPersonal2.Id;
        business.PTF_Filiale__c = filiale.Id;
        business.CRM_NDG__c = 'Account06';

        Account business2 = AllDataFactory.getAccount('07', 'IndustriesBusiness');
        business2.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        business2.PTF_Filiale__c = filiale.Id;
        business.CRM_NDG__c = 'Account07';

        Account business3 = AllDataFactory.getAccount('08', 'IndustriesBusiness');
        business3.PTF_Portafoglio__c = microPortafoglioPersonal2.Id;
        business3.PTF_Filiale__c = filiale.Id;
        business3.CRM_NDG__c = 'Account08';

        insert new List<Account>{personAccount3, cointestazione, gruppo, business, business2,business3};

        CRM_LinkedNDG__c capoGruppo = new CRM_LinkedNDG__c(
            CRM_Account__c = gruppo.Id,
            CRM_RelatedAccount__c = business.Id,
            CRM_LinkCode__c = '113',
            CRM_Status__c = 'A',
            CRM_LinkType__c = 'CAPOGRUPPO'
        );
        CRM_LinkedNDG__c membroGruppo = new CRM_LinkedNDG__c(
            CRM_Account__c = gruppo.Id,
            CRM_RelatedAccount__c = business2.Id,
            CRM_LinkCode__c = '165',
            CRM_Status__c = 'A',
            CRM_LinkType__c = 'CONN.GIUR.'
        );
        CRM_LinkedNDG__c membroGruppo1 = new CRM_LinkedNDG__c(
            CRM_Account__c = gruppo.Id,
            CRM_RelatedAccount__c = business3.Id,
            CRM_LinkCode__c = '165',
            CRM_Status__c = 'E',
            CRM_LinkType__c = 'CONN.GIUR.'
        );
        insert new List<CRM_LinkedNDG__c>{capoGruppo, membroGruppo, membroGruppo1};

        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];
        
        User user = AllDataFactory.getUser('10', profile.Id, 'Personal');
        user.FederationIdentifier='10';
        User ufficioModelliDistributivi = AllDataFactory.getUser('11', profile.Id, 'Personal');
        ufficioModelliDistributivi.FederationIdentifier = '11';
        ufficioModelliDistributivi.Profilo__c = 'NEC_D.0';
        User NECF1 = AllDataFactory.getUser('14', profile.Id, 'Family');
        NECF1.FederationIdentifier = '14';
        NECF1.Profilo__c = 'NEC_F.1';
        insert new List<User>{user, ufficioModelliDistributivi, NECF1};

        System.runAs(user){

            Contact contact = AllDataFactory.getContact('01', ufficioModelliDistributivi.Id, banca.id);
            Contact contact2 = AllDataFactory.getContact('02', NECF1.Id, filiale.id);
            insert new List<Contact>{contact, contact2};
        }
    }
    @isTest
    static void testInit(){
        Contact c= new Contact(LastName='test', PTF_User__c=UserInfo.getUserId());
        insert c;
        Wallet__c mp=[SELECT Id,PTF_ModelloDiServizio__c,PTF_Banca__r.FinServ__BankNumber__c,PTF_Filiale__r.PTF_BranchTypeDesc__c FROM Wallet__c ORDER BY CreatedDate asc LIMIT 1];
        Map<String,Object> output=AggiungiMassivamenteNdgPFController.init(mp.Id);
        System.debug('outpt1 ' + output);
        System.assertEquals(False,output.get('hasOFS'));
        System.assertEquals([SELECT Id, Profile.Name, Profilo__c, PTF_RuoloLDAP__c, idced__c, PTF_IdCEDPadre__c, banca__c FROM User WHERE id =: UserInfo.getUserId()], output.get('currentUser'));
        
    }

    @isTest
    static void testLoadUpdate(){
        User user = [SELECT Id FROM user WHERE FederationIdentifier = '14'];
        
        Test.startTest();
        System.runAs(user){

            Wallet__c mp1=[SELECT Id,PTF_ModelloDiServizio__c,PTF_Banca__r.FinServ__BankNumber__c,PTF_Filiale__r.PTF_BranchTypeDesc__c  FROM Wallet__c ORDER BY CreatedDate desc LIMIT 1];
            Wallet__c mp2=[SELECT Id,PTF_ModelloDiServizio__c,PTF_Banca__r.FinServ__BankNumber__c,PTF_Filiale__r.PTF_BranchTypeDesc__c  FROM Wallet__c ORDER BY CreatedDate asc LIMIT 1];
            AggiungiMassivamenteNdgPFController.loadMwList(mp1.PTF_Filiale__c, 'Personal', null, mp1.Id, 0, 5);
            AggiungiMassivamenteNdgPFController.loadNdgList(mp2, true, 'Test',  null, 0, 5, mp1);
            List<Account> ndgList = [SELECT Id FROM Account];
            List<String> ndgIdList = new List<String>();
            ndgIdList.add(ndgList[0].Id);
            AggiungiMassivamenteNdgPFController.moveNdgsToWallet(mp1.Id, ndgIdList);
            // Map<String, String> idFittiziaMap = SpostaNdgIterDataLoader.idFittiziaMap;
            Map<String, SObject> servceModelMap = AggiungiMassivamenteNdgPFController.servceModelMap;
            servceModelMap = AggiungiMassivamenteNdgPFController.servceModelMap;
            List<Account> accounts = [SELECT Id,PTF_Portafoglio__c  
            FROM Account    
            WHERE Id IN :ndgIdList];
            System.assertEquals(True,accounts.size()>0);
            System.assertEquals(mp1.Id, accounts[0].PTF_Portafoglio__c);
        }
        Test.stopTest();
    }

    @isTest
    static void testLoadUpdate2(){
        Test.startTest();
        
        Wallet__c mp1=[SELECT Id,PTF_ModelloDiServizio__c,PTF_Banca__r.FinServ__BankNumber__c,PTF_Filiale__r.PTF_BranchTypeDesc__c  FROM Wallet__c ORDER BY CreatedDate asc LIMIT 1];
        Wallet__c mp2=[SELECT Id,PTF_ModelloDiServizio__c,PTF_Banca__r.FinServ__BankNumber__c,PTF_Filiale__r.PTF_BranchTypeDesc__c  FROM Wallet__c ORDER BY CreatedDate desc LIMIT 1];
        AggiungiMassivamenteNdgPFController.loadMwList(mp1.PTF_Filiale__c, 'Personal', null, mp1.Id, 0, 5);
        AggiungiMassivamenteNdgPFController.loadNdgList(mp2, true, 'Test',  null, 0, 5, mp1);
        List<Account> ndgList = [SELECT Id FROM Account];
        List<String> ndgIdList = new List<String>();
        ndgIdList.add(ndgList[0].Id);
        AggiungiMassivamenteNdgPFController.moveNdgsToWallet(mp1.Id, ndgIdList);
        Test.stopTest();
        List<Account> accounts = [SELECT Id,PTF_Portafoglio__c  
                                FROM Account    
                                WHERE Id IN :ndgIdList];
        System.assertEquals(True,accounts.size()>0);
        System.assertEquals(mp1.Id, accounts[0].PTF_Portafoglio__c);

    }
    @isTest
    static void testGetLogicaApprovazione(){
        Test.startTest();
        Wallet__c mp1=[SELECT Id, PTF_Filiale__c,PTF_ModelloDiServizio__c FROM Wallet__c ORDER BY CreatedDate asc LIMIT 1];
        Wallet__c mp2=[SELECT Id, PTF_Filiale__c,PTF_ModelloDiServizio__c FROM Wallet__c ORDER BY CreatedDate desc LIMIT 1];
        Map<String,Object> getLogicaApprovazione1 = AggiungiMassivamenteNdgPFController.getLogicaApprovazione(mp1.Id, mp2.Id);
        List<ConfigurazioneSpostamenti__mdt> ConfigurazioneSpostamenti = [ SELECT Id, PTF_MDS_End__c, PTF_MDS_Start__c
                    FROM ConfigurazioneSpostamenti__mdt 
                    WHERE PTF_MDS_Start__c =: mp1.PTF_ModelloDiServizio__c AND PTF_MDS_End__c =: mp2.PTF_ModelloDiServizio__c];
        Test.stopTest();
        System.assert(ConfigurazioneSpostamenti.size()==getLogicaApprovazione1.size());      
        
    }
}