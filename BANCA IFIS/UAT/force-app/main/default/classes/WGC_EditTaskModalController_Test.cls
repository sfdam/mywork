@isTest
public with sharing class WGC_EditTaskModalController_Test {
    @isTest
    public static void Test_Metodi(){
        WGC_AllDataFactory.disattivaTrigger();
        Account a = WGC_AllDataFactory.createAccount(1,true).get(0);
        Test.startTest();
        WGC_EditTaskModalController.getActivity(a.Id);
        Test.stopTest();

    }
}