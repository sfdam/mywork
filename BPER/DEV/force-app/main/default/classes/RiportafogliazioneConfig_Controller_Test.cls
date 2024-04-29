@isTest
public with sharing class RiportafogliazioneConfig_Controller_Test {

    @IsTest
    static void testGetAllData() {
        Riportafogliazione_Conf__c rip = new Riportafogliazione_Conf__c();
        rip.Tipologia_Spostamento__c= 'UPGRADE';
        Test.startTest();
        List<Riportafogliazione_Conf__c> riport = RiportafogliazioneConfig_Controller.getAllData();
        Test.stopTest();
    }

     @IsTest
     static void testUpdatePercent() {
        
        List<Riportafogliazione_Conf__c> riport = new List<Riportafogliazione_Conf__c>();
        Riportafogliazione_Conf__c rip = new Riportafogliazione_Conf__c();
        rip.Tipologia_Spostamento__c= 'UPGRADE';
        riport.add(rip);
        Test.startTest();
        RiportafogliazioneConfig_Controller.updatePercent(riport);
        Test.stopTest();

        }

}