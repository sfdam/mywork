global with sharing class ExternalRoutingControllerAbandoned {
    public ExternalRoutingControllerAbandoned() {}  

    @InvocableMethod (label='externalRoutingAbandoned')
    global static void externalRouting(List<String> ids){
     // softphone_it.ConnectorOutboundSoftphoneLogs.insertLogExtendedUrl('externalRoutingAbandoned','exception in externalRoutingAbandoned','','INFO',String.valueOf(ids)); 
           
        List<String> app = ids[0].split(',');
        
        String prechatId = '';
         String id = '';
        try{
     
            id = app.get(0).substring(0, 15);
            if ( app.size() == 2 ){
               prechatId = app.get(1);
                
            }
               softphone_it.ConnectorOutboundSoftphoneLogs.insertLogExtended('externalRoutingAbandoned','externalRoutingAbandoned flow START ','chatId : ' + id,'INFO');
       
        	External_Routing_Bean__c erb = [SELECT id,Interaction_Id__c FROM External_Routing_Bean__c WHERE PreChat_Id__c in (:id,:prechatId) order by CreatedDate desc limit 1];
        	CalloutOutbound(erb.Interaction_Id__c);
        }catch(Exception e){
            softphone_it.ConnectorOutboundSoftphoneLogs.insertLogExtendedUrl('externalRoutingAbandoned','exception in externalRoutingAbandoned, id=' + id + ',prechatId=' + prechatId + ', ids.get0' + ids.get(0),e.getMessage(),'ERROR',String.valueOf(ids)); 
        }

    }
    
   @future (callout=true)
    public Static void CalloutOutbound(String id){
        Map<String, Object> params = new Map<String, Object>();
        params.put('state', 'disconnected');
        String body = JSON.Serialize(params);
		
        if(!Test.isRunningTest()){
        	HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC(body,  'conversations/chats/' + id, 'PATCH'); 
            softphone_it.ConnectorOutboundSoftphoneLogs.insertLogExtendedUrl('externalRoutingAbandoned','conversations/chats/' + id ,response.getBody(),'INFO',String.valueOf(params)); 
        }
    }  
}