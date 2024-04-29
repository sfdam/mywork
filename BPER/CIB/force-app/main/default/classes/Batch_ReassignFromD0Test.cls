@IsTest
public with sharing class Batch_ReassignFromD0Test {
    
    @TestSetup
    public static void setup(){

        // TriggerControl__c tc = new TriggerControl__c();
        // tc.name = 'TEST';
        // insert tc;

        ServiceModel__c privateMMDS = new ServiceModel__c(Name = 'Private',
        PTF_Division__c = 'PR',
        PTF_MacroDivision__c = 'WM');

        ServiceModel__c personalMMDS = new ServiceModel__c(Name = 'Personal',
        PTF_Division__c = 'PE',
        PTF_MacroDivision__c = 'WM');

        ServiceModel__c familyMMDS = new ServiceModel__c(Name = 'Family',
        PTF_Division__c = 'FP',
        PTF_MacroDivision__c = 'EB');
        insert new List<ServiceModel__c>{personalMMDS, familyMMDS, privateMMDS};

        Account banca = AllDataFactory.getAccount('10', 'Banca');
        banca.FinServ__BankNumber__c = '05387';
        banca.PTF_IdCed__c = '0010';
        insert banca;
        Account dir = AllDataFactory.getAccount('09', 'DirezioneRegionale');
        // dir.PTF_ABICED__c = '05387';
        dir.parentId = banca.Id;
        dir.PTF_IdCed__c = '0009';
        insert dir;
        Account area = AllDataFactory.getAccount('08', 'Area');
        // area.PTF_ABICED__c = '05387';
        area.parentId = dir.Id;
        area.PTF_IdCed__c = '0008';
        insert area;

        Account ufficioPrivate = AllDataFactory.getAccount('13', 'FilialeDiRelazione');
        // filiale.PTF_ABICED__c = '05387';
        ufficioPrivate.PTF_BranchTypology__c = 'A';
        ufficioPrivate.PTF_Division__c = 'PR';
        ufficioPrivate.PTF_MacroDivision__c = 'WM';
        ufficioPrivate.PTF_IdCed__c = '0011';
        insert ufficioPrivate;

        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        // filiale.PTF_ABICED__c = '05387';
        filiale.PTF_IdCed__c = '0001';
        filiale.parentId = area.Id;
        filiale.PTF_BranchTypology__c = 'A';
        filiale.PTF_UffPrivate__c = ufficioPrivate.Id;

        Account ufficioPersonal = AllDataFactory.getAccount('11', 'FilialeDiRelazione');
        // filiale.PTF_ABICED__c = '05387';
        ufficioPersonal.parentId = area.Id;
        ufficioPersonal.PTF_IdCed__c = '0012';
        ufficioPersonal.PTF_BranchTypology__c = 'A';
        ufficioPersonal.PTF_Division__c = 'PE';
        ufficioPersonal.PTF_MacroDivision__c = 'WM';
        Account ufficioFamily = AllDataFactory.getAccount('12', 'FilialeDiRelazione');
        // filiale.PTF_ABICED__c = '05387';
        ufficioFamily.parentId = area.Id;
        ufficioFamily.PTF_BranchTypology__c = 'A';
        ufficioFamily.PTF_IdCed__c = '0013';
        ufficioFamily.PTF_Division__c = 'FP';
        ufficioFamily.PTF_MacroDivision__c = 'EB';
        insert new List<Account>{filiale, ufficioPersonal, ufficioFamily};

        Wallet__c microPortafoglioFamily = AllDataFactory.getWallet('MicroWallet',  null, 'Family');
        Wallet__c microPortafoglioPersonal = AllDataFactory.getWallet('MicroWallet',  null, 'Personal');
        Wallet__c microPortafoglioPrivate = AllDataFactory.getWallet('MicroWallet',  null, 'Private');
        insert new List<Wallet__c>{microPortafoglioFamily, microPortafoglioPersonal, microPortafoglioPrivate};
        microPortafoglioFamily.PTF_Filiale__c = filiale.Id;
        microPortafoglioFamily.PTF_Area__c = area.Id;
        microPortafoglioFamily.PTF_DirezioneRegionale__c = dir.id;
        microPortafoglioFamily.PTF_Banca__c = banca.Id;
        microPortafoglioPersonal.PTF_Filiale__c = filiale.Id;
        microPortafoglioPersonal.PTF_Area__c = area.Id;
        microPortafoglioPersonal.PTF_DirezioneRegionale__c = dir.id;
        microPortafoglioPersonal.PTF_Banca__c = banca.Id;
        microPortafoglioPrivate.PTF_Filiale__c = filiale.Id;
        microPortafoglioPrivate.PTF_Area__c = area.Id;
        microPortafoglioPrivate.PTF_DirezioneRegionale__c = dir.id;
        microPortafoglioPrivate.PTF_Banca__c = banca.Id;
        microPortafoglioPrivate.PTF_UffPrivate__c = ufficioPrivate.Id;

        update new List<Wallet__c>{microPortafoglioFamily, microPortafoglioPersonal, microPortafoglioPrivate};

        // Relazione Di Cointestazione
        Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
        personAccount.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        personAccount.PTF_Filiale__c = filiale.Id;

        Account personAccount2 = AllDataFactory.getAccount('02', 'PersonAccount');
        personAccount2.PTF_Portafoglio__c = microPortafoglioPrivate.Id;
        personAccount2.PTF_Filiale__c = filiale.Id;

        insert new List<Account>{personAccount, personAccount2};

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
        User NECT7 = AllDataFactory.getUser('15', profile.Id, 'Private');
        NECA1.FederationIdentifier = '15';
        NECA1.Profilo__c = 'NEC_T.7';
        insert new List<User>{user, NECT4Personal, NECT4Family, NECA1, NECT7, ufficioModelliDistributivi};
        
        Contact contactUffModDis = AllDataFactory.getContact('01', ufficioModelliDistributivi.Id, banca.id);
        contactUffModDis.PTF_Ruolo__c = '100';
        Contact contactNECT4Personal = AllDataFactory.getContact('02', NECT4Personal.Id, ufficioPersonal.id);
        contactNECT4Personal.PTF_Ruolo__c = '100';
        Contact contactNECT4Family = AllDataFactory.getContact('03', NECT4Family.Id, ufficioFamily.id);
        contactNECT4Family.PTF_Ruolo__c = '100';
        Contact contactNECA1 = AllDataFactory.getContact('04', NECA1.Id, area.id);
        contactNECA1.PTF_Ruolo__c = '100';
        Contact contactNECT7 = AllDataFactory.getContact('05', NECT7.Id, ufficioPrivate.id);
        contactNECT7.PTF_Ruolo__c = '100';
        System.runAs(user){
            insert contactUffModDis;
            ConfigurazioneSpostamenti__mdt iter = [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                                PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                                PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                                PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                                ,PTF_SuperUsers__c
                                                FROM ConfigurazioneSpostamenti__mdt
                                                WHERE Tipo_di_Spostamento__c = 'MDS' AND PTF_Abi__c = '05387' AND
                                                PTF_MDS_Start__c = 'Personal' AND PTF_MDS_End__c = 'Family' AND 
                                                PTF_IsActive__c = true];
                                                
                                                Map<String, SObject> ndgIterMap = new Map<String, SObject>{
                                                    personAccount.Id => iter
                                                };
                                                Map<String, String> ndgIterTypeMap = new Map<String, String>{
                                                    personAccount.Id => 'MDS'
            };
            Map<String, String> subjectMap = new Map<String, String>{
                personAccount.Id => iter.MasterLabel
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


            iter = [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                                PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                                PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                                PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                                ,PTF_SuperUsers__c
                                                FROM ConfigurazioneSpostamenti__mdt
                                                WHERE Tipo_di_Spostamento__c = 'MDS' AND PTF_Abi__c = '05387' AND
                                                PTF_MDS_Start__c = 'Private' AND PTF_MDS_End__c = 'Personal' AND 
                                                PTF_IsActive__c = true];
                                                
                                                ndgIterMap = new Map<String, SObject>{
                                                    personAccount2.Id => iter
                                                };
                                                ndgIterTypeMap = new Map<String, String>{
                                                    personAccount2.Id => 'MDS'
            };
            subjectMap = new Map<String, String>{
                personAccount2.Id => iter.MasterLabel
            };
            configurationKeyMap = new Map<String, String>{
                personAccount2.Id => 'Private_Personal'
            };
            req = new RestRequest(); 
            res = new RestResponse();

            Wallet__c portafoglioPrivate = [SELECT Id, Name, PTF_ModelloDiServizio__c, PTF_Pool__c, PTF_UffPrivate__c, PTF_Filiale__r.PTF_UffPrivate__c, PTF_Filiale__r.PTF_IDCEDUffPrivate__c, PTF_Filiale__r.PTF_UffPrivate__r.PTF_IdCedPadre__c,
            PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
            PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,
            PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
            PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c, PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,
            (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
            FROM Wallet__c WHERE Id =: microPortafoglioPrivate.Id LIMIT 1];

            Wallet__c portafoglioPersonal = [SELECT Id, Name, PTF_ModelloDiServizio__c, PTF_Pool__c, PTF_UffPrivate__c, PTF_Filiale__r.PTF_UffPrivate__c, PTF_Filiale__r.PTF_IDCEDUffPrivate__c, PTF_Filiale__r.PTF_UffPrivate__r.PTF_IdCedPadre__c,
            PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
            PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,
            PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
            PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c, PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,
            (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
            FROM Wallet__c WHERE Id =: microPortafoglioPersonal.Id LIMIT 1];
            
            req.requestURI = 'callout:CallMeBack/services/apexrest/createQueues';  
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(JSON.serialize(
            new Map<String,Object>{
                'accountList' => new List<Account>{personAccount2},
                'ndgIterMap' => ndgIterMap,
                'portafoglioDiPartenza' => portafoglioPrivate,
                'portafoglioDiDestinazione' => portafoglioPersonal,
                'process' => ''
            }
            ));
            RestContext.request = req;
            RestContext.response = res;
            
            
            response = (Map<String, Object>)JSON.deserializeUntyped(CreateQueuesController.createQueues());
            System.debug('DK response: ' + JSON.serialize(response));
            accountWorkOrderKeyMap = (Map<String, String>)JSON.deserialize((String)JSON.serialize(response.get('accountWorkOrderKeyMap')), Map<String, String>.class);
            System.debug('DK accountWorkOrderKeyMap: ' + JSON.serialize(accountWorkOrderKeyMap));
            woStepMap = (Map<String, String>)JSON.deserialize((String)JSON.serialize(response.get('woStepMap')), Map<String, String>.class);
            System.debug('DK woStepMap: ' + JSON.serialize(woStepMap));
            // Test.stopTest();
    
            req = new RestRequest(); 
            res = new RestResponse();
    
            // req.requestURI = 'callout:CallMeBack/services/apexrest/createQueues';  
            req.httpMethod = 'PATCH';
            req.requestBody = Blob.valueof(JSON.serialize(
                new Map<String,Object>{
                    'ndgList' => new List<Account>{personAccount2},
                    'ndgIterTypeMap' => ndgIterTypeMap,
                    'portafoglioDestinazione' => microPortafoglioPersonal.Id,
                    'accountKeyMap' => accountWorkOrderKeyMap,
                    'currentNDGId' => personAccount2.Id,
                    'gruppoFinanziarioId' => '',
                    'primari' => new List<String>{personAccount2.id},
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
            insert new List<Contact>{contactNECT4Personal, contactNECT4Family, contactNECA1, contactNECT7};
        }
    }

    @IsTest
    public static void testExecute(){
        Test.startTest();
        Batch_ReassignFromD0 obj = new Batch_ReassignFromD0();
        DataBase.executeBatch(obj); 
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteErr(){
        WorkOrder wo = [SELECT Id, StepsApprovers__c FROM WorkOrder WHERE HasNF__c = true LIMIT 1];
        wo.StepsApprovers__c = 'NEC_F.1), STEP2(NEC_T.4, NEC_T.4), STEP3(NEC_A.1)';
        update wo;
        Test.startTest();
        Batch_ReassignFromD0 obj = new Batch_ReassignFromD0();
        Map<String, String> idCedFittiziaMap = Batch_ReassignFromD0.idCedFittiziaMap;
        idCedFittiziaMap = Batch_ReassignFromD0.idCedFittiziaMap;
        Map<String, String> idFittiziaMap = Batch_ReassignFromD0.idFittiziaMap;
        idFittiziaMap = Batch_ReassignFromD0.idFittiziaMap;
        DataBase.executeBatch(obj); 
        Test.stopTest();
    }
}