global without sharing class ScheduledRequest implements Schedulable{

    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'ScheduledRequest';

    public ScheduledRequest(String request){
    
        System.debug('DK request: ' + request);
        requestsToRetry = new Set<String>{request};
    }

    public Set<String> requestsToRetry{get;set;}
    
    global void execute(SchedulableContext SC) {
        
        System.debug('DK requestsToRetry: ' + JSON.serialize(requestsToRetry));
        List<SV_FailedRequest__c> requestsToDelete = new List<SV_FailedRequest__c>();
        for(SV_FailedRequest__c request : [SELECT id, OwnerId, RequestName__c, RecordId__c, FieldsMap__c, CertificationName__c FROM SV_FailedRequest__c WHERE RequestName__c IN: requestsToRetry AND Owner.name != 'Utente Integrazione Batch' LIMIT 50]){

            sendRequest(JSON.serialize(request));
        }
    }

    @future(callout=true)
    global static void sendRequest(String serializedFailedrequest){

        SV_FailedRequest__c request = (SV_FailedRequest__c) JSON.deserialize(serializedFailedrequest, SV_FailedRequest__c.class);
        Map<String, Object> parsedJsonElementFields = (Map<String, Object>)JSON.deserializeUntyped(request.FieldsMap__c);
        Map<String, Map<String, Object>> fieldsMap = new Map<String, Map<String, Object>>();
        for(String fieldName : parsedJsonElementFields.keySet()){

            fieldsMap.put(fieldName, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementFields.get(fieldName))));
        }
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(MakeRequestController.makeRequest(request.RequestName__c,
                                                            request.RecordId__c, 
                                                            fieldsMap,
                                                            null,
                                                            request.CertificationName__c,
                                                            request.OwnerId, false));
        try {
            
            System.debug('DK response: ' + response);

            if(response != null &&
            response.containsKey('statusCode') &&
            !String.isBlank((String)response.get('statusCode')) &&
            ((String)response.get('statusCode')).startsWith('2')){
    
                delete request;
            }
        } catch (Exception exc) {
            System.debug(NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage());
            String testoMail = NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage()+'<br/>'+exc.getStackTraceString()+'<br/> RecordId: '+ request.Id + '<br/> Response: ' + JSON.serialize(response);
            mandaMail('Errore',testoMail); 
        }   
    }

    public static void mandaMail(String tipoMail, String mailBody) {
        String subject = (tipoMail=='Errore' ? 'Errore ' : (tipoMail=='Warning' ? 'Warning ' :'Elaborazione '))+NOME_CLASSE;
        Utenti_Speciali__mdt utenteSviluppatore = (Utenti_Speciali__mdt)MetadataUtility.getRecordByName('Utenti_Speciali__mdt', COD_SVILUPPATORI);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Set<String> emails = new Set<String>();
        mail.setSenderDisplayName('Salesforce');
        if (utenteSviluppatore!=null && !String.isEmpty(utenteSviluppatore.Email__c)) {
            mail.setReplyTo(utenteSviluppatore.Email__c);
            emails.add(utenteSviluppatore.Email__c);
        }
        mail.setSubject(subject);
        if (!Test.isRunningTest() && emails.size()>0) {
            mail.setToAddresses(new List<String>(emails));
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