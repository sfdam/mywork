trigger OnCRMAccountDetailTrigger on CRM_AccountDetail__c  (after insert, after update) {

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            OnCRMAccountDetailTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);
        }
        else if(Trigger.isUpdate) {
            OnCRMAccountDetailTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);
        }
    }

}