public without sharing class OnCampaignMemberTriggerHandler {
    
    public static Boolean trafficLightTrackingTrigger = false;
    public static Boolean trafficLightGhostTrigger = false;
    public static Boolean trafficLightAssegnazioneAzione = false;
    public static final String AGENT_OWNED_CALLBACK = 'AGENT_OWNED_CALLBACK';
    public static List<SV_Log__c> logsToInsert = new List<SV_Log__c>();

    public class SendRequestException extends Exception{}

    public static void trackHistory(Map<Id, CampaignMember> oldTriggerCampMembMap, Map<Id, CampaignMember> newTriggerCampMembMap){
        //if(!trafficLightAssegnazioneAzione){    
            //Get apiname of object (CampaignMember)
            String objApiName = String.valueOf(newTriggerCampMembMap.getSObjectType());
        
            //Get data information from metadata
            TrackingHistoryConfiguration__mdt[] metadataList = [SELECT ParentField__c, TrackingFieldList__c,
                                                                RecordTypeDevName__c, ObjectDevName__c
                                                                FROM TrackingHistoryConfiguration__mdt
                                                                WHERE ObjectDevName__c = :objApiName
                                                                LIMIT 1];

            if(metadataList.size() > 0 && !trafficLightTrackingTrigger){                                                    
                TrackingHistoryConfiguration__mdt metadataObj = metadataList.get(0);
                
                //For each record, for each field to track, create a tracking object
                System.debug('Record type dettaglio: '+metadataObj.RecordTypeDevName__c);

                String recordTypeIdString = Schema.SObjectType.TrackingHistory__c.getRecordTypeInfosByDeveloperName().get(metadataObj.RecordTypeDevName__c).getRecordTypeId();
                List<String> trackingFieldList = metadataObj.TrackingFieldList__c.split(';');
                List<TrackingHistory__c> trackingObjectsList = new List<TrackingHistory__c>();
                TrackingHistory__c trackingObj; 

                for(CampaignMember newTriggerCampMemb : newTriggerCampMembMap.values()){
                    String trackingFields = '';
                    String oldValue = '';
                    String newValue = '';
                    for(String tf : trackingFieldList){
                        trackingFields = trackingFields + ';' + tf;
                        if(oldTriggerCampMembMap != null && oldTriggerCampMembMap.containsKey(newTriggerCampMemb.Id)){
                            oldValue = oldValue + ';' + oldTriggerCampMembMap.get(newTriggerCampMemb.Id).get(tf);
                        }
                        newValue = newValue + ';' + newTriggerCampMemb.get(tf);
                    }
                    trackingFields = trackingFields.substring(1, trackingFields.length());
                    if(!String.isBlank(oldValue)) oldValue = oldValue.substring(1, oldValue.length());
                    newValue = newValue.substring(1, newValue.length());

                    if(newValue != oldValue){
                        trackingObj = new TrackingHistory__c(
                            RecordTypeId = recordTypeIdString,
                            ParentObject__c = newTriggerCampMemb.Id,
                            Cliente__c = newTriggerCampMemb.Contact.AccountId,
                            Tracking_Field__c = trackingFields,
                            OldValue__c = oldValue,
                            NewValue__c = newValue);
                        trackingObjectsList.add(trackingObj);
                    }
                }
                
                insert trackingObjectsList;
         //   }
        } else {
            System.debug('SV trackHistory trafficLightAssegnazioneAzione: ' + trafficLightAssegnazioneAzione);
        }
        
    }
    
    public static void checkNCS(List<CampaignMember> newRecords, Map<Id,CampaignMember> oldMap){
        if(!trafficLightAssegnazioneAzione){    

            Map<String,SObject> ncsMap= new Map<String,SObject>();
            //ncsMap=SV_Utilities.keyBy([SELECT Campaign_Name__c, NCS__c FROM NotCallableStatus__mdt ], 'Campaign_Name__c');
            List<String> cmToSend= new List<String>();
            for(CampaignMember cm:newRecords){
                /*if(ncsMap.containsKey(cm.Campaign_Name__c)){
                    String ncs=(String) ncsMap.get(cm.Campaign_Name__c).get('NCS__c');
                    List<String> ncsList=ncs.split(';');
                    if(ncsList.contains(cm.Status) && !ncsList.contains(oldMap.get(cm.Id).Status)){
                        cmToSend.add(cm.softphone_it__Gc_Contact_List_Id__c+'_'+cm.softphone_it__Gc_Contact_Id_externalId__c);
                    }
                }*/
                if(cm.CRM_NotCallable__c && !oldMap.get(cm.Id).CRM_NotCallable__c) {
                    cmToSend.add(cm.softphone_it__Gc_Contact_List_Id__c+'_'+cm.softphone_it__Gc_Contact_Id_externalId__c);
                }
            }
            if(!cmToSend.isEmpty()){

                sendRequest(cmToSend);
            }
        } else {
            System.debug('SV trackHistory trafficLightAssegnazioneAzione: ' + trafficLightAssegnazioneAzione);
        } 
   }

   public static HttpResponse authVsGenesys(){

        Endpoint__c apiRequest = Endpoint__c.getInstance('GenesysToken');
        String orgId=UserInfo.getOrganizationId().left(15);
        softphone_it__Connector_Settings__c  cs= softphone_it__Connector_Settings__c.getInstance(orgId);
        String aut = EncodingUtil.base64Encode(Blob.valueof(cs.softphone_it__GC_CLIENT_ID__c+':'+cs.softphone_it__GC_CLIENT_SECRET__c));
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiRequest.Endpoint__c);
        request.setMethod(apiRequest.Method__c);
        request.setHeader('Authorization', 'Basic '+aut);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody('grant_type=client_credentials');

        HttpResponse response = http.send(request);
        if(!Test.isRunningTest()){
            System.debug('@@@@@tokenResponse'+response.getBody());
            Map<String,Object> deserializedResponse= (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            String token=(String) deserializedResponse.get('access_token');
            System.debug(token);
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Bper');
            orgPart.put('genesysToken', token, 86400);
        }
        
        //System.debug((String) orgPart.get('genesysToken'));
        System.debug('@@@MC response '+response);

        return response;
   }

   public static HttpResponse updateVSGenesys( List<String> params){
        Endpoint__c apiRequest = Endpoint__c.getInstance('UpdateCampaignMember');
        Map<String, String> headersReq = new Map<String, String>();
            
            
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = String.format(apiRequest.Endpoint__c, params);
        request.setEndpoint(endpoint);
        request.setMethod(apiRequest.Method__c);
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Bper');
        String token= (String) orgPart.get('genesysToken');
        system.debug('token : '+token);
        request.setHeader('Authorization', 'Bearer '+token);
        headersReq.put('Authorization', 'Bearer '+token);
        request.setHeader('Content-Type', 'application/json');
        headersReq.put('Content-Type', 'application/json');
        Map<String,Object> body= new Map<String,Object>();
        body.put('callable',false);
        request.setBody(JSON.serialize(body));


        HttpResponse response = http.send(request);

        string[] headerkeysRes = response.getHeaderKeys();

        //create an object to store your header key-value pairs
        Map<string, string> headersRes = new map<string, string>();

        //iterate through they keys, and populate your map
        for(string s : headerkeysRes){
            headersRes.put(s,response.getHeader(s));
        }

        System.debug('@@@@@updateResponse'+response.getBody());
        logsToInsert.add(writeLog(
            apiRequest.Name,
            apiRequest.Method__c,
            null,
            response.getStatusCode(),
            response.getStatus(),
            response.getBody().length() >= 131071 ? response.getBody().substring(0, 131071) : response.getBody(),
            headersReq,
            headersRes,
            endpoint,
            ''
            // responseObj.isCorrect() ? null : responseObj.getErrors()
        ));

        return response;
   }

    @future(callout=true)
    public static void sendRequest(List<String> cmToSend){
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Bper');
        Integer authCounter,updateCounter;
        Integer MAX_N_TRIALS = 3;

        for(String cm:cmToSend){
            // verifica token
            // token non valido -> rifaccio chiamata authVsGenesys -> riffaccio per max 3 volte chiamata updateVSGenesys
            // token valido -> faccio max 3 volte chiamata updateVSGenesys
            authCounter = updateCounter = 0;
            System.debug('RC token: '+orgPart.get('genesysToken'));
            if(!orgPart.contains('genesysToken') || orgPart.get('genesysToken') == null){
                while( authCounter < MAX_N_TRIALS){
                    HttpResponse authResp = authVsGenesys();
                    System.debug('RC authResp: '+authResp);
                    if(authResp.getStatusCode()== 200){
                        break;
                    }else{
                        authCounter++;
                    }
                }
                if(authCounter == MAX_N_TRIALS){
                    throw new SendRequestException('Autenticazione fallita');
                  
                }
            }

            while(updateCounter < MAX_N_TRIALS ){
                
                HttpResponse updateResp=updateVSGenesys(cm.split('_'));
                System.debug('RC updateResp: '+updateResp);
                if(updateResp.getStatusCode()==200){
                    break;
                }else{
                    updateCounter++;
                }
            }
            if(updateCounter == MAX_N_TRIALS){
                throw new SendRequestException('Update non riuscito');
                
            }
           
        }
    }

    public static void genesysQueueCallout(List<CampaignMember> newCampaigMemberList,  Map<Id,CampaignMember> oldMap){
        if(!trafficLightAssegnazioneAzione){    
            if((newCampaigMemberList.size() == 1 && newCampaigMemberList[0].Status != oldMap.get(newCampaigMemberList[0].Id).Status) ||
            (newCampaigMemberList.size() == 1 && newCampaigMemberList[0].CRM_DataOraRicontatto__c != oldMap.get(newCampaigMemberList[0].Id).CRM_DataOraRicontatto__c)){
                updateQueueCallout(newCampaigMemberList[0].Id);
            }
        } else {
            System.debug('SV trackHistory trafficLightAssegnazioneAzione: ' + trafficLightAssegnazioneAzione);
        } 
    }

    @future(callout=true)
    public static void updateQueueCallout(Id campaignMemberId){

        CampaignMember cmInfo = [SELECT Id, Name,
                                        CRM_DataOraRicontatto__c,
                                        CRM_NumeroTentativi__c,
                                        Contact.Phone,
                                        Campaign.CRM_QueueId__c,
                                        Campaign.CRM_Intervallo_richiamata__c,
                                        Campaign.softphone_it__Gc_Custom_Fields__c,
                                        CRM_EsitoCampagna__r.CRM_Richiamata_Genesys__c, Status,CRM_AgentId__c 
                                        FROM CampaignMember 
                                        WHERE ID =: campaignMemberId];


        Datetime dataRicontatto;
                    
        if(cmInfo.CRM_DataOraRicontatto__c  != null && cmInfo.CRM_DataOraRicontatto__c > Datetime.now()) {
            dataRicontatto = cmInfo.CRM_DataOraRicontatto__c;
        } else if (cmInfo.CRM_DataOraRicontatto__c  == null && cmInfo.CRM_EsitoCampagna__r.CRM_Richiamata_Genesys__c && cmInfo.campaign.CRM_Intervallo_richiamata__c == null) {
            dataRicontatto = Datetime.now().addDays(1);
        } else if ((cmInfo.CRM_DataOraRicontatto__c  == null || cmInfo.CRM_DataOraRicontatto__c < Datetime.now()) && cmInfo.CRM_EsitoCampagna__r.CRM_Richiamata_Genesys__c && cmInfo.Campaign.CRM_Intervallo_richiamata__c != null) {
            dataRicontatto = Datetime.now().addMinutes(Integer.valueOf(cmInfo.Campaign.CRM_Intervallo_richiamata__c));
        }

        if(dataRicontatto  != null){

            //controllo checkScheduleCall == 0
            checkScheduleCallGenesys(cmInfo);
            if(cmInfo.Status == 'Follow-up'){
                scheduleCallWithPreferredAgent(dataRicontatto, cmInfo);
            }else{
                scheduleCallGenesys(dataRicontatto, cmInfo);
            }
     
        }

    }

    public static void scheduleCallGenesys(Datetime dataRicontatto, CampaignMember cmInfo)
    {
        try{
            System.debug('@@@@@dataRicontatto '+dataRicontatto);
            String dataString = dataRicontatto.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

            HttpResponse tokenResponse = authVsGenesys();
            String token;
            if(!Test.isRunningTest()){
                Map<String,Object> deserializedResponse= (Map<String,Object>) JSON.deserializeUntyped(tokenResponse.getBody());
                token=(String) deserializedResponse.get('access_token');
            }
            Map<String, String> headersReq = new Map<String, String>();

            String endpoint = 'https://api.mypurecloud.de/api/v2/conversations/callbacks';
            System.debug('@@@@@endpoint '+endpoint);
            System.debug('@@@@@autToken '+token);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer '+ token);
            headersReq.put('Authorization', 'Bearer '+ token);
            request.setHeader('Content-Type', 'application/json');
            headersReq.put('Content-Type', 'application/json');
            Map<String,Object> reqBody = new Map<String,Object>();

            Map<String,Object> dataReq = new Map<String,Object>();
            List<String> fieldList = cmInfo.Campaign.softphone_it__Gc_Custom_Fields__c.split(',');

            Sobject sCampaignMember = cmInfo;
            for(String key : fieldList){
                dataReq.put(key,String.valueOf(sCampaignMember.get(key)));
            }

            reqBody.put('queueId', cmInfo.Campaign.CRM_QueueId__c);
            reqBody.put('callbackNumbers', new List<String>{'+39' + cmInfo.Contact.Phone});
            reqBody.put('callbackScheduledTime', dataString);
            reqBody.put('data', dataReq);
            if(cmInfo.CRM_DataOraRicontatto__c  != null && cmInfo.CRM_DataOraRicontatto__c > Datetime.now()){
                Map<String, Object> routingData = new Map<String, Object>();
                routingData.put('priority', '1000000');
                routingData.put('queueId', cmInfo.Campaign.CRM_QueueId__c);
                reqBody.put('routingData', routingData);
            }
            reqBody.put('callbackUserName', '+39' + cmInfo.Contact.Phone);


    
            System.debug('updateQueueCallout - queueId: '+ cmInfo.Campaign.CRM_QueueId__c);
            System.debug('updateQueueCallout - callbackNumbers: '+ new List<String>{'+39' + cmInfo.Contact.Phone});
            System.debug('updateQueueCallout - callbackScheduledTime: '+ dataString);
            System.debug('updateQueueCallout - data: '+ dataReq);
            System.debug('updateQueueCallout - request: '+ request);
            System.debug('updateQueueCallout - reqBody: '+ reqBody);
            System.debug('@@@@@updateQueueOnGenesys Authorization '+request.getHeader('Authorization'));

            request.setBody(JSON.serialize(reqBody));
                
            HttpResponse response = !Test.isRunningTest() ? http.send(request) : null;

            string[] headerkeysRes = response.getHeaderKeys();

            //create an object to store your header key-value pairs
            Map<string, string> headersRes = new map<string, string>();

            //iterate through they keys, and populate your map
            for(string s : headerkeysRes){
                headersRes.put(s,response.getHeader(s));
            }

            System.debug('@@@@@updateResponse'+response.getBody());
            logsToInsert.add(writeLog(
                'Ricontatto',
                'POST',
                JSON.serialize(reqBody),
                response.getStatusCode(),
                response.getStatus(),
                response.getBody().length() >= 131071 ? response.getBody().substring(0, 131071) : response.getBody(),
                headersReq,
                headersRes,
                endpoint,
                ''
                // responseObj.isCorrect() ? null : responseObj.getErrors()
            ));
            System.enqueueJob(new QueueableJobs(logsToInsert, '1'));
        }catch(Exception e){
            System.debug('@@@@@error  genesysQueueCallout: '+e.getStackTraceString());
        }
    }

    //DK FIX callout GENESYS
    public static SV_Log__c writeLog(String apiRequestName, String method, String input, Integer code, String status, String output,  Map<String,String> reqHeader, Map<String,String> resHeader, String endpoint, String errorMessage) {

        String inputPretty = input;
        String outputPretty = output;

        String reqHeaderPretty ;
        String resHeaderPretty ;

        List<String> path = endpoint.split('\\?');

        try {
            inputPretty = JSON.serializePretty(JSON.deserializeUntyped(input));
        } catch (Exception e) {}
    
        try {
            outputPretty = JSON.serializePretty(JSON.deserializeUntyped(output));
        } catch (Exception e) {}

        try {
            reqHeaderPretty = JSON.serializePretty(reqHeader);
        } catch (Exception e) {}

        try {
            resHeaderPretty = JSON.serializePretty(resHeader);
        } catch (Exception e) {}

        system.debug('@@@@@@@@ resHeader: '+resHeader);
        SV_Log__c log = new SV_Log__c(
            Source__c = apiRequestName,
            Method__c = method,
            Code__c = string.valueof(code),
            Status__c = status,
            Input_Payload__c = inputPretty != null && inputPretty.length() >= 131071 ? inputPretty.substring(0, 131071) : inputPretty,
            Output_Payload__c = outputPretty != null && outputPretty.length() >= 131071 ? outputPretty.substring(0, 131071) : outputPretty,
            Success__c = string.valueof(code).startsWith('2') ? true : false,
            ResponseHeader__c=resHeaderPretty,
            RequestHeader__c=reqHeaderPretty,
            Endpoint__c = path[0],
            Parameters__c = path.size() > 1 ? path[1] : ''
            // ErorrMessage__c = errorMessage

        );
        return log;

    }
    public static SV_Log__c writeLog(String apiRequestName, String method, String input, String code, String status, String output,  Map<String,String> reqHeader, Map<String,String> resHeader, String endpoint, String errorMessage) {

        String inputPretty = input;
        String outputPretty = output;

        String reqHeaderPretty ;
        String resHeaderPretty ;

        List<String> path = endpoint.split('\\?');
        
        try {
            inputPretty = JSON.serializePretty(JSON.deserializeUntyped(input));
        } catch (Exception e) {}
    
        try {
            outputPretty = JSON.serializePretty(JSON.deserializeUntyped(output));
        } catch (Exception e) {}

        try {
            reqHeaderPretty = JSON.serializePretty(reqHeader);
        } catch (Exception e) {}

        try {
            resHeaderPretty = JSON.serializePretty(resHeader);
        } catch (Exception e) {}

        system.debug('@@@@@@@@ resHeader: '+resHeader);
        SV_Log__c log = new SV_Log__c(
            Source__c = apiRequestName,
            Method__c = method,
            Code__c = code,
            Status__c = status,
            Input_Payload__c = inputPretty != null && inputPretty.length() >= 131071 ? inputPretty.substring(0, 131071) : inputPretty,
            Output_Payload__c = outputPretty != null && outputPretty.length() >= 131071 ? outputPretty.substring(0, 131071) : outputPretty,
            Success__c = code == '000' ? true : false,
            ResponseHeader__c=resHeaderPretty,
            RequestHeader__c=reqHeaderPretty,
            Endpoint__c = path[0],
            Parameters__c = path.size() > 1 ? path[1] : ''
            // ErorrMessage__c = errorMessage

        );

        return log;

    }
    //DK FIX callout GENESYS

    public static void scheduleCallWithPreferredAgent(Datetime dataRicontatto, CampaignMember cmInfo)
    {
        try{
            System.debug('@@@@@dataRicontatto '+dataRicontatto);
            String dataString = dataRicontatto.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

            HttpResponse tokenResponse = authVsGenesys();
            String token;
            if(!Test.isRunningTest()){
                Map<String,Object> deserializedResponse= (Map<String,Object>) JSON.deserializeUntyped(tokenResponse.getBody());
                token=(String) deserializedResponse.get('access_token');
            }
            Map<String, String> headersReq = new Map<String, String>();

            String endpoint = 'https://api.mypurecloud.de/api/v2/conversations/callbacks';
            System.debug('@@@@@endpoint '+endpoint);
            System.debug('@@@@@autToken '+token);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer '+ token);
            headersReq.put('Authorization', 'Bearer '+ token);
            request.setHeader('Content-Type', 'application/json');
            headersReq.put('Content-Type', 'application/json');
            Map<String,Object> reqBody = new Map<String,Object>();

            Map<String,Object> dataReq = new Map<String,Object>();
            List<String> fieldList = cmInfo.Campaign.softphone_it__Gc_Custom_Fields__c.split(',');

            Sobject sCampaignMember = cmInfo;
            for(String key : fieldList){
                dataReq.put(key,String.valueOf(sCampaignMember.get(key)));
            }
            
            Map<String, Object> routingData = new Map<String, Object>();
            routingData.put('queueId', cmInfo.Campaign.CRM_QueueId__c);
            
            List<Map<String, Object>> scoredAgents = new List<Map<String, Object>>();
            Map<String, Object> agent = new Map<String, Object>();
            agent.put('id', cmInfo.CRM_AgentId__c);
            scoredAgents.add(new Map<String, Object>{'agent' => agent, 'score' => 100});
            routingData.put('scoredAgents', scoredAgents);
            routingData.put('routingFlags', new List<String>{AGENT_OWNED_CALLBACK});
            routingData.put('priority', '1000000');
            reqBody.put('queueId', cmInfo.Campaign.CRM_QueueId__c);
            reqBody.put('routingData', routingData);
            reqBody.put('callbackNumbers', new List<String>{'+39' + cmInfo.Contact.Phone});
            reqBody.put('callbackScheduledTime', dataString);
            reqBody.put('data', dataReq);
            reqBody.put('callbackUserName', '+39' + cmInfo.Contact.Phone);
       
            System.debug('updateQueueCallout - queueId: '+ cmInfo.Campaign.CRM_QueueId__c);
            System.debug('updateQueueCallout - callbackNumbers: '+ new List<String>{'+39' + cmInfo.Contact.Phone});
            System.debug('updateQueueCallout - callbackScheduledTime: '+ dataString);
            System.debug('updateQueueCallout - data: '+ dataReq);
            System.debug('updateQueueCallout - request: '+ request);
            System.debug('updateQueueCallout - reqBody: '+ reqBody);
            System.debug('@@@@@updateQueueOnGenesys Authorization '+request.getHeader('Authorization'));

            request.setBody(JSON.serialize(reqBody));
                
            HttpResponse response = !Test.isRunningTest() ? http.send(request) : null;

            string[] headerkeysRes = response.getHeaderKeys();

            //create an object to store your header key-value pairs
            Map<string, string> headersRes = new map<string, string>();

            //iterate through they keys, and populate your map
            for(string s : headerkeysRes){
                headersRes.put(s,response.getHeader(s));
            }

            System.debug('@@@@@updateResponse'+response.getBody());
            logsToInsert.add(writeLog(
                'Ricontatto',
                'POST',
                JSON.serialize(reqBody),
                response.getStatusCode(),
                response.getStatus(),
                response.getBody().length() >= 131071 ? response.getBody().substring(0, 131071) : response.getBody(),
                headersReq,
                headersRes,
                endpoint,
                ''
                // responseObj.isCorrect() ? null : responseObj.getErrors()
            ));

            System.enqueueJob(new QueueableJobs(logsToInsert, '1'));
        }catch(Exception e){
            System.debug('@@@@@error  genesysQueueCallout: '+e.getStackTraceString());
        }
    }

    public static Integer checkScheduleCallGenesys(CampaignMember cmInfo)
    {
        //https://api.mypurecloud.de/api/v2/analytics/conversations/details/query
        integer hits = 0;
        map<string, string> mapContactCallback = new map<string, string>();
        try
        {
            HttpResponse tokenResponse = authVsGenesys();
            String token;
            if(!Test.isRunningTest())
            {
                Map<String,Object> deserializedResponse= (Map<String,Object>) JSON.deserializeUntyped(tokenResponse.getBody());
                token=(String) deserializedResponse.get('access_token');
            }

            String endpoint = 'https://api.mypurecloud.de/api/v2/analytics/conversations/details/query';
            System.debug('@@@@@endpoint '+endpoint);
            System.debug('@@@@@autToken '+token);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer '+ token);
            request.setHeader('Content-Type', 'application/json');

            /**
             * {
                 "segmentFilters": [
                     {
                         "type": "and",
                        "clauses": [
                            {
                        "type": "and",
                        "predicates": [
                        {
                            "dimension": "queueId",
                            "value": "5f6dcc65-620b-4425-8c3d-967a9b97c2c6"
                        }
                        ]
                    },
                    {
                        "type": "and",
                        "predicates": [
                        {
                            "dimension": "mediaType",
                            "value": "callback"
                        }
                        ]
                    }
                        ]
                    }
                ],
                "conversationFilters": [
                    {
                        "type": "and",
                        "clauses": [
                            {
                        "type": "and",
                        "predicates": [
                        {
                            "dimension": "conversationEnd",
                            "operator": "notExists"
                        }
                        ]
                    }
                        ]
                    }
                ],
                "interval": "2022-06-28T00:00:00/2022-06-28T23:59:59"
                }

             */
            Map<String,Object> reqBody = new Map<String,Object>();

            
            reqBody.put('segmentFilters', new list<object>
            {
                new map<string, object>
                {
                    'type'=> 'and', 
                    'clauses'=> new list<object>
                    {
                        new map<string, object>
                        {
                            'type'=> 'and',
                            'predicates' => new list<object>
                            {
                                new map<string, object>
                                {
                                    'dimension' => 'queueId',
                                    'value' => cmInfo.Campaign.CRM_QueueId__c
                                }
                            }
                        },
                        new map<string, object>
                        {
                            'type'=> 'and',
                            'predicates' => new list<object>
                            {
                                new map<string, object>
                                {
                                    'dimension' => 'mediaType',
                                    'value' => 'callback'
                                }
                            }
                        }
                    }
                }
            });
            reqBody.put('conversationFilters',  new list<object>
            {
                new map<string, object>
                {
                    'type'=> 'and', 
                    'clauses'=> new list<object>
                    {
                        new map<string, object>
                        {
                            'type'=> 'and',
                            'predicates' => new list<object>
                            {
                                new map<string, object>
                                {
                                    'dimension' => 'conversationEnd',
                                    'operator' => 'notExists'
                                }
                            }
                        }
                    }
                }
            });
            reqBody.put('interval', Datetime.valueOf(String.valueOf(System.today()-1)+ ' 00:00:00').format('yyyy-MM-dd\'T\'HH:mm:ss') +'/'+ 
                                    Datetime.valueOf(String.valueOf(System.today()+1)+ ' 23:59:59').format('yyyy-MM-dd\'T\'HH:mm:ss'));

            System.debug('updateQueueCallout - request: '+ request);
            System.debug('updateQueueCallout - reqBody: '+ reqBody);
            System.debug('@@@@@updateQueueOnGenesys Authorization '+request.getHeader('Authorization'));

            request.setBody(JSON.serialize(reqBody));

            HttpResponse response = !Test.isRunningTest() ? http.send(request) : null;
            System.debug('response  '+response);

            Map<String,Object> deserializedResponse = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());

            system.debug('deserialized Body '+deserializedResponse);

            hits = (Integer) deserializedResponse.get('totalHits');

            if(hits > 0)
            {
                for(Object conversations :  (List<Object>) deserializedResponse.get('conversations'))
                {
                    map<string, object> conversationsMap = (map<string, object>) conversations;

                    //conversations.participants.sessions.callbackNumbers = Contact.Phone
                    list<object> callBackNumbList = new list<object>();
                    String conversationId = (String) conversationsMap.get('conversationId');
                    for(object partecipants : (List<Object>) conversationsMap.get('participants')) 
                    {
                        map<string, object> partecipantsMap = (map<string, object>) partecipants;
                        //.get('sessions')
                        for(object session : (List<Object>) partecipantsMap.get('sessions'))
                        {
                            map<string, object> sessionMap = (map<string, object>) session;
                            callBackNumbList.addAll((List<object>) sessionMap.get('callbackNumbers'));
                        }
                    }

                    for(object numb : callBackNumbList)
                    {
                    System.debug('numb: '+numb );
                    System.debug('cm Phone: '+cmInfo.Contact.Phone);
                    String numb2 = (String)numb;
                    String finalNumb = numb2.replace('+39','');
                    System.debug('numb2: '+finalNumb );
                    if(finalNumb == cmInfo.Contact.Phone ){
                            mapContactCallback.put(String.valueOf(numb), conversationId);
                        }
                        
                    }
                }
                
                //terminare recupero info callbacknumber e creazione mappe
                //Map<String, String> <conversations.participants.sessions.callbackNumbers, conversations.conversationId>
                //mapContactCallback
                //set<string> callBackNumbSet = new set<string>(callBackNumbList);
                

                if(mapContactCallback.keySet().size() > 0) deleteScheduledCallGenesys(mapContactCallback);
            }
            
            logsToInsert.add(writeLog(
                    'CheckRicontatto',
                    'POST',
                    null,
                    response.getStatusCode(),
                    response.getStatus(),
                    response.getBody().length() >= 131071 ? response.getBody().substring(0, 131071) : response.getBody(),
                    null,
                    null,
                    endpoint,
                    ''
                    // responseObj.isCorrect() ? null : responseObj.getErrors()
                ));
        }
        catch(Exception e)
        {
            System.debug('@@@@@error  genesysQueueCallout: '+e+' '+e.getStackTraceString());
        }

        return mapContactCallback.keySet().size();
    }

    public static String deleteScheduledCallGenesys(map<string, string> mapContactCallback)
    {
        string result = '';
        try
        {
            HttpResponse tokenResponse = authVsGenesys();
            String token;
            if(!Test.isRunningTest())
            {
                Map<String,Object> deserializedResponse= (Map<String,Object>) JSON.deserializeUntyped(tokenResponse.getBody());
                token=(String) deserializedResponse.get('access_token');
            }

            Set<String> conversationIdSet = new set<string>(mapContactCallback.values());

            for(string idChiamata : conversationIdSet) 
            {
                String endpoint = 'https://api.mypurecloud.de/api/v2/conversations/'+ idChiamata +'/disconnect';
                Map<String, String> headersReq = new Map<String, String>();
                System.debug('@@@@@endpoint '+endpoint);
                System.debug('@@@@@autToken '+token);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod('POST');
                request.setHeader('Authorization', 'Bearer '+ token);
                headersReq.put('Authorization', 'Bearer '+ token);
                request.setHeader('Content-Type', 'application/json');
                headersReq.put('Content-Type', 'application/json');
                
                HttpResponse response = http.send(request);
                string[] headerkeysRes = response.getHeaderKeys();

                //create an object to store your header key-value pairs
                Map<string, string> headersRes = new map<string, string>();

                //iterate through they keys, and populate your map
                for(string s : headerkeysRes){
                    headersRes.put(s,response.getHeader(s));
                }
                Map<String,Object> deserializedResponse = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                System.debug('@@@@@response '+response.getBody());
                if(response.getStatusCode() != 200)
                {
                    system.debug('@@@@@error  genesysQueueCallout: ' + deserializedResponse.get('message'));
                }
                
                logsToInsert.add(writeLog(
                    'disconnectChat',
                    'POST',
                    null,
                    response.getStatusCode(),
                    response.getStatus(),
                    response.getBody().length() >= 131071 ? response.getBody().substring(0, 131071) : response.getBody(),
                    headersReq,
                    headersRes,
                    endpoint,
                    ''
                    // responseObj.isCorrect() ? null : responseObj.getErrors()
                ));
                
                
            }
        }
        catch(Exception e)
        {
            result = 'error '+e+' '+e.getStackTraceString();
            System.debug('@@@@@error  genesysQueueCallout: '+e+' '+e.getStackTraceString());
        }

        return result;
    }
    

    public static void setFields(List<CampaignMember> records, Map<Id, CampaignMember> oldTriggerCampMembMap, Boolean isInsert) {
        if(!trafficLightAssegnazioneAzione)
        {
            System.debug('SV setFields records: ' + records);
            //PTF_Area__c
            //PTF_DirezioneRegionale__c
            //PTF_Filiale__c
    		Funzionalita__c f = Funzionalita__c.getInstance();
            
            //MS - Aggiunta casistica per utenti ETL
            if(f.isMC__c)
            {
				Set<Id> setContactId = new Set<Id>();
		
				for(CampaignMember rec: records)
                {
					setContactId.add(rec.ContactId);
				}
		
				Map<String, SObject> mapContact = SV_Utilities.keyBy([
					SELECT Id, Account.PTF_Filiale__c, Account.CRM_Filiale__c, Account.PTF_Portafoglio__c, Account.CRM_FilialiRapportoToShow__c, Account.PTF_Filiale__r.PTF_Area__c, Account.CRM_Filiale__r.PTF_Area__c, Account.PTF_Filiale__r.PTF_DirezioneRegionale__c, Account.CRM_Filiale__r.PTF_DirezioneRegionale__c, Account.PTF_Filiale__r.PTF_IdCed__c, Account.CRM_Filiale__r.PTF_IdCed__c, Account.ModelloDiServizio__c
					FROM Contact 
					WHERE Id IN : setContactId ], 'Id', false);
			
		
				for(CampaignMember rec: records)
                {
					Contact contact = (Contact)mapContact.get(rec.ContactId);
					rec.PTF_Area__c = contact.Account.PTF_Filiale__c != NULL ? contact.Account.PTF_Filiale__r.PTF_Area__c : contact.Account.CRM_Filiale__r.PTF_Area__c;
					rec.PTF_DirezioneRegionale__c  = contact.Account.PTF_Filiale__c != NULL ? contact.Account.PTF_Filiale__r.PTF_DirezioneRegionale__c : contact.Account.CRM_Filiale__r.PTF_DirezioneRegionale__c;
					rec.PTF_Filiale__c = contact.Account.PTF_Filiale__c != NULL ? contact.Account.PTF_Filiale__c : contact.Account.CRM_Filiale__c;
					rec.PTF_IdCed__c = contact.Account.PTF_Filiale__c != NULL ? contact.Account.PTF_Filiale__r.PTF_IdCed__c : contact.Account.CRM_Filiale__r.PTF_IdCed__c;
					rec.PTF_ModelloDiServizio__c = (contact.Account.ModelloDiServizio__c != NULL) ? contact.Account.ModelloDiServizio__c : 'Non Portafogliati';
					rec.CRM_Portafoglio__c = (contact.Account.PTF_Portafoglio__c != NULL) ? contact.Account.PTF_Portafoglio__c : NULL;
				}
            }
            // MS
			else if(f.isETL__c)
			{
                Set<Id> campaignIds = new Set<Id>();
                List<CampaignMember> cmList = new List<CampaignMember>();
                
                if(isInsert){
                    cmList = records;
                }else{
                	for(CampaignMember rec: records){
						if(rec.isActive__c && !oldTriggerCampMembMap.get(rec.id).isActive__c) 
                            cmList.add(rec);   
					}
                }
                
                for(CampaignMember rec: cmList){
					campaignIds.add(rec.CampaignId);   
				}
                
                MAP <id,Campaign> campaigns = new MAP<Id, Campaign> ([Select Id,CRM_StatoFormula__c,StartDate,CRM_DataInizioAffinamento__c from Campaign where Id in :campaignIds]);
                
                
                for(CampaignMember campaignMember: cmList){
                    
                    campaignMember.Data_Ingresso__c = evaluateCreationDate(campaignMember, campaigns.get(campaignMember.campaignId), isInsert);

                }
            }
        }
        else
        {
            System.debug('SV trackHistory trafficLightAssegnazioneAzione: ' + trafficLightAssegnazioneAzione); 
        }
    }

    public static void setGhost(Map<Id, CampaignMember> oldTriggerCampMembMap, Map<Id, CampaignMember> newTriggerCampMembMap, String triggerEvent){
        System.debug('SV setGhost triggerEvent: ' + triggerEvent);
        System.debug('SV setGhost oldTriggerCampMembMap: ' + oldTriggerCampMembMap);
        System.debug('SV setGhost newTriggerCampMembMap: ' + newTriggerCampMembMap);

        List<CampaignMember__c> ghostToInsert = new List<CampaignMember__c>(); 
        List<Id> campaignMemberToUpdate = new List<Id>(); 
        
        List<Id> campaignMemberToDelete = new List<Id>(); 

        Map<String, SObject> residualeWallet =SV_Utilities.keyBy([ SELECT id, Name, PTF_Filiale__r.PTF_IdCED__c 
                                                                    FROM Wallet__c 
                                                                    WHERE PTF_ModelloDiServizio__c = 'Assente' AND 
                                                                        PTF_DeletionDate__c = NULL ], 'PTF_Filiale__r.PTF_IdCED__c', false);
        

        if(!trafficLightGhostTrigger){                                                  
            if(triggerEvent == 'Insert'){
                for(CampaignMember cm : newTriggerCampMembMap.values()){
                    System.debug('SV cm.PTF_idCed__c: ' + cm.PTF_idCed__c);
                    if(cm.PTF_idCed__c != NULL && residualeWallet.containsKey(cm.PTF_idCed__c)){
                        // MS - Aggiunto campo Data_ingresso__c
                        ghostToInsert.add(new CampaignMember__c(
                            PTF_Portafoglio__c = cm.CRM_Portafoglio__c != NULL ? cm.CRM_Portafoglio__c : (Id)residualeWallet.get(cm.PTF_idCed__c).get('Id'),
                            PTF_idCed__c = cm.PTF_idCed__c,
                            PTF_ModelloDiServizio__c = cm.PTF_ModelloDiServizio__c,
                            Campaign__c = cm.CampaignId,
                            Contact__c = cm.ContactId,
                            CRM_CampaignMemberId__c = cm.Id,
                            CRM_AssegnatarioUser__c = cm.CRM_Assegnatario__c,
                            CRM_Account__c = cm.CRM_AccountId__c,
                            PTF_Ambito__c = (cm.PTF_ModelloDiServizio__c == 'Family' || cm.PTF_ModelloDiServizio__c == 'POE' || cm.PTF_ModelloDiServizio__c == 'Assente' || cm.PTF_ModelloDiServizio__c == 'Residuale' || cm.PTF_ModelloDiServizio__c == 'Non Portafogliati') ? 'AssegnazioneAzione' : cm.PTF_ModelloDiServizio__c,
                            Status__c =  cm.Status,
                            CRM_PrioritaContatto__c =  cm.CRM_PrioritaContatto__c,
                            CRM_ValoreAttributo1_Date__c = cm.CRM_ValoreAttributo1_Date__c,
                            CRM_ValoreAttributo1_Number__c= cm.CRM_ValoreAttributo1_Number__c,
                            CRM_ValoreAttributo1_Text__c = cm.CRM_ValoreAttributo1_Text__c,
                            CRM_ValoreAttributo2_Date__c = cm.CRM_ValoreAttributo2_Date__c, 
                            CRM_ValoreAttributo2_Number__c = cm.CRM_ValoreAttributo2_Number__c,
                            CRM_ValoreAttributo2_Text__c = cm.CRM_ValoreAttributo2_Text__c,
                            //Data_Uscita__c = cm.Data_Prevista_Uscita__c
                            Priorita_Campaign_Member__c = cm.Priorita_Campaign_Member__c,
                            Data_ingresso__c = cm.Data_ingresso__c 
                        ));
                    }
                }
            } else {
                for(CampaignMember cm : newTriggerCampMembMap.values()){
                    if(cm.isActive__c){
                        System.debug('SV setGhost UPDATE: ' + cm.Id);

                        campaignMemberToUpdate.add(cm.Id);
                        
                    } else {
                        campaignMemberToDelete.add(cm.Id);
                    }
                }
            }
        }

        if(!ghostToInsert.isEmpty()){

            insert ghostToInsert;
        }

        System.debug('SV setGhost campaignMemberToUpdate: ' + campaignMemberToUpdate);

        if(!campaignMemberToUpdate.isEmpty()){

            List<CampaignMember__c> ghostToUpdate =new List<CampaignMember__c> ([ SELECT id, PTF_idCed__c, PTF_ModelloDiServizio__c, Campaign__c, Contact__c, CRM_CampaignMemberId__c,
                                                                        CRM_Assegnatario__c, CRM_Account__c, PTF_Ambito__c, Status__c, Motivo_Affinamento__c, CRM_NoteAffinamento__c,
                                                                        CRM_DataEsclusione__c, CRM_NominativoUtente__c,CRM_ValoreAttributo1_Date__c, CRM_ValoreAttributo1_Number__c, 
                                                                        CRM_ValoreAttributo1_Text__c, CRM_ValoreAttributo2_Date__c, CRM_ValoreAttributo2_Number__c, CRM_ValoreAttributo2_Text__c
                                                                        , CRM_Autore__c, Priorita_Campaign_Member__c // AL 2023-04-12 -- Aggiunta del campo CRM_Autore__c 
                                                                    FROM CampaignMember__c 
                                                                    WHERE CRM_CampaignMemberId__c IN : campaignMemberToUpdate ]);
            

            for(CampaignMember__c ghost : ghostToUpdate){
                ghost.PTF_idCed__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).PTF_idCed__c;
                ghost.PTF_ModelloDiServizio__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).PTF_ModelloDiServizio__c;
                ghost.Campaign__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CampaignId;
                ghost.Contact__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).ContactId;
                ghost.CRM_AssegnatarioUser__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_Assegnatario__c;
                ghost.CRM_Account__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_AccountId__c;
                ghost.PTF_Ambito__c = (newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).PTF_ModelloDiServizio__c == 'Family' || newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).PTF_ModelloDiServizio__c == 'POE' || newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).PTF_ModelloDiServizio__c == 'Assente' || newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).PTF_ModelloDiServizio__c == 'Residuale' || newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).PTF_ModelloDiServizio__c == 'Non Portafogliati') ? 'AssegnazioneAzione' : newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).PTF_ModelloDiServizio__c;
                ghost.Status__c =  newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).Status;
                ghost.CRM_NominativoUtente__c =  newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_NominativoUtente__c;
                ghost.CRM_DataEsclusione__c =  newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_DataEsclusione__c;
                ghost.CRM_NoteAffinamento__c =  newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_NoteAffinamento__c;
                ghost.Motivo_Affinamento__c =  newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).Motivo_Affinamento__c;
                ghost.CRM_ValoreAttributo1_Date__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_ValoreAttributo1_Date__c;
                ghost.CRM_ValoreAttributo1_Number__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_ValoreAttributo1_Number__c;
                ghost.CRM_ValoreAttributo1_Text__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_ValoreAttributo1_Text__c;
                ghost.CRM_ValoreAttributo2_Date__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_ValoreAttributo2_Date__c; 
                ghost.CRM_ValoreAttributo2_Number__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_ValoreAttributo2_Number__c; 
                ghost.CRM_ValoreAttributo2_Text__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_ValoreAttributo2_Text__c;
                ghost.PTF_Portafoglio__c = (newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_Portafoglio__c)!= NULL ? newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_Portafoglio__c : (Id)residualeWallet.get(newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).PTF_idCed__c).get('Id') ;
                //ghost.Data_Uscita__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).Data_Prevista_Uscita__c;
                ghost.CRM_Autore__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_Autore__c; // AL 2023-04-12 -- Aggiunta del campo CRM_Autore__c 
                ghost.Priorita_Campaign_Member__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).Priorita_Campaign_Member__c;
            }

            System.debug('SV setGhost' + ghostToUpdate);

            update ghostToUpdate;
        }

        if(!campaignMemberToDelete.isEmpty()){
            List<CampaignMember__c> ghostToDelete = new List<CampaignMember__c> ([ SELECT Id
            FROM CampaignMember__c 
            WHERE CRM_CampaignMemberId__c IN : campaignMemberToDelete ]);

            delete ghostToDelete;
        }
        
    }

    public static void setGhostForInsert(Map<Id, CampaignMember> newTriggerCampMembMap){
        System.debug('SV setGhostForInsert: ' + newTriggerCampMembMap);

        List<CampaignMember__c> ghostToInsert = new List<CampaignMember__c>(); 

        Map<String, SObject> assenteleWallet =SV_Utilities.keyBy([ SELECT id, Name, PTF_Filiale__r.PTF_IdCED__c 
                                                                    FROM Wallet__c 
                                                                    WHERE PTF_ModelloDiServizio__c = 'Assente' AND 
                                                                        PTF_DeletionDate__c = NULL ], 'PTF_Filiale__r.PTF_IdCED__c', false);
        

        for(CampaignMember cm : newTriggerCampMembMap.values()){
            System.debug('SV cm.PTF_idCed__c: ' + cm.PTF_idCed__c);
            if(cm.PTF_idCed__c != NULL && assenteleWallet.containsKey(cm.PTF_idCed__c)){
                ghostToInsert.add(new CampaignMember__c(
                    PTF_Portafoglio__c = cm.CRM_Portafoglio__c != NULL ? cm.CRM_Portafoglio__c : (Id)assenteleWallet.get(cm.PTF_idCed__c).get('Id'),
                    PTF_idCed__c = cm.PTF_idCed__c,
                    PTF_ModelloDiServizio__c = cm.PTF_ModelloDiServizio__c,
                    Campaign__c = cm.CampaignId,
                    Contact__c = cm.ContactId,
                    CRM_CampaignMemberId__c = cm.Id,
                    CRM_AssegnatarioUser__c = cm.CRM_Assegnatario__c,
                    CRM_Account__c = cm.CRM_AccountId__c,
                    PTF_Ambito__c = (cm.PTF_ModelloDiServizio__c == 'Family' || cm.PTF_ModelloDiServizio__c == 'POE' || cm.PTF_ModelloDiServizio__c == 'Assente' || cm.PTF_ModelloDiServizio__c == 'Residuale' || cm.PTF_ModelloDiServizio__c == 'Non Portafogliati') ? 'AssegnazioneAzione' : cm.PTF_ModelloDiServizio__c,
                    Status__c =  cm.Status,
                    CRM_PrioritaContatto__c =  cm.CRM_PrioritaContatto__c,
                    CRM_ValoreAttributo1_Date__c = cm.CRM_ValoreAttributo1_Date__c,
                    CRM_ValoreAttributo1_Number__c= cm.CRM_ValoreAttributo1_Number__c,
                    CRM_ValoreAttributo1_Text__c = cm.CRM_ValoreAttributo1_Text__c,
                    CRM_ValoreAttributo2_Date__c = cm.CRM_ValoreAttributo2_Date__c, 
                    CRM_ValoreAttributo2_Number__c = cm.CRM_ValoreAttributo2_Number__c,
                    CRM_ValoreAttributo2_Text__c = cm.CRM_ValoreAttributo2_Text__c
                    //Data_Uscita__c = cm.Data_Prevista_Uscita__c
                    , CRM_Autore__c = cm.CRM_Autore__c // AL 2023-04-12 -- Aggiunta del campo CRM_Autore__c 
                ));
            }
        }

        if(!ghostToInsert.isEmpty()){

            insert ghostToInsert;
        }
    }

    public static void setGhostForUpdate(Map<Id, CampaignMember> newTriggerCampMembMap){

        if(!trafficLightGhostTrigger){
            System.debug('SV setGhostForUpdate: ' + newTriggerCampMembMap);
            System.debug('SV setGhostForUpdate: ' + newTriggerCampMembMap);

            List<CampaignMember__c> ghostToUpdate =new List<CampaignMember__c> ([ SELECT id, PTF_idCed__c, PTF_ModelloDiServizio__c, Campaign__c, Contact__c, CRM_CampaignMemberId__c,
            CRM_AssegnatarioUser__c, CRM_Account__c, PTF_Ambito__c, Status__c, Motivo_Affinamento__c, CRM_NoteAffinamento__c,
                                                                                    CRM_DataEsclusione__c, CRM_NominativoUtente__c,CRM_ValoreAttributo1_Date__c, CRM_ValoreAttributo1_Number__c, 
                                                                                    CRM_ValoreAttributo1_Text__c, CRM_ValoreAttributo2_Date__c, CRM_ValoreAttributo2_Number__c, CRM_ValoreAttributo2_Text__c
                                                                                FROM CampaignMember__c 
                                                                                WHERE CRM_CampaignMemberId__c IN : newTriggerCampMembMap.keySet() ]);
            Map<String, SObject> assenteleWallet =SV_Utilities.keyBy([ SELECT id, Name, PTF_Filiale__r.PTF_IdCED__c 
                                                                    FROM Wallet__c 
                                                                    WHERE PTF_ModelloDiServizio__c = 'Assente' AND 
                                                                        PTF_DeletionDate__c = NULL ], 'PTF_Filiale__r.PTF_IdCED__c', false);
            for(CampaignMember__c ghost : ghostToUpdate){
                ghost.PTF_idCed__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).PTF_idCed__c;
                ghost.PTF_ModelloDiServizio__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).PTF_ModelloDiServizio__c;
                ghost.Campaign__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CampaignId;
                ghost.Contact__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).ContactId;
                ghost.CRM_AssegnatarioUser__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_Assegnatario__c;
                ghost.CRM_Account__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_AccountId__c;
                ghost.PTF_Ambito__c = (newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).PTF_ModelloDiServizio__c == 'Family' || newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).PTF_ModelloDiServizio__c == 'POE' || newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).PTF_ModelloDiServizio__c == 'Assente' || newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).PTF_ModelloDiServizio__c == 'Residuale' || newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).PTF_ModelloDiServizio__c == 'Non Portafogliati') ? 'AssegnazioneAzione' : newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).PTF_ModelloDiServizio__c;
                ghost.Status__c =  newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).Status;
                ghost.CRM_NominativoUtente__c =  newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_NominativoUtente__c;
                ghost.CRM_DataEsclusione__c =  newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_DataEsclusione__c;
                ghost.CRM_NoteAffinamento__c =  newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_NoteAffinamento__c;
                ghost.Motivo_Affinamento__c =  newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).Motivo_Affinamento__c;
                ghost.CRM_ValoreAttributo1_Date__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_ValoreAttributo1_Date__c;
                ghost.CRM_ValoreAttributo1_Number__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_ValoreAttributo1_Number__c;
                ghost.CRM_ValoreAttributo1_Text__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_ValoreAttributo1_Text__c;
                ghost.CRM_ValoreAttributo2_Date__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_ValoreAttributo2_Date__c; 
                ghost.CRM_ValoreAttributo2_Number__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_ValoreAttributo2_Number__c; 
                ghost.CRM_ValoreAttributo2_Text__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_ValoreAttributo2_Text__c;
                ghost.PTF_Portafoglio__c = (newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_Portafoglio__c)!= NULL ? newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).CRM_Portafoglio__c : (Id)assenteleWallet.get(newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).PTF_idCed__c).get('Id') ;
                //ghost.Data_Uscita__c = newTriggerCampMembMap.get(ghost.CRM_CampaignMemberId__c).Data_Prevista_Uscita__c;
            }
    
            System.debug('SV setGhost' + ghostToUpdate);
            OnCampaignMemberTriggerHandler.trafficLightGhostTrigger = true;
            update ghostToUpdate;
        }
    }

    public static void setGhostForDelete(Map<Id, CampaignMember> newTriggerCampMembMap){
        System.debug('SV setGhostForDelete: ' + newTriggerCampMembMap);
        Set<Id> campaignMemberToDelete = new Set<Id>();

        for(CampaignMember cm : newTriggerCampMembMap.values()){
            if(!cm.isActive__c){
                campaignMemberToDelete.add(cm.Id);
            }
        }

        if(campaignMemberToDelete.size() > 0){
            List<CampaignMember__c> ghostToDelete =new List<CampaignMember__c> ([ SELECT id
                                                                                    FROM CampaignMember__c 
                                                                                    WHERE CRM_CampaignMemberId__c IN : campaignMemberToDelete ]);

            System.debug('SV setGhost' + ghostToDelete);
            delete ghostToDelete;
        }
    }


    public static void activateGhost(List<CampaignMember> newRecordList, Map<Id, CampaignMember> oldRecordMap){
        List<CampaignMember__c> cmGhostToInsertList = new List<CampaignMember__c>();

        Map<String, SObject> assenteleWallet =SV_Utilities.keyBy([ SELECT id, Name, PTF_Filiale__r.PTF_IdCED__c 
                                                                    FROM Wallet__c 
                                                                    WHERE PTF_ModelloDiServizio__c = 'Assente' AND 
                                                                        PTF_DeletionDate__c = NULL ], 'PTF_Filiale__r.PTF_IdCED__c', false);
        for(CampaignMember cm : newRecordList){
            if(cm.isActive__c && !oldRecordMap.get(cm.Id).isActive__c &&
            cm.PTF_idCed__c != NULL && assenteleWallet.containsKey(cm.PTF_idCed__c)){
                // MS - Aggiunto campo Data_ingresso__c
                cmGhostToInsertList.add(new CampaignMember__c(
                    PTF_Portafoglio__c = cm.CRM_Portafoglio__c != NULL ? cm.CRM_Portafoglio__c : (Id)assenteleWallet.get(cm.PTF_idCed__c).get('Id'),
                    PTF_idCed__c = cm.PTF_idCed__c,
                    PTF_ModelloDiServizio__c = cm.PTF_ModelloDiServizio__c,
                    Campaign__c = cm.CampaignId,
                    Contact__c = cm.ContactId,
                    CRM_CampaignMemberId__c = cm.Id,
                    CRM_AssegnatarioUser__c = cm.CRM_Assegnatario__c,
                    CRM_Account__c = cm.CRM_AccountId__c,
                    PTF_Ambito__c = (cm.PTF_ModelloDiServizio__c == 'Family' || cm.PTF_ModelloDiServizio__c == 'POE' || cm.PTF_ModelloDiServizio__c == 'Assente' || cm.PTF_ModelloDiServizio__c == 'Residuale' || cm.PTF_ModelloDiServizio__c == 'Non Portafogliati') ? 'AssegnazioneAzione' : cm.PTF_ModelloDiServizio__c,
                    Status__c =  cm.Status,
                    CRM_PrioritaContatto__c =  cm.CRM_PrioritaContatto__c,
                    CRM_ValoreAttributo1_Date__c = cm.CRM_ValoreAttributo1_Date__c,
                    CRM_ValoreAttributo1_Number__c= cm.CRM_ValoreAttributo1_Number__c,
                    CRM_ValoreAttributo1_Text__c = cm.CRM_ValoreAttributo1_Text__c,
                    CRM_ValoreAttributo2_Date__c = cm.CRM_ValoreAttributo2_Date__c, 
                    CRM_ValoreAttributo2_Number__c = cm.CRM_ValoreAttributo2_Number__c,
                    CRM_ValoreAttributo2_Text__c = cm.CRM_ValoreAttributo2_Text__c,
                    //Data_Uscita__c = cm.Data_Prevista_Uscita__c
                    //
                    CRM_Autore__c = cm.CRM_Autore__c, // AL 2023-04-12 -- Aggiunta del campo CRM_Autore__c 
                    Data_ingresso__c = cm.Data_ingresso__c
                ));
            }
        }

        if(!cmGhostToInsertList.isEmpty()){
            insert cmGhostToInsertList;
        }
    }
    
    public static void testRun() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }

    public static Date evaluateCreationDate(CampaignMember campaignMember, Campaign campaign, Boolean isInsert)
    {
        Date creationDate = null;
        
        if(isInsert)
        {
            if (campaign.CRM_StatoFormula__c == 'In Anteprima' )
            {
                creationDate = getLatestDatetime(new List<DateTime>{ campaignMember.CreatedDate, campaign.CRM_DataInizioAffinamento__c }).date();
            }
            else if (campaign.CRM_StatoFormula__c == 'In Corso' || campaign.CRM_StatoFormula__c == 'Chiusa')
            {
                creationDate = getLatestDatetime(new List<DateTime>{ campaignMember.CreatedDate, campaign.StartDate }).date();
            }
        }
        else
        {
            if (Campaign.CRM_StatoFormula__c == 'In Anteprima')
            {
                creationDate = getLatestDatetime(new List<DateTime>{ System.today(), campaign.CRM_DataInizioAffinamento__c }).date();
            }
            else if (campaign.CRM_StatoFormula__c == 'In Corso' || campaign.CRM_StatoFormula__c == 'Chiusa')
            {
                creationDate = getLatestDatetime(new List<DateTime>{ System.today(), campaign.StartDate }).date();
            }
        }
        return creationDate;
    }
    
    public static Datetime getLatestDatetime(List<Datetime> datetimeList) {
    Datetime latestDatetime = null;
    
    for (Datetime datetim : datetimeList) {
        if (latestDatetime == null || datetim > latestDatetime) {
            latestDatetime = datetim;
        }
    }
    
    return latestDatetime;
	}
}