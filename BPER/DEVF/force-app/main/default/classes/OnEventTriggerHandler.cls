/**
 * Name         :   OnEventTriggerHandler
 * Author       :   Ezio Dal Bo @TEN
 * Create date  :   2020-09-25
 * Description  :   Manange event logic about trigger on Event
**/
public class OnEventTriggerHandler {
    
    public static Boolean trafficLightTrackingTrigger = false;
    public static Boolean skipEventTrigger = false;
    
    /**
     * Name         :   afterInsert
     * Create date  :   2020-09-25
     * Author       :   Ezio Dal Bo @TEN
     * Description  :   manage after insert trigger event
     */
    public static void afterInsert(List<Event> newRecords) {
        checkEventCase(newRecords, null,'afterInsert');
    }

    /**
     * Name         :   afterUpdate
     * Create date  :   2020-09-25
     * Author       :   Ezio Dal Bo @TEN
     * Description  :   manage after update trigger event
     */
  public static void afterUpdate(List<Event> newRecords,Map<Id,Event> oldRecords) {
        List<Event> newEventWithWathIdChanged = new List<Event>();
        Map<Id,Event> oldEventWithWathIdChanged = new Map<Id,Event>();

        for (Event t : newRecords) {
            System.debug('GR TEST t.WhatId: '+ t.WhatId);
            Event oldEvent = oldRecords.get(t.Id);
            System.debug('GR TEST oldEvent.WhatId: '+ oldEvent.WhatId);
            if (t.WhatId!=oldEvent.WhatId) {
                newEventWithWathIdChanged.add(t);
                oldEventWithWathIdChanged.put(t.Id,oldEvent);
            }
        }

        if (newEventWithWathIdChanged.size()>0) checkEventCase(newEventWithWathIdChanged,oldEventWithWathIdChanged,'afterUpdate');
    }

    /**
     * Name         :   afterDelete
     * Create date  :   2020-09-25
     * Author       :   Ezio Dal Bo @TEN
     * Description  :   manage after delete trigger event
     */
    public static void afterDelete(List<Event> oldRecords) {
        checkEventCase(oldRecords,null,'afterDelete');
    }

