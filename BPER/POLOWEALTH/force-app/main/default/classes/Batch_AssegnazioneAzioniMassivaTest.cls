@isTest
public class Batch_AssegnazioneAzioniMassivaTest {
    
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
        business.CRM_NDG__c = 'Account05';
        insert business;

        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];

        User titolare = AllDataFactory.getUser('14', profile.Id, 'CORPORATE');
        titolare.FederationIdentifier = '14';
        titolare.Profilo__c = 'NEC_F.1';
        insert titolare;

        String recordTypeTopDownMono = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Monostep').getRecordTypeId();
        Campaign campaign = AllDataFactory.getCampaign('01', titolare.Id, recordTypeTopDownMono);
        campaign.CRM_PrevistoAffinamento__c =true;
        campaign.CRM_OwnerSystem__c = 'Siebel';
        campaign.CRM_SottotipologiaCampagna__c='Campagna';
        campaign.CRM_DataFineAffinamento__c = Date.newInstance(2022, 11, 30);
        campaign.CRM_NomeAttributo1__c =null;
        campaign.CRM_NomeAttributo2__c =null;
        
        insert campaign;

        System.runAs(titolare){
            
            Contact contact = AllDataFactory.getContact('01', titolare.Id, filiale.id);
            Contact referente = AllDataFactory.getContact('02', null, business.id);
            insert new List<Contact>{contact, referente};
            
            CampaignMember campaignMember = AllDataFactory.getCampaignMember('01', campaign.Id, referente.Id, titolare.Id);
            insert CampaignMember;
        }
    }
    
    @IsTest
    public static void testSetRollback(){

        
        CampaignMember campaignMember = [SELECT Id FROM CampaignMember LIMIT 1];
        
        test.startTest();
       
        Boolean response = CRM_AffinamentoRollbackActionCtrl.setRollback(campaignMember.id);
        
        test.stopTest();
    }
    
    @IsTest
    public static void testSetRollbackKO(){

        
        CampaignMember campaignMember = [SELECT Id, campaignId FROM CampaignMember LIMIT 1];
        Campaign camp = new Campaign();
        camp.id =campaignMember.campaignId;
        camp.CRM_PrevistoAffinamento__c = false;
        camp.CRM_DataFineAffinamento__c = null;
        update camp;
        test.startTest();
        try{
        Boolean response = CRM_AffinamentoRollbackActionCtrl.setRollback(campaignMember.id);
        }catch(Exception ex){
            system.debug('ex: '+ex.getMessage());
        }
        test.stopTest();
    }
    
        @isTest
    static void unitTest1() {
		List<CampaignMember> campaignMember = new List<CampaignMember>([SELECT Id, campaignId, createdBy.Id FROM CampaignMember LIMIT 1]);
        
        
        Test.startTest();
        Batch_AssegnazioneAzioniMassiva bam = new Batch_AssegnazioneAzioniMassiva();
        bam.idCmList= new List<String>{campaignMember.get(0).id};
        bam.userId = campaignMember.get(0).createdBy.Id;
        Database.executeBatch(bam,200);
        Test.stopTest();
    }

}