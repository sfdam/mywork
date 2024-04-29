trigger CaseTrigger on Case (before insert, after insert, before update, after update) {
   
    if (Trigger.isInsert)
    {
        if(Trigger.isBefore)
        {
            THR_CaseTriggerHandler.assignEntitlement(Trigger.new);
        }

        if(Trigger.isAfter) {
            THR_CaseTriggerHandler.createNewCaseOwnershipRecords(Trigger.new);
        }
    }
    
     
    if (Trigger.isUpdate)
    {
        if(Trigger.isBefore)   
        {
              system.debug('@@@@@@@@is before update trigger');
            THR_CaseTriggerHandler.completeMilestone(Trigger.newMap,Trigger.oldMap);
        }

        if(Trigger.isAfter) {
            THR_CaseTriggerHandler.updateCaseOwnershipRecord(Trigger.newMap,Trigger.oldMap);
        }
    }


}