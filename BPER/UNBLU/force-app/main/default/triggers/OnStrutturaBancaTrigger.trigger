trigger OnStrutturaBancaTrigger on Struttura_Banca__c (before insert,before update) {
    
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_StrutturaBancaTrigger__c) return;
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            OnStrutturaBancaTriggerHandler.beforeInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            OnStrutturaBancaTriggerHandler.beforeUpdte(Trigger.new, Trigger.oldMap);
        }
    }

}