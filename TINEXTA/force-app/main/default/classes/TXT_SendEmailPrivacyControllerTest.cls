@isTest
public class TXT_SendEmailPrivacyControllerTest {
    
    @TestSetup
    static void makeData(){
        // Folder f = new Folder(Name = 'TestFolderEmail');
        // insert f;
        List<EmailTemplate> emList = new List<EmailTemplate>();
        EmailTemplate em1 = new EmailTemplate(Name = 'TXT informativa privacy contitolari', DeveloperName = 'TXT_informativa_privacy_contitolari', Body = 'TestBody1', FolderId =  UserInfo.getUserId() /*f.Id*/, TemplateType = 'text');
        EmailTemplate em2 = new EmailTemplate(Name = 'TXT informativa privacy', DeveloperName = 'TXT_informativa_privacy', Body = 'TestBody2', FolderId = UserInfo.getUserId() /*f.Id*/, TemplateType = 'text');
        emList.add(em1);
        emList.add(em2);

        insert emList;


        Test.startTest();

        Test.stopTest();
    }

    @isTest
    static void testUserHasAccess(){
        Test.startTest();
            TXT_SendEmailPrivacyController.userHasAccess();
        Test.stopTest();
    }


    @isTest
    static void testGetEmailTemplate(){
        Test.startTest();
            TXT_SendEmailPrivacyController.getEmailTemplate();
        Test.stopTest();
    }

    @isTest
    static void testSendMailOK(){
        EmailTemplate em = [SELECT Id, Name, Body FROM EmailTemplate LIMIT 1];
        EmailTemplate em2 = [SELECT Id, Name, Body FROM EmailTemplate WHERE DeveloperName = 'TXT_informativa_privacy_contitolari' LIMIT 1];
        // Account acc = [SELECT Id FROM Account LIMIT 1];
        // Lead l = [SELECT Id FROM Lead LIMIT 1];
        // Contact c = [SELECT Id FROM Contact WHERE AccountId =: acc.Id LIMIT 1];
        List<Lead> l = TestDataFactory.createLeads(1);
        l[0].Company = 'Test123';
        l[0].LastName = 'Test123';
        l[0].Email = 'test@test.it.invalid';
        insert l;

        List<Account> acc = TestDataFactory.createAccounts(1);
        insert acc;

        Contact c = new Contact(FirstName = 'TestContact', LastName = 'Test', AccountId = acc[0].Id);
        insert c;

        Test.startTest();
            // TXT_SendEmailPrivacyController.sendEmail(em.Id, em.Body, acc.Id, 'Account');
            TXT_SendEmailPrivacyController.sendEmail(em.Id, em.Body, l[0].Id, 'Lead');
            TXT_SendEmailPrivacyController.sendEmail(em.Id, em.Body, c.Id, 'Contact');
            TXT_SendEmailPrivacyController.sendEmail(em2.Id, em2.Body, c.Id, 'Contact');
        Test.stopTest();
    }

    @isTest
    static void testSendMailKO(){
        EmailTemplate em = [SELECT Id, Name, Body FROM EmailTemplate LIMIT 1];

        List<Lead> l = TestDataFactory.createLeads(1);
        l[0].Company = 'Test123';
        l[0].LastName = 'Test123';
        l[0].Email = 'test@test.it.invalid';
        insert l;

        Test.startTest();
            TXT_SendEmailPrivacyController.sendEmail(em.Id, null, l[0].Id, null);
            TXT_SendEmailPrivacyController.sendEmail(null, null, null, null);
        Test.stopTest();
    }
}