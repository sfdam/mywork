@IsTest
public with sharing class CommunityPromotionsControllerTest {
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
                Country ='Italy',
                IsActive = true,
                TimeZoneSidKey ='America/Los_Angeles',
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

            Contact contact = new Contact(
                    FirstName = 'FirstName',
                    LastName = 'LastName',
                    AccountId = account.Id,
                    Email = 'firstName.lastName@test.it',
                    THR_Country__c = 'IT'
            );
            insert contact;

            Campaign campaign = new Campaign(
                    Name = 'Test',
                    IsActive = true,
                    StartDate = System.today().addMonths(-1),
                    EndDate = System.today().addMonths(1)
            );
            insert campaign;

            CampaignMember campaignMember = new CampaignMember(
                    ContactId = contact.Id,
                    Status = 'sent',
                    CampaignId = campaign.Id
            );
            insert campaignMember;

            User customerCommunityLoginUser = new User(
                    Alias = 'test123',
                    Email = 'test123@noemail.com',
                    EmailEncodingKey = 'UTF-8',
                    LastName = 'Testing',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    ProfileId = [SELECT Id FROM Profile WHERE Name = 'Menarini Customer Community Login User' LIMIT 1].Id,
                    Country = 'Italy',
                    IsActive = true,
                    ContactId = contact.Id,
                    TimeZoneSidKey = 'America/Los_Angeles',
                    Username = 'tester@noemail.com'
            );

            insert customerCommunityLoginUser;
        }
    }

    @IsTest
    public static void getPromotions_test1() {
        User user = [SELECT Id FROM User WHERE Username = 'tester@noemail.com' LIMIT 1];
        CommunityPromotionsController.Promotions promotions;

        Test.startTest();
        System.runAs(user) {
            promotions = CommunityPromotionsController.getPromotions();
        }
        Test.stopTest();

        System.assertEquals(1, promotions.campaignMembers.size());
    }

    @IsTest
    public static void getBase64File_test1() {
        User user = [SELECT Id FROM User WHERE Username = 'tester@noemail.com' LIMIT 1];
        String base64File;
        ContentVersion contentVersion = new ContentVersion(
                Title = 'test',
                PathOnClient = 'test',
                VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body')
        );
        insert contentVersion;

        ContentDocument contentDocument = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
                LinkedEntityId = [SELECT Id FROM Campaign LIMIT 1].Id,
                ContentDocumentId = contentDocument.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
        );
        insert contentDocumentLink;

        Test.startTest();
        System.runAs(user) {
            base64File = CommunityPromotionsController.getBase64File(contentDocument.Id);
        }
        Test.stopTest();

        System.assertEquals(true, String.isNotBlank(base64File));
    }
}