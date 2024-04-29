global with sharing class ExternalRoutingWeb {
    public ExternalRoutingWeb() {}  

    @InvocableMethod (label='er_web')
    global static void externalRouting(List<String> ids){
        softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('INFO', 'er_web', 'START_FLOW', ids.toString(), '', '');
        for ( String caseId : ids ){
            try{ 
                softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('INFO', 'er_web', 'START', caseId, '', '');
                Case cs = [select id,CRM_OnQueue__c  from Case where id=:caseId limit 1];
                if ( cs.CRM_OnQueue__c == null || cs.CRM_OnQueue__c == false ){
                    cs.CRM_OnQueue__c = true;
                    update cs;
                    CalloutOutbound(caseId);
                }else{
                    softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('INFO', 'er_web', 'END', caseId, 'The case is already routed', String.valueOf(cs));
                }
               
                //softphone_it.ConnectorOutboundSoftphoneLogs.insertLogExtended('er_chat',String.valueOf(cce),'chatId : ' + chatId,'INFO');
                
            }catch(Exception e){
                System.debug('ERRORE: ' + e.getMessage());
                softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('ERROR', 'er_web', 'ERROR', caseId, e.getMessage(), '');
            }
        }
        
    }
    
   @future (callout=true)
    public Static void CalloutOutbound(String caseId){
       Case cs = [select id,CRM_MotivoDellaChat__c,CRM_WebChannelName__c,G_LastAgentRouted__c  from Case where id=:caseId limit 1];
       List<GenesysSetting__c> settingsList = [select id,G_MotivoDiContatto__c,G_QUEUE_ID__c, G_MEDIA_TYPE__c, G_PRIORITY__c  from GenesysSetting__c where G_MEDIA_TYPE__c='web'];
       GenesysSetting__c settings;
        GenesysSetting__c settingsAltro;
        for ( GenesysSetting__c gs : settingsList ){
            if (gs.G_MotivoDiContatto__c == cs.CRM_MotivoDellaChat__c ){
               settings = gs;
            }
            if ( gs.G_MotivoDiContatto__c == 'Altri prodotti e servizi' ){
                settingsAltro = gs;
            }
        }
        if ( settings == null ){
            settings = settingsAltro;
        }
        
        if ( settings == null ){
            softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('ERROR', 'er_web', 'conversations/email', caseId, 'cannot find settings', String.valueOf(cs));
       
            return;
        }
        String flowId = settings.G_QUEUE_ID__c;
        Decimal priority = settings.G_PRIORITY__c;
        // String priority = settings.G_PRIORITY__c;
        String customerName = cs.CRM_WebChannelName__c;
        Map<String, Object> params = new Map<String, Object>();
        params.put('flowId', flowId);
        params.put('provider', 'Salesforce');
        if ( customerName == null || customerName == ''){
              customerName = 'Cliente sconosciuto';
         }

        params.put('customerName', customerName);
        Map<String, String> attributes = new Map<String, String>{
            'case_id'=> caseId, 
            'last_agent' => cs.G_LastAgentRouted__c,
            'priority'=> priority != null ? ''+priority : null, 
            'motivo_chat'=> settings.G_MotivoDiContatto__c,
            'customer_name' => customerName,
            'media_type'=> settings.G_MEDIA_TYPE__c};
        params.put('attributes', attributes);
        String body = JSON.Serialize(params);
        if(!Test.isRunningTest()){
            HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC(body,  'conversations/emails', 'POST'); 
            softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('INFO', 'er_web', 'POST', 'conversations/emails', response.getBody(), String.valueOf(params));
        }
        
        
    }
   
}