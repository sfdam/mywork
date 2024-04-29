@isTest
public with sharing class sganciaReferentePTF_Controller_Test {

    @TestSetup
    static void makeData(){
        
        Account filiale = AllDataFactory.getAccount('04', 'FilialeDiRelazione');
        Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet', filiale.Id, 'CORPORATE');
        insert microPortafoglio;
        Contact gestore = AllDataFactory.getContact('01', null, filiale.Id);
        insert gestore;
        Assignment__c ass = AllDataFactory.getAssignment('Primario', microPortafoglio.Id, gestore.Id);
        insert ass;
    }

    @IsTest
    static void testGetWallet() {
        Contact gestore = [SELECT Id FROM Contact LIMIT 1];
        List<Assignment__c> wallet = sganciaReferentePTF_Controller.getWallet(gestore.Id);
    }
    @IsTest
    static void testGetContact() {
        Contact gestore = [SELECT Id FROM Contact LIMIT 1];
        List<Contact> con = sganciaReferentePTF_Controller.getContact(gestore.Id);
    }

    @IsTest
    static void testSganciaReferente() {
        List<Assignment__c> testAssignments = [SELECT Id, PTF_Gestore__c FROM Assignment__c];

        List<String> assignmentIds = new List<String>();
        for (Assignment__c ass : testAssignments) {
            assignmentIds.add(ass.Id);
        }

        Test.startTest();
        sganciaReferentePTF_Controller.sganciaReferente(assignmentIds, 'testNome', testAssignments[0].PTF_Gestore__c);
        Test.stopTest();
    }
}