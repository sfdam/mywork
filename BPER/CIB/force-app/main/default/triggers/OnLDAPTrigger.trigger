trigger OnLDAPTrigger on LDAP__c (before insert,before update) {
    
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_LDAPTrigger__c) return;
    
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            OnLDAPTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isInsert) {
            OnLDAPTriggerHandler.beforeInsert(Trigger.new);
        }
    }
}