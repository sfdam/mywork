trigger ART_OrgUnitUserTrigger on cgcloud__Org_Unit_User__c (after insert) {
    
    if (Trigger.isAfter && Trigger.isInsert) {
        ART_OrgUnitUserTriggerHandler.updateCustomerWorkplaceOwner(Trigger.new);
    }
}