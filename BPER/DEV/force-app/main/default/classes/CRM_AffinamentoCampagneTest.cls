@istest
public class CRM_AffinamentoCampagneTest {
    @TestSetup
    static void makeData(){
	Funzionalita__c funzionalita = new Funzionalita__c();
        funzionalita.Disable_Trigger__c = true;
        funzionalita.Disable_CampaignMemberTrigger__c = true;
        insert funzionalita;

        Endpoint__c endPoint = new Endpoint__c();
        endPoint.Name = 'salvaEsitazioneAzioniNec';
        endPoint.Method__c = 'POST';
        endPoint.Timeout__c = 120000;
        endPoint.Endpoint__c = 'Test';
        insert endPoint;
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
        campaign.CRM_SottotipologiaCampagna__c ='Campagna';
        campaign.CRM_TipologiaCampagna__c = 'Commerciale';
        insert campaign;

        System.runAs(titolare){
            
            Contact contact = AllDataFactory.getContact('01', titolare.Id, filiale.id);
            Contact referente = AllDataFactory.getContact('02', null, business.id);
            insert new List<Contact>{contact, referente};
            
            CampaignMember campaignMember = AllDataFactory.getCampaignMember('01', campaign.Id, referente.Id, titolare.Id);
            insert CampaignMember;
            
            campaignMember__c campaignMemberC = new campaignMember__c();
            campaignMemberC.Status__c = 'Inviato';
            campaignMemberC.Campaign__c = campaign.Id;
            campaignMemberC.PTF_Portafoglio__c = microPortafoglioCORPORATE.id;
            insert campaignMemberC;
            
            campaignMember__c campaignMemberC1 = new campaignMember__c();
            campaignMemberC1.Status__c = 'Eliminato';
            campaignMemberC1.Campaign__c = campaign.Id;
            campaignMemberC1.PTF_Portafoglio__c = microPortafoglioCORPORATE.id;
            insert campaignMemberC1;
        }
    }

    @IsTest
    public static void testGetCampaignmember(){

        User titolare = [SELECT Id FROM User WHERE FederationIdentifier = '14' LIMIT 1];
        Campaign campaign = [SELECT Id FROM Campaign LIMIT 1];
        System.runAs(titolare){
        test.startTest();
            CRM_AffinamentoCampagne.WrapperObj response = CRM_AffinamentoCampagne.getCampaignMember(campaign.Id);
        
        test.stopTest();
        System.assertEquals(True, response.campaignMemberList != null);
        System.assertEquals(True, response.campaignMemberMap != null) ;

        }
   }

    @IsTest
    public static void testSetCampaignmember(){

        User titolare = [SELECT Id FROM User WHERE FederationIdentifier = '14' LIMIT 1];
        CampaignMember campaignMember = [SELECT Id FROM CampaignMember LIMIT 1];
        
        System.runAs(titolare){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
            Boolean response = CRM_AffinamentoCampagne.setCampaignMember(new List<String>{campaignMember.Id}, 'Numerosità elevata', 'Nota');
        
        test.stopTest();
        System.assertEquals(False, response) ;
        }
    }
    
    @IsTest
    public static void testSetCampaignmemberAff(){

        User titolare = [SELECT Id FROM User WHERE FederationIdentifier = '14' LIMIT 1];
        Campaign campaign = [SELECT Id FROM Campaign LIMIT 1];
        
        System.runAs(titolare){
        test.startTest();
              CRM_AffinamentoCampagne.WrapperObj response = CRM_AffinamentoCampagne.getCampaignMemberAff(campaign.Id);
        test.stopTest();
        System.assertEquals(True, response.campaignMemberList != null);
        System.assertEquals(True, response.campaignMemberMap != null) ;
        }
    }
}