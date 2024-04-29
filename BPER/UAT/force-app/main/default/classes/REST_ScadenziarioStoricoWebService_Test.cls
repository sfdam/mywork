/**
 * @description       : class test for REST_ScadenziarioStoricoWebService
 * @author            : alessandro di nardo
 * @group             : ten
 * @creation          : 20-06-2023  
 * @last modified on  : 20-06-2023 
 * @last modified by  : 
**/
@isTest
public class REST_ScadenziarioStoricoWebService_Test {
    @TestSetup
    static void makeData() {

        

        Date CloseDate = Date.newInstance(2022, 10, 10);

        Account account = AllDataFactory.getAccount('01', 'PersonAccount');
        account.FinServ__BankNumber__c = '05387';
        account.CRM_NDG__c = '75421702'; 
        insert account;

        List<Account> listAcc = [SELECT Id FROM Account limit 1]; 

        Profile profile=[SELECT Id FROM Profile WHERE Name='Service Cloud User'];

        System.debug('AD listAcc[0].id : ' + listAcc[0].id);
        User user = new User();
        user.LastName='Old';
        user.ProfileId=profile.Id;
        user.TimeZoneSidKey='Europe/Rome';
        user.LocaleSidKey='it_IT';
        user.EmailEncodingKey='ISO-8859-1';
        user.LanguageLocaleKey ='it';
        user.Alias='Old';
        user.Email='old@fake.com';
        user.Username='old@fake.com';
        user.FederationIdentifier='10';
        insert user;

        Opportunity newOp = new Opportunity();
        newOp.Name='OPP-351642'; 
        newOp.CloseDate=CloseDate; 
        newOp.CRM_Banca__c='05387'; 
        newOp.CRM_Filiale__c='0032'; 
        newOp.CRM_IdProposta__c='351642'; 
        newOp.AccountId=account.Id; 
        newOp.StageName='Proposta in corso'; 
        newOp.CRM_StatoContratto__c=null; 
        newOp.CRM_Codiceprodotto__c='KI_BPEUR621'; 
        newOp.CRM_NoteEsitazioneOpps__c=''; 
        newOp.CRM_Canale__c='Bstore';
        newOp.OwnerId='0053X00000D5580QAB';
        insert newOp;
    }

    @isTest
    static void testEsitoInsert(){



        Funzionalita__c x = new Funzionalita__c();
        x.Disable_Trigger__c =true;
        insert x;

        //List<Account> listAcc = [SELECT id FROM Account limit 1]; 

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest/v1/scadenziariostoricowebservice/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;

        REST_ScadenziarioStoricoWebService.Proposta proposta = new REST_ScadenziarioStoricoWebService.Proposta();
        
        proposta.autore= 'Ricci Giuseppe';
        proposta.banca= '05387';
        proposta.codProdotto= 'KI_BPEUR621';
        proposta.codStatoProposta= '1';
        proposta.dataInserimento= '2022-09-19-08-30-49-000000532';
        proposta.dataScadenza= '20221010';
        proposta.dataUltimaModifica= '20220919';
        proposta.descStatoContratto= null;
        proposta.descStatoProposta= 'Proposta in corso';
        proposta.filiale= '0032';
        proposta.idProposta= '35164';
        proposta.ndgClienteCointestatari= '';
        //proposta.ndgClienteCointestatari= '75421702|75421703'; for test filter Account.CRM_NDG__c IN :listaClienteCointestatari
        proposta.ndgClientePrimario= '75421702';
        //proposta.ndgClientePrimario= '75421704';  for test filter Account.CRM_NDG__c IN :listaClienteCointestatari
        proposta.ndgCointestazione = null;
        proposta.nota= '';
        proposta.tipologiaRecord= 'ONLINE';
        proposta.utente= 'U10';
        
        REST_ScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest serviceReq = new REST_ScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest();
        serviceReq.proposta=proposta;

        REST_ScadenziarioStoricoWebService.ScadenziarioStoricoWebServiceInputDto inputDto = new REST_ScadenziarioStoricoWebService.ScadenziarioStoricoWebServiceInputDto();    
        inputDto.ScadenziarioStoricoCrmWsServiceRequest=serviceReq;

        Test.startTest();
        REST_ScadenziarioStoricoWebService.getScadenziarioStoricoWebServiceRequest(inputDto);
        Test.stopTest();

    }

    @isTest
    static void testEsitoUpdate(){

        Funzionalita__c x = new Funzionalita__c();
        x.Disable_Trigger__c =true;
        insert x;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.headers.put('testata_operationId','1234');

        req.requestURI = '/services/apexrest/v1/scadenziariostoricowebservice/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;

        REST_ScadenziarioStoricoWebService.Proposta proposta = new REST_ScadenziarioStoricoWebService.Proposta();
        
        proposta.autore= 'Ricci Giuseppe';
        proposta.banca= '05387';
        proposta.codProdotto= 'KI_BPEUR621';
        proposta.codStatoProposta= '1';
        proposta.dataInserimento= '2022-09-19-08-30-49-000000532';
        proposta.dataScadenza= '20221010';
        proposta.dataUltimaModifica= '20220919';
        proposta.descStatoContratto= null;
        proposta.descStatoProposta= 'Proposta in corso';
        proposta.filiale= '0032';
        proposta.idProposta= '351642';
        proposta.ndgClienteCointestatari= '';
        proposta.ndgClientePrimario= '75421702';
        proposta.ndgCointestazione = null;
        proposta.nota= '';
        proposta.tipologiaRecord= 'ONLINE';
        proposta.utente= 'U810011';
        
        REST_ScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest serviceReq = new REST_ScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest();
        serviceReq.proposta=proposta;

        REST_ScadenziarioStoricoWebService.ScadenziarioStoricoWebServiceInputDto inputDto = new REST_ScadenziarioStoricoWebService.ScadenziarioStoricoWebServiceInputDto();    
        inputDto.ScadenziarioStoricoCrmWsServiceRequest=serviceReq;

        Test.startTest();
        REST_ScadenziarioStoricoWebService.getScadenziarioStoricoWebServiceRequest(inputDto);
        Test.stopTest();

    }
}