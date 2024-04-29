/**
 * Name         :   OnTaskTriggerHandler
 * Author       :   Ezio Dal Bo @TEN
 * Create date  :   2020-09-25
 * Description  :   Manange event logic about trigger on Task
**/
public class OnTaskTriggerHandler {

    public static Boolean trafficLightTrackingTrigger = false;

    /**
     * Name         :   afterInsert
     * Create date  :   2020-09-25
     * Author       :   Ezio Dal Bo @TEN
     * Description  :   manage after insert trigger event
     */
    public static void afterInsert(List<Task> newRecords) {
        checkTaskCase(newRecords, null,'afterInsert');
    }

    /**
     * Name         :   afterUpdate
     * Create date  :   2020-09-25
     * Author       :   Ezio Dal Bo @TEN
     * Description  :   manage after update trigger event
     */
    public static void afterUpdate(List<Task> newRecords,Map<Id,Task> oldRecords) {
        List<Task> newTaskWithWathIdChanged = new List<Task>();
        Map<Id,Task> oldTaskWithWathIdChanged = new Map<Id,Task>();

        for (Task t : newRecords) {
            Task oldTask = oldRecords.get(t.Id);
            if (t.WhatId!=oldTask.WhatId) {
                newTaskWithWathIdChanged.add(t);
                oldTaskWithWathIdChanged.put(t.Id,oldTask);
            }
        }

        if (newTaskWithWathIdChanged.size()>0) {
            checkTaskCase(newTaskWithWathIdChanged,oldTaskWithWathIdChanged,'afterUpdate');
        }
    }

    /**
     * Name         :   afterDelete
     * Create date  :   2020-09-25
     * Author       :   Ezio Dal Bo @TEN
     * Description  :   manage after delete trigger event
     */
    public static void afterDelete(List<Task> oldRecords) {
        checkTaskCase(oldRecords,null,'afterDelete');
    }

