public class OnFinServAlertTriggerHandler {

    public static Boolean trafficLightTrackingTrigger = false;

    public static void trackHistory(Map<Id, FinServ__Alert__c> oldTriggerOnFinServAlertMap, Map<Id, FinServ__Alert__c> newTriggerOnFinServAlertMap){
	
        //Get apiname of object (OnFinServAlert)
		String objApiName = String.valueOf(newTriggerOnFinServAlertMap.getSObjectType());
	
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
            
            for(FinServ__Alert__c newTriggerOnFinServAlert : newTriggerOnFinServAlertMap.values()){
                for(String trackingField : trackingFieldList){
                    String oldValue;
                    String newValue = (String) newTriggerOnFinServAlert.get(trackingField);
                    
                    if(!(oldTriggerOnFinServAlertMap == null || oldTriggerOnFinServAlertMap.isEmpty())){
                        FinServ__Alert__c oldTriggerOnFinServAlert = oldTriggerOnFinServAlertMap.get(newTriggerOnFinServAlert.id);
                        oldValue = (String) oldTriggerOnFinServAlert.get(trackingField);
                    }

                    if((!String.isBlank(newValue) && String.isBlank(oldValue)) || (!String.isBlank(newValue) && !String.isBlank(oldValue) && !(newValue.equals(oldValue)))){
                        TrackingHistory__c trackingObj = new TrackingHistory__c(
                                                        RecordTypeId = recordTypeIdString,
                                                        ParentObject__c = newTriggerOnFinServAlert.Id,
                                                        Cliente__c = newTriggerOnFinServAlert.FinServ__Account__c,
                                                        Tracking_Field__c = trackingField,
                                                        Tracking_ObjRecordType__c = '',
                                                        OldValue__c = oldValue,
                                                        NewValue__c = newValue);
                        //get dynamically the field API name which contains the record id from metadata
                        trackingObj.put(metadataObj.ParentField__c, newTriggerOnFinServAlert.id);
                        
                        trackingObjects.add(trackingObj);
                    }

                }
            }
            
            insert trackingObjects;
        }
		
		
	}
}