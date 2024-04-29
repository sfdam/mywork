@IsTest
public class AssegnaAzioniControllerTest {
    
    @TestSetup
    static void makeData(){

        Account banca = AllDataFactory.getAccount('01', 'Banca');
        banca.FinServ__BankNumber__c = '05387';
        insert banca;
        Account dir = AllDataFactory.getAccount('02', 'DirezioneRegionale');
        dir.FinServ__BankNumber__c = '05387';
        dir.parentId = banca.Id;
        dir.PTF_Banca__c = banca.Id;
        insert dir;
        Account area = AllDataFactory.getAccount('03', 'Area');
        area.FinServ__BankNumber__c = '05387';
        area.parentId = dir.Id;
        area.PTF_Banca__c = banca.Id;
        area.PTF_DirezioneRegionale__c = dir.Id;
        insert area;
        Account filiale = AllDataFactory.getAccount('04', 'FilialeDiRelazione');
        filiale.FinServ__BankNumber__c = '05387';
        filiale.parentId = area.Id;
        filiale.PTF_BranchTypology__c = 'A';
        filiale.PTF_Banca__c = banca.Id;
        filiale.PTF_DirezioneRegionale__c = dir.Id;
        filiale.PTF_Area__c = area.Id;
        filiale.PTF_IdCED__c = '0004';
        insert filiale;

        Wallet__c microPortafoglioCORPORATE = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'CORPORATE');
        insert microPortafoglioCORPORATE;

        Account business = AllDataFactory.getAccount('05', 'IndustriesBusiness');
        business.PTF_Portafoglio__c = microPortafoglioCORPORATE.Id;
        business.PTF_Filiale__c = filiale.Id;
        business.CRM_NDG__c = 'Account05';
        insert business;

        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];

        User titolare = AllDataFactory.getUser('14', profile.Id, 'CORPORATE');
        titolare.FederationIdentifier = '14';
        titolare.Profilo__c = 'NEC_F.1';

        User vicario = AllDataFactory.getUser('13', profile.Id, 'CORPORATE');
        vicario.FederationIdentifier = '13';
        vicario.Profilo__c = 'NEC_F.1';
        insert new List<User>{titolare, vicario};

        String recordTypeTopDownMono = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Monostep').getRecordTypeId();
        Campaign campaign = AllDataFactory.getCampaign('01', titolare.Id, recordTypeTopDownMono);
        campaign.CRM_NomeAttributo1__c =null;
        campaign.CRM_NomeAttributo2__c =null;
        insert campaign;
        
        String recordTypeTriggerBased = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Trigger_Monostep').getRecordTypeId();
        Campaign eventTB = AllDataFactory.getCampaign('01', titolare.Id, recordTypeTriggerBased);
        eventTB.CRM_NomeAttributo1__c =null;
        eventTB.CRM_NomeAttributo2__c =null;
        insert eventTB;

        Opportunity opp = AllDataFactory.getOpportunity('01', vicario.Id, Date.today().addDays(30));
        insert opp;

        System.runAs(titolare){
            
            Contact contact = AllDataFactory.getContact('01', titolare.Id, filiale.id);
            Contact referente = AllDataFactory.getContact('02', null, business.id);
            insert new List<Contact>{contact, referente};
            
            CampaignMember campaignMember = AllDataFactory.getCampaignMember('01', campaign.Id, referente.Id, titolare.Id);
            insert CampaignMember;
            
            CampaignMember campaignMemberEvent = AllDataFactory.getCampaignMember('01', eventTB.Id, referente.Id, titolare.Id);
            insert campaignMemberEvent;
        }
    }

    @IsTest
    public static void testGetContact(){

        User titolare = [SELECT Id FROM User WHERE FederationIdentifier = '14' LIMIT 1];
        
        test.startTest();
        System.runAs(titolare){
            AssegnaAzioniController.WrapperObj response = AssegnaAzioniController.getContact();
        }
        test.stopTest();
    }

    @IsTest
    public static void testGetCampaignMember(){

        User titolare = [SELECT Id FROM User WHERE FederationIdentifier = '14' LIMIT 1];
        
        test.startTest();
        System.runAs(titolare){
            AssegnaAzioniController.WrapperObj response = AssegnaAzioniController.getCampaignMember();
        }
        test.stopTest();
    }

    @IsTest
    public static void testGetEventMember(){

        User titolare = [SELECT Id FROM User WHERE FederationIdentifier = '14' LIMIT 1];
        
        test.startTest();
        System.runAs(titolare){
            Map<String,Object> response = AssegnaAzioniController.getEventMember();
        }
        test.stopTest();
    }

    @IsTest
    public static void testSetCampaignMember(){

        User titolare = [SELECT Id FROM User WHERE FederationIdentifier = '14' LIMIT 1];
        User vicario = [SELECT Id FROM User WHERE FederationIdentifier = '13' LIMIT 1];
        CampaignMember member = [SELECT ID FROM CampaignMember WHERE Campaign.RecordType.DeveloperName ='Top_Down_Monostep' LIMIT 1 ];
        
        test.startTest();
        System.runAs(titolare){
            Boolean response = AssegnaAzioniController.setCampaignMember(new List<String>{titolare.Id}, new List<String>{member.Id},100);
        }
        test.stopTest();
    }

    @IsTest
    public static void testGetOppsMember(){

        User titolare = [SELECT Id FROM User WHERE FederationIdentifier = '14' LIMIT 1];
        
        test.startTest();
        System.runAs(titolare){
            Map<String,Object> response = AssegnaAzioniController.getOppsMember('0004');
        }
        test.stopTest();
    }

    @IsTest
    public static void testSetOppsMember(){

        User titolare = [SELECT Id FROM User WHERE FederationIdentifier = '14' LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        test.startTest();
        System.runAs(titolare){
            Boolean response = AssegnaAzioniController.setOpportunity(new List<String>{titolare.Id}, new List<String>{opp.Id});
        }
        test.stopTest();
    }

    @IsTest
    public static void testReassignItem(){

        User titolare = [SELECT Id FROM User WHERE FederationIdentifier = '14' LIMIT 1];
        User vicario = [SELECT Id FROM User WHERE FederationIdentifier = '13' LIMIT 1];

        CampaignMember member = [SELECT ID FROM CampaignMember WHERE Campaign.RecordType.DeveloperName ='Top_Down_Monostep' LIMIT 1];
        CampaignMember memberEvent = [SELECT ID FROM CampaignMember WHERE Campaign.RecordType.DeveloperName ='Trigger_Monostep' LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        
        test.startTest();
        System.runAs(titolare){
            Boolean response = AssegnaAzioniController.reassignItem(new List<String>{memberEvent.Id}, new List<String>{member.Id}, new List<String>{opp.Id}, titolare.Id,100);
        }
        test.stopTest();
    }
     @IsTest
    public static void futureMethodTest(){

        User titolare = [SELECT Id FROM User WHERE FederationIdentifier = '14' LIMIT 1];
        User vicario = [SELECT Id FROM User WHERE FederationIdentifier = '13' LIMIT 1];

        CampaignMember member = [SELECT ID FROM CampaignMember WHERE Campaign.RecordType.DeveloperName ='Top_Down_Monostep' LIMIT 1];
        CampaignMember memberEvent = [SELECT ID FROM CampaignMember WHERE Campaign.RecordType.DeveloperName ='Trigger_Monostep' LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        
        test.startTest();
        System.runAs(titolare){
             AssegnaAzioniController.futureMethod(new List<String>{titolare.Id}, new List<String>{member.Id});
        }
        test.stopTest();
    }
    
}