@IsTest
public with sharing class CommunityUserTest {
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
            Account account = new Account(
                    Name = 'TestAcctPharma',
                    THR_CustomerIdentificationCode__c = 'TAP_0001',
                    THR_AccountsKey__c = 'EXTTAPID_0001',
                    THR_MAIL__c = 'TestAcctPharma@test.it',
                    THR_VATNumber__c = 'VATTAP_0001',
                    BillingStreet = 'Via test, 33',
                    BillingPostalCode = '00Test01',
                    BillingCity = 'Rome',
                    BillingCountry = 'Italy',
                    THR_Country__c = 'IT',
                    THR_AccountGroup__c = 'Deposit',
                    THR_DepositDevName__c = 'THR_EMA',
                    OwnerId = adminUser.Id
            );
            insert account;
        }
    }

    @IsTest
    public static void createCommunityUser_test1() {
        String userId;
        Account account = [SELECT Id, THR_Country__c, THR_AccountsKey__c FROM Account LIMIT 1];
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Menarini Customer Community Login User' LIMIT 1];
        String email = 'firstName.lastName@testEmail.it';
        String firstName;
        String lastName  = 'Community User';

        Test.startTest();
        userId = CommunityUser.createCommunityUser(account, profile, email, firstName, lastName);
        Test.stopTest();

        System.assertEquals(true, String.isNotBlank(userId));
    }

    @IsTest
    public static void createCommunityUser_test2() {
        String userId;

        Test.startTest();
        try {
            userId = CommunityUser.createCommunityUser(null, null, null, null, null);
        }
        catch (Exception ex) {
            System.debug('---> ' + ex.getMessage());
        }
        Test.stopTest();

        System.assertEquals(null, userId);
    }
}