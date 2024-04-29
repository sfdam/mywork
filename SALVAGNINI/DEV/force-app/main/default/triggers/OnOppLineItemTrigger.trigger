trigger OnOppLineItemTrigger on OpportunityLineItem (after insert, after delete) {
    if(Trigger.isInsert){
        if(Trigger.isAfter){
            OnOppLineItemTriggerHandler.manageModelsField(trigger.newMap);
            OnOppLineItemTriggerHandler.fillOpportunitySystem(trigger.newMap);
        }
    }
    if(Trigger.isDelete){
        if(Trigger.isAfter){
            OnOppLineItemTriggerHandler.manageModelsField(trigger.oldMap);
        }
    }
}