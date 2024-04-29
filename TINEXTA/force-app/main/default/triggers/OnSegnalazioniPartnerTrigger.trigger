trigger OnSegnalazioniPartnerTrigger on Segnalazioni__c (after insert, after update) {
    
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disabilita_tutti_i_trigger__c)return;
    
        if(trigger.isInsert){
        if(trigger.isAfter){
            OnSegnalazioniPartnerTriggerHandler.aggiornanumerosegnalazione(Trigger.new);
            system.debug('After Insert');
        }
        }
            
       if(trigger.isUpdate){
        if(trigger.isafter){
                   system.debug('After Update');
        }
        
    }
}