    private static void checkEventCase(List<Event> events, Map<Id,Event> oldEvents, String action) {
        // obtain case prefix
        Schema.sObjectType sObjType = Schema.getGlobalDescribe().get('Case');
        String casePrefix = sObjType.getDescribe().getKeyPrefix();
        System.debug('casePrefix '+casePrefix);
        OnCaseTriggerHandler.skipCustomValidation=true;
        if ('afterInsert'.equals(action)) {
            Set<Id> caseIds = new Set<Id>();
            for (Event t : events) {
                //System.debug('casePrefixEvent '+String.valueOf(t.whatId).startsWith(casePrefix));
                if (t.whatId!=null && String.valueOf(t.whatId).startsWith(casePrefix))caseIds.add(t.whatId);
                
            }
            if (!caseIds.isEmpty()) {
                List<Case> casesToUpdate = queryCases(caseIds);
                if (casesToUpdate.size()>0) {
                    for (Case c : casesToUpdate) {
                        c.CRM_IsPresentEvent__c = true;
                    }
                }
                update casesToUpdate;
            }
        }
        else if ('afterDelete'.equals(action)) {
            Set<Id> caseIds = new Set<Id>();
            Set<Id> caseIdToUdpate = new Set<Id>();
            for (Event t : events) {
                if (t.whatId!=null && String.valueOf(t.whatId).startsWith(casePrefix)) {
                    caseIds.add(t.whatId);
                }
            }
            if (!caseIds.isEmpty()) {
                Map<Id,Set<Id>> mCaseEvent = queryEventByCaseId(caseIds);
                for (Event t : events) {
                    if (!mCaseEvent.containsKey(t.WhatId)) caseIdToUdpate.add(t.WhatId);
                    
                }
                if (!caseIdToUdpate.isEmpty()) {
                    List<Case> caseToUpdate = queryCases(caseIdToUdpate);
                    if (caseToUpdate!=null && caseToUpdate.size()>0) {
                        for (Case c : caseToUpdate) {
                            c.CRM_IsPresentEvent__c = false;
                        }
                        update caseToUpdate;
                    }
                }
            }
        }
        else if ('afterUpdate'.equals(action)) {
            Set<Id> idCasesToSetTrue = new Set<Id>();
            Set<Id> idCasesToCheckToFalse = new Set<Id>();
            List<Case> CaseToUpdate = new List<Case>();
            for (Event t : events) {
                Event oEvent = oldEvents.get(t.Id);
                //case 1 
                if (t.WhatId==null && oEvent.WhatId!=null && String.valueOf(oEvent.whatId).startsWith(casePrefix))idCasesToCheckToFalse.add(oEvent.WhatId);
                // case 2
                else if (oEvent.WhatId==null && t.WhatId!=null && String.valueOf(t.WhatId).startsWith(casePrefix)) idCasesToSetTrue.add(t.WhatId);
 // case 3
                else if (t.WhatId!=null && oEvent.WhatId!=null) {
                    // case 3a
                    if (String.valueOf(t.WhatId).startsWith(casePrefix) && String.valueOf(oEvent.WhatId).startsWith(casePrefix)) {
                        idCasesToSetTrue.add(t.WhatId);
                        idCasesToCheckToFalse.add(oEvent.WhatId);
                    } // case 3b
                    else if (!String.valueOf(t.WhatId).startsWith(casePrefix) && String.valueOf(oEvent.WhatId).startsWith(casePrefix)) idCasesToCheckToFalse.add(oEvent.WhatId); // case 3c
                    else if (String.valueOf(t.WhatId).startsWith(casePrefix) && !String.valueOf(oEvent.WhatId).startsWith(casePrefix)) idCasesToSetTrue.add(t.WhatId);

                }
            }
            if (idCasesToCheckToFalse.size()>0) {
                Map<Id,Set<Id>> mCaseEvent = queryEventByCaseId(idCasesToCheckToFalse);
                if (!mCaseEvent.isEmpty()) {
                    for ( Id idc : idCasesToCheckToFalse) {
                        if (mCaseEvent.containsKey(idc)) idCasesToSetTrue.add(idc);
 
                    }
                }
                idCasesToCheckToFalse.removeAll(idCasesToSetTrue);
            }

            if (idCasesToSetTrue.size()>0) {
                List<Case> casesTrue = queryCases(idCasesToSetTrue);
                for (Case c : casesTrue) {
                    c.CRM_IsPresentEvent__c = true;
                }
                CaseToUpdate.addAll(casesTrue);
            }

            if (idCasesToCheckToFalse.size()>0) {
                List<Case> casesFalse = queryCases(idCasesToCheckToFalse);
                for (Case c : casesFalse) {
                    c.CRM_IsPresentEvent__c = false;
                }
                CaseToUpdate.addAll(casesFalse);
            }

            if (CaseToUpdate.size()>0) update CaseToUpdate;

        }
    }

    private static List<Case> queryCases(Set<Id> caseIds) {
        List<Case> cases = null;
        try {
            cases = [SELECT  Id,
                     CRM_IsPresentEvent__c 
                     FROM Case 
                     WHERE Id IN:caseIds];
        }
        catch(exception exc) {
            throw exc;
        }
        return (cases!=null && cases.size()>0 ? cases : new List<Case>());
    }

    private static Map<Id,Set<Id>> queryEventByCaseId(Set<Id> caseIds) {
        Map<Id,Set<Id>>  mCaseEvent = new Map<Id,Set<Id>>();
        try {
            List<Event> events = [
                SELECT  Id,
                        WhatId
                FROM Event
                WHERE WhatId IN:caseIds
            ];
            if (events!=null && events.size()>0) {
                for (Event t : events) {
                    Set<Id> ids = (mCaseEvent.containsKey(t.WhatId) ? mCaseEvent.get(t.WhatId) : new Set<Id>());
                    ids.add(t.Id);
                    mCaseEvent.put(t.WhatId,ids);
                }
            }
        }
        catch(exception exc) {
            throw exc;
        }
        return mCaseEvent;
    }

