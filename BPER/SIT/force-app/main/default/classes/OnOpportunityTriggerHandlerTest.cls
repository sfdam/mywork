@IsTest
public with sharing class OnOpportunityTriggerHandlerTest {
    
    @TestSetup
    static void setup(){
       
        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        insert filiale;

        Account acc = AllDataFactory.getAccount('02', 'FilialeDiRelazione');
        insert acc;

        
        Product2 product = new Product2(
            Name = 'Test'
        );
        insert product;

        FinServ__FinancialAccount__c  finservFinAcc = new FinServ__FinancialAccount__c();
        finservFinAcc.Name='Test';
        finservFinAcc.FinServ__ProductName__c = product.Id;
        finservFinAcc.FinServ__PrimaryOwner__c=acc.id;
        insert finservFinAcc;

        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Test';
        opportunity.StageName = 'Discovery';
        opportunity.CloseDate = Date.today().addDays(20);
        opportunity.AccountId = filiale.Id;
        opportunity.RecordTypeId=SV_Utilities.getRecordTypeByDeveloperName('Opportunity', 'WalletShareOpportunity');
        opportunity.FinServ__FinancialAccount__c =finservFinAcc.id;
        opportunity.Amount =100;
        opportunity.Probability=20;
        opportunity.Type='New Businnes';
        opportunity.LeadSource='Other';
        opportunity.NextStep='next';
        opportunity.Description='description';
        opportunity.CRM_Bisogno__c='Assicurativo';
        opportunity.CRM_Canale__c	='Check-up';
        opportunity.CRM_EsitoContatto__c='Da contattare';	

        insert opportunity;

        Endpoint__c endpoint2 = new Endpoint__c();
        endpoint2.Name = 'notificaStatoProcesso';
        endpoint2.Method__c = 'GET';
        endpoint2.Timeout__c = 120000;
        endpoint2.Endpoint__c = 'https://apigw-test.bper.it/gateway/CrmAPI/v1/crm/notifica-stato-processo/abi/{abi}/ndg/{ndg}/dataRichiesta/{dataRichiesta}/prodottoCorrelato/{prodottoCorrelato}';
        endpoint2.EndpointParams__c = '{"abi":"{testata_abi}","termid": "WEB","utente":"{security_utente}","agenzia":"{security_idced}","livello":"50"}';
        insert endpoint2;
    }

    @isTest
    static void testUpdate(){

        Opportunity opportunity = [SELECT id, Name FROM Opportunity LIMIT 1];
        opportunity.Name = 'New Name';
        update opportunity;
    }

    @isTest
    static void testDate(){
        
        delete [SELECT id, Name FROM Opportunity LIMIT 1];
    }
    @isTest
    static void testCall(){
        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        insert filiale;

        Account acc = AllDataFactory.getAccount('02', 'FilialeDiRelazione');
        insert acc;

        Product2 product = new Product2(
            Name = 'Test2'
        );
        insert product;

        FinServ__FinancialAccount__c  finservFinAcc = new FinServ__FinancialAccount__c();
        finservFinAcc.Name='Test';
        finservFinAcc.FinServ__ProductName__c = product.Id;
        finservFinAcc.FinServ__PrimaryOwner__c=acc.id;
        insert finservFinAcc;
        Opportunity opportunity = new Opportunity();
        opportunity.RecordTypeId=SV_Utilities.getRecordTypeByDeveloperName('Opportunity', 'Opportunita_da_cc_vs_rete');
        opportunity.Name = 'TestCall';
        opportunity.StageName = 'Inviata Filiale';
        opportunity.CloseDate = Date.today().addDays(20);
        opportunity.AccountId = filiale.Id;
        opportunity.FinServ__FinancialAccount__c =finservFinAcc.id;
        opportunity.Amount =100;
        opportunity.Probability=20;
        opportunity.Type='New Businnes';
        opportunity.LeadSource='Other';
        opportunity.NextStep='next';
        opportunity.Description='description';
        opportunity.CRM_Bisogno__c='Assicurativo';
        opportunity.CRM_Canale__c	='Check-up';
        opportunity.CRM_EsitoContatto__c='Da contattare';	


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        insert opportunity;
        Test.stopTest();
    }
}