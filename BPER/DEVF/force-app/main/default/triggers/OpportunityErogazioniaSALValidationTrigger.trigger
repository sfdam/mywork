trigger OpportunityErogazioniaSALValidationTrigger on Opportunity (before update) {
    
    if(Trigger.isUpdate && Trigger.isBefore){
         Set<Id> opportunityIds = new Set<Id>();
    String idRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunita_Magazzino_Finanziamenti').getRecordTypeId();
    // Trova le opportunità che devono essere validate
    for (Opportunity opp : Trigger.new) {
        system.debug('erogazione a sal' +opp.CRM_Erogazione_a_SAL__c);
        system.debug('stagename ' +opp.StageName);
        system.debug('devname ' +opp.RecordTypeId);
        system.debug('old stange name ' +Trigger.oldMap.get(opp.Id).StageName);
        if (opp.CRM_Erogazione_a_SAL__c &&
            opp.StageName == 'Chiusa' &&
            Trigger.oldMap.get(opp.Id).StageName == 'In erogazione' && 
            opp.RecordTypeId ==idRT) {
            opportunityIds.add(opp.Id);
        }
    }
    
    // Attiva il trigger solo se ci sono opportunità interessate
    if (!opportunityIds.isEmpty()) {
        // Trova le erogazioni valide per le opportunità selezionate
        Map<Id, Integer> erogazioniCountByOppId = new Map<Id, Integer>();
        for (AggregateResult result : [
            SELECT CRM_Opportunity__c, COUNT(Id)
            FROM Forecast_Erogazioni__c
            WHERE CRM_Opportunity__c IN :opportunityIds
            AND CRM_Importo__c > 0
            GROUP BY CRM_Opportunity__c
        ]) {
            erogazioniCountByOppId.put((Id)result.get('CRM_Opportunity__c'), (Integer)result.get('expr0'));
        }
        
        // Controlla le erogazioni per ciascuna opportunità e aggiungi un messaggio di errore se necessario
        for (Id oppId : opportunityIds) {
            Integer erogazioniCount = erogazioniCountByOppId.get(oppId);
            if (erogazioniCount == null || erogazioniCount == 0) {
                Opportunity opp = Trigger.newMap.get(oppId);
                opp.addError('Necessario inserire almeno un\'erogazione a SAL per accedere alla fase Chiusa');
            }
        }
    }
    }
   
}