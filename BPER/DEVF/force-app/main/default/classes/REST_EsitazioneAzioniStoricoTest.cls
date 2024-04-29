/**
 * @description       : 
 * @author            : simone.viglianti@tengroup.it
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : simone.viglianti@tengroup.it
**/
@isTest
public class REST_EsitazioneAzioniStoricoTest {
    @TestSetup
    static void makeData(){

        Endpoint__c endPoint = new Endpoint__c();
        endPoint.Name = 'salvaEsitazioneAzioniNec';
        endPoint.Method__c = 'POST';
        endPoint.Timeout__c = 120000;
        endPoint.Endpoint__c = 'Test';
        insert endPoint;

   
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
        cointestazione.NDW_ExternalId__c = banca.FinServ__BankNumber__c+'_'+banca.CRM_NDG__c;
        cointestazione.FinServ__BankNumber__c= banca.FinServ__BankNumber__c;
        cointestazione.CRM_NDG__c = banca.CRM_NDG__c;

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
        prod.ProductCode =  banca.FinServ__BankNumber__c;
        prod.CRM_SubGroupCode__c = banca.FinServ__BankNumber__c;
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
        cmpgn.CRM_DataPubblicazione__c = System.today();
        cmpgn.CRM_DataFineFase2__c =System.today();
        cmpgn.CRM_PrevistoAffinamento__c = true; 
        cmpgn.CRM_DataFineAffinamento__c = System.today().addDays(-1);
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
        cmpMember.Chiave_Banca_NDG__c = banca.FinServ__BankNumber__c+'-'+banca.CRM_NDG__c;
        cmpMember.NDW_ExternalId__c = banca.FinServ__BankNumber__c+'_'+banca.CRM_NDG__c;
        //cmpMember.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('CampaignMember', 'Monostep');
        insert cmpMember;

        CRM_AssociazioneProdottiCampagna__c ass = new CRM_AssociazioneProdottiCampagna__c();
        ass.CRM_Prodotto__c = prod.Id;
        ass.CRM_Campagna__c = cmpgn.Id;

        insert ass;
    }

    @isTest
    static void test(){
        Funzionalita__c x = new Funzionalita__c();
        x.Disable_Trigger__c =true;
        insert x;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        Account a =[SELECT FinServ__BankNumber__c,CRM_NDG__c from Account where Name IN ('AccountBanca') limit 1];
        req.headers.put('testata_operationId',a.FinServ__BankNumber__c/*'1234'*/);

        req.requestURI = '/services/apexrest/v1/esitazioneazionistorico/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        
        REST_EsitazioneAzioniStorico.EsitazioneAzioniInput input = new REST_EsitazioneAzioniStorico.EsitazioneAzioniInput();
        input.banca = a.FinServ__BankNumber__c;
        input.ndg = a.CRM_NDG__c;
        input.matricola = a.FinServ__BankNumber__c;
        input.appChiamante = 'Test';
        input.nomeMatricola = 'Test';
        input.prodotto = a.FinServ__BankNumber__c;
        input.tipoRichiesta = 'ESITAZIONE';

        List<REST_EsitazioneAzioniStorico.EsitazioneAzioniInput> inputList = new List<REST_EsitazioneAzioniStorico.EsitazioneAzioniInput>();
        inputList.add(input);

        REST_EsitazioneAzioniStorico.EsitazioneAzioniStoricoWsServiceRequest wsReq = new REST_EsitazioneAzioniStorico.EsitazioneAzioniStoricoWsServiceRequest();
        wsReq.esitazioneAzioniInput = inputList;

        REST_EsitazioneAzioniStorico.EsitazioneAzioniStoricoInputDto req1 = new REST_EsitazioneAzioniStorico.EsitazioneAzioniStoricoInputDto();
        req1.EsitazioneAzioniStoricoWsServiceRequest = wsReq;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        REST_EsitazioneAzioniStorico.getEsitazioneAzioniStoricoRequest(req1);
        Test.stopTest();
    }
}