trigger OnCondizioniTrigger on Condizioni__c (before insert, after insert, before update, after update, before delete) {
    
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disabilita_tutti_i_trigger__c)return;
    
 	if (trigger.isBefore && trigger.isInsert){
		OnCondizioniTriggerHandler.setMinimum(trigger.new);
    }	
    
    if (trigger.isafter && trigger.isinsert) {
      OnCondizioniTriggerHandler.OnCondizioniOpzionali (trigger.newMap);
      OnCondizioniTriggerHandler.AllineaRollupInsert(trigger.new);
      OnCondizioniTriggerHandler.aggiornaCampoCondizioniApprovazioneQuote_Insert(trigger.newMap);
      // OnCondizioniTriggerHandler.createCondizioniOpzionaliInfostore(Trigger.newMap.keySet());      
    }

    
    if (trigger.isBefore && trigger.isUpdate){
		OnCondizioniTriggerHandler.setMinimumOnUpdate(trigger.newMap, trigger.oldMap);
        //OnCondizioniTriggerFormule.calcoloImporto(trigger.newMap);
        
    }	

     if(Trigger.isAfter && Trigger.isUpdate){
    //   OnCondizioniTriggerHandler.updateCondizioniInfostore(Trigger.oldMap.keySet());
       OnCondizioniTriggerHandler.aggiornaCampoCondizioniApprovazioneQuote_Update(trigger.newMap, trigger.oldMap);
     }
    
        if (trigger.isbefore && trigger.isdelete) {
        OnCondizioniTriggerHandler.AllineaRollupDelete(trigger.old);
    }

 }