trigger Linea on Linea__c (after update) {
  if (Funzionalita__c.getInstance().DisabilitaTriggers__c) return;
  T tu = T.getInstance();

  if (T.isAfterUpdate()) {
    TrgLinea.inviaMail(tu);
  }

}