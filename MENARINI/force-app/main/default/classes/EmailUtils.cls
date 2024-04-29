public with sharing class EmailUtils {

    @AuraEnabled
    public static Boolean sendEmail(String firstName, String lastName, String phone,
            String senderEmail, String vatNumber, String clientCode, String subject, String emailBody) {

        OrgWideEmailAddress orgAddress = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Webform'];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String fullName = firstName + ' ' + lastName;
        mail.setSubject(subject);
        mail.setReplyTo(senderEmail);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);

        List<String> toAddresses = new List<String>();
        if(Test.isRunningTest()) {
            toAddresses.add('test@test.com');
            mail.setSenderDisplayName(fullName + ', ' + senderEmail);
        }
        else {
            for (Community_Email_Receiver__mdt email : [SELECT Id, Receiver__c FROM Community_Email_Receiver__mdt WHERE Active__c = TRUE]) {
                toAddresses.add(email.Receiver__c);
            }
            mail.setOrgWideEmailAddressId(orgAddress.Id);
        }

        String styleHTML = 'style="color: rgb(20, 63, 89); font-size: 0.9rem; font-family: Arial; font-style: normal"';
        String emailBodyHTML = '<p>' + emailBody + '</p>';
        String signatureHTML =
                        '<p><br><b>Nome e Cognome</b>: ' + fullName +
                        '<br><b>Telefono</b>: ' + phone +
                        '<br><b>Email</b>: ' + '<a href="mailto:' + senderEmail +'">' + senderEmail + '</a>' +
                        '<br><b>Partiva Iva</b>: ' + vatNumber +
                        '<br><b>Codice Cliente</b>: ' + clientCode +
                        '</p>';

        String bodyHTML = '<div ' + styleHTML + '>' + emailBodyHTML + signatureHTML  +'</div>';
        mail.setHtmlBody(bodyHTML);
        //mail.setPlainTextBody(bodyHTML);
        mail.setToAddresses(toAddresses);

        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});

        return inspectResults(results);
    }

    private static Boolean inspectResults(Messaging.SendEmailResult [] results) {
        Boolean success = false;

        for (Messaging.SendEmailResult res : results) {
            System.debug('@@@ Result: ' + res);
            success = res.isSuccess();
        }
        return success;
    }
}