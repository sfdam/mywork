public class ConnectorScheduleHelper {
    
     public Static Map<String, Object> getSchedulerGroup(String schedulGroupId){
        try{
            //if(!Test.isRunningTest()){
                HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC('',  'architect/schedulegroups/' + schedulGroupId, 'GET');
                System.debug('Scheduler Groups: ' + response.getBody());
          if ( response.getStatusCode() != 200 ){
              NoDataFoundException  n = new NoDataFoundException ();
              n.setMessage(response.getStatus());
              throw n;
            }
                return (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            //}  
        } catch (exception e) {
            /*
            Softphone_it.ConnectorOutboundSoftphoneLogs.insertLogExtendedUrl('getSchedulerGroup', 'Error on getSchedulerGroup', 'Error: \'' +
                 e.getMessage() +  '\'', 'Error', 'architect/schedulegroups/' + schedulGroupId);
	*/       
}   
        return null;
    }
    
    public Static Map<String, Object> getSchedule(String scheduleId){
        try{
            //if(!Test.isRunningTest()){
                HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC('',  'architect/schedules/' + scheduleId, 'GET');
                System.debug('Schedule: ' + response.getBody());
            if ( response.getStatusCode() != 200 ){
              NoDataFoundException  n = new NoDataFoundException ();
              n.setMessage(response.getStatus());
              throw n;
            }
                return (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            //}  
        } catch (exception e) {
            /*
            Softphone_it.ConnectorOutboundSoftphoneLogs.insertLogExtendedUrl('getSchedule', 'Error on getSchedule - ', 'Error: \'' +
                 e.getMessage() +  '\'', 'Error', 'architect/schedules/' + scheduleId);
*/         
throw(e);
        }   
        
    }
    
    
    
    
    public Static Map<String, Object> submit(String body){
        try{
            //if(!Test.isRunningTest()){
            System.debug('submit, body : ' + body);

            HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC(body,  'conversations/chats', 'POST'); 
            System.debug('callout Genesys END, response : '+ response);
       
            if ( response.getStatusCode() != 200 ){
              NoDataFoundException  n = new NoDataFoundException ();
              n.setMessage('msg : ' + response.getStatusCode());
              throw n;
            }
                return (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            //}  
        } catch (exception e) {
            Softphone_it.ConnectorOutboundSoftphoneLogs.insertLogExtendedUrl('submit', 'Error on submit - ', 'Error: \'' +
                 e.getMessage() +  '\'', 'Error', 'conversations/chats');
            throw(e);
        }   
        
    }
    
}