@IsTest
public class REST_GetRecuperoPortafoglioTest {
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
        insert area;


        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        filiale.PTF_BranchTypology__c='A';
        filiale.PTF_Banca__c=banca.Id;
        filiale.PTF_DirezioneRegionale__c=dr.Id;
        filiale.PTF_Area__c= area.Id;
        Account filiale2 = AllDataFactory.getAccount('02', 'FilialeDiRelazione');
        filiale2.PTF_Banca__c=banca.Id;
        filiale2.PTF_DirezioneRegionale__c=dr.Id;
        filiale2.PTF_Area__c= area.Id;
        filiale2.PTF_BranchTypology__c='A';
        insert new List<Account>{filiale, filiale2};

        RoleTypology__c ruolo = new RoleTypology__c();
        ruolo.Name = 'Titolare';
        insert ruolo;

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
        
        Profile profile = [SELECT id FROM Profile WHERE Name =: Label.System_Administrator LIMIT 1];
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
        insert new List<Wallet__c>{microPortafoglio, microPortafoglio2};

        Assignment__c primarioAssignment2 = AllDataFactory.getAssignment('Primario', microPortafoglio2.Id, contact2.Id);
        Assignment__c primarioAssignment = AllDataFactory.getAssignment('Primario', microPortafoglio.Id, contact.Id);
        Assignment__c backupAssignment = AllDataFactory.getAssignment('Backup', microPortafoglio.Id, contact3.Id);
        insert new List<Assignment__c>{primarioAssignment2, primarioAssignment, backupAssignment};

