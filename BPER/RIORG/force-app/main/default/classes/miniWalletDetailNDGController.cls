public with sharing class miniWalletDetailNDGController {
    @AuraEnabled
    public static List<Account> getAllData(String recordId){
        System.debug('MC Record ID '+recordId);
        return [SELECT  id,PTF_Portafoglio__c,PTF_Portafoglio__r.name,PTF_MiniPortafoglio__c,PTF_MiniPortafoglio__r.Name,PTF_MiniPortafoglio__r.PTF_SL__r.name 
                FROM  Account 
                WHERE id=:recordId];
    }
}