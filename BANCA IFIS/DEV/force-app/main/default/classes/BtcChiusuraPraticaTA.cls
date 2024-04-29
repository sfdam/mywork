/**
* Progetto:         Banca IFIS
* Developer:        Marco Tomasi
* Description:      Batch che provvede a settare 'Stato = Chiuso' e 'Fase = Persa' su tutte le commesse con  in cui non è stato effettuato
                    alcun accesso negli ultimi 60 giorni.
*/

global class BtcChiusuraPraticaTA implements Database.Batchable<SObject>{

	global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id FROM Cessione__c WHERE (DataUltimoAccesso__c < LAST_N_DAYS:60) AND (Stato__c = \'0\' OR Stato__c = \'1\')');
    }

	global void execute(Database.BatchableContext BC, List<Cessione__c> cessList){
        MailUtils.isMailTiAnticipoDisabilitate = true;
        U.massSet(cessList, 'Stato__c', '5');
        update(cessList);
    }

    global void finish(Database.BatchableContext BC) {}

}