trigger OnCondizioneOpzionaleTrigger on Condizione_Opzionale__c (before insert,after insert, after update) {

    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disabilita_tutti_i_trigger__c)return;
    
    if(Trigger.isAfter && Trigger.isUpdate){
       OnCondizioneOpzionaleTriggerHandler.aggiornaCampoCondizioniApprovazioneQuote_Update(trigger.newMap, trigger.oldMap);
     }
     
    if (trigger.isafter && trigger.isinsert) {
      OnCondizioneOpzionaleTriggerHandler.aggiornaCampoCondizioniApprovazioneQuote_Insert(trigger.newMap);     
    }
    
    if (trigger.isbefore && trigger.isinsert) {
      OnCondizioneOpzionaleTriggerHandler.insertquoteline(trigger.new);     
    }
    
    
    // if(Trigger.isAfter && Trigger.isDelete){
    //     // Set<String> condizioniPadreIds = (Set<String>)Utilities.getSet(Trigger.oldMap.values(), 'CondizionePadre_WarrantCPQ__c');
    //     Set<String> condizioniIds = (Set<String>)Utilities.getSet(Trigger.oldMap.values(), 'Id');
    //     OnCondizioneOpzionaleTriggerHandler.eliminaCondizioniOpzionaliInfostore(condizioniIds);
    // }
}