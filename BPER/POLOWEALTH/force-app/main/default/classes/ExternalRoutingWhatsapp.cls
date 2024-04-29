global with sharing class ExternalRoutingWhatsapp {
    public ExternalRoutingWhatsapp(Object o) {}  
    
    @InvocableMethod (label='er_whatsapp')
    global static void pushToGcWithTId(List<String> objId){
        softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('INFO', 'er_whatsapp', 'START_FLOW', objId.toString(), '', '');
        
        for ( String chatId : objId ){
            try{ 
                softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('INFO', 'er_whatsapp', 'START', chatId, '', '');
                CalloutOutbound(chatId);
            }catch(Exception e){
                System.debug('ERRORE: ' + e.getMessage());
                softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('ERROR', 'er_whatsapp', 'START', chatId,  e.getMessage(), '');
            }
        }
    }
    
   @future (callout=true)
    public Static void CalloutOutbound(String sfdcId){
        softphone_it__Connector_Settings__c COS = softphone_it__Connector_Settings__c.getOrgDefaults();
        GenesysSetting__c settings = [select id, G_QUEUE_ID__c, G_MEDIA_TYPE__c, G_PRIORITY__c from GenesysSetting__c where G_MEDIA_TYPE__c='Whatsapp' limit 1];
        if ( settings == null ){       
            softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('ERROR', 'er_whatsapp', 'ERROR', 'SFDC ID: '+sfdcId, 'cannot find whatsapp queue in GenesysSetting__c', '');
            return;
        }
        String queueId = settings.G_QUEUE_ID__c;
        //String priority = settings.G_PRIORITY__c;
        Decimal priority = settings.G_PRIORITY__c;
         if ( queueId == null || priority == null){     
            softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('ERROR', 'er_whatsapp', 'ERROR', String.valueOf(settings), 'cannot find whatsapp queue in GenesysSetting__c', '');
            return;
        }
        String mediaType = settings.G_MEDIA_TYPE__c;
        String ani = '';

        MessagingSession ms = [select id, CreatedDate, MessagingEndUser.Name, MessagingEndUser.MessagingPlatformKey from MessagingSession Where id =:sfdcId order by CreatedDate desc limit 1];
        if ( ms != null){
            /*if(ms.MessagingEndUser.Name.contains('whatsapp')) {
             ani = ms.MessagingEndUser.Name.split(':')[1];
            } else {
                ani = ms.MessagingEndUser.Name;
            }*/
            ani = ms.MessagingEndUser.MessagingPlatformKey.split(':')[1];
        }
        
        Map<String, Object> params = new Map<String, Object>();
        params.put('queueId', queueId);
        params.put('provider', 'Salesforce');
        params.put('customerName', ani);
        //params.put('priority', Integer.valueOf(priority));
        params.put('priority', priority);
        Map<String, String> attributes = new Map<String, String>{'livechat_id'=> sfdcId, 'ani'=> ani, 'media_type'=> mediaType};
        params.put('attributes', attributes);
        String body = JSON.Serialize(params);
        String url = 'conversations/chats';
        if(!Test.isRunningTest()){
            HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC(body,  url, 'POST');
            System.debug('Genesys response: ' + response.getBody());
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('Genesys response ID: ' + (String)results.get('id'));
            //updateTaskFromResponse(response, PreChatId);
           softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('INFO', 'er_whatsapp', 'POST', url, JSON.serialize(params), response.getBody());
        }
      
    }
}