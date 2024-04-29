@istest
public with sharing class IterHandlerTest {
    @TestSetup
    static void makeData(){

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
        Wallet__c microPortafoglioPersonal = AllDataFactory.getWallet('MicroWallet',  filiale2.Id, 'Personal');
        insert new List<Wallet__c>{microPortafoglioFamily, microPortafoglioPersonal};

        // Relazione Di Cointestazione
        Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
        personAccount.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        personAccount.PTF_Filiale__c = filiale.Id;

        Account personAccount2 = AllDataFactory.getAccount('02', 'PersonAccount');
        personAccount2.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        personAccount2.PTF_Filiale__c = filiale.Id;

        insert new List<Account>{personAccount, personAccount2};
        
        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];
        
        User user = AllDataFactory.getUser('10', profile.Id, 'Personal');
        user.FederationIdentifier='10';
        user.Profilo__c = 'ADMIN';
        insert new List<User>{user};
        
         WorkOrder wo = new WorkOrder(Status = 'pending', Queues__c = 'STEP1(NEC_F.1), STEP2(NEC_T.4, NEC_T.4), STEP3(NEC_A.1)', OriginalOwner__c = user.Id, PTF_Origine__c = microPortafoglioFamily.Id, PTF_Destinazione__c = microPortafoglioPersonal.Id, Step__c = '1');
         insert wo;
       
        
        Contact contact = AllDataFactory.getContact('02', user.Id, filiale.id);
        System.runAs(user){
            
            insert contact;
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
        }
    }

    @istest
    static void test() {
        User user = [SELECT id FROm user WHERE FederationIdentifier = '10' LIMIT 1];
        WorkOrder wo = [SELECT id FROM WorkOrder LIMIT 1];
        Test.startTest();
        System.runAs(user){

            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = 'callout:CallMeBack/services/apexrest/iterHandler';  
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(JSON.serialize(
                new Map<String,Object>{
                    wo.id => 'Annullato'
                }
            ));

            RestContext.request = req;
            RestContext.response = res;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
            IterHandler.annullater();
        }
        Test.stopTest();
        System.assertEquals(true, (IterHandler.annullater()) != null);
    }

    @istest
    static void testKO() {
        User user = [SELECT id FROm user WHERE FederationIdentifier = '10' LIMIT 1];
        WorkOrder wo = [SELECT id FROm WorkOrder LIMIT 1];
        Test.startTest();
        System.runAs(user){

            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = 'callout:CallMeBack/services/apexrest/iterHandler';  
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(JSON.serialize(
                new Map<String,Object>{
                     wo.id => ''
                }
            ));

            RestContext.request = req;
            RestContext.response = res;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
            try {
                
                IterHandler.annullater();
            } catch (Exception ex) {
                
                System.debug('DK Exception: ' + ex  + '; Stacktrace: ' + ex.getStackTraceString());
            }
        }
        Test.stopTest();
        System.assertEquals(true, (IterHandler.annullater()) !=null);
    }


    @istest
    static void testCloseIter() {
        User user = [SELECT id FROm user WHERE FederationIdentifier = '10' LIMIT 1];
        WorkOrder wo = [SELECT id FROm WorkOrder LIMIT 1];
        Test.startTest();
        System.runAs(user){

            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = 'callout:CallMeBack/services/apexrest/iterHandler';  
            req.httpMethod = 'PATCH';
            req.requestBody = Blob.valueof(JSON.serialize(
                new Map<String,Object>{
                    'recordId' => wo.id,
                    'queueId' => '',
                    'status' => 'Approvato'
                }
            ));

            RestContext.request = req;
            RestContext.response = res;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
            IterHandler.closeIter();
        }
        Test.stopTest();
        System.assertEquals(true, IterHandler.closeIter() !=null);
    }
}