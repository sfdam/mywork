public with sharing class ContactController {
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts() {

        return [SELECT id, FirstName, LastName, Email, AccountId FROM Contact];
    }
}