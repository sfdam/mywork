@IsTest
public with sharing class CommunityUsersBatchTest {
    @TestSetup
    public static void setup() {

        UserRole userRole = new UserRole(DeveloperName = 'TestRole', Name = 'TestRole');
        insert userRole;

        User adminUser = new User(
                UserRoleId = userRole.Id,
                Alias = 'admin',
                Email = 'adminUser@noemail.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
                Country = 'Italy',
                IsActive = true,
                TimeZoneSidKey = 'America/Los_Angeles',
                Username = 'adminUser@noemail.com'
        );
        insert adminUser;

        System.runAs(adminUser) {
            insert new List<Account>{
                    new Account(
                            Name = 'TestAcctPharma1',
                            THR_CustomerIdentificationCode__c = 'TAP_0001',
                            THR_AccountsKey__c = 'EXTTAPID_0001',
                            THR_MAIL__c = 'TestAcctPharma1@test.it',
                            THR_VATNumber__c = 'VATTAP_0001',
                            BillingStreet = 'Via test, 33',
                            BillingPostalCode = '00Test01',
                            BillingCity = 'Rome',
                            BillingCountry = 'Italy',
                            THR_Country__c = 'IT',
                            THR_AccountGroup__c = 'Deposit',
                            THR_DepositDevName__c = 'THR_EMA',
                            OwnerId = adminUser.Id
                    ),
                    new Account(
                            Name = 'TestAcctPharma2',
                            THR_CustomerIdentificationCode__c = 'TAP_0002',
                            THR_AccountsKey__c = 'EXTTAPID_0002',
                            THR_MAIL__c = 'TestAcctPharma2@test.it',
                            THR_VATNumber__c = 'VATTAP_0002',
                            BillingStreet = 'Via test, 33',
                            BillingPostalCode = '00Test02',
                            BillingCity = 'Rome',
                            BillingCountry = 'Italy',
                            THR_Country__c = 'IT',
                            THR_AccountGroup__c = 'Deposit',
                            THR_DepositDevName__c = 'THR_EMA',
                            OwnerId = adminUser.Id
                    )
            };

            insert new List<Community_User__c> {
                    new Community_User__c(LastName__c = 'Community User 1', Email__c = 'communityUser1.@emailTestCommunityUser1.it', Customer_Identification_Code__c = 'TAP_0001'),
                    new Community_User__c(LastName__c = 'Community User 1', Email__c = 'communityUser1.@emailTestCommunityUser1.it', Customer_Identification_Code__c = 'TAP_0001'),
                    new Community_User__c(LastName__c = 'Community User 2', Email__c = 'communityUser2.@emailTestCommunityUser2.it', Customer_Identification_Code__c = 'TAP_0002'),
                    new Community_User__c(LastName__c = 'Community User 3', Email__c = 'communityUser3.@emailTestCommunityUser3.it', Customer_Identification_Code__c = 'TAP_0003')
            };
        }
    }

    @IsTest
    public static void createCommunityUser_test1() {
        Test.startTest();
        Database.executeBatch(new CommunityUsersBatch(), 200);
        Test.stopTest();

        List<Community_User__c> createdCommunityUsers = new List<Community_User__c>();
        List<Community_User__c> errorCommunityUsers = new List<Community_User__c>();
        List<String> emails = new List<String>();

        for(Community_User__c communityUser : [SELECT Id, Status__c, Email__c, Customer_Identification_Code__c FROM Community_User__c]) {
            if(communityUser.Status__c == 'Created') {
                emails.add(communityUser.Email__c);
                createdCommunityUsers.add(communityUser);
            }
            else if(communityUser.Status__c == 'Error') {
                errorCommunityUsers.add(communityUser);
            }
        }

        System.assertEquals(2, createdCommunityUsers.size());
        System.assertEquals(2, errorCommunityUsers.size());

        List<Account> accounts = [SELECT Id, Name, THR_CustomerIdentificationCode__c, (SELECT Id, Name FROM Contacts WHERE Community_Email__c IN :emails) FROM Account];
        System.assertEquals(2, accounts.size());

        List<String> contactIds = new List<String>();
        for(Account account : accounts) {
            System.assertEquals(1, account.Contacts.size());
            contactIds.add(account.Contacts[0].Id);
        }

        List<String> customerIdentificationCodes = new List<String>();
        List<User> users = [SELECT Id, Email, ContactId, Contact.Community_Email__c, Contact.THR_ExternelContactKey__c, Contact.THR_Country__c, Contact.Account.THR_CustomerIdentificationCode__c, Contact.Account.THR_AccountsKey__c, Contact.Account.THR_Country__c FROM User WHERE ContactId IN : contactIds AND Profile.Name = 'Menarini Customer Community Login User'];
        System.assertEquals(2, users.size());

        for(User user : users) {
            customerIdentificationCodes.add(user.Contact.Account.THR_CustomerIdentificationCode__c);
            System.assertEquals(true, user.Email == user.Contact.Community_Email__c);
            System.assertEquals(true, user.Contact.THR_ExternelContactKey__c == user.Contact.Account.THR_AccountsKey__c);
            System.assertEquals(true, user.Contact.THR_Country__c == user.Contact.Account.THR_Country__c);
        }

        for(Community_User__c communityUser : createdCommunityUsers) {
            System.assertEquals(true, customerIdentificationCodes.contains(communityUser.Customer_Identification_Code__c));
        }
    }
}