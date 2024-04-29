/**
 * Trigger che cancella gli oggetti Allegato__c collegati a questi documenti.
 */
trigger ContentDocument on ContentDocument (before delete) {
  if (Funzionalita__c.getInstance().DisabilitaTriggers__c) return;

  TrgContentDocument.cancellaAllegati(Trigger.old);

}