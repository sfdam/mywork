@isTest
public with sharing class CIB_SimulatoreControllerTest {
    @TestSetup
    static void makeData(){
        Simulazione__c sim = new Simulazione__c();
        insert sim;
    }

    @isTest
    public static void test1(){
        CIB_SimulatoreController.init();
    }
}