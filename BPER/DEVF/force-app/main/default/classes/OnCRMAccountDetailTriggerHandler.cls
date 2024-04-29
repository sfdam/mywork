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
            List<TrackingHistory__c> trackingObjectsList = new List<TrackingHistory__c>();
            TrackingHistory__c trackingObj; 

            for(CRM_AccountDetail__c newTriggerAccountDetail : newTriggerAccountDetailMap.values()){
                String trackingFields = '';
                String oldValue = '';
                String newValue = '';
                for(String tf : trackingFieldList){
                    trackingFields = trackingFields + ';' + tf;
                    if(oldTriggerAccountDetailMap.containsKey(newTriggerAccountDetail.Id)){
                        oldValue = oldValue + ';' + oldTriggerAccountDetailMap.get(newTriggerAccountDetail.Id).get(tf);
                    }
                    newValue = newValue + ';' + newTriggerAccountDetail.get(tf);
                }
                trackingFields = trackingFields.substring(1, trackingFields.length());
                if(!String.isBlank(oldValue)) oldValue = oldValue.substring(1, oldValue.length());
                newValue = newValue.substring(1, newValue.length());
				trackingObj = new TrackingHistory__c(
														RecordTypeId = recordTypeIdString,
														ParentObject__c = newTriggerAccountDetail.Id,
                                                        Cliente__c = newTriggerAccountDetail.CRM_Account__c,
														Tracking_Field__c = trackingFields,
														OldValue__c = oldValue,
														NewValue__c = newValue);

                trackingObjectsList.add(trackingObj);
			}
			
			insert trackingObjectsList;
        }
    }
}