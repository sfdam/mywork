trigger OnMemoTrigger on CRM_Memo__c (after insert, after update, after delete) {

    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            OnMemoTriggerHandler.handleAfterInsert(Trigger.new, Trigger.newMap);
        }

        if(Trigger.isUpdate) {
            OnMemoTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }

        if(Trigger.isDelete) {
            OnMemoTriggerHandler.handleAfterDelete(Trigger.oldMap);
        }
    }
}