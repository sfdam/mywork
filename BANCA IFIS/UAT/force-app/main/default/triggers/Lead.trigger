trigger Lead on Lead (before insert, before update, after insert, after update) {
  if (Funzionalita__c.getInstance().DisabilitaTriggers__c) return;
  T tu = T.getInstance();

  if(T.isBeforeInsert()) {
  }

  if(T.isBeforeUpdate()) {
  }

  if(T.isAfterInsert()) {
    TrgLead.startConversionBatch(tu);
  }

  if(T.isAfterUpdate()) {
    TrgLead.startConversionBatch(tu);
  }
}