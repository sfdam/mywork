public class OnCRMPropContrPrevTriggerHandler {
//Factory SR 2022-07-07: Allineamento del metodo trackHistory a quello della classe OnCampaignMemberTriggerHandler

    public static Boolean trafficLightTrackingTrigger = false;
    public static Boolean trafficLightAssegnazioneAzione = false; 										//Factory SR 2022-07-07

    public static void trackHistory(Map<Id, CRM_ProposteContrattiPreventivi__c> oldTriggerCRMProposteContrattiPreventiviMap, Map<Id, CRM_ProposteContrattiPreventivi__c> newTriggerCRMProposteContrattiPreventiviMap){
		if(!trafficLightAssegnazioneAzione){  															//Factory SR 2022-07-07
		        //Get apiname of object (CRMProposteContrattiPreventivi)
				String objApiName = String.valueOf(newTriggerCRMProposteContrattiPreventiviMap.getSObjectType());
			
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
		            TrackingHistory__c trackingObj; 													//Factory SR 2022-07-07							
		            for(CRM_ProposteContrattiPreventivi__c newTriggerCRMProposteContrattiPreventivi : newTriggerCRMProposteContrattiPreventiviMap.values()){
		            //Factory SR 2022-07-07 begin
		            	String trackingFields = '';
		                String oldValue = '';
		                String newValue = '';
		                for(String tf : trackingFieldList){
		                        trackingFields = trackingFields + ';' + tf;
		                        if(oldTriggerCRMProposteContrattiPreventiviMap != null && oldTriggerCRMProposteContrattiPreventiviMap.containsKey(newTriggerCRMProposteContrattiPreventivi.Id)){
		                            oldValue = oldValue + ';' + oldTriggerCRMProposteContrattiPreventiviMap.get(newTriggerCRMProposteContrattiPreventivi.Id).get(tf);
		                        }
		                        newValue = newValue + ';' + newTriggerCRMProposteContrattiPreventivi.get(tf);
		                }
		                trackingFields = trackingFields.substring(1, trackingFields.length());
		                    if(!String.isBlank(oldValue)) oldValue = oldValue.substring(1, oldValue.length());
		                    newValue = newValue.substring(1, newValue.length());
		
		                    if(newValue != oldValue){
		                        trackingObj = new TrackingHistory__c(
		                            RecordTypeId = recordTypeIdString,
		                            ParentObject__c = newTriggerCRMProposteContrattiPreventivi.Id,
		                            Cliente__c = newTriggerCRMProposteContrattiPreventivi.CRM_NDGPrimario__c,
		                            Tracking_Field__c = trackingFields,
		                            Tracking_ObjRecordType__c = '',
		                            OldValue__c = oldValue,
		                            NewValue__c = newValue);
		                        trackingObjects.add(trackingObj);
		                	}
		            	         
		                
		               /* for(String trackingField : trackingFieldList){
		                    String oldValue;
		                    String newValue = (String) newTriggerCRMProposteContrattiPreventivi.get(trackingField);
		                    
		                    if(!(oldTriggerCRMProposteContrattiPreventiviMap == null || oldTriggerCRMProposteContrattiPreventiviMap.isEmpty())){
		                        CRM_ProposteContrattiPreventivi__c oldTriggerCRMProposteContrattiPreventivi = oldTriggerCRMProposteContrattiPreventiviMap.get(newTriggerCRMProposteContrattiPreventivi.id);
		                        oldValue = (String) oldTriggerCRMProposteContrattiPreventivi.get(trackingField);
		                    }
		
		                    if((!String.isBlank(newValue) && String.isBlank(oldValue)) || (!String.isBlank(newValue) && !String.isBlank(oldValue) && !(newValue.equals(oldValue)))){
		                        TrackingHistory__c trackingObj = new TrackingHistory__c(
		                                                        RecordTypeId = recordTypeIdString,
		                                                        ParentObject__c = newTriggerCRMProposteContrattiPreventivi.Id,
		                                                        Cliente__c = newTriggerCRMProposteContrattiPreventivi.CRM_NDGPrimario__c,
		                                                        Tracking_Field__c = trackingField,
		                                                        Tracking_ObjRecordType__c = '',
		                                                        OldValue__c = oldValue,
		                                                        NewValue__c = newValue);
		                        //get dynamically the field API name which contains the record id from metadata
		                        trackingObj.put(metadataObj.ParentField__c, newTriggerCRMProposteContrattiPreventivi.id);
		                        
		                        trackingObjects.add(trackingObj);
		                    }
		
		                }*/
		                //Factory SR 2022-07-07 end fine
		            }
		            
		            insert trackingObjects;
		        }
		//Factory SR 2022-07-07 begin
		} else {
            System.debug('OnCRMPropContrPrevTriggerHandler-trackHistory trafficLightAssegnazioneAzione: ' + trafficLightAssegnazioneAzione);
        }
		//Factory SR 2022-07-07 end
		
	}
}