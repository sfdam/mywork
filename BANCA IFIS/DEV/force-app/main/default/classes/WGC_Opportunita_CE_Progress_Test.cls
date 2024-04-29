@isTest
private with sharing class WGC_Opportunita_CE_Progress_Test {

    @isTest
    public static void Test_01(){
        createOpp();
        Test.startTest();
        WGC_Opportunita_CE_Progress_Controller.getOpportunityInBonis();
        Test.stopTest();
    }

    @isTest
    public static void Test_02(){
        createOpp();
        Test.startTest();
        WGC_Opportunita_CE_Progress_Controller.getOpportunityProcedurali();
        Test.stopTest();
    }

    @isTest
    public static void Test_03(){
        Dashboard_FF__c dash = new Dashboard_FF__c(Name= 'default',IdCommerciali__c = 'idtest');
        insert dash;

        Id fastFinance = [SELECT Id FROM Profile WHERE Name = 'IFIS - B/O Valutazione Fast Finance' LIMIT 1].Id;
        Id creditiErariali = [SELECT Id FROM Profile WHERE Name = 'IFIS - Crediti Erariali' LIMIT 1].Id;

        User user1 = new User(Alias = 'User1', Email='UserOne@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserOne@testorg.com', LastName = 'UserOne', ProfileId = fastFinance, Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles');
        User user2 = new User(Alias = 'User2', Email='UserTwo@testorg.com', EmailEncodingKey='UTF-8', Username = 'UserTwo@testorg.com', LastName = 'UserTwo', ProfileId = creditiErariali, Qualifica_Utente__c = 'Filo Diretto', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles');

       List<User> users = new List<User>{user1,user2};
        insert users;

        Test.startTest();
        System.runAs(user1) {
            WGC_Opportunita_CE_Progress_Controller.getDashboard();
        }

        System.runAs(user2) {
            WGC_Opportunita_CE_Progress_Controller.getDashboard();
        }

        WGC_Opportunita_CE_Progress_Controller.getDashboard();

        Test.stopTest();
    }

    private static void createOpp(){
        WGC_AllDataFactory.disattivaTrigger();

        Id recordTypeCE = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('WGC_IFIS_Oppotunita_Crediti_Erariali').getRecordTypeId();
        Id recordTypeFF = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('IFISOpportunitaFastFinance').getRecordTypeId();

        List<Opportunity> toUpdate = new List<Opportunity>();

        List<Opportunity> opp = WGC_AllDataFactory.createOpportunity(2,true);
        for (Opportunity o : opp){
            o.RecordTypeId = recordTypeCE;
            toUpdate.add(o);
        }

        List<Opportunity> opp1 = WGC_AllDataFactory.createOpportunity(2,true);
        for (Opportunity o : opp1){
            o.RecordTypeId = recordTypeCE;
            o.StageName = 'In Lavorazione';
            toUpdate.add(o);
        }

        List<Opportunity> opp2 = WGC_AllDataFactory.createOpportunity(2,true);
        for (Opportunity o : opp2){
            o.RecordTypeId = recordTypeCE;
            o.StageName = 'Valutazione Pratica';
            toUpdate.add(o);
        }

        List<Opportunity> opp3 = WGC_AllDataFactory.createOpportunity(2,true);
        for (Opportunity o : opp3){
            o.RecordTypeId = recordTypeCE;
            o.StageName = 'Predisposizione Contratto';
            toUpdate.add(o);
        }

        List<Opportunity> opp4 = WGC_AllDataFactory.createOpportunity(2,true);
        for (Opportunity o : opp4){
            o.RecordTypeId = recordTypeCE;
            o.StageName = 'Attivazione';
            toUpdate.add(o);
        }

        List<Opportunity> opp5 = WGC_AllDataFactory.createOpportunity(2,true);
        for (Opportunity o : opp5){
            o.RecordTypeId = recordTypeCE;
            o.StageName = 'Perfezionamento Contratto';
            toUpdate.add(o);
        }

        update toUpdate;
    }
}