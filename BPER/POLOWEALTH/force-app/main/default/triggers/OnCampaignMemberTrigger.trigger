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
            OnCampaignMemberTriggerHandler.checkNCS(Trigger.new, Trigger.oldMap);
            OnCampaignMemberTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);
            OnCampaignMemberTriggerHandler.genesysQueueCallout(Trigger.new, Trigger.oldMap);
            OnCampaignMemberTriggerHandler.setGhost(Trigger.oldMap, Trigger.newMap, 'Update');
            OnCampaignMemberTriggerHandler.activateGhost(Trigger.new, Trigger.oldMap);
            // OnCampaignMemberTriggerHandler.setGhostForUpdate(Trigger.newMap);
            // OnCampaignMemberTriggerHandler.setGhostForDelete(Trigger.newMap);

        }
    }
}