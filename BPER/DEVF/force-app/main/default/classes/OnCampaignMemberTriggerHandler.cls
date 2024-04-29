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
            
            for(CampaignMember cm : newRecords){
                system.debug('cm = ' + cm);
                system.debug('cm.campaign = ' + cm.Campaign);
                
                if ( !Test.isRunningTest() && !cm.Campaign.softphone_it__Genesys_Cloud_Sync__c ){
                    continue;
                }
                if(cm.CRM_NotCallable__c && !oldMap.get(cm.Id).CRM_NotCallable__c) {
                   // cmToSend.add(cm.softphone_it__Gc_Contact_List_Id__c+'_'+cm.softphone_it__Gc_Contact_Id_externalId__c);
                   setContactListRecordNotCallable(cm.softphone_it__Gc_Contact_List_Id__c,cm.softphone_it__Gc_Contact_Id_externalId__c);
                }else if ( cm.isActive__c && !oldMap.get(cm.Id).isActive__c ){
                    //isActive from false to true
                    //add record to calling list
                    String body = buildCampaignMemberPayload(cm);
                    addCampaignMemberToContactList(cm.softphone_it__Gc_Contact_List_Id__c, body);

                }else if (!cm.isActive__c && oldMap.get(cm.Id).isActive__c ){
                     //isActive from true to false
                     //remove from callinglist
                     deleteRecordFromContactList(cm.softphone_it__Gc_Contact_List_Id__c, cm.softphone_it__Gc_Contact_Id_externalId__c);
                }
            }
           
        } else {
            System.debug('SV trackHistory trafficLightAssegnazioneAzione: ' + trafficLightAssegnazioneAzione);
        } 
   }


    @future(callout=true)
   public static void setContactListRecordNotCallable(String contactListId, String contactId){
         Map<String,Object> params= new Map<String,Object>();
         params.put('callable',false);
        String body = JSON.serialize(params);
        String url = 'outbound/contactlists/' + contactListId + '/contacts/' + contactId;
        if(!Test.isRunningTest()){
            HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC(body, url , 'PUT'); 
            String correlation = response.getHeader('ININ-Correlation-Id');
            insertDebugLog(contactId, 'INFO', 'er_trigger_cm', 'PUT', url, body, response.getBody(),correlation);
            //extResult.addLog(ConnectorEntityController.createDebugLog(tId,caseId,'INFO', 'er_scrub_outbound', 'PUT', url, body,'STATUS CODE=' + ( response != null ? response.getStatusCode() : 0 )+ ';response=' +response.getBody(),''));
        }
   }

   @future(callout=true)
   public static void deleteRecordFromContactList(String contactListId, String contactId){
       
        String url = 'outbound/contactlists/' + contactListId + '/contacts/' + contactId;
        if(!Test.isRunningTest()){
            HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC('', url , 'DELETE'); 
            String correlation = response.getHeader('ININ-Correlation-Id');
            insertDebugLog(contactId, 'INFO', 'er_trigger_cm', 'DELETE', url, '', response.getBody(),correlation);
            //extResult.addLog(ConnectorEntityController.createDebugLog(tId,caseId,'INFO', 'er_scrub_outbound', 'PUT', url, body,'STATUS CODE=' + ( response != null ? response.getStatusCode() : 0 )+ ';response=' +response.getBody(),''));
        }
   }

   public static String buildCampaignMemberPayload(CampaignMember cm ){
        Map<String, Object> contact = new Map<String, Object>();
        Map<String, String> data = new Map<String, String>();
        data.put('firstName', cm.FirstName);
        data.put('lastName', cm.LastName);
        data.put('phone', cm.Phone);
        data.put('mobile', cm.MobilePhone);
        data.put('status', cm.Status);
        data.put('id',cm.softphone_it__Gc_Contact_Id_externalId__c);
        contact.put('contactListId', cm.Campaign.softphone_it__Gc_Contact_List_Id__c);
        contact.put('data', data);
        contact.put('callable', true);
        

        if(cm.Campaign.softphone_it__Gc_Custom_Fields__c != null){
            List<String> CustomFieldsArray = cm.Campaign.softphone_it__Gc_Custom_Fields__c.split(',');
            for(String CField : CustomFieldsArray){
                system.debug('CField: ' + CField);
                data.put(CField.trim(), String.valueOf(cm.get(CField)));
                system.debug('data.get: ' + data.get(CField));
            }
        }

        return JSON.serialize(contact);
   }
   @future(callout=true)
   public static void addCampaignMemberToContactList(String contactListId, String body){
       
        String url = 'outbound/contactlists/'+contactListId+'/contacts';
        if(!Test.isRunningTest()){
            HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC(body,  url , 'POST');
            String correlation = response.getHeader('ININ-Correlation-Id');
            insertDebugLog(contactListId, 'INFO', 'er_trigger_cm', 'POST', url, body, response.getBody(),correlation);
            //extResult.addLog(ConnectorEntityController.createDebugLog(tId,caseId,'INFO', 'er_scrub_outbound', 'PUT', url, body,'STATUS CODE=' + ( response != null ? response.getStatusCode() : 0 )+ ';response=' +response.getBody(),''));
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

	    System.debug('updateQueueCallout, cmInfo :' + cmInfo);
        Datetime dataRicontatto;
                    
        if(cmInfo.CRM_DataOraRicontatto__c  != null && cmInfo.CRM_DataOraRicontatto__c > Datetime.now()) {
            dataRicontatto = cmInfo.CRM_DataOraRicontatto__c;
        } else if (cmInfo.CRM_DataOraRicontatto__c  == null && cmInfo.CRM_EsitoCampagna__r.CRM_Richiamata_Genesys__c && cmInfo.campaign.CRM_Intervallo_richiamata__c == null) {
            dataRicontatto = Datetime.now().addDays(1);
        } else if ((cmInfo.CRM_DataOraRicontatto__c  == null || cmInfo.CRM_DataOraRicontatto__c < Datetime.now()) && cmInfo.CRM_EsitoCampagna__r.CRM_Richiamata_Genesys__c && cmInfo.Campaign.CRM_Intervallo_richiamata__c != null) {
            dataRicontatto = Datetime.now().addMinutes(Integer.valueOf(cmInfo.Campaign.CRM_Intervallo_richiamata__c));
        }
        List<softphone_it__Softphone_Gc_Sync_Log__c> logs = new List<softphone_it__Softphone_Gc_Sync_Log__c>();
        if(dataRicontatto  != null){          
            //controllo checkScheduleCall == 0
            try{
                List<softphone_it__Softphone_Gc_Sync_Log__c> logsPostScheduleCall =  calloutGetScheduledCallGenesys(cmInfo);
                logs.addAll(logsPostScheduleCall);
                if(cmInfo.Status == 'Follow-up'){
                    softphone_it__Softphone_Gc_Sync_Log__c logSchedulePreferred =  calloutScheduleCallWithPreferredAgent(dataRicontatto, cmInfo);
                    logs.add(logSchedulePreferred);
                }else{
                    softphone_it__Softphone_Gc_Sync_Log__c logScheduleCall = calloutScheduleCallGenesys(dataRicontatto, cmInfo);
                    logs.add(logScheduleCall);
                }
            }catch(Exception e){
                logs.add(createDebugLog(campaignMemberId, 'ERROR', 'er_trigger_cm', '', '', '', e.getMessage(),''));
            }
                
        }

        if ( logs.size() > 0 ) {
            try{
                insert logs;
            }catch(Exception e){
                System.debug('Error insert logs: ' + e.getMessage());
            }
            
        }

    }

    public static softphone_it__Softphone_Gc_Sync_Log__c calloutScheduleCallGenesys(Datetime dataRicontatto, CampaignMember cmInfo)
    {
	
        String dataString = dataRicontatto.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        Map<String,Object> reqBody = new Map<String,Object>();
        Map<String,Object> dataReq = new Map<String,Object>();
        System.debug('calloutScheduleCallGenesys, cmInfo : ' + cmInfo);
        System.debug('calloutScheduleCallGenesys, cmInfo.Campaign : ' + cmInfo.Campaign.softphone_it__Gc_Custom_Fields__c);
        List<String> fieldList = cmInfo.Campaign.softphone_it__Gc_Custom_Fields__c != null ?  cmInfo.Campaign.softphone_it__Gc_Custom_Fields__c.split(',') : new List<String>();

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
        System.debug('updateQueueCallout - reqBody: '+ reqBody);
        String body = JSON.serialize(reqBody);
        HttpResponse response = new HttpResponse();
        String correlation = '';

        if(!Test.isRunningTest()){
            response = softphone_it.ConnectorCalloutGc.CalloutGC(body,  'conversations/callbacks', 'POST'); 
            correlation = response.getHeader('ININ-Correlation-Id');
       }
   
       return createDebugLog(cmInfo.Id, 'INFO', 'er_trigger_cm', 'POST', 'conversations/callbacks', body, response.getBody(),correlation);
            
    }

    //DK FIX callout GENESYS

    public static softphone_it__Softphone_Gc_Sync_Log__c calloutScheduleCallWithPreferredAgent(Datetime dataRicontatto, CampaignMember cmInfo)
    {

        String dataString = dataRicontatto.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

        Map<String,Object> reqBody = new Map<String,Object>();

        Map<String,Object> dataReq = new Map<String,Object>();
        List<String> fieldList = cmInfo.Campaign.softphone_it__Gc_Custom_Fields__c != null ?  cmInfo.Campaign.softphone_it__Gc_Custom_Fields__c.split(',') : new List<String>();

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
        System.debug('updateQueueCallout - reqBody: '+ reqBody);
        String body = JSON.serialize(reqBody);
        HttpResponse response = new HttpResponse();
        String correlation = '';
        if(!Test.isRunningTest()){
             response = softphone_it.ConnectorCalloutGc.CalloutGC(body,  'conversations/callbacks', 'POST'); 
             correlation = response.getHeader('ININ-Correlation-Id');
        }
        return createDebugLog(cmInfo.Id, 'INFO', 'er_trigger_cm', 'POST', 'conversations/callbacks', body, response.getBody(),correlation);
    }


    public static List<softphone_it__Softphone_Gc_Sync_Log__c> calloutGetScheduledCallGenesys(CampaignMember cmInfo){
        Map<String,Object> reqBody = new Map<String,Object>();     
       
        List<softphone_it__Softphone_Gc_Sync_Log__c> logs = new List<softphone_it__Softphone_Gc_Sync_Log__c>();
        HttpResponse response = new HttpResponse();    
        String correlation = '';
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
        String body = JSON.serialize(reqBody);
        if(!Test.isRunningTest()){
            response = softphone_it.ConnectorCalloutGc.CalloutGC(body,  'analytics/conversations/details/query', 'POST'); 
            correlation = response.getHeader('ININ-Correlation-Id');
            logs.add(createDebugLog(cmInfo.Id, 'INFO', 'er_trigger_cm', 'GET', 'analytics/conversations/details/query', body, response.getBody(),correlation));
            Map<string, string> mapContactCallback = getCallbackNumber(cmInfo,response.getBody());   
            if(mapContactCallback.keySet().size() > 0){
                List<softphone_it__Softphone_Gc_Sync_Log__c> deleted = calloutDeleteScheduledCallGenesys(mapContactCallback);
                logs.addAll(deleted);
            } 
            
        }
        return logs;
    
    }

    public static Map<String,String> getCallbackNumber(CampaignMember cmInfo,String body){
        Map<string, string> mapContactCallback = new Map<string, string>();  
        Map<String,Object> deserializedResponse = (Map<String,Object>) JSON.deserializeUntyped(body);

        system.debug('deserialized Body '+deserializedResponse);

        Integer hits = (Integer) deserializedResponse.get('totalHits');

        if(hits > 0){
            for(Object conversations :  (List<Object>) deserializedResponse.get('conversations')){
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

                for(object numb : callBackNumbList){
                System.debug('numb: '+numb );
                System.debug('cm Phone: '+cmInfo.Contact);
                String numb2 = (String)numb;
                String finalNumb = numb2.replace('+39','');
                System.debug('numb2: '+finalNumb );
                if(finalNumb == cmInfo.Contact.Phone ){
                        mapContactCallback.put(String.valueOf(numb), conversationId);
                    }
                    
                }
            }
            
        }
        return mapContactCallback;
    }

    public static List<softphone_it__Softphone_Gc_Sync_Log__c> calloutDeleteScheduledCallGenesys(map<string, string> mapContactCallback)
    {
        List<softphone_it__Softphone_Gc_Sync_Log__c> logs = new List<softphone_it__Softphone_Gc_Sync_Log__c>();
        Set<String> conversationIdSet = new set<string>(mapContactCallback.values());
        for(string idChiamata : conversationIdSet) {   
            if(!Test.isRunningTest()){
                HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC('',  'conversations/'+ idChiamata +'/disconnect', 'POST'); 
            String correlation = response.getHeader('ININ-Correlation-Id');
            logs.add(createDebugLog(idChiamata, 'INFO', 'er_trigger_cm', 'POST', 'conversations/'+ idChiamata +'/disconnect', '', response.getBody(),correlation));     
            }
        }
        return logs;
        
    }
   
    public static void setFields(List<CampaignMember> records) {
        if(!trafficLightAssegnazioneAzione){
            System.debug('SV setFields records: ' + records);
            //PTF_Area__c
            //PTF_DirezioneRegionale__c
            //PTF_Filiale__c
    
            Set<Id> setContactId = new Set<Id>();
    
            for(CampaignMember rec: records){
                setContactId.add(rec.ContactId);
            }
    
            Map<String, SObject> mapContact = SV_Utilities.keyBy([
                SELECT Id, Account.PTF_Filiale__c, Account.CRM_Filiale__c, Account.PTF_Portafoglio__c, Account.CRM_FilialiRapportoToShow__c, Account.PTF_Filiale__r.PTF_Area__c, Account.CRM_Filiale__r.PTF_Area__c, Account.PTF_Filiale__r.PTF_DirezioneRegionale__c, Account.CRM_Filiale__r.PTF_DirezioneRegionale__c, Account.PTF_Filiale__r.PTF_IdCed__c, Account.CRM_Filiale__r.PTF_IdCed__c, Account.ModelloDiServizio__c, Account.PTF_ModelloDiServizio__c // Michele Barile - 26/03/2024 - Aggiunto Account.PTF_ModelloDiServizio__c
                FROM Contact 
                WHERE Id IN : setContactId ], 'Id', false);
           
            // Michele Barile - 25/03/2024 - CR 76711 - START
            
            System.debug('OnCampaignMemberTriggerHandler -> setFields -> mapContact ' + JSON.serialize(mapContact));
            System.debug('OnCampaignMemberTriggerHandler -> setFields -> (List<Contact>)mapContact.values() ' + (List<Contact>)mapContact.values());
            // Set contenente le filiali dei campaignMember di interesse
            Set<Id> filialiSet = new Set<Id>();
            for(Contact con : (List<Contact>)mapContact.values()){
                if (con.Account.PTF_ModelloDiServizio__c == 'POE') {
                    filialiSet.add(con.Account.PTF_Filiale__c);
                }   
            }
            System.debug('OnCampaignMemberTriggerHandler -> setFields -> filialiSet ' + filialiSet);

            // Set di codici corrispondenti ai referenti POE
            Set<String> codeSet = new Set<String>{'21','22','25','37','52','54','55','56','57','100','101','102'};
            System.debug('OnCampaignMemberTriggerHandler -> setFields -> codeSet ' + codeSet);

            // Cerco i contatti che soddisfano i criteri
            List<Contact> contactList = [SELECT Id, PTF_RegistrationNumber__c, Name, PTF_IdCED__c, AccountId, PTF_User__c, PTF_ProfiloLDAP__c, PTF_IsVice__c, PTF_Ruolo__c, PTF_TipologiaRuolo__r.Name, PTF_User__r.CRM_MMDSVisibili__c, PTF_TipologiaRuolo__r.PTF_Code__c, Account.PTF_Filiale__c, Account.CRM_Filiale__c
            FROM Contact
            WHERE AccountId IN :filialiSet
            AND PTF_TipologiaRuolo__r.PTF_Code__c IN :codeSet
            AND PTF_Ruolo__c != NULL
            AND PTF_User__c != NULL 
            AND PTF_User__r.isActive = true];
            System.debug('OnCampaignMemberTriggerHandler -> setFields -> contactList ' + contactList);

            //mappa con chiave l'id della filiale e valore una lista di contatti appartenenti alla stessa filiale del campaignMember
            Map<Id, List<Contact>> filialeToContactsMap = new Map<Id, List<Contact>>();
            for (contact con : contactList) {
                if (!filialeToContactsMap.containsKey(con.AccountId)) {
                    filialeToContactsMap.put(con.AccountId, new List<Contact>());
                }
                filialeToContactsMap.get(con.AccountId).add(con);
            }
            System.debug('OnCampaignMemberTriggerHandler -> setFields -> filialeToContactsMap ' + filialeToContactsMap);

            //Michele Barile - 25/03/2024 - CR 76711 - END

            for(CampaignMember rec: records){
                Contact contact = (Contact)mapContact.get(rec.ContactId);
                rec.PTF_Area__c = contact.Account.PTF_Filiale__c != NULL ? contact.Account.PTF_Filiale__r.PTF_Area__c : contact.Account.CRM_Filiale__r.PTF_Area__c;
                rec.PTF_DirezioneRegionale__c  = contact.Account.PTF_Filiale__c != NULL ? contact.Account.PTF_Filiale__r.PTF_DirezioneRegionale__c : contact.Account.CRM_Filiale__r.PTF_DirezioneRegionale__c;
                rec.PTF_Filiale__c = contact.Account.PTF_Filiale__c != NULL ? contact.Account.PTF_Filiale__c : contact.Account.CRM_Filiale__c;
                rec.PTF_IdCed__c = contact.Account.PTF_Filiale__c != NULL ? contact.Account.PTF_Filiale__r.PTF_IdCed__c : contact.Account.CRM_Filiale__r.PTF_IdCed__c;
                rec.PTF_ModelloDiServizio__c = (contact.Account.ModelloDiServizio__c != NULL) ? contact.Account.ModelloDiServizio__c : 'Non Portafogliati';
                rec.CRM_Portafoglio__c = (contact.Account.PTF_Portafoglio__c != NULL) ? contact.Account.PTF_Portafoglio__c : NULL;
            
                //Michele Barile - 26/03/2024 - CR 76711 - START

                // Se trovo un solo referente, valorizzo il campo CRM_Assegnatario__c con l'Id dello user (Contact.PTF_User__c).
                List<Contact> filialeContacts = filialeToContactsMap.get(rec.PTF_Filiale__c);
                if (filialeContacts != null && filialeContacts.size() == 1) {
                    rec.CRM_Assegnatario__c = filialeContacts[0].PTF_User__c;
                }
                //Michele Barile - 26/03/2024 - CR 76711 - END
            
            }
    
        } else {
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
        
	System.debug('setGhost , residualeWallet = ' + residualeWallet);
        if(!trafficLightGhostTrigger){                                                  
            if(triggerEvent == 'Insert'){
                for(CampaignMember cm : newTriggerCampMembMap.values()){
                    System.debug('SV cm.PTF_idCed__c: ' + cm.PTF_idCed__c);
                    if(cm.PTF_idCed__c != NULL && residualeWallet.containsKey(cm.PTF_idCed__c)){
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
                            CRM_ValoreAttributo2_Text__c = cm.CRM_ValoreAttributo2_Text__c
                            //Data_Uscita__c = cm.Data_Prevista_Uscita__c
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
                ));
            }
        }

        if(!ghostToInsert.isEmpty()){

            insert ghostToInsert;
        }
    }
/*
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

*/
    public static void activateGhost(List<CampaignMember> newRecordList, Map<Id, CampaignMember> oldRecordMap){
        List<CampaignMember__c> cmGhostToInsertList = new List<CampaignMember__c>();

        Map<String, SObject> assenteleWallet =SV_Utilities.keyBy([ SELECT id, Name, PTF_Filiale__r.PTF_IdCED__c 
                                                                    FROM Wallet__c 
                                                                    WHERE PTF_ModelloDiServizio__c = 'Assente' AND 
                                                                        PTF_DeletionDate__c = NULL ], 'PTF_Filiale__r.PTF_IdCED__c', false);
        for(CampaignMember cm : newRecordList){
            if(cm.isActive__c && !oldRecordMap.get(cm.Id).isActive__c &&
            cm.PTF_idCed__c != NULL && assenteleWallet.containsKey(cm.PTF_idCed__c)){
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
                    CRM_ValoreAttributo2_Text__c = cm.CRM_ValoreAttributo2_Text__c
                    //Data_Uscita__c = cm.Data_Prevista_Uscita__c
                    //
                ));
            }
        }

        if(!cmGhostToInsertList.isEmpty()){
            insert cmGhostToInsertList;
        }
    }


    public static void insertDebugLog(String id,String loglevel,String action, String method, String url,  String body,String response,String header){
        softphone_it__Softphone_Gc_Sync_Log__c softphoneLog = createDebugLog(id,loglevel,action,method,url,body,response,header);
        insert softphoneLog;
    }

    public static softphone_it__Softphone_Gc_Sync_Log__c createDebugLog(String id,String loglevel,String action, String method, String objId,  String body,String response,String header){
        softphone_it__Softphone_Gc_Sync_Log__c softphoneLog = new softphone_it__Softphone_Gc_Sync_Log__c();
        datetime dateTimeNow = datetime.now();
        softphoneLog.softphone_it__Log_Level__c = loglevel;
        softphoneLog.softphone_it__Action__c = action;
        softphoneLog.softphone_it__Date__c = dateTimeNow;
        softphoneLog.softphone_it__ws_method__c = method;
        softphoneLog.softphone_it__ws_url__c = objId;
        softphoneLog.softphone_it__ws_body__c = body;
        softphoneLog.softphone_it__ws_response__c = response;
        softphoneLog.softphone_it__ws_response_header__c = header;
        return softphoneLog;
    }
}