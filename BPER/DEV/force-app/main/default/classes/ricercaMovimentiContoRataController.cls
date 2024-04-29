public with sharing class ricercaMovimentiContoRataController {

    @AuraEnabled
    public static List<ParametriMovimentiContoCorrente__mdt> getCustomMetadata(){
       
        return [SELECT CodiceCasuale__c, TipoMovimento__c FROM ParametriMovimentiContoCorrente__mdt];
   
    }

}