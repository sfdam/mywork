trigger OnCaseTrigger on Case (after insert, before insert, after update, before update, after delete) {
    
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_CaseTrigger__c) return;
    
    if(OnCaseTriggerHandler.skipExecution) return;
    if(Trigger.isInsert){
        if(Trigger.isBefore){

            sYSTEM.DEBUG('DK start isBefore isInsert');
            OnCaseTriggerHandler.skipCustomValidation=true;
            OnCaseTriggerHandler.setFields(Trigger.new,  Trigger.oldMap, false);
            OnCaseTriggerHandler.checkFinancialAccountRole(Trigger.new,  Trigger.oldMap, false);
            OnCaseTriggerHandler.linkChatOrWhatsappCase(Trigger.new); //valerio.salvati
        }
        
        if(Trigger.isAfter){
            sYSTEM.DEBUG('DK start isAfter isInsert');
            OnCaseTriggerHandler.isChildUpdate(Trigger.new,  Trigger.oldMap, false);
            OnCaseTriggerHandler.setOwnerTeamPolo(Trigger.new,  Trigger.oldMap);
           // OnCaseTriggerHandler.createCaseTeam(Trigger.new,  Trigger.oldMap);
            //OnCaseTriggerHandler.publishEvent(Trigger.new,  Trigger.oldMap);
            OnCaseTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);
            //OnCaseTriggerHandler.linkChatInteraction(Trigger.new); //valerio.salvati

        }
    }

    if(Trigger.isUpdate){
        if(UserInfo.getName()!='Automated Process'){
            if(Trigger.isAfter){
                sYSTEM.DEBUG('DK start isAfter isUpdate');
                OnCaseTriggerHandler.isParentUpdate(Trigger.new,  Trigger.newMap,  Trigger.oldMap);
                OnCaseTriggerHandler.isChildUpdate(Trigger.new,  Trigger.oldMap, true);
                OnCaseTriggerHandler.switchOwnerTeam(Trigger.newMap,  Trigger.oldMap);
                //OnCaseTriggerHandler.switchCaseTeam(Trigger.new,  Trigger.oldMap);
                OnCaseTriggerHandler.makeCalloutCase(Trigger.newMap,  Trigger.oldMap);
                //OnCaseTriggerHandler.publishEvent(Trigger.new,  Trigger.oldMap);
                OnCaseTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);

            }
            if(Trigger.isBefore){
                sYSTEM.DEBUG('DK start isBefore isUpdate');
                OnCaseTriggerHandler.customValidation(Trigger.new,  Trigger.oldMap);
                OnCaseTriggerHandler.checkFinancialAccountRole(Trigger.new,  Trigger.oldMap, true);
                OnCaseTriggerHandler.setFields(Trigger.new, Trigger.oldMap, true);
                OnCaseTriggerHandler.fromUsertoQueue(Trigger.new,  Trigger.oldMap);
            }
        }   
    }
    /*if(trigger.isDelete){
        if(trigger.isAfter){
            OnCaseTriggerHandler.publishEvent(Trigger.old,  Trigger.oldMap);
        }
    }*/
}