@isTest
public with sharing class LoadAmmortamentoLineaControllerTest {
    @TestSetup
    static void makeData(){

        Simulazione__c sim = new Simulazione__c();
        insert sim;
        Linea__c lin = new Linea__c();  
        lin.Simulazione__c=sim.ID;
        insert lin;
    }

    @isTest
    public static void test1(){
        Simulazione__c sim = [SELECT id from Simulazione__c LIMIT 1];
        List<Linea__c> listLinee = [SELECT Id, Simulazione__c FROM Linea__c WHERE Simulazione__c = :sim.Id]; 

        Opportunity opportunity1 = AllDataFactory.getOpportunity('test', UserInfo.getUserId(), Date.today().addDays(30));
        insert opportunity1;

        RataLinea__c rlin = new RataLinea__c();
        rlin.Linea__c = listLinee[0].Id;

        Object response = LoadAmmortamentoLineaController.init(listLinee[0].Id);
        LoadAmmortamentoLineaController.save(listLinee[0], new List<RataLinea__c>{rlin});
    }
}