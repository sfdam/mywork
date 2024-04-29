/**
* Controller of multipleAssignement LWC
*
* @author  Dam Kebe @Lutech
* @version 1.0
* @since   2020-07-27
*/
@isTest
public class ManageGestoriControllerTest {
    
    @TestSetup
    public static void setup(){
        Funzionalita__c x= new Funzionalita__c();
        x.Disable_Trigger__c=true;
        insert x;
        Profile profile = [SELECT id FROM Profile WHERE Name=: Label.System_Administrator LIMIT 1];
        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        user.Email='user1askdasgdhgas@bper.it';
        User user2 = AllDataFactory.getUser('02', profile.Id, 'CORPORATE');
        user2.Email='user2askdasgdhgas@bper.it';
        User user3 = AllDataFactory.getUser('03', profile.Id, 'CORPORATE');
        user3.Email='user3askdasgdhgas@bper.it';
        insert new List<User>{user, user2, user3};
            System.runAs(user){
                Account banca = AllDataFactory.getAccount('01', 'Banca');
        Account direzioneRegionale = AllDataFactory.getAccount('02', 'DirezioneRegionale');
        Account area = AllDataFactory.getAccount('03', 'Area');
        Account filiale = AllDataFactory.getAccount('04', 'FilialeDiRelazione');
        filiale.PTF_BranchTypology__c = 'A';
        Account executive = AllDataFactory.getAccount('05', 'FilialeDiRelazione');
        executive.PTF_IdCEDPadre__c='3008';
        Account uffPrivate = AllDataFactory.getAccount('06', 'FilialeDiRelazione');
        insert uffPrivate;
        Account acc = AllDataFactory.getAccount('07', 'FilialeDiRelazione');
        acc.PTF_UffPrivate__c=uffPrivate.id;
        insert new List<Account>{banca, direzioneRegionale, area, filiale,executive,acc};

        System.debug('Acc executive '+ executive);

        RoleTypology__c ruolo = new RoleTypology__c();
        ruolo.Name = 'TestRuolo';
        insert ruolo;
        RoleTypology__c ruolo1 = new RoleTypology__c();
        ruolo1.Name = 'Titolare';
        ruolo1.PTF_Code__c='100';
        insert ruolo1;

        ServiceModel__c modelloDiServizio = new ServiceModel__c();
        modelloDiServizio.Name = 'CORPORATE';
        insert modelloDiServizio;

        RoleMDS__c ruoloMDS = new RoleMDS__c();
        ruoloMDS.PTF_BranchTypology__c = 'A';
        ruoloMDS.PTF_RoleTypology__c = ruolo.Id;
        ruoloMDS.PTF_ServiceModel__c = modelloDiServizio.Id;
        ruoloMDS.PTF_StartDate__c = Date.today().addDays(-10);
        ruoloMDS.PTF_EndDate__c = Date.today().addDays(10);
        insert ruoloMDS;

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

        Contact contact = AllDataFactory.getContact('01', user.Id, filiale.Id);
        contact.PTF_TipologiaRuolo__c = ruolo.Id;
        contact.PTF_ProfiloLDAP__c = 'NEC_F.1';
        contact.PTF_ReferenteElegibile__c=true;
        Contact contact2 = AllDataFactory.getContact('02', user2.Id, filiale.Id);
        contact2.PTF_TipologiaRuolo__c = ruolo.Id;
        contact2.PTF_ProfiloLDAP__c = 'NEC_F.1';
        contact2.PTF_ReferenteElegibile__c=true;
        Contact contact3 = AllDataFactory.getContact('03', user3.Id, filiale.Id);
        contact3.PTF_TipologiaRuolo__c = ruolo.Id;
        contact3.PTF_ProfiloLDAP__c = 'NEC_F.1';
        contact3.PTF_ReferenteElegibile__c=true;
        Contact contact4 = AllDataFactory.getContact('04', user3.Id, executive.Id);
        contact4.PTF_RegistrationNumber__c='55555';
        contact4.PTF_TipologiaRuolo__c = ruolo1.Id;
        contact4.PTF_Ruolo__c='100';
        contact4.PTF_ProfiloLDAP__c = 'NEC_T.7';
        contact4.PTF_ReferenteElegibile__c=true;
        contact4.AccountId=executive.id;
        insert new List<Contact>{contact, contact2, contact3,contact4};
        System.debug('Ref elegibile'+ contact4.PTF_ReferenteElegibile__c);
        System.debug('Executive ruolo'+ contact4.PTF_Ruolo__c);
        System.debug('Ref PTF_IdCEDPadre__c'+ contact4.Account.PTF_IdCEDPadre__c);
                

        Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet', filiale.Id, 'CORPORATE');
        insert microPortafoglio;

        Assignment__c backupAssignment = AllDataFactory.getAssignment('Backup', microPortafoglio.Id, contact.Id);
        Assignment__c primarioAssignment = AllDataFactory.getAssignment('Primario', microPortafoglio.Id, contact2.Id);
        insert new List<Assignment__c>{backupAssignment, primarioAssignment};
            }
        
    }

