@isTest 
public with sharing class OpportunitaEsitoIncontroContrTest {
    @TestSetup
    static void makeData(){
        Account a = new Account();
        a.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        a.FirstName='test';
        a.LastName='test';
        insert a;

        List<Opportunity> listOpps = new List<Opportunity>();
        Opportunity opp1 = new Opportunity();
        opp1.AccountId=a.Id;
        opp1.Name= 'Test';
        opp1.StageName='Non risponde 1';
        opp1.CloseDate=Date.today().addDays(3);
        opp1.Data_Stipula_Signing__c = Date.today();
        opp1.Memo_CIB_Saved__c = true;
        listOpps.add(opp1);

        insert listOpps;

    }

    @isTest
    public static void test() {
        Test.startTest();
        OpportunitaEsitoIncontroApexController.fetchOpportunitaEsitoIncontro();
        List<Opportunity> listOpp= [SELECT ID, Orario_IB_Committee__c
                                FROM Opportunity
                                LIMIT 1];

        listOpp[0].Orario_IB_Committee__c = '8';
        OpportunitaEsitoIncontroApexController.updateOpportunitaEsitoIncontro(listOpp);
        Test.stopTest();
    }
}