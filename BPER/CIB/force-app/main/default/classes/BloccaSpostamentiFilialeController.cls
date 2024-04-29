public without sharing class BloccaSpostamentiFilialeController {
    @AuraEnabled
    public static Account getRecord(String accountId) {
        try {
            return [SELECT Id, PTF_BloccaSpostamentiInFiliale__c, PTF_BloccaSpostamentiVersoFiliale__c, PTF_BloccaSpostamentiFiliale__c FROM Account WHERE Id =: accountId LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateRecord(String accountId, String field, Boolean value) {
        Account account = new Account(Id = accountId);
        account.put('PTF_' + field + '__c', value);
        update account;
    }
}