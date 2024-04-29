public with sharing class indicatoriKPI_Controller {

     @AuraEnabled
    public static Boolean getNdgOFS(String recId){

        List<Account> ndgOFS = [SELECT id, PTF_OFS__c FROM Account WHERE PTF_Portafoglio__c=:recId AND PTF_OFS__c = true AND PTF_DeletionDate__c = NULL];

        System.debug('@@@GR recordId: '+ recId);
        System.debug('GR ndgOFS: ' + ndgOFS);

        return ndgOFS.size() > 0 ? true : false;
        
    }
}