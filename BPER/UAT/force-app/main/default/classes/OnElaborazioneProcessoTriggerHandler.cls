/****
 * Name			:	OnElaborazioneProcessoTriggerHandler
 * Author		:	Ezio Dal Bo @TEN
 * Create Date	:	2020-10-13
 ***/	
public class OnElaborazioneProcessoTriggerHandler {
    
    public static void afterInsert(List<Elaborazione_Processo__c> newRecords) {
        List<string> names = new list<string>();
        for(Elaborazione_Processo__c ep: newRecords){
            names.add(ep.Name);
        }
        Map<string, List<ScheduledJob__c>> mappa = new Map<string, List<ScheduledJob__c>>();
        
        List<ScheduledJob__c> listaScheduledJobs = [
            SELECT	Id,
            		Codice_Gruppo__c,
            		Nome_Classe__c,
            		Trigger__c,
            		Batch_size__c,
            		Tipologia_Della_Classe__c,
            		Ordine_Di_Esecuzione__c
            FROM ScheduledJob__c 
            WHERE Trigger__c = true 
            AND attivo__c = true                                                 
            AND codice_gruppo__c in : names
            ORDER BY Ordine_Di_Esecuzione__c ASC
        ];
        for(ScheduledJob__c s: listaScheduledJobs){
            system.debug('dentro lista scheduled jobs');
            if(!mappa.containskey(s.codice_gruppo__c)){
                List<ScheduledJob__c> nuovaLista = new List<ScheduledJob__c>();
                nuovaLista.add(s);
                mappa.put(s.codice_gruppo__c, nuovaLista);
            }
            else
            {
                List<ScheduledJob__c> nuovaLista = mappa.get(s.Codice_Gruppo__c);
                nuovaLista.add(s);
                mappa.put(s.codice_gruppo__c, nuovaLista);
            }
        }
        system.debug('mappa scheduled jobs: ' +mappa);
        for(string codice_gruppo: mappa.keyset()){
            List<ScheduledJob__c> listaScheduledJobsCorrispondenti = mappa.get(codice_gruppo);
            system.debug('nell esecuzione: ' +listaScheduledJobsCorrispondenti);
            jobRunner.executeNext(listaScheduledJobsCorrispondenti);
        }
    }
}