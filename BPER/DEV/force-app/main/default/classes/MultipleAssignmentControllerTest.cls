/**
* Controller of multipleAssignement LWC
*
* @author  Dam Kebe @Lutech
* @version 1.0
* @since   2020-07-27
*/
@isTest
public without sharing class MultipleAssignmentControllerTest {
    
    @TestSetup
    public static void setup(){
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

        Wallet__c portafoglioTecnico = AllDataFactory.getWallet('TechnicalWallet', filiale.Id, 'Personal');
        Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Personal');
        Wallet__c portafoglioAssente = AllDataFactory.getWallet('Assente',  filiale.Id, 'Assente');
        insert new List<Wallet__c>{portafoglioTecnico, microPortafoglio, portafoglioAssente};

        Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
        personAccount.PTF_NaturaGiuridica__c = 'PF';
        personAccount.PTF_Portafoglio__c = portafoglioTecnico.Id;
        personAccount.PTF_Filiale__c = filiale.Id;

        Account personAccount2 = AllDataFactory.getAccount('02', 'PersonAccount');
        personAccount2.PTF_NaturaGiuridica__c = 'PF';
        personAccount2.PTF_Portafoglio__c = portafoglioAssente.Id;
        personAccount2.PTF_Filiale__c = filiale.Id;

        Account personAccount3 = AllDataFactory.getAccount('03', 'PersonAccount');
        personAccount3.PTF_NaturaGiuridica__c = 'PF';
        personAccount3.PTF_Portafoglio__c = microPortafoglio.Id;
        personAccount3.PTF_Filiale__c = filiale.Id;

        Account personAccount4 = AllDataFactory.getAccount('06', 'PersonAccount');
        personAccount4.PTF_NaturaGiuridica__c = 'PF';
        personAccount4.PTF_Portafoglio__c = microPortafoglio.Id;
        personAccount4.PTF_Filiale__c = filiale.Id;

        Account cointestazione = AllDataFactory.getAccount('04', 'Cointestazione');
        cointestazione.PTF_NaturaGiuridica__c = 'CO';
        cointestazione.PTF_Portafoglio__c = microPortafoglio.Id;
        cointestazione.PTF_Filiale__c = filiale.Id;

        Account cointestazione2 = AllDataFactory.getAccount('05', 'Cointestazione');
        cointestazione2.PTF_NaturaGiuridica__c = 'CO';
        cointestazione2.PTF_Portafoglio__c = portafoglioAssente.Id;
        cointestazione2.PTF_Filiale__c = filiale.Id;

        Account cointestazione3 = AllDataFactory.getAccount('06', 'Cointestazione');
        cointestazione3.PTF_Portafoglio__c = portafoglioAssente.Id;
        cointestazione3.PTF_Filiale__c = filiale.Id;
        cointestazione3.PTF_NaturaGiuridica__c='CO';
        
        insert new List<Account>{personAccount, personAccount2, personAccount3, personAccount4, cointestazione, cointestazione2,cointestazione3};

        CRM_AccountAccountJointOwnershipRelation__c relazioneDiCointestazionePrimario = new CRM_AccountAccountJointOwnershipRelation__c();
        relazioneDiCointestazionePrimario.CRM_PrimaryNDG__c = true;
        relazioneDiCointestazionePrimario.CRM_Account__c = personAccount2.Id;
        relazioneDiCointestazionePrimario.CRM_JointOwnership__c = cointestazione.Id;
        relazioneDiCointestazionePrimario.CRM_Active__c=true;

        CRM_AccountAccountJointOwnershipRelation__c relazioneDiCointestazioneCointestatario = new CRM_AccountAccountJointOwnershipRelation__c();
        relazioneDiCointestazioneCointestatario.CRM_PrimaryNDG__c = false;
        relazioneDiCointestazioneCointestatario.CRM_Account__c = personAccount3.Id;
        relazioneDiCointestazioneCointestatario.CRM_JointOwnership__c = cointestazione.Id;
        relazioneDiCointestazioneCointestatario.CRM_Active__c=true;

        CRM_AccountAccountJointOwnershipRelation__c relazioneDiCointestazionePrimario2 = new CRM_AccountAccountJointOwnershipRelation__c();
        relazioneDiCointestazionePrimario2.CRM_PrimaryNDG__c = true;
        relazioneDiCointestazionePrimario2.CRM_Account__c = personAccount2.Id;
        relazioneDiCointestazionePrimario2.CRM_JointOwnership__c = cointestazione2.Id;
        relazioneDiCointestazionePrimario2.CRM_Active__c=true;

        CRM_AccountAccountJointOwnershipRelation__c relazioneDiCointestazioneCointestatario2 = new CRM_AccountAccountJointOwnershipRelation__c();
        relazioneDiCointestazioneCointestatario2.CRM_PrimaryNDG__c = false;
        relazioneDiCointestazioneCointestatario2.CRM_Account__c = personAccount4.Id;
        relazioneDiCointestazioneCointestatario2.CRM_JointOwnership__c = cointestazione2.Id;
        relazioneDiCointestazioneCointestatario2.CRM_Active__c=true;

        CRM_AccountAccountJointOwnershipRelation__c relazioneDiCointestazioneCointestatario3 = new CRM_AccountAccountJointOwnershipRelation__c();
        relazioneDiCointestazioneCointestatario3.CRM_PrimaryNDG__c = true;
        relazioneDiCointestazioneCointestatario3.CRM_Account__c = personAccount4.Id;
        relazioneDiCointestazioneCointestatario3.CRM_JointOwnership__c = cointestazione3.Id;
        relazioneDiCointestazioneCointestatario3.CRM_Active__c=true;

        insert new List<CRM_AccountAccountJointOwnershipRelation__c>{relazioneDiCointestazionePrimario, relazioneDiCointestazioneCointestatario, relazioneDiCointestazionePrimario2, relazioneDiCointestazioneCointestatario2,relazioneDiCointestazioneCointestatario3};
        
        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];
        User NECF1 = AllDataFactory.getUser('14', profile.Id, 'Personal');
        NECF1.FederationIdentifier = '14';
        NECF1.Profilo__c = 'NEC_F.1';
        
        insert NECF1;

        User NECD0 = AllDataFactory.getUser('15', profile.Id, 'Personal');
        NECD0.FederationIdentifier = '15';
        NECD0.Profilo__c = 'NEC_D.0';
        
        insert NECD0;
        System.runAs(NECF1){
    
            Contact contact = AllDataFactory.getContact('01', NECF1.Id, filiale.id);
            insert contact;
        }
        System.runAs(NECD0){
    
            Contact contact2 = AllDataFactory.getContact('02', NECD0.Id, filiale.id);
            insert contact2;
        }
    }

    @isTest
    public static void testLoadNdgList(){

        List<Wallet__c> portafoglioTecnico = [SELECT id, PTF_ModelloDiServizio__c FROM Wallet__c WHERE RecordTypeId =: SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'TechnicalWallet') LIMIT 1];
        Map<String,Object> response = (Map<String,Object>)MultipleAssignmentController.loadNdgList(portafoglioTecnico[0].id, 0, 5, '', '','');
        Integer ndgListCount = (Integer)response.get('ndgListCount');
        System.assert(ndgListCount == 1, 'Expected: ' + ndgListCount);
    }

    @isTest
    public static void testAssenteLoadNdgList(){

        List<Wallet__c> portafoglioAssente = [SELECT id, PTF_ModelloDiServizio__c,PTF_StatoAssegnazione__c FROM Wallet__c WHERE RecordTypeId =: SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'Assente') LIMIT 1];
        Map<String,Object> response = (Map<String,Object>)MultipleAssignmentController.loadAssenteNdgList(portafoglioAssente[0].id, 20);
        Integer ndgListCount = (Integer)response.get('ndgListCount');
        System.assert(ndgListCount == 3, 'Expected: ' + ndgListCount);
    }

    @isTest
    public static void testCheckCointestazione(){

        List<Wallet__c> portafoglioAssente = [SELECT id, PTF_ModelloDiServizio__c ,PTF_StatoAssegnazione__c FROM Wallet__c WHERE RecordTypeId =: SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'Assente') LIMIT 1];
        Map<String,Object> ndgList = (Map<String,Object>)MultipleAssignmentController.loadAssenteNdgList(portafoglioAssente[0].id, 20);
        List<Account> accountList = (List<Account>)ndgList.get('ndgList');
        Account account;
        for(Account element : accountList){

            if(element.RecordType.DeveloperName == 'Cointestazione'){

                account = element;
                break;
            }
        }
        Wallet__c currentPF = [SELECT Id, Name, PTF_ModelloDiServizio__c,
        PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
        PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,PTF_StatoAssegnazione__c,
        PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
        PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c,
        (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
        FROM Wallet__c WHERE Id =: account.PTF_portafoglio__c LIMIT 1];
        Test.startTest();
        Map<String,Object> responseCheckCointestazione = (Map<String,Object>)MultipleAssignmentController.checkCointestazione(account, portafoglioAssente[0].id, account.RecordType.DeveloperName, currentPF);
        Test.stopTest();
        System.assertEquals(true, responseCheckCointestazione.size()>0);
    }

    @isTest
    public static void testCheckCointestazione2(){

        List<Wallet__c> portafoglioAssente = [SELECT id, PTF_ModelloDiServizio__c,PTF_StatoAssegnazione__c FROM Wallet__c WHERE RecordTypeId =: SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'Assente') LIMIT 1];
        Map<String,Object> ndgList = (Map<String,Object>)MultipleAssignmentController.loadAssenteNdgList(portafoglioAssente[0].id, 20);
        List<Account> accountList = (List<Account>)ndgList.get('ndgList');
        Account account;
        for(Account element : accountList){

            if(element.RecordType.DeveloperName != 'Cointestazione'){

                account = element;
                break;
            }
        }
        Wallet__c currentPF = [SELECT Id, Name, PTF_ModelloDiServizio__c,
        PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
        PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,PTF_StatoAssegnazione__c,
        PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
        PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c,
        (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
        FROM Wallet__c WHERE Id =: account.PTF_portafoglio__c LIMIT 1];
        Test.startTest();
        Map<String,Object> responseCheckCointestazione = (Map<String,Object>)MultipleAssignmentController.checkCointestazione(account, portafoglioAssente[0].id, account.RecordType.DeveloperName, currentPF);
    	Test.stopTest();
        System.assertEquals(true, responseCheckCointestazione.size()>0);
    }
    @isTest
    public static void testLoadMwList(){

        List<Wallet__c> portafoglioTecnico = [SELECT id, PTF_ModelloDiServizio__c FROM Wallet__c WHERE RecordTypeId =: SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'TechnicalWallet') LIMIT 1];
        Map<String,Object> ndgList = (Map<String,Object>)MultipleAssignmentController.loadNdgList(portafoglioTecnico[0].id, 0, 5, '', '','');
        List<String> filaielIdList = new List<String>();
        for(Account account : (List<Account>)ndgList.get('ndgList')){

            filaielIdList.add(account.PTF_Filiale__c);
        }
        Map<String,Object> response = (Map<String,Object>)MultipleAssignmentController.loadMwList(filaielIdList, new List<String>{'Personal'}, 0, 5);
        Integer mwListCount = (Integer)response.get('mwListCount'); 
        System.assert(mwListCount == 1, 'Expected: ' + mwListCount);
    }

    @isTest
    public static void testAssenteLoadMwList(){

        List<Wallet__c> portafoglioAssente = [SELECT id, PTF_ModelloDiServizio__c FROM Wallet__c WHERE RecordTypeId =: SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'Assente') LIMIT 1];
        Map<String,Object> ndgList = (Map<String,Object>)MultipleAssignmentController.loadAssenteNdgList(portafoglioAssente[0].id, 20);
        System.debug('AAA ndgList' +ndgList);
        List<Account> accountList = (List<Account>)ndgList.get('ndgList');
        Account account;
        for(Account element : accountList){

            if(element.RecordType.DeveloperName != 'Cointestazione'){

                account = element;
                break;
            }
        }
        Wallet__c currentPF = [SELECT Id, Name, PTF_ModelloDiServizio__c,
        PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
        PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,PTF_StatoAssegnazione__c,
        PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
        PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c,
        (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
        FROM Wallet__c WHERE Id =: account.PTF_portafoglio__c LIMIT 1];
        User titolare = [SELECT Id FROM User WHERE Profilo__c = 'NEC_F.1' AND FederationIdentifier = '14'];
        User userDZero = [SELECT Id FROM User WHERE Profilo__c = 'NEC_D.0' AND FederationIdentifier = '15'];
        System.runAs(titolare){

            Map<String,Object> response = (Map<String,Object>)MultipleAssignmentController.loadAssenteMwList(JSON.serialize(account),new List<String>{'Personal'}, false, 0, 5, '', true, currentPF.PTF_Filiale__c, currentPF);
            Integer mwListCount = (Integer)response.get('mwListCount');
            System.assert(mwListCount == 1, 'Expected: ' + mwListCount);
        }
        System.runAs(userDZero){
            Map<String,Object> response = (Map<String,Object>)MultipleAssignmentController.loadAssenteMwList(JSON.serialize(account),new List<String>{'Personal'}, false, 0, 5, '', true, currentPF.PTF_Filiale__c, currentPF);
            Integer mwListCount = (Integer)response.get('mwListCount');
            System.assert(mwListCount == 1, 'Expected: ' + mwListCount);
        }
    }

    @isTest
    public static void testCointestazioneAssenteLoadMwList(){

        List<Wallet__c> portafoglioAssente = [SELECT id, PTF_ModelloDiServizio__c FROM Wallet__c WHERE RecordTypeId =: SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'Assente') LIMIT 1];
        Map<String,Object> ndgList = (Map<String,Object>)MultipleAssignmentController.loadAssenteNdgList(portafoglioAssente[0].id, 20);
        List<Account> accountList = (List<Account>)ndgList.get('ndgList');
        Account account;
        for(Account element : accountList){

            if(element.RecordType.DeveloperName == 'Cointestazione'){

                account = element;
                break;
            }
        }
        Wallet__c currentPF = [SELECT Id, Name, PTF_ModelloDiServizio__c,
        PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
        PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,PTF_StatoAssegnazione__c,
        PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
        PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c,
        (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
        FROM Wallet__c WHERE Id =: account.PTF_portafoglio__c LIMIT 1];
        User titolare = [SELECT Id FROM User WHERE Profilo__c = 'NEC_F.1' AND FederationIdentifier = '14'];
        Integer mwListCount;
        test.startTest();
        System.runAs(titolare){

            Map<String,Object> response = (Map<String,Object>)MultipleAssignmentController.loadAssenteMwList(JSON.serialize(account),new List<String>{'Personal'}, false, 0, 5, '', true, currentPF.PTF_Filiale__c, currentPF);
             mwListCount = (Integer)response.get('mwListCount');
        }
        test.stopTest();
        System.assertEquals(true, mwListCount >0);
    }
    

    @isTest
    public static void testExecuteAssignment(){

        List<Wallet__c> portafoglioTecnico = [SELECT id, PTF_ModelloDiServizio__c FROM Wallet__c WHERE RecordTypeId =: SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'TechnicalWallet') LIMIT 1];
        Map<String,Object> ndgList = (Map<String,Object>)MultipleAssignmentController.loadNdgList(portafoglioTecnico[0].id, 0, 5, '', '','');
        List<String> ndgIdList = new List<String>();
        List<String> filaielIdList = new List<String>();
        List<String> mwIdList = new List<String>();
        for(Account account : (List<Account>)ndgList.get('ndgList')){

            ndgIdList.add(account.Id);
            filaielIdList.add(account.PTF_Filiale__c);
        }
        Map<String,Object> mwList = (Map<String,Object>)MultipleAssignmentController.loadMwList(filaielIdList, new List<String>{'Personal'}, 0, 5);
        for(Wallet__c wallet : (List<Wallet__c>)mwList.get('mwList')){

            mwIdList.add(wallet.Id);
        }
        Map<String, Object> params = new Map<String, Object>{
            'ndgIds' => ndgIdList,
            'mwId' => !mwIdList.isEmpty() ? mwIdList[0] : ''
        };
        Test.startTest();    
         MultipleAssignmentController.executeAssignment(JSON.serialize(params));
        Test.stopTest();
        List<Account> accounts=[SELECT id,PTF_Portafoglio__c FROM Account Where Id = :ndgIdList[0]];
        System.assertEquals(true, accounts.size()>0);
    }

    @isTest
    public static void testExecuteAssignmentAssente(){

        List<Wallet__c> portafoglioAssente = [SELECT id, PTF_ModelloDiServizio__c FROM Wallet__c WHERE RecordTypeId =: SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'Assente') LIMIT 1];
        Map<String,Object> ndgList = (Map<String,Object>)MultipleAssignmentController.loadAssenteNdgList(portafoglioAssente[0].id, 20);
        List<Account> accountList = (List<Account>)ndgList.get('ndgList');
        Account account;
        for(Account element : accountList){

            if(element.RecordType.DeveloperName != 'Cointestazione'){

                account = element;
                break;
            }
        }
        Wallet__c currentPF = [SELECT Id, Name, PTF_ModelloDiServizio__c,
        PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
        PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,PTF_StatoAssegnazione__c,
        PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
        PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c,
        (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
        FROM Wallet__c WHERE Id =: account.PTF_portafoglio__c LIMIT 1];
        User titolare = [SELECT Id FROM User WHERE Profilo__c = 'NEC_F.1' AND FederationIdentifier = '14'];
        System.runAs(titolare){

            Map<String,Object> mwList = (Map<String,Object>)MultipleAssignmentController.loadAssenteMwList(JSON.serialize(account), new List<String>{'Personal'}, false, 0, 5, '', true, currentPF.PTF_Filiale__c, currentPF);
            Integer mwListCount = (Integer)mwList.get('mwListCount');
            List<String> mwIdList = new List<String>();
            for(Wallet__c wallet : (List<Wallet__c>)mwList.get('mwList')){
    
                mwIdList.add(wallet.Id);
            }
            System.debug('@@@mwIdList: '+mwIdList);
            System.debug('@@@ndg: '+JSON.serialize(account));
            Map<String, Object> params = new Map<String, Object>{
                'ndg' => account.Id,
                'mwId' => mwIdList[0]
            };
            Test.startTest();   
            MultipleAssignmentController.executeAssignmentAssente(JSON.serialize(params));
            Test.stopTest();
        	List<Account> accounts=[SELECT id,PTF_Portafoglio__c FROM Account Where PTF_Portafoglio__c = :mwIdList[0]];
        	System.assertEquals(true, accounts.size()>0);
        }
    }
    @isTest
    public static void testInit(){
        Test.startTest();
        List<Wallet__c> wList= [SELECT Id FROM Wallet__c];
        Map<String,Object> response = new Map<String,Object>();
        for(Wallet__c w: wList){
            response = MultipleAssignmentController.init(w.Id);
        }
        Test.stopTest();
        System.assertEquals(true, response.size()>0);
    }
    
    @isTest
    public static void testloadPortafoglioPrimario(){
        String microPortafoglioId = [SELECT Id FROM Wallet__c WHERE RecordTypeId =: SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'MicroWallet') LIMIT 1].Id;
        Map<String,Object> response = MultipleAssignmentController.loadPortafoglioPrimario(microPortafoglioId);
		System.debug('testloadPortafoglioPrimario response: '+response);
		System.assertEquals(true,response.get('mwList') != null);
    }
    
    @isTest
    public static void testloadRelatedRecords(){
        List<String> idPersoneFisiche = new List<String>();
        List<String> idCointestazioni = new List<String>();
        Map<String,Account> personeFisiche = new Map<String,Account>([SELECT Id FROM Account WHERE RecordTypeId =: SV_Utilities.getRecordTypeByDeveloperName('Account', 'PersonAccount')]);
        Map<String,Account> cointestazioni = new Map<String,Account>([SELECT Id FROM Account WHERE RecordTypeId =: SV_Utilities.getRecordTypeByDeveloperName('Account', 'Cointestazione')]);
        idPersoneFisiche.addAll(personeFisiche.keySet());
       	idCointestazioni.addAll(cointestazioni.keySet());
        test.startTest();
		Map<String,Object> response = MultipleAssignmentController.loadRelatedRecords(idPersoneFisiche,idCointestazioni);
        test.stopTest();
        system.assertEquals(true, response.size()>0);
    }
}