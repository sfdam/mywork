public without sharing class CommunityUsersBatch implements Database.Batchable<SObject> {

    private static final String QUERY = 'SELECT Id, Name, FirstName__c, LastName__c, Email__c, Status__c, Description__c, Customer_Identification_Code__c FROM Community_User__c WHERE Status__c = \'Waiting\'';
    private static final String PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'Menarini Customer Community Login User' LIMIT 1].Id;
    private static final String TIME_ZONE_SID_KEY = 'Europe/Rome';
    private static final String LOCALE_SID_KEY = 'it_IT';
    private static final String EMAIL_ENCODING_KEY = 'ISO-8859-1';
    private static final String LANGUAGE_LOCALE_KEY = 'it';
    private static final Integer COMMUNITY_USER_DESCRIPTION_MAX_LENGTH = Schema.getGlobalDescribe().get('Community_User__c').getDescribe().fields.getMap().get('Description__c').getDescribe().getLength();

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(QUERY);
    }

    public void execute(Database.BatchableContext BC, List<Community_User__c> scope){
        Set<String>  customerIdentificationCodes = new Set<String>();
        Map<String, Account> accountMap = new Map<String, Account>();

        for(Community_User__c communityUser : scope) {
            customerIdentificationCodes.add(communityUser.Customer_Identification_Code__c);
        }

        System.debug('[CommunityUsersBatch] ---> customerIdentificationCodes: ' + JSON.serialize(customerIdentificationCodes));

        if(!customerIdentificationCodes.isEmpty()) {
            for(Account account : [SELECT Id, THR_CustomerIdentificationCode__c, THR_AccountsKey__c, THR_Country__c FROM Account WHERE THR_CustomerIdentificationCode__c != NULL AND THR_CustomerIdentificationCode__c IN :customerIdentificationCodes]) {
                accountMap.put(account.THR_CustomerIdentificationCode__c, account);
            }
        }

        System.debug('[CommunityUsersBatch] ---> accountMap: ' + JSON.serialize(accountMap));

        List<Contact> contacts = new List<Contact>();
        List<User> users = new List<User>();
        List<Community_User__c> successCommunityUsersForAccount = new List<Community_User__c>();
        List<Community_User__c> successCommunityUsersForContact = new List<Community_User__c>();
        List<Community_User__c> successCommunityUsersForUser = new List<Community_User__c>();
        List<Community_User__c> errorCommunityUsers = new List<Community_User__c>();

        for(Community_User__c communityUser : scope) {
            Account currentAccount = accountMap.get(communityUser.Customer_Identification_Code__c);

            if (currentAccount != null) {
                successCommunityUsersForAccount.add(communityUser);

                contacts.add(new Contact(
                        FirstName = communityUser.FirstName__c,
                        LastName = communityUser.LastName__c,
                        Email = communityUser.Email__c,
                        Community_Email__c = communityUser.Email__c,
                        AccountId = currentAccount.Id,
                        THR_ExternelContactKey__c = currentAccount.THR_AccountsKey__c,
                        THR_Country__c = currentAccount.THR_Country__c)
                );
            }
            else {
                communityUser.Status__c = 'Error';
                communityUser.Description__c = 'Can not find any matching Account with Customer Identification Code \'' + communityUser.Customer_Identification_Code__c + '\'';
                errorCommunityUsers.add(communityUser);
            }
        }

        System.debug('[CommunityUsersBatch] ---> successCommunityUsersForAccount: ' + JSON.serialize(successCommunityUsersForAccount));
        System.debug('[CommunityUsersBatch] ---> errorCommunityUsers: ' + JSON.serialize(errorCommunityUsers));
        System.debug('[CommunityUsersBatch] ---> contacts: ' + JSON.serialize(contacts));
        Database.SaveResult[] contactSaveResults = Database.insert(contacts, false);

        for(Integer i = 0; i < successCommunityUsersForAccount.size(); i++) {
            if(contactSaveResults[i].isSuccess()) {
                successCommunityUsersForContact.add(successCommunityUsersForAccount[i]);

                users.add(new User(
                        ContactId = contactSaveResults[i].getId(),
                        Username = successCommunityUsersForAccount[i].Email__c /*+ '.' + EncodingUtil.convertToHex(Crypto.generateAesKey(128))*/,
                        FirstName = successCommunityUsersForAccount[i].FirstName__c,
                        LastName = successCommunityUsersForAccount[i].LastName__c,
                        Alias = successCommunityUsersForAccount[i].LastName__c.length() > 8 ? successCommunityUsersForAccount[i].LastName__c.substring(0, 8) : successCommunityUsersForAccount[i].LastName__c,
                        Email = successCommunityUsersForAccount[i].Email__c,
                        CommunityNickname = successCommunityUsersForAccount[i].Email__c.length() > 40 ? successCommunityUsersForAccount[i].Email__c.substring(0, 40) : successCommunityUsersForAccount[i].Email__c,
                        ProfileId = PROFILE_ID,
                        TimeZoneSidKey = TIME_ZONE_SID_KEY,
                        LocaleSidKey = LOCALE_SID_KEY,
                        EmailEncodingKey = EMAIL_ENCODING_KEY,
                        LanguageLocaleKey = LANGUAGE_LOCALE_KEY)
                );
            }
            else {
                successCommunityUsersForAccount[i].Status__c = 'Error';
                successCommunityUsersForAccount[i].Description__c = JSON.serialize(contactSaveResults[i].getErrors()).abbreviate(COMMUNITY_USER_DESCRIPTION_MAX_LENGTH);
                errorCommunityUsers.add(successCommunityUsersForAccount[i]);
            }
        }

        System.debug('[CommunityUsersBatch] ---> successCommunityUsersForContact: ' + JSON.serialize(successCommunityUsersForContact));
        System.debug('[CommunityUsersBatch] ---> errorCommunityUsers: ' + JSON.serialize(errorCommunityUsers));
        System.debug('[CommunityUsersBatch] ---> users: ' + JSON.serialize(users));
        List<Contact> contactsToDelete = new List<Contact>();
        Database.SaveResult[] userSaveResult = Database.insert(users, false);

        for(Integer i = 0; i < successCommunityUsersForContact.size(); i++) {
            if(userSaveResult[i].isSuccess()) {
                successCommunityUsersForContact[i].Status__c = 'Created';
                successCommunityUsersForUser.add(successCommunityUsersForContact[i]);
            }
            else {
                contactsToDelete.add(new Contact(Id = users[i].ContactId));
                successCommunityUsersForContact[i].Status__c = 'Error';
                successCommunityUsersForContact[i].Description__c = JSON.serialize(userSaveResult[i].getErrors()).abbreviate(COMMUNITY_USER_DESCRIPTION_MAX_LENGTH);
                errorCommunityUsers.add(successCommunityUsersForContact[i]);
            }
        }

        System.debug('[CommunityUsersBatch] ---> contactsToDelete: ' + JSON.serialize(contactsToDelete));
        System.debug('[CommunityUsersBatch] ---> successCommunityUsersForUser: ' + JSON.serialize(successCommunityUsersForUser));
        System.debug('[CommunityUsersBatch] ---> errorCommunityUsers: ' + JSON.serialize(errorCommunityUsers));
        List<Community_User__c> communityUsersToUpdate = new List<Community_User__c>();
        communityUsersToUpdate.addAll(successCommunityUsersForUser);
        communityUsersToUpdate.addAll(errorCommunityUsers);
        update communityUsersToUpdate;
        delete contactsToDelete;
    }

    public void finish(Database.BatchableContext BC){}
}