        Account ndg = AllDataFactory.getAccount('NDG1','PersonAccount');
        ndg.PTF_Portafoglio__c=microPortafoglio.Id;
        Account ndg2 = AllDataFactory.getAccount('NDG2','Cointestazione');
        ndg2.PTF_Portafoglio__c=microPortafoglio.Id;
        insert new List<Account>{ndg2, ndg};
        }
        
    }

    @IsTest
    static void testOk(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest//v1/getrecuperoportafoglio/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto recuperoPortafoglioInput = new REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto();
        recuperoPortafoglioInput.pAbi ='1234';
        String filialeId= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c FROM Account WHERE Name='Account01' ][0].Id;
        recuperoPortafoglioInput.pCodPortafoglio=[SELECT Id, PTF_Codice_Portafoglio__c FROM Wallet__c WHERE PTF_Filiale__c=:filialeId ][0].PTF_Codice_Portafoglio__c;
        recuperoPortafoglioInput.pNomEmailAddr='01';
        REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput);
        Test.stopTest();
        System.assertEquals(true,(REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput)) !=null);

    }
    @IsTest
    static void testMissingParameter(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest//v1/getrecuperoportafoglio/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto recuperoPortafoglioInput = new REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto();
        REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput);
        Test.stopTest();
        System.assertEquals(true, (REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput)) !=null);
    }

    @IsTest
    static void testMissingConsulente(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest//v1/getrecuperoportafoglio/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto recuperoPortafoglioInput = new REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto();
        recuperoPortafoglioInput.pAbi ='1234';
        String filialeId= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c FROM Account WHERE Name='Account01' ][0].Id;
        recuperoPortafoglioInput.pCodPortafoglio=[SELECT Id, PTF_Codice_Portafoglio__c FROM Wallet__c WHERE PTF_Filiale__c=:filialeId ][0].PTF_Codice_Portafoglio__c;
        recuperoPortafoglioInput.pNomEmailAddr='04';
        REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput);
        Test.stopTest();
        System.assertEquals(true, (REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput)) !=null);
    }

    @IsTest
    static void testMissingNDG(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest//v1/getrecuperoportafoglio/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto recuperoPortafoglioInput = new REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto();
        recuperoPortafoglioInput.pAbi ='1234';
        String filialeId= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c FROM Account WHERE Name='Account02' ][0].Id;
        recuperoPortafoglioInput.pCodPortafoglio=[SELECT Id, PTF_Codice_Portafoglio__c FROM Wallet__c WHERE PTF_Filiale__c=:filialeId ][0].PTF_Codice_Portafoglio__c;
        recuperoPortafoglioInput.pNomEmailAddr='02';
        REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput);
        Test.stopTest();
        system.assertEquals(true, (REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput)) !=null);
    }

    @IsTest
    static void testWithoutPortafoglio(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest//v1/getrecuperoportafoglio/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto recuperoPortafoglioInput = new REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto();
        recuperoPortafoglioInput.pAbi ='1234';
        recuperoPortafoglioInput.pNomEmailAddr='01';
        REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput);
        Test.stopTest();
        System.assertEquals(true, (REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput)) != null);
    }
    @IsTest
    static void testBackup(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest//v1/getrecuperoportafoglio/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto recuperoPortafoglioInput = new REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto();
        recuperoPortafoglioInput.pAbi ='1234';
        String filialeId= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c FROM Account WHERE Name='Account01' ][0].Id;
        recuperoPortafoglioInput.pCodPortafoglio=[SELECT Id, PTF_Codice_Portafoglio__c FROM Wallet__c WHERE PTF_Filiale__c=:filialeId ][0].PTF_Codice_Portafoglio__c;
        recuperoPortafoglioInput.pNomEmailAddr='03';
        recuperoPortafoglioInput.pFlgBackup=true;
        REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput);
        Test.stopTest();
        System.assertEquals(true,(REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput)) !=null);
    }
    @IsTest
    static void testBackupWithoutPortafoglio(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest//v1/getrecuperoportafoglio/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto recuperoPortafoglioInput = new REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto();
        recuperoPortafoglioInput.pAbi ='1234';
        recuperoPortafoglioInput.pNomEmailAddr='03';
        recuperoPortafoglioInput.pFlgBackup=true;
        REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput);
        Test.stopTest();
        System.assertEquals(true, (REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput)) !=null);
    }
    @IsTest
    static void testMissingABI(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest//v1/getrecuperoportafoglio/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto recuperoPortafoglioInput = new REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto();
        recuperoPortafoglioInput.pAbi ='123456';
        recuperoPortafoglioInput.pNomEmailAddr='01';
        recuperoPortafoglioInput.pFlgBackup=true;
        REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput);
        Test.stopTest();
        System.assertEquals(true, (REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput)) !=null);
    }
    @IsTest
    static void testMissingFiliale(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest//v1/getrecuperoportafoglio/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto recuperoPortafoglioInput = new REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto();
        recuperoPortafoglioInput.pAbi ='12345';
        recuperoPortafoglioInput.pNomEmailAddr='01';
        recuperoPortafoglioInput.pFlgBackup=true;
        REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput);
        Test.stopTest();
        System.assertEquals(true, (REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput)) !=null);
    }

    @IsTest
    static void testGenericException(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest//v1/getrecuperoportafoglio/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(null);
        Test.stopTest();
        System.assertEquals(true, (REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(null)) !=null);
    }
    @IsTest
    static void testMissingAssignment(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest//v1/getrecuperoportafoglio/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto recuperoPortafoglioInput = new REST_GetRecuperoPortafoglio.RecuperoPortafoglioInputDto();
        recuperoPortafoglioInput.pAbi ='1234';
        String filialeId= [SELECT Id, Parent.Parent.Parent.FinServ__BankNumber__c FROM Account WHERE Name='Account01' ][0].Id;
        recuperoPortafoglioInput.pCodPortafoglio=[SELECT Id, PTF_Codice_Portafoglio__c FROM Wallet__c WHERE PTF_Filiale__c=:filialeId ][0].PTF_Codice_Portafoglio__c;
        recuperoPortafoglioInput.pNomEmailAddr='01';
        recuperoPortafoglioInput.pFlgBackup=true;
        REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput);
        Test.stopTest();
        System.assertEquals(true, (REST_GetRecuperoPortafoglio.getRecuperoPortafoglio(recuperoPortafoglioInput)) !=null);
    }
}