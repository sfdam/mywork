global with sharing class ConnectorPushToGenesysCloud {
    public ConnectorPushToGenesysCloud(Object o) {}  
    
    @InvocableMethod (label='pushToGcWithId')
    global static void pushToGcWithTId(List<String> objId){
        CalloutOutbound(objId.get(0));
    }
    
   @future (callout=true)
    public Static void CalloutOutbound(String sfdcId){
        //get the Connector Settings object, to read the queueId
        softphone_it__Connector_Settings__c COS = softphone_it__Connector_Settings__c.getOrgDefaults();
        String queueId = COS.softphone_it__GC_QUEUE_ID__c;
     	//creates the map for the mandatory fields
        Map<String, Object> params = new Map<String, Object>();
        params.put('queueId', queueId);
        params.put('provider', 'Salesforce');
        //creates the map for the participant data
        Map<String, String> attributes = new Map<String, String>{'SFDC_ID'=> sfdcId};
        params.put('attributes', attributes);
        String body = JSON.Serialize(params);
		
        if(!Test.isRunningTest()){
            //calls the ConnectorCalloutGc class from the cti-connector-core package,
            //that will submit the interaction to Genesys Cloud
        	HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC(body,  'conversations/emails', 'POST'); 
        }
    }
}