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
        
        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];
		
        User titolare = AllDataFactory.getUser('14', profile.Id, 'CORPORATE');
        titolare.FederationIdentifier = '14';
        titolare.Profilo__c = 'NEC_F.1';
        insert titolare;
        
        User refPrivate = AllDataFactory.getUser('15', profile.Id, 'PRIVATE');
        refPrivate.FederationIdentifier = '15';
        refPrivate.PTF_RuoloLDAP__c ='069';
        refPrivate.Profilo__c = 'NEC_F.1';
        
        insert refPrivate;
        Wallet__c microPortafoglioCORPORATE;
		System.runAs(titolare){
            microPortafoglioCORPORATE = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'CORPORATE');
            insert microPortafoglioCORPORATE;
 		}
        Account business = AllDataFactory.getAccount('05', 'IndustriesBusiness');
        business.PTF_Portafoglio__c = microPortafoglioCORPORATE.Id;
        business.PTF_Filiale__c = filiale.Id;
        business.CRM_Filiale__c = filiale.Id;
        business.CRM_NDG__c = 'Account05';
        business.ModelloDiServizio__c = 'Key Client Privati';
        business.PTF_IdCED__c = '21025';
        insert business;
            
        String recordTypeTopDownMono  = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Monostep').getRecordTypeId();
        Campaign campaign = AllDataFactory.getCampaign('01', titolare.Id, recordTypeTopDownMono); 
        campaign.CRM_NomeAttributo1__c =null;
        campaign.CRM_NomeAttributo2__c =null;
        //campaign.CRM_TipologiaAzione__c = 'Dinamica'; FORMULA : IF( CONTAINS(RecordType.Name, "Trigger"), "Evento trigger based",
		//													IF(ISPICKVAL(CRM_SottotipologiaCampagna__c, "Campagna"), "Tradizionale", "Dinamica"))
		campaign.CRM_SottotipologiaCampagna__c = 'Evento';
        Campaign campaign02 = AllDataFactory.getCampaign('02', titolare.Id, recordTypeTopDownMono);
        campaign02.CRM_NomeAttributo1__c =null;
        campaign02.CRM_NomeAttributo2__c =null;
		campaign02.CRM_SottotipologiaCampagna__c = 'Campagna';
        insert new List<Campaign> { campaign, campaign02 };
        
        System.runAs(titolare) {
            
            Contact contact = AllDataFactory.getContact('01', titolare.Id, filiale.id);
            contact.PTF_ProfiloLDAP__c='NEC_F.1';
            Contact referente = AllDataFactory.getContact('02', null, business.id);
            insert new List<Contact>{contact, referente};
            
            CampaignMember campaignMember = AllDataFactory.getCampaignMember('01', campaign.Id, referente.Id, titolare.Id);
            campaignMember.CRM_Portafoglio__c = microPortafoglioCORPORATE.Id;
            insert CampaignMember;
            
            CampaignMember__c cmg = New CampaignMember__c(); // Oggetto selezionato dal controller
            cmg.Campaign__c = campaign.Id;
            cmg.PTF_Portafoglio__c = microPortafoglioCORPORATE.Id;
            cmg.CRM_Account__c = business.id;
            cmg.CRM_Autore__c = 'testAutore';
            cmg.Data_Uscita__c = Datetime.now();
            cmg.Status__c = 'Creato';
            CampaignMember__c cmg02 = New CampaignMember__c();
            cmg02.Campaign__c = campaign02.Id;
            cmg02.PTF_Portafoglio__c = microPortafoglioCORPORATE.Id;
            cmg02.CRM_Account__c = business.id;
            cmg02.CRM_Autore__c = 'testAutore01';
            cmg02.Data_Uscita__c = Datetime.now();
            cmg02.Status__c = 'Eliminato';
            insert new List<CampaignMember__c>{ cmg, cmg02 };
        }
    }

    @IsTest
    public static void testGetCampaignmember(){

        User titolare 		 = [SELECT Id FROM User WHERE FederationIdentifier = '14' LIMIT 1];
        Campaign campaign    = [SELECT Id FROM Campaign WHERE Name = 'Campaign01' LIMIT 1];
        Campaign notCampaign = [SELECT Id FROM Campaign WHERE Name = 'Campaign02' LIMIT 1];
        System.runAs(titolare) {
        test.startTest();
            CRM_AttributiCampagneTableController.WrapperObj response = CRM_AttributiCampagneTableController.getCampaignMember(null);
            response = CRM_AttributiCampagneTableController.getCampaignMember(campaign.Id);
        	response = CRM_AttributiCampagneTableController.getCampaignMember(notCampaign.Id);
        
        test.stopTest();
            System.assertEquals(true, response != null);
        }
    }
    
    @IsTest
    public static void testGetCampaignmember2(){

        User gestorePrivate = [SELECT Id FROM User WHERE FederationIdentifier = '15' LIMIT 1];
        Campaign campaign = [SELECT Id FROM Campaign WHERE Name = 'Campaign01' LIMIT 1];
        System.runAs(gestorePrivate){
        test.startTest();
			CRM_AttributiCampagneTableController.WrapperObj response = CRM_AttributiCampagneTableController.getCampaignMember(campaign.Id);
        
        test.stopTest();
            System.assertEquals(true, response != null);
        }
    }
}