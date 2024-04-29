@IsTest
public class REST_PortafogliazioneOnline_Test {
    @TestSetup
    static void makeData(){
        
        List<sObject> ls1 = Test.loadData(ServiceModel__c.sObjectType, 'ServiceModel_TEST');
        Account banca= AllDataFactory.getAccount('Banca','Banca');
        banca.FinServ__BankNumber__c='1234';
        Account banca2= AllDataFactory.getAccount('Banca2','Banca');
        banca2.FinServ__BankNumber__c='12345';

        insert new List<Account>{banca, banca2};

        Account dr= AllDataFactory.getAccount('DR','DirezioneRegionale');
        dr.PTF_Banca__c=banca.Id;

        insert dr;

        Account area = AllDataFactory.getAccount('Area','Area');
        area.PTF_DirezioneRegionale__c=dr.Id;
        area.PTF_Banca__c=banca.Id;
        insert area;


        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        filiale.PTF_BranchTypology__c='A';
        filiale.PTF_Area__c= area.Id;
        filiale.PTF_Banca__c=banca.Id;
        filiale.PTF_DirezioneRegionale__c=dr.Id;
        filiale.PTF_IdCEDFiliale__c='0';
        filiale.PTF_IdCED__c='0';
        Account filiale2 = AllDataFactory.getAccount('02', 'FilialeDiRelazione');
        filiale2.PTF_Area__c= area.Id;
        filiale2.PTF_Banca__c=banca.Id;
        filiale2.PTF_DirezioneRegionale__c=dr.Id;
        filiale2.PTF_BranchTypology__c='A';
        filiale.PTF_IdCEDFiliale__c='0';
        filiale2.PTF_IdCED__c='0';
        insert new List<Account>{filiale, filiale2};

        RoleTypology__c ruolo = new RoleTypology__c();
        ruolo.Name = 'Titolare';
        insert ruolo;

        ServiceModel__c modelloDiServizio = new ServiceModel__c();
        modelloDiServizio.Name = 'Private';
        insert modelloDiServizio;

        RoleMDS__c ruoloMDS = new RoleMDS__c();
        ruoloMDS.PTF_BranchTypology__c = 'A';
        ruoloMDS.PTF_RoleTypology__c = ruolo.Id;
        ruoloMDS.PTF_ServiceModel__c = modelloDiServizio.Id;
        ruoloMDS.PTF_StartDate__c = Date.today().addDays(-10);
        ruoloMDS.PTF_EndDate__c = Date.today().addDays(10);
        insert ruoloMDS;
        
        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];
        
        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        user.FederationIdentifier='01';
        User user2 = AllDataFactory.getUser('02', profile.Id, 'CORPORATE');
        user2.FederationIdentifier='02';
        User user3 = AllDataFactory.getUser('03', profile.Id, 'CORPORATE');
        user3.FederationIdentifier='03';
        insert new List<User>{user, user2,user3};

