trigger OnElaborazioneProcessoTrigger on Elaborazione_Processo__c (after insert) {
    
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_ElaborazioneProcessoTrigger__c) return;
    
    OnElaborazioneProcessoTriggerHandler.afterInsert(Trigger.new);
}