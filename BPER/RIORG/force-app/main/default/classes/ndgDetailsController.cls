public with sharing class ndgDetailsController {
    @AuraEnabled
    public static List<Account> getAllData(String recordId){
        System.debug('MC Record ID '+recordId);
        return [SELECT  id,Name,CRM_NDG__c, ModelloDiServizio__c, PTF_GruppoComportamentale__c, PTF_SegmentoComportamentale__c, PTF_Banca__c, PTF_Banca__r.Name,PTF_DirezioneRegionale__c, PTF_DirezioneRegionale__r.Name,PTF_Area__c, PTF_Area__r.Name,PTF_OFS__c, PTF_Filiale__c, PTF_Filiale__r.name,PTF_NaturaGiuridica__c, 
                        PTF_StatoCRM__c, PTF_StatoAnagrafe__c, PTF_StatoSofferenza__c, AnnualRevenue, PTF_Accordato__c, PTF_Utilizzato__c, PTF_Patrimonio__c,PTF_Portafoglio__c,PTF_Portafoglio__r.name,PTF_MiniPortafoglio__c,
                        PTF_MiniPortafoglio__r.Name,PTF_MiniPortafoglio__r.PTF_SL__r.name 
                        FROM  Account 
                        WHERE id=:recordId];
    }
}