trigger AssegnazioneAnagrafica on AssegnazioneAnagrafica__c (before insert, before update, after insert, after update) {
	Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.DisabilitaTriggerAssegnazioneAnagrafica__c) return;
    if( Trigger.isAfter && Trigger.isUpdate ){
        //Metodo che ricalcola l'assegnazione anagrafica
        // ERRORE 
        //WGC_TrgAssegnazioneAnagrafica.ricalcoloAssegnazioneAnagrafica(Trigger.oldMap, Trigger.newMap);
        WGC_TrgAssegnazioneAnagrafica.ricalcoloAssegnazioneAnagrafica_New(Trigger.oldMap, Trigger.newMap);
    }
}