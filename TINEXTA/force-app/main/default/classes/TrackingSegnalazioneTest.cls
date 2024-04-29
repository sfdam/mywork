@isTest
public class TrackingSegnalazioneTest {
	
    @TestSetup
    static void makeData() {       
        Segnalazione__c s = new Segnalazione__c(
        	Oggetto__c = 'Test',
            Tipologia__c = 'Bug',
            Priorita__c = 'Media',
            Impatto_utente__c = 'Grave',
            Importanza_funzione__c = 'Critica',
            Stato__c = 'Nuova'
        );
        insert s;
        Segnalazione__c s1 = new Segnalazione__c(
        	Oggetto__c = 'Test',
            Tipologia__c = 'Change Request',
            Priorita__c = 'Media',
            Impatto_utente__c = 'Grave',
            Importanza_funzione__c = 'Critica',
            Stato__c = 'Nuova'
        );
        insert s1;

        s.Stato__c = 'In analisi';
        update s;

        Tracking_segnalazione__c ts = new Tracking_Segnalazione__c(
        	Segnalazione__c = s.Id,
            Inizio__c = System.now().addMinutes(-75),
            Fine__c = System.now()
        );
        
        insert ts;
    }
    
    @isTest
    static void testOK() {
        Segnalazione__c s = [SELECT Id, Stato__c FROM Segnalazione__c WHERE Stato__c = 'In analisi'];
        s.Stato__c = 'Completata';
        update s;
        Test.startTest();
        	update [SELECT Id FROM Tracking_segnalazione__c LIMIT 1]; 
        Test.stopTest();
    }
}