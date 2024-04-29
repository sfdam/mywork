@IsTest
public with sharing class OnNDGManagementMemberTriggerHandlerTest {
    
    @TestSetup
    public static void setup(){
        Funzionalita__c x= new Funzionalita__c();
        x.Disable_Trigger__c=true;
        insert x;
        Profile profile = [SELECT id FROM Profile WHERE Name=: Label.System_Administrator LIMIT 1];
        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        User user2 = AllDataFactory.getUser('02', profile.Id, 'CORPORATE');
        User user3 = AllDataFactory.getUser('03', profile.Id, 'CORPORATE');
        insert new List<User>{user, user2, user3};
            System.runAs(user){
                Account banca = AllDataFactory.getAccount('01', 'Banca');
                Account direzioneRegionale = AllDataFactory.getAccount('02', 'DirezioneRegionale');
                Account area = AllDataFactory.getAccount('03', 'Area');
                Account filiale = AllDataFactory.getAccount('04', 'FilialeDiRelazione');
                filiale.PTF_BranchTypology__c = 'A';
                insert new List<Account>{banca, direzioneRegionale, area, filiale}
        ;

        Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet', filiale.Id, 'CORPORATE');
        insert microPortafoglio;
        
        Account personAccount = AllDataFactory.getAccount('05', 'PersonAccount');
        personAccount.PTF_Filiale__c = filiale.Id;
        personAccount.PTF_Portafoglio__c = microPortafoglio.Id;
        personAccount.PTF_StatoCRM__c='ATT';
        insert personAccount;

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

        Contact contact = AllDataFactory.getContact('01', user.Id, filiale.Id);
        contact.PTF_TipologiaRuolo__c = ruolo.Id;
        Contact contact2 = AllDataFactory.getContact('02', user2.Id, filiale.Id);
        contact2.PTF_TipologiaRuolo__c = ruolo.Id;
        Contact contact3 = AllDataFactory.getContact('03', user3.Id, filiale.Id);
        contact3.PTF_TipologiaRuolo__c = ruolo.Id;
        insert new List<Contact>{contact, contact2, contact3};

        Assignment__c backupAssignment = AllDataFactory.getAssignment('Backup', microPortafoglio.Id, contact.Id);
        Assignment__c primarioAssignment = AllDataFactory.getAssignment('Primario', microPortafoglio.Id, contact2.Id);
        insert new List<Assignment__c>{backupAssignment, primarioAssignment};
            }
        
    }

    @IsTest
    public static void testCreateDoppioPresidio(){

        User user = [SELECT id FROM User WHERE LastName = 'Test01' LIMIT 1];
        System.runAs(user)
        {

            Account personAccount = [SELECT id FROM Account WHERE LastName = 'LastName05' LIMIT 1];
            Map<String, SObject> doppiPresidiDaChiudere = SV_Utilities.keyBy([SELECT  Id,
                                PTF_EndDate__c
                        FROM NDGManagementMember__c], 'Id');
            List<NDGManagementMember__c> responseDelete = CreateDoppioPresidioController.deleteDoppioPresidio(personAccount.Id, new List<String>(doppiPresidiDaChiudere.keySet()));
            NDGManagementMember__c response = CreateDoppioPresidioController.createDoppioPresidio(personAccount.Id);
            NDGManagementMember__c listeNDGMemb=[SELECT id,PTF_HistoryRole__c,PTF_HistoryRoleCode__c
                                                        FROM NDGManagementMember__c where PTF_NDG__c =:personAccount.id LIMIT 1];

            Contact contacts =[SELECT id,PTF_TipologiaRuolo__c, PTF_Ruolo__c FROM Contact WHERE LastName='LastName02' LIMIT 1];

            System.assertEquals(listeNDGMemb.PTF_HistoryRole__c, 'Titolare');
            System.assertEquals(listeNDGMemb.PTF_HistoryRoleCode__c, contacts.PTF_Ruolo__c);
        }
    }
}