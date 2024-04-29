public with sharing class OnCRMAccountDetailTriggerHandler {

    public static Boolean trafficLightTrackingTrigger = false;

    public static void trackHistory(Map<Id, CRM_AccountDetail__c> oldTriggerAccountDetailMap, Map<Id, CRM_AccountDetail__c> newTriggerAccountDetailMap){
	
        //Get apiname of object (Event)
		String objApiName = String.valueOf(newTriggerAccountDetailMap.getSObjectType());
	
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
            List<TrackingHistory__c> trackingObjects = new List<TrackingHistory__c>();
            String newValue;

            for(CRM_AccountDetail__c newTriggerAccountDetail : newTriggerAccountDetailMap.values()){
                for(String trackingField : trackingFieldList){
                    String oldValue;
                    System.debug('track: '+newTriggerAccountDetail.get(trackingField));
                    
                    if(newTriggerAccountDetail.get(trackingField)==true)
                        newValue='true';
                    else if(newTriggerAccountDetail.get(trackingField)==false) {
                        newValue='false';
                    }
                    else newValue = (String) newTriggerAccountDetail.get(trackingField);
                    
                    if(!(oldTriggerAccountDetailMap == null || oldTriggerAccountDetailMap.isEmpty())){
                        CRM_AccountDetail__c oldTriggerAccountDetail = oldTriggerAccountDetailMap.get(newTriggerAccountDetail.id);
                        System.debug('track old: '+oldTriggerAccountDetail.get(trackingField));

                        if(oldTriggerAccountDetail.get(trackingField)==true)
                            oldValue='true';
                        else if(oldTriggerAccountDetail.get(trackingField)==false) {
                            oldValue='false';
                        }
                        else oldValue = (String) oldTriggerAccountDetail.get(trackingField);
                        
                    }

                    if((!String.isBlank(newValue) && String.isBlank(oldValue)) || (!String.isBlank(newValue) && !String.isBlank(oldValue) && !(newValue.equals(oldValue)))){
                        TrackingHistory__c trackingObj = new TrackingHistory__c(
                                                        RecordTypeId = recordTypeIdString,
                                                        ParentObject__c = newTriggerAccountDetail.Id,
                                                        Cliente__c = newTriggerAccountDetail.CRM_Account__c,
                                                        Tracking_Field__c = trackingField,
                                                        Tracking_ObjRecordType__c = '',
                                                        OldValue__c = oldValue,
                                                        NewValue__c = newValue);
                        //get dynamically the field API name which contains the record id from metadata
                        trackingObj.put(metadataObj.ParentField__c, newTriggerAccountDetail.id);
                        
                        trackingObjects.add(trackingObj);
                    }

                }
            }
            
            insert trackingObjects;
        }
    }
}