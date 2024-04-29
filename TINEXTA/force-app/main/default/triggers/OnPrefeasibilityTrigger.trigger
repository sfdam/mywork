trigger OnPrefeasibilityTrigger on WRT_Pre_Feasibility__c (before insert, after update, before update) {
    
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disabilita_Trigger_Prefeasibility__c)return;
    
    if (Trigger.isInsert){
        if (Trigger.isBefore){
            OnPrefeasibilityTriggerHandler.checkDuplicates(Trigger.new);
        }
        if (Trigger.isBefore){
            OnPrefeasibilityTriggerHandler.checkModifyInsert(Trigger.new);
        }
    }
    if (Trigger.isUpdate){
        if (Trigger.isBefore){
            OnPrefeasibilityTriggerHandler.checkModify(Trigger.newMap, trigger.oldMap);
        }
    }
}