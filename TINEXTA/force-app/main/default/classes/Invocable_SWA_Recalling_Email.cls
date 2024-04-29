public class Invocable_SWA_Recalling_Email {
    
    @InvocableMethod(label='SWAInvioRecall')
    public static void Invocable_Invio_Recall(List<List<String>> Input) {
        
        while(!Input.isEmpty())
        {
            list<String> NewInput = Input.remove(0);   
            
            Log__c esito = new Log__c(  Societa__c = 'Swascan',
                                      Source__c = 'Invocable_SWA_Recalling_Email',
                                      InputPayload__c = NewInput.toString());
            
            try{
                String destinatario = NewInput[0];
                String destinatarioCC = NewInput[1];
                String subject = NewInput[2];
                String nomeOwner = NewInput[3];
                String opportunityId = NewInput[4];
                String body = NewInput[5];
                
                String orgWideAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :nomeOwner].Id;
                System.debug('Nome Owner: '+nomeOwner);
                System.debug('Org Wide Address Id: '+orgWideAddress);
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{destinatario});
                email.setCcAddresses(destinatarioCC.split(','));
                email.setSubject(subject);
                email.setHtmlBody(body);
                email.setOrgWideEmailAddressId(orgWideAddress);
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                
                esito.success__c = true;
                esito.ID_Record__c = opportunityId;
                esito.OutputPayload__c = body;
                
            }catch (exception e){
                esito.success__c = false;
                esito.ErrorMessage__c = e.getMessage()+' '+e.getLineNumber()+' '+e.getStackTraceString();
            } finally {
                insert esito;
            }       
        }
    }
}