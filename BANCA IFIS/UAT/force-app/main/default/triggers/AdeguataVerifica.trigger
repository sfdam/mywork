trigger AdeguataVerifica on AdeguataVerifica__c (after insert, after update) {
  if (Funzionalita__c.getInstance().DisabilitaTriggers__c) return;
  T tu = T.getInstance();

  if(T.isAfterInsert() || T.isAfterUpdate()) {
    TrgAdeguataVerifica.allineaAdeguataVerifica(tu);
  }
}