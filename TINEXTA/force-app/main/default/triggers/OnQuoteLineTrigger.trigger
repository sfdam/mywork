trigger OnQuoteLineTrigger on SBQQ__QuoteLine__c (after insert,after update, before insert, before update, before delete) {
    
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disabilita_tutti_i_trigger__c)return;
    
    if (trigger.isafter && trigger.isinsert){
      	OnQuoteLineTriggerHandler.InsertDaListino(trigger.newMap);
      	WRT_IntegrazioneController.QuoteLineIntegration_SharePoint(Trigger.newMap.keySet());
        OnQuoteLineTriggerHandler.setCongaTemplateOnQuote(trigger.newMap, null, 'isInsert');		
    }
    
    If(trigger.isbefore && trigger.isinsert){
        OnQuoteLineTriggerHandler.setCongaTemplateAppoggio(trigger.new, null, 'isInsert');
        System.debug('Insert before TRIGGER');
    }
    
    If(trigger.isbefore && trigger.isupdate){
        System.debug('Update before TRIGGER');
        OnQuoteLineTriggerHandler.ReferenteTecnico (trigger.oldMap, trigger.newMap);
        OnQuoteLineTriggerHandler.ListUnitPriceApprovazioneLegale (trigger.oldMap, trigger.newMap);
        OnQuoteLineTriggerHandler.setCongaTemplateAppoggio(trigger.new, trigger.oldMap, 'isUpdate');
   
    }
    
    
    If(trigger.isafter && trigger.isupdate){
        system.debug('update AFTER');
                OnQuoteLineTriggerHandler.aggiornaStatoApprovazioni_Update(trigger.newMap, trigger.oldMap);
                OnQuoteLineTriggerHandler.updateTipoPagamento (trigger.oldMap, trigger.newMap);
                OnQuoteLineTriggerHandler.approvazioniWarrantQLI_Update(trigger.newMap, trigger.oldMap);
                OnQuoteLineTriggerHandler.setCongaTemplateOnQuote(trigger.newMap, trigger.oldMap, 'isUpdate'); 
    }
    If(trigger.isbefore && trigger.isdelete){
        System.debug('DELETE TRIGGER');
        OnQuoteLineTriggerHandler.CheckDelete(trigger.oldMap);
    }
    
    if (trigger.isafter && trigger.isupdate){
        if(Trigger.newMap.values()[0].Documenti_oppotunita_warranthub__c == null)
          WRT_IntegrazioneController.QuoteLineIntegration_SharePoint(Trigger.newMap.keySet());
        //OnQuoteLineTriggerHandler.QuoteStatoPagStatoFatt (trigger.old, trigger.new);        
    }
       
  }