    // @isTest
    // public static void testGetMicroPortafoglio(){

    //     List<Wallet__c> microPortafoglio = [SELECT id, PTF_Filiale__c, PTF_ModelloDiServizio__c FROM Wallet__c LIMIT 1];
    //     Wallet__c retrievedMW = ManageGestoriController.getMicroPortafoglio(microPortafoglio[0].Id);
    //     System.assert(microPortafoglio[0].Id == retrievedMW.Id, 'error');
    // }

    @isTest
    public static void testGetGestoriList(){

        List<Wallet__c> microPortafoglio = [SELECT id, PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypology__c, PTF_ModelloDiServizio__c FROM Wallet__c LIMIT 1];
        Map<String,Object> init = ManageGestoriController.init(microPortafoglio[0].Id);
        List<Map<String, Object>> response = ManageGestoriController.getGestoriList(microPortafoglio[0].Id, (Map<String, List<String>>)JSON.deserialize(JSON.serialize(init.get('roleMDSMap')), Map<String, List<String>>.class), 'Backup');
        System.assert(response.size() == 1);
    }

    @isTest
    public static void testSearchGestoriList(){

        List<Wallet__c> microPortafoglio = [SELECT id, PTF_Filiale__c, PTF_ModelloDiServizio__c FROM Wallet__c LIMIT 1];
        Map<String,Object> init = ManageGestoriController.init(microPortafoglio[0].Id);
        List<Map<String, Object>> gestoriList = ManageGestoriController.getGestoriList(microPortafoglio[0].Id, (Map<String, List<String>>)JSON.deserialize(JSON.serialize(init.get('roleMDSMap')), Map<String, List<String>>.class), 'Backup');
        Map<String, object> params = new Map<String, Object>();
        params.put('recordId', microPortafoglio[0].Id);
        params.put('contactIdList', new List<String>{(String)gestoriList[0].get('contactId')});
        params.put('nome', 'FirstName');
        params.put('cognome', 'LastName');
        params.put('hasOFS', false);
        params.put('matricola', '03');
        params.put('mds', 'Key Client');
        params.put('recordTypeName', 'Backup');
        Map<String, Object> response = ManageGestoriController.searchGestoriList(JSON.serialize(params), microPortafoglio[0].PTF_Filiale__c, (List<String>)JSON.deserialize(JSON.serialize(init.get('eligibleRoles')), List<String>.class), 0, 5,'System Administrator',true, false);
        //System.debug('referentiList: ' + JSON.serializePretty((List<Contact>)response.get('referentiList')));
        System.assert((Integer)response.get('referentiListCount') == 0,'expected: ' + (Integer)response.get('referentiListCount'));
    }
        @isTest
    public static void testSearchGestoriList1(){

        List<Wallet__c> microPortafoglio = [SELECT id, PTF_Filiale__c, PTF_ModelloDiServizio__c FROM Wallet__c LIMIT 1];
        Map<String,Object> init = ManageGestoriController.init(microPortafoglio[0].Id);
        List<Map<String, Object>> gestoriList = ManageGestoriController.getGestoriList(microPortafoglio[0].Id, (Map<String, List<String>>)JSON.deserialize(JSON.serialize(init.get('roleMDSMap')), Map<String, List<String>>.class), 'Backup');
        Map<String, object> params = new Map<String, Object>();
        params.put('recordId', microPortafoglio[0].Id);
        params.put('contactIdList', new List<String>{(String)gestoriList[0].get('contactId')});
        params.put('nome', 'FirstName');
        params.put('cognome', 'LastName');
        params.put('hasOFS', true);
        params.put('matricola', '03');
        params.put('mds', 'Private');
        params.put('recordTypeName', 'Backup');
        Map<String, Object> response = ManageGestoriController.searchGestoriList(JSON.serialize(params), microPortafoglio[0].PTF_Filiale__c, (List<String>)JSON.deserialize(JSON.serialize(init.get('eligibleRoles')), List<String>.class), 1, 5,'System Administrator',true, false);
        //System.debug('referentiList: ' + JSON.serializePretty((List<Contact>)response.get('referentiList')));
        System.assert((Integer)response.get('referentiListCount') == 0,'expected: ' + (Integer)response.get('referentiListCount'));
    }

