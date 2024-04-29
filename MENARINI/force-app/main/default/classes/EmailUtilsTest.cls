@IsTest
public with sharing class EmailUtilsTest {

    @IsTest
    public static void sendEmailTest() {
        String firstName = 'Test FirstName';
        String lastName = 'test lastName';
        String phone = '1234567890';
        String vatNumber = 'Test_Vat567890';
        String clientCode = 'Test_ClientCode12345';
        String sender = 'test@example.com';
        String subject = 'TestSendEmail';
        String body = 'Just a test email';

        Test.startTest();
        Boolean response = EmailUtils.sendEmail(firstName, lastName, phone, sender, vatNumber, clientCode, subject, body);
        Test.stopTest();
        System.assert(response == true);
    }


}