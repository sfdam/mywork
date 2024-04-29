global without sharing class QbleInvioOffertaInfostore implements Queueable, Database.AllowsCallouts {

    global List<String> quotelineids{get;set;}

    global QbleInvioOffertaInfostore(List<String> quotelineids) {
        this.quotelineids = quotelineids;
    }

    global void execute(QueueableContext context) {
        if(this.quotelineids.isEmpty())
            return;

        Id qlId = (Id)this.quotelineids.remove(0);

        try{
            SBQQ__QuoteLine__c ql = [SELECT Id, SBQQ__Quote__c, SBQQ__Quote__r.Name FROM SBQQ__QuoteLine__c WHERE Id =: qlId LIMIT 1];
            Id quoteId = ql.SBQQ__Quote__c; 
            String msg = WRT_IntegrazioneController.opportunityIntegration_InfoStore_CPQ(quoteId);

            if(msg != 'OK' || Test.isRunningTest()){
                sendErrorEmail(quoteId, ql.SBQQ__Quote__r.Name, msg);
            }

            if(!this.quotelineIds.isEmpty() && !Test.isRunningTest())
                System.enqueueJob(new QbleInvioOffertaInfostore(this.quotelineIds));
            
        } catch (Exception e){
            System.debug('@@@ exception ' + e.getMessage() + ' ' + e.getStackTraceString());
            if(!this.quotelineIds.isEmpty() && !Test.isRunningTest())
                System.enqueueJob(new QbleInvioOffertaInfostore(this.quotelineIds));          
        }
    }

    private static void sendErrorEmail(Id quoteId, String quoteName, String msg){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(new List<String>{'edp@warranthub.it'});
        // message.setToAddresses(new List<String>{'edp@warranthub.it.test'});
        message.setSubject('Errore invio pratiche da Salesforce a Infostore: ' + msg);
        message.setHtmlBody('<h2>Errore di invio Pratiche CPQ da Salesforce ad Infostore</h2><p>errore avvenuto sull\'invio dell\'offerta: ' + quoteName + '('+quoteId+')</p><p>in data: ' + String.valueOf(System.Now()) + ' </p><p>Messaggio di errore: '+ msg +'</p>');
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
}