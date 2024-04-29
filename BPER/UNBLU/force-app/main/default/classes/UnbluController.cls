global without sharing class UnbluController {

    public UnbluController(Object o) { } 
    
    @RemoteAction
    global static String unbluPersonSearch(String username){
        String id = '';
        try{
            Map<String, Object> body = new Map<String, Object>();
            body.put('$_type', 'PersonQuery');
            List<Map<String,Object>> filters = new List<Map<String,Object>>();
            Map<String,Object> searchFilter = new Map<String,Object>();
            searchFilter.put('$_type','UsernamePersonSearchFilter');
            searchFilter.put('field','USERNAME');
            Map<String,Object> operator = new Map<String,Object>();
            operator.put('$_type','EqualsStringOperator');
            operator.put('type','EQUALS');
            operator.put('value',username);
            searchFilter.put('operator',operator);
            filters.add(searchFilter);
            body.put('searchFilters',filters);
            String bodyString = JSON.serialize(body);
            HttpResponse response = UnbluRestClient.executeRequest('POST', '/persons/search',bodyString );
            insertDebugLog(null, 'INFO', 'unblu_ws_request', 'POST', '/persons/search', bodyString, response.getBody());
            id = getUnbluPersonIdFromResponse(response);
        }catch(Exception e ){
            System.debug('Error calling unbluPersonSearch : ' + e);
            insertDebugLog(null, 'ERROR', 'unblu_ws_request', 'POST', '/persons/search', username, e.getMessage());  
        }
        return id;
    }

    private static String getUnbluPersonIdFromResponse(HttpResponse response){
        String id = null;
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());  
        List<Object> items = (List<Object>)results.get('items');
        if ( items.size() == 1 ){
            Map<String, Object> item = (Map<String, Object>)items[0];
            id = (String)item.get('id');
        }
        return id;
    }

    @RemoteAction
    global static Boolean unbluInviteAgentToConversation(String unbluConvId,String unbluPersonId){
        Boolean result = true;
        try{
            Map<String, Object> body = new Map<String, Object>();
            body.put('conversationId', unbluConvId);
            body.put('agentPersonId', unbluPersonId);
            body.put('comment', '');
            body.put('joinHidden', false);
            String bodyString = JSON.serialize(body);
            HttpResponse response = UnbluRestClient.executeRequest('POST', '/invitations/inviteAgentToConversation',bodyString );
            insertDebugLog(unbluConvId, 'INFO', 'unblu_ws_request', 'POST', '/invitations/inviteAgentToConversation', bodyString, response.getBody());
            if ( response.getStatusCode() != 200 ){
                result = false;
            }
        }catch(Exception e){
            insertDebugLog(unbluConvId, 'ERROR', 'unblu_ws_request', 'POST', '/invitations/inviteAgentToConversation', 'conversationId : ' + unbluConvId + ';personId :' + unbluPersonId, e.getMessage());
            result = false;
        }
        
       return result;
    }

    @RemoteAction
    global static Boolean unbluAddParticipant(String unbluConvId,String unbluPersonId){
        Boolean result = true;
        String url = '/conversations/' + unbluConvId + '/addParticipant';
        try{
            Map<String, Object> body = new Map<String, Object>();
            body.put('personId', unbluPersonId);
            body.put('connectedViaExternalMessenger', false);
            body.put('hidden', false);
            body.put('conversationStarred', false);
            String bodyString = JSON.serialize(body);
            
            HttpResponse response = UnbluRestClient.executeRequest('POST', url,bodyString );
            insertDebugLog(unbluConvId, 'INFO', 'unblu_ws_request', 'POST',url , bodyString, response.getBody());
            if ( response.getStatusCode() != 200 ){
                result = false;
            }
        }catch(Exception e){
            insertDebugLog(unbluConvId,'ERROR', 'unblu_ws_request', 'POST', '', ';personId :' + unbluPersonId, e.getMessage());
            result = false;
        }
        
       return result;
    }
    @RemoteAction
    global static Boolean unbluSetAssigneePerson(String unbluConvId,String unbluPersonId){
        Boolean result = true;
        String url = '/conversations/' + unbluConvId + '/setAssigneePerson';
        try{
            Map<String, Object> body = new Map<String, Object>();
            body.put('personId', unbluPersonId);
            String bodyString = JSON.serialize(body);
            
            HttpResponse response = UnbluRestClient.executeRequest('POST', url,bodyString );
            insertDebugLog(unbluConvId,'INFO', 'unblu_ws_request', 'POST',url , bodyString, response.getBody());
            if ( response.getStatusCode() != 200 ){
                result = false;
            }
        }catch(Exception e){
            insertDebugLog(unbluConvId,'ERROR', 'unblu_ws_request', 'POST', '', ';personId :' + unbluPersonId, e.getMessage());
            result = false;
        }
        
       return result;
    }
    @RemoteAction
    global static Boolean unbluEndConversation(String unbluConvId){
        Boolean result = true;
        String url = '/conversations/' + unbluConvId + '/end';
        try{
            Map<String, Object> body = new Map<String, Object>();
            body.put('reason', 'OTHER');
            body.put('comment', 'Genesys End Conversation');
            String bodyString = JSON.serialize(body);
            
            HttpResponse response = UnbluRestClient.executeRequest('POST', url,bodyString );
            insertDebugLog(unbluConvId,'INFO', 'unblu_ws_request', 'POST',url , bodyString, response.getBody());
            if ( response.getStatusCode() != 200 ){
                result = false;
            }
        }catch(Exception e){
            insertDebugLog(unbluConvId,'ERROR', 'unblu_ws_request', 'POST', '', '', e.getMessage());
            result = false;
        }
        
       return result;
    }
    //https://unblu.cloud/app/rest/v3/invitations/requeueConversation
    @RemoteAction
    global static Boolean unbluRequeueConversation(String unbluConvId){
        Boolean result = true;
        String url = '/invitations/requeueConversation';
        try{
            Map<String, Object> body = new Map<String, Object>();
            body.put('conversationId', unbluConvId);
            body.put('agentRemovalType', 'REMOVE_ASSIGNED_AGENT');
            String bodyString = JSON.serialize(body);
            
            HttpResponse response = UnbluRestClient.executeRequest('POST', url,bodyString );
            insertDebugLog(unbluConvId,'INFO', 'unblu_ws_request', 'POST',url , bodyString, response.getBody());
            if ( response.getStatusCode() != 200 ){
                result = false;
            }
        }catch(Exception e){
            insertDebugLog(unbluConvId,'ERROR', 'unblu_ws_request', 'POST', '', '', e.getMessage());
            result = false;
        }
        
       return result;
    }
    @RemoteAction
    global static Case updateUnbluChatAccepted(String caseId){
        Case c = new Case(Id=caseId,OwnerId=UserInfo.getUserId(),UnbluChatStatus__c='accepted');
        upsert c;
        return c;
    }

    @RemoteAction
    global static Case updateUnbluChatEnded(String caseId){
        Case c = new Case(Id=caseId,UnbluChatStatus__c='ended');
        upsert c;
        return c;
    }

    global static void insertDebugLog(String unbluId,String loglevel,String action, String method, String url,  String body,String response){
        softphone_it__Softphone_Gc_Sync_Log__c softphoneLog = createDebugLog(unbluId,loglevel,action,method,url,body,response);
        insert softphoneLog;
    }

    global static softphone_it__Softphone_Gc_Sync_Log__c createDebugLog(String unbluId,String loglevel,String action, String method, String objId,  String body,String response){
        softphone_it__Softphone_Gc_Sync_Log__c softphoneLog = new softphone_it__Softphone_Gc_Sync_Log__c();
        datetime dateTimeNow = datetime.now();
        softphoneLog.ChatId__c = unbluId;
        softphoneLog.softphone_it__Log_Level__c = loglevel;
        softphoneLog.softphone_it__Action__c = action;
        softphoneLog.softphone_it__Date__c = dateTimeNow;
        softphoneLog.softphone_it__ws_method__c = method;
        softphoneLog.softphone_it__ws_url__c = objId;
        softphoneLog.softphone_it__ws_body__c = body;
        softphoneLog.softphone_it__ws_response__c = response;
        return softphoneLog;
    }
    
}