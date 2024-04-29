@isTest
public class CIB_SintesiSimulazioneController_Test {
	@testSetup
    public static void makedata(){
        Simulazione__c sim = new Simulazione__c();
        insert sim;
        Linea__c lin = new Linea__c();  
        lin.Simulazione__c=sim.ID;
        insert lin;
    }
    
    
    @isTest
    public static void test1(){
        Simulazione__c sim = [SELECT id from Simulazione__c LIMIT 1];
        CIB_SintesiSimulazioneController.getLinee(sim.Id, 'Simulazione__c');
    }

    @isTest
    public static void test2(){
        Linea__c lin = [SELECT id from Linea__c LIMIT 1];
        CIB_SintesiSimulazioneController.getLinee(lin.Id, 'Linea__c');
    }
}