    @isTest
    public static void testDeleteSelectedGestoriBackup(){

        List<Wallet__c> microPortafoglio = [SELECT id, PTF_Filiale__c, PTF_ModelloDiServizio__c FROM Wallet__c LIMIT 1];
        Map<String,Object> init = ManageGestoriController.init(microPortafoglio[0].Id);
        List<Map<String, Object>> gestoriList = ManageGestoriController.getGestoriList(microPortafoglio[0].Id, (Map<String, List<String>>)JSON.deserialize(JSON.serialize(init.get('roleMDSMap')), Map<String, List<String>>.class), 'Backup');
        List<String> gestoriToDelete = new List<String>();
        for(Map<String, Object> assignment : gestoriList){

            gestoriToDelete.add((String)assignment.get('Id'));
        }
        String recordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Backup');
        ManageGestoriController.deleteSelectedGestori(microPortafoglio[0].Id, gestoriToDelete, 'Backup');
        System.assert([SELECT count() FROM Assignment__C WHERE RecordtypeId =: recordTypeId AND PTF_MicroWallet__c =: microPortafoglio[0].Id AND PTF_EndDate__c = null] == 0);
    }

    @isTest
    public static void testDeleteSelectedGestoriPrimario(){

        List<Wallet__c> microPortafoglio = [SELECT id, PTF_Filiale__c, PTF_ModelloDiServizio__c FROM Wallet__c LIMIT 1];
        Map<String,Object> init = ManageGestoriController.init(microPortafoglio[0].Id);
        List<Map<String, Object>> gestoriList = ManageGestoriController.getGestoriList(microPortafoglio[0].Id, (Map<String, List<String>>)JSON.deserialize(JSON.serialize(init.get('roleMDSMap')), Map<String, List<String>>.class), 'Primario');
        List<String> gestoriToDelete = new List<String>();
        for(Map<String, Object> assignment : gestoriList){

            gestoriToDelete.add((String)assignment.get('Id'));
        }
        String recordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Primario');
        ManageGestoriController.deleteSelectedGestori(microPortafoglio[0].Id, gestoriToDelete, 'Primario');
        System.assert([SELECT count() FROM Assignment__C WHERE RecordtypeId =: recordTypeId AND PTF_MicroWallet__c =: microPortafoglio[0].Id AND PTF_EndDate__c = null] == 0);
    }

