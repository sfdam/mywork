trigger Allegato on Allegato__c (after insert, after update, before delete) {
  if (Funzionalita__c.getInstance().DisabilitaTriggers__c) return;
  T tu = T.getInstance();

  if(Trigger.isAfter && Trigger.isInsert)  TrgAllegato.inseritoAllegato(tu);
  if(Trigger.isAfter && Trigger.isUpdate)  TrgAllegato.aggiornatoAllegato(tu);
  if(Trigger.isBefore && Trigger.isDelete) TrgAllegato.eliminatoAllegato(tu);

}