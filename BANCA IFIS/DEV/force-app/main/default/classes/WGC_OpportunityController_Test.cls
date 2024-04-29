@isTest
public class WGC_OpportunityController_Test {
    @isTest
    public static void Test_WGC_OpportunityController1(){
        WGC_AllDataFactory.disattivaTrigger();
        List<Opportunity> listOpp = WGC_AllDataFactory.createOpportunity(10,true);
        List<WGC_Budget__c> listBudget = WGC_AllDataFactory.createBudget(1,true);
        Test.startTest();
        WGC_OpportunityController.getCurrentYearAndMonthData();
        WGC_OpportunityController.getTotalAndPerMonthData();
        Test.stopTest();
    }

    @isTest
    public static void Test_WGC_OpportunityController2(){
        /*WGC_AllDataFactory.disattivaTrigger();
        List<Opportunity> listOpp = WGC_AllDataFactory.createOpportunity(10,true);
        List<WGC_Budget__c> listBudget = WGC_AllDataFactory.createBudget(1,true);*/
        Test.startTest();
        WGC_OpportunityController.getCurrentYearAndMonthData();
        WGC_OpportunityController.getTotalAndPerMonthData();
        Test.stopTest();
    }
}