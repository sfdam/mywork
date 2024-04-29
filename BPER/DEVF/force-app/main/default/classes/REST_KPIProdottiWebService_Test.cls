@isTest
public with sharing class REST_KPIProdottiWebService_Test {
    @TestSetup
    static void makeData(){

        Account acc = AllDataFactory.getAccount('01', 'PersonAccount');
        acc.NDW_ExternalId__c = '1234_4568';
        acc.CRM_NDG__c = '4568';
        insert acc;

        Product2 product = new Product2(
            Name = 'Test'
        );
        insert product;
        

        FinServ__FinancialAccount__c financialAccount = AllDataFactory.getFinancialAccount('BankingAccount', '01', acc.Id);
        financialAccount.FinServ__Status__c = 'ATTIVO';
        financialAccount.FinServ__JointOwner__c = null;
        financialAccount.FinServ__ProductName__c = product.Id;
        insert financialAccount;

        FinServ__FinancialAccountRole__c financialAccountRole = AllDataFactory.getFinancialAccountRole('AccountRole', financialAccount.Id, acc.Id, 'Primary Owner');
        insert financialAccountRole;

        Campaign cmpgn = new Campaign();
		cmpgn.Name = 'Testcampaign';
		cmpgn.IsActive = TRUE;
        cmpgn.CRM_OwnerSystem__c = 'Siebel';
        cmpgn.Status = 'In corso';
        cmpgn.StartDate = Date.today().addDays(5);
        cmpgn.EndDate = Date.today().addDays(10);
        insert cmpgn;

        CampaignMember cmpMember = new CampaignMember();
        cmpMember.ContactId = [SELECT Id FROM Contact WHERE AccountId =: acc.Id LIMIT 1].Id; 
        cmpMember.CampaignId = cmpgn.Id;
        cmpMember.Status = 'Da ricontattare';
        insert cmpMember;

        CRM_AssociazioneProdottiCampagna__c assProdCmp = new CRM_AssociazioneProdottiCampagna__c();
        assProdCmp.CRM_Campagna__c = cmpgn.Id;
        insert assProdCmp;

        Campaign cmpgn2 = new Campaign();
		cmpgn2.Name = 'Testcampaign2';
		cmpgn2.IsActive = TRUE;
        cmpgn2.CRM_OwnerSystem__c = 'Siebel';
        cmpgn2.Status = 'Chiusa';
        // cmpgn2.StartDate = Date.today().addDays(-5);
        // cmpgn2.EndDate = Date.today().addDays(10);
        insert cmpgn2;

        CampaignMember cmpMember2 = new CampaignMember();
        cmpMember2.ContactId = [SELECT Id FROM Contact WHERE AccountId =: acc.Id LIMIT 1].Id; 
        cmpMember2.CampaignId = cmpgn2.Id;
        cmpMember2.Status = 'Cliente non interessato';
        insert cmpMember2;

        CRM_AssociazioneProdottiCampagna__c assProdCmp2 = new CRM_AssociazioneProdottiCampagna__c();
        assProdCmp2.CRM_Campagna__c = cmpgn2.Id;
        insert assProdCmp2;
        
    }

    @isTest
    static void test(){
        Funzionalita__c x = new Funzionalita__c();
        x.Disable_Trigger__c =true;
        insert x;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest/v1/getkpiprodottiweb/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();

        REST_KPIProdottiWebService.KpiProdottiWebInputDto input = new REST_KPIProdottiWebService.KpiProdottiWebInputDto();
        input.KPIProdottiWsServiceRequest = new REST_KPIProdottiWebService.KPIProdottiWsServiceRequest();
        input.KPIProdottiWsServiceRequest.banca = '1234';
        input.KPIProdottiWsServiceRequest.ndg = '4568';
        input.KPIProdottiWsServiceRequest.uo = 'ou=99999,O=GBBPER,C=IT';
        input.KPIProdottiWsServiceRequest.scudati = 'S';
        input.KPIProdottiWsServiceRequest.flagEstrazione = 'PP, PS, PR, KPI';


        // List<REST_EsitazioneAzioniStorico.EsitazioneAzioniInput> inputList = new List<REST_EsitazioneAzioniStorico.EsitazioneAzioniInput>();
        // inputList.add(input);

        // REST_EsitazioneAzioniStorico.EsitazioneAzioniStoricoWsServiceRequest wsReq = new REST_EsitazioneAzioniStorico.EsitazioneAzioniStoricoWsServiceRequest();
        // wsReq.esitazioneAzioniInput = inputList;

        // REST_EsitazioneAzioniStorico.EsitazioneAzioniStoricoInputDto req1 = new REST_EsitazioneAzioniStorico.EsitazioneAzioniStoricoInputDto();
        // req1.EsitazioneAzioniStoricoWsServiceRequest = wsReq;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        REST_KPIProdottiWebService.getKpiProdottiWebRequest(input);
        Test.stopTest();
    }
}