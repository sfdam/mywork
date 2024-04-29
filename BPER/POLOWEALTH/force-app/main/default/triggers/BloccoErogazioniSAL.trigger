trigger BloccoErogazioniSAL on Forecast_Erogazioni__c (before insert, before update) {
    for(Forecast_Erogazioni__c erogazione : Trigger.new) {
        if (Trigger.isInsert || (Trigger.isUpdate && (erogazione.CRM_Anno__c != Trigger.oldMap.get(erogazione.Id).CRM_Anno__c || erogazione.CRM_Mese__c != Trigger.oldMap.get(erogazione.Id).CRM_Mese__c))) {
            // Recupera l'opportunità associata all'erogazione
            Opportunity opp = [SELECT Id, CloseDate FROM Opportunity WHERE Id = :erogazione.CRM_Opportunity__c LIMIT 1];
            
            // Controlla se l'opportunità è stata trovata e se i valori di anno e mese sono superiori alla CloseDate
            if(opp != null && erogazione.CRM_Anno__c != null && erogazione.CRM_Mese__c != null) {
                Integer annoOpportunita = opp.CloseDate.year();
                Integer meseOpportunita = opp.CloseDate.month();
                
                // Mappa per convertire il nome del mese in un numero
                Map<String, Integer> mappaMesi = new Map<String, Integer>{
                    'Gennaio' => 1,
                    'Febbraio' => 2,
                    'Marzo' => 3,
                    'Aprile' => 4,
                    'Maggio' => 5,
                    'Giugno' => 6,
                    'Luglio' => 7,
                    'Agosto' => 8,
                    'Settembre' => 9,
                    'Ottobre' => 10,
                    'Novembre' => 11,
                    'Dicembre' => 12
                };
                
                Integer annoErogazione = Integer.valueOf(erogazione.CRM_Anno__c);
                Integer meseErogazione = mappaMesi.get(erogazione.CRM_Mese__c);
                
                if (annoErogazione > annoOpportunita || (annoErogazione == annoOpportunita && meseErogazione > meseOpportunita)) {
                    erogazione.addError('Impossibile ' + (Trigger.isInsert ? 'creare' : 'modificare') + ' l\'erogazione: il mese e/o l\'anno dell\'erogazione non possono essere successivi alla data di chiusura dell\'opportunità.');
                }
            }
        }
    }
}