@isTest
public class QueueableUtilityTest {
    
        @TestSetup
    static void makeData(){
    Account banca= AllDataFactory.getAccount('Banca','Banca');
        banca.FinServ__BankNumber__c='1234';
        banca.CRM_NDG__c = '4568';
        //banca.NDW_ExternalId__c = '1234_4568';

        insert banca;

        Account dir = AllDataFactory.getAccount('09', 'DirezioneRegionale');
        // dir.PTF_ABICED__c = '05387';
        dir.parentId = banca.Id;
        insert dir;

        Account area = AllDataFactory.getAccount('08', 'Area');
        // area.PTF_ABICED__c = '05387';
        area.parentId = dir.Id;
        insert area;
        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        // filiale.PTF_ABICED__c = '05387';
        filiale.parentId = area.Id;
        filiale.PTF_BranchTypology__c = 'A';
        insert filiale;

        Account cointestazione = AllDataFactory.getAccount('04', 'Cointestazione');
        //cointestazione.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        cointestazione.PTF_Filiale__c = filiale.Id;
        cointestazione.NDW_ExternalId__c = '1234_4568';
        cointestazione.FinServ__BankNumber__c='1234';
        cointestazione.CRM_NDG__c = '4568';

        insert cointestazione;

        Contact contact = new Contact();
        contact.LastName = 'Tst';
        contact.PTF_RegistrationNumber__c='01';
        contact.AccountId = banca.Id;

        insert contact;

        CRM_AccountAccountJointOwnershipRelation__c acc = new CRM_AccountAccountJointOwnershipRelation__c();
        acc.CRM_Account__c = banca.Id;
        acc.CRM_JointOwnership__c = cointestazione.Id;
        acc.CRM_Active__c = true;

        insert acc;

        Product2 prod = new Product2();
        prod.Name = 'Test';
        prod.ProductCode = '1234';
        prod.CRM_SubGroupCode__c = '1234';
        prod.CRM_ProductCategoryCode__c = '2345';
        prod.CRM_NeedCode__c = 'test';
        prod.CRM_MacroGroupCode__c = 'test1';
        prod.CRM_GroupCode__c = 'ddd';

        insert prod;

    
        Campaign cmpgn = new Campaign();
        cmpgn.Name = 'Testcampaign';
        cmpgn.IsActive = TRUE;
        cmpgn.CRM_SottotipologiaCampagna__c = 'Campagna';
        //cmpgn.CRM_OwnerSystem__c = 'Siebel';
        cmpgn.Status = 'In corso';
        cmpgn.CRM_DataPubblicazione__c = Date.today();
        cmpgn.CRM_DataFineFase2__c = Date.today();
        cmpgn.CRM_PrevistoAffinamento__c = true; 
        cmpgn.CRM_DataFineAffinamento__c = Date.today().addDays(-1);
        cmpgn.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Campaign', 'Trigger_Monostep');
        insert cmpgn;

        CRM_CampaignHesitationValues__c esit = new CRM_CampaignHesitationValues__c();
        esit.Name = 'test';
        esit.CRM_CodiceEsitazione__c = '123';
        insert esit;

        CRM_AssociazioneEsitazioniCampagne__c cmp = new CRM_AssociazioneEsitazioniCampagne__c();
        cmp.Campagna__c = cmpgn.Id;
        cmp.CRM_TipoEsitazione__c = 'Default';
        cmp.CRM_EsitazioneCampagna__c = esit.Id;
        cmp.CRM_OpportunityToCreate__c = 'No';
        cmp.CRM_CheckEsitoSiebel__c = false;
        insert cmp;

        CampaignMember cmpMember = new CampaignMember();
        cmpMember.ContactId = contact.Id; 
        cmpMember.CampaignId = cmpgn.Id;
        cmpMember.Status = 'Da contattare';
        cmpMember.CRM_StatoAssegnazione__c = 'Assegnato';
        cmpMember.isActive__c = true;
        cmpMember.CRM_EsitoCampagna__c = cmp.Id;
        cmpMember.CRM_EsitoCampagnaCC__c = cmp.Id;
        cmpMember.CRM_EsitoCampagnaRete__c = cmp.Id;
        cmpMember.Status = 'Cliente non adatto';
        cmpMember.NDW_ExternalId__c = '1234_4568';
        cmpMember.CRM_Assegnatario__c = UserInfo.getUserId();
        //cmpMember.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('CampaignMember', 'Monostep');
        insert cmpMember;
    }
    
    static testmethod  void testMetodo1(){
        
        List<CampaignMember> con = [select id from campaignMember];
        List<String> useridList = new List<String> ();
        useridList.add(UserInfo.getUserId());
        Test.startTest();
         
		System.Queueable job = new QueueableUtility(useridList);
		System.enqueueJob(job);
        Test.stopTest();       
        
    }

}