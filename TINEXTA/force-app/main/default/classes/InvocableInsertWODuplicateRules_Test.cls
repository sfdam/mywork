@isTest(SeeAllData=true)
public class InvocableInsertWODuplicateRules_Test {

    @isTest static void testSuccess() {
        List<InvocableInsertWODuplicateRules.ActionRequest> arList = new List<InvocableInsertWODuplicateRules.ActionRequest>();
        InvocableInsertWODuplicateRules.ActionRequest arTest = new InvocableInsertWODuplicateRules.ActionRequest();

        Id rtId = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Lead' LIMIT 1].id;
        
        arTest.fonte = 'Banca';
        arTest.fonteLead = 'Banche';
        arTest.posizione = 'Formazione';
        arTest.societa = 'Warrant';
        arTest.StatoSegnalazione='In lavorazione';
        arTest.Origine='Segnalazione Partner';
                arTest.LeadObject = new Lead(LastName = 'TestCompany',
                              FirstName = 'Test',
                              Company = 'TestCompany',
                              Partiva_Iva__c = '00000900000', 
                              Codice_Fiscale__c = '00000900000',
                              Societa_di_riferimento__c ='Warrant',
                              RecordTypeId = rtId);
        
        arList.add(arTest);
        
        Test.startTest();
        List<String> res = InvocableInsertWODuplicateRules.InsertWODuplicateRules(arList);
        System.debug('Result: ' + res[0]);
        System.assertEquals('Segnalazione inserita correttamente', res[0]);
        Test.stopTest();
    }
    
 /*   @isTest static void testFailure() {
        
        List<InvocableInsertWODuplicateRules.ActionRequest> arList = new List<InvocableInsertWODuplicateRules.ActionRequest>();
        InvocableInsertWODuplicateRules.ActionRequest arTest = new InvocableInsertWODuplicateRules.ActionRequest();

        arTest.fonte = 'Banca';
        arTest.fonteLead = 'Banche';
        arTest.posizione = 'Formazione';
        arTest.societa = 'Warrant';
        arTest.LeadObject = new Lead();
        
        arList.add(arTest);
        
        Test.startTest();
        List<String> res = InvocableInsertWODuplicateRules.InsertWODuplicateRules(arList);
        System.debug('Result: ' + res[0]);
        System.assertEquals('Errore di inserimento, contattare amministratore', res[0]);
        Test.stopTest();
    }*/
    
}