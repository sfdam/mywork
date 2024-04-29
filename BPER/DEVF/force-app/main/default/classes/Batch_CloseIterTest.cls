@isTest
public with sharing class Batch_CloseIterTest {
    
    @TestSetup
    static void makeData(){
        // TriggerControl__c tc = new TriggerControl__c();
        // tc.name = 'TEST';
        // insert tc;

        ServiceModel__c personal = new ServiceModel__c(Name = 'Personal',
        PTF_Division__c = 'PE',
        PTF_MacroDivision__c = 'WM');

        ServiceModel__c family = new ServiceModel__c(Name = 'Family',
        PTF_Division__c = 'FP',
        PTF_MacroDivision__c = 'EB');
        insert new List<ServiceModel__c>{personal, family};

        Account banca = AllDataFactory.getAccount('10', 'Banca');
        banca.FinServ__BankNumber__c = '05387';
        insert banca;
        Account dir = AllDataFactory.getAccount('09', 'DirezioneRegionale');
        // dir.PTF_ABICED__c = '05387';
        dir.parentId = banca.Id;
        insert dir;
        Account area = AllDataFactory.getAccount('08', 'Area');
        // area.PTF_ABICED__c = '05387';
        area.parentId = dir.Id;
        insert area;
        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        // filiale.PTF_ABICED__c = '05387';
        filiale.parentId = area.Id;
        filiale.PTF_BranchTypology__c = 'A';

        Account ufficioPersonal = AllDataFactory.getAccount('11', 'FilialeDiRelazione');
        // filiale.PTF_ABICED__c = '05387';
        ufficioPersonal.parentId = area.Id;
        ufficioPersonal.PTF_BranchTypology__c = 'A';
        ufficioPersonal.PTF_Division__c = 'PE';
        ufficioPersonal.PTF_MacroDivision__c = 'WM';
        Account ufficioFamily = AllDataFactory.getAccount('12', 'FilialeDiRelazione');
        // filiale.PTF_ABICED__c = '05387';
        ufficioFamily.parentId = area.Id;
        ufficioFamily.PTF_BranchTypology__c = 'A';
        ufficioFamily.PTF_Division__c = 'FP';
        ufficioFamily.PTF_MacroDivision__c = 'EB';
        insert new List<Account>{filiale, ufficioPersonal, ufficioFamily};

        Wallet__c microPortafoglioFamily = AllDataFactory.getWallet('MicroWallet',  null, 'Family');
        Wallet__c microPortafoglioPersonal = AllDataFactory.getWallet('MicroWallet',  null, 'Personal');
        insert new List<Wallet__c>{microPortafoglioFamily, microPortafoglioPersonal};
        microPortafoglioFamily.PTF_Filiale__c = filiale.Id;
        microPortafoglioFamily.PTF_Area__c = area.Id;
        microPortafoglioFamily.PTF_DirezioneRegionale__c = dir.id;
        microPortafoglioFamily.PTF_Banca__c = banca.Id;
        microPortafoglioPersonal.PTF_Filiale__c = filiale.Id;
        microPortafoglioPersonal.PTF_Area__c = area.Id;
        microPortafoglioPersonal.PTF_DirezioneRegionale__c = dir.id;
        microPortafoglioPersonal.PTF_Banca__c = banca.Id;

        update new List<Wallet__c>{microPortafoglioFamily, microPortafoglioPersonal};

        // Relazione Di Cointestazione
        Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
        personAccount.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        personAccount.PTF_Filiale__c = filiale.Id;

        Account personAccount2 = AllDataFactory.getAccount('02', 'PersonAccount');
        personAccount2.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        personAccount2.PTF_Filiale__c = filiale.Id;

        Account personAccount3 = AllDataFactory.getAccount('03', 'PersonAccount');
        personAccount3.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        personAccount3.PTF_Filiale__c = filiale.Id;

        Account cointestazione = AllDataFactory.getAccount('04', 'Cointestazione');
        cointestazione.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        cointestazione.PTF_Filiale__c = filiale.Id;

        // Gruppo
        Account gruppo = AllDataFactory.getAccount('05', 'GruppoFinanziario');
        gruppo.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        gruppo.PTF_Filiale__c = filiale.Id;
        gruppo.PTF_NaturaGiuridica__c = 'GF';

        Account business = AllDataFactory.getAccount('06', 'IndustriesBusiness');
        business.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        business.PTF_Filiale__c = filiale.Id;

        Account business2 = AllDataFactory.getAccount('07', 'IndustriesBusiness');
        business2.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        business2.PTF_Filiale__c = filiale.Id;

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

        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];
        
        User user = AllDataFactory.getUser('10', profile.Id, 'Personal');
        user.FederationIdentifier='10';
        User ufficioModelliDistributivi = AllDataFactory.getUser('11', profile.Id, 'Personal');
        ufficioModelliDistributivi.FederationIdentifier = '11';
        ufficioModelliDistributivi.Profilo__c = 'NEC_D.0';

        User NECT4Personal = AllDataFactory.getUser('12', profile.Id, 'Personal');
        NECT4Personal.FederationIdentifier = '12';
        NECT4Personal.Profilo__c = 'NEC_T.4';
        User NECT4Family = AllDataFactory.getUser('13', profile.Id, 'Personal');
        NECT4Family.FederationIdentifier = '13';
        NECT4Family.Profilo__c = 'NEC_T.4';
        User NECA1 = AllDataFactory.getUser('14', profile.Id, 'Personal');
        NECA1.FederationIdentifier = '14';
        NECA1.Profilo__c = 'NEC_A.1';
        insert new List<User>{user, NECT4Personal, NECT4Family, NECA1, ufficioModelliDistributivi};
        
        Contact contactUffModDis = AllDataFactory.getContact('01', ufficioModelliDistributivi.Id, banca.id);
        contactUffModDis.PTF_Ruolo__c = '100';
        Contact contactNECT4Personal = AllDataFactory.getContact('02', NECT4Personal.Id, ufficioPersonal.id);
        contactNECT4Personal.PTF_Ruolo__c = '100';
        Contact contactNECT4Family = AllDataFactory.getContact('03', NECT4Family.Id, ufficioFamily.id);
        contactNECT4Family.PTF_Ruolo__c = '100';
        Contact contactNECA1 = AllDataFactory.getContact('04', NECA1.Id, area.id);
        contactNECA1.PTF_Ruolo__c = '100';
        System.runAs(user){
            insert new List<Contact>{contactUffModDis, contactNECT4Personal, contactNECT4Family, contactNECA1};
    
            ConfigurazioneSpostamenti__mdt iter = [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                                PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                                PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                                PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                                ,PTF_SuperUsers__c
                                                FROM ConfigurazioneSpostamenti__mdt
                                                WHERE Tipo_di_Spostamento__c = 'MDS' AND PTF_Abi__c = '05387' AND
                                                PTF_MDS_Start__c = 'Personal' AND PTF_MDS_End__c = 'Family'];
                                                
                                                Map<String, SObject> ndgIterMap = new Map<String, SObject>{
                                                    personAccount.Id => iter
                                                };
                                                Map<String, String> ndgIterTypeMap = new Map<String, String>{
                                                    personAccount.Id => 'MDS'
            };
            Map<String, String> subjectMap = new Map<String, String>{
                personAccount.Id => 'MDS Personal - Family'
            };
            Map<String, String> configurationKeyMap = new Map<String, String>{
                personAccount.Id => 'Personal_Family'
            };
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = 'callout:CallMeBack/services/apexrest/createQueues';  
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(JSON.serialize(
            new Map<String,Object>{
                'accountList' => new List<Account>{personAccount},
                'ndgIterMap' => ndgIterMap,
                'portafoglioDiPartenza' => microPortafoglioPersonal,
                'portafoglioDiDestinazione' => microPortafoglioFamily,
                'process' => ''
            }
            ));
            RestContext.request = req;
            RestContext.response = res;
            
            
            Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(CreateQueuesController.createQueues());
            System.debug('DK response: ' + JSON.serialize(response));
            Map<String, String> accountWorkOrderKeyMap = (Map<String, String>)JSON.deserialize((String)JSON.serialize(response.get('accountWorkOrderKeyMap')), Map<String, String>.class);
            System.debug('DK accountWorkOrderKeyMap: ' + JSON.serialize(accountWorkOrderKeyMap));
            Map<String, String> woStepMap = (Map<String, String>)JSON.deserialize((String)JSON.serialize(response.get('woStepMap')), Map<String, String>.class);
            System.debug('DK woStepMap: ' + JSON.serialize(woStepMap));
            // Test.stopTest();
    
            req = new RestRequest(); 
            res = new RestResponse();
    
            // req.requestURI = 'callout:CallMeBack/services/apexrest/createQueues';  
            req.httpMethod = 'PATCH';
            req.requestBody = Blob.valueof(JSON.serialize(
                new Map<String,Object>{
                    'ndgList' => new List<Account>{personAccount},
                    'ndgIterTypeMap' => ndgIterTypeMap,
                    'portafoglioDestinazione' => microPortafoglioFamily.Id,
                    'accountKeyMap' => accountWorkOrderKeyMap,
                    'currentNDGId' => personAccount.Id,
                    'gruppoFinanziarioId' => '',
                    'primari' => new List<String>{personAccount.id},
                    'woStepMap' => woStepMap,
                    'ownerId' => UserInfo.getuserId(),
                    'configurationKeyMap' => configurationKeyMap,
                    'subjectMap' => subjectMap,
                    'note' => 'TEST',
                    'process' => '',
                    'motivazione' => '',
                    'lineItemIter' => true
                }
            ));
    
            RestContext.request = req;
            RestContext.response = res;
            CreateQueuesController.sendMovementsRequest();

            IterConfiguration__c iterConfig = new IterConfiguration__c(
                UnitaOrganizzativa__c = filiale.Id,
                TipoSpostamento__c = 'MDS',
                GiorniAnnullamento__c = -1
            );
            insert iterConfig;
        }
    }

    @isTest
    public static void testBatch(){
        Test.startTest();
        Batch_CloseIter batch = new Batch_CloseIter();
        Id batchJobId = Database.executeBatch(batch, 50);
        Test.stopTest();
    }
}