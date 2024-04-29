@isTest
public class REST_OpenPopUp_Test {

    @TestSetup
    static void makeData(){

        Account banca = new Account();
        banca.Name = 'Banca';
        banca.FinServ__BankNumber__c='1234';
        banca.CRM_NDG__c = '4568';
        banca.NDW_ExternalId__c = '1234_4568';
        insert banca;

        Contact contact = new Contact();
        contact.LastName = 'Tst';
        contact.PTF_RegistrationNumber__c='01';
        contact.AccountId = banca.Id;
        insert contact;

        Campaign cmp = new Campaign();
        cmp.Name = 'Test Campaign';
        cmp.Type = 'Test Type';
        cmp.StartDate = Date.today();
        cmp.EndDate = Date.today().addDays(30);
        cmp.CRM_SottotipologiaCampagna__c = 'Test Subtype';
        cmp.CRM_Categoria__c = 'Test Category';
        insert cmp;

        CampaignMember cmpMember = new CampaignMember();
        cmpMember.ContactId = contact.Id; 
        cmpMember.CampaignId = cmp.Id;
        cmpMember.Status = 'Da contattare';
        cmpMember.CRM_StatoAssegnazione__c = 'Assegnato';
        cmpMember.isActive__c = true;
        cmpMember.Status = 'Cliente non adatto';
        cmpMember.NDW_ExternalId__c = '1234_4568';
        insert cmpMember;
    }

    @isTest
    static void openPopUpRequestTest() {
        REST_OpenPopUp.AzioniCommercialiInput input = new REST_OpenPopUp.AzioniCommercialiInput();
        input.abi = '12345';
        input.filiale = 'filiale';
        input.ndg = '67890';

        RestRequest request = new RestRequest();
        request.requestURI = '/v1/openpopup/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.addHeader('testata_operationId', 'test-id');
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request = request;

        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.NDW_ExternalId__c = '12345_67890';
        acc.ModelloDiServizio__c = 'Private';
        insert acc;

        Campaign campaign = new Campaign();
        campaign.Name = 'Test Campaign';
        campaign.Type = 'Test Type';
        insert campaign;

        Contact contact = new Contact();
        contact.AccountId = acc.Id;
        contact.LastName='test';
        insert contact;

        CampaignMember campaignMember = new CampaignMember();
        campaignMember.CampaignId = campaign.Id;
        campaignMember.ContactId = contact.Id;
        campaignMember.Status = 'Test Status';
        insert campaignMember;

        CRM_Memo__c memo = new CRM_Memo__c();
        memo.Cliente__c = acc.Id;
        memo.CRM_Titolo__c = 'Test Title';
        memo.CRM_PopupCassa__c = true;
        memo.CRM_FineValidita__c = System.today().addDays(1);
        insert memo;

        RestResponse response = new RestResponse();
        RestContext.response = response;

        REST_OpenPopUp.EstraiAzioniCommercialiClienteResponse result = REST_OpenPopUp.openPopUpRequest(input);


    }

}