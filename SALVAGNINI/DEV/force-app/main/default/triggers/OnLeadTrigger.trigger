trigger OnLeadTrigger on Lead (before insert , before update) {
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            OnLeadTriggerHandler.manageTerritoryOnInsert(trigger.new);
        }
    }
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            OnLeadTriggerHandler.manageTerritoryOnUpdate(trigger.oldMap,trigger.newMap);
        }
    }


}