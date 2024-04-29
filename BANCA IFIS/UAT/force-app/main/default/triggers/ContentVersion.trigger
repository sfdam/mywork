trigger ContentVersion on ContentVersion (before insert, before update, after update, after insert) {
  if (Funzionalita__c.getInstance().DisabilitaTriggers__c) return;
  T tu = T.getInstance();

  if (T.isAfterInsert()) {
    TrgContentVersion.collegaOpportunita(tu);
  }
}