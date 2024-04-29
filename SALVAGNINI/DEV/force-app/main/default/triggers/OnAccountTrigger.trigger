trigger OnAccountTrigger on Account (before insert, before update, after update , after insert) {
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            OnAccountTriggerHandler.manageTerrioryOnInsert(trigger.new);
        }
    }
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            OnAccountTriggerHandler.manageTerritoryOnUpdate(trigger.oldMap,trigger.newMap);
        }
    }
    if(trigger.isAfter){
        List<String> recordIds = new List<string>();
        for(Id singleId : trigger.newMap.keyset()){
            if(trigger.newMap.get(singleId).Type == 'Customer'){
                recordIds.Add(singleId);
            }
        }
        StSTriggerHandler.sendRecords(recordIds);
    }
}