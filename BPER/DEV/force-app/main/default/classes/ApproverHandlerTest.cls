@IsTest
public with sharing class ApproverHandlerTest {
    @TestSetup
    public static void setup(){

        User user = AllDataFactory.getUser ('User','00e3X000002TZ01QAG','Enti e Tesorerie');
        insert user;
        
        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        insert filiale;

        Wallet__c microPortafoglioFamily = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Family');
        Wallet__c microPortafoglioPersonal = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Personal');
        insert new List<Wallet__c>{microPortafoglioFamily, microPortafoglioPersonal};

        // Relazione Di Cointestazione
        Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
        personAccount.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        personAccount.PTF_Filiale__c = filiale.Id;
        insert personAccount; 
        
        WorkOrder workOrder = new WorkOrder();
        insert workOrder;

    }

    @IsTest
    public static void testGetAllProcessInstancesMap(){

        Test.startTest();
        Account account = [SELECT id, PTF_Portafoglio__c FROM Account WHERE LastName = 'LastName01' LIMIT 1];
        // Map<String,Object> initResponse = SpostaNdgIterController.init(account.Id);
        Wallet__c portafoglioDiPartenza = [SELECT Id, Name, PTF_ModelloDiServizio__c,
        PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
        PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,
        PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
        PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c, PTF_Pool__c, PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,
        (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
        FROM Wallet__c WHERE Id =: account.PTF_Portafoglio__c AND RecordType.developerName != 'TechnicalWallet'];
        ConfigurazioneSpostamenti__mdt iter = [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                            PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                            PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                            PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                            ,PTF_SuperUsers__c
                                            FROM ConfigurazioneSpostamenti__mdt
                                            WHERE Tipo_di_Spostamento__c = 'MDS' AND PTF_Abi__c = '05387' AND
                                            PTF_MDS_Start__c = 'Personal' AND PTF_MDS_End__c = 'Family'];
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
        WorkOrder workOrder = [SELECT id, Status, Step__c, PTF_MDS_Origine__c, PTF_MDS_Destinazione__c, PTF_Branch_Origine__c, PTF_Branch_Destinazione__c, 
            PTF_MicroMercato_Origine__c, PTF_Area_Origine__c, PTF_DirezioneRegionale_Origine__c, 
            PTF_MicroMercato_Destinazione__c, PTF_Area_Destinazione__c, PTF_DirezioneRegionale_Destinazione__c 
            FROM WorkOrder LIMIT 1];
        Map<String, List<ProcessInstance>> response = ApproverHandler.getAllProcessInstancesMap(new List<Id>{workOrder.Id});
        System.assertEquals(true, response.size()>0);
    }
}