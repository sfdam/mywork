@isTest
public class TestOnPoliticheCreditizieTrigger {
    static testMethod void testOnPoliticheCreditizieTrigger() {
        // Crea un Account e un PoliticheCreditizie__c collegato
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        CRM_PoliticheCreditizie__c pc = new CRM_PoliticheCreditizie__c(CRM_AccountId__c = acc.Id, CRM_DescrizioneNACE__c = 'Test NACE Description');
        insert pc;
        
        // Verifica che il campo DescrizioneNACE__c dell'Account sia stato copiato correttamente dal PoliticheCreditizie__c durante l'inserimento
        acc = [SELECT Id, CRM_DescrizioneNACE__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Test NACE Description', acc.CRM_DescrizioneNACE__c);
        
        // Aggiorna il PoliticheCreditizie__c e verifica che il campo DescrizioneNACE__c dell'Account sia stato aggiornato correttamente
        pc.CRM_DescrizioneNACE__c = 'Updated NACE Description';
        update pc;
        acc = [SELECT Id, CRM_DescrizioneNACE__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Updated NACE Description', acc.CRM_DescrizioneNACE__c);
    }
}