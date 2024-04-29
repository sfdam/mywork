@istest
public class CRM_AttributiCampagneTableControllerTest {
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
        insert filiale;

        Wallet__c microPortafoglioCORPORATE = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'CORPORATE');
        insert microPortafoglioCORPORATE;

        Account business = AllDataFactory.getAccount('05', 'IndustriesBusiness');
        business.PTF_Portafoglio__c = microPortafoglioCORPORATE.Id;
        business.PTF_Filiale__c = filiale.Id;
        business.CRM_Filiale__c = filiale.Id;
        business.CRM_NDG__c = 'Account05';
        insert business;

        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];

        User titolare = AllDataFactory.getUser('14', profile.Id, 'CORPORATE');
        titolare.FederationIdentifier = '14';
        titolare.Profilo__c = 'NEC_F.1';
        
        insert titolare;

        String recordTypeTopDownMono = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Monostep').getRecordTypeId();
        Campaign campaign = AllDataFactory.getCampaign('01', titolare.Id, recordTypeTopDownMono);
        campaign.CRM_NomeAttributo1__c =null;
        campaign.CRM_NomeAttributo2__c =null;
        insert campaign;

        System.runAs(titolare){
            
            Contact contact = AllDataFactory.getContact('01', titolare.Id, filiale.id);
            contact.PTF_ProfiloLDAP__c='NEC_F.1';
            Contact referente = AllDataFactory.getContact('02', null, business.id);
            insert new List<Contact>{contact, referente};
            
            CampaignMember campaignMember = AllDataFactory.getCampaignMember('01', campaign.Id, referente.Id, titolare.Id);
            insert CampaignMember;
        }
    }

    @IsTest
    public static void testGetCampaignmember(){

        User titolare = [SELECT Id FROM User WHERE FederationIdentifier = '14' LIMIT 1];
        Campaign campaign = [SELECT Id FROM Campaign LIMIT 1];
        System.runAs(titolare){
        test.startTest();
            CRM_AttributiCampagneTableController.WrapperObj response = CRM_AttributiCampagneTableController.getCampaignMember(null);
            response = CRM_AttributiCampagneTableController.getCampaignMember(campaign.Id);
        
        test.stopTest();
            System.assertEquals(true, response != null);
        }
    }
}