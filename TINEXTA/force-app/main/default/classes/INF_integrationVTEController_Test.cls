@isTest
public class INF_integrationVTEController_Test {

    @TestSetup
    static void makeData(){
        Funzionalita__c x = new Funzionalita__c();
		x.Disabilita_tutti_i_trigger__c=true;
        Insert x;

        EndpointServizi__c es = new EndpointServizi__c(INF_Username_VTE__c = 'Salesforce', INF_Access_Key_VTE__c = 'TestAccessKey', INF_Url_VTE__c = 'https://infocerttest.vtecrm.net/restapi/v1/vtews/');
        insert es;

        Test.setMock(HttpCalloutMock.Class, new HTTPMockFactory(200, 'ok', '{"status":200, "message": "ok", "data": { "id": "testid" }}', new Map<string,string>()));

        x.Disabilita_tutti_i_trigger__c=false;
        Update x;    
    }

    @isTest
    public static void vteCreate(){
        User usr = TestDataFactory.create_User([SELECT Id FROM Profile WHERE Name = 'Utente Commerciale InfoCert' LIMIT 1].Id);
        usr.Societa__c = 'InfoCert';
        usr.Escludi_da_convalida__c = true;
        insert usr;

        List <Account> acc= TestDataFactory.createAccounts(2);
        List<Opportunity> oppList = new List<Opportunity>();
        System.runAs(usr){
            
            for(Account a:acc){
                a.Societa_di_riferimento__c='Infocert';
                a.WRT_Codice_IBAN__c = 'IT60X0542811101000000123456';
                a.Warrant_impedire_creazione_account__c = true;
            }
            Insert acc;

            Opportunity opp = new Opportunity(AccountId = acc[0].Id, Name = 'TestOpp', StageName = 'Prospect', CloseDate = System.today().addMonths(1));
            oppList.add(opp);
            insert oppList;
            
        }

        Test.setMock(HttpCalloutMock.Class, new HTTPMockFactory(200, 'ok', '{"status":200, "message": "ok", "data": { "id": "testid" }}', new Map<string,string>()));
        Test.startTest();
            System.runAs(usr){
                Case c1 = new Case(Status = 'New', Priority = 'High', AccountId = acc[0].Id, Opportunity__c = oppList[0].Id);
                Insert c1;
                INF_integrationVTEController.createTicketVTE(c1.Id);
            }
        Test.stopTest();
    }

    @isTest
    public static void vteCreateFatturazione(){
        User usr = TestDataFactory.create_User([SELECT Id FROM Profile WHERE Name = 'Utente Commerciale InfoCert' LIMIT 1].Id);
        usr.Societa__c = 'InfoCert';
        usr.Escludi_da_convalida__c = true;
        insert usr;

        List <Account> acc= TestDataFactory.createAccounts(2);
        List<Opportunity> oppList = new List<Opportunity>();
        System.runAs(usr){
            
            for(Account a:acc){
                a.Societa_di_riferimento__c='Infocert';
                a.WRT_Codice_IBAN__c = 'IT60X0542811101000000123456';
                a.Warrant_impedire_creazione_account__c = true;
            }
            Insert acc;

            Opportunity opp = new Opportunity(AccountId = acc[0].Id, Name = 'TestOpp', StageName = 'Prospect', CloseDate = System.today().addMonths(1));
            oppList.add(opp);
            insert oppList;
            
        }

        Test.setMock(HttpCalloutMock.Class, new HTTPMockFactory(200, 'ok', '{"status":200, "message": "ok", "data": { "id": "testid" }}', new Map<string,string>()));
        Test.startTest();
            System.runAs(usr){
                Case c1 = new Case(Status = 'New', Priority = 'High', AccountId = acc[0].Id, Opportunity__c = oppList[0].Id);
                Insert c1;
                INF_integrationVTEController.createTicketFatturazione(oppList[0].Id, 'body', true, 'partner', 10);
            }
        Test.stopTest();
    }
}