public class OnOpportunityTriggerHandler {
    /*
    public static void publishEvent(List<Opportunity> records, Map<Id,Opportunity> oldMap){
        List<OpportunityDataTableEvent__e> eventList = new List<OpportunityDataTableEvent__e>();
        for(Opportunity o:records){
            OpportunityDataTableEvent__e event = new OpportunityDataTableEvent__e();
            event.OpportunityId__c=o.Id;
            event.UserId__c=UserInfo.getUserId();
            eventList.add(event);
        }
        EventBus.publish(eventList);
    }*/

    public static Boolean trafficLightTrackingTrigger = false;

    public static Set<String> ccOppMatchSet {
        get{

            if(ccOppMatchSet != null){
                return ccOppMatchSet;
            }
            ccOppMatchSet = new Set<String>();
            List<CCOpportunityMatch__mdt> ccOppMatch = [SELECT id, Prodotto__c, Esito__c, Assegnatario__c, StessoAssegnatario__c FROM CCOpportunityMatch__mdt];
            ccOppMatchSet.addAll(SV_Utilities.keyBy(ccOppMatch, '{Prodotto__c}_{Esito__c}_{Assegnatario__c}', true).keySet());
            for(CCOpportunityMatch__mdt ccOpportunityMatch : ccOppMatch){
                if(ccOpportunityMatch.StessoAssegnatario__c){
                    ccOppMatchSet.add(ccOpportunityMatch.Prodotto__c + '_' + ccOpportunityMatch.Esito__c + '_true');
                }
            }
            System.debug('DK ccOppMatchSet: ' + JSON.serialize(ccOppMatchSet));
            return ccOppMatchSet;
        }set;
    }

    public static void makeCallOpportunity(Map<Id,sObject> oldOptMap, Map<Id,sObject> newOptMap){

        List<Id> oppCallIdList = new List<Id>();
        List<Id> oppCCMatched = new List<Id>();

        Map<String, SObject> ownerOppMap = SV_Utilities.keyBy(newOptMap.values(), 'OwnerId');
        Map<String, SOBject> userMap = SV_Utilities.keyBy([SELECT id, Name FROM USer WHERE id IN: ownerOppMap.keySet()], 'Id');

        for(Id oppId : newOptMap.keyset()){
            String requestMatch = (String)newOptMap.get(oppId).get('CRM_ProductCategory__c') + '_' + (String)newOptMap.get(oppId).get('StageName');
            System.debug('DK requestMatch: ' + requestMatch);
            System.debug('DK userMap.get(newOptMap.get(oppId).OwnerId).get(): ' + (String)userMap.get((String)newOptMap.get(oppId).get('OwnerId')).get('Name'));
            if((String)newOptMap.get(oppId).get('RecordTypeId') == SV_Utilities.getRecordTypeByDeveloperName('Opportunity', 'Opportunita_da_cc_vs_rete') &&
                (String)newOptMap.get(oppId).get('StageName') == 'In corso' && 
                !System.isFuture()){
                oppCallIdList.add(oppId);
            }
            
            if(ccOppMatchSet.contains(requestMatch + '_' + (String)userMap.get((String)newOptMap.get(oppId).get('OwnerId')).get('Name')) ||
                ccOppMatchSet.contains(requestMatch + '_Tutti') ||
                ccOppMatchSet.contains(requestMatch + '_' + (UserInfo.getUserId() == (String)newOptMap.get(oppId).get('OwnerId')))){

                oppCCMatched.add(oppId);
            }
        }

        if(oppCallIdList.size()>0){
            
            for(Id oppId :oppCallIdList){

                sendRequest(oppId, 'notificaStatoProcesso');
            }
        }

        if(oppCCMatched.size()>0){
            
            for(Id oppId :oppCCMatched){

                sendRequest(oppId, 'inserisciEventoContactCenter_Opp');
            }
        }
    }

