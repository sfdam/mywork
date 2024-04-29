trigger OnQuoteTrigger on SBQQ__Quote__c (after insert,after update, before insert, before update, before delete) {
    
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disabilita_tutti_i_trigger__c)return;
    
    if (trigger.isafter && trigger.isinsert){
        system.debug('After Insert');
        OnQuoteTriggerHandler.InsertOpportunity(trigger.newMap);
        OnQuoteTriggerHandler.approvazioneFatturato_Insert(trigger.newMap);
        //OnQuoteTriggerHandler.approvazioniWarrant_Insert(trigger.new);
        // WRT_IntegrazioneController.QuoteIntegration_SharePoint(Trigger.newMap.keySet());        
    }
    
    if (trigger.isbefore && trigger.isinsert){
        OnQuoteTriggerHandler.BlockCreate(trigger.new);
        system.debug('Before Insert');
        
    }
    
    if (trigger.isafter && trigger.isupdate){
        system.debug('After Update');
        OnQuoteTriggerHandler.CampiDisdetta (trigger.oldMap, trigger.newMap);
        OnQuoteTriggerHandler.approvazioniWarrant_Update(trigger.newMap, trigger.oldMap);
        //OnQuoteTriggerHandler.changeOwner(trigger.new, trigger.old);
        
    }
    
    if (trigger.isbefore && trigger.isupdate){
        system.debug('Before Update');
        OnQuoteTriggerHandler.QuoteClose (trigger.oldMap, trigger.newMap);
        OnQuoteTriggerHandler.checkWOChiusaPersa(trigger.newMap, trigger.oldMap); //AMS 001083
        OnQuoteTriggerHandler.NumeroInfostore (trigger.oldMap, trigger.newMap);  
        OnQuoteTriggerHandler.AggiornamentoCloseDateApprovazioneLegale(trigger.oldMap, trigger.newMap);
        
        //OnQuoteTriggerHandler.updateStageNameRules(trigger.oldMap, trigger.newMap);
        
    }
    
    if(trigger.isbefore && trigger.isdelete){
        system.debug('Before Delete');
        OnQuoteTriggerHandler.blockDelete(trigger.oldMap);
    }
    
    
}