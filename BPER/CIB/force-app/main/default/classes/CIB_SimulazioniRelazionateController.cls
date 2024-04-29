public class CIB_SimulazioniRelazionateController {
    
    @AuraEnabled
    public static Map<String, Object> init(String recordId){
        System.debug('DK START init');
        try {
            Map<String, List<Object>> optionsMap = new Map<String, List<Object>>();
            // optionsMap.put('Modello_di_Servizio__c', new List<Object>());
            optionsMap.put('Provincia__c', new List<Object>());
            optionsMap.put('Segmento_di_Rischio__c', new List<Object>());
            optionsMap.put('Classe_di_rating__c', new List<Object>());
            optionsMap.put('Giudizio_slotting_criteria__c', new List<Object>());
            optionsMap.put('Classe_di_merito_altre_variabili__c', new List<Object>());

            // linee
            optionsMap.put('Formatecnica__c', new List<Object>());
            optionsMap.put('Tipo_di_ammortamento__c', new List<Object>());
            optionsMap.put('Tipo_funding__c', new List<Object>());
            optionsMap.put('Valuta__c', new List<Object>());
            optionsMap.put('Durata__c', new List<Object>());
            optionsMap.put('Periodicita_rata__c', new List<Object>());
            optionsMap.put('Preammortamento__c', new List<Object>());
            optionsMap.put('Numero_periodi_di_erogazione__c', new List<Object>());
            optionsMap.put('Tipo_garanzia__c', new List<Object>());
            optionsMap.put('Tipo_pegno__c', new List<Object>());
            optionsMap.put('Tipo_tasso__c', new List<Object>());
            optionsMap.put('Tipo_garanzia__c', new List<Object>());
            optionsMap.put('Indicizzazione_tasso_variabile__c', new List<Object>());
            optionsMap.put('Sensitivity__c', new List<Object>());
            optionsMap.put('Ratacorrispondentemodificatasso__c', new List<Object>());

            Schema.SObjectType simObjSobjectType = Schema.getGlobalDescribe().get('Simulazione__c');
            Schema.SObjectType lineaObjSobjectType = Schema.getGlobalDescribe().get('Linea__c');
            for(String field: optionsMap.keySet()){
                if(simObjSobjectType.getDescribe().fields.getMap().containsKey(field)){

                    for(Schema.PicklistEntry picklistValue : simObjSobjectType.getDescribe().fields.getMap().get(field).getDescribe().getPicklistValues()){
                        if(picklistValue.active){
                            optionsMap.get(field).add(new Map<String, String>{'label' => picklistValue.getLabel(), 'value' => picklistValue.getValue()});
                        }
                    }
                }else if(lineaObjSobjectType.getDescribe().fields.getMap().containsKey(field)){

                    for(Schema.PicklistEntry picklistValue : lineaObjSobjectType.getDescribe().fields.getMap().get(field).getDescribe().getPicklistValues()){
                        if(picklistValue.active){
                            optionsMap.get(field).add(new Map<String, String>{'label' => picklistValue.getLabel(), 'value' => picklistValue.getValue()});
                        }
                    }
                }
            }
            Map<String, Object> response = new Map<String, Object>{
                'recordInfo' => [SELECT Id, OwnerId, Owner.Name FROM Opportunity WHERE Id =: recordId], 
                'simulazioni' => Database.query(SV_Utilities.selectAllField('Simulazione__c').replace('FROM', ', Owner.Name, (' + SV_Utilities.selectAllField('Linea__c').replace('Linea__c', 'Linee__r') + ') FROM') + ' WHERE Opportunity__c =: recordId ORDER BY Name ASC'),
                'optionsMap' => optionsMap
            };
            return response;
        } catch (Exception ex) {
            System.debug('DK Exception: ' + ex.getMessage() + '; at:' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage() + '; at:' + ex.getStackTraceString());
        }
    }
}