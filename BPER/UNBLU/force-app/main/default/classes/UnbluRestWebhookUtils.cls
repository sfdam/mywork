global with sharing class UnbluRestWebhookUtils {

    public static boolean checkSignature(String requestSignature,String requestBody){
        softphone_it__Connector_Settings__c COS = softphone_it__Connector_Settings__c.getOrgDefaults();
       
        if(requestSignature == null || requestSignature == ''){
            return false;
        }
        Blob hmac = Crypto.generateMac(
            'hmacSHA1',
            Blob.valueOf(requestBody),
            Blob.valueOf(COS.UnbluWebhookSecret__c)
        );
        return EncodingUtil.convertToHex(hmac) == requestSignature;
    }
   

    /*
    global static Task handlePost() {
    
    Task tsk;
    ConversationWrapper wrapper;
    Conversation conv;
    
    GlobalSettings gSettings = GlobalSettings.getInstance();
    
    String webhookBody = RestContext.request.requestBody.toString();
    String webhookSignature = RestContext.request.headers.get('X-Unblu-Signature');

        try {
            if (String.isNotEmpty(gSettings.webhookSecret) && !isValidRequestSignature(webhookSignature, webhookBody)) {
                 RestResponse response = RestContext.response;
                response.statusCode = 403;
                response.responseBody = Blob.valueOf('Invalid request signature');
                return tsk;
            }
            if (gSettings.log_conversation_once_ended) {
                UnbluAPI.useAdminCredentials = true;

                wrapper = parseWebHookBody(webhookBody);
                conv = wrapper.conv;

                if (wrapper.conv != null) {
                    System.enqueueJob(new ConversationEndedListenerQueueable(wrapper));
                } else {
                     RestResponse response = RestContext.response;
                    response.statusCode = 400;
                    response.responseBody = Blob.valueOf('Unable to parse conversation data');
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            System.debug(e.getStackTraceString());
    
            unblusuite__Error_Log__c errorLog = new unblusuite__Error_Log__c(
                        unblusuite__Conversation_ID__c = conv?.id,
                        unblusuite__Error_Message__c = e.getMessage() + '\n' + e.getStackTraceString()
                    );
            insert errorLog;
        }


        if (Test.isRunningTest()) {
              RestResponse response = RestContext.response;
                response.statusCode = 200;
                response.responseBody = Blob.valueOf(conv.id);
            }
        return tsk;
    }
*/
    /*
    @TestVisible private static ConversationWrapper parseWebHookBody(String webhookBody){
    
        ConversationWrapper wrapper = new ConversationWrapper();
        
        JSONParser parser = JSON.createParser(webhookBody);
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                    if (parser.getText() == 'timestamp') {
                        parser.nextToken();
                        wrapper.conversationTimeStamp = (Long)parser.readValueAs(Long.class);
                    } else if (parser.getText() == '$_type') {
                        parser.nextToken();
                        wrapper.eventType = (String)parser.readValueAs(String.class);
                    } else if (parser.getText() == 'conversation') {
                        parser.nextToken();
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            wrapper.conv = (Conversation)parser.readValueAs(Conversation.class);
                        }
                    }
                }

            }

        return wrapper;
    }
    */

    
}