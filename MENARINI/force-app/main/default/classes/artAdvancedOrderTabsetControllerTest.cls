@isTest
public with sharing class artAdvancedOrderTabsetControllerTest {
    @TestSetup
    static void makeData(){
        cgcloud__Order_Template__c orderTemplate = new 	cgcloud__Order_Template__c();
        insert orderTemplate;
        cgcloud__Order__c orderHeader = new cgcloud__Order__c(
            cgcloud__Order_Template__c = orderTemplate.Id
        );
        insert orderHeader;
    }
    @isTest 
    static void getPdfFileAsBase64StringTest() {
        List<cgcloud__Order__c> listOrders = [SELECT Id
                                                FROM cgcloud__Order__c
                                                LIMIT 1];
    Test.startTest();
    artAdvancedOrderTabsetController.getPdfFileAsBase64String(listOrders[0].Id);
    Test.stopTest();
    }
}