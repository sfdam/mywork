@isTest
public with sharing class WGC_CircularUserImgController_Test {
    @isTest
    public static void Test_getUserNeg()
    {
        WGC_AllDataFactory.createUser(15,true).get(0);
        User us = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        WGC_CircularUserImgController.getUser(us.Id);
        Test.stopTest();
    }


    @isTest
    public static void Test_getUserPos()
    {
        Test.startTest();
        User user = WGC_CircularUserImgController.getUser(null);
        Test.stopTest();
    }
}