    @isTest
    public static void testInsertNewGestoriBackup(){

        List<Wallet__c> microPortafoglio = [SELECT id, PTF_Filiale__c, PTF_ModelloDiServizio__c FROM Wallet__c LIMIT 1];
        /*Map<String,Object> init = ManageGestoriController.init(microPortafoglio[0].Id);
        List<Map<String, Object>> gestoriList = ManageGestoriController.getGestoriList(microPortafoglio[0].Id, (Map<String, List<String>>)JSON.deserialize(JSON.serialize(init.get('roleMDSMap')), Map<String, List<String>>.class), 'Backup');
        Map<String, object> params = new Map<String, Object>();
        params.put('recordId', microPortafoglio[0].Id);
        params.put('contactIdList', new List<String>{(String)gestoriList[0].get('contactId')});
        params.put('nome', 'FirstName');
        params.put('cognome', 'LastName');
        params.put('matricola', '');
        params.put('hasOFS', false);
        params.put('recordTypeName', 'Backup');
        params.put('mds', 'CORPORATE');
        //Map<String, Object> referentiList = ManageGestoriController.searchGestoriList(JSON.serialize(params), microPortafoglio[0].PTF_Filiale__c, /*(List<String>)JSON.deserialize(JSON.serialize(init.get('eligibleRoles')), List<String>.class)new List<String>(), 0, 5);
        //List<Contact> gestoriToInsert = (List<Contact>)referentiList.get('referentiList');
        //Set<Id> gestoriToInsertIdSet = SV_Utilities.getIdSet(gestoriToInsert, 'Id');
        /*List<String> gestoriToInsertIdList = new List<String>();
        for(Id gestoriToInsertId : gestoriToInsertIdSet){
            
            gestoriToInsertIdList.add(gestoriToInsertId);
        }*/
        List<String> gestoriToInsertIdList = new List<String>();
        List<Contact> conList =[SELECT Id FROM Contact];
        for(Contact con:conList){
            gestoriToInsertIdList.add(con.Id);
        }
        ManageGestoriController.insertNewGestori(microPortafoglio[0].Id, gestoriToInsertIdList, 'Backup');
        String recordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Backup');
        System.assert([SELECT count() FROM Assignment__C WHERE RecordtypeId =: recordTypeId AND PTF_MicroWallet__c =: microPortafoglio[0].Id ] >0);

    }

    @isTest
    public static void testInsertNewGestoriPrimario(){

        List<Wallet__c> microPortafoglio = [SELECT id, PTF_Filiale__c, PTF_ModelloDiServizio__c FROM Wallet__c LIMIT 1];
        /*Map<String,Object> init = ManageGestoriController.init(microPortafoglio[0].Id);
        List<Map<String, Object>> gestoriList = ManageGestoriController.getGestoriList(microPortafoglio[0].Id, (Map<String, List<String>>)JSON.deserialize(JSON.serialize(init.get('roleMDSMap')), Map<String, List<String>>.class), 'Primario');
        Map<String, object> params = new Map<String, Object>();
        params.put('recordId', microPortafoglio[0].Id);
        params.put('contactIdList', new List<String>{(String)gestoriList[0].get('contactId')});
        params.put('nome', 'FirstName');
        params.put('cognome', 'LastName');
        params.put('hasOFS', false);
        params.put('matricola', '');
        params.put('recordTypeName', 'Primario');
        params.put('mds', 'CORPORATE');
        Map<String, Object> referentiList = ManageGestoriController.searchGestoriList(JSON.serialize(params), microPortafoglio[0].PTF_Filiale__c, /*(List<String>)JSON.deserialize(JSON.serialize(init.get('eligibleRoles')), List<String>.class)new List<String>(), 0, 5);
        /*List<Contact> gestoriToInsert = (List<Contact>)referentiList.get('referentiList');
        Set<Id> gestoriToInsertIdSet = SV_Utilities.getIdSet(gestoriToInsert, 'Id');
        List<String> gestoriToInsertIdList = new List<String>();
        for(Id gestoriToInsertId : gestoriToInsertIdSet){
            
            gestoriToInsertIdList.add(gestoriToInsertId);
        }*/
        List<String> gestoriToInsertIdList = new List<String>();
        List<Contact> conList =[SELECT Id FROM Contact];
        for(Contact con:conList){
            gestoriToInsertIdList.add(con.Id);
        }
        test.startTest();
        ManageGestoriController.insertNewGestori(microPortafoglio[0].Id, gestoriToInsertIdList, 'Primario');
        test.stopTest();
        String recordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Primario');
        Integer countResult = [SELECT count() FROM Assignment__C WHERE RecordtypeId =: recordTypeId AND PTF_MicroWallet__c =: microPortafoglio[0].Id AND PTF_EndDate__c = null];
        System.Assert(countResult>0);
    }

