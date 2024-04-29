public with sharing class CommunityUser {

    private static final String TIME_ZONE_SID_KEY = 'Europe/Rome';
    private static final String LOCALE_SID_KEY = 'it_IT';
    private static final String EMAIL_ENCODING_KEY = 'ISO-8859-1';
    private static final String LANGUAGE_LOCALE_KEY = 'it';

    public static String createCommunityUser(Account account, Profile profile, String username, String email, String firstName, String lastName, String alias, String timeZoneSidKey, String localeSidKey, String emailEncodingKey, String languageLocaleKey) {
        Savepoint savepoint = Database.setSavepoint();

        try {
            Contact contact = new Contact(FirstName = firstName, LastName = lastName, AccountId = account.Id, Email = email, THR_ExternelContactKey__c = account.THR_AccountsKey__c, THR_Country__c = account.THR_Country__c);
            insert contact;

            User user = new User(
                    ContactId = contact.Id,
                    Username = String.isBlank(username) ? (email + '.' + EncodingUtil.convertToHex(Crypto.generateAesKey(128))) : username,
                    FirstName = firstName,
                    LastName = lastName,
                    Alias = String.isBlank(alias) ? (lastName.length() > 8 ? lastName.substring(0, 8) : lastName) : alias,
                    Email = email,
                    CommunityNickname = lastName,
                    ProfileId = profile.Id,
                    TimeZoneSidKey = String.isBlank(timeZoneSidKey) ? TIME_ZONE_SID_KEY : timeZoneSidKey,
                    LocaleSidKey = String.isBlank(localeSidKey) ? LOCALE_SID_KEY : localeSidKey,
                    EmailEncodingKey = String.isBlank(emailEncodingKey) ? EMAIL_ENCODING_KEY : emailEncodingKey,
                    LanguageLocaleKey = String.isBlank(languageLocaleKey) ? LANGUAGE_LOCALE_KEY : languageLocaleKey
            );

            insert user;
            return user.Id;
        }
        catch (Exception ex) {
            Database.rollback(savepoint);
            throw ex;
        }
    }

    public static String createCommunityUser(Account account, Profile profile, String email, String firstName, String lastName) {
        return createCommunityUser(account, profile, null, email, firstName, lastName, null, null, null, null, null);

    }
}