    public static void trackHistory(Map<Id, Event> oldTriggerEventMap, Map<Id, Event> newTriggerEventMap){
    
        //Get apiname of object (Event)
        String objApiName = String.valueOf(newTriggerEventMap.getSObjectType());
    
        //Get data information from metadata
        TrackingHistoryConfiguration__mdt[] metadataList = [SELECT ParentField__c, 
                                                            TrackingFieldList__c,
                                                            RecordTypeDevName__c, 
                                                            ObjectDevName__c
                                                            FROM TrackingHistoryConfiguration__mdt
                                                            WHERE ObjectDevName__c = :objApiName
                                                            LIMIT 1];
        
        if(metadataList.size() > 0 && !trafficLightTrackingTrigger){                                                    
            TrackingHistoryConfiguration__mdt metadataObj = metadataList.get(0);
        
            //For each record, for each field to track, create a tracking object
            String recordTypeIdString = Schema.SObjectType.TrackingHistory__c.getRecordTypeInfosByDeveloperName().get(metadataObj.RecordTypeDevName__c).getRecordTypeId();
            List<String> trackingFieldList = metadataObj.TrackingFieldList__c.split(';');
            List<TrackingHistory__c> trackingObjects = new List<TrackingHistory__c>();
            
            for(Event newTriggerEvent : newTriggerEventMap.values()){
                for(String trackingField : trackingFieldList){
                    String oldValue;
                    String newValue = (String) newTriggerEvent.get(trackingField);
                    
                    if(!(oldTriggerEventMap == null || oldTriggerEventMap.isEmpty())){
                        Event oldTriggerEvent = oldTriggerEventMap.get(newTriggerEvent.id);
                        oldValue = (String) oldTriggerEvent.get(trackingField);
                    }

                    if((!String.isBlank(newValue) && String.isBlank(oldValue)) || (!String.isBlank(newValue) && !String.isBlank(oldValue) && !(newValue.equals(oldValue)))){
                        TrackingHistory__c trackingObj = new TrackingHistory__c(
                                                        RecordTypeId = recordTypeIdString,
                                                        ParentObject__c = newTriggerEvent.Id,
                                                        Cliente__c = newTriggerEvent.AccountId,
                                                        Tracking_Field__c = trackingField,
                                                        Tracking_ObjRecordType__c = Schema.SObjectType.Event.getRecordTypeInfosById().get(newTriggerEvent.RecordTypeId).getDeveloperName(),
                                                        OldValue__c = oldValue,
                                                        NewValue__c = newValue);
                        //get dynamically the field API name which contains the record id from metadata
                        trackingObj.put(metadataObj.ParentField__c, newTriggerEvent.id);
                        
                        trackingObjects.add(trackingObj);
                    }

                }
            }
            
            insert trackingObjects;
        }
        
        
    }
    public static void updateWhoId(List<Event> events) {

        if(events.size()==1 && events[0].ownerId.getSObjectType().getDescribe().getName()!='User' && events[0].RecordTypeId==Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('AppuntamentoCC').getRecordTypeId()){
            Event newEvent=events[0];
            Account acc;
            List<Account> accList= new List<Account>();
            if(String.isNotBlank(newEvent.CC_ABI_NDG__c)){

                accList=[SELECT Id, PersonContactId, RecordType.DeveloperName 
                         FROM Account 
                         WHERE NDW_ExternalId__c=: newEvent.CC_ABI_NDG__c];
                
                if(accList.size()==1){
                    acc=accList[0];
                }
            }
            else if(newEvent.CC_Phone__c!=null){
                String QueryString =  'FIND \'' + newEvent.CC_Phone__c + '\' IN PHONE FIELDS RETURNING';
                QueryString += ' Account (Id, PersonContactId, RecordType.DeveloperName, Name, CRM_SmartWebMobilePhone__c, Phone, CRM_Phone1__c,CRM_Phone2__c, CRM_PhoneBpercard__c, CRM_Cellulare_aziendale_Bpercard__c WHERE Recordtype.DeveloperName != \'Cointestazione\')';
                List<List<SObject>> searchList = search.query(queryString);
                accList=(List<Account>) searchList[0];
                if(accList.size()==1)acc=accList[0];
                
            }
            if(acc!=null){
                if(acc.RecordType.DeveloperName=='PersonAccount'){
                    newEvent.WhoId=acc.PersonContactId;
                    newEvent.WhatId=acc.Id;
                }
                else if(acc.RecordType.DeveloperName=='IndustriesBusiness'){
                    newEvent.WhatId=acc.Id;
                    List<Contact> con=[SELECT Id 
                                       FROM Contact 
                                       WHERE AccountId=:acc.Id AND RecordType.DeveloperName ='IndustriesBusiness'];
                    if(con.size()>0) newEvent.WhoId=con[0].Id;
                    
                }
            }
        }  
    }

