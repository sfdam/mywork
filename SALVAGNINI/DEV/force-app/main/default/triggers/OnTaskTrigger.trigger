trigger OnTaskTrigger on Task (after update) {
    if (Trigger.isUpdate) {
        if(Trigger.isAfter){
            OnTaskTriggerHandler.notifySerOwner(Trigger.oldMap, Trigger.newMap);
        }
    }
}