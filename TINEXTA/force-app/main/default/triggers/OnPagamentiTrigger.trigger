trigger OnPagamentiTrigger on Pagamenti__c (before delete, before insert, after insert, after update, before update, after delete) {
    
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disabilita_tutti_i_trigger__c)return;
    
        if (trigger.isbefore && trigger.isinsert) {
            OnPagamentiTriggerHandler.StimainLettere(trigger.new);
            
        }
    
    	if (trigger.isAfter && trigger.isInsert){
        	OnPagamentiTriggerHandler.setOnCondizioni(trigger.newMap); 
            OnPagamentiTriggerHandler.aggiornaCampoPagamentiApprovazioneQuote_Insert(trigger.newMap);
    	}
        
    	if (trigger.isafter && trigger.isupdate) {
            OnPagamentiTriggerHandler.AllineaRollupUpdate(trigger.newMap, trigger.oldMap);
            OnPagamentiTriggerHandler.setOnCondizioniup(trigger.oldMap, trigger.newMap);
        }
    
    	if (trigger.isbefore && trigger.isupdate) {
      		OnPagamentiTriggerHandler.StimainLettere(trigger.new);
            OnPagamentiTriggerHandler.updateStatoPagamento(trigger.newMap, trigger.oldMap);
            OnPagamentiTriggerHandler.aggiornaCampoPagamentiApprovazioneQuote_Update(trigger.newMap, trigger.oldMap);
        }
      
     if (trigger.isbefore && trigger.isdelete) {
        OnPagamentiTriggerHandler.AllineaRollupDelete(trigger.old);
    }

    // if(Trigger.isAfter && Trigger.isDelete){
    //     OnPagamentiTriggerHandler.eliminaPagamentiInfostore(new Set<String>( (List<String>)new List<Id>( Trigger.oldMap.keySet() ) ));
    // }

}