    private static void checkTaskCase(List<Task> tasks, Map<Id,Task> oldTasks, String action) {
        // obtain case prefix
        Schema.sObjectType sObjType = Schema.getGlobalDescribe().get('Case');
        String casePrefix = sObjType.getDescribe().getKeyPrefix();
        OnCaseTriggerHandler.skipCustomValidation=true;
        if ('afterInsert'.equals(action)) {
            Set<Id> caseIds = new Set<Id>();
            for (Task t : tasks) {
                if (t.whatId!=null && String.valueOf(t.whatId).startsWith(casePrefix)) {
                    caseIds.add(t.whatId);
                }
            }
            if (!caseIds.isEmpty()) {
                List<Case> casesToUpdate = queryCases(caseIds);
                if (casesToUpdate.size()>0) {
                    for (Case c : casesToUpdate) {
                        c.CRM_IsPresentTask__c = true;
                    }
                }
                update casesToUpdate;
            }
        }
        else if ('afterDelete'.equals(action)) {
            Set<Id> caseIds = new Set<Id>();
            Set<Id> caseIdToUdpate = new Set<Id>();
            for (Task t : tasks) {
                if (t.whatId!=null && String.valueOf(t.whatId).startsWith(casePrefix)) {
                    caseIds.add(t.whatId);
                }
            }
            if (!caseIds.isEmpty()) {
                Map<Id,Set<Id>> mCaseTask = queryTaskByCaseId(caseIds);
                for (Task t : tasks) {
                    if (!mCaseTask.containsKey(t.WhatId)) {
                        caseIdToUdpate.add(t.WhatId);
                    }
                }
                if (!caseIdToUdpate.isEmpty()) {
                    List<Case> caseToUpdate = queryCases(caseIdToUdpate);
                    if (caseToUpdate!=null && caseToUpdate.size()>0) {
                        for (Case c : caseToUpdate) {
                            c.CRM_IsPresentTask__c = false;
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
            for (Task t : tasks) {
                Task oTask = oldTasks.get(t.Id);
                //case 1 
                if (t.WhatId==null && oTask.WhatId!=null && String.valueOf(oTask.whatId).startsWith(casePrefix)) {
                    idCasesToCheckToFalse.add(oTask.WhatId);
                } // case 2
                else if (oTask.WhatId==null && t.WhatId!=null && String.valueOf(t.WhatId).startsWith(casePrefix)) {
                    idCasesToSetTrue.add(t.WhatId);
                } // case 3
                else if (t.WhatId!=null && oTask.WhatId!=null) {
                    // case 3a
                    if (String.valueOf(t.WhatId).startsWith(casePrefix) && String.valueOf(oTask.WhatId).startsWith(casePrefix)) {
                        idCasesToSetTrue.add(t.WhatId);
                        idCasesToCheckToFalse.add(oTask.WhatId);
                    } // case 3b
                    else if (!String.valueOf(t.WhatId).startsWith(casePrefix) && String.valueOf(oTask.WhatId).startsWith(casePrefix)) {
                        idCasesToCheckToFalse.add(oTask.WhatId);
                    } // case 3c
                    else if (String.valueOf(t.WhatId).startsWith(casePrefix) && !String.valueOf(oTask.WhatId).startsWith(casePrefix)) {
                        idCasesToSetTrue.add(t.WhatId);
                    }
                }
            }
            if (idCasesToCheckToFalse.size()>0) {
                Map<Id,Set<Id>> mCaseTask = queryTaskByCaseId(idCasesToCheckToFalse);
                if (!mCaseTask.isEmpty()) {
                    for ( Id idc : idCasesToCheckToFalse) {
                        if (mCaseTask.containsKey(idc)) {
                            idCasesToSetTrue.add(idc);
                        }
                    }
                }
                idCasesToCheckToFalse.removeAll(idCasesToSetTrue);
            }

            if (idCasesToSetTrue.size()>0) {
                List<Case> casesTrue = queryCases(idCasesToSetTrue);
                for (Case c : casesTrue) {
                    c.CRM_IsPresentTask__c = true;
                }
                CaseToUpdate.addAll(casesTrue);
            }

            if (idCasesToCheckToFalse.size()>0) {
                List<Case> casesFalse = queryCases(idCasesToCheckToFalse);
                for (Case c : casesFalse) {
                    c.CRM_IsPresentTask__c = false;
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
                        CRM_IsPresentTask__c
                FROM Case
                WHERE Id IN:caseIds
            ];
        }
        catch(exception exc) {
            throw exc;
        }
        return (cases!=null && cases.size()>0 ? cases : new List<Case>());
    }

    private static Map<Id,Set<Id>> queryTaskByCaseId(Set<Id> caseIds) {
        Map<Id,Set<Id>>  mCaseTask = new Map<Id,Set<Id>>();
        try {
            List<Task> tasks = [
                SELECT  Id,
                        WhatId
                FROM Task
                WHERE WhatId IN:caseIds
            ];
            if (tasks!=null && tasks.size()>0) {
                for (Task t : tasks) {
                    Set<Id> ids = (mCaseTask.containsKey(t.WhatId) ? mCaseTask.get(t.WhatId) : new Set<Id>());
                    ids.add(t.Id);
                    mCaseTask.put(t.WhatId,ids);
                }
            }
        }
        catch(exception exc) {
            throw exc;
        }
        return mCaseTask;
    }

    public static void trackHistory(Map<Id, Task> oldTriggerTaskMap, Map<Id, Task> newTriggerTaskMap){
	
        //Get apiname of object (Task)
		String objApiName = String.valueOf(newTriggerTaskMap.getSObjectType());
	
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
            
            for(Task newTriggerTask : newTriggerTaskMap.values()){
                for(String trackingField : trackingFieldList){
                    String oldValue;
                    String newValue = (String) newTriggerTask.get(trackingField);
                    
                    if(!(oldTriggerTaskMap == null || oldTriggerTaskMap.isEmpty())){
                        Task oldTriggerTask = oldTriggerTaskMap.get(newTriggerTask.id);
                        oldValue = (String) oldTriggerTask.get(trackingField);
                    }

                    if((!String.isBlank(newValue) && String.isBlank(oldValue)) || (!String.isBlank(newValue) && !String.isBlank(oldValue) && !(newValue.equals(oldValue)))){
                        TrackingHistory__c trackingObj = new TrackingHistory__c(
                                                        RecordTypeId = recordTypeIdString,
                                                        ParentObject__c = newTriggerTask.Id,
                                                        Cliente__c = newTriggerTask.AccountId,
                                                        Tracking_Field__c = trackingField,
                                                        Tracking_ObjRecordType__c = Schema.SObjectType.Task.getRecordTypeInfosById().get(newTriggerTask.RecordTypeId).getDeveloperName(),
                                                        OldValue__c = oldValue,
                                                        NewValue__c = newValue);
                        //get dynamically the field API name which contains the record id from metadata
                        trackingObj.put(metadataObj.ParentField__c, newTriggerTask.id);
                        
                        trackingObjects.add(trackingObj);
                    }

                }
            }
            
            insert trackingObjects;
        }
		
		
	}
    
}