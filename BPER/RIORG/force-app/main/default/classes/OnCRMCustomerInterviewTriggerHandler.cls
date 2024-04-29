public class OnCRMCustomerInterviewTriggerHandler {

    public static Boolean trafficLightTrackingTrigger = false;


    public static void trackHistory(Map<Id, CRM_CustomerInterview__c> oldTriggerCRM_CustomerInterviewMap, Map<Id, CRM_CustomerInterview__c> newTriggerCRM_CustomerInterviewMap){
	
        //Get apiname of object (CRM_CustomerInterview)
		String objApiName = String.valueOf(newTriggerCRM_CustomerInterviewMap.getSObjectType());
	
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
            
            for(CRM_CustomerInterview__c newTriggerCRM_CustomerInterview : newTriggerCRM_CustomerInterviewMap.values()){
                for(String trackingField : trackingFieldList){
                    String oldValue;
                    String newValue = (String) newTriggerCRM_CustomerInterview.get(trackingField);
                    
                    if(!(oldTriggerCRM_CustomerInterviewMap == null || oldTriggerCRM_CustomerInterviewMap.isEmpty())){
                        CRM_CustomerInterview__c oldTriggerCRM_CustomerInterview = oldTriggerCRM_CustomerInterviewMap.get(newTriggerCRM_CustomerInterview.id);
                        oldValue = (String) oldTriggerCRM_CustomerInterview.get(trackingField);
                    }

                    if((!String.isBlank(newValue) && String.isBlank(oldValue)) || (!String.isBlank(newValue) && !String.isBlank(oldValue) && !(newValue.equals(oldValue)))){
                        TrackingHistory__c trackingObj = new TrackingHistory__c(
                                                        RecordTypeId = recordTypeIdString,
                                                        ParentObject__c = newTriggerCRM_CustomerInterview.Id,
                                                        Cliente__c = newTriggerCRM_CustomerInterview.CRM_Customer__c,
                                                        Tracking_Field__c = trackingField,
                                                        Tracking_ObjRecordType__c = Schema.SObjectType.CRM_CustomerInterview__c.getRecordTypeInfosById().get(newTriggerCRM_CustomerInterview.RecordTypeId).getDeveloperName(),
                                                        OldValue__c = oldValue,
                                                        NewValue__c = newValue);
                        //get dynamically the field API name which contains the record id from metadata
                        trackingObj.put(metadataObj.ParentField__c, newTriggerCRM_CustomerInterview.id);
                        
                        trackingObjects.add(trackingObj);
                    }

                }
            }
            
            insert trackingObjects;
            trafficLightTrackingTrigger = true;
        }
		
		
	}
}