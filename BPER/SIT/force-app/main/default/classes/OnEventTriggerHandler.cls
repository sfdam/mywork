/**
 * Name         :   OnEventTriggerHandler
 * Author       :   Ezio Dal Bo @TEN
 * Create date  :   2020-09-25
 * Description  :   Manange event logic about trigger on Event
**/
public class OnEventTriggerHandler {
    
    public static Boolean trafficLightTrackingTrigger = false;

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
            Event oldEvent = oldRecords.get(t.Id);
            if (t.WhatId!=oldEvent.WhatId) {
                newEventWithWathIdChanged.add(t);
                oldEventWithWathIdChanged.put(t.Id,oldEvent);
            }
        }

        if (newEventWithWathIdChanged.size()>0) {
            checkEventCase(newEventWithWathIdChanged,oldEventWithWathIdChanged,'afterUpdate');
        }
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
                if (t.whatId!=null && String.valueOf(t.whatId).startsWith(casePrefix)) {
                    caseIds.add(t.whatId);
                }
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
                    if (!mCaseEvent.containsKey(t.WhatId)) {
                        caseIdToUdpate.add(t.WhatId);
                    }
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
                if (t.WhatId==null && oEvent.WhatId!=null && String.valueOf(oEvent.whatId).startsWith(casePrefix)) {
                    idCasesToCheckToFalse.add(oEvent.WhatId);
                } // case 2
                else if (oEvent.WhatId==null && t.WhatId!=null && String.valueOf(t.WhatId).startsWith(casePrefix)) {
                    idCasesToSetTrue.add(t.WhatId);
                } // case 3
                else if (t.WhatId!=null && oEvent.WhatId!=null) {
                    // case 3a
                    if (String.valueOf(t.WhatId).startsWith(casePrefix) && String.valueOf(oEvent.WhatId).startsWith(casePrefix)) {
                        idCasesToSetTrue.add(t.WhatId);
                        idCasesToCheckToFalse.add(oEvent.WhatId);
                    } // case 3b
                    else if (!String.valueOf(t.WhatId).startsWith(casePrefix) && String.valueOf(oEvent.WhatId).startsWith(casePrefix)) {
                        idCasesToCheckToFalse.add(oEvent.WhatId);
                    } // case 3c
                    else if (String.valueOf(t.WhatId).startsWith(casePrefix) && !String.valueOf(oEvent.WhatId).startsWith(casePrefix)) {
                        idCasesToSetTrue.add(t.WhatId);
                    }
                }
            }
            if (idCasesToCheckToFalse.size()>0) {
                Map<Id,Set<Id>> mCaseEvent = queryEventByCaseId(idCasesToCheckToFalse);
                if (!mCaseEvent.isEmpty()) {
                    for ( Id idc : idCasesToCheckToFalse) {
                        if (mCaseEvent.containsKey(idc)) {
                            idCasesToSetTrue.add(idc);
                        }
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

            if (CaseToUpdate.size()>0) {
                update CaseToUpdate;
            }
        }
    }

    private static List<Case> queryCases(Set<Id> caseIds) {
        List<Case> cases = null;
        try {
            cases = [
                SELECT  Id,
                        CRM_IsPresentEvent__c
                FROM Case
                WHERE Id IN:caseIds
            ];
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
        TrackingHistoryConfiguration__mdt[] metadataList = [SELECT ParentField__c, TrackingFieldList__c,
                                                            RecordTypeDevName__c, ObjectDevName__c
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
    
}