    @IsTest
    public static void testGetPercentage(){

        List<Wallet__c> microPortafoglio = [SELECT id, PTF_Filiale__c, PTF_ModelloDiServizio__c FROM Wallet__c LIMIT 1];
        Assignment__c c= [SELECT PTF_Gestore__c FROM Assignment__c WHERE PTF_MicroWallet__c =:microPortafoglio[0].Id AND RecordType.DeveloperName='Primario' LIMIT 1];
        
        Test.startTest();
        ManageGestoriController.PercentageWrapper percentageWrapper = ManageGestoriController.getPercentage(microPortafoglio[0].Id, c.PTF_Gestore__c);
        Test.stopTest();
        System.assert(percentageWrapper !=null);
    }
    
    @isTest
    public static void testSearchGestoriPrivateList(){
        List<Wallet__c> microPortafoglio = [SELECT id, PTF_Filiale__c, PTF_ModelloDiServizio__c FROM Wallet__c LIMIT 1];
        Map<String,Object> init = ManageGestoriController.init(microPortafoglio[0].Id);
        List<Map<String, Object>> gestoriList = ManageGestoriController.getGestoriList(microPortafoglio[0].Id, (Map<String, List<String>>)JSON.deserialize(JSON.serialize(init.get('roleMDSMap')), Map<String, List<String>>.class), 'Backup');
        Map<String, object> params = new Map<String, Object>();
        params.put('recordId', microPortafoglio[0].Id);
        params.put('contactIdList', new List<String>{(String)gestoriList[0].get('contactId')});
        params.put('nome', 'FirstName');
        params.put('cognome', 'LastName');
        params.put('hasOFS', false);
        params.put('matricola', '03');
        params.put('recordTypeName', 'Backup');
        Test.startTest();
        Map<String, Object> response = ManageGestoriController.searchGestoriPrivateList(JSON.serialize(params),microPortafoglio[0].Id,microPortafoglio[0].PTF_ModelloDiServizio__c , microPortafoglio[0].PTF_Filiale__c, false, false);
        test.stopTest();
        System.assertEquals(true,response.size()> 0);
        
    }
        @isTest
    public static void testSearchGetBackupPrivateList(){
        List<Wallet__c> microPortafoglio = [SELECT id, PTF_Filiale__c, PTF_ModelloDiServizio__c FROM Wallet__c LIMIT 1];
        Map<String,Object> init = ManageGestoriController.init(microPortafoglio[0].Id);
        List<Map<String, Object>> gestoriList = ManageGestoriController.getGestoriList(microPortafoglio[0].Id, (Map<String, List<String>>)JSON.deserialize(JSON.serialize(init.get('roleMDSMap')), Map<String, List<String>>.class), 'Backup');
        Map<String, object> params = new Map<String, Object>();
        params.put('recordId', microPortafoglio[0].Id);
        params.put('contactIdList', new List<String>{(String)gestoriList[0].get('contactId')});
        params.put('nome', 'FirstName');
        params.put('cognome', 'LastName');
        params.put('hasOFS', false);
        params.put('matricola', '03');
        params.put('recordTypeName', 'Backup');
        Test.startTest();
        Map<String, Object> response = ManageGestoriController.searchGetBackupPrivateList(JSON.serialize(params),microPortafoglio[0].Id,microPortafoglio[0].PTF_ModelloDiServizio__c , microPortafoglio[0].PTF_Filiale__c);
        test.stopTest();
        System.assertEquals(true,response.size()> 0);
        
    }
}