    @future(callout=true)
    public static void sendRequest(Id recordId, String request){

        StaticResource staticResource = [select id,body from StaticResource Where Name = 'jsonWrapper'];
        String jsonWrapper = staticResource.body.toString();
        Map<String, Map<String, Object>> fieldsMap = new Map<String, Map<String, Object>>();
        Map<String, Map<String, String>> conditionMap = new Map<String, Map<String, String>>();
        Map<String,Object> parsedJsonWrapper = (Map<String,Object>)JSON.deserializeUntyped(jsonWrapper);
        Map<String,Object> parsedJsonElement = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonWrapper.get(request)));
        Map<String, Object> parsedJsonElementFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('fields')));
        for(String fieldName : parsedJsonElementFields.keySet()){

            fieldsMap.put(fieldName, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementFields.get(fieldName))));
        }
            
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(MakeRequestController.makeRequest(request, recordId, fieldsMap, null, 'salesforceprodclient2024', '',false));
        System.debug('DK response: ' + response);
        if((String)response.get('statusCode') != '204' && request == 'inserisciEventoContactCenter_Opp'){

            insert new SV_FailedRequest__c(RequestName__c = request,
                                RecordId__c = recordId,
                                FieldsMap__c = JSON.serialize(fieldsMap),
                                CertificationName__c = 'salesforceprodclient2024');
        }
    }

    public static void trackHistory(Map<Id, Opportunity> oldTriggerOpportunityMap, Map<Id, Opportunity> newTriggerOpportunityMap){
    
        //Get apiname of object (Opportunity)
        String objApiName = String.valueOf(newTriggerOpportunityMap.getSObjectType());
    
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
            
            for(Opportunity newTriggerOpportunity : newTriggerOpportunityMap.values()){
                for(String trackingField : trackingFieldList){
                    String oldValue;
                    String newValue = (String) newTriggerOpportunity.get(trackingField);
                    
                    if(!(oldTriggerOpportunityMap == null || oldTriggerOpportunityMap.isEmpty())){
                        Opportunity oldTriggerOpportunity = oldTriggerOpportunityMap.get(newTriggerOpportunity.id);
                        oldValue = (String) oldTriggerOpportunity.get(trackingField);
                    }

                    if((!String.isBlank(newValue) && String.isBlank(oldValue)) || (!String.isBlank(newValue) && !String.isBlank(oldValue) && !(newValue.equals(oldValue)))){
                        TrackingHistory__c trackingObj = new TrackingHistory__c(
                                                        RecordTypeId = recordTypeIdString,
                                                        ParentObject__c = newTriggerOpportunity.Id,
                                                        Cliente__c = newTriggerOpportunity.AccountId,
                                                        Tracking_Field__c = trackingField,
                                                        Tracking_ObjRecordType__c = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(newTriggerOpportunity.RecordTypeId).getDeveloperName(),
                                                        OldValue__c = oldValue,
                                                        NewValue__c = newValue);
                        //get dynamically the field API name which contains the record id from metadata
                        trackingObj.put(metadataObj.ParentField__c, newTriggerOpportunity.id);
                        
                        trackingObjects.add(trackingObj);
                    }

                }
            }
            
            insert trackingObjects;
        }
        
        
    }
    
    public static void populateAccountId(List<Opportunity> newTriggerOpportunity){
        List<Id> listContId = new List<Id>();
        List<Opportunity> listOptItem = new List<Opportunity>();
        for(Opportunity optTemp : newTriggerOpportunity){
            if(optTemp.AccountId == null){
                listContId.add(optTemp.ContactId);
                listOptItem.add(optTemp);
            }
        }
        System.debug('listContId: '+listContId.size());
        System.debug('listOptItem: '+listOptItem.size());
        
        Map<Id,Contact> mapOptCont = new Map <Id,Contact>([Select id, accountId FROM Contact where ID IN :listContId]);
        System.debug('listOptItem: '+mapOptCont.size());
            
        for(Opportunity optTemp : listOptItem){
                optTemp.accountId = mapOptCont.get(optTemp.ContactId).AccountId;
            }
        
    }
}