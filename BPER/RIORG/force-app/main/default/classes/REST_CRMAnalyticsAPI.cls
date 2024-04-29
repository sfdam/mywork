global class REST_CRMAnalyticsAPI implements Schedulable {
   private static final String COD_SVILUPPATORI = 'DEVELOPER';
   
   public static void execute(SchedulableContext SC){
    	REST_CRMAnalyticsAPI.executeConnectorSync();
    }
    
    @future(callout=true)
    public static void executeConnectorSync(){
        
		//Retrieve the datasetConnector Id from /services/data/v54.0/wave/dataConnectors
        String restApi = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v54.0/wave/dataConnectors/0It0D000000CaYmSAK/ingest';
        String restAPIBody = '{}';
        //String restApi = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v55.0/wave/dataflowjobs';
        //String restAPIBody = '{"dataflowId":"02K09000003LanwEAC","command":"start"}';
        
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        httpRequest.setHeader('Content-Type', 'application/json; charset=UTF-8');
        httpRequest.setHeader('Accept', 'application/json');
        httpRequest.setEndpoint(restApi);
        httpRequest.setBody(restAPIBody);
        
        try {  
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);
            System.Debug(httpRequest);    
        } catch( System.Exception e) {
            System.debug(LoggingLevel.ERROR, 'ERROR: '+ e);
            throw e;
        }
    }
    
    
    public void generaMail(String mailBody,String subject,Id idUtente,Set<String> addresses, Utenti_Speciali__mdt utenteSviluppatore) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        
        
        if (idUtente!=null) {
            mail.setTargetObjectId(idUtente);
        }
        mail.setSenderDisplayName('Salesforce');
        if (utenteSviluppatore!=null && !String.isEmpty(utenteSviluppatore.Email__c)) {
            mail.setReplyTo(utenteSviluppatore.Email__c);
        }
        mail.setSubject(subject);
        if (!Test.isRunningTest() && addresses.size()>0) {
            mail.setToAddresses(new List<String>(addresses));
        }
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);
        mail.setHtmlBody(mailBody);
        if (!Test.isRunningTest()) {
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

}