global class REST_CRMAnalyticsAPIrequest implements Schedulable {
   private static final String COD_SVILUPPATORI = 'DEVELOPER';
   
   public static void execute(SchedulableContext SC){
    	REST_CRMAnalyticsAPIrequest.executeConnectorSync();
    }
    
    @future(callout=true)
    public static void executeConnectorSync(){
       
		String restApi = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v55.0/wave/replicatedDatasets/';
        String restAPIBody = '{}';
		List<String> listEnabledObject = new List<String>{'CRM_CustomerInterview__c','Event','Opportunity','Campaign','CampaignMember','CH_Memo__c','CRM_Memo__c','FinServ__Alert__c'};
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('GET');
        httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        httpRequest.setHeader('Content-Type', 'application/json; charset=UTF-8');
        httpRequest.setHeader('Accept', 'application/json');
        httpRequest.setEndpoint(restApi);
        Map<String, Object> response = new Map<String, Object>();
 		Map<String, Object> objectItem = new Map<String, Object>();
		String httpResponse = '';
        List<dataRequest> dataRetrived = new List<dataRequest>();
	
        
        
        try {  
            //Step 0: GET DATA REQUEST
            Http http = new Http();   
            httpResponse = http.send(httpRequest).getBody();
            response = (Map<String, Object>)JSON.deserializeUntyped(httpResponse);
            for(Object index : (List<Object>)response.get('replicatedDatasets')){
                
                objectItem = (Map<String, Object>)index;
                if(listEnabledObject.contains((String)objectItem.get('sourceObjectName'))){
                    system.debug('--------------------------------- ');
                    system.debug('SourceObjectName: '+objectItem.get('sourceObjectName')+' Id: '+objectItem.get('id')+' ReplicationDataflowId: '+objectItem.get('replicationDataflowId'));
                    dataRequest dr = new dataRequest();
                    dr.SourceObjectName = (String)objectItem.get('sourceObjectName');
                    dr.Id = (String)objectItem.get('id');
                    dr.ReplicationDataflowId = (String)objectItem.get('replicationDataflowId');
                    dataRetrived.add(dr);
                       
                }
                          
                
            }
            System.Debug('DR: '+dataRetrived);
            
            //Step 1: SET Full Request
            for(dataRequest dr : dataRetrived){
                restApi = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v55.0/wave/replicatedDatasets/'+dr.Id;
                httpRequest.setMethod('PATCH');
                restAPIBody = '{"fullRefresh" : true}';
                httpRequest.setBody(restAPIBody);
                httpRequest.setEndpoint(restApi);
                http = new Http();   
            	httpResponse = http.send(httpRequest).getBody();
            	response = (Map<String, Object>)JSON.deserializeUntyped(httpResponse);   
                system.debug('response step 1: '+response);
            }
            
            //Step 2: Start sync
            for(dataRequest dr : dataRetrived){
                
                restApi = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v55.0/wave/dataflowjobs';
                httpRequest.setMethod('POST');
                restAPIBody = '{"dataflowId" : "'+dr.ReplicationDataflowId+'","command":"start"}';
                httpRequest.setBody(restAPIBody);
                httpRequest.setEndpoint(restApi);
                http = new Http();   
            	httpResponse = http.send(httpRequest).getBody();
            	response = (Map<String, Object>)JSON.deserializeUntyped(httpResponse);   
                system.debug('response step 2: '+response);
            }
            //Step 3: SET Incremental Request
           /* for(dataRequest dr : dataRetrived){
                restApi = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v55.0/wave/replicatedDatasets/'+dr.Id;
                httpRequest.setMethod('PATCH');
                restAPIBody = '{"connectionMode" : "Incremental"}';
                httpRequest.setBody(restAPIBody);
                httpRequest.setEndpoint(restApi);
                http = new Http();   
            	httpResponse = http.send(httpRequest).getBody();
            	response = (Map<String, Object>)JSON.deserializeUntyped(httpResponse);   
                system.debug('response step 3: '+response);
            }*/
        } catch( System.Exception e) {
            System.debug(LoggingLevel.ERROR, 'ERROR: '+ e);
            throw e;
        }
    
    }
    
    global class dataRequest{
        global String SourceObjectName;
        global String Id;
        global String ReplicationDataflowId;
    }
    
   

}