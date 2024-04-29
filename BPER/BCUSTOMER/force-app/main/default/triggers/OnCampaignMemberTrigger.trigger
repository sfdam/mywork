trigger OnCampaignMemberTrigger on CampaignMember (before insert, before update, after insert, after update) {

    // if(Trigger.isAfter){
    //  if(Trigger.isInsert || Trigger.isUpdate){
    //      OnCampaignMemberTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);
    //  }
    // }

    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_CampaignMemberTrigger__c) {
        System.debug('SV CampaignMember trigger Disable_CampaignMemberTrigger__c: ' + f.Disable_CampaignMemberTrigger__c);
        return;
    }


    if(trigger.isInsert){
        if(trigger.isBefore){
            System.debug('SV CampaignMember INSERT trigger.isBefore');
            if(f.isMC__c){
                OnCampaignMemberTriggerHandler.setFields(Trigger.new);
            }
        }
        
        if(trigger.isAfter){
            System.debug('SV CampaignMember INSERT trigger.isAfter');
            OnCampaignMemberTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);
            OnCampaignMemberTriggerHandler.setGhostForInsert(Trigger.newMap);
            
        }        
    }
    
    if(trigger.isUpdate){
        if(trigger.isBefore){
            System.debug('SV CampaignMember UPDATE trigger.isBefore');
            if(f.isMC__c){
                OnCampaignMemberTriggerHandler.setFields(Trigger.new);
            }
        }
        
        if(trigger.isAfter){
            System.debug('SV CampaignMember UPDATE trigger.isAfter');
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get('CampaignMember').getDescribe().fields.getMap();

            String commaSepratedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(commaSepratedFields == null || commaSepratedFields == ''){
                    commaSepratedFields = fieldName;
                }else{
                    commaSepratedFields = commaSepratedFields + ', ' + fieldName;
                }
            }
            List<Id> cmIds = new List<Id>();
            for ( CampaignMember cm : Trigger.New ){
                cmIds.add(cm.Id);
            }
            String query = 'SELECT ' + commaSepratedFields + ', CampaignMember.Campaign.softphone_it__Gc_Contact_List_Id__c, CampaignMember.Campaign.softphone_it__Genesys_Cloud_Sync__c, CampaignMember.Campaign.softphone_it__Gc_Custom_Fields__c,CampaignMember.Campaign.Name, ' +
                'Contact.Phone,Campaign.CRM_QueueId__c,Campaign.CRM_Intervallo_richiamata__c,CRM_EsitoCampagna__r.CRM_Richiamata_Genesys__c ' +
                'FROM CampaignMember WHERE Id IN :cmIds';
            System.debug('running query : ' + query);
            List<CampaignMember> members =  Database.query(query);
            System.debug('campaign member campaign :' + members[0].Campaign);
            OnCampaignMemberTriggerHandler.checkNCS(members, Trigger.oldMap);
            OnCampaignMemberTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);
            OnCampaignMemberTriggerHandler.genesysQueueCallout(Trigger.New, Trigger.oldMap);
            OnCampaignMemberTriggerHandler.setGhost(Trigger.oldMap, Trigger.newMap, 'Update');
            OnCampaignMemberTriggerHandler.activateGhost(Trigger.new, Trigger.oldMap);
            // OnCampaignMemberTriggerHandler.setGhostForUpdate(Trigger.newMap);
            // OnCampaignMemberTriggerHandler.setGhostForDelete(Trigger.newMap);

        }
    }
}