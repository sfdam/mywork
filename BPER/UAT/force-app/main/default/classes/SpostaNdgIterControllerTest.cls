@isTest
public class SpostaNdgIterControllerTest {
    
    @TestSetup
    public static void setup(){

        // TriggerControl__c tc = new TriggerControl__c();
        // tc.name = 'TEST';
        // insert tc;

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

        Account filiale2 = AllDataFactory.getAccount('30', 'FilialeDiRelazione');
        filiale2.FinServ__BankNumber__c = '05387';
        filiale2.parentId = area.Id;
        filiale2.PTF_BranchTypology__c = 'A';
        filiale2.PTF_Banca__c = banca.Id;
        filiale2.PTF_DirezioneRegionale__c = dir.Id;
        filiale2.PTF_Area__c = area.Id;
        insert new List<Account>{filiale, filiale2};

        Wallet__c microPortafoglioFamily = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Family');
        Wallet__c microPortafoglioFamily2 = AllDataFactory.getWallet('MicroWallet',  filiale2.Id, 'Family');
        Wallet__c microPortafoglioPersonal = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Personal');
        Wallet__c microPortafoglioPersonal2 = AllDataFactory.getWallet('MicroWallet',  filiale2.Id, 'Personal');
        Wallet__c microPortafoglioAssente = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Assente');
        Wallet__c microPortafoglioCF = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Consulenti Finanziari');
        insert new List<Wallet__c>{microPortafoglioFamily, microPortafoglioPersonal, microPortafoglioFamily2, microPortafoglioPersonal2, microPortafoglioAssente,microPortafoglioCF};

        // Relazione Di Cointestazione
        Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
        personAccount.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        personAccount.PTF_Filiale__c = filiale.Id;

        Account personAccount2 = AllDataFactory.getAccount('02', 'PersonAccount');
        personAccount2.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        personAccount2.PTF_Filiale__c = filiale.Id;

        Account personAccount3 = AllDataFactory.getAccount('03', 'PersonAccount');
        personAccount3.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        personAccount3.PTF_Filiale__c = filiale.Id;

        Account personAccount4 = AllDataFactory.getAccount('09', 'PersonAccount');
        personAccount4.PTF_Portafoglio__c = microPortafoglioAssente.Id;
        personAccount4.PTF_Filiale__c = filiale.Id;
        
		Account personAccount12 = AllDataFactory.getAccount('12', 'PersonAccount');
        personAccount4.PTF_Portafoglio__c = microPortafoglioCF.Id;
        personAccount4.PTF_Filiale__c = filiale.Id;
        
        Account cointestazione = AllDataFactory.getAccount('04', 'Cointestazione');
        cointestazione.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        cointestazione.PTF_Filiale__c = filiale.Id;
        cointestazione.PTF_NaturaGiuridica__c='CO';
        insert cointestazione;

        // Gruppo
        Account gruppo = AllDataFactory.getAccount('05', 'GruppoFinanziario');
        gruppo.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        gruppo.PTF_Filiale__c = filiale.Id;
        gruppo.PTF_NaturaGiuridica__c = 'GF';

        Account business = AllDataFactory.getAccount('06', 'IndustriesBusiness');
        business.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        business.PTF_Filiale__c = filiale.Id;
        business.CRM_NDG__c = 'Account06';

        Account business2 = AllDataFactory.getAccount('07', 'IndustriesBusiness');
        business2.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        business2.PTF_Filiale__c = filiale.Id;
        business.CRM_NDG__c = 'Account07';

        Account business3 = AllDataFactory.getAccount('08', 'IndustriesBusiness');
        business3.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        business3.PTF_Filiale__c = filiale.Id;
        business3.CRM_NDG__c = 'Account08';

        insert new List<Account>{personAccount, personAccount2, personAccount3, gruppo, business, business2,business3};

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

        CRM_AccountAccountJointOwnershipRelation__c relazioneDiCointestazionePrimario = new CRM_AccountAccountJointOwnershipRelation__c();
        relazioneDiCointestazionePrimario.CRM_PrimaryNDG__c = true;
        relazioneDiCointestazionePrimario.CRM_Account__c = personAccount.Id;
        relazioneDiCointestazionePrimario.CRM_JointOwnership__c = cointestazione.Id;
        relazioneDiCointestazionePrimario.CRM_Active__c = true;

        CRM_AccountAccountJointOwnershipRelation__c relazioneDiCointestazioneCointestatario = new CRM_AccountAccountJointOwnershipRelation__c();
        relazioneDiCointestazioneCointestatario.CRM_PrimaryNDG__c = false;
        relazioneDiCointestazioneCointestatario.CRM_Account__c = personAccount2.Id;
        relazioneDiCointestazioneCointestatario.CRM_JointOwnership__c = cointestazione.Id;
        relazioneDiCointestazioneCointestatario.CRM_Active__c = true;

        CRM_AccountAccountJointOwnershipRelation__c relazioneDiCointestazioneCointestatario2 = new CRM_AccountAccountJointOwnershipRelation__c();
        relazioneDiCointestazioneCointestatario2.CRM_PrimaryNDG__c = false;
        relazioneDiCointestazioneCointestatario2.CRM_Account__c = personAccount3.Id;
        relazioneDiCointestazioneCointestatario2.CRM_JointOwnership__c = cointestazione.Id;
        relazioneDiCointestazioneCointestatario2.CRM_Active__c = true;
        insert new List<CRM_AccountAccountJointOwnershipRelation__c>{relazioneDiCointestazionePrimario, relazioneDiCointestazioneCointestatario, relazioneDiCointestazioneCointestatario2};

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
    public static void testCreateQueues(){
        
        Test.startTest();
        User user = [SELECT Id FROM User WHERE Profilo__c = 'NEC_F.1' AND FederationIdentifier = '14' LIMIT 1];
        Map<String, Object> response = new Map<String, Object>();
        System.runAs(user){

            Account account = [SELECT id, PTF_Portafoglio__c FROM Account WHERE LastName = 'LastName01' LIMIT 1];
            account.PTF_NaturaGiuridica__c = 'PF';
            Map<String,Object> initResponse = SpostaNdgIterController.init(account.Id);
            Wallet__c portafoglioDiPartenza = (Wallet__c) JSON.deserialize(JSON.serialize(initResponse.get('currentPF')), Wallet__c.class);
            Account currentNDG = (Account) JSON.deserialize(JSON.serialize(initResponse.get('currentNDG')), Account.class);
            ConfigurazioneSpostamenti__mdt iter = [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                                PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                                PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                                PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                                ,PTF_SuperUsers__c
                                                FROM ConfigurazioneSpostamenti__mdt
                                                WHERE Tipo_di_Spostamento__c = 'MDS' AND PTF_Abi__c = '05387' AND
                                                PTF_MDS_Start__c = 'Personal' AND PTF_MDS_End__c = 'Family'];
            iter.PTF_CheckNaturaGiuridica__c = 'PF,CO';
            Map<String,Object> loadMwListResponse = SpostaNdgIterDataLoader.loadMwList(new list<String>{'Family'}, new list<String>{'Autonoma'}, 5, currentNDG, portafoglioDiPartenza, 'primario', false, currentNDG.PTF_Filiale__c, '', new List<String>(), new List<Assignment__c>());
            loadMwListResponse = SpostaNdgIterDataLoader.loadMwList(new list<String>{'Family'}, new list<String>{'Autonoma'}, 5, currentNDG, portafoglioDiPartenza, 'cointestazione', true, currentNDG.PTF_Filiale__c, '', new List<String>(), new List<Assignment__c>());
            loadMwListResponse = SpostaNdgIterDataLoader.loadMwList(new list<String>{'Family'}, new list<String>{'Autonoma'}, 5, currentNDG, portafoglioDiPartenza, '', true, currentNDG.PTF_Filiale__c, '', new List<String>(), new List<Assignment__c>());
            List<Wallet__c> portafogliEligible = (List<Wallet__c>) JSON.deserialize(JSON.serialize(loadMwListResponse.get('mwList')), List<Wallet__c>.class);
            Wallet__c portafoglioDiDestinazione = [SELECT Id, Name, PTF_ModelloDiServizio__c,
            PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
            PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,
            PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
            PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c,
            (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
            FROM Wallet__c WHERE PTF_ModelloDiServizio__c = 'Family' AND RecordType.developerName != 'TechnicalWallet' LIMIT 1 ];
            Map<String, SObject> ndgIterMap = new Map<String, SObject>{
                account.Id => iter
            };
            Map<String, String> ndgIterTypeMap = new Map<String, String>{
                account.Id => 'MDS'
            };
            Map<String, String> subjectMap = new Map<String, String>{
                account.Id => 'MDS Personal - Family'
            };
            Map<String, String> configurationKeyMap = new Map<String, String>{
                account.Id => 'Personal_Family'
            };
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
            response = (Map<String, Object>)JSON.deserializeUntyped((String)JSON.deserializeUntyped(SpostaNdgIterController.createQueues(new List<Account> {currentNDG}, ndgIterMap, portafoglioDiPartenza, portafoglioDiDestinazione, true, '')));
            Map<String, String> accountWorkOrderKeyMap = (Map<String, String>)JSON.deserialize((String)JSON.serialize(response.get('accountWorkOrderKeyMap')), Map<String, String>.class);
        }
        Test.stopTest();
        System.assertEquals(true, response.size()>0);
    }

    @isTest
    public static void testCointestatario(){

        Test.startTest();
        User user = [SELECT Id FROM User WHERE Profilo__c = 'NEC_F.1' AND FederationIdentifier = '14' LIMIT 1];
        String response;
        System.runAs(user){

            Account account = [SELECT id, PTF_Portafoglio__c FROM Account WHERE LastName = 'LastName03' LIMIT 1];
            account.PTF_NaturaGiuridica__c = 'PF';
            Map<String,Object> initResponse = SpostaNdgIterController.init(account.Id);
            Account currentNDG = (Account) JSON.deserialize(JSON.serialize(initResponse.get('currentNDG')), Account.class);
            Wallet__c portafoglioDiPartenza = (Wallet__c) JSON.deserialize(JSON.serialize(initResponse.get('currentPF')), Wallet__c.class);
            ConfigurazioneSpostamenti__mdt iter = [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                                PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                                PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                                PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                                ,PTF_SuperUsers__c
                                                FROM ConfigurazioneSpostamenti__mdt
                                                WHERE Tipo_di_Spostamento__c = 'MDS' AND PTF_Abi__c = '05387' AND
                                                PTF_MDS_Start__c = 'Personal' AND PTF_MDS_End__c = 'Family'];
            iter.PTF_CheckNaturaGiuridica__c = 'PF,CO';
            Map<String,Object> loadMwListResponse = SpostaNdgIterDataLoader.loadMwList(new list<String>{'Family'}, new list<String>{'Autonoma'}, 5, currentNDG, portafoglioDiPartenza, '', true, currentNDG.PTF_Filiale__c, '', new List<String>(), new List<Assignment__c>());
            List<Wallet__c> portafogliEligible = (List<Wallet__c>) JSON.deserialize(JSON.serialize(loadMwListResponse.get('mwList')), List<Wallet__c>.class);
            Wallet__c portafoglioDiDestinazione = [SELECT Id, Name, PTF_ModelloDiServizio__c,
            PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
            PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,
            PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
            PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c,
            (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
            FROM Wallet__c WHERE PTF_ModelloDiServizio__c = 'Family' AND RecordType.developerName != 'TechnicalWallet' LIMIT 1 ];
            Map<String, SObject> ndgIterMap = new Map<String, SObject>{
                account.Id => iter
            };
            Map<String, String> ndgIterTypeMap = new Map<String, String>{
                account.Id => 'MDS'
            };
            Map<String, String> subjectMap = new Map<String, String>{
                account.Id => 'MDS Personal - Family'
            };
            Map<String, String> configurationKeyMap = new Map<String, String>{
                account.Id => 'Personal_Family'
            };
            String workOrderKey = SV_Utilities.generateRandomString(24);
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
            response = SpostaNdgIterController.sendMovementRequest(portafoglioDiDestinazione.Id, new List<Account> {currentNDG}, ndgIterTypeMap, subjectMap, 'Note', configurationKeyMap, new List<String>{account.Id}, new Map<String, String>{account.Id => workOrderKey}, new Map<String, String>{workOrderKey => 'STEP1 (NEC_D.4)'}, '', '', account.Id, '', true, '', '', false);
        }
        Test.stopTest();
        System.assertEquals(true, response !=null);
    }

    @isTest
    public static void testCointestazione(){
        User user = [SELECT Id FROM User WHERE Profilo__c = 'NEC_F.1' AND FederationIdentifier = '14' LIMIT 1];
        System.runAs(user){
        Test.startTest();
        Account account = [SELECT id, PTF_Portafoglio__c FROM Account WHERE Name = 'Account04' LIMIT 1];
        Map<String,Object> initResponse = SpostaNdgIterController.init(account.Id);
        Test.stopTest();
        System.assertEquals(true, initResponse.size()>0);
    	}
    }
    @isTest
    public static void testCapoGruppo(){

        Test.startTest();
        User user = [SELECT Id FROM User WHERE Profilo__c = 'NEC_F.1' AND FederationIdentifier = '14' LIMIT 1];
        Map<String,Object> loadNdgList = new Map<String,Object>();
        System.runAs(user){

            Account account = [SELECT id, PTF_Portafoglio__c, PTF_Gruppo__c FROM Account WHERE Name = 'Account06' LIMIT 1];
            Account gruppo = [SELECT id, PTF_Portafoglio__c, PTF_Gruppo__c FROM Account WHERE RecordType.DeveloperName = 'GruppoFinanziario' LIMIT 1];
            Map<String,Object> initResponse = SpostaNdgIterController.init(account.Id);
            Wallet__c portafoglioDiPartenza = (Wallet__c) JSON.deserialize(JSON.serialize(initResponse.get('currentPF')), Wallet__c.class);
            Account currentNDG = (Account) JSON.deserialize(JSON.serialize(initResponse.get('currentNDG')), Account.class);
            Wallet__c portafoglioDiDestinazione = [SELECT Id, Name, PTF_ModelloDiServizio__c,
            PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
            PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,
            PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
            PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c,PTF_StatoAssegnazione__c,
            (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
            FROM Wallet__c WHERE PTF_ModelloDiServizio__c = 'Family' AND RecordType.developerName != 'TechnicalWallet' LIMIT 1 ];
            loadNdgList = SpostaNdgIterController.loadNdgList(gruppo.Id, account.Id, portafoglioDiDestinazione, portafoglioDiPartenza, 5, 'SPA');
        }
        Test.stopTest();
        System.assertEquals(true, loadNdgList.size()>0);
    }

    @isTest
    public static void testMembroGruppo(){
        User user = [SELECT Id FROM User WHERE Profilo__c = 'NEC_F.1' AND FederationIdentifier = '14' LIMIT 1];
        System.runAs(user){
        Test.startTest();
        Account account = [SELECT id, PTF_Portafoglio__c FROM Account WHERE Name = 'Account07' LIMIT 1];
        Map<String,Object> initResponse = SpostaNdgIterController.init(account.Id);
        Test.stopTest();
        System.assertEquals(true, initResponse.size()>0);
        }
     }

    @isTest
    public static void testMoveNdg(){
		User user = [SELECT Id FROM User WHERE Profilo__c = 'NEC_F.1' AND FederationIdentifier = '14' LIMIT 1];
        System.runAs(user){
        Test.startTest();
        Account account = [SELECT id, PTF_Portafoglio__c, RecordType.DeveloperName, PTF_Filiale__c FROM Account WHERE LastName = 'LastName01' LIMIT 1];
        Map<String,Object> initResponse = SpostaNdgIterController.init(account.Id);
        Wallet__c portafoglioDiDestinazione = [SELECT Id, PTF_Filiale__c
        FROM Wallet__c WHERE PTF_ModelloDiServizio__c = 'Family' AND RecordType.developerName != 'TechnicalWallet' LIMIT 1 ];
        SpostaNdgIterController.moveNdgsToWallet(portafoglioDiDestinazione.Id, portafoglioDiDestinazione.PTF_Filiale__c, new List<String>{account.Id}, new List<Account>{account});
        Test.stopTest();
        Account account2 = [SELECT id, PTF_Portafoglio__c, RecordType.DeveloperName, PTF_Filiale__c FROM Account WHERE PTF_Portafoglio__c =: portafoglioDiDestinazione.Id LIMIT 1 ];
        System.assertEquals(true, account2 !=null);
         }
    }

    @isTest
    public static void testCheckEligible(){

        Test.startTest();
        User user = [SELECT Id FROM User WHERE Profilo__c = 'NEC_F.1' AND FederationIdentifier = '14' LIMIT 1];
        Boolean eligible = true;
        System.runAs(user){
            Account account = [SELECT id, PTF_Portafoglio__c,
            PTF_Portafoglio__r.PTF_ModelloDiServizio__c, PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c,
            PTF_Portafoglio__r.PTF_Capofila__c, PTF_Portafoglio__r.PTF_Area__c
            FROM Account 
            WHERE Name = 'Account06' LIMIT 1];
                     
            Map<String,Object> initResponse = SpostaNdgIterController.init(account.Id);
            Wallet__c portafoglioDiPartenza = (Wallet__c) JSON.deserialize(JSON.serialize(initResponse.get('currentPF')), Wallet__c.class);
            Wallet__c portafoglioDiPartenzaCF = (Wallet__c) JSON.deserialize(JSON.serialize(initResponse.get('currentPF')), Wallet__c.class);
            portafoglioDiPartenzaCF.PTF_StatoAssegnazione__c ='Non Assegnato';
            update portafoglioDiPartenzaCF;
            Account filiale = [Select id from Account where Name ='Account30' Limit 1];
            Account currentNDG = (Account) JSON.deserialize(JSON.serialize(initResponse.get('currentNDG')), Account.class);
            Wallet__c portafoglioDiDestinazione = [SELECT Id, Name, PTF_ModelloDiServizio__c,
            PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
            PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,
            PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
            PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c,PTF_StatoAssegnazione__c,
            (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
            FROM Wallet__c WHERE PTF_ModelloDiServizio__c = 'Family' AND RecordType.developerName != 'TechnicalWallet' and PTF_Filiale__c =:filiale.Id ];
            
            Wallet__c portafoglioDiDestinazioneCF = [SELECT Id, Name, PTF_ModelloDiServizio__c,
            PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
            PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,
            PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
            PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c,PTF_StatoAssegnazione__c,
            (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
            FROM Wallet__c WHERE PTF_ModelloDiServizio__c = 'Consulenti Finanziari' AND RecordType.developerName != 'TechnicalWallet' LIMIT 1 ];
			
            portafoglioDiDestinazioneCF.PTF_StatoAssegnazione__c ='Non Assegnato';
            update portafoglioDiDestinazioneCF;
            
            eligible = SpostaNdgIterDataLoader.checkEligibleSuperUser(portafoglioDiDestinazione, currentNDG);
            eligible = SpostaNdgIterDataLoader.checkEligible(portafoglioDiDestinazione, currentNDG, portafoglioDiPartenza);
            eligible = SpostaNdgIterDataLoader.checkEligible(portafoglioDiDestinazioneCF, currentNDG, portafoglioDiDestinazioneCF);
            eligible = SpostaNdgIterDataLoader.checkEligible(portafoglioDiDestinazioneCF, currentNDG, portafoglioDiDestinazione);
            SpostaNdgIterDataLoader.testRun();
            Map<String, SObject> serviceModelMap = SpostaNdgIterDataLoader.servceModelMap;
            Map<String, String> idFittiziaMap = SpostaNdgIterDataLoader.idFittiziaMap;
        }
        Test.stopTest();
        // System.assertEquals(false, eligible);
    }

    
    @isTest
    public static void testConfigMap(){
        SpostaNdgIterDataLoader.currentMDS = 'Key Client Imprese';
        Map<String, ConfigurazioneSpostamenti__mdt> configMap = SpostaNdgIterDataLoader.mdsConfigurazioniMap;
    }
}