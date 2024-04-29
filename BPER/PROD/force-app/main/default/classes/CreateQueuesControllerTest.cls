@isTest
public class CreateQueuesControllerTest {

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

        Account ufficioPersonal = AllDataFactory.getAccount('110', 'AltraUnitaOrganizzativa');
        // filiale.PTF_ABICED__c = '05387';
        ufficioPersonal.parentId = area.Id;
        ufficioPersonal.PTF_BranchTypology__c = 'A';
        ufficioPersonal.PTF_Division__c = 'PE';
        ufficioPersonal.PTF_MacroDivision__c = 'WM';
        ufficioPersonal.PTF_IdCed__c = '7894';
        Account ufficioFamily = AllDataFactory.getAccount('111', 'AltraUnitaOrganizzativa');
        // filiale.PTF_ABICED__c = '05387';
        ufficioFamily.parentId = area.Id;
        ufficioFamily.PTF_BranchTypology__c = 'A';
        ufficioFamily.PTF_Division__c = 'FP';
        ufficioFamily.PTF_MacroDivision__c = 'EB';
        ufficioFamily.PTF_IdCed__c = '5612';
        insert new List<Account>{filiale, filiale2, ufficioPersonal, ufficioFamily};

        Wallet__c microPortafoglioFamily = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Family');
        Wallet__c microPortafoglioFamily2 = AllDataFactory.getWallet('MicroWallet',  filiale2.Id, 'Family');
        Wallet__c microPortafoglioPersonal = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Personal');
        Wallet__c microPortafoglioPersonal2 = AllDataFactory.getWallet('MicroWallet',  filiale2.Id, 'Personal');
        insert new List<Wallet__c>{microPortafoglioFamily, microPortafoglioPersonal, microPortafoglioFamily2, microPortafoglioPersonal2};

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

        Account cointestazione = AllDataFactory.getAccount('04', 'Cointestazione');
        cointestazione.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        cointestazione.PTF_Filiale__c = filiale.Id;

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

        insert new List<Account>{personAccount, personAccount2, personAccount3, cointestazione, gruppo, business, business2};

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
        insert new List<CRM_LinkedNDG__c>{capoGruppo, membroGruppo};

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

        Map<String, SObject> profileMap = SV_Utilities.keyBy([SELECT id, Name FROM Profile], 'Name');
        
        User user = AllDataFactory.getUser('10', profileMap.get(Label.System_Administrator).Id, 'Personal');
        user.FederationIdentifier='10';
        user.Profilo__c = 'ADMIN';
        user.abi__c='05387';
        user.idced__c='5385'; 
        user.Email='useraskdasgdhgas@bper.it';
        User ufficioModelliDistributivi = AllDataFactory.getUser('11', profileMap.get('NEC_D.0').Id, 'Personal');
        ufficioModelliDistributivi.FederationIdentifier = '11';
        ufficioModelliDistributivi.Profilo__c = 'NEC_D.0';
        ufficioModelliDistributivi.abi__c='05387';
        ufficioModelliDistributivi.idced__c='5385'; 
        ufficioModelliDistributivi.Email='ufficioModelliDistributivis@bper.it';
        
        User NECF1 = AllDataFactory.getUser('14', profileMap.get('NEC_F.1').Id, 'Family');
        NECF1.FederationIdentifier = '14';
        NECF1.Profilo__c = 'NEC_F.1';
        NECF1.abi__c='05387';
        NECF1.idced__c='5385'; 
        NECF1.Email='NECF1askdasgdhgas@bper.it';

        User NECA1 = AllDataFactory.getUser('15', profileMap.get('NEC_A.1').Id, 'Family');
        NECA1.FederationIdentifier = '15';
        NECA1.Profilo__c = 'NEC_A.1';
        NECA1.abi__c='05387';
        NECA1.idced__c='8553';
		NECA1.Email='NECA11askdasgdhgas@bper.it';
        
        User NECT4Family = AllDataFactory.getUser('16', profileMap.get('NEC_T.4').Id, 'Family');
        NECT4Family.FederationIdentifier = '16';
        NECT4Family.Profilo__c = 'NEC_T.4';
        NECT4Family.abi__c='05387';
        NECT4Family.idced__c='5612';
		NECT4Family.Email='NECT4Familygdhgas@bper.it';
        
