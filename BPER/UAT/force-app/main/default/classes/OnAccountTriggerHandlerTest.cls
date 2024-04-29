@isTest
public with sharing class OnAccountTriggerHandlerTest {

    @TestSetup
    static void testOnInsert(){

        Funzionalita__c x = new Funzionalita__c();
        x.Disable_ProcessBuilder__c =true;
        x.Disable_Flow__c=true; 
        insert x;
        Endpoint__c endpoint2 = new Endpoint__c();
        endpoint2.Name = 'aggiornaFilialeDiRelazione';
        endpoint2.Method__c = 'PATCH';
        endpoint2.Timeout__c = 120000;
        endpoint2.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/AnagrafeClientiAPI/v4/anagrafica/aggiorna-filiale/bancaSett/{bancaSett}/codiceNDG/{codiceNDG}/filialePrincipale/{filialePrincipale}';
        insert endpoint2;
        
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
        Account filiale2 = AllDataFactory.getAccount('02', 'FilialeDiRelazione');
        filiale2.FinServ__BankNumber__c = '05387';
        filiale2.parentId = area.Id;
        filiale2.PTF_BranchTypology__c = 'A';
        filiale2.PTF_Banca__c = banca.Id;
        filiale2.PTF_DirezioneRegionale__c = dir.Id;
        filiale2.PTF_Area__c = area.Id;
        insert new List<Account>{filiale, filiale2};

        Wallet__c microPortafoglioFamily = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Family');
        Wallet__c microPortafoglioPersonal = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Personal');
        Wallet__c portafoglioTecnico = AllDataFactory.getWallet('TechnicalWallet',  filiale.Id, 'Private');
        Wallet__c microPortafoglioFamily2 = AllDataFactory.getWallet('MicroWallet',  filiale2.Id, 'Family');
        insert new List<Wallet__c>{microPortafoglioFamily, microPortafoglioFamily2, portafoglioTecnico, microPortafoglioPersonal};

        RoleTypology__c ruolo = new RoleTypology__c();
        ruolo.Name = 'Titolare';
        insert ruolo;

        ServiceModel__c modelloDiServizio = new ServiceModel__c();
        modelloDiServizio.Name = 'Personal';
        insert modelloDiServizio;

        RoleMDS__c ruoloMDS = new RoleMDS__c();
        ruoloMDS.PTF_BranchTypology__c = 'A';
        ruoloMDS.PTF_RoleTypology__c = ruolo.Id;
        ruoloMDS.PTF_ServiceModel__c = modelloDiServizio.Id;
        ruoloMDS.PTF_StartDate__c = Date.today().addDays(-10);
        ruoloMDS.PTF_EndDate__c = Date.today().addDays(10);
        insert ruoloMDS;
        
        Contact contact = AllDataFactory.getContact('01', UserInfo.getUserId(), filiale.Id);
        contact.PTF_TipologiaRuolo__c = ruolo.Id;
        insert contact;

        // Relazione Di Cointestazione
        Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
        personAccount.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        personAccount.PTF_Filiale__c = filiale.Id;
        personAccount.PTF_StatoCRM__c = 'ATT';
        personAccount.PTF_Banca__c = banca.Id;
        insert personAccount;

        // Relazione Di Cointestazione
        Account personAccount2 = AllDataFactory.getAccount('02', 'PersonAccount');
        personAccount2.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        personAccount2.PTF_Filiale__c = filiale.Id;
        personAccount2.PTF_StatoCRM__c = 'ATT';
        personAccount2.ModelloDiServizio__c = 'Private';
        personAccount2.PTF_Banca__c = banca.Id;
        insert personAccount2;

        // Relazione Di Cointestazione
        Account personAccount3 = AllDataFactory.getAccount('03', 'PersonAccount');
        personAccount3.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        personAccount3.PTF_Filiale__c = filiale.Id;
        personAccount3.PTF_StatoCRM__c = 'ATT';
        personAccount3.ModelloDiServizio__c = 'Family';
        personAccount3.PTF_Banca__c = banca.Id;
        insert personAccount3;

        Account personAccount4 = AllDataFactory.getAccount('04', 'PersonAccount');
        personAccount4.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        personAccount4.PTF_Filiale__c = filiale.Id;
        personAccount4.PTF_StatoCRM__c = 'ATT';
        personAccount4.ModelloDiServizio__c = 'Family';
        personAccount4.PTF_StatoSofferenza__c=true;
        personAccount4.PTF_StatoAnagrafe__c='E';
        personAccount4.PTF_Banca__c = banca.Id;
        insert personAccount4;

        Account account = [SELECT id, PTF_Portafoglio__c FROM Account WHERE LastName = 'LastName01' LIMIT 1];
        account.PTF_Banca__c = banca.Id;
        update account;
        Account account2 = [SELECT id, PTF_Portafoglio__c FROM Account WHERE LastName = 'LastName01' LIMIT 1];
        Map<String,Object> initResponse = SpostaNdgIterController.init(account2.Id);
        Wallet__c portafoglioDiPartenza = (Wallet__c) JSON.deserialize(JSON.serialize(initResponse.get('currentPF')), Wallet__c.class);
        Account currentNDG = (Account) JSON.deserialize(JSON.serialize(initResponse.get('currentNDG')), Account.class);
        Map<String,Object> loadMwListResponse = SpostaNdgIterDataLoader.loadMwList(new list<String>{'Family'}, new list<String>{'Autonoma'}, 5, currentNDG, portafoglioDiPartenza, 'primario', false, '', '', new List<String>(), new List<Assignment__c>());
        List<Wallet__c> portafogliEligible = (List<Wallet__c>) JSON.deserialize(JSON.serialize(loadMwListResponse.get('mwList')), List<Wallet__c>.class);
        Map<String, String> subjectMap = new Map<String, String>{
            account.Id => 'MDS Personal - Family'
        };
        Map<String, String> configurationKeyMap = new Map<String, String>{
            account.Id => 'Personal_Family'
        };
        //SpostaNdgIterController.sendMovementRequest(portafogliEligible[0].Id, new List<Account> {account}, subjectMap, 'Note', configurationKeyMap, new List<String>{account.Id});
    }

    /*@isTest
    static void testMoveAccount(){

        WorkOrder workOrder = [SELECT id, Status, Step__c, PTF_MDS_Origine__c, PTF_MDS_Destinazione__c, PTF_Branch_Origine__c, PTF_Branch_Destinazione__c, 
            PTF_MicroMercato_Origine__c, PTF_Area_Origine__c, PTF_DirezioneRegionale_Origine__c, 
            PTF_MicroMercato_Destinazione__c, PTF_Area_Destinazione__c, PTF_DirezioneRegionale_Destinazione__c 
            FROM WorkOrder LIMIT 1];
        Map<String,  Map<String, Boolean>> workOrderApproversMap = OnWorkOrderTriggerHandler.getApprovers(new List<WorkOrder>{workOrder});
        List<Approval.ProcessWorkitemRequest> pwirList = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem p: [SELECT Id, ProcessInstance.TargetObjectId
                                        FROM ProcessInstanceWorkitem 
                                        WHERE ProcessInstance.Status='Pending' AND ProcessInstance.TargetObjectId =: workOrder.Id]){
            Approval.ProcessWorkitemRequest result = new Approval.ProcessWorkitemRequest();
            
            result.setAction('Approve');           
            result.setWorkitemId(p.Id);
            pwirList.add(result);
        }
        System.debug('DK pwirList: ' + JSON.serialize(pwirList));
        List<String> userIdList = new List<String>(); 
        for(Id approverId : workOrderApproversMap.values()[0].keySet()){

            if(approverId.getSobjectType().getDescribe().getName() == 'User'){

                userIdList.add(approverId);
            }else{

                Map<String, SObject> groupMemberMap = SV_Utilities.keyBy([SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId =: approverId], 'UserOrGroupId');
                userIdList.add(new List<String>(groupMemberMap.keySet())[0]);
            }
        }
        List<User> users = [SELECT id, Name FROM User WHERE Id IN: userIdList];
        System.debug('DK users: ' + JSON.serialize(users));
        System.runAs(users[0]){
            try{

                Approval.process(new List<Approval.ProcessWorkitemRequest>{pwirList[0]});
            }catch(Exception ex){

                Approval.process(new List<Approval.ProcessWorkitemRequest>{pwirList[1]});
            }
        }
        Test.startTest();
        System.runAs(users[1]){

            try{

                Approval.process(new List<Approval.ProcessWorkitemRequest>{pwirList[0]});
            }catch(Exception ex){

                Approval.process(new List<Approval.ProcessWorkitemRequest>{pwirList[1]});
            }
        }
        Test.stopTest();
    }*/

    @isTest
    static void testMoveAccount2(){
        Test.startTest();
        Account personAccount = [SELECT id, PTF_Portafoglio__c, PTF_Filiale__c, PTF_Portafoglio__r.PTF_Filiale__c FROM Account WHERE LastName = 'LastName02'];
        Wallet__c portafoglio = [SELECT id, PTF_Filiale__c FROM Wallet__c WHERE Id !=: personAccount.PTF_Portafoglio__c AND PTF_Filiale__c !=: personAccount.PTF_Filiale__c][0];
        personAccount.PTF_Accordato__c=1000;
        personAccount.PTF_Utilizzato__c=1000;
        personAccount.PTF_Patrimonio__c=1000;
        personAccount.PTF_StatoCRM__c='ATT';
        personAccount.PTF_Portafoglio__c = portafoglio.Id;
        personAccount.PTF_Filiale__c = portafoglio.PTF_Filiale__c;
        update personAccount;
        Test.stopTest();
    }

    @isTest
    static void testSetTechnicalWallet(){
        Test.startTest();
        Account filiale = [SELECT id, PTF_Portafoglio__c, PTF_Portafoglio__r.PTF_Filiale__c FROM Account WHERE Name = 'Account01'];
        // Relazione Di Cointestazione
        Account personAccount = AllDataFactory.getAccount('02', 'PersonAccount');
        personAccount.ModelloDiServizioCaricamento__c = 'Private';
        personAccount.PTF_Filiale__c = filiale.Id;
        personAccount.PTF_StatoCRM__c = 'ATT';
        insert personAccount;
        Test.stopTest();
        
    }
    
    @isTest
    static void tetsChangeFiliale(){
        Test.startTest();
        Account personAccount = [SELECT id FROM Account WHERE LastName = 'LastName02'];
        Account filiale= [SELECT id FROM Account WHERE Name = 'Account02'];
        personAccount.PTF_Filiale__c=filiale.Id;

        Contact contact = AllDataFactory.getContact('01', UserInfo.getUserId(), filiale.Id);
        
        insert contact;

        update personAccount;
        Test.stopTest();
    }
    @isTest
    static void tetsChangeModelloServizio(){
        Test.startTest();
        Account personAccount = [SELECT id FROM Account WHERE LastName = 'LastName03'];
        personAccount.ModelloDiServizio__c='Private';

        update personAccount;
        Test.stopTest();
    }

    @isTest
    static void testSetResiduale(){
        Test.startTest();
        List<Account> personAccount = [SELECT id,ModelloDiServizio__c,PTF_StatoSofferenza__c,PTF_StatoAnagrafe__c,PTF_Filiale__c
                                                 FROM Account WHERE LastName = 'LastName04'];
        List<Account> filiale = [SELECT id, RecordTypeId,PTF_Capofila__c,PTF_Area__c,PTF_DirezioneRegionale__c,PTF_Banca__c
                                                FROM Account WHERE Name = 'Account02'];
        Account filiale2 = [SELECT id, RecordTypeId,PTF_Capofila__c,PTF_Area__c,PTF_DirezioneRegionale__c,PTF_Banca__c
                                                FROM Account WHERE Name = 'Account02'];
        Map<Id,Account> mappaAcc= new Map<Id,Account>();
        mappaAcc.put(filiale2.id,filiale2);
        OnAccountTriggerHandler.setResiduale(personAccount,mappaAcc);
        OnAccountTriggerHandler.changeStruttura(filiale,mappaAcc);

        Test.stopTest();
    }

   

    //GPF S:43039 - Sportelli Leggeri
    /*
    @isTest
    static void testresetMiniWalletLookup(){
        Test.startTest();
        Account filiale = new Account();
        filiale.FirstName = 'filialeTest';
        filiale.LastName = 'filialeTest';
        insert filiale;
        
        Wallet__c w = new Wallet__c();
        w.PTF_Filiale__c = filiale.Id;
        w.PTF_ModelloDiServizio__c = 'Personal';
        insert w;
        
        Account a = new Account();
        a.FirstName = 'Test43039';
        a.LastName = 'Test43039';
        a.PTF_Portafoglio__c = w.id;
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'Test43039';
        c.LastName = 'Test43039';
        insert c;

        MiniWallet__c mw = new MiniWallet__c();
        mw.Name = 'Test43039';
        mw.PTF_Portafoglio__c = w.Id;
        mw.Referente__c = c.Id;
        mw.PTF_SL__c = a.Id;
        insert mw;

        a.PTF_MiniPortafoglio__c = mw.Id;
        update a;

        Wallet__c nw = new Wallet__c();
        nw.PTF_Filiale__c = a.Id;
        nw.PTF_ModelloDiServizio__c = 'Personal';
        insert nw;

        a.PTF_Portafoglio__c = nw.Id;
        update a;

        List<Account> personAccount = [SELECT id,PTF_MiniPortafoglio__c FROM Account WHERE FirstName = 'Test43039' LIMIT 1];
        //System.debug('ID: '+ personAccount.Id +' LookUP Dopo Update: '+personAccount.PTF_MiniPortafoglio__c);
        System.assertEquals(personAccount[0].PTF_MiniPortafoglio__c,null);
        Test.stopTest();
    }*/
    //GPF E:43039 - Sportelli Leggeri

}