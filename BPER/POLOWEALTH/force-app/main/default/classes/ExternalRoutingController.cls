global with sharing class ExternalRoutingController {
    public ExternalRoutingController() {}  

    @RemoteAction
    global static void createCase(String id, String customerName) {
        Case c = new Case();   
        c.Subject = id;
		c.softphoneerc__IWS_PreChat_Id__c = id;
        c.softphoneerc__IWS_Customer_Name__c = customerName;
        try{           
            Database.SaveResult sr =  Database.insert(c);
                System.debug('save result : ' + sr);   
            } catch(Exception e){
            System.debug('Error in insert ' + e);
         }
    }

   @RemoteAction
    global static void createTask(String id, String customerName) {
        Task t = new Task();   
        t.Subject = id;
		t.softphoneerc__IWS_PreChat_Id__c = id;
        t.softphoneerc__IWS_Customer_Name__c = customerName;
        try{           
            Database.SaveResult sr =  Database.insert(t);
                System.debug('save result : ' + sr);   
            } catch(Exception e){
            System.debug('Error in insert ' + e);
         }
    }
    
    @InvocableMethod (label='externalRouting')
    global static void externalRouting(List<Task> tasks){
        String preChat = tasks.get(0).softphoneerc__IWS_PreChat_Id__c;
        String customerName = tasks.get(0).softphoneerc__IWS_Customer_Name__c;
        CalloutOutbound(preChat, customerName);
    }
    
   @future (callout=true)
    public Static void CalloutOutbound(String PreChatId, String customerName){
        softphone_it__Connector_Settings__c COS = softphone_it__Connector_Settings__c.getOrgDefaults();
        String queueId = COS.softphone_it__GC_QUEUE_ID__c;
        Map<String, Object> params = new Map<String, Object>();
        params.put('queueId', queueId);
        params.put('provider', 'Salesforce');
        params.put('customerName', customerName);
        Map<String, String> attributes = new Map<String, String>{'prechat_id'=> PreChatId};
        params.put('attributes', attributes);
        String body = JSON.Serialize(params);
		
        if(!Test.isRunningTest()){
        	HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC(body,  'conversations/chats', 'POST');
            System.debug('Genesys response: ' + response.getBody());
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('Genesys response ID: ' + (String)results.get('id'));
            updateTaskFromResponse(response, PreChatId);
            
        }
    }
    
    public static void updateTaskFromResponse(HTTPResponse response, String preChatId){
        Task lct = [SELECT id FROM Task WHERE softphoneerc__IWS_PreChat_Id__c = :preChatId limit 1];
       String res = '';
       
        if (response.getStatusCode() == 200) {
                 System.debug(response.getBody());
            	 res = response.getBody();
                 Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                 lct.softphone_it__IWS_Interaction_ID__c = (String)results.get('id');
                 update lct;
             } else {
                 res = 'The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus();
             }
         softphone_it.ConnectorOutboundSoftphoneLogs.insertLog('createChat',res,'INFO');
      
    }
    
}