/**
 * @description       : 
 * @author            : alessandro.dinardo@lutech.it
 * @group             : tengroup
 * @last modified on  : 24-01-2024
 * @last modified by  : alessandro.dinardo@lutech.it
 * description        : CR 76756  Queueable chiamata dalla batch 'Batch_AggiornaMassivamenteTag' con il compito di eseguire l'aggiornamento 
 *                      dei dati di account su salesforce analytics attraverso il metodo future 'executeConnectorSync'
**/

global class AggiornaMassivamenteTagQueueable implements Queueable {



    public AggiornaMassivamenteTagQueueable() {
        
    }

    public void execute(QueueableContext qc) {  

        System.debug('AD AggiornaMassivamenteTagQueueable execute');

        try{
            
             
            //AD chiamo il metodo per eseguire la sincronizzazione
            AggiornaMassivamenteTagQueueable.executeConnectorSync();
           

        }catch(Exception e){
            System.debug('AD AggiornaMassivamenteTagQueueable error : ' + e);

        }

    }

	//AD metodo usato per aggiornare i dati su salesforce analytics
    //documentazione file : 'CRM Analytics Activities Lutech Drill Down Only'
    @future(callout=true)
    public static void executeConnectorSync(){
       	System.debug('AD executeConnectorSync start');

		//String restApi = URL.getOrgDomainURL().toExternalForm() + '/services/data/v55.0/wave/replicatedDatasets/';
		String restApi =  'callout:CallMeBack/services/data/v55.0/wave/replicatedDatasets/';
        String restAPIBody = '{}';
		List<String> listEnabledObject = new List<String>{'Account'};//AD oggetto su cui voglio fare la sincronizzazione
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
            System.debug('AD replicatedDatasets httpResponse : ' + httpResponse);

            response = (Map<String, Object>)JSON.deserializeUntyped(httpResponse);
            for(Object index : (List<Object>)response.get('replicatedDatasets')){
                System.debug('AD replicatedDatasets index : ' + index);
                objectItem = (Map<String, Object>)index;
                System.debug('AD replicatedDatasets objectItem : ' + objectItem);

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
                //restApi = URL.getOrgDomainURL().toExternalForm() + '/services/data/v55.0/wave/replicatedDatasets/'+dr.Id;
                restApi =  'callout:CallMeBack/services/data/v55.0/wave/replicatedDatasets/'+dr.Id;
                httpRequest.setMethod('PATCH');
                restAPIBody = '{"fullRefresh" : true , "passThroughFilter": "Check_Sync_Analytics__c = true"}';
                
                system.debug('AD AggiornaMassivamenteTagQueueable restAPIBody: '+restAPIBody);
                httpRequest.setBody(restAPIBody);
                httpRequest.setEndpoint(restApi);
                http = new Http();   
            	httpResponse = http.send(httpRequest).getBody();//AD bk
                system.debug('AD AggiornaMassivamenteTagQueueable httpResponse: '+httpResponse);//AD bk
                response = (Map<String, Object>)JSON.deserializeUntyped(httpResponse);//AD bk  
                system.debug('response step 1: '+response);
                
                //AD nuova response
                //httpResponse res = http.send(httpRequest);//AD test nuovo httpResponse per ottenere lo statusCode
                //String responseBody = res.getBody();//AD test body della risposta                
                //system.debug('AD AggiornaMassivamenteTagQueueable httpResponse body : '+responseBody);//AD test
            	//response = (Map<String, Object>)JSON.deserializeUntyped(responseBody);//AD test   
                //System.debug('AD response tatusCode : '+ res.getStatusCode());//AD test
            }
            
            //Step 2: Start sync
            /** */
            for(dataRequest dr : dataRetrived){
                
                //restApi = URL.getOrgDomainURL().toExternalForm() + '/services/data/v55.0/wave/dataflowjobs';
                restApi =  'callout:CallMeBack/services/data/v55.0/wave/dataflowjobs';
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
            System.debug( 'AD executeConnectorSync : ' + e);
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