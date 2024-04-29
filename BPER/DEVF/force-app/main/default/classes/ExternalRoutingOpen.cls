global with sharing class ExternalRoutingOpen {
    public ExternalRoutingOpen() {}  

    @InvocableMethod (label='er_open')
    global static void externalRouting(List<String> id){ 
        softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('INFO', 'er_open', 'START', id.toString(), '', '');
        for(String chatId : id){      
            try{ 
                CalloutOutbound('a71c33c6-634a-4ed2-a348-c362dbaba633', 'customerName', 'caseId','motivoChat', chatId, 0);
            }catch(Exception e){
                System.debug('ERRORE: ' + e.getMessage());
                softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('ERROR', 'er_open', 'ERROR', id.toString(), e.getMessage(), '');
            }
        }
    }
    
    
   @future (callout=true)
    public Static void CalloutOutbound(String openId,String customerName,String caseId,String motivoChat,String chatId,Decimal priority){
        softphone_it__Connector_Settings__c COS = softphone_it__Connector_Settings__c.getOrgDefaults();
        String queueId = COS.softphone_it__GC_QUEUE_ID__c;
        DateTime dt = DateTime.now();
        String dtDate = dt.formatGmt('yyyy-MM-dd');
        String dtTime = dt.formatGmt('HH:mm:ss.SSS');
        String dtIso = dtDate + 'T' + dtTime + 'Z';

        Map<String, Object> toMap = new Map<String, Object> {'id' => openId};
        Map<String, Object> fromMap = new Map<String, Object> {
            'id' => chatId,
            'idType' => 'Opaque',
            'nickname' => 'Softphone External Routing'
        };

        Map<String, Object> customAttributes = new Map<String, Object> {
            'case_id' => caseId,
            'customer_name' => customerName,
            'motivo_chat' => motivoChat,
            'media_type' => 'unblu_chat',
            'unblu_chat_id' => chatId
        };

        Map<String, Object> metadata = new Map<String, Object> {
            'customAttributes' => customAttributes
        };
        Map<String, Object> channel = new Map<String, Object> {
            'platform' => 'Open',
            'messageId' => chatId,
            'time' => dtIso,
            'to' => toMap,
            'from' => fromMap,
            'metadata' => metadata
        };
        Map<String, Object> params = new Map<String, Object> {
            'channel' => channel,
            'type' => 'Text',
            'text' => 'Salesforce External Routing',
            'direction' => 'Inbound'
        };
            
       
        String body = JSON.Serialize(params);
        
        if(!Test.isRunningTest()){
            HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC(body,  'conversations/messages/inbound/open', 'POST'); 
            softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('INFO', 'er_open', 'POST', 'conversations/messages/inbound/open', JSON.serialize(params), response.getBody());
        }
    }
}