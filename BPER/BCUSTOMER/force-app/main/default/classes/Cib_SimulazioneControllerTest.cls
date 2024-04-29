@IsTest
public with sharing class Cib_SimulazioneControllerTest {
    
    @TestSetup
    static void makeData(){

        Simulazione__c sim = new Simulazione__c();
        insert sim;
        Linea__c lin = new Linea__c();  
        lin.Simulazione__c=sim.ID;
        insert lin;
        RataLinea__c rlin = new RataLinea__c();
        rlin.Linea__c = lin.Id;
        insert rlin;
    }

    @isTest
    public static void test1(){
        Simulazione__c sim = [SELECT id from Simulazione__c LIMIT 1];
        List<Linea__c> listLinee = [SELECT Id, Simulazione__c FROM Linea__c WHERE Simulazione__c = :sim.Id]; 
        List<RataLinea__c> listRataLinee = [SELECT Id FROM RataLinea__c WHERE Linea__c = :listLinee[0].Id];

        Opportunity opportunity1 = AllDataFactory.getOpportunity('test', UserInfo.getUserId(), Date.today().addDays(30));
        insert opportunity1;

        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];

        Cib_SimulazioneController.init(sim.Id, opportunity.Id);
        Cib_SimulazioneController.save(sim, listLinee, new List<Map<String,Object>>{}, listRataLinee);
        Cib_SimulazioneController.clone(sim.Id);
    }
}