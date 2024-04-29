public class OnCRMIngaggioRetiEsterneTriggerHandler {

    public static Boolean trafficLightTrackingTrigger = false;

    public static void trackHistory(Map<Id, CRM_IngaggioRetiEsterne__c> oldTriggerCRM_IngaggioRetiEsterneMap, Map<Id, CRM_IngaggioRetiEsterne__c> newTriggerCRM_IngaggioRetiEsterneMap){
	
        //Get apiname of object (CRM_IngaggioRetiEsterne)
		String objApiName = String.valueOf(newTriggerCRM_IngaggioRetiEsterneMap.getSObjectType());
	
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
            
            for(CRM_IngaggioRetiEsterne__c newTriggerCRM_IngaggioRetiEsterne : newTriggerCRM_IngaggioRetiEsterneMap.values()){
                for(String trackingField : trackingFieldList){
                    String oldValue;
                    String newValue = (String) newTriggerCRM_IngaggioRetiEsterne.get(trackingField);
                    
                    if(!(oldTriggerCRM_IngaggioRetiEsterneMap == null || oldTriggerCRM_IngaggioRetiEsterneMap.isEmpty())){
                        CRM_IngaggioRetiEsterne__c oldTriggerCRM_IngaggioRetiEsterne = oldTriggerCRM_IngaggioRetiEsterneMap.get(newTriggerCRM_IngaggioRetiEsterne.id);
                        oldValue = (String) oldTriggerCRM_IngaggioRetiEsterne.get(trackingField);
                    }

                    if((!String.isBlank(newValue) && String.isBlank(oldValue)) || (!String.isBlank(newValue) && !String.isBlank(oldValue) && !(newValue.equals(oldValue)))){
                        TrackingHistory__c trackingObj = new TrackingHistory__c(
                                                        RecordTypeId = recordTypeIdString,
                                                        ParentObject__c = newTriggerCRM_IngaggioRetiEsterne.Id,
                                                        Cliente__c = newTriggerCRM_IngaggioRetiEsterne.CRM_Cliente__c,
                                                        Tracking_Field__c = trackingField,
                                                        Tracking_ObjRecordType__c = '',
                                                        OldValue__c = oldValue,
                                                        NewValue__c = newValue);
                        //get dynamically the field API name which contains the record id from metadata
                        trackingObj.put(metadataObj.ParentField__c, newTriggerCRM_IngaggioRetiEsterne.id);
                        
                        trackingObjects.add(trackingObj);
                    }

                }
            }
            
            insert trackingObjects;
        }
		
		
	}
}