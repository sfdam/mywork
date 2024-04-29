public with sharing class crudAbilitatoOffFuorisede_controller {
    @AuraEnabled
    public static MyWrapper init(String currentUserId, String recordId) {
        MyWrapper result = new MyWrapper();

        // Query sull'oggetto Account
        Account acc = [SELECT CRM_NDG__c, FinServ__BankNumber__c FROM Account WHERE Id = :recordId LIMIT 1];
        result.crmNdg = acc.CRM_NDG__c;
        result.bankNumber = acc.FinServ__BankNumber__c;

        // Query sull'oggetto User
        User user = [SELECT FederationIdentifier FROM User WHERE Id = :currentUserId LIMIT 1];
        result.federationIdentifier = user.FederationIdentifier;

        return result;
    }

    public class MyWrapper {
        @AuraEnabled public String crmNdg;
        @AuraEnabled public String bankNumber;
        @AuraEnabled public String federationIdentifier;
    }
}