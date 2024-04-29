trigger OnFinanziamentiTrigger on Finanziamenti__c (after insert,before insert, before delete, before update, after update, after delete) {
    
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disabilita_tutti_i_trigger__c)return;
    
    if(trigger.isBefore && trigger.isInsert){
    }
    
    if (trigger.isafter && trigger.isinsert) {
        OnFinanziamentiTriggerHandler.InsertdaListino(trigger.newMap);
        OnFinanziamentiTriggerHandler.AllineaRollupInsert(trigger.new);
        OnFinanziamentiTriggerHandler.aggiornaCampoFinanziamentoApprovazioneQuote_Insert(trigger.newMap);
        //OnFinanziamentiTriggerHandler.createFinanziamentiInfostore(Trigger.newMap.keySet());        
    }
    
    if(trigger.isBefore && trigger.isUpdate){

    }
    
    if (trigger.isafter && trigger.isupdate) {
        OnFinanziamentiTriggerHandler.AllineaRollupUpdate(trigger.oldmap,trigger.newmap);
        //OnFinanziamentiTriggerHandler.aggiornaCampoFinanziamentoApprovazioneQuote_Update(trigger.newMap, trigger.oldMap);
        //OnFinanziamentiTriggerHandler.aggiornaFinanziamentiInfostore(trigger.newMap.keySet());
    }
    
    if (trigger.isbefore && trigger.isdelete) {
        OnFinanziamentiTriggerHandler.AllineaRollupDelete(trigger.old);
    }
    
}