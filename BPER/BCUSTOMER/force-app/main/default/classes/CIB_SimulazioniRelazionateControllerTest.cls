@IsTest
public with sharing class CIB_SimulazioniRelazionateControllerTest {
    
    @TestSetup
    static void makeData(){
        Simulazione__c sim = new Simulazione__c();
        insert sim;
    }

    @isTest
    public static void test1(){
        Simulazione__c sim = [SELECT id from Simulazione__c LIMIT 1];
        CIB_SimulazioniRelazionateController.init(sim.Id);
    }
}