public class WRT_FlowUtils_SendEmailFromTemplate {
    public class FlowInputs {
        @InvocableVariable public String templateName;
        @InvocableVariable public String recipient;
    }
    
    @InvocableMethod
    public static void sendEmailFromTemplate (List<FlowInputs> request) {
        
        String templateName = request[0].templateName;
        String recipient = request[0].recipient;
    }
    
    public static void sendEmail(String recipient){
       /*Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
       message.setTargetObjectId(contact.id); 
        message.setSenderDisplayName(‘Company Support’); 
        message.setReplyTo(‘no-reply@company.com’);
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(false); 
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = ‘Test Account Alert Email’];
        message.setTemplateID(emailTemplate.Id); 
        message.setWhatId(account.Id); //This is important for the merge fields in template to work
        message.toAddresses = new String[] { contact.email};
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) 
        {
            System.debug(‘The email was sent successfully.’);
        } else {
            System.debug(‘The email failed to send: ‘ +  results[0].errors[0].message);
        }
	*/
   }
}