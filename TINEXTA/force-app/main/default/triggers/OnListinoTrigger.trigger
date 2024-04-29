trigger OnListinoTrigger on Business_Area_Warrant__c (after insert, after update, before delete) {
 Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disabilita_tutti_i_trigger__c)return;
    
    

    if (trigger.isafter && trigger.isinsert){
        system.debug('After Insert');
      OnListinoTriggerHandler.CalcoloImportoCondizioneInsert (trigger.new);
	  OnListinoTriggerHandler.CalcoloImportoCondizioniOpzionaliInsert(trigger.new);	
     }
    
        if (trigger.isafter && trigger.isupdate){
        system.debug('After Update');
          OnListinoTriggerHandler.CalcoloImportoCondizione (trigger.new, trigger.old);
      	  OnListinoTriggerHandler.CalcoloImportoCondizioniOpzionaliUpdate(trigger.new,trigger.old);
          OnListinoTriggerHandler.CalcoloImportoFinanziamento(trigger.new, trigger.old);
     }
    
            if (trigger.isbefore && trigger.isdelete){
                system.debug('Before Delete');
                OnListinoTriggerHandler.CalcoloImportoFinanziamentoDelete(trigger.old);
                OnListinoTriggerHandler.CalcoloCondizioneDelete(trigger.old);
                OnListinoTriggerHandler.CalcoloCondizioneOpzionaleDelete(trigger.old);
            }
    
   
    
    
}