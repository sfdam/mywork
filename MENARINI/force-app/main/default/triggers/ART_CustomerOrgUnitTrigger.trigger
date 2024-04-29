trigger ART_CustomerOrgUnitTrigger on cgcloud__Account_Org_Unit__c (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {
        ART_CustomerOrgUnitTriggerHandler.setOrgUnitUser(Trigger.new);
    }
}