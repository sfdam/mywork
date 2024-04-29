trigger OnNDGManagementMemberTrigger on NDGManagementMember__c (before insert) {
    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            OnNDGManagementMemberTriggerHandler.setStoricoCampi(Trigger.new);
        }
    }
}