@IsTest
public with sharing class OnAssignmentTriggerHandlerTest {
    
    @TestSetup
    public static void setup(){
        
        Profile profile = [SELECT id FROM Profile WHERE Name =: Label.System_Administrator LIMIT 1];
        User user = AllDataFactory.getUser('01', profile.Id, 'Couco');
        User user2 = AllDataFactory.getUser('02', profile.Id, 'Couco');
        User user3 = AllDataFactory.getUser('03', profile.Id, 'Couco');
        insert new List<User>{user, user2, user3};
            System.runAs(user3){
                Account banca = AllDataFactory.getAccount('01', 'Banca');
        Account direzioneRegionale = AllDataFactory.getAccount('02', 'DirezioneRegionale');
        Account area = AllDataFactory.getAccount('03', 'Area');
        Account filiale = AllDataFactory.getAccount('04', 'FilialeDiRelazione');
        filiale.PTF_BranchTypology__c = 'A';
        insert new List<Account>{banca, direzioneRegionale, area, filiale};

        RoleTypology__c ruolo = new RoleTypology__c();
        ruolo.Name = 'TestRuolo';
        insert ruolo;

        ServiceModel__c modelloDiServizio = new ServiceModel__c();
        modelloDiServizio.Name = 'Couco';
        insert modelloDiServizio;

        RoleMDS__c ruoloMDS = new RoleMDS__c();
        ruoloMDS.PTF_BranchTypology__c = 'A';
        ruoloMDS.PTF_RoleTypology__c = ruolo.Id;
        ruoloMDS.PTF_ServiceModel__c = modelloDiServizio.Id;
        ruoloMDS.PTF_StartDate__c = Date.today().addDays(-10);
        ruoloMDS.PTF_EndDate__c = Date.today().addDays(10);
        insert ruoloMDS;

        Contact contact = AllDataFactory.getContact('01', user.Id, filiale.Id);
        contact.PTF_TipologiaRuolo__c = ruolo.Id;
        Contact contact2 = AllDataFactory.getContact('02', user2.Id, filiale.Id);
        contact2.PTF_TipologiaRuolo__c = ruolo.Id;
        Contact contact3 = AllDataFactory.getContact('03', user3.Id, filiale.Id);
        contact3.PTF_TipologiaRuolo__c = ruolo.Id;
        insert new List<Contact>{contact, contact2, contact3};

        Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet', filiale.Id, 'Couco');
        insert microPortafoglio;

        Wallet__c microPortafoglio2 = AllDataFactory.getWallet('MicroWallet', '', 'Couco');
        insert microPortafoglio2;

        // Relazione Di Cointestazione
        Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
        personAccount.PTF_Portafoglio__c = microPortafoglio.Id;
        personAccount.PTF_Filiale__c = filiale.Id;
        insert personAccount;

        
            }
        
    }
    
    @IsTest
    static void testInsert(){
        
        Wallet__c microPortafoglio = [SELECT ID FROM Wallet__c WHERE RecordType.DeveloperName = 'MicroWallet' and PTF_Filiale__c != null];
        List<Contact> contacts = [SELECT id FROM Contact LIMIT 2];
        Assignment__c backupAssignment = AllDataFactory.getAssignment('Backup', microPortafoglio.Id, contacts[0].Id);
        Assignment__c primarioAssignment = AllDataFactory.getAssignment('Primario', microPortafoglio.Id, contacts[1].Id);
        Test.startTest();
        insert new List<Assignment__c>{backupAssignment, primarioAssignment};
        Test.stopTest();
    }
    @IsTest
    static void testInsert2(){
        
        Wallet__c microPortafoglio = [SELECT ID FROM Wallet__c WHERE RecordType.DeveloperName = 'MicroWallet' and PTF_Filiale__c = null];
        List<Contact> contacts = [SELECT id FROM Contact LIMIT 2];
        Assignment__c backupAssignment = AllDataFactory.getAssignment('Backup', microPortafoglio.Id, contacts[0].Id);
        Assignment__c primarioAssignment = AllDataFactory.getAssignment('Primario', microPortafoglio.Id, contacts[1].Id);
        Test.startTest();
        insert new List<Assignment__c>{backupAssignment, primarioAssignment};
        Test.stopTest();
    }

    @IsTest
    static void testDelete(){
        
        Wallet__c microPortafoglio = [SELECT ID FROM Wallet__c WHERE RecordType.DeveloperName = 'MicroWallet' and PTF_Filiale__c != null];
        List<Contact> contacts = [SELECT id FROM Contact LIMIT 2];
        Assignment__c backupAssignment = AllDataFactory.getAssignment('Backup', microPortafoglio.Id, contacts[0].Id);
        Assignment__c primarioAssignment = AllDataFactory.getAssignment('Primario', microPortafoglio.Id, contacts[1].Id);
        insert new List<Assignment__c>{backupAssignment, primarioAssignment};

        List<Assignment__c> assignmentsToDelete = [SELECT Id, PTF_EndDate__c, PTF_EndDate_DT__c FROM Assignment__c];
        for(Assignment__c assignment : assignmentsToDelete){

            assignment.PTF_EndDate__c = Date.today();
            assignment.PTF_EndDate_DT__c = Datetime.now();
        }

        update assignmentsToDelete;
    }
    @IsTest
    static void tesInvokeBatch(){
        Wallet__c microPortafoglio = [SELECT ID FROM Wallet__c WHERE RecordType.DeveloperName = 'MicroWallet' and PTF_Filiale__c != null];
        List<Contact> contacts = [SELECT id FROM Contact LIMIT 2];
        Assignment__c primarioAssignment = AllDataFactory.getAssignment('Primario', microPortafoglio.Id, contacts[1].Id);
        insert primarioAssignment;
        Set<Id> idAssignment = new Set<Id>();
        Id assId = [SELECT ID FROM Assignment__c LIMIT 1].Id;
        idAssignment.add(assId);


        Id primarioAssignmentId = [SELECT ID FROM Assignment__c LIMIT 1 ].Id;
        OnAssignmentTriggerHandler.invokeBatch('Batch_OnAssignmentTriggerHandler',new Map<String,Object>{'eventType'=> 'onAfterUpdate','idAssignment'=>idAssignment});
    }
}