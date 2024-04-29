public with sharing class HelloWorldController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountList() {
        return [
            SELECT Id, Name, Phone, Type
            FROM Account
            LIMIT 10
        ];
    }

}