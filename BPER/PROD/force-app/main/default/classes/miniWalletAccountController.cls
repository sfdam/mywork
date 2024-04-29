public with sharing class miniWalletAccountController {
    @AuraEnabled
    public static List<MiniWallet__c> getAllData(String recordId){
        
        return [SELECT Id, Name, PTF_Portafoglio__c, Referente__c,Referente__r.name, PTF_Filiale__c, PTF_Capofila__c, PTF_Area__c, PTF_DirezioneRegionale__c, PTF_Banca__c, PTF_SL__c, PTF_SL__r.Name 
                       FROM MiniWallet__c 
                       WHERE PTF_Portafoglio__c=:recordId];
    }
    @AuraEnabled
    public static List<AggregateResult> getNumNDG(String recordId){
        
        return [SELECT count(id) numMiniWallet,PTF_MiniPortafoglio__c
                FROM Account
                WHERE PTF_MiniPortafoglio__c !=null and PTF_Portafoglio__c=:recordId  group by PTF_MiniPortafoglio__c];
    }
    

}