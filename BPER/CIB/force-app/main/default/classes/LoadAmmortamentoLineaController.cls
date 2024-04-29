public without sharing class LoadAmmortamentoLineaController {

    @AuraEnabled
    public static Object init(String recordId) {

        return new Map<String, Object>{
            'record' => [SELECT Id, idAmmortamentoLinea__c, ServizioAmmortamento__c FROM Linea__c WHERE Id =: recordId],
            'rate' => Database.query(SV_Utilities.selectAllField('RataLinea__c') + ' WHERE Linea__c =: recordId ORDER BY Numerorata__c,Ratacorrispondentemodificatasso__c,ProgrPeriodo__c ASC')
        };
    }
    
    @AuraEnabled
    public static void save(Linea__c record, List<RataLinea__c> rateToInsert){
        System.debug('Dk record: ' + JSON.serialize(record));
        System.debug('Dk rateToInsert: ' + JSON.serialize(rateToInsert));
        try {
            upsert record;
            insert rateToInsert;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}