    public static void checkRicontatto(List<Event> events, Map<Id,Event> oldEventsMap){

        if(events.size()==1 && events[0].ownerId.getSObjectType().getDescribe().getName()!='User' && events[0].RecordTypeId==Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('AppuntamentoCC').getRecordTypeId()){

            Event newEvent=events[0];
            Event oldEvent=oldEventsMap.get(events[0].Id);
            System.debug('DK newEvent: ' + newEvent.CRM_EventStatus__c);
            System.debug('DK oldEvent: ' + oldEvent.CRM_EventStatus__c);
            if(newEvent.CRM_EventStatus__c!=oldEvent.CRM_EventStatus__c){
                if(newEvent.CRM_EventStatus__c=='Da Ricontattare' || newEvent.CRM_EventStatus__c=='Follow up'){
                    calloutScheduleCallGenesys(newEvent.Id, null);
                }
                else if(newEvent.CRM_EventStatus__c=='Non risponde 1' || newEvent.CRM_EventStatus__c=='Non risponde 2'){
                    Datetime startDateTime=checkSlot(newEvent);
                    calloutScheduleCallGenesys(newEvent.Id, startDateTime);
                }
            }

        }
        

    }

    public static Datetime checkSlot(Event ev) {

        Datetime now = System.now();
        Integer currentYear = now.year();
        Integer currentMonth = now.month();
        Integer currentDay = now.day();
        Integer currentHour = now.hour();
        Integer currentMinute = now.minute();
        Integer startYear;
        Integer startMonth;
        Integer startDay;
        Integer startHour;
        Integer startMinute;
    
        if(currentMinute < 30){
            startHour = currentHour;
            startMinute = 30;
            startYear = currentYear;
            startMonth = currentMonth;
            startDay = currentDay;
        }else if (currentHour != 23){
            startHour = currentHour + 1;
            startMinute = 0;
            startYear = currentYear;
            startMonth = currentMonth;
            startDay = currentDay;
        }else{
            startHour = 0;
            startMinute = 0;
            startYear = System.today().addDays(1).year();
            startMonth = System.today().addDays(1).month();
            startDay = System.today().addDays(1).day();
        }
    
        System.debug('@@@@@orario' + startYear + '-' + startMonth + '-' + startDay + 'T' + startHour + ':' + startMinute);
        Integer startSlot = getSlotNumber(startHour, startMinute);
        System.debug('@@@@@ MS startSlot ' + startSlot);
    
        //GR START
        String ownerId = ev.OwnerId;
    
        PA_Calendario__c calendar = [SELECT CC_NumMaxChiamate__c 
                                     FROM PA_Calendario__c 
                                     WHERE CC_IdCalendario__c = :ownerId 
                                     LIMIT 1];
        Integer maxChiamate = calendar != null ? Integer.valueOf(calendar.CC_NumMaxChiamate__c) : 0;
        System.debug('Gr maxChiamate: ' + maxChiamate);
        Integer limiteMaxEventi = maxChiamate != 0 ? maxChiamate : 3;
        System.debug('Gr limiteMaxEventi: ' + limiteMaxEventi);
        //GR END

        GenesysSetting__c gs = [SELECT Name, CC_Limite_Max__c, CC_Minuti_Ricontatto__c 
                                FROM GenesysSetting__c 
                                WHERE Name = 'Presa Appuntamento' 
                                LIMIT 1];
        Integer daysToCheck = !Test.isRunningTest() ? Integer.valueOf(gs.CC_Limite_Max__c) : 2;
        Integer minRic = !Test.isRunningTest() ? Integer.valueOf(gs.CC_Minuti_Ricontatto__c) : 30;
    
        List<BusinessHours> bh = [SELECT Id, Name, IsActive, IsDefault, SundayStartTime, SundayEndTime, MondayStartTime, 
                                  MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                                  ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime 
                                  FROM BusinessHours 
                                  WHERE Name = 'BPER_FOL' 
                                  LIMIT 1];
        System.debug('@@@@@ BusinessHours ' + bh);
        Date lastDate = Date.newInstance(startYear, startMonth, startDay);
        Date nextDate = lastDate;
    
        for (Integer i = 0; i < daysToCheck; i++) {
            Datetime dt = (DateTime) nextDate;
            lastDate = BusinessHours.nextStartDate(bh[0].Id, dt).date();
            nextDate = lastDate.addDays(1);
        }
    
        daysToCheck = Date.today().daysBetween(lastDate) + 1;
        System.debug('@@@@daysToCheck' + daysToCheck);
    
        String query;
        String evId = ev.Id;
        query = 'SELECT Id, StartDateTime, EndDateTime FROM Event WHERE Id != :evId AND OwnerId = :ownerId AND StartDateTime > :now AND StartDateTime <= NEXT_N_DAYS:' + daysToCheck + ' AND CRM_EventStatus__c != \'Appuntamento cancellato da cliente\' ORDER BY StartDateTime ASC';
        List<Event> events = Database.query(query);
    
        Integer dayChecking = 1;
        Integer checkingHour = startHour;
        Integer checkingMinute = startMinute;
        Integer checkingYear = startYear;
        Integer checkingMonth = startMonth;
        Integer checkingDay = startDay;
        Integer foundSlot;
        Integer foundHour;
        Integer foundMinute;
        Integer foundYear;
        Integer foundMonth;
        Integer foundDay;
    
        List<Integer> indexToRemove = new List<Integer>();
    
        while (dayChecking <= daysToCheck) {
            Date checkDate = Date.newInstance(checkingYear, checkingMonth, checkingDay);
            System.debug('@@@@checkDate' + checkDate);
            Integer startLoopFrom = dayChecking == 1 ? startSlot : 1;
            Integer evXSlot = 0;
    
            for (Integer i = startLoopFrom; i <= 48; i++) {
                evXSlot = 0;
                indexToRemove.sort();
                Integer sz = indexToRemove.size() - 1;
    
                for (Integer j = sz; j >= 0; j--) {
                    events.remove(indexToRemove[j]);
                }
    
                indexToRemove = new List<Integer>();
                System.debug('@@@@ MS all slots' + i);
    
                if (isDuringBusiness(i, checkingYear, checkingMonth, checkingDay, bh[0])) {
                    System.debug('@@@@slot' + i);
    
                    for (Integer j = 0; j < events.size(); j++) {
                        Event e = events[j];
                        Integer evSlot = getSlotNumber(e.StartDateTime.hour(), e.StartDateTime.minute());
                        Date evDate = Date.newInstance(e.StartDateTime.year(), e.StartDateTime.month(), e.StartDateTime.day());
                        System.debug('@@@@event ' + e.Id + ' @@@@slot ' + i + ' @@@@evSlot ' + evSlot + ' @@@@evDate ' + evDate + ' @@@@checkDate ' + checkDate);
    
                        if (evDate < checkDate || (evDate == checkDate && evSlot < i)) {
                            System.debug('@@@here');
                            indexToRemove.add(j);
                            System.debug('@@@@removing ' + events[j].Id);
                            continue;
                        } else if (BusinessHours.isWithin(bh[0].Id, e.StartDateTime) && evDate == checkDate && evSlot == i) {
                            evXSlot++;
                            //GR START
                            if(evXSlot == limiteMaxEventi) break;
                            //GR END
                            System.debug('@@@evXSlot: ' + evXSlot + '@@@slot: ' + i);
                            indexToRemove.add(j);
                            System.debug('@@@@removing ' + events[j].Id);
                            continue;
                        } else if (evDate > checkDate || (evDate == checkDate && evSlot > i))  break;
                        
                    }
                    if (evXSlot < limiteMaxEventi) {
                        System.debug('GR DENTRO evXSlot < limiteMaxEventi');
                        System.debug('@@@@slot' + i);
                        System.debug('@@@@foundSlot' + i);
                        foundSlot = i;
                        String hour_minute = getHour_Minute(i);
                        foundHour = Integer.valueOf(hour_minute.split('_')[0]);
                        foundMinute = Integer.valueOf(hour_minute.split('_')[1]);
                        foundYear = checkingYear;
                        foundMonth = checkingMonth;
                        foundDay = checkingDay;
                        break;
                    }
                }
            }
    
            if (foundSlot != null) { 
                System.debug('@@@@slot');
                break;
            }
    
            Date newDate = Date.newInstance(checkingYear, checkingMonth, checkingDay).addDays(1);
            checkingHour = 0;
            checkingMinute = 0;
            checkingYear = newDate.year();
            checkingMonth = newDate.month();
            checkingDay = newDate.day();
            dayChecking++;
        }
    
        if (foundSlot != null) {
            return Datetime.newInstance(foundYear, foundMonth, foundDay, foundHour, foundMinute, 0);
        } else {
            return BusinessHours.nextStartDate(bh[0].Id, Datetime.newInstance(startYear, startMonth, startDay, startHour, startMinute, 0).addMinutes(minRic));
        }
    }
    
