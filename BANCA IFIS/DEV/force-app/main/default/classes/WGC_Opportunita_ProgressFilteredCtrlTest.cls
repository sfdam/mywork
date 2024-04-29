@isTest
public inherited sharing class WGC_Opportunita_ProgressFilteredCtrlTest {

    @TestSetup
    static void makeData(){
        WGC_AllDataFactory.createUtenzaDefault();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'IFIS - Sviluppo Commerciale Filiali'];
        User u = new User(Email = 'TestIFIS123abc@testorg.com',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing213bsd', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Los_Angeles', UserName = 'TestIFISacs124@testorg.com', Alias = '123abc', WGC_La_Mia_Filiale__c = '000');
		insert u;

        Test.startTest();
        System.runAs(u){
            List<Account> accList = WGC_AllDataFactory.createAccount(1);
            accList[0].NDGGruppo__c = accList[0].NDGGruppo__c + String.valueOf(Math.random()).substring(2, 4);
            accList[0].NDGGruppoGiuridico__c = accList[0].NDGGruppoGiuridico__c + String.valueOf(Math.random()).substring(2, 4);
            accList[0].WGC_NDG_controllante__c = accList[0].WGC_NDG_controllante__c + String.valueOf(Math.random()).substring(2, 4);
            insert accList;
            List<Opportunity> oppList = WGC_AllDataFactory.createOpportunity2(4);
            oppList[0].AccountId = accList[0].Id;
            oppList[1].AccountId = accList[0].Id;
            oppList[2].AccountId = accList[0].Id;
            oppList[3].AccountId = accList[0].Id;

            insert oppList;

            oppList[1].StageName = 'Valutazione Pratica';
            oppList[2].StageName = 'Perfezionamento Contratto';
            oppList[3].StageName = 'Attivazione';

            update oppList;
        }
        Test.stopTest();
    }

    @isTest
    static void getOpportunityCountFilteredTest(){
        User u = [SELECT Id, Name FROM User WHERE Username = 'TestIFISacs124@testorg.com' LIMIT 1];

        Test.startTest();

        System.runAs(u){
            WGC_Opportunita_Progress_FilteredCtrl.getOpportunityCountByStatusFiltered('','');
            WGC_Opportunita_Progress_FilteredCtrl.getOpportunityCountByStatusFiltered('abc','');
            WGC_Opportunita_Progress_FilteredCtrl.getOpportunityCountByStatusFiltered('abc','abc');
            WGC_Opportunita_Progress_FilteredCtrl.getFilialeUtentiOptions();
            WGC_Opportunita_Progress_FilteredCtrl.getCommercialeOptions('000');
            WGC_Opportunita_Progress_FilteredCtrl.getCommercialeOptions('');
        }
        
        Test.stopTest();
    }

}