        User NECT4Personal = AllDataFactory.getUser('17', profileMap.get('NEC_T.4').Id, 'Personal');
        NECT4Personal.FederationIdentifier = '17';
        NECT4Personal.Profilo__c = 'NEC_T.4';
        NECT4Personal.abi__c='05387';
        NECT4Personal.idced__c='7894'; 
        NECT4Personal.Email='NECT4Personalgdhgas@bper.it';
        
        insert new List<User>{user, ufficioModelliDistributivi, NECF1, NECA1, NECT4Family};
        

            
        System.runAs(user){

            Contact contactUfficioModelliDistributivi = AllDataFactory.getContact('01', ufficioModelliDistributivi.Id, banca.id);
            Contact contactNECF1 = AllDataFactory.getContact('02', NECF1.Id, filiale.id);
            Contact contactNECA1 = AllDataFactory.getContact('03', NECA1.Id, area.id);
            Contact contactNECT4Family = AllDataFactory.getContact('04', NECT4Family.Id, ufficioFamily.id);
            Contact contactNECT4Personal = AllDataFactory.getContact('05', NECT4Personal.Id, ufficioPersonal.id);
            insert new List<Contact>{contactUfficioModelliDistributivi, contactNECF1, contactNECA1, contactNECT4Family, contactNECT4Personal};
        }
    }

    static testMethod void testDoPost(){
        
        Test.startTest();
        Account account = [SELECT id, PTF_Portafoglio__c FROM Account WHERE LastName = 'LastName01' LIMIT 1];
        Map<String,Object> initResponse = SpostaNdgIterController.init(account.Id);
        Wallet__c portafoglioDiPartenza = (Wallet__c) JSON.deserialize(JSON.serialize(initResponse.get('currentPF')), Wallet__c.class);
        ConfigurazioneSpostamenti__mdt iter = [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                            PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                            PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                            PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                            ,PTF_SuperUsers__c
                                            FROM ConfigurazioneSpostamenti__mdt
                                            WHERE Tipo_di_Spostamento__c = 'MDS' AND PTF_Abi__c = '05387' AND
                                            PTF_MDS_Start__c = 'Personal' AND PTF_MDS_End__c = 'Family' limit 1];
        Account currentNDG = (Account) JSON.deserialize(JSON.serialize(initResponse.get('currentNDG')), Account.class);
        Map<String,Object> loadMwListResponse = SpostaNdgIterDataLoader.loadMwList(new list<String>{'Family'}, new list<String>{'Autonoma'}, 5, currentNDG, portafoglioDiPartenza, 'primario', false, '', '', new List<String>(), new List<Assignment__c>());
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
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = 'callout:CallMeBack/services/apexrest/createQueues';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSON.serialize(
            new Map<String,Object>{
                'accountList' => new List<Account>{account},
                'ndgIterMap' => ndgIterMap,
                'portafoglioDiPartenza' => portafoglioDiPartenza,
                'portafoglioDiDestinazione' => portafoglioDiDestinazione,
                'process' => ''
            }
        ));
        RestContext.request = req;
        RestContext.response = res;
        
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(CreateQueuesController.createQueues());
        Test.stopTest();
    }

    static testMethod void testDoPatch(){

        Test.startTest();
        Account account = [SELECT id, PTF_Portafoglio__c FROM Account WHERE name = 'Account06' LIMIT 1];
        Map<String,Object> initResponse = SpostaNdgIterController.init(account.Id);
        String gruppoFinanziarioId = (String)initResponse.get('gruppoFinanziarioId');
        Wallet__c portafoglioDiPartenza = (Wallet__c) JSON.deserialize(JSON.serialize(initResponse.get('currentPF')), Wallet__c.class);
        ConfigurazioneSpostamenti__mdt iter = [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                            PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                            PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                            PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                            ,PTF_SuperUsers__c
                                            FROM ConfigurazioneSpostamenti__mdt
                                            WHERE Tipo_di_Spostamento__c = 'MDS' AND PTF_Abi__c = '05387' AND
                                            PTF_MDS_Start__c = 'Personal' AND PTF_MDS_End__c = 'Family' limit 1];
        // List<Wallet__c> portafogliEligible = (List<Wallet__c>) JSON.deserialize(JSON.serialize(loadMwListResponse.get('mwList')), List<Wallet__c>.class);
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

        // User approver = [SELECT id FROM User WHERE Email = 'test10@test.com' LIMIT 1];
        String workOrderKey = SV_Utilities.generateRandomString(24);
        // String queueName = 'Q_' + workOrderKey + '_false_1_1';
        // Group queue = new Group();
        // queue.Name = 'Approvers Step 1 Queue 1';
        // queue.DeveloperName = queueName;
        // queue.Type = 'Queue';
        // insert queue;
        // GroupMember member = new GroupMember();
        // member.GroupId = queue.Id;
        // member.UserOrGroupId = approver.Id;
        // insert member;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = 'callout:CallMeBack/services/apexrest/createQueues';  
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(JSON.serialize(
            new Map<String,Object>{
                'ndgList' => new List<Account>{account},
                'ndgIterTypeMap' => ndgIterTypeMap,
                'portafoglioDiDestinazione' => portafoglioDiDestinazione.Id,
                'accountKeyMap' => new Map<String, String>{account.Id => workOrderKey},
                'ownerId' => UserInfo.getuserId(),
                'currentNDGId' => account.Id,
                'gruppoFinanziarioId' => gruppoFinanziarioId,
                'primari' => new List<String>{account.id},
                'woStepMap' => new Map<String, String>{workOrderKey => 'STEP1 (NEC_D.4)'},
                'configurationKeyMap' => configurationKeyMap,
                'subjectMap' => subjectMap,
                'note' => 'TEST'
            }
        ));

        RestContext.request = req;
        RestContext.response = res;
        CreateQueuesController.sendMovementsRequest();
        Test.stopTest();
    }
    
    
    static testMethod void testDoPost1(){
        
        Test.startTest();
         Account account = [SELECT id, PTF_Portafoglio__c FROM Account WHERE name = 'Account06' LIMIT 1];
        Map<String,Object> initResponse = SpostaNdgIterController.init(account.Id);
        Wallet__c portafoglioDiPartenza = (Wallet__c) JSON.deserialize(JSON.serialize(initResponse.get('currentPF')), Wallet__c.class);
        ConfigurazioneSpostamenti__mdt iter = [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                            PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                            PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                            PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                            ,PTF_SuperUsers__c
                                            FROM ConfigurazioneSpostamenti__mdt
                                            WHERE Tipo_di_Spostamento__c = 'MDS' AND PTF_Abi__c = '05387' AND
                                            PTF_MDS_Start__c = 'Personal' AND PTF_MDS_End__c = 'Family' limit 1 ];
        Account currentNDG = (Account) JSON.deserialize(JSON.serialize(initResponse.get('currentNDG')), Account.class);
        Map<String,Object> loadMwListResponse = SpostaNdgIterDataLoader.loadMwList(new list<String>{'Family'}, new list<String>{'Autonoma'}, 5, currentNDG, portafoglioDiPartenza, 'primario', false, '', '', new List<String>(), new List<Assignment__c>());
        List<Wallet__c> portafogliEligible = (List<Wallet__c>) JSON.deserialize(JSON.serialize(loadMwListResponse.get('mwList')), List<Wallet__c>.class);
        Wallet__c portafoglioDiDestinazione = [SELECT Id, Name, PTF_ModelloDiServizio__c,
        PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
        PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,
        PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
        PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c,
        (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
        FROM Wallet__c WHERE PTF_ModelloDiServizio__c = 'Family' AND RecordType.developerName != 'TechnicalWallet' LIMIT 1 ];
        ServiceModel__c sm=new ServiceModel__c();
        insert sm;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = 'callout:CallMeBack/services/apexrest/createQueues';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSON.serialize(
            new Map<String,Object>{
                'accountList' => new List<Account>{account},
                'portafoglioDiPartenza' => portafoglioDiPartenza,
                'portafoglioDiDestinazione' => portafoglioDiDestinazione,
                'process' => ''
             
            }
        ));
        RestContext.request = req;
        RestContext.response = res;
        
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(CreateQueuesController.createQueues());
        Test.stopTest();
    }    
 
   @isTest
    public static void testRunMethod() {
        CreateQueuesController.testRun();
    }
}