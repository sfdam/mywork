@isTest
public class REST_getReferentiAziendali_Test {

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
    }

    @isTest
    static void openPopUpRequestTest() {

        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1/getReferentiAziendali?abi=05387&ndg=13528580';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;

        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        REST_getReferentiAziendali.getReferentiAziendaliRequest();
    }
}