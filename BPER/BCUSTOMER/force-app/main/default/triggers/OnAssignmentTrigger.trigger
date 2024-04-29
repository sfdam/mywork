/**
 * Name         :   OnAssignmentTrigger
 * Author       :   Ezio Dal Bo @TEN
 * Create Date  :   2020-07-30
**/
trigger OnAssignmentTrigger on Assignment__c (after insert, after update) {
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c && !Batch_CalcoloReferenti.runAssignmentTrigger) return;
    if (f.Disable_AssignmentTrigger__c && !Batch_CalcoloReferenti.runAssignmentTrigger) return;

    if (Trigger.isBefore) {

    }else if (Trigger.isAfter) {
        
        if (Trigger.isInsert) {

            OnAssignmentTriggerHandler.onAfterInsert(Trigger.New);
            OnAssignmentTriggerHandler.setFieldsOnPTF(Trigger.NewMap, null);

        }
        else if (Trigger.isUpdate) {

            OnAssignmentTriggerHandler.onAfterUpdate(Trigger.New, Trigger.OldMap);
            OnAssignmentTriggerHandler.setFieldsOnPTF(Trigger.NewMap, Trigger.OldMap);

        }
    }
}