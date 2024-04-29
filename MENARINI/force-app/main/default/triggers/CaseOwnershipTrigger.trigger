trigger CaseOwnershipTrigger on Case_Ownership__c (before insert, after insert) {

    if (Trigger.isInsert)
    {
        if(Trigger.isAfter) {
            THR_CaseOwnershipHandler.createNewPartialRecord(Trigger.new);
        }
    }
}