    private static Integer getSlotNumber(Integer hour, Integer minute){

        return ((hour + 1)*2) - ((30-minute)/30);


    }

    private static String getHour_Minute(Integer slot){
        System.debug('@@@@ MS slot '+slot);
        Integer hour;
        Integer minute;
        if(Math.mod(slot, 2)==0){
            hour=((slot)/2)-1;
            minute=30;

        }
        else{
            hour=((slot+1)/2)-1;
            minute=0;
        }
        System.debug('@@@@ h_m '+hour+'_'+minute);
        return hour+'_'+minute;

    }

    private static Boolean isDuringBusiness(Integer slot, Integer year, Integer month, Integer day, BusinessHours bh){
        Integer hour;
        Integer minute;
        if(Math.mod(slot, 2)==0){
            hour=((slot)/2)-1;
            minute=30;

        }
        else{
            hour=((slot+1)/2)-1;
            minute=0;
        }
        Datetime dt= Datetime.newInstance(year, month, day, hour, minute,0);
        return BusinessHours.isWithin(bh.id, dt);

    }

    @future(callout=true)
    public static void calloutScheduleCallGenesys(Id eventId,Datetime stdt)
    {
        System.debug('DK eventId: ' + eventId);
        System.debug('DK stdt: ' + stdt);
        try{
            List<Event> events= [SELECT Id,OwnerId, StartDateTime, CC_Phone__c, CRM_EventStatus__c, TYPEOF What 
                                 WHEN Account 
                                 THEN Id, CRM_SmartWebMobilePhone__c 
                                 END FROM Event 
                                 WHERE Id=:eventId];
            if(events.size()>0){

                Event event=events[0];
                List<PA_Calendario__c> calList=[SELECT CC_IdCoda__c  
                                                FROM PA_Calendario__c 
                                                WHERE CC_IdCalendario__c =: event.OwnerId];
                System.debug('@@@@@'+ JSON.serialize(calList));

                if(calList.size()>0){

                    List<SV_Log__c> logsToInsert = new List<SV_Log__c>();
                    Map<String, Object> routingData = new Map<String, Object>();
                    String dataString;
                    PA_Calendario__c cal= calList[0];
                    if(event.CRM_EventStatus__c=='Da Ricontattare' || event.CRM_EventStatus__c=='Follow up'){
                        dataString = event.StartDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
                        // Capire con Giuseppe
                        if(event.StartDateTime > Datetime.now()){
                            routingData.put('priority', '1000000');
                            routingData.put('queueId',  cal.CC_IdCoda__c);
                            
                        }
                    }
                    else{
                        dataString=stdt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
                        routingData.put('priority', '1000000');
                        routingData.put('queueId',  cal.CC_IdCoda__c);
                    }
                    
                   
                    Map<String,Object> reqBody = new Map<String,Object>();
                    reqBody.put('routingData', routingData);
                    
                    Map<String,Object> dataReq = new Map<String,Object>();
                    dataReq.put('event_Id',eventId);
                    reqBody.put('data', dataReq);
                    reqBody.put('queueId', cal.CC_IdCoda__c);
                /*if(event.What instanceof Account){
                        Account acc = event.What;
                        if(acc.CRM_SmartWebMobilePhone__c!=null){
                            reqBody.put('callbackNumbers', new List<String>{'+39' + acc.CRM_SmartWebMobilePhone__c});
                            reqBody.put('callbackUserName', '+39' + acc.CRM_SmartWebMobilePhone__c);
                        }
                        
                    }
                    else{*/
                        //reqBody.put('callbackNumbers', new List<String>{'+39' + event.CC_Phone__c});
                        //reqBody.put('callbackUserName', '+39' + event.CC_Phone__c);
                        reqBody.put('callbackNumbers', new List<String>{event.CC_Phone__c});
                        reqBody.put('callbackUserName', event.CC_Phone__c);
                    //}
                    
                    reqBody.put('callbackScheduledTime', dataString);
                    
                    System.debug('scheduleCallGenesys - reqBody: '+ JSON.serialize(reqBody));
              
                    String body = JSON.serialize(reqBody);
                    HttpResponse response = softphone_it.ConnectorCalloutGc.CalloutGC(body, 'conversations/callbacks' , 'POST'); 
                    String correlation = response.getHeader('ININ-Correlation-Id');
                    OnCampaignMemberTriggerHandler.insertDebugLog(eventId, 'INFO', 'er_trigger_event', 'POST', 'conversations/callbacks', body, response.getBody(),correlation);
                    Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    System.debug('DK responseMap: ' + JSON.serialize(responseMap));
                    Map<String, Object> conversation = (Map<String, Object>)responseMap.get('conversation');
                    String conversationId = '';
                    if(conversation != null) conversationId = (String)conversation.get('id');
              
                    if(conversationId != '' && (event.CRM_EventStatus__c=='Non risponde 1' || event.CRM_EventStatus__c=='Non risponde 2')){
                        skipEventTrigger=true;
                        Event updateEv= new Event(Id=eventId, StartDateTime=stdt, EndDateTime=stdt.addMinutes(29), CC_IdConversationGenesys__c=conversationId);
                        update updateEv;
                    }
                    
                    else if(conversationId != '' && (event.CRM_EventStatus__c=='Da Ricontattare' || event.CRM_EventStatus__c=='Follow up')){
                        skipEventTrigger=true;
                        Event updateEv= new Event(Id=eventId, CC_IdConversationGenesys__c=conversationId);
                        update updateEv;
                    }
                    // MS end
                }
                

            }
            }catch(Exception e){
                System.debug('@@@@@error  genesysQueueCallout: '+e.getStackTraceString());
            }          
    }

    
}