        System.runAs(user3){
        Contact contact = AllDataFactory.getContact('01', user.Id, filiale.Id);
        contact.PTF_RegistrationNumber__c='01';
        Contact contact2 = AllDataFactory.getContact('02', user2.Id, filiale2.Id);
        contact2.PTF_RegistrationNumber__c='02';
        Contact contact3 = AllDataFactory.getContact('03', user3.Id, filiale.Id);
        contact3.PTF_RegistrationNumber__c='03';
        contact.PTF_TipologiaRuolo__c = ruolo.Id;
        contact2.PTF_TipologiaRuolo__c=ruolo.Id;
        insert new List<Contact>{contact, contact2, contact3};

        Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet', filiale.Id, 'CORPORATE');
        Wallet__c microPortafoglio2 = AllDataFactory.getWallet('MicroWallet', filiale2.Id, 'CORPORATE');
        Wallet__c microPortafoglio3 = AllDataFactory.getWallet('MicroWallet', filiale2.Id, 'CORPORATE');
        insert new List<Wallet__c>{microPortafoglio, microPortafoglio2,microPortafoglio3};
        
        Assignment__c primarioAssignment = AllDataFactory.getAssignment('Primario', microPortafoglio.Id, contact.Id);
        Assignment__c primarioAssignment2 = AllDataFactory.getAssignment('Primario', microPortafoglio2.Id, contact2.Id);
        Assignment__c primarioAssignment3 = AllDataFactory.getAssignment('Primario', microPortafoglio3.Id, contact2.Id);
        
        /*Assignment__c primarioAssignment = new assignment__c (
            PTF_MicroWallet__c = microPortafoglio.Id,
            PTF_Gestore__c = contact.Id,
            RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Primario'),
            PTF_EndDate__c = null
        );

        Assignment__c primarioAssignment2 = new assignment__c (
            PTF_MicroWallet__c = microPortafoglio2.Id,
            PTF_Gestore__c = contact2.Id,
            RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Primario'),
            PTF_EndDate__c = null
        );

        Assignment__c primarioAssignment3 = new assignment__c (
            PTF_MicroWallet__c = microPortafoglio3.Id,
            PTF_Gestore__c = contact3.Id,
            RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Primario'),
            PTF_EndDate__c = null
        );*/

        insert new List<Assignment__c>{primarioAssignment2, primarioAssignment, primarioAssignment3};
        
        Account ndg = AllDataFactory.getAccount('NDG1','PersonAccount');
        ndg.PTF_Portafoglio__c=microPortafoglio2.Id;
        ndg.CRM_NDG__c='1234';
        ndg.NDW_ExternalId__c='1234_1234';
        Account ndg2 = AllDataFactory.getAccount('NDG3','PersonAccount');
        ndg2.CRM_NDG__c='123456';
        ndg2.NDW_ExternalId__c='1234_123456';
        ndg2.PTF_DeletionDate__c=Date.today();
        Account ndg3 = AllDataFactory.getAccount('NDG3','Cointestazione');
        ndg3.CRM_NDG__c='123';
        ndg3.NDW_ExternalId__c='1234_123';
        ndg3.PTF_DeletionDate__c=Date.today();
        insert new List<Account>{ndg2, ndg, ndg3};
        }
        
    }
    @isTest
    public static void testOk(){
        Funzionalita__c x = new Funzionalita__c();
        x.Disable_Trigger__c =true;
        insert x;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest/v1/portafogliazioneOnline/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();

        REST_PortafogliazioneOnline.PortafogliazioneOnlineInput portafogliazioneOnlineInput = new REST_PortafogliazioneOnline.PortafogliazioneOnlineInput();
        portafogliazioneOnlineInput.Abi ='1234';
        Account filiale= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c, PTF_IdCED__c FROM Account WHERE Name='Account01' ][0];
        portafogliazioneOnlineInput.CodFiliale =filiale.PTF_IdCED__c;
        portafogliazioneOnlineInput.Matricola='01';
        portafogliazioneOnlineInput.CodiceMDS='1';
        portafogliazioneOnlineInput.ndgList = new List<REST_PortafogliazioneOnline.NDG_Input>();
        REST_PortafogliazioneOnline.NDG_Input ndg1= new REST_PortafogliazioneOnline.NDG_Input();
        ndg1.denominazione='test';
        ndg1.NaturaGiuridica='PF';
        ndg1.NDG='30011456';
        ndg1.Cognome='Galli';
        ndg1.Nome='Giacomo';
        portafogliazioneOnlineInput.ndgList.add(ndg1);
        REST_PortafogliazioneOnline.NDG_Input ndg2= new REST_PortafogliazioneOnline.NDG_Input();
        ndg2.denominazione='Test2';
        ndg2.NaturaGiuridica='CO';
        ndg2.NDG='123';
        ndg2.Cognome='Rossi';
        ndg2.Nome='Luigi';
        portafogliazioneOnlineInput.ndgList.add(ndg2);
        system.debug('@@@@lancio servizio');
        REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput);
        Test.stopTest();
        System.assertEquals(true, (REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput)) !=null);
    }
    @isTest
    public static void testOkWtihoutPortafoglio(){
        Funzionalita__c x = new Funzionalita__c();
        x.Disable_Trigger__c =true;
        insert x;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest/v1/portafogliazioneOnline/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_PortafogliazioneOnline.PortafogliazioneOnlineInput portafogliazioneOnlineInput = new REST_PortafogliazioneOnline.PortafogliazioneOnlineInput();
        portafogliazioneOnlineInput.Abi ='1234';
        Account filiale= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c, PTF_IdCED__c FROM Account WHERE Name='Account01' ][0];
        portafogliazioneOnlineInput.CodFiliale =filiale.PTF_IdCED__c;
        portafogliazioneOnlineInput.matricola='01';
        portafogliazioneOnlineInput.ndgList = new List<REST_PortafogliazioneOnline.NDG_Input>();
        REST_PortafogliazioneOnline.NDG_Input ndg1= new REST_PortafogliazioneOnline.NDG_Input();
        ndg1.denominazione ='Test'; 
        ndg1.NaturaGiuridica ='PF';
        ndg1.NDG ='30011456';
        ndg1.Cognome ='Galli';
        ndg1.Nome ='Giacomo';                     
        ndg1.fuoriSede = false;
        portafogliazioneOnlineInput.ndgList.add(ndg1);
        REST_PortafogliazioneOnline.NDG_Input ndg2= new REST_PortafogliazioneOnline.NDG_Input();
        ndg2.denominazione='Test2';
        ndg2.NaturaGiuridica='CO';
        ndg2.NDG='123';
        ndg2.Cognome='Rossi';
        ndg2.Nome='Luigi';
        portafogliazioneOnlineInput.ndgList.add(ndg2);
        REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput);
        Test.stopTest();
        System.assertEquals(true, (REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput)) !=null);
    }
    @isTest
    public static void checkParams(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest/v1/portafogliazioneOnline/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_PortafogliazioneOnline.PortafogliazioneOnlineInput portafogliazioneOnlineInput = new REST_PortafogliazioneOnline.PortafogliazioneOnlineInput();
        Account filiale= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c, PTF_IdCED__c FROM Account WHERE Name='Account01' ][0];        
        REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput);
        Test.stopTest();
        System.assertEquals(true, (REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput)) !=null);
    }
    @isTest
    public static void checkParams2(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest/v1/portafogliazioneOnline/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_PortafogliazioneOnline.PortafogliazioneOnlineInput portafogliazioneOnlineInput = new REST_PortafogliazioneOnline.PortafogliazioneOnlineInput();
        portafogliazioneOnlineInput.Abi ='1234';
        Account filiale= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c, PTF_IdCED__c FROM Account WHERE Name='Account02' ][0];
        portafogliazioneOnlineInput.CodFiliale =filiale.PTF_IdCED__c;
        portafogliazioneOnlineInput.Matricola='01';
        portafogliazioneOnlineInput.ndgList = new List<REST_PortafogliazioneOnline.NDG_Input>();
        REST_PortafogliazioneOnline.NDG_Input ndg1= new REST_PortafogliazioneOnline.NDG_Input();
        ndg1.denominazione= 'test';
        ndg1.NaturaGiuridica='PF';
        portafogliazioneOnlineInput.ndgList.add(ndg1);
        REST_PortafogliazioneOnline.NDG_Input ndg2= new REST_PortafogliazioneOnline.NDG_Input();
        ndg2.NaturaGiuridica='CO';
        ndg2.NDG='123';
        portafogliazioneOnlineInput.ndgList.add(ndg2);
        REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput);
        Test.stopTest();
        System.assertEquals(true, (REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput)) !=null);
        
    }
    @isTest
    public static void checkParams3(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest/v1/portafogliazioneOnline/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_PortafogliazioneOnline.PortafogliazioneOnlineInput portafogliazioneOnlineInput = new REST_PortafogliazioneOnline.PortafogliazioneOnlineInput();
        portafogliazioneOnlineInput.Abi ='1234';
        Account filiale= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c, PTF_IdCED__c FROM Account WHERE Name='Account01' ][0];
        portafogliazioneOnlineInput.CodFiliale =filiale.PTF_IdCED__c;
        portafogliazioneOnlineInput.Matricola='01';
        portafogliazioneOnlineInput.ndgList = new List<REST_PortafogliazioneOnline.NDG_Input>();
        REST_PortafogliazioneOnline.NDG_Input ndg1= new REST_PortafogliazioneOnline.NDG_Input();
        ndg1.Nome='Giacomo';
        portafogliazioneOnlineInput.ndgList.add(ndg1);
        REST_PortafogliazioneOnline.NDG_Input ndg2= new REST_PortafogliazioneOnline.NDG_Input();
        ndg2.NaturaGiuridica='CO';
        ndg2.NDG='123';
        portafogliazioneOnlineInput.ndgList.add(ndg2);
        REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput);
        Test.stopTest();
        System.assertEquals(true, (REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput)) !=null);
    }
    @isTest
    public static void testMissingABI(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest/v1/portafogliazioneOnline/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_PortafogliazioneOnline.PortafogliazioneOnlineInput portafogliazioneOnlineInput = new REST_PortafogliazioneOnline.PortafogliazioneOnlineInput();
        portafogliazioneOnlineInput.Abi ='1234567';
        Account filiale= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c, PTF_IdCED__c FROM Account WHERE Name='Account01' ][0];
        portafogliazioneOnlineInput.CodFiliale =filiale.PTF_IdCED__c;
        portafogliazioneOnlineInput.matricola='01';
        portafogliazioneOnlineInput.ndgList = new List<REST_PortafogliazioneOnline.NDG_Input>();
        REST_PortafogliazioneOnline.NDG_Input ndg1= new REST_PortafogliazioneOnline.NDG_Input();
        ndg1.NaturaGiuridica='PF';
        ndg1.NDG='30011456';
        ndg1.Cognome='Galli';
        ndg1.Nome='Giacomo';
        ndg1.Denominazione='test';
        portafogliazioneOnlineInput.ndgList.add(ndg1);
        REST_PortafogliazioneOnline.NDG_Input ndg2= new REST_PortafogliazioneOnline.NDG_Input();
        ndg2.NaturaGiuridica='CO';
        ndg2.NDG='123';
        ndg2.Denominazione='test2';
        portafogliazioneOnlineInput.ndgList.add(ndg2);
        REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput);
        Test.stopTest();
        System.assertEquals(true, (REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput)) !=null);

    }
    @isTest
    public static void testMissingFiliale(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest/v1/portafogliazioneOnline/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_PortafogliazioneOnline.PortafogliazioneOnlineInput portafogliazioneOnlineInput = new REST_PortafogliazioneOnline.PortafogliazioneOnlineInput();
        portafogliazioneOnlineInput.Abi ='1234';
        portafogliazioneOnlineInput.CodFiliale ='0000';
        Account filiale= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c, PTF_IdCED__c FROM Account WHERE Name='Account01' ][0];
        portafogliazioneOnlineInput.matricola='01';
        portafogliazioneOnlineInput.ndgList = new List<REST_PortafogliazioneOnline.NDG_Input>();
        REST_PortafogliazioneOnline.NDG_Input ndg1= new REST_PortafogliazioneOnline.NDG_Input();
        ndg1.NaturaGiuridica='PF';
        ndg1.NDG='30011456';
        ndg1.Cognome='Galli';
        ndg1.Nome='Giacomo';
        ndg1.Denominazione='test';
        portafogliazioneOnlineInput.ndgList.add(ndg1);
        REST_PortafogliazioneOnline.NDG_Input ndg2= new REST_PortafogliazioneOnline.NDG_Input();
        ndg2.NaturaGiuridica='CO';
        ndg2.NDG='123';
        ndg2.Denominazione='test2';
        portafogliazioneOnlineInput.ndgList.add(ndg2);
        REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput);
        Test.stopTest();
        System.assertEquals(true, (REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput)) !=null);

    }
    @isTest
    public static void testMissingConsulente(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest/v1/portafogliazioneOnline/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_PortafogliazioneOnline.PortafogliazioneOnlineInput portafogliazioneOnlineInput = new REST_PortafogliazioneOnline.PortafogliazioneOnlineInput();
        portafogliazioneOnlineInput.Abi ='1234';
        Account filiale= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c, PTF_IdCED__c FROM Account WHERE Name='Account01' ][0];
        portafogliazioneOnlineInput.CodFiliale =filiale.PTF_IdCED__c;
        portafogliazioneOnlineInput.matricola='02';
        portafogliazioneOnlineInput.ndgList = new List<REST_PortafogliazioneOnline.NDG_Input>();
        REST_PortafogliazioneOnline.NDG_Input ndg1= new REST_PortafogliazioneOnline.NDG_Input();
        ndg1.NaturaGiuridica='PF';
        ndg1.NDG='30011456';
        ndg1.Cognome='Galli';
        ndg1.Nome='Giacomo';
        ndg1.Denominazione='test';
        portafogliazioneOnlineInput.ndgList.add(ndg1);
        REST_PortafogliazioneOnline.NDG_Input ndg2= new REST_PortafogliazioneOnline.NDG_Input();
        ndg2.NaturaGiuridica='CO';
        ndg2.NDG='123';
        ndg2.Denominazione='test2';
        portafogliazioneOnlineInput.ndgList.add(ndg2);
        REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput);
        Test.stopTest();
        System.assertEquals(true, (REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput)) !=null);

    }
    @isTest
    public static void testCheckPortafoglioException(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest/v1/portafogliazioneOnline/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_PortafogliazioneOnline.PortafogliazioneOnlineInput portafogliazioneOnlineInput = new REST_PortafogliazioneOnline.PortafogliazioneOnlineInput();
        portafogliazioneOnlineInput.Abi ='1234';
        Account filiale= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c, PTF_IdCED__c FROM Account WHERE Name='Account01' ][0];
        portafogliazioneOnlineInput.CodFiliale =filiale.PTF_IdCED__c;
        portafogliazioneOnlineInput.Matricola = '02';
        portafogliazioneOnlineInput.CodiceMDS='54321';
        portafogliazioneOnlineInput.ndgList = new List<REST_PortafogliazioneOnline.NDG_Input>();
        REST_PortafogliazioneOnline.NDG_Input ndg1= new REST_PortafogliazioneOnline.NDG_Input();
        ndg1.Denominazione = 'Test';
        ndg1.NaturaGiuridica='PF';
        ndg1.NDG='30011456';
        ndg1.Cognome='Galli';
        ndg1.Nome='Giacomo';
        portafogliazioneOnlineInput.ndgList.add(ndg1);
        REST_PortafogliazioneOnline.NDG_Input ndg2= new REST_PortafogliazioneOnline.NDG_Input();
        ndg1.Denominazione = 'Test';
        ndg2.NaturaGiuridica='CO';
        ndg2.NDG='123';
        ndg2.Denominazione='Test2';
        portafogliazioneOnlineInput.ndgList.add(ndg2);
        REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput);
        Test.stopTest();
        System.assertEquals(true, (REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput)) !=null);

    }
    @isTest
    public static void testMorePortafoglioException(){
        Funzionalita__c x = new Funzionalita__c();
        x.Disable_Trigger__c =true;
        insert x;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest/v1/portafogliazioneOnline/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_PortafogliazioneOnline.PortafogliazioneOnlineInput portafogliazioneOnlineInput = new REST_PortafogliazioneOnline.PortafogliazioneOnlineInput();
        portafogliazioneOnlineInput.Abi ='1234';
        Account filiale= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c, PTF_IdCED__c FROM Account WHERE Name='Account02' ][0];
        portafogliazioneOnlineInput.CodFiliale =filiale.PTF_IdCED__c;
        portafogliazioneOnlineInput.matricola='02';
        portafogliazioneOnlineInput.ndgList = new List<REST_PortafogliazioneOnline.NDG_Input>();
        REST_PortafogliazioneOnline.NDG_Input ndg1= new REST_PortafogliazioneOnline.NDG_Input();
        ndg1.NaturaGiuridica='PF';
        ndg1.NDG='30011456';
        ndg1.Cognome='Galli';
        ndg1.Nome='Giacomo';
        ndg1.Denominazione='Test';
        portafogliazioneOnlineInput.ndgList.add(ndg1);
        REST_PortafogliazioneOnline.NDG_Input ndg2= new REST_PortafogliazioneOnline.NDG_Input();
        ndg2.NaturaGiuridica='CO';
        ndg2.NDG='123';
        ndg2.Denominazione='Test2';
        portafogliazioneOnlineInput.ndgList.add(ndg2);
        REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput);
        Test.stopTest();
        System.assertEquals(true, (REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput)) !=null);

    }
    @isTest
    public static void testNoPortafogliException(){
        Funzionalita__c x = new Funzionalita__c();
        x.Disable_Trigger__c =true;
        insert x;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest/v1/portafogliazioneOnline/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_PortafogliazioneOnline.PortafogliazioneOnlineInput portafogliazioneOnlineInput = new REST_PortafogliazioneOnline.PortafogliazioneOnlineInput();
        portafogliazioneOnlineInput.Abi ='1234';
        Account filiale= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c, PTF_IdCED__c FROM Account WHERE Name='Account02' ][0];
        Account filiale2= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c, PTF_IdCED__c FROM Account WHERE Name='Account01' ][0];
        portafogliazioneOnlineInput.CodFiliale =filiale.PTF_IdCED__c;
        portafogliazioneOnlineInput.matricola='02';
        portafogliazioneOnlineInput.ndgList = new List<REST_PortafogliazioneOnline.NDG_Input>();
        REST_PortafogliazioneOnline.NDG_Input ndg1= new REST_PortafogliazioneOnline.NDG_Input();
        ndg1.NaturaGiuridica='PF';
        ndg1.NDG='30011456';
        ndg1.Cognome='Galli';
        ndg1.Nome='Giacomo';
        ndg1.Denominazione='Test';
        portafogliazioneOnlineInput.ndgList.add(ndg1);
        REST_PortafogliazioneOnline.NDG_Input ndg2= new REST_PortafogliazioneOnline.NDG_Input();
        ndg2.NaturaGiuridica='CO';
        ndg2.NDG='123';
        ndg2.Denominazione='Test2';
        portafogliazioneOnlineInput.ndgList.add(ndg2);
        REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput);
        Test.stopTest();
        System.assertEquals(true, (REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput)) !=null);

    }
    
    @isTest
    public static void testAlreadyAssignedWtihoutPortafoglio(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest/v1/portafogliazioneOnline/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_PortafogliazioneOnline.PortafogliazioneOnlineInput portafogliazioneOnlineInput = new REST_PortafogliazioneOnline.PortafogliazioneOnlineInput();
        portafogliazioneOnlineInput.Abi ='1234';
        Account filiale= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c, PTF_IdCEDFiliale__c FROM Account WHERE Name='Account01' ][0];
        portafogliazioneOnlineInput.CodFiliale =filiale.PTF_IdCEDFiliale__c;
        portafogliazioneOnlineInput.matricola='01';
        portafogliazioneOnlineInput.ndgList = new List<REST_PortafogliazioneOnline.NDG_Input>();
        REST_PortafogliazioneOnline.NDG_Input ndg1= new REST_PortafogliazioneOnline.NDG_Input();
        ndg1.NaturaGiuridica='PF';
        ndg1.NDG='1234';
        ndg1.Cognome='Galli';
        ndg1.Nome='Giacomo';
        ndg1.Denominazione='Test';
        portafogliazioneOnlineInput.ndgList.add(ndg1);
        REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput);
        Test.stopTest();
        System.assertEquals(true, (REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput)) !=null);

    }
    @isTest
    public static void testException(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest/v1/portafogliazioneOnline/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_PortafogliazioneOnline.processRiportafogliazioneOnline(null);
        Test.stopTest();
        System.assertEquals(true, (REST_PortafogliazioneOnline.processRiportafogliazioneOnline(null)) !=null);

    }
    @isTest
    public static void testOk2(){
        Funzionalita__c x = new Funzionalita__c();
        x.Disable_Trigger__c =true;
        insert x;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest/v1/portafogliazioneOnline/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_PortafogliazioneOnline.PortafogliazioneOnlineInput portafogliazioneOnlineInput = new REST_PortafogliazioneOnline.PortafogliazioneOnlineInput();
        portafogliazioneOnlineInput.Abi ='1234';
        Account filiale= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c, PTF_IdCED__c FROM Account WHERE Name='Account01' ][0];
        portafogliazioneOnlineInput.CodFiliale =filiale.PTF_IdCED__c;
        portafogliazioneOnlineInput.Matricola='01';
        portafogliazioneOnlineInput.ndgList = new List<REST_PortafogliazioneOnline.NDG_Input>();
        REST_PortafogliazioneOnline.NDG_Input ndg1= new REST_PortafogliazioneOnline.NDG_Input();
        ndg1.NaturaGiuridica='PF';
        ndg1.NDG='123456';
        ndg1.Cognome='Galli';
        ndg1.Nome='Giacomo';
        ndg1.Denominazione='Test';
        portafogliazioneOnlineInput.ndgList.add(ndg1);
        REST_PortafogliazioneOnline.NDG_Input ndg2= new REST_PortafogliazioneOnline.NDG_Input();
        ndg2.NaturaGiuridica='CO';
        ndg2.NDG='30011456';
        ndg2.Denominazione='Test2';
        portafogliazioneOnlineInput.ndgList.add(ndg2);
        REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput);
        Test.stopTest();
        System.assertEquals(true, (REST_PortafogliazioneOnline.processRiportafogliazioneOnline(portafogliazioneOnlineInput)) !=null);
    }
}