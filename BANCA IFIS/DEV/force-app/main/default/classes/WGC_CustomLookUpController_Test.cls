@isTest
public with sharing class WGC_CustomLookUpController_Test {
    @isTest
    public static void Test_fetchLookUpValues(){
        WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createAccount(10,true);

        Test.startTest();
        WGC_CustomLookUpController.fetchLookUpValues('a', 'Account','Name');
        WGC_CustomLookUpController.fetchLookUpValues('a', 'Account','Name', true, '###Name###');
        Test.stopTest();
    }

}