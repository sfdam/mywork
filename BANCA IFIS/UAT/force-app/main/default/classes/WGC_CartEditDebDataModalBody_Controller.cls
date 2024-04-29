public without sharing class WGC_CartEditDebDataModalBody_Controller {

    @AuraEnabled
    public static String getAtecoStatus(String recordId) {
        system.debug('recordID: '+recordId);
        List<Account> accList = [SELECT Ateco__c FROM Account WHERE Id = :recordId];
        System.debug('accList: '+accList);
        
        
        Ateco__c ateco = [ SELECT Id, Name, Cedacri__c, Descrizione__c, Status__c FROM Ateco__c WHERE Cedacri__c =: accList[0].Ateco__c LIMIT 1];

        return ateco.Status__c;
    }
}