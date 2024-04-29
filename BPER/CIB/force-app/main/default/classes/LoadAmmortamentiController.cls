public without sharing class LoadAmmortamentiController {
    @AuraEnabled
    public static Object init(String recordId) {

        return new Map<String, Object>{
            'linee' => [SELECT Id, idAmmortamentoLinea__c, ServizioAmmortamento__c FROM Linea__c WHERE Simulazione__c =: recordId AND ServizioAmmortamento__c = false]
        };
    }

    @AuraEnabled
    public static void save(List<Linea__c> recordsToUpdateList, List<RataLinea__c> rateToInsert){
        System.debug('Dk recordsToUpdateList: ' + JSON.serialize(recordsToUpdateList));
        System.debug('Dk rateToInsert: ' + JSON.serialize(rateToInsert));
        try {
            upsert recordsToUpdateList;
            insert rateToInsert;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}